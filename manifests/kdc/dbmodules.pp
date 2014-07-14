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
define kerberos::kdc::dbmodule
(
	$tag				= $title,

	$database_name			= undef,
	$db_library			= undef,
	$disable_last_success		= undef,
	$disable_lockout		= undef,
	$ldap_conns_per_server		= undef,
	$ldap_kadmind_dn		= undef,
	$ldap_kdc_dn			= undef,
	$ldap_kerberos_container_dn	= undef,
	$ldap_servers			= undef,
	$ldap_service_password_file	= undef,
	$db_module_dir			= undef
)
{
	require kerberos::params
	require kerberos::kdc::dbmodules

	concat::fragment
	{ "$kerberos::params::kdc_conf.dbmodules.$tag":
		target	=> $kerberos::params::kdc_conf,
		order	=> 06,
		content	=> template("kerberos/kdc.conf.dbmodule.erb"),
	}
}

class kerberos::kdc::dbmodules
{
	concat::fragment
	{ "$kerberos::params::kdc_conf.dbmodules":
		target	=> $kerberos::params::kdc_conf,
		order	=> 05,
		content	=> "\n[dbmodules]\n",
	}
}
