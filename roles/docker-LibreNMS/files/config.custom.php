$config['bad_if_regexp'][] = '/^docker[\w]+$/';
$config['bad_if_regexp'][] = '/^lxcbr[0-9]+$/';
$config['bad_if_regexp'][] = '/^veth.*$/';
$config['bad_if_regexp'][] = '/^virbr.*$/';
$config['bad_if_regexp'][] = '/^lo$/';
$config['bad_if_regexp'][] = '/^macvtap.*$/';
$config['bad_if_regexp'][] = '/gre.*$/';
$config['bad_if_regexp'][] = '/tun[0-9]+$/';

$config['snmp']['community'][] = "public";

// v3
// $config['snmp']['v3'][0]['authlevel'] = 'AuthPriv';
// $config['snmp']['v3'][0]['authname'] = 'my_username';
// $config['snmp']['v3'][0]['authpass'] = 'my_password';
// $config['snmp']['v3'][0]['authalgo'] = 'MD5';
// $config['snmp']['v3'][0]['cryptopass'] = 'my_crypto';
// $config['snmp']['v3'][0]['cryptoalgo'] = 'AES';

$config['nets'][] = '192.168.0.0/16';
$config['nets'][] = '172.2.4.0/22';


$config['influxdb']['enable'] = true;
$config['influxdb']['transport'] = 'http'; # Default, other options: https, udp
$config['influxdb']['host'] = 'wpl-docker02.vm.library.wpl.lib.in.us';
$config['influxdb']['port'] = '8086';
$config['influxdb']['db'] = 'librenms';
$config['influxdb']['username'] = 'admin';
$config['influxdb']['password'] = 'admin';
$config['influxdb']['timeout'] = 0; # Optional
$config['influxdb']['verifySSL'] = false; # Optional