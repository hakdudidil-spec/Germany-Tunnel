FROM node:20-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends bash tar ca-certificates unzip curl \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

# Data dirs (agent.toml, tunnels, binaries, links.txt) - mount a volume here if the host supports it
# Xray-core is downloaded at build time (latest release, or pin with --build-arg XRAY_VERSION=v26.x.x).
# If the build host has no internet, the build still succeeds and xray.js downloads it at first start instead.
ARG XRAY_VERSION=latest
RUN mkdir -p /app/kariz/bin /app/xray \
 && rm -f /app/xray/xray.zip \
 && chmod +x /app/kariz/bin/* \
 && case "$(uname -m)" in aarch64|arm64) A=Xray-linux-arm64-v8a.zip ;; *) A=Xray-linux-64.zip ;; esac \
 && if [ "$XRAY_VERSION" = "latest" ]; then U="https://github.com/XTLS/Xray-core/releases/latest/download/$A"; \
    else U="https://github.com/XTLS/Xray-core/releases/download/$XRAY_VERSION/$A"; fi \
 && ( curl -fsSL --retry 5 --retry-delay 2 -o /tmp/xray.zip "$U" \
      && unzip -o /tmp/xray.zip xray geoip.dat geosite.dat -d /app/xray \
      && chmod +x /app/xray/xray \
      && echo "Xray downloaded: $(/app/xray/xray version | head -1)" ) \
    || echo "WARNING: could not download Xray at build time; it will be downloaded on first start."; \
    rm -f /tmp/xray.zip

# Domain of the container (leave empty for IP mode)
ENV XRAY_DOMAIN="u.hamkm.ir" \
    XRAY_UUID="c7327ef1-9916-44b7-9a89-ca18cb4c301a" \
    PORT=80 \
    XRAY_LINK_PORT=443 \
    XRAY_LINK_TLS=tls \
    NODE_ENV=production

EXPOSE 80

CMD ["node", "index.js"]
