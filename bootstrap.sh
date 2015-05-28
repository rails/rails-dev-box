# The output of all these installation steps is noisy. With this utility
# the progress report is nice and concise.

# Choose what to install
JAVA_ORACLE=true
RUBY_WITH_RVM=true
SQLITE=true
POSTGRESQL=true
MYSQL=true

# Variables
RUBY_VERSION=2.2.2
RAILS_VERSION=4.2.1
MYSQL_USER=root
MYSQL_PASSWORD=root

function install {
    echo installing $1
    shift
    apt-get -y install "$@" >/dev/null 2>&1
}

echo "updating package information"
apt-add-repository -y ppa:brightbox/ruby-ng >/dev/null 2>&1
add-apt-repository -y ppa:webupd8team/java >/dev/null 2>&1
add-apt-repository -y ppa:chris-lea/node.js >/dev/null 2>&1
apt-get -y update >/dev/null 2>&1

install "Build Essencial" build-essential
install Git git-core
install CURL curl
install DevLibs zlib1g-dev libssl-dev libreadline-dev libyaml-dev libcurl4-openssl-dev libffi-dev python-software-properties
install "Nokogiri dependencies" libxml2 libxml2-dev libxslt1-dev
install NodeJS nodejs
install memcached memcached
install Redis redis-server
install RabbitMQ rabbitmq-server
install ImageMagick imagemagick

if $JAVA_ORACLE
then
	sudo apt-get -y remove --purge openjdk-*
	echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | sudo /usr/bin/debconf-set-selections
	install Java8 oracle-java8-installer
	install SetDefaultJava8 oracle-java8-set-default
fi

if $RUBY_WITH_RVM
then
	echo "installing RVM with RUBY $RUBY_VERSION"
	if ! type rvm >/dev/null 2>&1; then
    curl -sSL https://rvm.io/mpapis.asc | gpg --import -
    curl -L https://get.rvm.io | bash -s stable
    source /etc/profile.d/rvm.sh
  fi
	rvm requirements
	rvm install $RUBY_VERSION
	rvm use $RUBY_VERSION --default
	echo "installing Rails $RAILS_VERSION"
	gem install rails -v $RAILS_VERSION -N >/dev/null 2>&1
fi

if $SQLITE
then
	install SQLite sqlite3 libsqlite3-dev
fi

if $POSTGRESQL
then
	install PostgreSQL postgresql postgresql-contrib libpq-dev
	sudo -u postgres createuser --superuser vagrant
	sudo -u postgres createdb -O vagrant activerecord_unittest
	sudo -u postgres createdb -O vagrant activerecord_unittest2
fi

if $MYSQL
then
debconf-set-selections <<< "mysql-server mysql-server/root_password password $MYSQL_USER"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $MYSQL_PASSWORD"
install MySQL mysql-server libmysqlclient-dev
mysql -uroot -proot <<SQL
CREATE USER 'rails'@'localhost';
CREATE DATABASE activerecord_unittest  DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
CREATE DATABASE activerecord_unittest2 DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON activerecord_unittest.* to 'rails'@'localhost';
GRANT ALL PRIVILEGES ON activerecord_unittest2.* to 'rails'@'localhost';
GRANT ALL PRIVILEGES ON inexistent_activerecord_unittest.* to 'rails'@'localhost';
SQL
fi

# Needed for docs generation.
update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

echo 'all set, rock on!'
