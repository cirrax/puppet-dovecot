# manage dovecot service
#
# @param ensure
#   Whether a service should be running.
#   Defaults to 'running'
# @param enable
#   Whether a service should be enabled.
#   Defaults to true
# @param service_name
#   The name of the service
#
class dovecot::service (
  String  $ensure       = 'running',
  Boolean $enable       = true,
  String  $service_name = 'dovecot',
) {

  Package<| tag =='dovecot'  |> -> Service['dovecot']

  service { 'dovecot':
    ensure => $ensure,
    enable => $enable,
    name   => $service_name,
  }
}

