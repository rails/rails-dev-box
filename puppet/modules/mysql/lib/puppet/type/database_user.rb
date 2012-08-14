# This has to be a separate type to enable collecting
Puppet::Type.newtype(:database_user) do
  @doc = "Manage a database user. This includes management of users password as well as priveleges"

  ensurable

  newparam(:name, :namevar=>true) do
    desc "The name of the user. This uses the 'username@hostname' or username@hostname."
    validate do |value|
      # https://dev.mysql.com/doc/refman/5.1/en/account-names.html
      # Regex should problably be more like this: /^[`'"]?[^`'"]*[`'"]?@[`'"]?[\w%\.]+[`'"]?$/
      raise(ArgumentError, "Invalid database user #{value}") unless value =~ /[\w-]*@[\w%\.]+/
      username = value.split('@')[0]
      if username.size > 16
        raise ArgumentError, "MySQL usernames are limited to a maximum of 16 characters"
      end
    end
  end

  newproperty(:password_hash) do
    desc "The password hash of the user. Use mysql_password() for creating such a hash."
    newvalue(/\w+/)
  end

end
