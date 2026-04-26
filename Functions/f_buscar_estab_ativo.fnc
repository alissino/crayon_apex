create or replace function f_buscar_estab_ativo
return empresa_estabelecimento.cd_estab%type
is
begin
  return k_empresa.f_buscar_estab_ativo;
end f_buscar_estab_ativo;
/
