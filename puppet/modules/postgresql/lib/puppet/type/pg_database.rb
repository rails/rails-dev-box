# This has to be a separate type to enable collecting
Puppet::Type.newtype(:pg_database) do
  @doc = "Manage Postgresql databases."

  ensurable

  newparam(:name, :namevar=>true) do
    desc "The name of the database."
  end

  newparam(:owner) do
    desc "The owner of the database"

    defaultto :postgres
  end

  newparam(:encoding) do
    desc "The character set encoding to use for the database"

    defaultto :UTF8
  end

  newparam(:locale) do
    desc "The locale to use for collation. Typical values include 'C' or 'en_US.UTF-8' or other specifiers"

	defaultto :'en_US.UTF-8'
  end

end
