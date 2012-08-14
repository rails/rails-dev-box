# This has to be a separate type to enable collecting
Puppet::Type.newtype(:database) do
  @doc = "Manage databases."

  ensurable

  newparam(:name, :namevar=>true) do
    desc "The name of the database."
  end

  newproperty(:charset) do
    desc "The characterset to use for a database"
    defaultto :utf8
    newvalue(/^\S+$/)
  end

end
