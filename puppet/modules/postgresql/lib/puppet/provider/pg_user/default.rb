Puppet::Type.type(:pg_user).provide(:default) do

  desc "A default pg_user provider which just fails."

  def create
    return false
  end

  def destroy
    return false
  end

  def exists?
    fail('This is just the default provider for pg_user, all it does is fail')
  end

end
