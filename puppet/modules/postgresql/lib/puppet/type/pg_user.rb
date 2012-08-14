# This has to be a separate type to enable collecting
Puppet::Type.newtype(:pg_user) do
  @doc = "Manage a Postgresql database user/role."

  ensurable

  newparam(:name, :namevar=>true) do
    desc "The name of the user/role"
  end

  newparam(:password) do
    desc "The password for the user/role"
  end

  newparam(:createdb) do
    desc "Is the user allowed to create databases."

    defaultto :false
  end

  newparam(:inherit) do
    desc "Inherit privileges of roles this user/role is a member of."

    defaultto :true
  end

  newparam(:login) do
    desc "Can the user/role/ login?"

    defaultto :true
  end

  newparam(:createrole) do
    desc "Can the user/role create other users/roles?"

    defaultto :false
  end

  newparam(:superuser) do
    desc "Is the user/role a superuser?"

    defaultto :false
  end

end
