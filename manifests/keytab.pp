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
define kerberos::keytab
(
	$principals,
	$keytab			= $title,
	$use_kadmin_local	= false,
	$password		= $use_kadmin_local ?
	{
		true	=> undef,
	},

	$realm			= undef,

	$owner			= undef,
	$group			= undef,
	$mode			= undef,

	$kdc_prefix		= undef,
	$tmpfile		= undef,

	$kdc_service		= undef,
	$kadmin_server_service	= undef,

	$cat			= undef,
	$grep			= undef,
	$kadmin			= undef,
	$kadmin_local		= undef,
	$klist			= undef,
	$rm			= undef
)
{
	require kerberos::params

	if ($realm == undef)
	{
		$realm_real = $kerberos::params::realm
	}
	else
	{
		$realm_real = $realm
	}

	if ($owner == undef)
	{
		$owner_real = $kerberos::params::keytab_owner
	}
	else
	{
		$owner_real = $owner
	}

	if ($group == undef)
	{
		$group_real = $kerberos::params::keytab_group
	}
	else
	{
		$group_real = $group
	}

	if ($mode == undef)
	{
		$mode_real = $kerberos::params::keytab_mode
	}
	else
	{
		$mode_real = $mode
	}

	if ($grep == undef)
	{
		$grep_real = $kerberos::params::grep
	}
	else
	{
		$grep_real = $grep
	}

	if ($tmpfile == undef)
	{
		$tmpfile_real = "$kdc_prefix/.kerberos::keytab::$keytab.tmp"
	}
	else
	{
		$tmpfile_real = $tmpfile
	}

	if ($kdc_service == undef)
	{
		$kdc_service_real = $kerberos::params::kdc_service
	}
	else
	{
		$kdc_service_real = $kdc_service
	}

	if ($kadmin_server_service == undef)
	{
		$kadmin_server_service_real = $kerberos::params::kadmin_server_service
	}
	else
	{
		$kadmin_server_service_real = $kadmin_server_service
	}

	if ($kdc_prefix == undef)
	{
		$kdc_prefix_real = $kerberos::params::kdc_prefix
	}
	else
	{
		$kdc_prefix_real = $kdc_prefix
	}

	if ($cat == undef)
	{
		$cat_real = $kerberos::params::cat
	}
	else
	{
		$cat_real = $cat
	}

	if ($kadmin == undef)
	{
		$kadmin_real = $kerberos::params::kadmin
	}
	else
	{
		$kadmin_real = $kadmin
	}

	if ($kadmin_local == undef)
	{
		$kadmin_local_real = $kerberos::params::kadmin_local
	}
	else
	{
		$kadmin_local_real = $kadmin_local
	}

	if ($klist == undef)
	{
		$klist_real = $kerberos::params::klist
	}
	else
	{
		$klist_real = $klist
	}

	if ($rm == undef)
	{
		$rm_real = $kerberos::params::rm
	}
	else
	{
		$rm_real = $rm
	}

	# Determine which kadmin command to use.
	# If remote kadmin is used, the given password is put into a locked down
	# temporary file, in (hopefully) a locked down folder. This is then passed
	# to kadmin via standard input, in the hopes that no unprivileged users will
	# be able to find out the password.
	case ($use_kadmin_local)
	{
		true:
		{
			$kadmin_command = $kadmin_local_real
		}
		false:
		{
			# Add the temporary file to disk.
			file
			{ $tmpfile_real:
				owner		=> "root",
				group		=> "root",
				mode		=> 400,
				content		=> $password,
				subscribe	=> [ Exec["kerberos::keytab::kadmin_addprinc::${principals}"], Exec["kerberos::keytab::kadmin_ktadd::${principals}"] ],
			}

			# Delete the file as soon as we're done with it.
			exec
			{ "$rm_real -f \"$tmpfile\"":
				require	=> [ File[$tmpfile_real], File[$keytab] ]
			}

			# Set the kadmin command to pass the password to kadmin via stdin.
			$kadmin_command = "$cat_real \"$tmpfile_real\" | $kadmin_real"
		}
	}

	# Add the given principals to the Kerberos realm.
	exec
	{ "kerberos::keytab::kadmin_addprinc::${principals}":
		command	=> "$kadmin_command -r $realm -q \"addprinc -randkey ${principals}\"",
		unless	=> "$kadmin_command -r $realm -q \"listprincs ${principals}\" | $grep_real \"${principals}\"",
		require => [ Service[$kdc_service_real] , Service[$kadmin_server_service_real] ],
	}

	# Save the given principals to the keytab file.
	exec
	{ "kerberos::keytab::kadmin_ktadd::${principals}":
		command		=> "$kadmin_command -r $realm -q \"ktadd -k $keytab ${principals}\"",
		unless		=> "$klist_real -k $keytab | $grep_real \"${principals}\"",
		require		=> Exec["kerberos::keytab::kadmin_addprinc::${principals}"],
		subscribe	=> File[$keytab],
	}

	# Make sure that the keytab is there, set the permissions on it,
	# and provide a resource hook for Puppet.
	file
	{ $keytab:
		ensure	=> present,
		owner	=> $owner_real,
		group	=> $group_real,
		mode	=> $mode_real,
	}
}
