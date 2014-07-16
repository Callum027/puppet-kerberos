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
define kerberos::kdc::acl
(
	$file			= $title,
	$owner			= undef,
	$group			= undef,
	$mode			= undef,

	$realm			= undef,
	$acl			=
	[
		{
			principal	=> "*/admin@$realm",
			permissions	=> "*",
		},
	],

	# Parameters retrieved from kerberos::params.
	$kadmin_server_service	= $kerberos::params::kadmin_server_service
)
{
	require kerberos::params
	require kerberos::kdc
	require kerberos::kadmin_server

	if ($owner == undef)
	{
		$owner_real = $kerberos::params::kadm5_acl_owner
	}
	else
	{
		$owner_real = $owner
	}

	if ($group == undef)
	{
		$group_real = $kerberos::params::kadm5_acl_group
	}
	else
	{
		$group_real = $group
	}

	if ($mode == undef)
	{
		$mode_real = $kerberos::params::kadm5_acl_mode
	}
	else
	{
		$mode_real = $mode
	}

	if ($realm == undef)
	{
		$realm_real = $kerberos::params::realm
	}
	else
	{
		$realm_real = $realm
	}

	if ($kadmin_server_service == undef)
	{
		$kadmin_server_service_real = $kerberos::params::kadmin_server_service
	}
	else
	{
		$kadmin_server_service_real = $kadmin_server_service
	}

	# Install the ACL to its given location.
	file
	{ $file:
		owner		=> $owner_real,
		group		=> $group_real,
		mode		=> $mode_real,
		content		=> template("kerberos/kadm5.acl.erb"),
		subscribe	=> Service[$kadmin_server_service_real],
	}
}
