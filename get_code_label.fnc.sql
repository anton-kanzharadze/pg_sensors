CREATE OR REPLACE FUNCTION public.get_code_label()
 RETURNS character varying
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
begin
	return 'Label';
end
$function$
;
