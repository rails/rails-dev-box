################################################################################
# Definition: wget::authfetch
#
# This class will download files from the internet.  You may define a web proxy
# using $::http_proxy if necessary. Username must be provided. And the user's
# password must be stored in the password variable within the .wgetrc file.
#
################################################################################
define wget::authfetch (
  $destination,
  $user,
  $source             = $title,
  $password           = '',
  $timeout            = '0',
  $verbose            = false,
  $redownload         = false,
  $nocheckcertificate = false,
  $execuser           = undef,
) {

  notice('wget::authfetch is deprecated, use wget::fetch with user/password params')

  wget::fetch { $title:
    destination        => $destination,
    source             => $source,
    timeout            => $timeout,
    verbose            => $verbose,
    redownload         => $redownload,
    nocheckcertificate => $nocheckcertificate,
    execuser           => $execuser,
    user               => $user,
    password           => $password,
  }

}
