use std::os::fd::AsRawFd;
use std::os::raw::{c_char, c_int, c_ulong, c_void};
use std::os::unix::ffi::OsStrExt;
use std::os::unix::process::CommandExt;

const MS_RDONLY: c_ulong = 0x01;
const MS_NOSUID: c_ulong = 0x02;
const MS_NODEV: c_ulong = 0x04;
const MS_RELATIME: c_ulong = 0x200000;
const MS_STRICTATIME: c_ulong = 0x1000000;

const CLONE_NEWTIME: c_int = 0x80;

unsafe extern "C" {
    fn mount(
        src: *const c_char,
        target: *const c_char,
        fstype: *const c_char,
        flags: c_ulong,
        data: *const c_void,
    ) -> c_int;
    fn getrandom(buf: *mut u8, buflen: usize, flags: u32) -> c_int;
    fn unshare(flags: c_int) -> c_int;
    fn ioctl(fd: c_int, request: c_int, ...) -> c_int;
}

fn gen_machine_id() -> String {
    use std::fmt::Write as _;
    let mut bytes: [u8; 16] = [0; 16];
    if unsafe { getrandom(bytes.as_mut_ptr(), 16, 0) } == -1 {
        eprintln!("[micro-activate] getrandom failed!");
    }
    let mut result = String::with_capacity(32);
    for b in bytes {
        let _ = write!(result, "{:02x}", b);
    }
    result
}

fn parse_tmpfiles_line(line: &str) -> Option<(&str, &str)> {
    // NOTE: does not support actual whitespace inside quotes
    // (that's not gonna appear in these files we parse)
    let mut it = line
        .split_whitespace()
        .map(|s| s.trim_start_matches('\'').trim_end_matches('\''));
    let instr = it.next()?;
    if !instr.starts_with('L') {
        return None;
    }
    let src = it.next()?;
    let _ = it.next()?;
    let _ = it.next()?;
    let _ = it.next()?;
    let _ = it.next()?;
    let dst = it.next()?;
    Some((src, dst))
}

fn link_tmpfiles(contents: &[u8]) -> Result<(), std::io::Error> {
    for (src, dst) in str::from_utf8(contents)
        .unwrap()
        .lines()
        .flat_map(parse_tmpfiles_line)
    {
        std::os::unix::fs::symlink(dst, src)?;
    }
    Ok(())
}

fn main() -> Result<(), std::io::Error> {
    if let Ok(status_str) = std::env::var("EXIT_CODE") {
        // When muvm-remote is init, it does this upon exit..
        // But with systemd, we need our own little handler somewhere. Why not this binary..
        let code = if status_str == "exited" {
            std::env::var("EXIT_STATUS")
                .unwrap()
                .parse::<i32>()
                .unwrap()
        } else {
            eprintln!(
                "muvm-remote process {status_str} ({:?})",
                std::env::var("EXIT_STATUS")
            );
            1
        };
        let rootdir = std::fs::OpenOptions::new().read(true).open("/").unwrap();
        unsafe {
            ioctl(rootdir.as_raw_fd(), 0x7602, code);
        }
        return Ok(());
    }

    let closure = std::env::var("MICROVM_CLOSURE").unwrap();

    // systemd really wants /run to be a mountpoint and will mount a tmpfs on its own
    // if it's not already a mountpoint. Well, it's correct: reaching into virtiofs
    // (which is what not-mounting would entail) for /run stuff is not great.
    //
    // Let's preserve the fixed passed-in files and set up the NixOS symlinks in the new mount.
    let resolv_conf = std::fs::read("/run/resolv.conf")?;
    let localtime = std::fs::read("/run/localtime")?;
    assert_eq!(
        unsafe {
            mount(
                c"tmpfs".as_ptr(),
                c"/run".as_ptr(),
                c"tmpfs".as_ptr(),
                MS_NOSUID | MS_NODEV | MS_STRICTATIME,
                std::ptr::null(),
            )
        },
        0
    );
    std::fs::write("/run/localtime", &localtime)?;
    std::fs::write("/run/resolv.conf", &resolv_conf)?;
    std::fs::write("/run/machine-id", &gen_machine_id())?;
    std::fs::create_dir("/run/systemd")?;
    std::os::unix::fs::symlink("/opt/systemd", "/run/systemd/system")?;
    std::os::unix::fs::symlink(&closure, "/run/current-system")?;
    if let Ok(tmp_graphics) =
        std::fs::read(format!("{closure}/etc/tmpfiles.d/graphics-driver.conf"))
    {
        link_tmpfiles(&tmp_graphics)?;
    } else {
        eprintln!("[micro-activate] Could not find the closure's graphics-driver.conf!");
    }

    // We need the /etc metadata overlay not just for abstract correctness, but even just to
    // allow the regular user to run systemctl (it doesn't like passwd being owned by non-root)..
    let metadata_img = std::fs::read_link(format!("{closure}/etc-metadata-image"))
        .expect("The closure must use an immutable /etc overlay!");
    let basedir = std::fs::read_link(format!("{closure}/etc-basedir"))
        .expect("The closure must use an immutable /etc overlay!");
    let overlay_opts = std::ffi::CString::new(format!(
        "redirect_dir=on,metacopy=on,lowerdir=/run/etc.meta::{}",
        basedir.display()
    ))
    .unwrap();
    std::fs::create_dir("/run/etc.meta")?;
    std::fs::remove_file("/etc")?;
    std::fs::create_dir("/etc")?;
    unsafe {
        assert_eq!(
            mount(
                metadata_img.as_os_str().as_bytes().as_ptr() as *const c_char,
                c"/run/etc.meta".as_ptr(),
                c"erofs".as_ptr(),
                MS_RDONLY | MS_NODEV | MS_NOSUID,
                std::ptr::null(),
            ),
            0
        );
        assert_eq!(
            mount(
                c"overlay".as_ptr(),
                c"/etc".as_ptr(),
                c"overlay".as_ptr(),
                MS_NODEV | MS_NOSUID | MS_RELATIME,
                overlay_opts.as_ptr() as *const c_void,
            ),
            0
        );
    }

    if let Ok(offset) = std::env::var("BOOT_TIME_OFFSET") {
        if unsafe { unshare(CLONE_NEWTIME) } != 0 {
            eprintln!("[micro-activate] Could not unshare time!");
        } else {
            std::fs::write(
                "/proc/self/timens_offsets",
                format!("monotonic {offset}\nboottime {offset}\n"),
            )?;
        }
    }

    let mut args = std::env::args_os().skip(1);
    let cmd = args.next().unwrap();
    Err(std::process::Command::new(cmd).args(args).exec())
}
