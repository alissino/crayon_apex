create or replace package k_usuario
is
  subtype typ_usuario is varchar2(45);
  
  procedure p_login(prm_cd_usuario in typ_usuario);
  
  function f_ativo
    return typ_usuario;
  

end k_usuario;
/
create or replace package body k_usuario
is
  
  procedure p_login(prm_cd_usuario in typ_usuario)
    is
    begin
      dbms_session.set_context(namespace => 'x_crayon_usuario',
                               attribute => 'cd_usuario',
                               value     => prm_cd_usuario);
      dbms_session.set_context(namespace => 'x_crayon_usuario',
                               attribute => 'dt_login',
                               value     => sysdate);
    end;
  
  function f_ativo
    return typ_usuario
    is
    begin
      
      return nvl(nvl(v('APP_USER'), sys_context('x_crayon_usuario', 'cd_usuario')), user);
    end;
  
end k_usuario;
/
