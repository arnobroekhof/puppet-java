# java module
# NOTE only 64 bit, linux and bin file are supported for the momment

class java ( $jdk_version, $jdk_package_location) {

  # create the OS java dir
  file { "/usr/java":
	ensure => 'directory',
  }

  # determine the jdk bin package 
  case $hardwareisa {
    'x86_64': {
	$jdk_package="jdk-${jdk_version}-linux-x64.bin"
	$jdk_target_version= regsubst($jdk_version, '6u', '')
	$jdk_target_dir="/usr/java/jdk1.6.0_${jdk_target_version}"
        # copy the package to /usr/java

	file { "/usr/java/$jdk_package":
	  ensure => 'present',
	  mode => 755,
	  owner => 'root',
	  group => 'root',
	  source => "puppet:///files/java/jdk/${jdk_package}",
	  require => File['/usr/java'],
	}
	exec { "yes | /usr/java/${jdk_package} >/dev/null 2>&1":
		cwd => '/usr/java',
		alias => 'unpackjava',
		path => ["/usr/bin", "/usr/sbin","/bin"],
		creates => "$jdk_target_dir",
		require => File["/usr/java/$jdk_package"],
	}
	exec { "/bin/ln -s ${jdk_target_dir} default":
		cwd => '/usr/java',
		alias => 'symlinkjavadir',
		path => ["/usr/bin", "/usr/sbin","/bin"],
		creates => "/usr/java/default",
		require => Exec['unpackjava'],
	}
	exec { "update-alternatives --install '/usr/bin/java' 'java' '/usr/java/default/bin/java' 1":
		alias => 'updatealternative',
		path => ["/usr/bin", "/usr/sbin","/bin"],
		creates => "/usr/bin/java",
		require => Exec['symlinkjavadir'],
	}	
	# set java home in profile
	exec { 'echo "JAVA_HOME=/usr/java/default" >> /etc/profile':
		alias => 'setjavahome',
		path => ["/usr/bin", "/usr/sbin","/bin"],
		unless => "/bin/grep JAVA_HOME /etc/profile",
		require => Exec['updatealternative'],
	 }
     }  
  }
}
