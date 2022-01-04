class mongo {
  exec { 'apt-update':
    path    => $::command_path,
    command => 'apt-get update'
  }
  Exec['apt-update'] -> Package <| |>

  file { '/home/ubuntu/install-mongo.sh':
    content => template('mongo/install-mongo.sh'),
    mode    => '0777',
    owner   => 'ubuntu',
    group   => 'ubuntu'
  }

  exec { 'install mongo':
    path    => $::command_path,
    command => 'sudo /home/ubuntu/install-mongo.sh -u mongo -p mongo -n 27017',
    cwd     => '/home/ubuntu/'
  }

  service { 'mongod':
    ensure    => running,
    enable    => true,
    hasstatus => true,
    path      => $::command_path,
    restart   => 'sudo systemctl restart mongod',
  }
}
