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
#  String. Major version of Curator repository (e.g. '2', '3', '5') from which
#  to download packages.
#
class curator (
  $ensure       = $::curator::params::ensure,
  $provider     = $::curator::params::provider,
  $package_name = $::curator::params::package_name,
  $manage_repo  = $::curator::params::manage_repo,
  $repo_version = $::curator::params::repo_version,
) inherits curator::params
{
  if ( $ensure != 'latest' ) or ( $ensure != 'absent' ) {
    if versioncmp($ensure, '4.0.0') < 0 {
      fail('This version of the curator module only supports version 4.0.0 or later of curator')
    }
  }

  validate_bool($manage_repo)

  if ( $manage_repo == true ) {
    if ( $provider != undef ) and ( $package_name != undef ) {
      $curator_provider     = $provider
      $curator_package_name = $package_name
    }
    else {
      $curator_provider     = $_provider
      $curator_package_name = $_package_name
    }

    unless ( $repo_version != undef ) and ( validate_bool($repo_version) ) {
      fail('curator module cannot manage_repo if $repo_version is not specified as a string (e.g. "3")')
    }

    include Class['::curator::manage_repo'] -> Package["${curator_package_name}"]
  }

  package { $curator_package_name:
    ensure   => $ensure,
    provider => $curator_provider,
  }

  class { ::curator::config:
    
  }

  $actions = keys($curator_actions)

  $actions.each |String $action| {
    file_concat { "curator-${action_cron}-actionfile":
      ensure => file,
      tag    => "CURATOR_ACTION_${action_cron}_${::fqdn}",
    }
  }

######
  validate_hash($curator_actions)

  create_resources('::curator::action', $actions)

}
