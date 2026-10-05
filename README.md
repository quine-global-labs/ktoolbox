# Ktoolbox

A simple Flutter desktop GUI for managing [Toolbox](https://containertoolbx.org/) containers on Linux.

Inspired by [Kontainer](https://github.com/DenysMb/Kontainer), which does the same thing for Distrobox.
Toolbox has a much smaller command surface than Distrobox (no clone, assemble, upgrade, or
app/binary export), so Ktoolbox stays intentionally minimal:

- List Toolbox containers (via `podman`, filtered by the `com.github.containers.toolbox` label)
- Create a container (optional name + image)
- Enter a container in your terminal (tries Ptyxis, Konsole, GNOME Terminal, then xterm)
- Remove a container

## Requirements

- [Podman](https://podman.io/) and [Toolbox](https://containertoolbx.org/) installed
- A terminal emulator on `$PATH` (ptyxis, konsole, gnome-terminal, or xterm)

## Running

```sh
flutter run -d linux
```

## Building

```sh
flutter build linux
```
