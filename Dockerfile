FROM node:20-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends bash tar ca-certificates unzip \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

# Data dirs (agent.toml, tunnels, binaries, links.txt) - mount a volume here if the host supports it
# The xray binary is shipped zipped (GitHub's web upload limit is 25 MB per file); unpack it at build time.
RUN mkdir -p /app/kariz/bin /app/xray \
 && unzip -o /app/xray/xray.zip -d /app/xray \
 && rm -f /app/xray/xray.zip \
 && chmod +x /app/xray/xray /app/kariz/bin/*

# Domain of the container (leave empty for IP mode)
ENV XRAY_DOMAIN="u.hamkm.ir" \
    XRAY_UUID="c7327ef1-9916-44b7-9a89-ca18cb4c301a" \
    PORT=80 \
    XRAY_LINK_PORT=443 \
    XRAY_LINK_TLS=tls \
    NODE_ENV=production

EXPOSE 80

CMD ["node", "index.js"]
