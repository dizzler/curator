# == Define: curator::action
#
# This define exists to manage action file fragments for Elastic's Curator.
#
# === Parameters
#
# [*order*]
# The order number controls in which sequence the action file fragments are
# concatenated. REQUIRED.
#
## Supply only one of either 'source' or 'template'.
# [*source*]
# Supply a Puppet file resource to be used as a file fragment for the action file.
#
# [*template*]
# Supply an ERB template to be used as a file fragment for the action file.
#
# === Examples
#
# Set action file fragment content with a Puppet file source:
#
# curator::action { 'snapshot':
#   source => 'puppet://path/to/snapshot-action.yaml',
#   order  => 10,
# }
#
# OR... with template (useful with Hiera):
#
# curator::action { 'snapshot':
#   template => "${module_name}/path/to/shapshot-action.yaml.erb",
#   order    => 10,
# }
#

define curator::action(
  $source              = undef,
  $template            = undef,
  $action              = undef,
  $frequency           = 'daily',
  $order               = undef,
  $description         = undef,
  # required parameters for specific actions
  # requiring action(s) listed in trailing comment
  $alias_name          = undef, #alias
  $allocation_key      = undef, #allocation
  $allocation_value    = undef, #allocation
  $count               = undef, #replicas
  $index_name          = undef, #create_index
  $max_num_segments    = undef, #forcemerge
  $snapshot_repository = undef, #delete_snapshots,restore,snapshot
  # optional parameters for action settings
  # associated actions listed in trailing comment
  $allocation_type     = undef, #allocation
) {
  # Allow use of custom source file or template. If not customized, an ERB
  # template is chosen from this modules "templates" directory based on the
  # value of the $action parameter.
  if ( $source != undef ) {
    $action_content = file($source)
  }
  elsif ( $template != undef ) {
    $action_content = template($template)
  }
  else {
    $action_content = template("curator/${action}.action.erb")
  }

  # $order is a required paramter. Even if you set the order of the action in a
  # custom source file or template, this module still needs the $order so that
  # the action fragment created by this define can be concatenated in the
  # correct order with respect to other actions.
  if ( $order == undef ) {
    fail('Required parameter $order was not set for define ::curator::action.')
  }
  validate_string($order)

  # Each curator action has its own set of required parameters/settings. Verify
  # these settings exist for a given action, using Elastic's documentation as
  # the source of truth.
  $_action = downcase($action)
  case $_action {
    'alias': {
      if ( $alias_name == undef ) {
        fail('Required paramter $alias_name was not set for action=alias in ::curator::action.')
      }
      else {
        validate_string($alias_name)
      }
    }
    'allocation': {
      
    }
    'close': {
      
    }
    'create_index': {
      
    }
    'delete_indices': {
      
    }
    'delete_snapshots': {
      
    }
    'open': {
      
    }
    'forcemerge': {
      
    }
    'replicas': {
      
    }
    'restore': {
      
    }
    'snapshot': {
      
    }
    'undef': {
      fail('Required parameter $action was not set for define ::curator::action.')
    }
    default: {
      fail('Required parameter $action was set to a value not supported by Curator in ::curator::action')
    }
  }

  file_fragment { $name:
    tag     => "CURATOR_ACTION_${cron_frequency}_${::fqdn}",
    content => $action_content,
    order   => $order,
    before  => File_concat["curator-${cron_frequency}-action"],
  }
}
