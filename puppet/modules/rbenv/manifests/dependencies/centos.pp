class rbenv::dependencies::centos {

  # These are the "build essentials" for RHEL / CentOS
  if ! defined(Package['autoconf'])  { package { 'autoconf':  ensure => installed } }
  if ! defined(Package['automake'])  { package { 'automake':  ensure => installed } }
  if ! defined(Package['binutils'])  { package { 'binutils':  ensure => installed } }
  if ! defined(Package['bison'])     { package { 'bison':     ensure => installed } }
  if ! defined(Package['flex'])      { package { 'flex':      ensure => installed } }
  if ! defined(Package['gcc'])       { package { 'gcc':       ensure => installed } }
  if ! defined(Package['gcc-c++'])   { package { 'gcc-c++':   ensure => installed } }
  if ! defined(Package['gettext'])   { package { 'gettext':   ensure => installed } }
  if ! defined(Package['libtool'])   { package { 'libtool':   ensure => installed } }
  if ! defined(Package['make'])      { package { 'make':      ensure => installed } }
  if ! defined(Package['patch'])     { package { 'patch':     ensure => installed } }
  if ! defined(Package['pkgconfig']) { package { 'pkgconfig': ensure => installed } }

  # Other packages required to build a proper Ruby
  if ! defined(Package['readline-devel']) { package { 'readline-devel': ensure => installed } }
  if ! defined(Package['openssl-devel'])  { package { 'openssl-devel':  ensure => installed } }
  if ! defined(Package['zlib-devel'])     { package { 'zlib-devel':     ensure => installed } }

  # Git and curl are needed for rbenv and ruby-build
  if ! defined(Package['git'])  { package { 'git':  ensure => installed } }
  if ! defined(Package['curl']) { package { 'curl': ensure => installed } }
}
