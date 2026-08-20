# munix

WIP: A microVM runner for NixOS systems with desktop integration, powered by muvm/libkrun.

## Quick Start

**1. Build a test VM:**
```bash
nix build '.#nixosConfigurations.testvm-x86_64.config.system.build.toplevel' -o testvm
```

**2. Run the VM:**
```bash
nix run '.#munix' -- testvm
```

This will start an interactive bash session inside the microVM.

**Run a specific command:**
```bash
nix run '.#munix' -- testvm fastfetch
```

**Create a custom VM:**

Use the template to bootstrap a new munix project:

```bash
mkdir my-vm && cd my-vm
nix flake init -t 'git+https://git.clan.lol/clan/munix#musictest'
git init && git add flake.nix
nix run
```

This creates a `flake.nix` with a music player demo (MPD + Euphonica). Edit the module to customize your VM.

## munix Options

- `--uid UID`, `-u UID` - Set microVM UID (default: 1337)
- `--gid GID`, `-g GID` - Set microVM GID (default: 1337)
- `--no-gpu` - Disable GPU acceleration
- `--no-wayland` - Disable Wayland support
- `--no-pipewire` - Disable PipeWire audio
- `--no-network` - Disable networking (guest has no outbound access)
- `--x11` - Enable X11 support
- `--bind SRC DST` - Bind mount SRC to DST in the VM
- `--ro-bind SRC DST` - Read-only bind mount
- `--expose PATH` - Expose PATH in the VM at the same location
- `--ro-expose PATH` - Expose PATH read-only

Example with options:
```bash
nix run '.#munix' -- --no-gpu --ro-expose /home/user/data testvm htop
```

## Development

Working on muvm & munix locally (not built into the nix store):

```bash
cd muvm && cargo build --locked --release
PATH=$PWD/muvm/target/release:$PATH ./munix testvm
```

## Requirements

- Linux system with KVM support (`/dev/kvm`)
- For GPU acceleration: Kernel 6.13+ with compatible drivers (amdgpu, msm)
- For Wayland: `XDG_RUNTIME_DIR` and `WAYLAND_DISPLAY` set

## Known Issues
