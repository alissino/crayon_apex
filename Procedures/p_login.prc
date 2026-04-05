create or replace procedure p_login(prm_cd_usuario varchar2) 
is
begin
  k_usuario.p_login(prm_cd_usuario);
end p_login;
/
