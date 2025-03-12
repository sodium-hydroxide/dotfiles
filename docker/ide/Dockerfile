FROM debian:bookworm-slim

ARG PASSWORD=pswd
ENV PASSWORD=PASSWORD
ENV SUDO_PASSWORD=PASSWORD

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    git \
    sudo \
    make \
    && curl -fsSL https://code-server.dev/install.sh | sh \
    && apt-get clean && rm -rf /var/lib/apt/lists/*


# Create a non-root user with sudo privileges
RUN useradd -m -s /bin/bash user && \
    echo "user:$SUDO_PASSWORD" | chpasswd && \
    usermod -aG sudo user
USER user
WORKDIR /home/user
RUN mkdir -p /home/user/.local/share/code-server/User /home/user/.local/share/code-server/extensions && \
    chown -R user:user /home/user/.local/share/code-server

COPY settings.json /home/user/.local/share/code-server/User/settings.json
COPY keybindings.json /home/user/.local/share/code-server/User/keybindings.json
COPY extensions.txt /home/user/extensions.txt

RUN while IFS= read -r extension; do \
code-server --install-extension "$extension" || echo "Failed to install $extension"; \
done < /home/user/extensions.txt && \
    rm /home/user/extensions.txt

EXPOSE 8080
CMD ["code-server", "--bind-addr", "0.0.0.0:8080", "--auth", "password"]
