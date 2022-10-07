#
# This class installs and cofigures dovecot
#
# Parameters:
# @param main_config        = {},
#   Hash of configurations to include in the main 
#   configuration file.
#   Defaults to {}
# @param configs
#   Hash of configs to write
#   Defaults to {}
# @param main_config_file
#   the name of the main configuration file
# @param config_path
#   the path where the configuration is.
# @param local_configdir
#   the name of a directory to put local
#   configuration files
# @param owner
#   owner of the configuration files
# @param group
#   group of the configuration files
# @param mode
#   mode of the configuration files
# @param include_sysdefault = true,
#   if true (the default) an include statement
#   in the main configuration file is added to 
#   include the system defaults before the local
#   configuration.
# @param create_resources
#   a Hash of Hashes to create additional resources eg. to
#   retrieve a certificate.
#   Defaults to {} (do not create any additional resources)
#   Example (hiera):
#
#   dovecot::create_resources:
#       sslcert::get_cert:
#           get_my_dovecot_cert:
#             private_key_path: '/etc/dovecot/ssl/key.pem'
#             cert_path: '/etc/dovecot/ssl/cert.pem'
#
#   Will result in  executing:
#
#   sslcert::get_cert{'get_my_postfix_cert':
#     private_key_path => "/etc/dovecot/ssl/key.pem"
#     cert_path        => "/etc/dovecot/ssl/cert.pem"
#   }
#
class dovecot (
  Hash    $main_config        = {},
  Hash    $configs            = {},
  String  $main_config_file   = 'dovecot.conf',
  String  $config_path        = '/etc/dovecot',
  String  $local_configdir    = 'conf.d',
  String  $owner              = 'root',
  String  $group              = 'root',
  String  $mode               = '0644',
  Boolean $include_sysdefault = true,
  Hash    $create_resources   = {},
) {
  Class['dovecot::install'] -> ::Dovecot::Configfile <||>

  file { "${config_path}/${local_configdir}":
    ensure  => 'directory',
    owner   => $owner,
    group   => $group,
    mode    => '0755',
    require => Class['dovecot::install'],
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

  include dovecot::install

  create_resources('::dovecot::configfile', { 'main_config' => {} }, $main_file_defaults)
  create_resources('::dovecot::configfile', $configs, $file_defaults)

  include dovecot::service

  if $include_sysdefault {
    concat::fragment { 'dovecot: include system defaults':
      target  => "${config_path}/${main_config_file}",
      content => '!include conf.d/*',
      order   => '00',
    }
  }

  # create generic resources (eg. to retrieve certificate)
  $create_resources.each | $res, $vals | {
    create_resources($res, $vals, { 'require' => Class['dovecot::install'] })
  }
}
