# Virtual Machine for Ruby on Rails Core Development

## Introduction

**Please note this virtual machine is not designed for Rails application development, only Rails core development.**

Welcome! This project automates the setup of a virtual machine development environment for working on Ruby on Rails itself. The virtual machine includes all the libraries and services required to start working on Ruby on Rails. See [What's Installed On the Virtual Machine](#whats-installed-on-the-virtual-machine) for a summary list of what the virtual machine provides.

Getting all of those libraries and services installed and running is one of the more complicated parts of starting to work on Rails: this project handles that all for you!

Being a virtual machine also means that it's a stable development platform isolated from changes on your host machine. If you, say, upgrade Mac OSX it could mean a lot of changes to your host machine but the virtual machine for working on Rails would remain the same.

Using Vagrant means the virtual machine can easily be changed or rebuilt. If the virtual machine ever stops working correctly you can always "destroy" the virtual machine (get any work off of it first!) and rebuild it from scratch.

## Requirements

In order to build the virtual machine you need to have two pieces of software installed onto the host machine (e.g. your Mac laptop). VirtualBox is what actually runs the virtual machine. Vagrant is what reads the given `Vagrantfile` and tells VirtualBox what to do.

* [VirtualBox](https://www.virtualbox.org)

* [Vagrant 2](http://vagrantup.com)

## Command Reference

### Commands to run on the "host"

When you see `host $` everything following the `$` is a command you should run in a terminal window on the machine running VirtualBox and Vagrant.

### Commands to run on the virtual machine

When you see `vagrant@rails-dev-box:~$` enter everything following the `$` as a command in a terminal window that is running `vagrant ssh` and connected to the virtual machine.

## Getting Started

Build the virtual machine by cloning this repo, changing into its directory, and running `vagrant up`

    host $ git clone https://github.com/rails/rails-dev-box.git
    host $ cd rails-dev-box
    host $ vagrant up

That's it. The `vagrant up` command builds the virtual machine described by the included `Vagrantfile`.

After `vagrant up` has finished the virtual machine has been built and is running. You can access the virtual machine by running `vagrant ssh`.

    host $ vagrant ssh
    Welcome to Ubuntu 18.04 LTS (GNU/Linux 4.15.0-20-generic x86_64)
    ...
    vagrant@rails-dev-box:~$

To exit the virtual machine and get back to the host run the `exit` command on the virtual machine or type `ctrl`-`d`.

    vagrant@rails-dev-box:~$ exit
    logout
    Connection to 127.0.0.1 closed.

    host $

### Port 3000 forwards to the virtual machine

Port 3000 in the host computer is forwarded to port 3000 in the virtual machine. That means you can reach Rails applications running in the virtual machine from a browser on your host machine by going to http://localhost:3000.

Forwarding the port is only one of the requirements. You also need to be sure that Rails applications running on the virtual machine to "bind" to the special IP address `0.0.0.0` instead of the default `127.0.0.1`.

    # example
    bin/rails server -b 0.0.0.0

## RAM and CPUs

By default, the virtual machine launches with 2 GB of RAM and 2 CPUs.

These can be overridden by setting the environment variables `RAILS_DEV_BOX_RAM` and `RAILS_DEV_BOX_CPUS`, respectively. Settings on virtual machine creation don't matter, the environment variables are checked each time the virtual machine boots.

`RAILS_DEV_BOX_RAM` has to be expressed in megabytes, so configure 4096 if you want the virtual machine to have 4 GB of RAM.

Use `vagrant reload` to change the virtual machine with either of those environment variables in place.

```
# see that the virtual machine has defaulted to 2G of memory
host $ vagrant ssh -c "free -h"
              total        used        free      shared  buff/cache   available
Mem:           1.9G        315M        1.4G         11M        260M        1.5G
Swap:          2.0G          0B        2.0G

# instruct the virtual machine to rebuild itself with 1G of memory
host $ RAILS_DEV_BOX_RAM=1024 vagrant reload

# see that the change has taken effect
host $ vagrant ssh -c "free -h"
              total        used        free      shared  buff/cache   available
Mem:           985M        308M        407M         11M        269M        526M
Swap:          2.0G          0B        2.0G
```

## What's Installed on the Virtual Machine

* Development tools

* Git

* Ruby 2.5

* Bundler

* SQLite3, MySQL, and Postgres

* Databases and users needed to run the Active Record test suite

* System dependencies for nokogiri, sqlite3, mysql, mysql2, and pg

* Memcached

* Redis

* RabbitMQ

* An ExecJS runtime

## Recommended Workflow

The recommended workflow is

* edit in the host computer

* test within the virtual machine.

This workflow is convenient because in the host computer you normally have your editor of choice fine-tuned, Git configured, and SSH keys in place.

## Install Your Rails Fork into the Virtual Machine

Clone your Rails fork into the `rails-dev-box` directory on the host computer:

    host $ ls
    bootstrap.sh MIT-LICENSE README.md Vagrantfile
    host $ git clone git@github.com:<your username>/rails.git

Vagrant mounts the `rails-dev-box` directory as `/vagrant` within the virtual machine:

    vagrant@rails-dev-box:~$ ls /vagrant
    bootstrap.sh MIT-LICENSE rails README.md Vagrantfile

Install gem dependencies in the virtual machine:

    vagrant@rails-dev-box:~$ cd /vagrant/rails
    vagrant@rails-dev-box:/vagrant/rails$ bundle

Please have a look at the [Contributing to Ruby on Rails](http://edgeguides.rubyonrails.org/contributing_to_ruby_on_rails.html) guide for tips on how to run test suites, how to generate an application that uses your local checkout of Rails, etc.

## Vagrant Usage

Log out of an ssh session on the virtual machine use the `exit` command or press `ctrl`-`d`

    vagrant@rails-dev-box:~$ exit

Pause (suspend) the virtual machine by running `vagrant suspend` on the host. When a virtual machine is suspended any work it is doing is paused and written out as a snapshot to disk. While suspended the virtual machine will not use any CPU or memory on the host.

    host $ vagrant suspend

Resume a suspended virtual machine

    host $ vagrant resume

Completely shutdown (power off) the virtual machine

    host $ vagrant halt

Boot the virtual machine back up again. **Note** this is the same command used to create the virtual machine in the first place, but Vagrant knows that virtual machine only needs to be restarted and not created from scratch.

    host $ vagrant up

Check the state of the virtual machine

    host $ vagrant status

Completely **delete the virtual machine and all of its contents**:

    host $ vagrant destroy # DANGER: any work on the virtual machine will be lost

Please check the [Vagrant documentation](http://docs.vagrantup.com/v2/) for more information on Vagrant.

## Faster Rails test suites

The default mechanism for sharing folders is convenient and works out the box in
all Vagrant versions, but there are a couple of alternatives that are more
performant.

### rsync

Vagrant 1.5 implements a [sharing mechanism based on rsync](https://www.vagrantup.com/blog/feature-preview-vagrant-1-5-rsync.html)
that dramatically improves read/write performance because files are actually stored in the
guest. Add the following line to the `config` block in the `Vagrantfile`

    config.vm.synced_folder '.', '/vagrant', type: 'rsync'

With that configuration in place you can run `vagrant rsync` to manually sync the vagrant folder to the virtual amchine.

    host $ vagrant rsync

Or you can run `vagrant rsync-auto` to tell vagrant to watch the vagrant folder for changes and rsync them automatically.

    host $ vagrant rsync-auto

### NFS

If you're using Mac OS X or Linux you can increase the speed of Rails test suites with Vagrant's NFS synced folders.

With an NFS server installed (already installed on Mac OS X), add the following to the `config` block in the `Vagrantfile`:

    config.vm.synced_folder '.', '/vagrant', type: 'nfs'
    config.vm.network 'private_network', ip: '192.168.50.4' # ensure this is available

Then run `vagrant up` to propagate the new settings to the virtual machine.

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
