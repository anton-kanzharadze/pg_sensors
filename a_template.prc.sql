CREATE OR REPLACE PROCEDURE public.i_servers_register(
	a_datetime timestamp,
	a_code int,
	a_sign boolean,
	a_sensors_serialno varchar(50),
	inout a_guid uuid 
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
/* Константы */
declare
	_code_cardio varchar(20) := get_code_cardio(); 
	_code_label varchar(20) := get_code_label();	
/* Локальные переменные */
declare
	_sensors_typesid int;
	_res int;		
	_test_code varchar(20);
begin	
	/* Проверка входных данных */
	if (a_datetime is null) or (coalesce(a_sensors_serialno, '') = '') or (coalesce(a_servers_alias, '') = '') 
			or (coalesce(a_services_alias, '') = '') or (coalesce(a_action_code, '') = '')  then
		raise exception 'Пустые входные параметры';
	end if;

	/* Проверки, получение необходимых данных */
	select a_guid = t.guid, 
		_sensors_typesid = t.sensors_typesid
	from sensors t
	where t.serialno = sensors_serialno
	and t.deleted = false;
	get diagnostics _rowcount = row_count;

	if _rowcount > 1 then
		raise exception 'Дублирование датчика "%s"', a_sensors_serialno;
	end if;
	if (_rowcount = 0) and (a_sensorstypes_code = _code_cardio and not _auto_cardio 
								or	a_sensorstypes_code = _code_label and not  _auto_label) then
		return;/*Нормальное завершение: авторегистрация выключена*/
	end if;
	
  /* До этой точки код выполняется в транзакции вызывающего кода.*/
  /* Начало блока "begin-exception-end". Здесь неявно устанавливается savepoint SP1 */
	begin
	/*начало DML*/						
	
		
	/**/
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

comment on procedure public.s_sensors_register is 'Шаблон';
