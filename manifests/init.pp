# == Class: curator
#
# Installs Elastic's Curator, manages the curator.conf file, creates an
# action.yml file for the actions to be performed by a given Curator job, and
# adds Curator jobs to cron for scheduled management of Elasticsearch indices.
#
# === Parameters
#
# [*ensure*]
#  String. Specify whether Curator should be installed and, if so, which version.
#  Default: 'latest'
#
# [*provider*]
#  String. Puppet provider to use to install Curator.
#  Default: 'pip'
#
# [*package_name*]
#  String. Name of package to be installed. Varies by provider.
#  Default: 'elasticsearch-curator'
#
# [*manage_repo*]
#  Boolean. Specify whether this module should manage the addition of the
#  package repo for your system.
#  Default: 'false'
#
# [*repo_version*]
#  String. Major version of Curator repository (e.g. '2', '3', '4', '5') from which
#  to download packages.
#  Default: '4'
#
class curator (
  $ensure               = $::curator::params::ensure,
  $provider             = $::curator::params::provider,
  $package_name         = $::curator::params::package_name,
  $manage_repo          = $::curator::params::manage_repo,
  $repo_version         = $::curator::params::repo_version,
  $bin_path             = $::curator::params::bin_path,
  $config_dir           = $::curator::params::config_dir,
  $config_filename      = $::curator::params::config_filename,
  $config_user          = $::curator::params::config_user,
  $config_group         = $::curator::params::config_group,
  $curator_action_files = hiera_hash(curator_action_files, {}),
  #$curator_actions      = hiera_hash(curator_actions, {}),
) inherits curator::params
{
  if ( $ensure != 'latest' ) or ( $ensure != 'absent' ) {
    if versioncmp($ensure, '4.0.0') < 0 {
      fail('This version of the curator module only supports version 4.0.0 or later of curator')
    }
  }

  if ( $provider != undef ) {
    $curator_provider     = $provider
    $curator_package_name = $package_name ? {
      undef   => $_package_name,
      default => $package_name,
    }
  }
  else {
    $curator_provider     = $_provider
    $curator_package_name = $_package_name
  }

  $curator_bin_path = $bin_path ? {
    undef   => $_bin_path,
    default => $bin_path,
  }

  validate_bool($manage_repo)

  if ( $manage_repo == true ) {
    if ( $repo_version == undef ) {
      fail('curator module requires a valid string for repo_version parameter, such as "4"')
    }
    else {
      validate_string($repo_version)
      case $repo_version {
        '2','3': {
          fail('curator module does not support repo versions prior to "4"')
        }
        '4': {
          info('curator module using version "4" of elastic/curator repo for manage_repo')
        }
        '5': {
          info('curator module using version "5" of elastic/curator repo for manage_repo')
        }
        default: {
          fail('invalid repo_version supplied for manage_repo in curator module')
        }
      }
    }

    include Class['::curator::manage_repo'] -> Package["${curator_package_name}"]
  }

  package { $curator_package_name:
    ensure   => $ensure,
    provider => $curator_provider,
    before   => Class['::curator::config']
  }

  class { '::curator::config':
    config_dir   => $config_dir,
    config_user  => $config_user,
    config_group => $config_group,
  }

  #validate_hash($curator_actions)
  #create_resources('::curator::action', $curator_actions)

  validate_hash($curator_action_files)
  $curator_action_file_defaults = {
    user     => $config_user,
    group    => $config_group,
    bin_path => $curator_bin_path,
  }
  create_resources('curator::action_file', $curator_action_files, $curator_action_file_defaults)
}
