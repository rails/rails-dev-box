redis module for puppet
=======================

0.10.0
------
Default version to install is 2.8.12.
Expose new parameters to redis class. - @brucem
Add parameters to configure snapshotting. - @kjoconnor
Fix deprecation warning in template. - @aadamovich
Add support for redis 2.8. - @rickard-von-essen
Add versions to module dependencies. - @yjpa7145
Updated download URL. - @coffeejunk
Adds user and group configuration parameters. - @yjpa7145
Fix rubygems deprecation warning. - @yjpa7145
Disable some puppet lint warnings.
Add chkconfig to init file. - @antonbabenko
Add redis::instance define to allow multiple instances. - @evanstachowiak

0.0.9
-----
Use maestrodev/wget and puppetlabs/gcc to replace some common package dependencies. - @garethr

0.0.8
-----
Fix init script when redis_bind_address is not defined (the default).

0.0.7
-----
Add support for parameterized listening port and bind address.

0.0.6
-----
Add support for installing any available version.

0.0.5
-----
Add option to install 2.6.
Add spec tests.

0.0.4
-----
It's possible to configure a password to redis setup.

0.0.3
-----
Fix init script.

0.0.2
-----
Change the name to redis so that module name and class name are in sync.

0.0.1
-----
First release!
