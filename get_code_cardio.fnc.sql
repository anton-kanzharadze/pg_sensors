CREATE OR REPLACE FUNCTION public.get_code_cardio()
 RETURNS character varying
 LANGUAGE plpgsql
 IMMUTABLE
AS $function$
begin
	return 'Cardio';
end
$function$
;
