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
define kerberos::kdc::kpropd_acl::host
(
	$realm,
	$hostname = $title,

	$kpropd_acl,
	$kpropd_acl_host_prefix
)
{
	notify { "defined kerberos::kdc::kpropd_acl::host for $kpropd_acl_host_prefix/$hostname@$realm": }
	concat::fragment
	{ "$kpropd_acl.$realm.$hostname":
		target	=> $kpropd_acl,
		order	=> "01-$realm-$hostname",
		content	=> "$kpropd_acl_host_prefix/$hostname@$realm\n",
	}
}

class kerberos::kdc::kpropd_acl
(
	$realm			= $kerberos::params::realm,

	$kdc_packages		= $kerberos::params::kdc_packages,
	$kpropd_acl		= $kerberos::params::kpropd_acl,
	$kpropd_acl_owner	= $kerberos::params::kpropd_acl_owner,
	$kpropd_acl_group	= $kerberos::params::kpropd_acl_group,
	$kpropd_acl_mode	= $kerberos::params::kpropd_acl_mode,
	$kpropd_acl_host_prefix	= $kerberos::params::kpropd_acl_host_prefix
) inherits kerberos::params
{
	if (!defined(Class["kerberos::kdc"]))
	{
		fail("kerberos::kdc is not defined")
	}

	# Export this KDC's hostname. It will be used to build
	# kpropd.acl, which is the Kerberos cluster's access control list.
	@@kerberos::kdc::kpropd_acl::host
	{ $fqdn:
		realm			=> $realm,
		kpropd_acl		=> $kpropd_acl,
		kpropd_acl_host_prefix	=> $kpropd_acl_host_prefix,
	}

	# Collect all of the slave KDCs, and save a kpropd access control list.
	Kerberos::Kdc::Kpropd_acl::Host <<| |>>

	# Set up the concat resource for kpropd.acl.
	concat
	{ $kpropd_acl:
		owner	=> $kpropd_acl_owner,
		group	=> $kpropd_acl_group,
		mode	=> $kpropd_acl_mode,
		require	=> Package[$kdc_packages],
	}
}
