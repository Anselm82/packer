$command_path = ['/usr/bin/', '/usr/sbin/', '/bin']
$document_root = '/var/www'
$database_port = 3366
$database_address = '127.0.0.1'
$database_user = 'mongo'
$database_name = 'mongo'
$database_password = 's3cr3tP4ssw0rd'

include mongo

notify { 'Showing machine Facts':
  message => "Please check access to http://${::database_address}",
}
