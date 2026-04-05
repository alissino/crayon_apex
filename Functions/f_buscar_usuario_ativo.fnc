create or replace function f_buscar_usuario_ativo 
  return k_usuario.typ_usuario
is
begin
  return k_usuario.f_ativo;
end f_buscar_usuario_ativo;
/
