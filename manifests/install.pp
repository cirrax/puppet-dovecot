#
# This class installs dovecot packages
#
# @param packages
#   Array of packages to install
#   Example (hiera):  
#     dovecot::install:  
#       - dovecot-core  
#       - dovecot-imapd  
#       - dovecot-pop3d  
#  
#  Will install current versions of dovecot-core,dovecot-imapd and dovecot-pop3d
# @param package_ensure
#   what to ensure for package
#   Defaults to 'installed'
#
class dovecot::install (
  Array  $packages       = ['dovecot-core'],
  String $package_ensure = 'installed',
) {
  package { $packages:
    ensure => $package_ensure,
    tag    => 'dovecot',
  }
}
