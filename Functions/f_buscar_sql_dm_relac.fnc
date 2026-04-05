create or replace function f_buscar_sql_dm_relac(prm_cd_objeto   in dominio_relacionamento.cd_objeto%type,
                                                 prm_cd_atributo in dominio_relacionamento.cd_atributo%type) 
  return k_dominio.typ_sql
is
begin
  return k_dominio.f_sql_dm_relac(prm_cd_objeto   => prm_cd_objeto, 
                                  prm_cd_atributo => prm_cd_atributo);
end f_buscar_sql_dm_relac;
/
