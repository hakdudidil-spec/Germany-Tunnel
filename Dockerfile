FROM node:20-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends bash tar ca-certificates \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

# Data dirs (agent.toml, tunnels, binaries, links.txt) - mount a volume here if the host supports it
RUN mkdir -p /app/kariz/bin /app/xray \
 && chmod +x /app/xray/xray /app/kariz/bin/* 2>/dev/null || true

# Domain of the container (leave empty for IP mode)
ENV XRAY_DOMAIN="u.hamkm.ir" \
    XRAY_LINK_PORT=443 \
    XRAY_LINK_TLS=tls \
    NODE_ENV=production

EXPOSE 80

CMD ["node", "index.js"]
