# Internal define to create a configuration file
# and include it in the main config file
#
# @param path
#   path to the configuration file
# @param owner
#   owner of the configuration file
# @param group
#   group of the configuration file
# @param mode
#   mode of the configuration file
# @param local_configdir
#   directory name where the local configuration is
#   only used if $include_in is not set to ''
# @param include_in
#   filename to add an include statement for the configuration
#   file. Defaults to '' which disables this function
# @param filename
#   the name of the configuration file
#   Defaults to $title
# @param values
#   Hash of configuration parameters to include in $filename
#   Defaults to {}
#   see ::dovecot for more information
# @param sections
#   Array of configuration section to include in $filenmame
#   Defaults to []
#   see ::dovecot for more information
#
define dovecot::configfile (
  String $path,
  String $owner,
  String $group,
  String $mode,
  String $local_configdir,
  String $include_in      = '',
  String $filename        = $title,
  Hash   $values          = {},
  Array[Hash] $sections        = [],
) {

  concat { "${path}/${filename}":
    owner          => $owner,
    group          => $group,
    mode           => $mode,
    warn           => true,
    notify         => Service[ 'dovecot'],
    ensure_newline => true,
  }

  ::dovecot::config{ $filename :
    file     => "${path}/${filename}",
    values   => $values,
    sections => $sections,
  }

  if $include_in != '' {
    concat::fragment { "dovecot: include ${filename} in ${include_in}":
      target  => $include_in,
      content => "!include ${local_configdir}/${filename}",
      order   => '01',
    }
  }
}

