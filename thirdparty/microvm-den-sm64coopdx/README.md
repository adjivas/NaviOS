# MicroVM

How to run:
```shell
% nix run .#runnable-sm64coopdx-microvm
```

How to play:
* [NoVNC](https://127.0.0.1:6080/vnc.html?autoconnect=1&scale=local&resize=scale)
* [Moonlight](https://127.0.0.1:47990)
* [Moonlight Web](https://127.0.0.1:8080)

How to log:
```shell
% journalctl -u home-manager-alice.service
% journalctl -u microvm-selfsigned-cert --user
% journalctl -u cage --user
% journalctl -u wayvnc --user
% journalctl -u novnc --user
% journalctl -u sunshine --user
% journalctl -u moonlight-web-stream --user
```
