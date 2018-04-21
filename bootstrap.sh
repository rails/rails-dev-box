#!/usr/bin/env bash
# The output of all these installation steps is noisy. With this utility
# the progress report is nice and concise.
function install {
    echo installing $1
    shift
    apt-get -y install "$@" >/dev/null 2>&1
}

# FIXME: This addresses an issue with Ubuntu 17.10 (Artful Aardvark). Should be
# revisited when the base image gets upgraded.
#
# Workaround for https://bugs.launchpad.net/cloud-images/+bug/1726818 without
# this the root file system size will be about 2GB.
echo expanding root file system
sudo resize2fs /dev/sda1

echo adding swap file
fallocate -l 2G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile
echo '/swapfile none swap defaults 0 0' >> /etc/fstab

echo updating package information
apt-add-repository -y ppa:brightbox/ruby-ng >/dev/null 2>&1
apt-get -y update >/dev/null 2>&1

install 'development tools' build-essential

install Ruby ruby2.5 ruby2.5-dev
update-alternatives --set ruby /usr/bin/ruby2.5 >/dev/null 2>&1
update-alternatives --set gem /usr/bin/gem2.5 >/dev/null 2>&1

# FIXME: Do not upgrade RubyGems, see https://github.com/rails/rails-dev-box/issues/147.
# echo installing current RubyGems
# gem update --system -N >/dev/null 2>&1

echo installing Bundler
gem install bundler -N >/dev/null 2>&1

install Git git
install SQLite sqlite3 libsqlite3-dev
install memcached memcached
install Redis redis-server
install RabbitMQ rabbitmq-server

install PostgreSQL postgresql postgresql-contrib libpq-dev
sudo -u postgres createuser --superuser vagrant
sudo -u postgres createdb -O vagrant grep_test
sudo -u postgres createdb -O vagrant grep_development

debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'
install MySQL mysql-server libmysqlclient-dev
# Set the password in an environment variable to avoid the warning issued if set with `-p`.
MYSQL_PWD=root mysql -uroot <<SQL
CREATE USER 'rails'@'localhost';
CREATE DATABASE activerecord_unittest  DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE activerecord_unittest2 DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON activerecord_unittest.* to 'rails'@'localhost';
GRANT ALL PRIVILEGES ON activerecord_unittest2.* to 'rails'@'localhost';
GRANT ALL PRIVILEGES ON inexistent_activerecord_unittest.* to 'rails'@'localhost';
SQL

install 'Nokogiri dependencies' libxml2 libxml2-dev libxslt1-dev
install 'Blade dependencies' libncurses5-dev
install 'ExecJS runtime' nodejs

# To generate guides in Kindle format.
install 'ImageMagick' imagemagick
echo installing KindleGen
kindlegen_tarball=kindlegen_linux_2.6_i386_v2_9.tar.gz
wget -q http://kindlegen.s3.amazonaws.com/$kindlegen_tarball
tar xzf $kindlegen_tarball kindlegen
mv kindlegen /usr/local/bin
rm $kindlegen_tarball

install 'MuPDF' mupdf mupdf-tools
install 'FFmpeg' ffmpeg
install 'Poppler' poppler-utils

# Needed for docs generation.
update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

echo 'all set, rock on!'
