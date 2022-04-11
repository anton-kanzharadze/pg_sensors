CREATE OR REPLACE PROCEDURE public.i_events_sensors_register(
	a_action_code varchar(20),
	a_happend timestamp,
	a_sensors_guid uuid,
	a_servers_guid uuid,
	a_services_guid uuid,
	inout a_guid uuid
)
 LANGUAGE plpgsql
AS $procedure$
declare
	_now timestamp := now() at time zone 'utc';
	_action_id int = (select id from events_actions where code = a_action_code);
begin
	if (a_happend is null) or (coalesce(a_action_code, '') = '') or (a_sensors_guid is null) 
		or (a_servers_guid is null) or (a_services_guid is null) or (_action_id is null) then
		raise exception 'ѕустые входные параметры';
	end if;
		 
if a_guid is not null then
	/* ќдно и то же событие может "происходить" многократно (например, если повторно прогон€ютс€ очереди);
	   повторно событие не регистрируетс€.*/
  if exists(select guid from events_sensors where guid = a_guid) then
  	return;
  end if;
elsif a_guid is null then
	a_guid := extensions.uuid_generate_v4();
end if;

-- добавление событи€ датчика
insert into events_sensors
  (guid, sensors_guid, servers_guid, services_guid, happend, written, events_actions_id)
values 
  (a_guid, a_sensors_guid, a_servers_guid, a_services_guid, a_happend, _now, _action_id);

end; $procedure$
;

-- Permissions

alter procedure public.i_events_sensors_register(varchar,timestamp,uuid,uuid,uuid,uuid) owner to postgres;

grant all on procedure public.i_events_sensors_register(varchar,timestamp,uuid,uuid,uuid,uuid) to postgres;
