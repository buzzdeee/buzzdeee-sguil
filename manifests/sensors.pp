# Class: sguil
# ===========================
#
# Full description of class sguil here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'sguil':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2019 Your name here, unless otherwise noted.
#
class sguil::sensors (
  Hash $sensors,
  String $package_name,
) {

  package { $package_name:
    ensure => installed,
  }

  $sensors.each |String $sensor, Hash $params| {
    file { "/etc/rc.d/sguil_${params['type']}sensor_${sensor}":
        owner      => 'root',
        group      => '0',
        mode       => '0755',
        content    => epp('sguil/sensor_rcscript.epp', {
        'configfile' => "/etc/sguil_${params['type']}sensor_${sensor}.conf",
        'agenttype'  => $params['type'],
        'daemon_user' => $params['daemon_user'],
      })
    }
    case $params['type'] {
      'pcap': {
                file { "/etc/sguil_${params['type']}sensor_${sensor}.conf":
                  owner   => $params['daemon_user'],
                  group   => '0',
                  mode    => '0440',
                  content => epp("sguil/${params['type']}_agent.conf.epp", {
                      'hostname'         => $params['hostname'],
                      'net_group'        => $params['net_group'],
                      'log_dir'          => $params['log_dir'],
                      'file_prefix'      => $params['file_prefix'], })
                }

                service { "sguil_${params['type']}sensor_${sensor}":
                  ensure => running,
                  require => [ File["/etc/rc.d/sguil_${params['type']}sensor_${sensor}"],
                              File["/etc/sguil_${params['type']}sensor_${sensor}.conf"]],
                }
              }
      'snort': {
                file { "/etc/sguil_${params['type']}sensor_${sensor}.conf":
                  owner   => $params['daemon_user'],
                  group   => '0',
                  mode    => '0640',
                  content => epp("sguil/${params['type']}_agent.conf.epp", {
                      'server_host' => $params['server_host'],
                      'server_port' => $params['server_port'],
                      'by_port'     => $params['by_port'],
                      'hostname'    => $params['hostname'],
                      'net_group'   => $params['net_group'],
                      'log_dir'     => $params['log_dir'],
                      'snort_perf_stats' => $params['snort_perf_stats'],
                      'snort_perf_file' => $params['snort_perf_file'],
                      'portscan' => $params['portscan'], })
                }

                service { "sguil_${params['type']}sensor_${sensor}":
                  ensure  => running,
                  require => [ File["/etc/rc.d/sguil_${params['type']}sensor_${sensor}"],
                              File["/etc/sguil_${params['type']}sensor_${sensor}.conf"]],
                }
              }
      default: { notice("sensor type ${params['type']} not supported")
                fail()
              }
    }
  }

}
