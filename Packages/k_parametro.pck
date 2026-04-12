create or replace package k_parametro is

  aux_cd_usuario k_usuario.typ_usuario := k_usuario.f_ativo;
  
  function f_valor(prm_cd_parametro in parametro.cd_parametro%type,
                   prm_cd_usuario   in k_usuario.typ_usuario default aux_cd_usuario)
    return parametro.ds_valor%type;
  
  function f_mask(prm_cd_parametro in parametro.cd_parametro%type,
                  prm_cd_usuario   in k_usuario.typ_usuario default aux_cd_usuario)
    return varchar2;
  
  function f_valor_lista(prm_cd_parametro in parametro.cd_parametro%type,
                         prm_cd_usuario   in parametro_usuario.cd_usuario%type default aux_cd_usuario)
    return k_lista.typ_lista;
    
  function f_valor_lista_pipe(prm_cd_parametro in parametro.cd_parametro%type,
                              prm_cd_usuario   in parametro_usuario.cd_usuario%type default aux_cd_usuario)
    return k_lista.typ_lista pipelined;
  
  procedure p_salvar(prm_cd_parametro in parametro.cd_parametro%type,
                     prm_ds_nome      in parametro.ds_nome%type,
                     prm_ds_descricao in parametro.ds_descricao%type,
                     prm_dm_tipo      in parametro.dm_tipo%type,
                     prm_cd_dominio   in parametro.cd_dominio%type,
                     prm_ds_separador in parametro.ds_separador%type,
                     prm_ds_valor     in parametro.ds_valor%type);
  
  procedure p_salvar_usu(prm_cd_param_usu in out parametro_usuario.cd_param_usu%type,
                         prm_cd_parametro in     parametro_usuario.cd_parametro%type,
                         prm_cd_usuario   in     parametro_usuario.cd_usuario%type,
                         prm_ds_valor     in     parametro_usuario.ds_valor%type);
  
  procedure p_excluir(prm_cd_parametro in parametro.cd_parametro%type);
  
  procedure p_excluir_usu(prm_cd_param_usu in parametro_usuario.cd_param_usu%type);

end k_parametro;
/
create or replace package body k_parametro is
  
  subtype typ_chave is varchar2(512);
  
  type typ_obj_param is record(ds_valor     parametro.ds_valor%type,
                               dm_tipo      parametro.dm_tipo%type,
                               ds_separador parametro.ds_separador%type,
                               cd_dominio   parametro.cd_dominio%type);
  
  type typ_vet_valor is table of typ_obj_param
    index by typ_chave;
  
  aux_vet_valor typ_vet_valor := typ_vet_valor();
  
  function f_chave(prm_cd_parametro parametro.cd_parametro%type,
                   prm_cd_usuario   k_usuario.typ_usuario)
    return typ_chave
    is
    begin
      return prm_cd_parametro||'|'||prm_cd_usuario;
    end;
  
  procedure p_carregar(prm_cd_parametro in parametro.cd_parametro%type,
                       prm_cd_usuario   in k_usuario.typ_usuario)
    is
      aux_ds_chave  typ_chave := f_chave(prm_cd_parametro, prm_cd_usuario);
      aux_obj_param typ_obj_param;
    begin
      begin
        select pu.ds_valor,
               p.dm_tipo,
               p.ds_separador,
               p.cd_dominio
          into aux_obj_param.ds_valor,
               aux_obj_param.dm_tipo,
               aux_obj_param.ds_separador,
               aux_obj_param.cd_dominio
          from parametro_usuario pu,
               parametro         p
         where p.cd_parametro  = pu.cd_parametro
           and pu.cd_parametro = prm_cd_parametro
           and pu.cd_usuario   = prm_cd_usuario;
      exception
        when no_data_found then
          select p.ds_valor,
                 p.dm_tipo,
                 p.ds_separador,
                 p.cd_dominio
            into aux_obj_param.ds_valor,
                 aux_obj_param.dm_tipo,
                 aux_obj_param.ds_separador,
                 aux_obj_param.cd_dominio
            from parametro p
           where p.cd_parametro = prm_cd_parametro;
      end;
      
      aux_vet_valor(aux_ds_chave) := aux_obj_param;
      
    end;
  
  function f_valor(prm_cd_parametro in parametro.cd_parametro%type,
                   prm_cd_usuario   in k_usuario.typ_usuario default aux_cd_usuario)
    return parametro.ds_valor%type
    is
      aux_ds_chave typ_chave := f_chave(prm_cd_parametro, prm_cd_usuario);
    begin
      if not aux_vet_valor.exists(aux_ds_chave) then
        p_carregar(prm_cd_parametro => prm_cd_parametro,
                   prm_cd_usuario   => prm_cd_usuario);
      end if;
      return aux_vet_valor(aux_ds_chave).ds_valor;
    end;
  
  function f_mask(prm_cd_parametro in parametro.cd_parametro%type,
                  prm_cd_usuario   in k_usuario.typ_usuario default aux_cd_usuario)
    return varchar2
    is
      aux_obj_param typ_obj_param;
      aux_ds_mask   varchar2(32000);
      aux_ds_chave  typ_chave := f_chave(prm_cd_parametro, prm_cd_usuario);
    begin
      if not aux_vet_valor.exists(aux_ds_chave) then
        p_carregar(prm_cd_parametro => prm_cd_parametro,
                   prm_cd_usuario   => prm_cd_usuario);
      end if; 
      
      aux_obj_param := aux_vet_valor(aux_ds_chave);
      
      if aux_obj_param.cd_dominio is not null then
        aux_ds_mask := k_dominio.f_mask(prm_cd_dominio => aux_obj_param.cd_dominio,
                                        prm_ds_valor   => aux_obj_param.ds_valor);
      else
        aux_ds_mask := aux_obj_param.ds_valor;
      end if;
      return aux_ds_mask;
    end;
  
  function f_valor_lista(prm_cd_parametro in parametro.cd_parametro%type,
                         prm_cd_usuario   in parametro_usuario.cd_usuario%type default aux_cd_usuario)
    return k_lista.typ_lista
    is
      aux_vt_lista k_lista.typ_lista;
      aux_ds_chave typ_chave := f_chave(prm_cd_parametro, prm_cd_usuario);
    begin
      if not aux_vet_valor.exists(aux_ds_chave) then
        p_carregar(prm_cd_parametro => prm_cd_parametro,
                   prm_cd_usuario   => prm_cd_usuario);
      end if;
      
      k_lista.p_criar_lista(prm_ds_string    => aux_vet_valor(aux_ds_chave).ds_valor,
                            prm_vt_lista     => aux_vt_lista,
                            prm_ds_separador => aux_vet_valor(aux_ds_chave).ds_separador);
      
      return aux_vt_lista;
      
    end f_valor_lista;
  
  function f_valor_lista_pipe(prm_cd_parametro in parametro.cd_parametro%type,
                              prm_cd_usuario   in parametro_usuario.cd_usuario%type default aux_cd_usuario)
    return k_lista.typ_lista pipelined
    is
      aux_vt_lista k_lista.typ_lista;
    begin
      aux_vt_lista := k_parametro.f_valor_lista(prm_cd_parametro, prm_cd_usuario);
      
      for i in 1 .. aux_vt_lista.count loop
        pipe row(aux_vt_lista(i));
      end loop;
      return;
    end;
  
  procedure p_salvar(prm_cd_parametro in parametro.cd_parametro%type,
                     prm_ds_nome      in parametro.ds_nome%type,
                     prm_ds_descricao in parametro.ds_descricao%type,
                     prm_dm_tipo      in parametro.dm_tipo%type,
                     prm_cd_dominio   in parametro.cd_dominio%type,
                     prm_ds_separador in parametro.ds_separador%type,
                     prm_ds_valor     in parametro.ds_valor%type)
    is
    begin
      update parametro p
         set p.ds_nome      = prm_ds_nome,
             p.ds_descricao = prm_ds_descricao,
             p.dm_tipo      = prm_dm_tipo,
             p.cd_dominio   = prm_cd_dominio,
             p.ds_separador = prm_ds_separador,
             p.ds_valor     = prm_ds_valor
       where p.cd_parametro = prm_cd_parametro;
      
      if sql%rowcount = 0 then
        insert
          into parametro
        values(prm_cd_parametro,
               prm_ds_nome,
               prm_ds_descricao,
               prm_dm_tipo,
               prm_cd_dominio,
               prm_ds_separador,
               prm_ds_valor);
      end if;
      commit;
    end;
  
  procedure p_salvar_usu(prm_cd_param_usu in out parametro_usuario.cd_param_usu%type,
                         prm_cd_parametro in     parametro_usuario.cd_parametro%type,
                         prm_cd_usuario   in     parametro_usuario.cd_usuario%type,
                         prm_ds_valor     in     parametro_usuario.ds_valor%type)
    is
    begin
      if prm_cd_param_usu is null then
        prm_cd_param_usu := parametro_usuario_seq.nextval;
        insert
          into parametro_usuario
        values(prm_cd_param_usu,
               prm_cd_parametro,
               prm_cd_usuario,
               prm_ds_valor);
      else
        update parametro_usuario pu
           set pu.cd_parametro = prm_cd_parametro,
               pu.cd_usuario   = prm_cd_usuario,
               pu.ds_valor     = prm_ds_valor
         where pu.cd_param_usu = prm_cd_param_usu;
      end if;
      commit;
    end;
  
  procedure p_excluir(prm_cd_parametro in parametro.cd_parametro%type)
    is
    begin
      delete
        from parametro_usuario pu
       where pu.cd_parametro = prm_cd_parametro;
      delete
        from parametro p
       where p.cd_parametro = prm_cd_parametro;
      commit;
    end;
  
  procedure p_excluir_usu(prm_cd_param_usu in parametro_usuario.cd_param_usu%type)
    is
    begin
      delete
        from parametro_usuario pu
       where pu.cd_param_usu = prm_cd_param_usu;
      commit;
    end;

  
end k_parametro;
/
