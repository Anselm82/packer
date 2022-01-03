class filebeat {

  exec { 'download filebeat':
    path    => $::command_path,
    command => 'sudo wget https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-6.8.22-amd64.deb'
  }

  exec { 'install filebeat':
    path    => $::command_path,
    command => 'sudo dpkg -i filebeat-6.8.22-amd64.deb'
  }
}
