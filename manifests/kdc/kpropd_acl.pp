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
define kerberos::kdc::hostname($hostname = $title, $realm) {}

class kerberos::kdc::kpropd_acl
(
	$realm			= $kerberos::params::realm,

	$kpropd_acl		= $kerberos::params::kpropd_acl,
	$kpropd_acl_owner	= $kerberos::params::kpropd_acl_owner,
	$kpropd_acl_group	= $kerberos::params::kpropd_acl_group,
	$kpropd_acl_mode	= $kerberos::params::kpropd_acl_mode
) inherits kerberos::params
{
	require kerberos::kdc

	# Export this KDC's hostname. It will be used to build
	# kpropd.acl, which is the Kerberos cluster's access control list.
	@@kerberos::kdc::hostname
	{ $fqdn:
		realm	=> $realm,
	}

	# Collect all of the slave KDCs, and save a kpropd access control list.
	Kerberos::Kdc::Hostname <<| realm == $realm |>>

	file
	{ $kpropd_acl:
		owner	=> $kpropd_acl_owner,
		group	=> $kpropd_acl_group,
		mode	=> $kpropd_acl_mode,
		content	=> template("kerberos/kpropd.acl.erb"),
	}
}
