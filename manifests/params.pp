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
  $bin_path     = undef

  case $::osfamily {
    'Debian': {
      $_package_name = 'python-elasticsearch-curator'
      $_provider     = 'apt'
      $_bin_path     = '/usr/local/bin/curator'
    }
    'RedHat': {
      #on RedHat/CentOS, system python interferes with 'yum install python-elasticsearch-curator'
      #use pip instead (i.e. this module does not support yum install of curator)
      $_package_name = 'elasticsearch-curator'
      $_provider     = 'pip'
      case $operatingsystemmajrelease {
        '6': {
          $_bin_path = '/usr/bin/curator'
        }
        '7': {
          $_bin_path = '/bin/curator'
        }
        default: {
          $_bin_path = '/usr/bin/curator'
        }
      }
    }
    default: {
      $_package_name = 'elasticsearch-curator'
      $_provider     = 'pip'
      $_bin_path     = '/usr/bin/curator'
    }
  }

  # Defaults for Curator config, actions, and crontab
  $config_dir      = '/etc/curator'
  $config_user     = 'root'
  $config_group    = 'root'
  $config_filename = 'curator.yml'
}
