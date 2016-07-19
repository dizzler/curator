#
define curator::action_file (
  $content       = undef,
  $source        = undef,
  $cron_ensure   = undef,
  $cron_hour     = 0,
  $cron_minute   = 30,
  $cron_month    = '*',
  $cron_monthday = '*',
  $cron_weekday  = '*',
  $user          = $::curator::params::config_user,
  $group         = $::curator::params::config_group,
  $bin_path      = $::curator::params::_bin_path,
)
{
  include ::curator::config

  $curator_config_path     = "${curator::config::curator_config_path}"
  $curator_actions_dir     = "${curator::config::curator_actions_dir}"
  $curator_actionfile_name = "${curator_actions_dir}/${name}.action.yml"

  if ( $content != undef ) or ( $source != undef ) {
    if ( $content != undef ) {
      $_content = $content
    }
    else {
      $_content = file($source)
    }

    file { "curator_${name}_actionfile":
      ensure  => file,
      path    => "${curator_actionfile_name}",
      content => $_content,
      owner   => $user,
      group   => $group,
      mode    => '0644',
    }
  }
  else {
    file_concat { "curator_${name}_actionfile_concat":
      tag   => "CURATOR_ACTION_${name}_${::fqdn}",
      path  => "${curator_actionfile_name}",
      owner => $user,
      group => $group,
      mode  => '0644',
    }
  }

  if ( $cron_ensure != undef ) {
    cron { "curator_${name}_cron":
      ensure   => $cron_ensure,
      command  => "${bin_path} --config ${curator_config_path} ${curator_actionfile_name} >/dev/null",
      hour     => $cron_hour,
      minute   => $cron_minute,
      month    => $cron_month,
      monthday => $cron_monthday,
      weekday  => $cron_weekday,
      user     => $user,
    }
  }
}
