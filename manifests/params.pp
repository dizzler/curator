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
  $config_dir = '/etc/curator'

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

  # Default path for Curator binary
  $curator_bin = '/bin/curator'

  # Defaults used for action files
  $action_files = {'daily': [ ]}
}
