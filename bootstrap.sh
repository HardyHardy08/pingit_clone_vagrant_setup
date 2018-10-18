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
echo "installing python3.6"
sudo apt-get install -y python3.6 && echo "installed python3.6"
echo "installing python dependencies"
sudo apt-get install -y python-virtualenv libpq-dev python-dev && echo "installed python dependencies"
echo "installing supervisor and nginx"
sudo apt-get install -y supervisor nginx && echo "installed supervisor and nginx"
echo "installing postgres"
sudo apt-get install -y postgresql postgresql-contrib && echo "installed postgres"

# create user to run the project // use users to run applications safely by implementing proper priviliges
sudo mkdir -p $PROJECT_DIR 
sudo groupadd --system webapps && echo "created webapps group"
sudo useradd --system --gid webapps --shell /bin/bash --home $PROJECT_DIR pingit && echo "created pingit user"
sudo chown pingit:webapps $PROJECT_DIR && echo "set permissions"

# create role and db in psql
sudo -su postgres createuser boong && echo "create psql role boong"
sudo -su postgres createdb boong_bank --owner=boong && echo "create psql database boong_bank"

# work-tree directory setup
## clone repo and remove unnecessary files and dirs
echo "cloning repo"
git clone $PROJECT_GITHUB_REPO . &&
rm -rf .git &&
rm .gitignore &&
rm -rf .travis &&
rm .travis.yml && echo "repo cloned and unnecessary files removed"

## log folder for NGINX and supervisor
echo "creating log dir and files"
mkdir logs
cd $PROJECT_DIR
touch logs/gunicorn_supervisor.log

# bare repo directory setup
echo "making git repo"
sudo mkdir -p $PINGIT_REPO
cd $PINGIT_REPO
git init --bare
touch hooks/post-receive
sudo chown pingit:webapps hooks/post-receive
cat /vagrant/config/post-receive > hooks/post-receive && echo "configured post-receive hook"

# project venv setup
echo "setting venv"
cd $PROJECT_DIR && virtualenv .
source bin/activate
pip install requirements/production.txt && echo "requirements installed"
# django setup
export DJANGO_DIR=/webapps/pingit/pingit_clone
export DJANGO_SETTINGS_MODULE=pingit_clone.settings.production
export DJANGO_SECRET_KEY="%-a9soi$l=ue_jwih)ib6yh9t4r&b6+l3xv^5^l&75i3ox8=9+"
export BOONG_PASSWORD="9bEoYmBgnyLnFA4P2Zn0dlNUNIu6wt2KddpHKv86gggXUhjoWyDstUvNSRVHhqg"
cd $DJANGO_DIR
python manage.py makemigrations customers banking
python manage.py migrate customers banking && echo "django has migrated"

# configure gunicorn script
echo "configure gunicorn"
touch bin/gunicorn_start
cat /vagrant/config/gunicorn_start >> bin/gunicorn_start && echo "configured gunicorn"
sudo chmod u+x bin/gunicorn_start

# configure supervisor
echo "configure supervisor"
touch /etc/supervisor/conf.d/pingit.conf
cat /vagrant/config/supervisor.pingit.conf >> /etc/supervisor/conf.d/pingit.conf && echo "configured supervisor"

# configure nginx
echo "configuring nginx"
touch /etc/nginx/sites-available/pingit
cat /vagrant/config/nginx.pingit >> /etc/nginx/sites-available/pingit && echo "created config file"
ln -s /etc/nginx/sites-available/pingit /etc/nginx/sites-enabled/pingit && echo "added config to enabled sites"
sudo service nginx restart && echo "configured nginx"
