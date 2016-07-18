# Class curator::params
#
# Default parameters for curator module
#
class curator::params {
  # Defaults used for installation of Curator
  $ensure       = 'latest'
  $provider     = undef
  $package_name = undef
  $manage_repo  = false
  $repo_version = undef

  case $::osfamily {
    'Debian': {
      $_package_name = 'python-elasticsearch-curator'
      $_provider     = 'apt'
    }
    'RedHat': {
      $_package_name = 'python-elasticsearch-curator'
      $_provider     = 'yum'
    }
    default: {
      $_package_name = 'elasticsearch-curator'
      $_provider     = 'pip'
    }
  }

  # Defaults for Curator config, actions, and crontab
  $config_dir   = '/etc/curator'
  $config_user  = 'root'
  $config_group = 'root'

  # Default path for Curator binary
  $bin_path = '/bin/curator'
}
