# Hosts config

| Name   | Description                 |
| ------ | --------------------------- |
| `meow` | Lenovo laptop, main machine |
| `wsl`  | WSL2 NixOS environment      |

Shared configuration lives in `system/`. Host-specific configs live inside the
host directory. Each host imports its own modules in `default.nix`.
