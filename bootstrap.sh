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

curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarn-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/yarn-archive-keyring.gpg] https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

echo updating package information
apt-get -y update >/dev/null 2>&1

install 'Ruby build dependencies' libyaml-dev libssl-dev libreadline-dev zlib1g-dev
install 'development tools' build-essential autoconf libtool

echo installing mise
curl -fsSL --retry 5 --retry-delay 3 --retry-connrefused -o /tmp/mise-install.sh https://mise.run
HOME=/home/vagrant sudo -u vagrant bash /tmp/mise-install.sh
rm -f /tmp/mise-install.sh
echo 'eval "$(/home/vagrant/.local/bin/mise activate bash)"' >> /home/vagrant/.bashrc

echo installing Ruby via mise
sudo -u vagrant HOME=/home/vagrant /home/vagrant/.local/bin/mise use --global ruby@4 >/dev/null 2>&1

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
# To address `unable to connect to /tmp/mysql.sock` for trilogy,
# and to pass MySQL root password in railties tests.
# /etc/environment is parsed by PAM for all sessions to expose these variables broadly.
# MYSQL_CODESPACES=1 tells railties tests to use 'root' as the MySQL root password.
cat >> /etc/environment <<'ENV'
MYSQL_SOCK=/var/run/mysqld/mysqld.sock
MYSQL_CODESPACES=1
ENV

install 'Nokogiri dependencies' libxml2-dev libxslt1-dev
install 'Blade dependencies' libncurses5-dev
install 'ruby-vips dependencies' libvips
install 'ExecJS runtime' nodejs
install 'Yarn' yarn

install 'MuPDF' mupdf mupdf-tools
install 'FFmpeg' ffmpeg
install 'Poppler' poppler-utils
install 'tzdata-legacy' tzdata-legacy
install 'ImageMagick' imagemagick

curl -fsSL https://dl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/googlechrome-linux-keyring.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/googlechrome-linux-keyring.gpg] http://dl.google.com/linux/chrome/deb/ stable main" > /etc/apt/sources.list.d/google-chrome.list
apt-get -y update >/dev/null 2>&1
install 'Google Chrome' google-chrome-stable

echo installing ChromeDriver
CHROME_VERSION=$(google-chrome-stable --version | grep -oP '\d+\.\d+\.\d+\.\d+')
apt-get -y install unzip >/dev/null 2>&1
curl -fsSL -o /tmp/chromedriver.zip "https://storage.googleapis.com/chrome-for-testing-public/${CHROME_VERSION}/linux64/chromedriver-linux64.zip"
unzip -o /tmp/chromedriver.zip -d /tmp/
mv /tmp/chromedriver-linux64/chromedriver /usr/local/bin/chromedriver
chmod +x /usr/local/bin/chromedriver
rm -rf /tmp/chromedriver.zip /tmp/chromedriver-linux64

# Needed for docs generation.
update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

echo "test -d /vagrant/rails && cd /vagrant/rails" >> /home/vagrant/.bashrc
echo 'all set, rock on!'
