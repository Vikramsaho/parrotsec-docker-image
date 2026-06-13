#!/bin/bash

export DISPLAY=:1

vncserver :1 
-localhost no 
-SecurityTypes None 
-geometry 1366x768 
-depth 24

openssl req 
-new 
-x509 
-nodes 
-days 365 
-subj "/C=US" 
-out /root/self.pem 
-keyout /root/self.pem

websockify 
--web=/opt/novnc 
--cert=/root/self.pem 
6080 
localhost:5901 &

tail -f /dev/null
