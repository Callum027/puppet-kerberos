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
define kerberos::client::appdefault
(
	$subsection,
	$tag 		= $title,

	$krb5_conf	= undef
)
{
	require kerberos::params

	# Fail if kerberos::client is not defined.
	if (!defined(Class["kerberos::client"]))
	{
		fail("kerberos::client is not defined")
	}

	# Set up the krb5.conf variable.
	if ($krb5_conf == undef)
	{
		$krb5_conf_real = $kerberos::params::krb5_conf
	}
	else
	{
		$krb5_conf_real = $krb5_conf
	}

	# Define the appdefaults section if it isn't already.
	if (!defined(Class["kerberos::client::appdefaults"]))
	{
		class
		{ "kerberos::client::appdefaults":
			krb5_conf	=> $krb5_conf_real,
		}
	}

	validate_hash($subsection)

	concat::fragment
	{ "$krb5_conf_real.appdefaults.$tag":
		target	=> $krb5_conf_real,
		order	=> "09-$tag",
		content	=> template("kerberos/krb5.conf.appdefault.erb"),
	}
}
