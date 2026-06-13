# parrotsec-docker-image

#Build:

docker build -t parrot-novnc .

#Run:

docker run -d \
  --name parrot-novnc \
  -p 6080:6080 \
  -p 5901:5901 \
  --restart unless-stopped \
  --shm-size=2g \
  parrot-novnc

#Access:

https://YOUR_SERVER_IP:6080/vnc.html

#A couple of notes:

systemd and snapd generally don't work properly inside standard Docker containers, so I've omitted them.
firefox-esr is the browser package normally available in Parrot/Debian-based distributions.
If you deploy on a VPS with 2–4 GB RAM, XFCE will run comfortably.
Railway won't be able to run this image because it requires a long-running desktop/VNC service and Docker privileges; deploy it on a VPS, Docker host, or VM instead.
