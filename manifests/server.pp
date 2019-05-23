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
class sguil::server(
  String $package_name,
  String $service_name,
  String $service_ensure,
  String $service_flags,
  String $confdir,
  String $user,
  String $group,
  String $sguild_lib_path,
  Integer $serverport,
  Integer $sensorport,
  String $rulesdir,
  String $tmpdatadir,
  String $dbname,
  String $dbuser,
  String $dbpass,
  String $dbhost,
  Integer $dbport,
  String $local_log_dir,
  String $tmp_load_dir,
  String $tcpflow,
  Integer $p0f,
  String $p0f_path,
) {

  package { $package_name:
    ensure => installed,
  }

  file { $confdir:
    ensure  => directory,
    require => Package[$package_name],
  }

  file { "${confdir}/sguild.conf":
    ensure  => file,
    owner   => 'root',
    group   => $group,
    mode    => '0640',
    content => epp('sguil/sguild.conf.epp'),
    require => File[$confdir],
  }

  file { '/var/log/sguild':
    ensure => 'directory',
    owner  => $user,
    group  => '0',
    mode   => '0755',
  }

  file { "${confdir}/certs":
    ensure  => 'directory',
    owner   => $user,
    group   => '0',
    mode    => '0755',
    require => File[$confdir],
  }

  file { dirname($local_log_dir):
    ensure  => 'directory',
    owner   => $user,
    group   => '0',
    mode    => '0755',
    require => File[$confdir],
  }  
  file { "${local_log_dir}":
    ensure  => 'directory',
    owner   => $user,
    group   => '0',
    mode    => '0755',
    require => File[$confdir],
  }
  file { "${tmp_load_dir}":
    ensure  => 'directory',
    owner   => $user,
    group   => '0',
    mode    => '0755',
    require => File[$confdir],
  }


  service { $service_name:
    ensure  => $service_ensure,
    flags   => $service_flags,
    require => [ File["${confdir}/sguild.conf"],
    		File["${confdir}/certs"],
    		File['/var/log/sguild'],
    		File[$tmp_load_dir],
    		File[$local_log_dir],
		],
  }

}
