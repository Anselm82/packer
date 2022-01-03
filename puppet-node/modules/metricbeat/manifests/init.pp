class metricbeat {

  exec { 'download metricbeat':
    path    => $::command_path,
    command => 'sudo wget https://artifacts.elastic.co/downloads/beats/metricbeat/metricbeat-7.16.2-amd64.deb'
  }

  exec { 'install metricbeat':
    path    => $::command_path,
    command => 'sudo dpkg -i metricbeat-7.16.2-amd64.deb'
  }
}
