CREATE OR REPLACE PROCEDURE public.i_services_register(a_alias character varying, a_servers_guid uuid, INOUT a_guid uuid)
 LANGUAGE plpgsql
AS $procedure$
declare
	_sqlstate text;
	_message text;
	_context text; 
	_completed bool := false;
	_now timestamp := now() at time zone 'utc';
	_rowcount int;
begin
	if(coalesce(a_alias, '') = '') or (a_servers_guid is null) then
		raise exception 'Пустые входные параметры';
	end if;

	select a_guid = t.guid from services t
	where t.alias = a_alias
	and t.servers_guid = a_servers_guid;

	if a_guid is not null then
		return;
	end if;

	begin/*exception*/
		
		a_guid := extensions.uuid_generate_v4();

		insert into services
			(guid, servers_guid, alias, created, is_connected, connected, changed)
		values
			(a_guid, a_servers_guid, a_alias, _now, false, null, _now);
	
		_completed := true;
	exception
	when others then
		get stacked diagnostics
			_sqlstate = returned_sqlstate,
			_message = message_text,
			_context = pg_exception_context;
			_context := regexp_replace(_context, E'[\\n\\r]+', ' ', 'g' );
		raise exception 'sqlstate: %, message: %, context: [%]', _sqlstate, _message, _context;
	end;

	if _completed then
	  commit;
	end if;
end; $procedure$
;
