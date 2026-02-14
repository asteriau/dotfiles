# About ❄️

In-house baked configs for Home-Manager and NixOS. Borrowed bits sprinkled on
top. Using [flakes](https://nixos.wiki/wiki/Flakes) and
[flake-parts](https://github.com/hercules-ci/flake-parts).

See an overview of the flake outputs by running
`nix flake show github:asteriau/dotfiles`.

> [!WARNING]
> This flake is tailored to my personal, opinionated daily workflow.
> Treat it as a reference rather than a drop-in replacement.
>
> While it may be possible to just replace the user, hostname, and hardware
> configuration, doing so is **not recommended**.

## 🗃️ Structure

- [hosts](./hosts): host-specific configuration
- [home](./home): [Home Manager](https://github.com/nix-community/home-manager)
  config
- [lib](./lib): helper functions
- [modules](./modules): exported NixOS modules
- [pkgs](./pkgs): package definitions
- [system](./system): NixOS configuration common between hosts

Each directory has its own README if you want to dive deeper.

# 📦 Exported packages

This flake exports several packages. To get a list of available packages, run

```console
nix flake show github:asteriau/dotfiles
```

Run packages directly with the below command, replacing `<packageName>` with the desired package:

```console
nix run github:asteriau/dotfiles#<packageName>
```

Or install from the `packages` output. For example:

```nix
# flake.nix
{
  inputs.asteriau-dotfiles = {
    url = "github:asteriau/dotfiles";
    inputs.nixpkgs.follows = "nixpkgs";
  };
}

# configuration.nix
{pkgs, inputs, ...}: {
  environment.systemPackages = [
    inputs.asteriau-dotfiles.packages."x86_64-linux".<packageName>
  ];
}
```

## 💻 Desktop preview

Currently, my widgets are created using [QuickShell](https://github.com/quickshell-mirror/quickshell/).

<details>
<summary>🌙</summary>

![Dark Mode Preview](https://github.com/asteriau/dotfiles/blob/main/assets/repo/preview-dark.png?raw=true)

</details>
<details>
<summary>
☀️
</summary>
insert catppuccin latte brainrot
</details>

# 💾 Resources

Other configurations or places from where I learned and copied:

- [mynixos](https://mynixos.com/) saved me from option hell
- [zero-to-nix](https://zero-to-nix.com/) teached me how nix works
- [fufexan/dotfiles](https://github.com/fufexan/dotfiles) the goat (he thanks more people there btw)

There surely are more but I tend to forget. Regardless, I am thankful to all of them. <3
