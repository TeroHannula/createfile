class createfile {
	file { "/tmp/hello.txt":
		content => "This Puppet module seems to work!\n",
	}
}
