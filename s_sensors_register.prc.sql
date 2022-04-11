CREATE OR REPLACE PROCEDURE hardware.s_devinfo_register(
	a_events_guid uuid, /*������������� �������*/
	a_servers_alias character varying, /*�������� ����� �����*/
	a_services_alias character varying, /*������-�����������*/
	a_created timestamp without time zone, /*���� � ����� �������� ������*/
	a_hardware_type_id int, /*��� ������������*/
	a_hardvare_version int, /*������ ������������*/
	a_firmware_version_major int, /*������ ������������ ����������� Major*/
	a_hirmware_version_minor int, /*������ ������������ ����������� Minor*/
	a_processor_serialno character varying, /*�������� ����� ����������*/
	a_protocol_version int, /*������ ��������� ������*/
	a_firmware_time timestamp without time zone, /*���� � ����� �������� ��������*/
	a_firmware_bank int, /*����� ����� � ������� �������� ��������*/
	a_firmware_reload_Counter int, /*���������� ������������?*/
	a_register_events boolean /*�����: �������������� �������*/
)
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
	_servers_guid uuid;
	_services_guid uuid;
	_sensors_typesid int;
	_res int;
	_test_code varchar(20);
declare
	r_device hardware.device%rowtype;	
begin
	if (a_datetime is null) or (coalesce(a_sensors_serialno, '') = '') or (coalesce(a_servers_alias, '') = '') 
			or (coalesce(a_services_alias, '') = '') or (coalesce(a_action_code, '') = '')  
			or (coalesce(a_sensorstypes_code, '') = '') then
		raise exception '������ ������� ���������';
	end if;
	  /* �� ���� ����� ��� ����������� � ���������� ����������� ����.*/
    /* ������ ����� begin-exception. ����� ������ ��������������� savepoint SP1 */
	begin/*exception*/

	/* ����������� ������� */
		call i_servers_register(a_servers_alias, /*out*/_servers_guid);
	/* ����������� �������*/
		call i_services_register(a_service_alias, _servers_guid, /*out*/_services_guid);
	
		select *  
		from hardware.device 
		into r_device		
		where processor_serialno = a_processor_serialno;

		if r_device.guid is null then
 			/* ���������� ������ ���������� */		
			insert into hardware.device (
				guid, servers_guid, hardware_type_Iid, hardware_version, firmware_version_major, 
				firmware_version_minor, processor_serialno, protocol_version, firmware_time, firmware_bank, 
				firmware_reload_counter, Cchanged, confirmed, created)
			values (extensions.uuid_generate_v4(), a_servers_guid, a_hardware_type_id, a_hardvare_version, a_firmware_Vversion_major, 
				a_firmware_version_minor, a_processor_serialno, a_protocol_version, a_firmware_time, a_firmware_bank, 
				a_firmware_reload_counter, a_created, a_areated, a_created);
		else
			/*���������� ���������� �� ������������� ����������*/
			if r_device.servers_guid <> _servers_guid /*���������� ������������ �� ������ ����*/
				or r_device.hardware_type_id <> a_hardware_type_id /*��������� ��� ����������*/
				or r_device.hardware_version <> a_hardvare_version /*���������� ������ ������������*/
				or r_device.firmware_version_major <>r_device.firmware_version_major /*���������� ��������*/
				or r_device.firmware_version_minor <> a_firmware_version_minor
				or r_device.firmware_time <> a_firmware_time
				or r_device.firmware_bank <> a_firmware_bank
				or r_device.firmware_reload_counter <> a_firmware_reload_counter
				or r_device.protocol_version <> a_protocol_version /*��������� �������� ������*/ then
				update hardware_device 
				set	servers_guid = _servers_guid, 
					hardware_type_id = hardware_type_id, 
					hardware_version = a_hardvare_version, 
					firmware_version_major = a_firmware_version_major, 
					firmware_version_minor = a_firmware_version_minor, 
					protocol_version = a_protocol_version, 
					firmware_time = a_firmware_time, 
					firmware_bank = a_firmware_bank, 
					firmware_reload_counter = a_firmware_reload_counter, 
					changed = a_created, 
					confirmed = a_created 
				where guid = r_device.guid;
			else
				/*���������� ������� Conformed*/
				update hardware_device 
				set	confirmed = greatest(confirmed, a_created)
				where guid = r_device.guid;
			end if;
		end if;
	
		_completed := true;
	  /* ����� ������� release savepoint SP1 */
	exception
	  /* rollback to savepont SP1. (���������� ��������� ���������� ��������) */		
	when others then
		get stacked diagnostics
			_sqlstate = returned_sqlstate,
			_message = message_text,
			_context = pg_exception_context;
		_context := regexp_replace(_context, E'[\\n\\r]+', ' ', 'g' );
		raise exception 'sqlstate: %, message: %, context: [%]', _sqlstate, _message, _context;
	end;

	if _completed then
	  /* ������������� ������� � ������ ����� ���������� */
	  commit;
	end if;
	/* ����� ������ begin-exception-end ����� ���� ��������� */
end; $procedure$
;
