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
class kerberos::kdc
(
	# Parameters retrieved from kerberos::params.
	$kdc_packages		= $kerberos::params::kdc_packages,
	$kdc_conf		= $kerberos::params::kdc_conf,
	$kdc_conf_owner		= $kerberos::params::kdc_conf_owner,
	$kdc_conf_group		= $kerberos::params::kdc_conf_group,
	$kdc_conf_mode		= $kerberos::params::kdc_conf_mode,
)
{
	require kerberos::params

	# Install the Kerberos KDC packages.
	package
	{ $kdc_packages:
		ensure	=> installed,
	}

	# Install kdc.conf. This file is assembled from multiple
	# concat fragments.
	concat
	{ $kdc_conf:
		owner	=> $krb5_conf_owner,
		group	=> $krb5_conf_group,
		mode	=> $krb5_conf_mode,
	}

	service
	{ $kdc_service:
		ensure	=> running,
		enabled	=> true,
		require	=> File[$kdc_conf],
	}
}
