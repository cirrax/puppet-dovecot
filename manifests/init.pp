#
# This class installs and cofigures dovecot
#
# Parameters:
#  $main_config        = {},
#    Hash of configurations to include in the main 
#    configuration file.
#    Defaults to {}
#  $configs
#    Hash of configs to write
#    Defaults to {}
#  $main_config_file
#    the name of the main configuration file
#    Defaults to $dovecot::params::main_config_file
#  $config_path
#    the path where the configuration is.
#    Defaults to $dovecot::params::config_path
#  $local_configdir
#    the name of a directory to put local
#    configuration files
#    Defaults to $dovecot::params::local_configdir
#  $owner
#    owner of the configuration files
#    Defaults to $dovecot::params::owner
#  $group
#    group of the configuration files
#    Defaults to $dovecot::params::group
#  $mode
#    mode of the configuration files
#    Defaults to $dovecot::params::mode
#  $include_sysdefault = true,
#    if true (the default) an include statement
#    in the main configuration file is added to 
#    include the system defaults before the local
#    configuration.
#
class dovecot (
  $main_config        = {},
  $configs            = {},
  $main_config_file   = $dovecot::params::main_config_file,
  $config_path        = $dovecot::params::config_path,
  $local_configdir    = $dovecot::params::local_configdir,
  $owner              = $dovecot::params::owner,
  $group              = $dovecot::params::group,
  $mode               = $dovecot::params::mode,
  $include_sysdefault = true,
) inherits dovecot::params {

  file{ "${config_path}/${local_configdir}":
    ensure => 'directory',
    owner  => $owner,
    group  => $group,
    mode   => '0755',
  }

  $main_file_defaults = {
    'filename'        => $main_config_file,
    'path'            => $config_path,
    'local_configdir' => $local_configdir,
    'owner'           => $owner,
    'group'           => $group,
    'mode'            => $mode,
    'include_in'      => '',
    'values'          => pick($main_config['values'],{}),
    'sections'        => pick($main_config['sections'],[]),
  }

  $file_defaults = {
    'path'            => "${config_path}/${local_configdir}",
    'local_configdir' => $local_configdir,
    'owner'           => $owner,
    'group'           => $group,
    'mode'            => $mode,
    'include_in'      => "${config_path}/${main_config_file}",
  }

  include ::dovecot::install

  create_resources('::dovecot::configfile', { 'main_config' => {} } , $main_file_defaults)
  create_resources('::dovecot::configfile', $configs, $file_defaults)

  include ::dovecot::service

  if $include_sysdefault  {
    concat::fragment { 'dovecot: include system defaults':
      target  => "${config_path}/${main_config_file}",
      content => '!include conf.d/*',
      order   => '00',
    }
  }
}

