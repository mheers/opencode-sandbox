# OpenCode Sandbox Wrapper

Purpose
- Build and run a Docker image that provides a stable CLI toolchain for OpenCode.

Quick Commands
- Build image: `docker build -t mheers/opencode-sandbox:latest .`
- Run via wrapper: `./oc` (recommended) or symlink `oc` into PATH.

Wrapper Script Behavior (`oc`)
- Creates one container per working directory using a name hash: `opencode-<hash>`.
- Reuses existing containers if present; otherwise starts a new one.
- Mounts the current repo to `/home/user/project` and forwards:
  - OpenCode config/state under `~/.opencode`, `~/.config/opencode`, `~/.local/share/opencode`, `~/.local/state/opencode`
  - Host `~/.gitconfig` and optional `./.gitconfig.oc` overrides
  - `~/.ssh` (read-only) and `~/.gnupg`
  - Docker socket and matching Docker group if available

Toolchain Notes
- Bun installs to `/usr/local/bun/bin` and is added to PATH.
- ocx installs to `/home/user/.ocx/bin` and is added to PATH.
- OpenCode installs to `/home/user/.opencode/bin` and is added to PATH.

ocx Setup (in image)
- Install: `curl -fsSL https://ocx.kdco.dev/install.sh | sh`
- Init: `ocx init --global`
- Registry: `ocx registry add https://ocx-kit.kdco.dev --name kit --global`
- Profile: `ocx profile add work --from kit/omo`

Default Shell
- `/usr/bin/zsh` with oh-my-zsh and plugins.

Agent Tools
- `showboat` — create executable demo documents that prove an agent's work. Installed via `go install`.
- `agent-browser` — browser automation CLI for AI agents. Installed via npm from vercel-labs/agent-browser.

OpenCode Skills (global, baked into the image)
- Skills are installed to `/home/user/.config/opencode/skills/`.
- `showboat` — guides the agent to create a `demo.md` showing the feature it just built.
- `agent-browser` — guides the agent to start and interact with a real web browser.
- Source files live in `skills/` in this repo and are COPYed into the image.

Validation
- In a running container: `command -v bun` and `command -v ocx` should succeed.
- `command -v showboat` and `command -v agent-browser` should succeed.
- `ls /home/user/.config/opencode/skills/showboat/SKILL.md` and `ls /home/user/.config/opencode/skills/agent-browser/SKILL.md` should succeed.
