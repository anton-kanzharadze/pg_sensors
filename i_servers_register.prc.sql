CREATE OR REPLACE PROCEDURE public.i_servers_register(a_alias character varying, INOUT a_guid uuid)
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
	if(coalesce(a_alias, '') = '') then
		raise exception 'Пустые входные параметры';
	end if;

	select t.guid into a_guid from servers t
	where t.alias = a_alias;

	if a_guid is not null then
		return;
	end if;

	/*TODO exec i_servers_calc_activity*/

	begin/*exception*/
		
		a_guid := extensions.uuid_generate_v4();

		insert into servers
			(guid, root_server_guid, alias, created, is_connected, connected, ipaddress, changed)
		values
			(a_guid, null, a_alias, _now, false, null, null, _now);
	
		/*TODO exec i_Events_Servers_Register*/
	
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
