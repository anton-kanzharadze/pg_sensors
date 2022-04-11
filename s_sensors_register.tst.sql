do $$
	declare 
	a_datetime timestamp := now();
	a_sensors_serialno varchar(50) := 'sen1';
	a_servers_alias varchar(20) := 'srv1';
	a_services_alias varchar(20) := 'svc1';
	a_macaddress varchar(20) := '01';
	a_action_code varchar(20) := 'OnAir';
	a_sensorstypes_code varchar(20) := 'Cardio';
	a_events_guid uuid;
	a_guid uuid;
begin
	
call public.s_sensors_register(
	a_datetime, 
	a_sensors_serialno, 
	a_servers_alias, 
	a_services_alias, 
	a_macaddress, 
	a_action_code, 
	a_sensorstypes_code,
	a_events_guid,
	a_guid);
	
raise notice 'a_events_guid=%, a_guid=%', a_events_guid, a_guid;

end $$
