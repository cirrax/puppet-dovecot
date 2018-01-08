#
# This class installs dovecot packages
#
# Parameters:
#  $packages:
#    Array of packages to install
#    Defaults to $dovecot::params::packages
#  $package_ensure:
#    what to ensure for package
#    Defaults to 'installed'
#
class dovecot::install (
  $packages         = $dovecot::params::packages,
  $package_ensure   = 'installed',
) inherits dovecot::params {

  package { $packages:
    ensure => $package_ensure,
    tag    => 'dovecot',
  }
}

