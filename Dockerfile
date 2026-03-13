FROM ubuntu:24.04

USER root
ENV DEBIAN_FRONTEND=noninteractive

# Add Docker's official apt repository for docker-ce-cli and docker-compose-plugin
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl gnupg \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
    && chmod a+r /etc/apt/keyrings/docker.asc \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
    > /etc/apt/sources.list.d/docker.list \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    bat \
    bash \
    build-essential \
    ca-certificates \
    coreutils \
    curl \
    dnsutils \
    docker-ce-cli \
    docker-compose-plugin \
    fd-find \
    fzf \
    git \
    gnupg \
    iproute2 \
    iputils-ping \
    jq \
    less \
    libnotify-bin \
    libasound2t64 \
    pulseaudio-utils \
    sound-theme-freedesktop \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libatspi2.0-0 \
    libcairo-gobject2 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libfontconfig1 \
    libfreetype6 \
    libgbm1 \
    libgdk-pixbuf-2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libx11-6 \
    libx11-xcb1 \
    libxcb-shm0 \
    libxcb1 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxkbcommon0 \
    libxrandr2 \
    libxrender1 \
    libxshmfence1 \
    mtr-tiny \
    net-tools \
    nmap \
    openssh-client \
    pkg-config \
    postgresql-client \
    procps \
    ripgrep \
    tar \
    tcpdump \
    tig \
    traceroute \
    unzip \
    usbutils \
    wget \
    xz-utils \
    zsh \
    zip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && npm install -g pnpm \
    && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir -p /home/user; \
    export HOME=/home/user; \
    export BUN_INSTALL=/home/user/.bun; \
    curl -fsSL https://bun.com/install | bash; \
    [ -d /home/user/.bun ] && chown -R 1000:1000 /home/user/.bun

RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
    amd64) go_arch="amd64" ;; \
    arm64) go_arch="arm64" ;; \
    *) echo "Unsupported architecture: $arch"; exit 1 ;; \
    esac; \
    go_version="$(curl -fsSL https://go.dev/dl/?mode=json | jq -r '.[0].version')"; \
    curl -fsSL "https://go.dev/dl/${go_version}.linux-${go_arch}.tar.gz" -o /tmp/go.tgz; \
    rm -rf /usr/local/go; \
    tar -C /usr/local -xzf /tmp/go.tgz; \
    rm /tmp/go.tgz

RUN curl -fsSL https://opencode.ai/install | bash \
    && ln -s /usr/bin/batcat /usr/local/bin/bat \
    && ln -s /usr/bin/fdfind /usr/local/bin/fd

RUN GOBIN=/usr/local/bin /usr/local/go/bin/go install github.com/simonw/showboat@latest
RUN GOBIN=/usr/local/bin /usr/local/go/bin/go install github.com/entireio/cli/cmd/entire@latest

RUN set -eux; \
    mkdir -p /home/user; \
    HOME=/home/user bash -lc "printf 'y\n2\n1\n' | npx -y get-shit-done-cc@latest"; \
    chown -R 1000:1000 /home/user/.config /home/user/.local/share /home/user/.local/state || true

ENV PATH="/home/user/.opencode/bin:/home/user/.bun/bin:/usr/local/go/bin:${PATH}"

RUN npm install -g agent-browser

RUN prefix="$(npm prefix -g)" \
    && "${prefix}/bin/agent-browser" install

RUN if id -u user >/dev/null 2>&1; then \
    true; \
    elif getent passwd 1000 >/dev/null 2>&1; then \
    useradd -m user; \
    else \
    useradd -m -u 1000 user; \
    fi \
    && usermod -s /usr/bin/zsh user \
    && mkdir -p /home/user/go \
    && chown -R 1000:1000 /home/user \
    && chmod 755 /home/user

RUN git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh /opt/oh-my-zsh \
    && git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions /opt/oh-my-zsh/custom/plugins/zsh-autosuggestions \
    && git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting /opt/oh-my-zsh/custom/plugins/zsh-syntax-highlighting \
    && chmod -R o+rX /opt/oh-my-zsh

RUN printf '%s\n' \
    'export ZSH=/opt/oh-my-zsh' \
    'ZSH_THEME="bira"' \
    'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' \
    'export PATH="/home/user/.opencode/bin:/home/user/.bun/bin:${PATH}"' \
    'export GPG_TTY=$(tty)' \
    'gpgconf --launch gpg-agent >/dev/null 2>&1' \
    'export AGENT_BROWSER_HOME=/opt/agent-browser' \
    'export AGENT_BROWSER_SOCKET_DIR=/home/user/.local/state/agent-browser' \
    'mkdir -p "$AGENT_BROWSER_SOCKET_DIR" || true' \
    'chmod 700 "$AGENT_BROWSER_SOCKET_DIR" || true' \
    'export ZSH_DISABLE_COMPFIX=true' \
    'export ZSH_CACHE_DIR=/tmp/zsh-cache' \
    'export ZSH_COMPDUMP=$ZSH_CACHE_DIR/.zcompdump' \
    'mkdir -p "$ZSH_CACHE_DIR"' \
    'source $ZSH/oh-my-zsh.sh' \
    > /etc/zsh/zshrc

RUN printf '%s\n' \
    'source /etc/zsh/zshrc' \
    > /home/user/.zshrc \
    && chown 1000:1000 /home/user/.zshrc

RUN printf '%s\n' \
    'export PATH="/home/user/.opencode/bin:/home/user/.bun/bin:${PATH}"' \
    'export GPG_TTY=$(tty)' \
    'gpgconf --launch gpg-agent >/dev/null 2>&1' \
    'export AGENT_BROWSER_HOME=/opt/agent-browser' \
    'export AGENT_BROWSER_SOCKET_DIR=/home/user/.local/state/agent-browser' \
    'mkdir -p "$AGENT_BROWSER_SOCKET_DIR" || true' \
    'chmod 700 "$AGENT_BROWSER_SOCKET_DIR" || true' \
    >> /etc/bash.bashrc

COPY skills/showboat/SKILL.md /opt/opencode/skills/showboat/SKILL.md
COPY skills/agent-browser/SKILL.md /opt/opencode/skills/agent-browser/SKILL.md
COPY skills/effective-go/SKILL.md /opt/opencode/skills/effective-go/SKILL.md
COPY skills/vue/SKILL.md /opt/opencode/skills/vue/SKILL.md
COPY skills/nuxt/SKILL.md /opt/opencode/skills/nuxt/SKILL.md
COPY skills/pinia/SKILL.md /opt/opencode/skills/pinia/SKILL.md
COPY skills/vite/SKILL.md /opt/opencode/skills/vite/SKILL.md
COPY skills/vitepress/SKILL.md /opt/opencode/skills/vitepress/SKILL.md
COPY skills/vitest/SKILL.md /opt/opencode/skills/vitest/SKILL.md
COPY skills/unocss/SKILL.md /opt/opencode/skills/unocss/SKILL.md
COPY skills/vue-best-practices/SKILL.md /opt/opencode/skills/vue-best-practices/SKILL.md
COPY skills/vue-router-best-practices/SKILL.md /opt/opencode/skills/vue-router-best-practices/SKILL.md
COPY skills/vue-testing-best-practices/SKILL.md /opt/opencode/skills/vue-testing-best-practices/SKILL.md
COPY skills/vueuse-functions/SKILL.md /opt/opencode/skills/vueuse-functions/SKILL.md
COPY skills/adapt/SKILL.md /opt/opencode/skills/adapt/SKILL.md
COPY skills/animate/SKILL.md /opt/opencode/skills/animate/SKILL.md
COPY skills/audit/SKILL.md /opt/opencode/skills/audit/SKILL.md
COPY skills/bolder/SKILL.md /opt/opencode/skills/bolder/SKILL.md
COPY skills/clarify/SKILL.md /opt/opencode/skills/clarify/SKILL.md
COPY skills/colorize/SKILL.md /opt/opencode/skills/colorize/SKILL.md
COPY skills/critique/SKILL.md /opt/opencode/skills/critique/SKILL.md
COPY skills/delight/SKILL.md /opt/opencode/skills/delight/SKILL.md
COPY skills/distill/SKILL.md /opt/opencode/skills/distill/SKILL.md
COPY skills/extract/SKILL.md /opt/opencode/skills/extract/SKILL.md
COPY skills/frontend-design/SKILL.md /opt/opencode/skills/frontend-design/SKILL.md
COPY skills/harden/SKILL.md /opt/opencode/skills/harden/SKILL.md
COPY skills/normalize/SKILL.md /opt/opencode/skills/normalize/SKILL.md
COPY skills/onboard/SKILL.md /opt/opencode/skills/onboard/SKILL.md
COPY skills/optimize/SKILL.md /opt/opencode/skills/optimize/SKILL.md
COPY skills/polish/SKILL.md /opt/opencode/skills/polish/SKILL.md
COPY skills/quieter/SKILL.md /opt/opencode/skills/quieter/SKILL.md
COPY skills/teach-impeccable/SKILL.md /opt/opencode/skills/teach-impeccable/SKILL.md

# Entrypoint script: merges /opt/opencode/skills into ~/.config/opencode/skills at startup
# Host-installed skills take precedence (cp -n = no-clobber)
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh \
    && chmod -R a+rX /opt/opencode/skills

# notify-send wrapper: injects --app-name="OpenCode" so KDE Connect can
# forward OpenCode completion notifications to Android. The plugin
# (@mohak34/opencode-notifier) calls notify-send without --app-name, so KDE
# Connect has no way to identify the source and its forwarding rules don't
# fire. /home/user/bin precedes /usr/bin in PATH, so this wrapper intercepts
# every bare `notify-send` call and adds the flag when absent.
RUN mkdir -p /home/user/bin \
    && printf '%s\n' \
        '#!/bin/bash' \
        '# Injects --app-name="OpenCode" when not already provided so KDE Connect' \
        '# can forward notifications to Android.' \
        'HAS_APP_NAME=0' \
        'for arg in "$@"; do' \
        '    case "$arg" in' \
        '        --app-name*|-a*)' \
        '            HAS_APP_NAME=1' \
        '            break' \
        '            ;;' \
        '    esac' \
        'done' \
        'if [ "$HAS_APP_NAME" -eq 0 ]; then' \
        '    exec /usr/bin/notify-send --app-name="OpenCode" "$@"' \
        'else' \
        '    exec /usr/bin/notify-send "$@"' \
        'fi' \
        > /home/user/bin/notify-send \
    && chmod +x /home/user/bin/notify-send \
    && chown -R 1000:1000 /home/user/bin

USER user
