#!/bin/bash

set -e

apt update -y
apt install -y git curl

# Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# Python
apt install -y python3 python3-pip

# Go to correct folder
cd /home/ubuntu

# Clone repo
git clone https://github.com/gururani1997/Flask-Terrafrom.git
cd Flask-Terrafrom

# --------------------
# Flask Backend
# --------------------
cd backend
pip3 install -r requirements.txt
nohup python3 app.py > backend.log 2>&1 &

cd ..

# --------------------
# Express Frontend
# --------------------
cd frontend
npm install
nohup node server.js > frontend.log 2>&1 &

echo "Deployment complete"