class nodejs {
  exec { 'apt-update':
    path    => $::command_path,
    command => 'apt-get update'
  }
  Exec['apt-update'] -> Package <| |>

  $node_packages = ['nodejs', 'npm', 'build-essential']

  package { $node_packages :
    ensure => installed,
    notify => Service['nginx'],
  }

  file { "${::document_root}/nodejs":
    ensure => 'directory',
    owner  => 'www-data',
    group  => 'www-data'
  }

  file { '/etc/systemd/system/hello-devops.service':
    content => template('nodejs/hello-devops.service'),
    mode    => '0755',
    owner   => 'root',
    group   => 'root'
  }

  file { "${::document_root}/nodejs/hello-devops.js":
    content => template('nodejs/hello-devops.js'),
    mode    => '0755',
    owner   => 'www-data',
    group   => 'www-data',
    require => File['/etc/nginx/sites-enabled/proxy.conf'],
  }

  exec { 'init app':
    path    => $::command_path,
    command => 'systemctl start hello-devops',
    cwd     => "${::document_root}/nodejs/",
    notify  => Service['nginx']
  }
}
