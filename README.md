# A Virtual Machine for Ruby on Rails Core Development

## Introduction

This project automates the setup of a development environment for Ruby on Rails core development. This is the easiest way to build a box with everything ready to start hacking on your pull request, all in an isolated virtual machine.

## Requirements

* [VirtualBox](https://www.virtualbox.org)

* [Vagrant](http://vagrantup.com)

## How To Build The Virtual Machine

Building the virtual machine is this easy:

    git clone https://github.com/rails/rails-dev-box.git
    cd rails-dev-box
    vagrant up

That's it.

If the base box is not present that command fetches it first. The setup itself takes about 3 minutes in my MacBook Air. After the installation has finished, you can access the virtual machine with

    vagrant ssh

Port 3000 in the host computer is forwarded to port 3000 in the virtual machine. Thus, applications running in the virtual machine can be accessed via localhost:3000 in the host computer.

## What's In The Box

* Git

* Ruby 1.9.3

* Bundler

* SQLite3, MySQL, and Postgres

* System dependencies for nokogiri, sqlite3, mysql, mysql2, and pg

* Databases and users needed to run the Active Record test suite

* therubyracer

* Memcached

## What's Next

The first time you log into the box you generally want to configure Git:

    git config --global user.name "John Doe"
    git config --global user.email johndoe@example.com

set up your SSH keys, and clone your fork.

## Virtual Machine Management

When done just log out with `^D` and suspend the virtual machine

    vagrant suspend

then, resume to hack again

    vagrant resume

Run

    vagrant halt

to shutdown the virtual machine, and

    vagrant up

to boot it again.

And to completely wipe the virtual machine from the disk **destroying all its contents**:

    vagrant destroy # DANGER: all is gone

Please check the [Vagrant documentation](http://vagrantup.com/v1/docs/index.html) for more information on Vagrant.
