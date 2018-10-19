#!/bin/bash
PROJECT_GITHUB_REPO=https://github.com/HardyHardy08/pingit_clone.git
PROJECT_DIR=/webapps/pingit
PINGIT_REPO=/webapps/repo/pingit

echo "======== running as pingit ========"
# work-tree directory setup
## clone repo and remove unnecessary files and dirs
cd $PROJECT_DIR
echo "======== cloning repo ========"
git clone $PROJECT_GITHUB_REPO . &&
rm -rf .git &&
rm .gitignore &&
rm -rf .travis &&
rm .travis.yml &&
echo "======== repo cloned and unnecessary files removed ========"

## log folder for NGINX and supervisor
echo "======== creating log dir and files ========"
mkdir logs
cd $PROJECT_DIR
touch logs/gunicorn_supervisor.log

# bare repo directory setup
echo "======== configuring git repo ========"
cd $PINGIT_REPO
git init --bare &&
echo "======== git installed ========"
touch hooks/post-receive
chmod 755 hooks/post-receive
cat /vagrant/config/post-receive > hooks/post-receive &&
echo "======== configured repo ========"

# project venv setup
echo "======== setting up virtual environment ========"
cd $PROJECT_DIR && virtualenv -p /usr/bin/python3.6 .
source bin/activate
pip install --no-cache-dir -r requirements/production.txt &&
echo "======== requirements installed ========"
# django setup
export DJANGO_DIR=/webapps/pingit/pingit_clone
export DJANGO_SETTINGS_MODULE=pingit_clone.settings.production
export DJANGO_SECRET_KEY="_k%7pmu4g7xs!d%4x5ntamuou(_uoh4vlmvp(&sf5cs8cwql=q"
export BOONG_PASSWORD="123123123123"
cd $DJANGO_DIR
python manage.py makemigrations customers banking
python manage.py migrate customers
python manage.py migrate banking &&
echo "======== django has migrated ========"
echo "======== logging out of pingit ========"
