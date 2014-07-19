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
class kerberos::params
{
	case $::osfamily
	{
		'Debian':
		{
			# General configuration.
			$prefix					= "/etc"
			$tmpdir					= "/tmp"
			$realm					= upcase($domain)

			# Executable locations.
			$cat					= "/bin/cat"
			$grep					= "/bin/grep"
			$kadmin					= "/usr/bin/kadmin"
			$kadmin_local				= "/usr/sbin/kadmin.local"
			$kdb5_util				= "/usr/sbin/kdb5_util"
			$klist					= "/usr/bin/klist"
			$kprop					= "/usr/sbin/kprop"
			$kpropd					= "/usr/sbin/kpropd"
			$rm					= "/bin/rm"

			# Client configuration options.
			$client_packages			= [ "krb5-user" ]

			# Kerberos KDC configuration options.
			$kdc_prefix				= "$prefix/krb5kdc"
			$kdc_database_dir			= "/var/lib/krb5kdc"

			$kdc_packages				= [ "krb5-kdc" ]
			$kdc_service				= "krb5-kdc"

			# Kerberos administration server configuration options.
			$kadmin_server_packages			= [ "krb5-admin-server" ]
			$kadmin_server_service			= "krb5-admin-server"

			# Default keytab location, permissions.
			$keytab					= "$prefix/krb5.keytab"
			$keytab_owner				= "root"
			$keytab_group				= "root"
			$keytab_mode				= "400"

			# krb5.conf location, permissions.
			$krb5_conf				= "$prefix/krb5.conf"
			$krb5_conf_owner			= "root"
			$krb5_conf_group			= "root"
			$krb5_conf_mode				= "444"

			# kdc.conf location, permissions.
			$kdc_conf				= "$kdc_prefix/kdc.conf"
			$kdc_conf_owner				= "root"
			$kdc_conf_group				= "root"
			$kdc_conf_mode				= "444"

			# kadmin.keytab location, permissions.
			$kadmin_keytab				= "$kdc_prefix/kadmin.keytab"
			$kadmin_keytab_owner			= "root"
			$kadmin_keytab_group			= "root"
			$kadmin_keytab_mode			= "400"

			# kadm5.acl location, permissions.
			$kadm5_acl				= "$kdc_prefix/kadm5.acl"
			$kadm5_acl_owner			= "root"
			$kadm5_acl_group			= "root"
			$kadm5_acl_mode				= "400"

			# KDC principal database location, kprop dump file location.
			$kdc_database_name			= "$kdc_database_dir/principal"
			$kprop_dump				= "$kdc_database_dir/dump"

			# kpropd.acl location, permissions, settings.
			$kpropd_acl				= "$kdc_prefix/kpropd.acl"
			$kpropd_acl_owner			= "root"
			$kpropd_acl_group			= "root"
			$kpropd_acl_mode			= "400"
			$kpropd_acl_host_prefix			= "host"

			# KDC master key stash location, permissions.
			$kdc_stash				= "$kdc_prefix/stash"
			$kdc_stash_owner			= "root"
			$kdc_stash_group			= "root"
			$kdc_stash_mode				= "400"
		}

		default:
		{
			fail("Sorry, but kerberos does not support the $::osfamily OS family at this time")
		}
	}

}
