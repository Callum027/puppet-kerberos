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
class kerberos::configs::kdc_master
(
	$password		= undef,
	$realm			= $kerberos::params::realm,

	$krb5_keytab 		= $kerberos::params::krb5_keytab,

	$kdc_database_dir	= $kerberos::params::kdc_database_dir
	$kdc_database_name	= "$kdc_database_dir/principal"

	$kadm5_keytab		= $kerberos::params::kadm5_keytab,
	$kadm5_acl		= $kerberos::params::kadm5_acl,

	$kprop_dump		= $kerberos::params::kprop_dump,

	$kdb5_util		= $kerberos::params::kdb5_util,
	$kprop			= $kerberos::params::kprop
) inherits kerberos::params
{
	include kerberos::client
	include kerberos::kdc
	include kerberos::kadmin_server

	# Configure the Kerberos client, to connect with the local database.
	class
	{ 'kerberos::client::libdefaults':
		default_realm	=> $realm,
		kdc_timesync	=> 1,
		ccache_type	=> 4,
		forwardable	=> true,
		proxiable	=> true,
	}

	kerberos::client::realm
	{ $realm:
		kdc		=> $fqdn,
		admin_server	=> $fqdn,
	}

	class
	{ 'kerberos::client::domain_realm':
		realm	=> $realm,
	}

	class
	{ 'kerberos::client::logging':
		kdc		=> "FILE:/var/log/krb5-kdc.log",
		admin_server	=> "FILE:/var/log/krb5-admin-server.log",
		default		=> "FILE:/var/log/krb5.log",
	}

	# Set up the KDC configuration.
	class
	{ 'kerberos::kdc::kdcdefaults':
		kdc_ports	=> [ 750, 88 ],
	}

	kerberos::kdc::realm
	{ $realm:
		password		=> $password,

		database_name		=> $kdc_database_name,
		admin_keytab		=> "FILE:$kadm5_keytab",
		acl_file		=> $kadm5_acl,
		kdc_ports		=> [ 750, 88 ],
		max_life		=> "10h 0m 0s",
		max_renewable_life	=> "7d 0h 0m 0s",
		master_key_type		=> "des3-hmac-sha1",
		default_principal_flags	=> "+preauth",
	}

	# Set up kadm5.acl, which stores the access control list
	# for the kadmin daemon.
	kerberos::kadmin_server::acl
	{ $kadm5_acl:
		realm	=> $realm,
	}

	# Install a host keytab for this machine. Needed for host authentication.
	kerberos::keytab
	{ $krb5_keytab:
		use_kadmin_local	=> true,
		principals		=> "host/$fqdn",
	}

	# Set up kpropd.acl, which stores the access control list
	# for replication to the slave KDCs.
	require kerberos::kdc::kpropd_acl

	# Get the list of hostnames from kpropd.acl.
	$hostnames = $kerberos::kdc::kpropd_acl::hostname

	# Set up cron jobs to update the slave KDCs.
	cron
	{ "kerberos::kdc::master::cron::kprop::${hostnames}":
		command	=> "$kdb5_util dump $kprop_dump && $kprop -r $realm -f $kprop_dump ${hostnames}",
		minute	=> "*/5",
		require	=> [ Service[$kdc_service], File[$kpropd_acl] ],
	}
}
