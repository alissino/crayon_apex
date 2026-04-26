create or replace package k_usuario
is
  subtype typ_usuario is varchar2(45);
  
  type typ_rec_estabs is record(cd_estab   empresa_estabelecimento.cd_estab%type,
                                ds_nome    pessoa.ds_nome%type,
                                ds_cnpj    pessoa_documento.ds_documento%type,
                                cd_empresa empresa.cd_empresa%type,
                                ds_tipo    varchar2(45),
                                ds_link    varchar2(400));
                                
  type typ_vet_estabs is table of typ_rec_estabs;
  
  procedure p_login(prm_cd_usuario in typ_usuario);
  
  function f_ativo
    return typ_usuario;
  
  function f_buscar_estabs_usuario(prm_cd_usuario typ_usuario)
    return typ_vet_estabs pipelined;

end k_usuario;
/
create or replace package body k_usuario
is
  
  cursor cur_estabs(prm_cd_usuario in typ_usuario)
      is select ee.cd_estab,
                k_empresa.f_buscar_razao_social_estab(ee.cd_estab) ds_nome,
                k_empresa.f_buscar_doc_estab(ee.cd_estab, 'CNPJ', true) ds_cnpj,
                k_dominio.f_mask_relac('empresa_estabelecimento', 'dm_tipo', ee.dm_tipo) ds_tipo,
                ee.cd_empresa
           from empresa_estabelecimento ee;
  
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
  
  function f_buscar_estabs_usuario(prm_cd_usuario typ_usuario)
    return typ_vet_estabs pipelined
    is
      aux_rc_estab typ_rec_estabs;
    begin
      for rec_estab in cur_estabs(prm_cd_usuario) loop
        aux_rc_estab.cd_estab   := rec_estab.cd_estab;
        aux_rc_estab.ds_nome    := rec_estab.ds_nome;
        aux_rc_estab.ds_cnpj    := rec_estab.ds_cnpj;
        aux_rc_estab.ds_tipo    := rec_estab.ds_tipo;
        aux_rc_estab.cd_empresa := rec_estab.cd_empresa;
        aux_rc_estab.ds_link    := 'javascript:selecionarEstab(' || rec_estab.cd_estab || ')';
        pipe row(aux_rc_estab);
      end loop;
      return;
    end;
  
end k_usuario;
/
