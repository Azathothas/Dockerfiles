```mathematica
 80K └─┬ main
 40K   ├─┬ s6-rc.services
 20K   │ ├─┬ tailscaled
4.0K   │ │ ├── type
4.0K   │ │ ├── run.default.userspace.zapper
4.0K   │ │ ├── run.default.userspace
4.0K   │ │ └── run.default.tun
 16K   │ └─┬ ssh
4.0K   │   ├── type
4.0K   │   ├── run.zapper
4.0K   │   └── run.default
 16K   ├── x86_64-ubuntu.dockerfile
 12K   ├─┬ systemd.services
4.0K   │ ├── tailscaled.service.userspace
4.0K   │ └── tailscaled.service.tun
8.0K   └── README.md
```
