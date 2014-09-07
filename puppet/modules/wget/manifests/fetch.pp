################################################################################
# Definition: wget::fetch
#
# This class will download files from the internet.  You may define a web proxy
# using $http_proxy if necessary.
#
################################################################################
define wget::fetch (
  $destination,
  $source             = $title,
  $timeout            = '0',
  $verbose            = false,
  $redownload         = false,
  $nocheckcertificate = false,
  $no_cookies         = false,
  $execuser           = undef,
  $user               = undef,
  $password           = undef,
  $headers            = undef,
  $cache_dir          = undef,
  $cache_file         = undef,
  $flags              = undef,
) {

  include wget

  $http_proxy_env = $::http_proxy ? {
    undef   => [],
    default => [ "HTTP_PROXY=${::http_proxy}", "http_proxy=${::http_proxy}" ],
  }
  $https_proxy_env = $::https_proxy ? {
    undef   => [],
    default => [ "HTTPS_PROXY=${::https_proxy}", "https_proxy=${::https_proxy}" ],
  }
  $password_env = $user ? {
    undef   => [],
    default => [ "WGETRC=${destination}.wgetrc" ],
  }

  # not using stdlib.concat to avoid extra dependency
  $environment = split(inline_template('<%= (@http_proxy_env+@https_proxy_env+@password_env).join(\',\') %>'),',')

  $verbose_option = $verbose ? {
    true  => '--verbose',
    false => '--no-verbose'
  }

  if $redownload == true or $cache_dir != undef  {
    $unless_test = 'test'
  } else {
    $unless_test = "test -s ${destination}"
  }

  $nocheckcert_option = $nocheckcertificate ? {
    true  => ' --no-check-certificate',
    false => ''
  }

  $no_cookies_option = $no_cookies ? {
    true  => ' --no-cookies',
    false => '',
  }

  $user_option = $user ? {
    undef   => '',
    default => " --user=${user}",
  }

  if $user != undef {
    $wgetrc_content = $::operatingsystem ? {
      # This is to work around an issue with macports wget and out of date CA cert bundle.  This requires
      # installing the curl-ca-bundle package like so:
      #
      # sudo port install curl-ca-bundle
      'Darwin' => "password=${password}\nCA_CERTIFICATE=/opt/local/share/curl/curl-ca-bundle.crt\n",
      default  => "password=${password}",
    }

    file { "${destination}.wgetrc":
      owner   => $execuser,
      mode    => '0600',
      content => $wgetrc_content,
      before  => Exec["wget-${name}"],
    }
  }

  $output_option = $cache_dir ? {
    undef   => " --output-document='${destination}'",
    default => " -N -P '${cache_dir}'",
  }

  # again, not using stdlib.concat, concatanate array of headers into a single string
  if $headers != undef {
    $headers_all = inline_template('<% @headers.each do | header | -%> --header "<%= header -%>"<% end -%>')
  }

  $header_option = $headers ? {
    undef   => '',
    default => $headers_all,
  }

  $flags_joined = $flags ? {
    undef => '',
    default => inline_template(' <%= @flags.join(" ") %>')
  }

  $exec_user = $cache_dir ? {
    undef   => $execuser,
    default => undef,
  }

  exec { "wget-${name}":
    command     => "wget ${verbose_option}${nocheckcert_option}${no_cookies_option}${header_option}${user_option}${output_option}${flags_joined} '${source}'",
    timeout     => $timeout,
    unless      => $unless_test,
    environment => $environment,
    user        => $exec_user,
    path        => '/usr/bin:/usr/sbin:/bin:/usr/local/bin:/opt/local/bin',
    require     => Class['wget'],
  }

  if $cache_dir != undef {
    $cache = $cache_file ? {
      undef   => inline_template('<%= require \'uri\'; File.basename(URI::parse(@source).path) %>'),
      default => $cache_file,
    }
    file { $destination:
      ensure  => file,
      source  => "${cache_dir}/${cache}",
      owner   => $execuser,
      require => Exec["wget-${name}"],
    }
  }
}
