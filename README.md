# parrotsec-docker-image

You can use the following `README.md` for the repository.

# Parrot Security Desktop (noVNC)

Run a Parrot Security XFCE desktop in Docker and access it directly from your browser using noVNC.

## Features

* Parrot Security base image
* XFCE Desktop Environment
* TigerVNC Server
* noVNC Web Access
* Firefox ESR
* Git, Curl, Wget, Vim
* Browser-based remote desktop

## Repository Structure

```text
.
├── Dockerfile
├── start.sh
└── README.md
```

## Build Image

```bash
docker build -t parrot-novnc .
```

## Run Container

```bash
docker run -d \
  --name parrot-novnc \
  -p 6080:6080 \
  -p 5901:5901 \
  --restart unless-stopped \
  --shm-size=2g \
  parrot-novnc
```

## Access Desktop

Open:

```text
https://YOUR_SERVER_IP:6080/vnc.html
```

or

```text
http://YOUR_SERVER_IP:6080/vnc.html
```

## Enter Container

```bash
docker exec -it parrot-novnc bash
```

## Stop Container

```bash
docker stop parrot-novnc
```

## Start Container

```bash
docker start parrot-novnc
```

## Remove Container

```bash
docker rm -f parrot-novnc
```

## View Logs

```bash
docker logs -f parrot-novnc
```

## VPS Requirements

Minimum:

* 2 vCPU
* 2 GB RAM
* 20 GB Storage

Recommended:

* 4 vCPU
* 4 GB RAM
* 40 GB Storage

## Security Notice

This image starts VNC with no authentication for convenience.

For production deployments:

* Enable VNC passwords
* Use HTTPS
* Restrict access with a firewall
* Place behind a reverse proxy
* Use a VPN whenever possible

## Disclaimer

Use only on systems and networks you own or are authorized to test.

### If Railway/GitHub should build directly from the repository

Use:

```dockerfile
COPY start.sh /start.sh
RUN chmod +x /start.sh
```

and make sure the repository contains:

```text
Dockerfile
start.sh
README.md
```

Then push:

```bash
git add .
git commit -m "Initial Parrot noVNC setup"
git push origin main
```

If Railway still fails, send the **full build log after the Dockerfile fix**, because the next likely issue will be missing packages (`novnc`, `xfce4-goodies`, etc.) in the Parrot image rather than Dockerfile syntax.
