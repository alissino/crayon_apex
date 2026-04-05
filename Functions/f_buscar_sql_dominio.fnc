create or replace function f_buscar_sql_dominio(prm_cd_dominio in dominio.cd_dominio%type) 
return k_dominio.typ_sql 
is
begin
  return k_dominio.f_sql_dm(prm_cd_dominio => prm_cd_dominio);
end f_buscar_sql_dominio;
/
