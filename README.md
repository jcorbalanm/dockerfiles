# About
This repository contains all the docker compose configurations for all self-hosted services running on my homelab. 

All services run on a Debian VM behind **Traefik** as reverse proxy, with automatic TLS via DNS challenge, using Cloudflare. Access to the services is done through a headscale self-hosted instance, with the control server API exposed through a Wireguard tunnel to a peer in [Fly.io](https://fly.io) with a public IP.

## Structure

Each service has its own directory, with config files and a docker-compose.yml. Data storage is done on the hosts `/opt` folder, with docker volume binds. 

## Running services

### Infrastructure

| Service | Description | Notes |
|---|---|---|
| **Headscale + Fly.io** | Self-hosted Tailscale control plane | DERP relay via Fly.io at zero cost, allows devices in the network to talk to each other seamlessly and in a secure way, without having to physically be in the same network, or expose services to the internet |
| **Traefik** | Reverse proxy + automatic TLS | Wildcard cert for `*.kibit.net` via Cloudflare DNS challenge |
| **Portainer** | Docker container management UI | Used to access containers logs and status without having to connect to the hosts VM |
| **Checkmate** | Uptime monitoring | Used to keep track of the status and response time of the services, other VMs and external websites |
| **Watchtower** | Automatic container image updates | Selective — some services opt out via label |
| **Mafl** | Homepage dashboard | Served at root `kibit.net`, easy point of entry to all services as user |

### Media

| Service | Description | Notes |
|---|---|---|
| **Jellyfin** | Media server | Binds `/media` read-only, currently exposes UDP 7359 directly, for Kodi discovery |
| **Lyrion Music Server** | Audio streaming (formerly Logitech Media Server) | Binds `/media/wd-media/musica` read-only, serves music to the Squeezebox receivers in my house |
| **qBittorrent** | BitTorrent client | Self explanatory |
| **Jackett** | Torrent indexer / proxy | Aggregates torrent search engines and sites to search globally from qBittorrent |
| **Qui** | qBittorrent UI alternative | Adds additional features on top of qBittorrent, better UI for phone usage |

### Productivity

| Service | Description | Notes |
|---|---|---|
| **Paperless-ngx** | Document management with OCR |  |
| **Actual Budget** | Personal finance manager |  |
| **Mealie** | Recipe manager |  |
| **Linkding** | Bookmark manager | Very useful when paired with the [browser extension](https://linkding.link/browser-extension/) |
| **Miniflux** | RSS reader |  |
| **Code Server** | VS Code in the browser | Workspace mapped to `/home/jcorbalan`. Used to access config files and a shell from outside my computer when necessary |

## Networking

All services use a shared external Docker network called `proxy`:

```bash
docker network create proxy
```

Traefik listens on this network and routes traffic based on `Host()` rules defined in each service's labels.

**TLS** is handled centrally by Traefik using a wildcard certificate for `*.kibit.net` obtained via Cloudflare DNS challenge. No individual service manages its own certificates.

**Security headers** (HSTS, CSP, X-Content-Type-Options, etc.) are applied globally via a Traefik middleware defined in `traefik/config.yml`.

## Helper script

```bash
./docker-restart.sh
```

This script iterates over every subdirectory, runs `docker compose down && docker compose up -d`, and skips any directory containing a `.disabled` or `.ignore` file.

## Opting out of  Watchtower

Most services update automatically. The following are pinned and opt out of Watchtower via label:

```yaml
labels:
  - "com.centurylinklabs.watchtower.enable=false"
```

 
| Service | Reason |
|---|---|
| Traefik | Core infrastructure — manual review before any update |
| qBittorrent | Update could stop or break torrents, manual update preferred |
| Actual Budget | Financial data — update only after changelog review |
| Headscale | VPN control plane — updates must be done carefully, reading the changelog |

