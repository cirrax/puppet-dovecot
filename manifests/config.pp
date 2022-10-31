# Internal define to handle configuration content
#
# @param file
#   the name (including path) of the configuration file
#   Defaults to $title
# @param recursion
#   String to identify the recursion for the sections
#   For details see code ;(
#   Defaults to '0'
# @param trim
#   integer which gives the amount of spaces used to
#   ident any configuration added in this iteration of the
#   recursion. Defauls to 0 
# @param values
#   The hash it expects needs name which corresponds to the $filename saved in $config_path/$local_configdir/
#   For instance the following hash will produce a file in /etc/dovecot/conf.d/master.conf if $config_path
#   and $local_configdir are set to default.
#   **NOTE - the file named will be completely overwritten, so ensure that ALL needed values are specified.**
#
#   <a name="values_example"></a>`Example (hiera):`
#
#   ```
#   dovecot::config:
#     'master.conf':                     # <- name ($filename)
#       values:
#         default_process_limit: 350
#         default_vsz_limit: 1024M
#         default_client_limit: 2000
#   ```
#
#   The resulting **/etc/dovecot/conf.d/master.conf** will look like this:
#
#   ```
#   This file is managed by Puppet. DO NOT EDIT.
#   default_client_limit = 2000
#   default_process_limit = 350
#   default_vsz_limit = 1024M
#   ```
#   
#   Defaults to {}
# @param sections
#   Sometimes you need to have [Sections](https://doc.dovecot.org/configuration_manual/config_file/#sections) 
#   in your config files.  
#   These are defined as an Array of hashes similar to the intial config hash:  
#   Expanding on our previous example, wanting to add an section we can add a 'sections' key to our hash.  
#   Each additional section is started with a **-** on its own line and indented correctly.
#
#   <a name="sections_example"></a>`Example (hiera):`
#
#   ```
#   dovecot::config:
#     mail.conf:
#       values:
#         'mail_location': 'maildir:~/'
#       sections:
#         - name: 'namespace inbox'
#           values:
#             'inbox': 'yes'
#             'seperator': '.'
#             'prefix': 'INBOX'
#   ``` 
#
#   This will result in **/etc/dovecot/conf.d/mail.conf** containing the following:
#
#   ```
#   This file is managed by Puppet. DO NOT EDIT.
#   mail_location = maildir:~/
#   namespace inbox {
#     inbox = yes
#     separator =.
#     prefix =INBOX.
#   }
#   ``` 
#
#   Some dovecot sections have a double bracket system (section within a section). This is done as follows:
#
#   Example (hiera):
#
#   ```
#   dovecot::config:
#     master.conf:
#       values:
#         default_process_limit: 350
#         default_vsz_limit: 1024M
#         default_client_limit: 2100
#       sections:
#         - name: 'service imap-login'
#           sections:
#             - name: 'inet_listener imap'
#               values:
#                 'port': '143'
#             - name: inet_listener imaps
#               values:
#                 'port': '993'
#                 'ssl': 'yes'
#             - name: 'inet_listener pop3'
#               values:
#                 'port': '110'
#             - name: inet_listener pop3s
#               values:
#                 'port': '995'
#                 'ssl': 'yes'
#   ```
#   This will produce the file **/etc/dovecot/conf.d/master.conf** with content below:
#
#   ```
#   This file is managed by Puppet. DO NOT EDIT.
#   default_client_limit = 2100
#   default_process_limit = 350
#   default_vsz_limit = 1024M
#   service imap-login {
#
#     inet_listener imap {
#       port = 143
#     }
#     inet_listener imaps {
#       port = 993
#       ssl = yes
#     }
#   }
#   service pop3-login {
#
#     inet_listener pop3 {
#       port = 110
#     }
#     inet_listener pop3s {
#       port = 995
#       ssl = yes
#     }
#   }
#   ```
#
#   Defaults to []
# 
define dovecot::config (
  String  $file      = $title,
  String  $recursion = '0',
  Integer $trim      = 0,
  Hash    $values    = {},
  Array[Hash]   $sections  = [],
) {
  # this fragment handles all non Hash values
  concat::fragment { "dovecot: ${file} ${recursion} vals":
    target  => $file,
    content => epp('dovecot/config.epp', {
        'values' => $values,
        'trim'   => $trim
    }),
    order   => "50-${recursion}-0",
  }

  # if we have sections, we need to recurse (to have sections in sections !)
  $_trim = String('', "%${trim}s")
  $sections.each | Integer $index, Hash $section | {
    concat::fragment { "dovecot: ${file} ${recursion} ${index} start":
      target  => $file,
      content => "${_trim}${section['name']} {",
      order   => "50-${recursion}-${index}-a",
    }
    ::dovecot::config { "${file} ${recursion}_2_${index}":
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
