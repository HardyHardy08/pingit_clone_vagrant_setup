#!/usr/bin/env bash
# boot script to get environment to have everything pingit_clone project needs to run
# Main items that need to run: Nginx, Gunicorn, Virtualenv, supervisor, PostgreSQL
start=`date +%s`
# vars
PROJECT_DIR=/webapps/pingit
PINGIT_REPO=/webapps/repo/pingit
red=`tput setaf 1`

# install python and dependencies
# TODO: move dependencies into text file -- best thing to do is to put them in a list, run through 
# it, check if they're installed, and install them if they're missing. Not sure how to do that in
# bash just yet so this will have to stand. Since trying to install installed packages return a 0
# anyway, this is fine.  
sudo apt-add-repository ppa:deadsnakes/ppa -y
sudo apt-get update
echo "======== installing python3.6 ========"
sudo apt-get install -y python3.6 &&
echo "======== installed python3.6 ========"
echo "======== installing python dependencies ========"
sudo apt-get install -y python-virtualenv libpq-dev python-dev &&
echo "======== installed python dependencies ========"
echo "======== installing supervisor and nginx ========"
sudo apt-get install -y supervisor nginx &&
echo "======== installed supervisor and nginx ========"
echo "======== installing postgres ========"
sudo apt-get install -y postgresql postgresql-contrib &&
echo "======== installed postgres ========"

# create user to run the project and make directories // use users to run applications safely by
# implementing proper priviliges
sudo mkdir -p $PROJECT_DIR 
sudo mkdir -p $PINGIT_REPO
sudo groupadd --system webapps &&
echo "======== created webapps group ========"
sudo useradd --system --gid webapps --shell /bin/bash --home $PROJECT_DIR pingit &&
echo "======== created pingit user ========"
sudo chown pingit:webapps $PROJECT_DIR 
sudo chown pingit:webapps $PINGIT_REPO
sudo chown vagrant:webapps /home/vagrant/.cache
sudo chmod -R 755 /home/vagrant/.cache
echo "======== set permissions ========"

# create role and db in psql -- how the hell do i check this?
sudo -su postgres createuser boong &&
sudo -su postgres psql -U postgres -c "ALTER USER boong WITH PASSWORD '123123123123'"
echo "======== create psql role boong ========"
sudo -su postgres createdb boong_bank --owner=boong &&
echo "======== create psql database boong_bank ========"

sudo -su pingit bash /vagrant/config/pingit_script.sh

# configure gunicorn script
echo "======== configure gunicorn ========"
touch $PROJECT_DIR/bin/gunicorn_start
cat /vagrant/config/gunicorn_start >> $PROJECT_DIR/bin/gunicorn_start &&
sudo chown pingit:webapps $PROJECT_DIR/bin/gunicorn_start
sudo chmod u+x $PROJECT_DIR/bin/gunicorn_start
echo "======== configured gunicorn ========"

# configure supervisor
echo "======== configure supervisor ========"
touch /etc/supervisor/conf.d/pingit.conf
cat /vagrant/config/supervisor.pingit.conf >> /etc/supervisor/conf.d/pingit.conf &&
echo "======== configured supervisor ========"

# configure nginx
echo "======== configuring nginx ========"
touch /etc/nginx/sites-available/pingit
cat /vagrant/config/nginx.pingit >> /etc/nginx/sites-available/pingit &&
echo "======== created config file ========"
ln -s /etc/nginx/sites-available/pingit /etc/nginx/sites-enabled/pingit &&
echo "======== added config to enabled sites ========"
sudo service nginx restart &&
echo "======== configured nginx ========"
end=`date +%s`

runtime=$((end-start))

echo "script runtime was"
echo $runtime