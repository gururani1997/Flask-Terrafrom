#!/bin/bash

yum update -y
yum install python3 git -y

mkdir -p /opt/backend
cd /opt/backend

git clone https://github.com/gururani1997/Flask-Terrafrom.git

cd Flask-Terrafrom/backend

pip3 install -r requirements.txt
nohup python3 app.py > backend.log 2>&1 &

# nohup python3 app.py --host=0.0.0.0 --port=8000 &