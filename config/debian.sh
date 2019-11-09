#!/bin/bash

# Debian 10 - Buster

# Add the PostgreSQL Apt repository for the shiny new versions.
apt install -y gnupg
cp system/pgdg.list /etc/apt/sources.list.d/
curl -o - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add

# Add the Yarn Apt repository for the shiny new versions.
cp system/yarn.list /etc/apt/sources.list.d/
curl -o - https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -

apt update
apt upgrade -y

# Add users to run and deploy the applications
adduser deploy --disabled-password
adduser app --system --group
usermod -a -G deploy app

# Allow deploy user to sudo certain commands
cp system/sudo-deploy /etc/sudoers.d/

# Install a gemrc to stop Rubygems from installing documentation
cp system/gemrc.yml /root/.gemrc
cp system/gemrc.yml /home/app/.gemrc
chown app:app /home/app/.gemrc
cp system/gemrc.yml /home/deploy/.gemrc
chown deploy:deploy /home/app/.gemrc

# Set up firewall
apt install -y ufw
ufw allow OpenSSH
ufw allow WWW
ufw allow "WWW Secure"

# Get automated updates for important security issues.
apt unstall -y unattended-upgrades

# Build tools are used by Rubygems to build certain Ruby extensions.
apt install -y build-essential

# Some Rubygems need headers and other tools to build.
apt install -y libssl-dev libreadline-dev libyaml-dev libffi-dev zlib1g-dev

# Git is used to install Rbenv and the application during deployment.
apt install -y git

# Yarn and NodeJS are used to compile front-end code.
apt install -y yarn

# The main applications and some related tool are written in Ruby and we use
# Rbenv to manage Ruby versions because the packages are usually horribly out
# of date.
git clone git://github.com/sstephenson/rbenv.git /usr/local/rbenv
chgrp -R adm /usr/local/rbenv
chmod -R g+rwxXs /usr/local/rbenv

git clone git://github.com/sstephenson/ruby-build.git /usr/local/rbenv/plugins/ruby-build
chgrp -R adm /usr/local/rbenv/plugins/ruby-build
chmod -R g+rwxs /usr/local/rbenv/plugins/ruby-build

cp system/rbenv.sh /etc/profile.d/
chmod +x /etc/profile.d/rbenv.sh
source system/rbenv.sh

rbenv install 2.6.5
rbenv global 2.6.5

# Bundler installs all the Ruby dependencies in the deploy directory as part
# of the deployment scripts.
gem install bundler

# PostgreSQL is the database server for all applications.
apt install -y postgresql-12 postgresql-server-dev-12
cp system/pg_hba.conf /etc/postgresql/12/main/pg_hba.conf
systemctl restart postgresql

echo "[install] The following may print errors but will be successful"
sudo -s -u postgres createuser -s app
sudo -s -u postgres createuser -s deploy
sudo -s -u postgres createdb --owner=app perf_check_ci_production
sudo -s -u postgres createdb --owner=app perf_check_ci_target_production

# Yeah, I know…
curl https://getcaddy.com | bash -s personal

chown root:root /usr/local/bin/caddy
chmod 755 /usr/local/bin/caddy
setcap CAP_NET_BIND_SERVICE=+eip /usr/local/bin/caddy

adduser caddy --group --home /var/www --system

mkdir /etc/caddy
chown -R root:caddy /etc/caddy
cp system/Caddyfile /etc/caddy
chown caddy:caddy /etc/caddy/Caddyfile
chmod 444 /etc/caddy/Caddyfile

mkdir /etc/ssl/caddy
chown -R caddy:root /etc/ssl/caddy
chmod 770 /etc/ssl/caddy

cp system/caddy.service /etc/systemd/system/
chmod 644 /etc/systemd/system/caddy.service

cp system/puma.service /etc/systemd/system/
chmod 644 /etc/systemd/system/puma.service

cp system/sidekiq.service /etc/systemd/system/
chmod 644 /etc/systemd/system/sidekiq.service

# TODO: now deploy the application so we have a Puma and Sidekiq config.

systemctl daemon-reload

systemctl enable caddy
systemctl enable puma
systemctl enable sidekiq

systemctl start caddy
systemctl start puma
systemctl start sidekiq
