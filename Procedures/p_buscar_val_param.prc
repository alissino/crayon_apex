create or replace procedure p_buscar_val_param(prm_cd_param parametro.cd_parametro%type,
                                               prm_cd_user  k_usuario.typ_usuario default k_parametro.aux_cd_usuario,
                                               prm_vl_param out parametro.ds_valor%type) 
is
begin
  prm_vl_param := k_parametro.f_valor(prm_cd_parametro => prm_cd_param, 
                                      prm_cd_usuario   => prm_cd_user);
end p_buscar_val_param;
/
