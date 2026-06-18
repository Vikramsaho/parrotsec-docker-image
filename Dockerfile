FROM parrotsec/security:latest

# Railway overrides PORT dynamically; set fallback default
ENV PORT=7681
ENV DEBIAN_FRONTEND=noninteractive

# Ensure our binaries target directory exists
RUN mkdir -p /usr/local/bin

# 1. Download Tini cleanly from explicit GitHub releases endpoint
ENV TINI_VERSION=v0.19.0
RUN set -eux; \
    arch="$(uname -m)"; \
    case "$arch" in \
      x86_64|amd64) tini_asset="tini" ;; \
      aarch64|arm64) tini_asset="tini-arm64" ;; \
      *) echo "Unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    wget -qO /usr/local/bin/tini "https://github.com{TINI_VERSION}/${tini_asset}" \
    && chmod +x /usr/local/bin/tini

# 2. Download Fastfetch cleanly from explicit GitHub releases endpoint
ENV FASTFETCH_VERSION=2.15.0
RUN set -eux; \
    arch="$(uname -m)"; \
    case "$arch" in \
      x86_64|amd64) ff_asset="fastfetch-linux-amd64.tar.gz" ;; \
      aarch64|arm64) ff_asset="fastfetch-linux-aarch64.tar.gz" ;; \
      *) echo "Unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    wget -qO /tmp/ff.tar.gz "https://github.com{FASTFETCH_VERSION}/${ff_asset}" \
    && tar -xzf /tmp/ff.tar.gz -C /tmp \
    && mv /tmp/fastfetch-linux-*/usr/bin/fastfetch /usr/local/bin/fastfetch \
    && rm -rf /tmp/ff.tar.gz /tmp/fastfetch-linux-*

# 3. Download ttyd cleanly from explicit GitHub releases endpoint
RUN set -eux; \
    arch="$(uname -m)"; \
    case "$arch" in \
      x86_64|amd64) ttyd_asset="ttyd.x86_64" ;; \
      aarch64|arm64) ttyd_asset="ttyd.aarch64" ;; \
      *) echo "Unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    wget -qO /usr/local/bin/ttyd "https://github.com{ttyd_asset}" \
    && chmod +x /usr/local/bin/ttyd

# Output system environment metrics on web session startup
RUN echo "/usr/local/bin/fastfetch || true" >> /root/.bashrc

EXPOSE 7681

# Route initialization execution contexts via Tini
ENTRYPOINT ["/usr/local/bin/tini","--"]

CMD ["/bin/bash","-lc", "/usr/local/bin/ttyd --writable -i 0.0.0.0 -p ${PORT} -c ${USERNAME}:${PASSWORD} /bin/bash"]
