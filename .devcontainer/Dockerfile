FROM debian:bookworm-slim

ARG USERNAME=developer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV DEBIAN_FRONTEND=noninteractive

# Install all dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    git \
    ca-certificates \
    gnupg \
    sudo \
    zsh \
    vim \
    jq \
    unzip \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Install Python 3.12
RUN curl -fsSL https://www.python.org/ftp/python/3.12.4/Python-3.12.4.tgz | tar xz \
    && cd Python-3.12.4 \
    && ./configure --enable-optimizations \
    && make -j$(nproc) \
    && make altinstall \
    && cd .. && rm -rf Python-3.12.4 \
    && ln -sf /usr/local/bin/python3.12 /usr/local/bin/python \
    && ln -sf /usr/local/bin/python3.12 /usr/local/bin/python3 \
    && ln -sf /usr/local/bin/pip3.12 /usr/local/bin/pip \
    && ln -sf /usr/local/bin/pip3.12 /usr/local/bin/pip3

# Install Node.js 20.x LTS
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install global npm packages (as root)
RUN npm install -g pnpm@latest @anthropic-ai/claude-code

# Install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && mv /root/.local/bin/uv /usr/local/bin/ \
    && mv /root/.local/bin/uvx /usr/local/bin/

# Install pytest globally
RUN pip install pytest

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME -s /bin/zsh \
    && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME
WORKDIR /home/$USERNAME

# Configure Claude Code with MCP servers
RUN echo '{"mcpServers":{"deepwiki":{"type":"http","url":"https://mcp.deepwiki.com/mcp"}}}' > /home/$USERNAME/.claude.json

# Add first-run reminders to shell
RUN echo '' >> /home/$USERNAME/.zshrc && \
    echo '# First-time setup reminders' >> /home/$USERNAME/.zshrc && \
    echo 'if [ ! -f ~/.gitconfig ]; then echo "⚠️  Git not configured. Run: git config --global user.name \"Your Name\" && git config --global user.email \"you@example.com\""; fi' >> /home/$USERNAME/.zshrc && \
    echo 'if [ ! -f ~/.config/gh/hosts.yml ]; then echo "⚠️  GitHub CLI not authenticated. Run: gh auth login"; fi' >> /home/$USERNAME/.zshrc && \
    echo 'if [ -z "$(ls -A ~/.claude 2>/dev/null)" ]; then echo "⚠️  Claude not authenticated. Run: claude"; fi' >> /home/$USERNAME/.zshrc

# Create directories (owned by developer user)
RUN mkdir -p /home/$USERNAME/workspaces

# Set default working directory
WORKDIR /home/$USERNAME/workspaces

CMD ["zsh"]
