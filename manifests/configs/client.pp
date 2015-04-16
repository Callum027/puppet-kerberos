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
class kerberos::configs::client
(
	$realm			= $kerberos::params::realm,
	$master_kdc		= undef,
	$admin_server		= undef,
	$kpasswd_server		= undef
) inherits kerberos::params
{
	include kerberos::client

	if ($kdc == undef)
	{
		$kdc = getparam(Kerberos::Configs::Kdc_master_advertise <| |>, "master_kdc")
	}

	if ($admin_server == undef)
	{
		$admin_server = $kdc
	}

	if ($kpasswd_server == undef)
	{
$		$kpasswd_server = $kdc
	}

	class
	{ 'kerberos::client::libdefaults':
		kdc_timesync	=> 1,
		ccache_type	=> 4,
		forwardable	=> true,
		proxiable	=> true,
	}

	kerberos::client::realm
	{ $realm:
		kdc		=> $kdc,
		admin_server	=> $admin_server,
		kpasswd_server	=> $kpasswd_server,
	}

	include kerberos::client::domain_realm
}
