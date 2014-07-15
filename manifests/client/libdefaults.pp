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
class kerberos::client::libdefaults
(
	$allow_weak_crypto		= undef,
	$ap_req_checksum_type		= undef,
	$canonicalize			= undef,
	$ccache_type			= undef,
	$clockskew			= undef,
	$default_ccache_name		= undef,
	$default_client_keytab_name	= undef,
	$default_realm			= upcase($domain),
	$default_tgs_enctypes		= undef,
	$default_tkt_enctypes		= undef,
	$dns_canonicalize_hostname	= undef,
	$dns_lookup_dc			= undef,
	$extra_addresses		= undef,
	$forwardable			= undef,
	$ignore_acceptor_hostname	= undef,
	$k5login_authoritative		= undef,
	$k5login_directory		= undef,
	$kdc_default_options		= undef,
	$kdc_timesync			= undef,
	$kdc_req_checksum_type		= undef,
	$noaddresses			= undef,
	$permitted_enctypes		= undef,
	$plugin_base_dir		= undef,
	$preferred_preauth_type		= undef,
	$proxiable			= undef,
	$rdns				= undef,
	$realm_try_domains		= undef,
	$renew_lifetime			= undef,
	$safe_checksum_type		= undef,
	$ticket_lifetime		= undef,
	$udp_preference_limit		= undef,
	$verify_ap_req_nofail		= undef,

	$krb5_conf			= $kerberos::params::krb5_conf
)
{
	require kerberos::params

	concat::fragment
	{ "$krb5_conf.libdefaults":
		target	=> $krb5_conf,
		order	=> 01,
		content	=> template("kerberos/krb5.conf.libdefaults.erb"),
	}
}
