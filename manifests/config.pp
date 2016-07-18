# == Class: cirrus_elasticsearch::curator_config
#
# This class exists to coordinate the functions of Curator for
# Elasticsearch, including the configuration and action files referenced
# by Curator's command line interface.
#
# Elasticsearch Curator performs operations on Elasticsearch indices,
# such as managing index aliases, snapshots, optimizations, and deletions.
#
# === Parameters
#
# 
#
# === Examples
#
#

class curator::config (
  $config_dir       = undef,
  $config_dir_purge = true,
  $config_filename  = undef,
  $config_user      = root,
  $config_group     = root,
  $config_source    = undef,
  $config_template  = 'curator/curator.yml.erb',
  $hosts            = ['localhost'],
  $port             = 9200,
  $url_prefix       = undef,
  $use_ssl          = false,
  $certificate      = undef,
  $client_cert      = undef,
  $client_key       = undef,
  $ssl_no_validate  = false,
  $http_auth        = false,
  $http_user        = undef,
  $http_password    = undef,
  $timeout          = 30,
  $master_only      = true,
  $loglevel         = 'INFO',
  $logfile          = '/var/log/curator.log',
  $logformat        = 'default',
)  
{
  File {
    owner => $config_user,
    group => $config_group,
  }

  include ::curator::params

  $curator_config_dir = $config_dir ? {
    undef   => $::curator::params::config_dir,
    default => $config_dir,
  }

  $curator_config_filename = $config_filename ? {
    undef   => $::curator::params::config_filename,
    default => $config_filename,
  }

  file { $curator_config_dir:
    ensure  => directory,
    purge   => $config_dir_purge,
    recurse => $config_dir_purge,
  }

  if ( $config_source != undef ) {
    $config_content = file($config_source)
  }
  else {
    $config_content = template($config_template)
  }

  file { "${curator_config_dir}/${curator_config_filename}":
    ensure  => file,
    content => $config_content,
    require => File["${curator_config_dir}"],
  }
}
