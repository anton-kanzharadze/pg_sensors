CREATE OR REPLACE PROCEDURE hardware.s_devinfo_register(
	a_events_guid uuid, /*Идентификатор события*/
	a_servers_alias character varying, /*Серийный номер блока*/
	a_services_alias character varying, /*Служба-отправитель*/
	a_created timestamp without time zone, /*Дата и время создания фрейма*/
	a_hardware_type_id int, /*Тип оборудования*/
	a_hardvare_version int, /*Версия оборудования*/
	a_firmware_version_major int, /*Версия программного обеспечения Major*/
	a_hirmware_version_minor int, /*Версия программного обеспечения Minor*/
	a_processor_serialno character varying, /*Серийный номер процессора*/
	a_protocol_version int, /*Версия протокола обмена*/
	a_firmware_time timestamp without time zone, /*Дата и время загрузки прошивки*/
	a_firmware_bank int, /*Номер банка в который записана прошивка*/
	a_firmware_reload_Counter int, /*Количество перепрошивок?*/
	a_register_events boolean /*Опция: регистрировать событие*/
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
		raise exception 'Пустые входные параметры';
	end if;
	  /* До этой точки код выполняется в транзакции вызывающего кода.*/
    /* Начало блока begin-exception. Здесь неявно устанавливается savepoint SP1 */
	begin/*exception*/

	/* Регистрация сервера */
		call i_servers_register(a_servers_alias, /*out*/_servers_guid);
	/* Регистрация сервиса*/
		call i_services_register(a_service_alias, _servers_guid, /*out*/_services_guid);
	
		select *  
		from hardware.device 
		into r_device		
		where processor_serialno = a_processor_serialno;

		if r_device.guid is null then
 			/* Добавление нового устройства */		
			insert into hardware.device (
				guid, servers_guid, hardware_type_Iid, hardware_version, firmware_version_major, 
				firmware_version_minor, processor_serialno, protocol_version, firmware_time, firmware_bank, 
				firmware_reload_counter, Cchanged, confirmed, created)
			values (extensions.uuid_generate_v4(), a_servers_guid, a_hardware_type_id, a_hardvare_version, a_firmware_Vversion_major, 
				a_firmware_version_minor, a_processor_serialno, a_protocol_version, a_firmware_time, a_firmware_bank, 
				a_firmware_reload_counter, a_created, a_areated, a_created);
		else
			/*Обновление информации по существующему устройству*/
			if r_device.servers_guid <> _servers_guid /*Устройство переставлено на другой блок*/
				or r_device.hardware_type_id <> a_hardware_type_id /*Изменился тип устройства*/
				or r_device.hardware_version <> a_hardvare_version /*Изменилась версия оборудования*/
				or r_device.firmware_version_major <>r_device.firmware_version_major /*Изменилась прошивка*/
				or r_device.firmware_version_minor <> a_firmware_version_minor
				or r_device.firmware_time <> a_firmware_time
				or r_device.firmware_bank <> a_firmware_bank
				or r_device.firmware_reload_counter <> a_firmware_reload_counter
				or r_device.protocol_version <> a_protocol_version /*Изменился протокол обмена*/ then
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
				/*Обновление времени Conformed*/
				update hardware_device 
				set	confirmed = greatest(confirmed, a_created)
				where guid = r_device.guid;
			end if;
		end if;
	
		_completed := true;
	  /* Здесь неявный release savepoint SP1 */
	exception
	  /* rollback to savepont SP1. (Переменные сохраняют полученные значения) */		
	when others then
		get stacked diagnostics
			_sqlstate = returned_sqlstate,
			_message = message_text,
			_context = pg_exception_context;
		_context := regexp_replace(_context, E'[\\n\\r]+', ' ', 'g' );
		raise exception 'sqlstate: %, message: %, context: [%]', _sqlstate, _message, _context;
	end;

	if _completed then
	  /* Подтверждение текущей и начало новой транзакции */
	  commit;
	end if;
	/* Таких блоков begin-exception-end может быть несколько */
end; $procedure$
;
