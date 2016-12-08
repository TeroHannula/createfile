class secure-webserver {


# laita php toimimaan oikeasti
# laita httpd.conf jos tarvitsee
# lataa ruleset
# jaa erillisiin moduuleihin, joista kukin tekee yhden tehtävän, ainakin php5.5-säätö


	include apt

	apt::ppa { 'ppa:ondrej/php': }		# Repo for PHP5.5

	Package { allowcdrom => 'true', }

	package { "apache2":
		ensure => 'latest',        # V2.4 is preferred for mod_security
	}

	package {'libapache2-mod-php5.5':
		require	=> Package['apache2'],
		ensure	=> installed,
	}

	package { 'php5.5':
		ensure => 'installed',
	}
    
	service { "apache2":
		require => Package['libapache2-mod-php5.5'],
		enable => 'true',
		ensure => 'true',
	}


	package { 'libapache2-mod-security2':
		require => Package['apache2'],
		ensure => 'latest',        # >= V2.8 needed for OWASP CRS ruleset
	}

	exec { 'load-modsecurity':
		command => "/usr/sbin/a2enmod mod-security2",
		unless => "/bin/readlink -e /etc/apache2/mods-enabled/libapache2-modsecurity.load",
		notify => Service['apache2'],
	}


#-------------- Install DVWA --------------


	exec { 'install-dvwa':
		require => Package['libapache2-mod-security2'],
		command => 'unzip files/v1.9.zip -d /var/www/html/',
		cwd	=> '/etc/puppet/modules/secure-webserver',
		path	=> '/usr/bin/',
		creates => '/var/www/html/DVWA-1.9',
	}

	exec { 'rename-dvwa':
		require	=> Exec['install-dvwa'],
		creates => '/var/www/html/dvwa/',
		path	=> '/bin/',
		command	=> 'mv /var/www/html/DVWA-1.9/ /var/www/html/dvwa/',
	}

}
