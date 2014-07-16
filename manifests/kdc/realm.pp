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
	$password			= undef,
	$tag				= $title,

	$acl_file			= undef,
	$admin_keytab			= undef,
	$database_module		= undef,
	$database_name			= undef,
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
	$key_stash_file			= undef,
	$kdc_ports			= undef,
	$kdc_tcp_ports			= undef,
	$master_key_name		= undef,
	$master_key_type		= undef,
	$max_life			= undef,
	$max_renewable_life		= undef,
	$no_host_referral		= undef,
	$des_crc_session_supported	= undef,
	$reject_bad_transit		= undef,
	$restrict_anonymous_to_tft	= undef,
	$supported_enctypes		= undef,

	$kdc_conf			= undef,
	$kdc_service			= undef,

	$kdb5_util			= undef
)
{
	require kerberos::params
	require kerberos::kdc::realms

	if ($kdc_conf == undef)
	{
		$kdc_conf_real = $kerberos::params::kdc_conf
	}
	else
	{
		$kdc_conf_real = $kdc_conf
	}

	if ($kdc_service == undef)
	{
		$kdc_service_real = $kerberos::params::kdc_service
	}
	else
	{
		$kdc_service_real = $kdc_service
	}

	if ($kdb5_util == undef)
	{
		$kdb5_util_real = $kerberos::params::kdb5_util
	}
	else
	{
		$kdb5_util_real = $kdb5_util
	}

	concat::fragment
	{ "$kdc_conf_real.realms.$tag":
		target	=> $kdc_conf_real,
		order	=> 03,
		content	=> template("kerberos/kdc.conf.realm.erb"),
	}

	# Actually create the database for the realm.
	if ($database_name != undef) and ($password != undef)
	{
		exec
		{ "kerberos::kdc::realm::kdb5_util::create::$tag": 
			command		=> "$kdb5_util_real -r $tag -P $password create -s":
			creates		=> $database_name,
			require		=> File[$kdc_conf_real],
			subscribe	=> Service[$kdc_service_real],
		}
	}

	# Create the stash file for the master key.
	if ($key_stash_file != undef)
	{
		exec
		{ "kerberos::kdc::realm::kdb5_util::stash::$tag": 
			command		=> "$kdb5_util_real stash":
			creates		=> $database_name,
			require		=> File[$kdc_conf_real],
			subscribe	=> Service[$kdc_service_real],
		}
	}
}

