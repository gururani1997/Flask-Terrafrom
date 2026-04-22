#!/bin/bash

apt update -y
apt install -y git nodejs npm

mkdir -p /opt/frontend
cd /opt/frontend

git clone https://github.com/gururani1997/Flask-Terrafrom.git

cd Flask-Terrafrom/frontend

npm install

export BACKEND_URL=http://<backend-ip>:8000

nohup node server.js > frontend.log 2>&1 &