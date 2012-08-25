# Changelog

## 1.0.0

- Support for installation of rbenv plugins (Special thanks to @fgrehm - Fabio
  Rehm)
  * Implemented rbenv::plugin
  * Moved ruby-build to rbenv::plugin::rubybuild
  * Implemented rbenv::plugin::rbenvvars
- Support for custom ruby build definitions (by Fabio Rehm)
- Refactored test suite related to the major changes (by Mislav Marohnic)
- Added bundle resource to bundle install inside a client directory (by
  Marcello Barnaba)
- Added a client resource defining an user that shares an rbenv
  installation. (by Marcello Barnaba)
- Major rewrite of the core parts (Special thanks to @vjt - Marcello
  Barnaba)
  * Rbenv class has been removed and replaced by defines for
    installation, compilation etc.
  * Refactor gem installation. Implemented rubygems provider, type etc.
- Added SuSE dependencies.
- Implemented gem installation capabilities (rbenv::gem first iteration by newrelic team).
- Support multiple users with different rbenvs (by newrelic guys).

## 0.3.1

- Fix escape string for PATH environment variable [GH-11]

## 0.3.0

- Add option to set group of the user [GH-9]
- Add option to set user home

## 0.2.0

- CentOS, Redhat compatibility [GH-5]
- Allow per user installation (several users on a single machine can have rbenv
  setup for them) [GH-5]
- Provide a more generic approach. Now the root user can be used, too.

## 0.1.0

- Move install to a define and provide more parameterization.
  WARNING! This is a major changeset and it is not compatible with previous
  versions. This will be included in a new minor version.

## 0.0.2

- Handle dependencies based on platform.
- Add specs and basic testing structures.

## 0.0.1

- Hello World

