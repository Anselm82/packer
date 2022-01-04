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

  exec { 'install express':
    path    => $::command_path,
    command => 'npm install express --save',
    cwd     => "${::document_root}/nodejs"
  }

  file { '/etc/systemd/system/hellodevops.service':
    content => template('nodejs/hellodevops.service'),
    mode    => '0755',
    owner   => 'root',
    group   => 'root'
  }

  file { "${::document_root}/nodejs/hellodevops.js":
    content => template('nodejs/hellodevops.js'),
    mode    => '0755',
    owner   => 'www-data',
    group   => 'www-data',
    require => File['/etc/nginx/sites-enabled/proxy.conf'],
  }

  exec { 'reload daemons':
    path    => $::command_path,
    command => 'sudo systemctl daemon-reload'
  }

  service { 'hellodevops':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    path      => $::command_path,
    restart   => 'sudo systemctl start hellodevops',
  }
}
