CREATE OR REPLACE FUNCTION public.get_code_disconnected()
 RETURNS character varying
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
begin
	return 'Disconnected';
end
$function$
;

-- Permissions

ALTER FUNCTION public.get_code_disconnected() OWNER TO postgres;
GRANT ALL ON FUNCTION public.get_code_disconnected() TO postgres;
