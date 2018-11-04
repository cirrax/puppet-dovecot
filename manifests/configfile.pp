# Internal define to create a configuration file
# and include it in the main config file
#
# Parameters:
#  $path
#    path to the configuration file
#  $owner
#    owner of the configuration file
#  $group,
#    group of the configuration file
#  $mode,
#    mode of the configuration file
#  $local_configdir
#    directory name where the local configuration is
#    only used if $include_in is not set to ''
#  $include_in
#    filename to add an include statement for the configuration
#    file. Defaults to '' which disables this function
#  $filename
#    the name of the configuration file
#    Defaults to $title
#  $values
#    Hash of configuration parameters to include in $filename
#    Defaults to {}
#    see ::dovecot for more information
#  $sections
#    Array of configuration section to include in $filenmame
#    Defaults to []
#    see ::dovecot for more information
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

