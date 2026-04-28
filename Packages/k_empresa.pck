create or replace package k_empresa is

  procedure p_salvar_emp(prm_cd_empresa  in out empresa.cd_empresa%type,
                         prm_cd_pessoa   in empresa.cd_pessoa%type,
                         prm_dm_situacao in empresa.dm_situacao%type);
  
  procedure p_salvar_estab(prm_cd_estab    in out empresa_estabelecimento.cd_estab%type,
                           prm_cd_empresa  in empresa_estabelecimento.cd_empresa%type,
                           prm_cd_pessoa   in empresa_estabelecimento.cd_pessoa%type,
                           prm_dm_tipo     in empresa_estabelecimento.dm_tipo%type,
                           prm_dm_crt      in empresa_estabelecimento.dm_crt%type,
                           prm_dm_situacao in empresa_estabelecimento.dm_situacao%type);
                           
  function f_buscar_razao_social_emp(prm_cd_empresa empresa.cd_empresa%type)
    return pessoa.ds_nome%type;
  
  function f_buscar_fantasia_emp(prm_cd_empresa empresa.cd_empresa%type)
    return pessoa.ds_fantasia%type;
    
  function f_buscar_empresa_estab(prm_cd_estab empresa_estabelecimento.cd_estab%type)
    return empresa.cd_empresa%type;
    
  function f_buscar_cd_pess_estab(prm_cd_estab empresa_estabelecimento.cd_estab%type)
    return pessoa.cd_pessoa%type;
  
  function f_buscar_razao_social_estab(prm_cd_estab empresa_estabelecimento.cd_estab%type)
    return pessoa.ds_nome%type;
    
  function f_buscar_fantasia_estab(prm_cd_estab empresa_estabelecimento.cd_estab%type)
    return pessoa.ds_fantasia%type;
  
  function f_buscar_doc_estab(prm_cd_estab empresa_estabelecimento.cd_estab%type,
                              prm_cd_doc   pessoa_documento.cd_documento%type,
                              prm_vf_mask  boolean default false)
    return pessoa_documento.ds_documento%type;
  
  
  function f_buscar_estab_ativo
    return empresa_estabelecimento.cd_estab%type;
  
  function f_buscar_empresa_ativa
    return empresa.cd_empresa%type;
    
  procedure p_buscar_num_serie_nf(prm_cd_estab  in  empresa_estabelecimento.cd_estab%type,
                                  prm_nr_numero out empresa_estab_seq_nf.nr_prox_numero%type,
                                  prm_nr_serie  out empresa_estab_seq_nf.nr_serie%type);

end k_empresa;
/
create or replace package body k_empresa is
  
  procedure p_salvar_emp(prm_cd_empresa  in out empresa.cd_empresa%type,
                         prm_cd_pessoa   in empresa.cd_pessoa%type,
                         prm_dm_situacao in empresa.dm_situacao%type)
    is
    begin
      if prm_cd_empresa is null then
        prm_cd_empresa := s_empresa.nextval;
        insert
          into empresa
              (cd_empresa,
               cd_pessoa,
               dm_situacao)
        values(prm_cd_empresa,
               prm_cd_pessoa,
               prm_dm_situacao);
      else
        update empresa e
           set e.cd_pessoa   = prm_cd_pessoa,
               e.dm_situacao = prm_dm_situacao
         where e.cd_empresa  = prm_cd_empresa;
      end if;
      commit;
    end p_salvar_emp;
  
  procedure p_salvar_estab(prm_cd_estab    in out empresa_estabelecimento.cd_estab%type,
                           prm_cd_empresa  in empresa_estabelecimento.cd_empresa%type,
                           prm_cd_pessoa   in empresa_estabelecimento.cd_pessoa%type,
                           prm_dm_tipo     in empresa_estabelecimento.dm_tipo%type,
                           prm_dm_crt      in empresa_estabelecimento.dm_crt%type,
                           prm_dm_situacao in empresa_estabelecimento.dm_situacao%type)
    is
    begin
      if prm_cd_estab is null then
        prm_cd_estab := s_empresa_estabelecimento.nextval;
        insert
          into empresa_estabelecimento
              (cd_estab,
               cd_empresa,
               cd_pessoa,
               dm_tipo,
               dm_crt,
               dm_situacao)
        values(prm_cd_estab,
               prm_cd_empresa,
               prm_cd_pessoa,
               prm_dm_tipo,
               prm_dm_crt,
               prm_dm_situacao);
      else
        update empresa_estabelecimento ee
           set ee.cd_empresa  = prm_cd_empresa,
               ee.cd_pessoa   = prm_cd_pessoa,
               ee.dm_tipo     = prm_dm_tipo,
               ee.dm_crt      = prm_dm_crt,
               ee.dm_situacao = prm_dm_situacao
         where ee.cd_estab    = prm_cd_estab;
      end if;
      commit;
    end p_salvar_estab;
    
  function f_buscar_razao_social_emp(prm_cd_empresa empresa.cd_empresa%type)
    return pessoa.ds_nome%type
    is
    begin
      return null;
    end f_buscar_razao_social_emp; 
  
  function f_buscar_fantasia_emp(prm_cd_empresa empresa.cd_empresa%type)
    return pessoa.ds_fantasia%type
    is
    begin
      return null;
    end f_buscar_fantasia_emp;
  
  function f_buscar_empresa_estab(prm_cd_estab empresa_estabelecimento.cd_estab%type)
    return empresa.cd_empresa%type
    is
      aux_cd_empresa empresa.cd_empresa%type;
    begin
      select ee.cd_empresa
        into aux_cd_empresa
        from empresa_estabelecimento ee
       where ee.cd_estab = prm_cd_estab;
      return aux_cd_empresa;
    end f_buscar_empresa_estab;
    
  function f_buscar_cd_pess_estab(prm_cd_estab empresa_estabelecimento.cd_estab%type)
    return pessoa.cd_pessoa%type
    is
      aux_cd_pessoa pessoa.cd_pessoa%type;
    begin
      select ee.cd_pessoa
        into aux_cd_pessoa
        from empresa_estabelecimento ee
       where ee.cd_estab = prm_cd_estab;
      
      return aux_cd_pessoa;
    end f_buscar_cd_pess_estab;
  
  function f_buscar_razao_social_estab(prm_cd_estab empresa_estabelecimento.cd_estab%type)
    return pessoa.ds_nome%type
    is
    begin
      return k_pessoa.f_buscar_nome(f_buscar_cd_pess_estab(prm_cd_estab));
    end f_buscar_razao_social_estab;
    
  function f_buscar_fantasia_estab(prm_cd_estab empresa_estabelecimento.cd_estab%type)
    return pessoa.ds_fantasia%type
    is
      aux_ds_fantasia pessoa.ds_fantasia%type;
    begin
      select p.ds_fantasia
        into aux_ds_fantasia
        from empresa_estabelecimento ee,
             pessoa                  p
       where p.cd_pessoa = ee.cd_pessoa
         and ee.cd_estab = prm_cd_estab;
      return aux_ds_fantasia;
    end f_buscar_fantasia_estab;
  
  function f_buscar_doc_estab(prm_cd_estab empresa_estabelecimento.cd_estab%type,
                              prm_cd_doc   pessoa_documento.cd_documento%type,
                              prm_vf_mask  boolean default false)
    return pessoa_documento.ds_documento%type
    is
    begin
      return k_pessoa.f_buscar_doc(prm_cd_pessoa    => f_buscar_cd_pess_estab(prm_cd_estab),
                                   prm_cd_documento => prm_cd_doc,
                                   prm_vf_mask      => prm_vf_mask);
    end f_buscar_doc_estab;
    
    
  function f_buscar_estab_ativo
    return empresa_estabelecimento.cd_estab%type
    is
    begin
      return v('CD_ESTAB');
    end f_buscar_estab_ativo;
  
  function f_buscar_empresa_ativa
    return empresa.cd_empresa%type
    is
    begin
      return f_buscar_empresa_estab(f_buscar_estab_ativo);
    end f_buscar_empresa_ativa;
    
  procedure p_buscar_num_serie_nf(prm_cd_estab  in  empresa_estabelecimento.cd_estab%type,
                                  prm_nr_numero out empresa_estab_seq_nf.nr_prox_numero%type,
                                  prm_nr_serie  out empresa_estab_seq_nf.nr_serie%type)
    is
      pragma autonomous_transaction;
      aux_nr_num_calc   empresa_estab_seq_nf.nr_prox_numero%type;
      aux_nr_serie_calc empresa_estab_seq_nf.nr_serie%type;
    begin
    
      lock table empresa_estab_seq_nf in exclusive mode wait 2;
      
      begin
        select sf.nr_prox_numero,
               sf.nr_serie
          into prm_nr_numero,
               prm_nr_serie
          from empresa_estab_seq_nf sf
         where sf.cd_estab = prm_cd_estab;
      exception
        when no_data_found then
          prm_nr_numero := 1;
          prm_nr_serie  := 1;
          insert
            into empresa_estab_seq_nf
                (cd_estab,
                 nr_serie,
                 nr_prox_numero)
          values(prm_cd_estab,
                 prm_nr_serie,
                 prm_nr_numero);
      end;
      
      aux_nr_num_calc   := prm_nr_numero + 1;
      aux_nr_serie_calc := prm_nr_serie;
      
      if aux_nr_num_calc > 999999999 then
        aux_nr_num_calc   := 1;
        aux_nr_serie_calc := aux_nr_serie_calc + 1;
      end if;
      
      update empresa_estab_seq_nf sf
         set sf.nr_prox_numero = aux_nr_num_calc,
             sf.nr_serie       = aux_nr_serie_calc
       where sf.cd_estab = prm_cd_estab;
      
      commit;
    
    exception
      when others then
        rollback;
        raise;
    end p_buscar_num_serie_nf;
  
end k_empresa;
/
