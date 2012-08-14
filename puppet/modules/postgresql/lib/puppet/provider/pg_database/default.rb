Puppet::Type.type(:pg_database).provide(:default) do

  desc "A default pg_database provider which just fails."

  def create
    return false
  end

  def destroy
    return false
  end

  def exists?
    fail('This is just the default provider for pg_database, all it does is fail')
  end

end
