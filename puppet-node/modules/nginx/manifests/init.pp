class nginx {

  package { 'nginx':
    ensure => installed,
  }

  file { '/etc/nginx/sites-enabled/default':
    ensure  => absent,
    require => Package['nginx'],
  }

  file { '/etc/nginx/sites-available/proxy.conf':
    content => template('nginx/proxy.conf.erb'),
    require => File['/etc/nginx/sites-enabled/default'],
  }

  file { '/etc/nginx/sites-enabled/proxy.conf':
    ensure  => link,
    target  => '/etc/nginx/sites-available/proxy.conf',
    require => File['/etc/nginx/sites-available/proxy.conf'],
    notify  => Service['nginx'],
  }

  service { 'nginx':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    path      => $::command_path,
    restart   => 'service nginx reload',
  }
}
