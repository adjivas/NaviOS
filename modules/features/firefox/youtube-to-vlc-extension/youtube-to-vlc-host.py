#!/usr/bin/env python3

import json
import shutil
import struct
import subprocess
import sys
import os
from urllib.parse import parse_qs, urlparse


MAX_MESSAGE_SIZE = 1024 * 1024

ALLOWED_HOSTS = {
    "youtube.com",
    "www.youtube.com",
    "m.youtube.com",
}


def find_program(name):
    path = shutil.which(name)

    if path is None:
        raise RuntimeError(f"Program not found in PATH: {name}")

    return path


def send(message):
    payload = json.dumps(message).encode("utf-8")

    sys.stdout.buffer.write(
        struct.pack("=I", len(payload))
    )

    sys.stdout.buffer.write(payload)
    sys.stdout.buffer.flush()


def read_request():
    header = sys.stdin.buffer.read(4)

    if len(header) != 4:
        raise RuntimeError("Missing native message")

    size = struct.unpack("=I", header)[0]

    if size > MAX_MESSAGE_SIZE:
        raise RuntimeError("Native message is too large")

    payload = sys.stdin.buffer.read(size)

    if len(payload) != size:
        raise RuntimeError("Incomplete native message")

    return json.loads(payload)


def validate_request(request):
    if request.get("command") != "play":
        raise RuntimeError("Invalid command")

    raw_url = request.get("url", "")

    if not isinstance(raw_url, str):
        raise RuntimeError("Invalid URL")

    url = urlparse(raw_url)

    if not (
        url.scheme == "https"
        and url.hostname in ALLOWED_HOSTS
        and url.path == "/watch"
        and parse_qs(url.query).get("v")
    ):
        raise RuntimeError("Invalid YouTube video URL")

    return raw_url

def open_in_vlc(raw_url):
    vlc = find_program("vlc")

    process_env = os.environ.copy()

    for variable in (
        "PYTHONPATH",
        "PYTHONHOME",
        "NIX_PYTHONPATH",
    ):
        process_env.pop(variable, None)

    subprocess.Popen(
        [
            vlc,
            "--no-qt-video-autoresize",
            raw_url,
        ],
        stdin=subprocess.DEVNULL,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
        env=process_env,
        start_new_session=True,
    )

def main():
    try:
        request = read_request()
        raw_url = validate_request(request)

        open_in_vlc(raw_url)

        send({
            "ok": True,
        })

    except Exception as error:
        send({
            "ok": False,
            "error": str(error),
        })


if __name__ == "__main__":
    main()
