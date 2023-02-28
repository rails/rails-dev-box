#!/usr/bin/env bash
# The output of all these installation steps is noisy. With this utility
# the progress report is nice and concise.
function install {
    echo installing $1
    shift
    apt-get -y install "$@" >/dev/null 2>&1
}

# TinyTDS
install libc6-dev libc6-dev
wget http://www.freetds.org/files/stable/freetds-1.1.32.tar.gz
tar -xzf freetds-1.1.32.tar.gz
cd freetds-1.1.32
./configure --prefix=/usr/local --with-tdsver=7.3
make
make install

# Preparation
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/18.04/mssql-server-2017.list | sudo tee /etc/apt/sources.list.d/microsoft.mssql-server-2017.list
curl https://packages.microsoft.com/config/ubuntu/18.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft.prod.list
apt-get update

# Install SQL Server
install mssql-server mssql-server
MSSQL_PID=Developer ACCEPT_EULA=Yes MSSQL_SA_PASSWORD=MSSQLadmin! /opt/mssql/bin/mssql-conf --noprompt setup
systemctl status mssql-server --no-pager

# Install the SQL Server command-line tools
ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> /home/vagrant/.bashrc

# Setup test databases and users
sleep 5
/opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P MSSQLadmin! <<SQL
CREATE DATABASE [activerecord_unittest];
CREATE DATABASE [activerecord_unittest2];
GO
CREATE LOGIN [rails] WITH PASSWORD = '', CHECK_POLICY = OFF, DEFAULT_DATABASE = [activerecord_unittest];
GO
USE [activerecord_unittest];
CREATE USER [rails] FOR LOGIN [rails];
GO
EXEC sp_addrolemember N'db_owner', N'rails';
EXEC master..sp_addsrvrolemember @loginame = N'rails', @rolename = N'sysadmin';
GO
SQL

# rbenv and Rubies
install libreadline-dev libreadline-dev
git clone https://github.com/rbenv/rbenv.git /home/vagrant/.rbenv
mkdir -p /home/vagrant/.rbenv/plugins
git clone https://github.com/rbenv/ruby-build.git /home/vagrant/.rbenv/plugins/ruby-build
chown -R vagrant:vagrant /home/vagrant/.rbenv

echo 'export PATH="/home/vagrant/.rbenv/bin:$PATH"' >> /home/vagrant/.bashrc
echo 'eval "$(rbenv init -)"' >> /home/vagrant/.bashrc

runuser -l vagrant -c '/home/vagrant/.rbenv/bin/rbenv install 2.7.7'
runuser -l vagrant -c '/home/vagrant/.rbenv/bin/rbenv install 3.0.5'
runuser -l vagrant -c '/home/vagrant/.rbenv/bin/rbenv install 3.1.3'
runuser -l vagrant -c '/home/vagrant/.rbenv/bin/rbenv global 3.2.1'

# Install dot
install graphviz graphviz

# Misc
echo "test -d /vagrant/activerecord-sqlserver-adapter && cd /vagrant/activerecord-sqlserver-adapter" >> /home/vagrant/.bashrc

echo 'all set, rock on!'
