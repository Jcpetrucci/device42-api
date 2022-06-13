#!/bin/bash
string_searching="Searching..."

while read -r -p 'd42? ' name; do
	
	printf '%s\r' "$string_searching" >&2
	{ curl --netrc -s -X POST -d 'header=yes' --data-urlencode 'query=SELECT d.name as device_name, SUBSTRING(a.alias_name,1,20) as alias, i.ip_address, d.cpucount as sockets, d.cpucore as cores, CONCAT(d.ram, d.ram_size_type) as ram, CONCAT(d.hard_disk_size, d.hard_disk_size_type) as hdd, REGEXP_REPLACE(SUBSTRING(d.notes,1,100),'"'[\n\r]'"','"' '"','"'g'"') as notes, TO_CHAR(d.first_added, '"'yyyy-mm-dd @hh:mm'"') as date_added, SUBSTRING(s.verbose_name,1,20) as subnet from view_device_v1 d join view_ipaddress_v1 i on i.device_fk = d.device_pk  left join view_devicealias_v1 a on a.device_fk = d.device_pk inner join view_subnet_v1 s on i.subnet_fk = s.subnet_pk WHERE d.cloud_instance_id LIKE '"'%${name,,}%'"' ORDER BY d.name ' 'https://ipam.optiv.com/services/data/v1.0/query/' 2>&1; } | column -t -s ','  
		echo 
done</proc/self/fd/0 
