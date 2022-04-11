CREATE OR REPLACE PROCEDURE public.i_sensors_register(a_datetime timestamp without time zone, a_sensors_serialno character varying, a_macaddress character varying, a_sensorstypes_code character varying, INOUT a_guid uuid)
 LANGUAGE plpgsql
AS $procedure$
declare
	_sqlstate text;
	_message text;
	_context text; 
	_completed bool := false;
	_now timestamp := now() at time zone 'utc';
	_rowcount int;
declare
	_sensors_typesid int = (select id from sensors_types where code = a_sensorstypes_code);
begin
	if (a_datetime is null) or (coalesce(a_sensors_serialno, '') = '') or (coalesce(a_sensorstypes_code, '') = '') then
		raise exception 'Пустые входные параметры';
	end if;

	if (select t.deleted
			from sensors t
			where t.serialno = a_sensors_serialno) then
		raise exception 'Датчик %s помечен как "Удаленный"', a_sensors_serialno;	
	end if;

	if _sensors_typesid is null then
		raise exception 'Типа датчика с кодом %s не найден', a_sensorstypes_code;
	end if;
 
	insert into sensors (guid, serialno, name, sensors_typesid, macaddress, created,
	 	is_connected, connected, disconnected, activity) 
	values (a_guid, a_sensors_serialno, a_sensors_serialno, _sensors_typesid, a_macaddress, _now,
	  false, null, null, a_datetime);		
	 
  insert into sensors_mac (guid, macaddress, created)
  values (a_guid, a_macaddress, _now);		 


end; $procedure$
;
;
