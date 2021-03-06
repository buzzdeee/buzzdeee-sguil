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
    # take care of the sensors config file
    case $params['type'] {
      'ossec': {
                file { "/etc/${params['type']}_agent.conf":
                  owner   => $params['daemon_user'],
                  group   => '0',
                  mode    => '0440',
                  content => epp("sguil/${params['type']}_agent.conf.epp", {
                      'hostname'           => $params['hostname'],
                      'server_host'        => $params['server_host'],
                      'server_port'        => $params['server_port'],
                      'net_group'          => $params['net_group'],
                      'dns'                => $params['dns'],
                      'use_dns'            => $params['use_dns'],
                      'default_dns_domain' => $params['default_dns_domain'], })
                }
              }
      'pads': {
                file { "/etc/${params['type']}_agent.conf":
                  owner   => $params['daemon_user'],
                  group   => '0',
                  mode    => '0440',
                  content => epp("sguil/${params['type']}_agent.conf.epp", {
                      'hostname'    => $params['hostname'],
                      'server_host' => $params['server_host'],
                      'server_port' => $params['server_port'],
                      'net_group'   => $params['net_group'],
                      'pads_fifo'   => $params['pads_fifo'], })
                }
              }
      'pcap': {
                file { "/etc/${params['type']}_agent.conf":
                  owner   => $params['daemon_user'],
                  group   => '0',
                  mode    => '0440',
                  content => epp("sguil/${params['type']}_agent.conf.epp", {
                      'hostname'    => $params['hostname'],
                      'server_host' => $params['server_host'],
                      'server_port' => $params['server_port'],
                      'net_group'   => $params['net_group'],
                      'log_dir'     => $params['log_dir'],
                      'file_prefix' => $params['file_prefix'], })
                }
              }
      'snort': {
                file { "/etc/${params['type']}_agent.conf":
                  owner   => $params['daemon_user'],
                  group   => '0',
                  mode    => '0640',
                  content => epp("sguil/${params['type']}_agent.conf.epp", {
                      'server_host'      => $params['server_host'],
                      'server_port'      => $params['server_port'],
                      'by_port'          => $params['by_port'],
                      'hostname'         => $params['hostname'],
                      'net_group'        => $params['net_group'],
                      'log_dir'          => $params['log_dir'],
                      'snort_perf_stats' => $params['snort_perf_stats'],
                      'snort_perf_file'  => $params['snort_perf_file'],
                      'portscan'         => $params['portscan'], })
                }
              }
      'suricata': {
                file { "/etc/${params['type']}_agent.conf":
                  owner   => $params['daemon_user'],
                  group   => '0',
                  mode    => '0640',
                  content => epp("sguil/${params['type']}_agent.conf.epp", {
                      'server_host' => $params['server_host'],
                      'server_port' => $params['server_port'],
                      'hostname'    => $params['hostname'],
                      'net_group'   => $params['net_group'],
                      'eve_file'    => $params['eve_file'],
                      'waldo_file'  => $params['waldo_file'], })
                }
              }
      'sancp': {
                file { "/etc/${params['type']}_agent.conf":
                  owner   => $params['daemon_user'],
                  group   => '0',
                  mode    => '0640',
                  content => epp("sguil/${params['type']}_agent.conf.epp", {
                      'server_host' => $params['server_host'],
                      'server_port' => $params['server_port'],
                      'hostname'    => $params['hostname'],
                      'net_group'   => $params['net_group'],
                      'sancp_dir'   => $params['sancp_dir'], })
                }
              }
      default: { notice("sensor type ${params['type']} not supported")
                fail()
              }
    }
    # and take care of the service itself
    service { "${params['type']}_agent":
        ensure  => running,
        enable  => true,
        flags   => "-c /etc/${params['type']}_agent.conf",
        require => File["/etc/${params['type']}_agent.conf"],
    }
  }

}
