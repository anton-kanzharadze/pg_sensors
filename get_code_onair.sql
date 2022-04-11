CREATE OR REPLACE FUNCTION public.get_code_onair()
 RETURNS character varying
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
begin
	return 'OnAir';
end
$function$
;

-- Permissions

ALTER FUNCTION public.get_code_onair() OWNER TO postgres;
GRANT ALL ON FUNCTION public.get_code_onair() TO postgres;
