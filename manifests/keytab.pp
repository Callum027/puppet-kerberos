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
	$realm			= $kerberos::params::realm,

	$owner			= $kerberos::params::keytab_owner,
	$group			= $kerberos::params::keytab_group,
	$mode			= $kerberos::params::keytab_mode,

	$use_kadmin_local	= false,
	$password		= $use_kadmin_local ?
	{
		true	=> undef,
	}

	$kdc_prefix		= $kerberos::params::kdc_prefix,
	$tmpfile		= "$kdc_prefix/.kerberos::keytab::$keytab.tmp",

	$kdc_service		= $kerberos::params::kdc_service,
	$kadmin_server_service	= $kerberos::params::kadmin_server_service,

	$cat			= $kerberos::params::cat,
	$grep			= $kerberos::params::grep,
	$kadmin			= $kerberos::params::kadmin,
	$kadmin_local		= $kerberos::params::kadmin_local,
	$klist			= $kerberos::params::klist,
	$rm			= $kerberos::params::rm
)
{
	# Determine which kadmin command to use.
	# If remote kadmin is used, the given password is put into a locked down
	# temporary file, in (hopefully) a locked down folder. This is then passed
	# to kadmin via standard input, in the hopes that no unprivileged users will
	# be able to find out the password.
	case ($use_kadmin_local)
	{
		true:
		{
			$kadmin_command = $kadmin_local
		}
		false:
		{
			# Add the temporary file to disk.
			file
			{ $tmpfile:
				owner		=> "root",
				group		=> "root",
				mode		=> 400,
				content		=> $password,
				subscribe	=> [ Exec["kerberos::keytab::kadmin_addprinc::${principals}"], Exec["kerberos::keytab::kadmin_ktadd::${principals}"] ],
			}

			# Delete the file as soon as we're done with it.
			exec
			{ "$rm -f \"$tmpfile\"":
				require	=> [ File[$tmpfile], File[$keytab] ]
			}

			# Set the kadmin command to pass the password to kadmin via stdin.
			$kadmin_command = join([ "$cat \"$tmpfile\" |" , $kadmin ], " ")
		}
	}

	# Add the given principals to the Kerberos realm.
	exec
	{ "kerberos::keytab::kadmin_addprinc::${principals}":
		command	=> "$kadmin_command -r $realm -q \"addprinc -randkey ${principals}\"",
		unless	=> "$kadmin_command -r $realm -q \"listprincs ${principals}\" | $grep \"${principals}\"",
		require => [ Service[$kdc_service] , Service[$kadmin_server_service] ],
	}

	# Save the given principals to the keytab file.
	exec
	{ "kerberos::keytab::kadmin_ktadd::${principals}":
		command		=> "$kadmin_command -r $realm -q \"ktadd -k $keytab ${principals}\"",
		unless		=> "$klist -k $keytab | $grep \"${principals}\"",
		require		=> Exec["kerberos::keytab::kadmin_addprinc::${principals}"],
		subscribe	=> File[$keytab],
	}

	# Make sure that the keytab is there, set the permissions on it,
	# and provide a resource hook for Puppet.
	file
	{ $keytab:
		ensure	=> present,
		owner	=> $owner,
		group	=> $group,
		mode	=> $mode,
	}
}
