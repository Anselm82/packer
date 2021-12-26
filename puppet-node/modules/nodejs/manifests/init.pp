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

  file { "${::npm_document_root}/nodejs":
    ensure => 'directory',
    owner  => 'vagrant',
    group  => 'vagrant'
  }

  file { '/etc/systemd/system/hello-devops.service':
    content => template('nodejs/hello-devops.service'),
    mode    => '0755',
    owner   => 'root',
    group   => 'root'
  }

  file { "${::npm_document_root}/nodejs/hello-devops.js":
    content => template('nodejs/hello-devops.js'),
    mode    => '0755',
    owner   => 'vagrant',
    group   => 'vagrant',
    require => File['/etc/nginx/sites-enabled/proxy.conf'],
  }

  exec { 'init app':
    path    => $::command_path,
    command => 'systemctl start hello-devops',
    cwd     => "${::npm_document_root}/nodejs/",
    notify  => Service['nginx']
  }
}
