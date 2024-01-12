#!/usr/bin/env bash

# The output of all these installation steps is noisy. With this utility
# the progress report is nice and concise.
function install {
    echo installing $1
    shift
    apt-get -y install "$@" >/dev/null 2>&1
}

echo adding swap file
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap defaults 0 0' >> /etc/fstab

# Prevents "Warning: apt-key output should not be parsed (stdout is not a terminal)".
export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1
curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo -E apt-key add -
echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list

echo updating package information
apt-get -y update >/dev/null 2>&1

install Ruby ruby-full bundler libyaml-dev
install 'development tools' build-essential autoconf libtool

# echo installing current RubyGems
gem update --system -N >/dev/null 2>&1

install Git git
install SQLite sqlite3 libsqlite3-dev pkg-config
install memcached memcached
install Redis redis-server
install RabbitMQ rabbitmq-server

install PostgreSQL postgresql postgresql-contrib libpq-dev
sudo -i -u postgres createuser --superuser vagrant
sudo -i -u postgres createdb -O vagrant -E UTF8 -T template0 activerecord_unittest
sudo -i -u postgres createdb -O vagrant -E UTF8 -T template0 activerecord_unittest2

debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
install MySQL mysql-server libmysqlclient-dev libssl-dev
# Set the password in an environment variable to avoid the warning issued if set with `-p`.
MYSQL_PWD=root mysql -uroot <<SQL
CREATE USER 'rails'@'localhost';
CREATE DATABASE activerecord_unittest  DEFAULT CHARACTER SET utf8mb4;
CREATE DATABASE activerecord_unittest2 DEFAULT CHARACTER SET utf8mb4;
GRANT ALL PRIVILEGES ON activerecord_unittest.* to 'rails'@'localhost';
GRANT ALL PRIVILEGES ON activerecord_unittest2.* to 'rails'@'localhost';
GRANT ALL PRIVILEGES ON inexistent_activerecord_unittest.* to 'rails'@'localhost';
SQL
# To address `unable to connect to /tmp/mysql.sock` for trilogy
echo "export MYSQL_SOCK=/var/run/mysqld/mysqld.sock" >> /home/vagrant/.bashrc

install 'Psych dependencies' libyaml-dev
install 'Nokogiri dependencies' libxml2 libxml2-dev libxslt1-dev
install 'Blade dependencies' libncurses5-dev
install 'ruby-vips dependencies' libvips
install 'ExecJS runtime' nodejs
install 'Yarn' yarn

install 'MuPDF' mupdf mupdf-tools
install 'FFmpeg' ffmpeg
install 'Poppler' poppler-utils
install 'tzdata-legacy' tzdata-legacy

# Needed for docs generation.
update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

echo "test -d /vagrant/rails && cd /vagrant/rails" >> /home/vagrant/.bashrc

echo 'all set, rock on!'
