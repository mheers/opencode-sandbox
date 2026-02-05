# OpenCode sandbox wrapper

Docker-based wrapper around the OpenCode CLI with a consistent toolchain and
runtime setup.

## Requirements

- Docker (including access to `/var/run/docker.sock` if you want Docker-in-Docker)

## Build

```bash
make build
# or
docker build -t mheers/opencode-sandbox:latest .
```

The image installs OpenCode plus common CLI tools (bat, fd, fzf, ripgrep, tig),
build tooling, Node.js, Go, and additional system libraries used by
agent-browser.

## Run

Symlink the wrapper script and use it like the original CLI:

```bash
ln -s "$(pwd)/oc" ~/bin/oc
oc
```

The wrapper creates one container per working directory (hashed name), reuses it
if present, and mounts:

- The current directory at `/home/user/project`
- OpenCode config and state directories under `~/.opencode`, `~/.config/opencode`,
  `~/.local/share/opencode`, and `~/.local/state/opencode`
- `~/.gitconfig` (host) and `./.gitconfig.oc` (container overrides)
- `~/.ssh` (read-only) and `~/.gnupg`
- `/var/run/docker.sock` and the matching Docker group when available

GPG signing works out of the box; the wrapper mounts `~/.gnupg` and forwards
`GPG_TTY` when the agent socket is available.

SSH agent forwarding is enabled when `SSH_AUTH_SOCK` is present on the host.

## Publish

```bash
make publish
```
