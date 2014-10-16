require 'spec_helper_acceptance'

describe 'postgresql::validate_db_connection:', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  before :all do
    # Setup postgresql server and a sample database for tests to use.
    pp = <<-EOS.unindent
      $db = 'foo'
      class { 'postgresql::server': }

      postgresql::server::db { $db:
        user     => $db,
        password => postgresql_password($db, $db),
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
  end

  after :all do
    # Remove postgresql server after all tests have ran.
    apply_manifest("class { 'postgresql::server': ensure => absent }", :catch_failures => true)
  end

  it 'should run puppet with no changes declared if socket connectivity works' do
    pp = <<-EOS.unindent
      postgresql::validate_db_connection { 'foo':
        database_name => 'foo',
        run_as        => 'postgres',
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
  end

  it 'stops postgresql' do
    # First we stop postgresql.
    pp = <<-EOS
      class { 'postgresql::server':
        service_ensure => 'stopped',
      }
    EOS
    apply_manifest(pp, :catch_failures => true)
  end

  it 'should keep retrying if database is down' do
    if fact('operatingsystem') == 'RedHat' && fact('operatingsystemrelease') =~ /^7/
      shell('nohup bash -c "sleep 10; systemctl start `basename /usr/lib/systemd/system/postgres*`" > /dev/null 2>&1 &')
    else
      shell('nohup bash -c "sleep 10; /etc/init.d/postgresql* start" > /dev/null 2>&1 &')
    end

    pp = <<-EOS.unindent
      postgresql::validate_db_connection { 'foo':
        database_name => 'foo',
        tries         => 30,
        sleep         => 1,
        run_as        => 'postgres',
      }
    EOS
    apply_manifest(pp, :catch_failures => true)
  end

  it 'should run puppet with no changes declared if db ip connectivity works' do
    pp = <<-EOS.unindent
      postgresql::validate_db_connection { 'foo':
        database_host     => 'localhost',
        database_name     => 'foo',
        database_username => 'foo',
        database_password => 'foo',
      }
    EOS

    apply_manifest(pp, :catch_failures => true)
  end

  it 'should fail catalogue if database connectivity fails' do
    pp = <<-EOS.unindent
      postgresql::validate_db_connection { 'foobarbaz':
        database_host     => 'localhost',
        database_name     => 'foobarbaz',
        database_username => 'foobarbaz',
        database_password => 'foobarbaz',
      }
    EOS

    apply_manifest(pp, :expect_failures => true)
  end

  it 'starts postgresql' do
    pp = <<-EOS
      class { 'postgresql::server':
        service_ensure => 'running',
      }
    EOS
    apply_manifest(pp, :catch_failures => true)
  end
end
