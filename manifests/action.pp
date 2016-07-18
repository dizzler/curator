# == Define: curator::action
#
# This define exists to manage action file fragments for Elastic's Curator.
#
# === Parameters
#
# [*cron_ensure*]
#  Boolean. If false, creates action fragment for concatenation in action file,
#  but does not schedule a cron job and instead runs curator command with
#  '--dry-run' parameter, where output of dry-run simulation sent to logfile.
#  If true, schedules a cronjob under the crontab of $cron_user, with frequency
#  determined by $cron_{hour,minute,month,monthday,weekday} parameters.
#  Default: false
#
# [*order*]
# The order number controls in which sequence the action file fragments are
# concatenated. REQUIRED.
#
## Supply only one of either 'source' or 'template'.
# [*source*]
# String. Supply a Puppet file resource to be used as a file fragment for the
# action file. 
#
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

define curator::action (
  $action_file           = 'daily',
  $cron_ensure           = undef,
  $cron_hour             = 0,
  $cron_minute           = 30,
  $cron_month            = '*',
  $cron_monthday         = '*',
  $cron_weekday          = '*',
  $cron_user             = 'root',
  $order                 = undef,
  # if $source is supplied, all parameters below $source will be ignored
  $source                = undef,
  $action                = undef,
  $description           = undef,
  # required parameters for specific actions and/or filtertypes
  # associated action(s) listed in trailing comment
  $alias_name            = undef, #alias
  $allocation_key        = undef, #allocation
  $allocation_value      = undef, #allocation
  $count                 = undef, #replicas
  $index_name            = undef, #create_index
  $max_num_segments      = undef, #forcemerge,
  $repository            = undef, #delete_snapshots,restore,snapshot
  # optional parameters for ALL actions
  $continue_if_exception = false,
  $disable_action        = false,
  $ignore_empty_list     = false, #not available for create_index action
  $timeout_override      = undef,
  # optional parameters for specific actions
  # associated action(s) listed in trailing comment
  $allocation_type       = undef, #allocation
  $delay                 = undef, #forcemerge
  $delete_aliases        = undef, #close
  $extra_settings        = undef, #alias,create_index,
  $ignore_unavailable    = false, #snapshot
  $include_aliases       = false, #restore
  $include_global_state  = true,  #snapshot
  $partial               = false, #snapshot
  $rename_pattern        = undef, #restore
  $rename_replacement    = undef, #restore
  $retry_count           = "3",   #delete_snapshots
  $retry_interval        = "120", #delete_snapshots
  $skip_repo_fs_check    = false, #snapshot
  $snapshot_name         = undef, #snapshot
  $wait_for_completion   = undef, #allocation(false),replicas(false),snapshot(true)
  # filters to apply with this action; if no filter specified then fail
  # if $filter_none is true, then this will override all other filters
  # all other $filters_* expect a hash as input
  #$filter_allocated     = undef,
  #$filter_age           = undef,
  #$filter_closed        = undef,
  #$filter_forcemerged   = undef,
  #$filter_kibana        = undef,
  #$filter_opened        = undef,
  #$filter_pattern       = undef,
  #$filter_space         = undef,
  #$filter_state         = undef,
  $filter_none           = false, #set to true to override ANY and ALL other filters
  $filter_1_enable       = false,
  $filter_1              = {},
  $filter_2_enable       = false,
  $filter_2              = {},
  $filter_3_enable       = false,
  $filter_3              = {},
  $filter_4_enable       = false,
  $filter_4              = {},
  $filter_5_enable       = false,
  $filter_5              = {},
  $filter_6_enable       = false,
  $filter_6              = {},
  $filter_7_enable       = false,
  $filter_7              = {},
  $filter_8_enable       = false,
  $filter_8              = {},
  $filter_9_enable       = false,
  $filter_9              = {},
) {
  # Allow use of custom source file to define the entire action and its filters.
  # If not customized, an ERB template is chosen from this module's "templates"
  # directory based on the value of the $action parameter.
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
