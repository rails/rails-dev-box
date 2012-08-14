Puppet::Type.type(:database_user).provide(:mysql) do

  desc "manage users for a mysql database."

  defaultfor :kernel => 'Linux'

  optional_commands :mysql      => 'mysql'
  optional_commands :mysqladmin => 'mysqladmin'

  def self.instances
    users = mysql("mysql", '-BNe' "select concat(User, '@',Host) as User from mysql.user").split("\n")
    users.select{ |user| user =~ /.+@/ }.collect do |name|
      new(:name => name)
    end
  end

  def create
    mysql("mysql", "-e", "create user '%s' identified by PASSWORD '%s'" % [ @resource[:name].sub("@", "'@'"), @resource.value(:password_hash) ])
  end

  def destroy
    mysql("mysql", "-e", "drop user '%s'" % @resource.value(:name).sub("@", "'@'") )
  end

  def password_hash
    mysql("mysql", "-NBe", "select password from user where CONCAT(user, '@', host) = '%s'" % @resource.value(:name)).chomp
  end

  def password_hash=(string)
    mysql("mysql", "-e", "SET PASSWORD FOR '%s' = '%s'" % [ @resource[:name].sub("@", "'@'"), string ] )
  end

  def exists?
    not mysql("mysql", "-NBe", "select '1' from user where CONCAT(user, '@', host) = '%s'" % @resource.value(:name)).empty?
  end

  def flush
    @property_hash.clear
    mysqladmin "flush-privileges"
  end

end
