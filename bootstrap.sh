# The output of all these installation steps is noisy. With this utility
# the progress report is nice and concise.



# Choose what to install
JAVA_ORACLE=true
RUBY_WITH_RVM=false
RUBY_WITH_RBENV=true # only install if RUBY_WITH_RVM is false
# RUBY WILL BE INSTALLED DIRECTLY IF 'RUBY_WITH_RVM' AND 'RUBY_WITH_RBENV' ARE FALSE
RAILS=true
SQLITE=true
POSTGRESQL=true
MYSQL=true

# Variables
RUBY_VERSION=2.2.2
RAILS_VERSION=4.2.1
MYSQL_USER=root
MYSQL_PASSWORD=root
RBENV_DIR=~/.rbenv
RUBY_BUILD_DIR="$RBENV_DIR/plugins/ruby-build"
REHASH_DIR="$RBENV_DIR/plugins/rbenv-gem-rehash"



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

elif $RUBY_WITH_RBENV
then

	echo "installing Rbenv with Ruby $RUBY_VERSION"
	if [ -d $RBENV_DIR ]
	then
		cd $RBENV_DIR
		git pull
	else
		git clone https://github.com/sstephenson/rbenv.git $RBENV_DIR
		echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
		echo 'eval "$(rbenv init -)"' >> ~/.bashrc
		export PATH="$HOME/.rbenv/bin:$PATH"
		eval "$(rbenv init -)"
	fi

	if [ -d $RUBY_BUILD_DIR ]
	then
		cd $RUBY_BUILD_DIR
		git pull
	else
		git clone https://github.com/sstephenson/ruby-build.git $RUBY_BUILD_DIR
		cd $RUBY_BUILD_DIR
		./install.sh
	fi

	if [ -d $REHASH_DIR ]
	then
		cd $REHASH_DIR
		git pull
	else
		git clone https://github.com/sstephenson/rbenv-gem-rehash.git $REHASH_DIR
	fi

	rbenv install $RUBY_VERSION -s
	rbenv global $RUBY_VERSION
	rbenv rehash

	echo installing Bundler
	echo "gem: --no-ri --no-rdoc" > ~/.gemrc
	gem install bundler -N >/dev/null 2>&1
	rbenv rehash

else
	install Ruby ruby2.2 ruby2.2-dev
	update-alternatives --set ruby /usr/bin/ruby2.2 >/dev/null 2>&1
	update-alternatives --set gem /usr/bin/gem2.2 >/dev/null 2>&1

	echo installing Bundler
	gem install bundler -N >/dev/null 2>&1
fi

if $RAILS
then
	echo "installing Rails $RAILS_VERSION"
	gem install rails -v $RAILS_VERSION -N >/dev/null 2>&1
fi

if $MYSQL
then
	echo installing Gem MySQL2
	gem install mysql2 -N >/dev/null 2>&1
fi
if $POSTGRESQL
then
	echo installing Gem PG
	gem install pg -N >/dev/null 2>&1
fi

# Needed for docs generation.
update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8

echo 'all set, rock on!'
