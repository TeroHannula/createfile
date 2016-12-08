class createfile {
	file { "/tmp/hello.txt":
		content => "Toimii",
	}
}

