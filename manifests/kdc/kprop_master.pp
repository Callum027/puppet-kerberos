# == Class: kerberos
#
# Full description of class kerberos here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { kerberos:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class kerberos::kdc::kprop_master
(
	$hostname	= $fqdn,
	$realm		= $kerberos::params::realm,

	$kpropd_acl	= $kerberos::params::kpropd_acl,
	$kprop_dump	= $kerberos::params::kprop_dump,

	$kdb5_util	= $kerberos::params::kdb5_util,
	$kprop		= $kerberos::params::kprop
) inherits kerberos::params
{
	# Create kpropd.acl.
	class
	{ 'kerberos::kdc::kpropd_acl':
		hostname	=> $hostname,
		realm		=> $realm,
		kpropd_acl	=> $kpropd_acl,
	}

	# Collect the KDC slave hosts, and configure their cron jobs.
	Kerberos::Kdc::Kpropd_slave <<| kpropd_acl == $kpropd_acl |>>
}
