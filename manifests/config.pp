# Internal define to handle configuration content
#
# Parameters:
#  $file
#    the name (including path) of the configuration file
#    Defaults to $title
#  $recursion
#    String to identify the recursion for the sections
#    For details see code ;(
#    Defaults to '0'
#  $trim
#    integer which gives the amount of spaces used to
#    ident any configuration added in this iteration of the
#    recursion. Defauls to 0 
#  $values
#    Hash of configuration parameters to include in $filename
#    Defaults to {}
#    see ::dovecot for more information
#  $sections
#    Array of configuration section to include in $filenmame
#    Defaults to []
#    see ::dovecot for more information
#
define dovecot::config (
  $file      = $title,
  $recursion = '0',
  $trim      = 0,
  $values    = {},
  $sections  = [],
) {

  # this fragment handles all non Hash values
  concat::fragment { "dovecot: ${file} ${recursion} vals":
    target  => $file,
    content => epp('dovecot/config.epp', {
      'values' => $values,
      'trim'   => $trim
    } ),
    order   => "50-${recursion}-0",
  }

  # if we have sections, we need to recurse (to have sections in sections !)
  $_trim = String('', "%${trim}s")
  $sections.each | $index, $section | {
    concat::fragment { "dovecot: ${file} ${recursion} ${index} start":
      target  => $file,
      content => "${_trim}${section['name']} {",
      order   => "50-${recursion}-${index}-a",
    }
    ::dovecot::config{"${file} ${recursion}_2_${index}":
      file      => $file,
      recursion => "${recursion}-${index}-b",
      values    => pick($sections[$index]['values'],{}),
      sections  => pick($sections[$index]['sections'],[]),
      trim      => $trim + 2,
    }
    concat::fragment { "dovecot: ${file} ${recursion} ${index} end":
      target  => $file,
      content => "${_trim}}",
      order   => "50-${recursion}-${index}-c",
    }
  }
}
