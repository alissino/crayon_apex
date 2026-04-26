create or replace function f_buscar_empr_ativa
return empresa.cd_empresa%type
is
begin
  return k_empresa.f_buscar_empresa_ativa;
end f_buscar_empr_ativa;
/
