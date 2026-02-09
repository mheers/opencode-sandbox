FROM ubuntu:24.04

USER root
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bat \
        bash \
        build-essential \
        ca-certificates \
        coreutils \
        curl \
        dnsutils \
        docker-compose \
        docker.io \
        fd-find \
        fzf \
        git \
        gnupg \
        iproute2 \
        iputils-ping \
        jq \
        less \
        libasound2t64 \
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
    mkdir -p /home/user; \
    HOME=/home/user curl -fsSL https://ocx.kdco.dev/install.sh | sh; \
    HOME=/home/user /usr/local/bin/ocx init --global; \
    HOME=/home/user /usr/local/bin/ocx registry add https://ocx-kit.kdco.dev --name kit --global; \
    HOME=/home/user /usr/local/bin/ocx profile add work --from kit/omo; \
    chown -R 1000:1000 /home/user/.config /home/user/.ocx || true

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

ENV PATH="/home/user/.opencode/bin:/home/user/.bun/bin:/home/user/.ocx/bin:/usr/local/go/bin:${PATH}"

RUN git clone --depth 1 https://github.com/vercel-labs/agent-browser /opt/agent-browser \
    && cd /opt/agent-browser \
    && npm install \
    && npm run build \
    && npm install -g /opt/agent-browser

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

RUN cat <<'EOF' > /etc/zsh/zshrc
export ZSH=/opt/oh-my-zsh
ZSH_THEME="bira"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
 export PATH="/home/user/.opencode/bin:/home/user/.bun/bin:/home/user/.ocx/bin:${PATH}"
export GPG_TTY=$(tty)
gpgconf --launch gpg-agent >/dev/null 2>&1
export AGENT_BROWSER_HOME=/opt/agent-browser
export AGENT_BROWSER_SOCKET_DIR=/home/user/.local/state/agent-browser
mkdir -p "$AGENT_BROWSER_SOCKET_DIR" || true
chmod 700 "$AGENT_BROWSER_SOCKET_DIR" || true
alias ocx-init='ocx init || true; ocx registry add https://registry.kdco.dev --name kdco || true; ocx add kdco/workspace || true'
export ZSH_DISABLE_COMPFIX=true
export ZSH_CACHE_DIR=/tmp/zsh-cache
export ZSH_COMPDUMP=$ZSH_CACHE_DIR/.zcompdump
mkdir -p "$ZSH_CACHE_DIR"
source $ZSH/oh-my-zsh.sh
EOF

RUN printf '%s\n' \
    'source /etc/zsh/zshrc' \
    > /home/user/.zshrc \
    && chown 1000:1000 /home/user/.zshrc

RUN printf '%s\n' \
    'export PATH="/home/user/.opencode/bin:/home/user/.bun/bin:/home/user/.ocx/bin:${PATH}"' \
    'export GPG_TTY=$(tty)' \
    'gpgconf --launch gpg-agent >/dev/null 2>&1' \
    'export AGENT_BROWSER_HOME=/opt/agent-browser' \
    'export AGENT_BROWSER_SOCKET_DIR=/home/user/.local/state/agent-browser' \
    'mkdir -p "$AGENT_BROWSER_SOCKET_DIR" || true' \
    'chmod 700 "$AGENT_BROWSER_SOCKET_DIR" || true' \
    'alias ocx-init="ocx init || true; ocx registry add https://registry.kdco.dev --name kdco || true; ocx add kdco/workspace || true"' \
    >> /etc/bash.bashrc

USER user
