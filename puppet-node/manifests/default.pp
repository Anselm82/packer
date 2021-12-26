$command_path = ['/usr/bin/', '/usr/sbin/', '/bin']
$npm_document_root = '/var/www'
$vagrant_dir = '/vagrant'
$mysql_port = 3366
$mysql_address = '127.0.0.1'
$mysql_user = 'wordpress'
$mysql_database = 'wordpress'
$mysql_password = 's3cr3tP4ssw0rd'
$wp_title = 'Wordpress by Juan José Hernández Alonso'
$wp_domain = $::ipaddress_enp0s8
$wp_email = 'anselm82@gmail.com'
$wp_username = 'admin'
$wp_password = 's3cr3tP4ssw0rd'

include nginx
include nodejs

notify { 'Showing machine Facts':
  message => "Machine with ${::memory['system']['total']} of memory and ${::processorcount} processor/s.
              Please check access to http://${::ipaddress_enp0s8}",
}
