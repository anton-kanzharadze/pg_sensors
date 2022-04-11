CREATE OR REPLACE FUNCTION public.get_code_connected()
 RETURNS character varying
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
begin
	return 'Connected';
end
$function$
;

-- Permissions

ALTER FUNCTION public.get_code_connected() OWNER TO postgres;
GRANT ALL ON FUNCTION public.get_code_connected() TO postgres;
