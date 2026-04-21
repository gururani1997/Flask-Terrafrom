#!/bin/bash

yum update -y

# Install Git
yum install git -y

# Install Node.js
curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
yum install -y nodejs

# Install Python
yum install -y python3

# Clone project
cd /home/ec2-user
git clone https://github.com/gururani1997/Flask-Terrafrom.git
cd Flask-Terrafrom

# --------------------
# Flask Backend
# --------------------
cd backend
pip3 install flask pymongo
nohup python3 app.py > backend.log 2>&1 &

cd ..

# --------------------
# Express Frontend
# --------------------
cd frontend
npm install
nohup node server.js > frontend.log 2>&1 &

echo "Deployment complete"