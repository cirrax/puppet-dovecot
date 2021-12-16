#
# This class installs dovecot packages
#
# Parameters:
#  $packages:
#    Array of packages to install
#  $package_ensure:
#    what to ensure for package
#    Defaults to 'installed'
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

