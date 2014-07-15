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
class kerberos::client::domain_realm
(
	$realm		= $kerberos::params::realm,
	$domain_realms	= $::osfamily ?
	{
		'Debian'	=>
		{
			join([ ".", lowcase($realm) ], "")	=> $realm,
			lowcase($realm)				=> $realm,
		},
	},

	$krb5_conf			= $kerberos::params::krb5_conf
)
{
	require kerberos::params

	validate_hash($domain_realms)

	concat::fragment
	{ "$krb5_conf.domain_realm":
		target	=> $krb5_conf,
		order	=> 04,
		content	=> template("kerberos/krb5.conf.domain_realm.erb"),
	}
}
