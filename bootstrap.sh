#!/usr/bin/env bash
# boot script to get environment to have everything pingit_clone project needs to run
# Main items that need to run: Nginx, Gunicorn, Virtualenv, supervisor, PostgreSQL

# vars
PROJECT_GITHUB_REPO=https://github.com/HardyHardy08/pingit_clone.git
PROJECT_DIR=/webapps/pingit
PINGIT_REPO=/webapps/repo/pingit

# install python and dependencies
# TODO: move dependencies into text file
sudo apt-add-repository ppa:deadsnakes/ppa -y
sudo apt-get update
sudo apt-get install -y python3.6
sudo apt-get install -y python-virtualenv libpq-dev python-dev 
sudo apt-get install -y supervisor nginx
sudo apt-get install -y postgresql postgresql-contrib

# create user to run the project // use users to run applications safely by implementing proper priviliges
sudo groupadd --system webapps
sudo useradd --system --gid webapps --shell /bin/bash --home $PROJECT_DIR pingit

# create role and db in psql
sudo -su postgres createuser boong
sudo -su postgres createdb boong_bank --owner=boong

# work-tree directory setup
sudo mkdir -p $PROJECT_DIR
sudo chown pingit:webapps $PROJECT_DIR
## log folder for NGINX and supervisor
cd $PROJECT_DIR
mkdir logs
touch logs/gunicorn_supervisor.log
## clone repo and remove unnecessary files and dirs
git clone $PROJECT_GITHUB_REPO . &&
rm -rf .git &&
rm .gitignore &&
rm -rf .travis &&
rm .travis.yml

# bare repo directory setup
sudo mkdir -p $PINGIT_REPO
cd $PINGIT_REPO
git init --bare
touch hooks/post-receive
sudo chown pingit:webapps hooks/post-receive
cat /vagrant/config/post-receive > hooks/post-receive


# configure gunicorn script
touch bin/gunicorn_start
cat /vagrant/config/gunicorn_start >> bin/gunicorn_start
sudo chmod u+x bin/gunicorn_start

# configure supervisor
touch /etc/supervisor/conf.d/pingit.conf
cat /vagrant/config/supervisor.pingit.conf >> /etc/supervisor/conf.d/pingit.conf

# configure nginx
touch /etc/nginx/sites-available/pingit
cat /vagrant/config/nginx.pingit >> /etc/nginx/sites-available/pingit
ln -s /etc/nginx/sites-available/pingit /etc/nginx/sites-enabled/pingit
sudo service nginx restart

# project venv setup
cd $PROJECT_DIR && virtualenv .
source bin/activate
pip install requirements/production.txt
# django setup
export DJANGO_DIR=/webapps/pingit/pingit_clone
export DJANGO_SETTINGS_MODULE=pingit_clone.settings.production
export DJANGO_SECRET_KEY="%-a9soi$l=ue_jwih)ib6yh9t4r&b6+l3xv^5^l&75i3ox8=9+"
export BOONG_PASSWORD="9bEoYmBgnyLnFA4P2Zn0dlNUNIu6wt2KddpHKv86gggXUhjoWyDstUvNSRVHhqg"
cd $DJANGO_DIR
python manage.py makemigrations customers banking
python manage.py migrate customers banking
