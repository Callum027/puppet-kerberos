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
define kerberos::kdc::realm
(
	$password,
	$tag				= $title,

	$acl_file			= $::osfamily ?
	{
		"Debian"	=> $kerberos::params::kadm5_acl,
		default		=> undef,
	},
	$admin_keytab			= $::osfamily ?
	{
		"Debian"	=> "FILE:$kerberos::params::kadm5_keytab",
		default		=> undef,
	},
	$database_module		= undef,
	$database_name			= $::osfamily ?
	{
		"Debian"	=> $kerberos::params::kdc_database_name,
		default		=> undef,
	},
	$default_principal_expiration	= undef,
	$default_principal_flags	= undef,
	$dict_file			= undef,
	$host_based_services		= undef,
	$iprop_enable			= undef,
	$iprop_master_ulogsize		= undef,
	$iprop_slave_poll		= undef,
	$iprop_port			= undef,
	$iprop_resync_timeout		= undef,
	$iprop_logfile			= undef,
	$kadmind_port			= undef,
	$key_stash_file			= $::osfamily ?
	{
		"Debian"	=> "$kdc_prefix/stash",
		default		=> undef,
	},
	$kdc_ports			= $::osfamily ?
	{
		"Debian"	=> [ 750, 88 ],
		default		=> undef,
	},
	$kdc_tcp_ports			= undef,
	$master_key_name		= undef,
	$master_key_type		= $::osfamily ?
	{
		"Debian"	=> "des3-hmac-sha1",
		default		=> undef,
	},
	$max_life			= $::osfamily ?
	{
		"Debian"	=> "10h 0m 0s",
		default		=> undef,
	},
	$max_renewable_life		= $::osfamily ?
	{
		"Debian"	=> "7d 0h 0m 0s",
		default		=> undef,
	},
	$no_host_referral		= undef,
	$des_crc_session_supported	= undef,
	$reject_bad_transit		= undef,
	$restrict_anonymous_to_tft	= undef,
	$supported_enctypes		= $::osfamily ?
	{
		"Debian"	=> [ "aes256-cts:normal", "arcfour-hmac:normal", "des3-hmac-sha1:normal", "des-cbc-crc:normal",  "des:normal",  "des:v4", "des:norealm", "des:onlyrealm", "des:afs3" ],
		default		=> undef,
	}
)
{
	require kerberos::params
	require kerberos::kdc::realms

	concat::fragment
	{ "$kerberos::params::kdc_conf.realms.$tag":
		target	=> $kerberos::params::kdc_conf,
		order	=> 03,
		content	=> template("kerberos/kdc.conf.realm.erb"),
	}

	# Actually create the database for the realm.
	exec
	{ "kerberos::kdc::realm::kdb5_util::create::$tag": 
		command		=> "$kerberos::params::kdb5_util -r $tag -P $password create -s":
		creates		=> $database_name,
		require		=> File[$kerberos::params::kdc_conf],
		subscribe	=> Service[$kerberos::params::kdc_service],
	}

	# Create the stash file for the master key.
	exec
	{ "kerberos::kdc::realm::kdb5_util::stash::$tag": 
		command		=> "$kerberos::params::kdb5_util stash":
		creates		=> $database_name,
		require		=> File[$kerberos::params::kdc_conf],
		subscribe	=> Service[$kerberos::params::kdc_service],
	}
}

class kerberos::kdc::realms
{
	concat::fragment
	{ "$kerberos::params::kdc_conf.realms":
		target	=> $kerberos::params::kdc_conf,
		order	=> 02,
		content	=> "\n[realms]\n",
	}
}
