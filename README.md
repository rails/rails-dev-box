# A Virtual Machine for ActiveRecord SQL Server Adapter Development

## Introduction

**Please note this VM is _not_ designed for Rails application development with MS SQL Server, only ActiveRecord SQL Server core development.**

Microsoft now supports running MS SQL Server server and the command-line tool `sqlcmd` on Linux (see https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-ubuntu). This document describes how to use a virtual machine for working on the ActiveRecord SQL Server adapter itself. Use this virtual machine to work on a pull request with everything ready to hack and run the test suites, including an instance of MS SQL Server running in the virtual machine. 

This project builds on the [rails-dev-box](https://github.com/rails/rails-dev-box) project with additions to support SQL Server adapter developement.

The VM installs all the software required to run the Ruby on Rails tests suite too. This allows you to run the PostgreSQL/SQLite/MySQL adapter test suites alongside the SQL Server adapters tests. 

The VM uses the Ubuntu 18.04 image as that's the version supported by [Microsoft](https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-ubuntu).

## Requirements

* [VirtualBox](https://www.virtualbox.org)

* [Vagrant 2](http://vagrantup.com)

* Install the `vagrant-vbguest` plugin: `vagrant plugin install vagrant-vbguest`.

## How To Build The Virtual Machine

Building the virtual machine is this easy:

    host $ git clone https://github.com/rails-sqlserver/activerecord-sqlserver-adapter-dev-box.git
    host $ cd activerecord-sqlserver-adapter-dev-box
    host $ vagrant up

That's it.

After the installation has finished, you can access the virtual machine with

    host $ vagrant ssh
    Welcome to Ubuntu 22.10 (GNU/Linux 5.19.0-21-generic x86_64)
    ...
    vagrant@activerecord-sqlserver-adapter-dev-box:~$

Port 1443 in the host computer is forwarded to port 1443 in the virtual machine. So you can connect to the 
SQL Server DBMS running on the VM through localhost:1433. [Azure Data Studio](https://docs.microsoft.com/en-us/sql/azure-data-studio)
is available on Windows/MacOS/Linux and can be used to connect to the SQL Server database.

## RAM and CPUs

By default, the VM launches with 4 GB of RAM and 2 CPUs.

These can be overridden by setting the environment variables `ACTIVERECORD_SQLSERVER_DEV_BOX_RAM` and `ACTIVERECORD_SQLSERVER_DEV_BOX_CPUS`, respectively. Settings on VM creation don't matter, the environment variables are checked each time the VM boots.

`ACTIVERECORD_SQLSERVER_DEV_BOX_RAM` has to be expressed in megabytes, so configure 4096 if you want the VM to have 4 GB of RAM.

## What's In The Box

Ruby on Rails:

* Development tools

* Git

* Ruby 3.0

* Bundler

* SQLite3, MySQL, and Postgres

* Databases and users needed to run the Active Record test suite

* System dependencies for `nokogiri`, `sqlite3`, `mysql2`, and `pg`

* Memcached

* Redis

* RabbitMQ

* An ExecJS runtime

SQL Server:

* TinyTDS

* SQL Server

* SQL Server command line tools

* Databases and users needed to run the SQL Server adapter test suite

* rbenv
  * Ruby 2.5.8
  * Ruby 2.6.6
  * Ruby 2.7.1 **default Ruby version**

* Graphicviz

## Recommended Workflow

The recommended workflow is

* edit in the host computer and

* test within the virtual machine.

Just clone your SQL Server adapter fork into the activerecord-sqlserver-adapter-dev-box directory on the host computer:

    host $ ls
    bootstrap.sh MIT-LICENSE README.md Vagrantfile
    host $ git clone git@github.com:<your username>/activerecord-sqlserver-adapter.git

Vagrant mounts that directory as _/vagrant_ within the virtual machine:

    vagrant@activerecord-sqlserver-adapter-dev-box:~$ ls /vagrant
    bootstrap.sh MIT-LICENSE activerecord-sqlserver-adapter README.md Vagrantfile

Install gem dependencies in there:

    vagrant@activerecord-sqlserver-adapter-dev-box:~$ cd /vagrant/activerecord-sqlserver-adapter
    vagrant@activerecord-sqlserver-adapter-dev-box:/vagrant/activerecord-sqlserver-adapter-dev-box$ bundle

We are ready to go to edit in the host, and test in the virtual machine.

Please have a look at the [Contributing to Ruby on Rails](http://edgeguides.rubyonrails.org/contributing_to_ruby_on_rails.html) guide for tips on how to run Rails test suites.

Please have a look at the [Running Unit Tests](https://github.com/rails-sqlserver/activerecord-sqlserver-adapter/blob/master/RUNNING_UNIT_TESTS.md) guide on how to run the SQL Server adapter test suites.

This workflow is convenient because in the host computer you normally have your editor of choice fine-tuned, Git configured, and SSH keys in place.

## Virtual Machine Management

When done just log out with `^D` and suspend the virtual machine

    host $ vagrant suspend

then, resume to hack again

    host $ vagrant resume

Run

    host $ vagrant halt

to shutdown the virtual machine, and

    host $ vagrant up

to boot it again.

You can find out the state of a virtual machine anytime by invoking

    host $ vagrant status

Finally, to completely wipe the virtual machine from the disk **destroying all its contents**:

    host $ vagrant destroy # DANGER: all is gone

Please check the [Vagrant documentation](http://docs.vagrantup.com/v2/) for more information on Vagrant.

## Faster test suites

The default mechanism for sharing folders is convenient and works out the box in
all Vagrant versions, but there are a couple of alternatives that are more
performant.

### rsync

Vagrant 1.5 implements a [sharing mechanism based on rsync](https://www.vagrantup.com/blog/feature-preview-vagrant-1-5-rsync.html)
that dramatically improves read/write because files are actually stored in the
guest. Just throw

    config.vm.synced_folder '.', '/vagrant', type: 'rsync'

to the _Vagrantfile_ and either rsync manually with

    vagrant rsync

or run

    vagrant rsync-auto

for automatic syncs. See the post linked above for details.

### NFS

If you're using Mac OS X or Linux you can increase the speed of test suites with Vagrant's NFS synced folders.

With an NFS server installed (already installed on Mac OS X), add the following to the Vagrantfile:

    config.vm.synced_folder '.', '/vagrant', type: 'nfs'
    config.vm.network 'private_network', ip: '192.168.50.4' # ensure this is available

Then

    host $ vagrant up

Please check the Vagrant documentation on [NFS synced folders](http://docs.vagrantup.com/v2/synced-folders/nfs.html) for more information.

## Troubleshooting

On `vagrant up`, it's possible to get this error message:

```
The box 'ubuntu/yakkety64' could not be found or
could not be accessed in the remote catalog. If this is a private
box on HashiCorp's Atlas, please verify you're logged in via
vagrant login. Also, please double-check the name. The expanded
URL and error message are shown below:

URL: ["https://atlas.hashicorp.com/ubuntu/yakkety64"]
Error:
```

And a known work-around (https://github.com/Varying-Vagrant-Vagrants/VVV/issues/354) can be:

    sudo rm /opt/vagrant/embedded/bin/curl

## License

Released under the MIT License, Copyright (c) 2012–<i>ω</i> Xavier Noria.
