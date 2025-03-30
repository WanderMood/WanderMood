-- Functie om te controleren of een tabel bestaat
CREATE OR REPLACE FUNCTION public.check_table_exists(table_name text)
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  table_exists boolean;
BEGIN
  SELECT EXISTS (
    SELECT FROM information_schema.tables 
    WHERE table_schema = 'public'
    AND table_name = $1
  ) INTO table_exists;
  
  RETURN table_exists;
END;
$$;

-- Voeg hier andere hulpfuncties toe indien nodig

-- Functie om SQL direct uit te voeren (alleen voor development)
CREATE OR REPLACE FUNCTION public.exec_sql(sql_query text)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  EXECUTE sql_query;
END;
$$; 