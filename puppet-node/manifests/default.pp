$command_path = ['/usr/bin/', '/usr/sbin/', '/bin']
$document_root = '/var/www'
$database_port = 3366
$database_address = '127.0.0.1'
$database_user = 'wordpress'
$database_name = 'wordpress'
$mysql_password = 's3cr3tP4ssw0rd'
$ip_domain = '127.0.0.1'
$email = 'anselm82@gmail.com'
$username = 'admin'
$password = 's3cr3tP4ssw0rd'

include nginx
include nodejs

notify { 'Showing machine Facts':
  message => "Please check access to http://${::ip_domain}",
}
