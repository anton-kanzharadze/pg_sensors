CREATE OR REPLACE FUNCTION public.get_code_offair()
 RETURNS character varying
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
begin
	return 'OffAir';
end
$function$
;

-- Permissions

ALTER FUNCTION public.get_code_offair() OWNER TO postgres;
GRANT ALL ON FUNCTION public.get_code_offair() TO postgres;
