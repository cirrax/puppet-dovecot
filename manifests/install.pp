#
# This class installs dovecot packages
#
# @param packages
#   Array of packages to install
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
