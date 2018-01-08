# manage dovecot service
#
# Parameters:
#   $ensure
#     Whether a service should be running.
#     Defaults to 'running'
#   $enabled
#     Whether a service should be enabled.
#     Defaults to true
#   $service_name
#     The name of the service
#     Defaults to $dovecot::params::service_name
#
class dovecot::service (
  $ensure       = 'running',
  $enable       = true,
  $service_name = $dovecot::params::service_name,
) inherits dovecot::params {

  Package<| tag =='dovecot'  |> -> Service['dovecot']

  service { 'dovecot':
    ensure => $ensure,
    enable => $enable,
    name   => $service_name,
  }
}

