create or replace package k_pessoa is

  function f_buscar_nome(prm_cd_pessoa pessoa.cd_pessoa%type)
    return pessoa.ds_nome%type;
  
  function f_buscar_doc(prm_cd_pessoa    pessoa.cd_pessoa%type,
                        prm_cd_documento documento.cd_documento%type,
                        prm_vf_mask      boolean default false)
    return pessoa_documento.ds_documento%type;
    
  function f_buscar_tipo(prm_cd_pessoa pessoa.cd_pessoa%type)
    return pessoa.dm_tipo%type;
  
  procedure p_buscar_endereco(prm_cd_pessoa      in pessoa.cd_pessoa%type,
                              prm_nr_endereco    in pessoa_endereco.nr_sequencia%type default null,
                              prm_cd_pais        out pessoa_endereco.cd_pais%type,
                              prm_cd_estado      out pessoa_endereco.cd_estado%type,
                              prm_cd_cidade      out pessoa_endereco.cd_cidade%type,
                              prm_nr_cep         out pessoa_endereco.nr_cep%type,
                              prm_ds_logradouro  out pessoa_endereco.ds_logradouro%type,
                              prm_ds_bairro      out pessoa_endereco.ds_bairro%type,
                              prm_ds_numero      out pessoa_endereco.ds_numero%type,
                              prm_ds_complemento out pessoa_endereco.ds_complemento%type);
  
  function f_buscar_end(prm_cd_pessoa    pessoa.cd_pessoa%type,
                        prm_nr_sequencia pessoa_endereco.nr_sequencia%type default null,
                        prm_ds_opcao     varchar2)
    return varchar2;
  
  procedure p_salvar(prm_cd_pessoa       in out pessoa.cd_pessoa%type,
                     prm_dm_tipo         in pessoa.dm_tipo%type,
                     prm_ds_nome         in pessoa.ds_nome%type,
                     prm_ds_fantasia     in pessoa.ds_fantasia%type,
                     prm_ds_nome_social  in pessoa.ds_nome_social%type,
                     prm_dt_nascimento   in pessoa.dt_nascimento%type,
                     prm_dm_sexo         in pessoa.dm_sexo%type,
                     prm_dm_estado_civil in pessoa.dm_estado_civil%type);
  
  procedure p_salvar_doc(prm_cd_pessoa    pessoa.cd_pessoa%type,
                         prm_cd_documento pessoa_documento.cd_documento%type,
                         prm_ds_documento pessoa_documento.ds_documento%type);
  
  procedure p_salvar_doc(prm_cd_pessoa    pessoa.cd_pessoa%type,
                         prm_cd_documento pessoa_documento.cd_documento%type,
                         prm_ds_documento pessoa_documento.ds_documento%type,
                         prm_dm_status    varchar2);
                         
  
  procedure p_salvar_cont(prm_nr_sequencia in out pessoa_contato.nr_sequencia%type,
                          prm_cd_pessoa    in pessoa.cd_pessoa%type,
                          prm_dm_tipo      in pessoa_contato.dm_tipo%type,
                          prm_ds_contato   in pessoa_contato.ds_contato%type);
                          
  procedure p_salvar_cont(prm_nr_sequencia in out pessoa_contato.nr_sequencia%type,
                          prm_cd_pessoa    in pessoa.cd_pessoa%type,
                          prm_dm_tipo      in pessoa_contato.dm_tipo%type,
                          prm_ds_contato   in pessoa_contato.ds_contato%type,
                          prm_ds_status    in varchar2);
  
  procedure p_salvar_end(prm_nr_sequencia   in out pessoa_endereco.nr_sequencia%type,
                         prm_cd_pessoa      in pessoa_endereco.cd_pessoa%type,
                         prm_cd_pais        in pessoa_endereco.cd_pais%type,
                         prm_cd_estado      in pessoa_endereco.cd_estado%type,
                         prm_cd_cidade      in pessoa_endereco.cd_cidade%type,
                         prm_nr_cep         in pessoa_endereco.nr_cep%type,
                         prm_ds_logradouro  in pessoa_endereco.ds_logradouro%type,
                         prm_ds_bairro      in pessoa_endereco.ds_bairro%type,
                         prm_ds_numero      in pessoa_endereco.ds_numero%type,
                         prm_ds_complemento in pessoa_endereco.ds_complemento%type,
                         prm_dm_situacao    in pessoa_endereco.dm_situacao%type);
  
  procedure p_salvar_end(prm_nr_sequencia   in out pessoa_endereco.nr_sequencia%type,
                         prm_cd_pessoa      in pessoa_endereco.cd_pessoa%type,
                         prm_cd_pais        in pessoa_endereco.cd_pais%type,
                         prm_cd_estado      in pessoa_endereco.cd_estado%type,
                         prm_cd_cidade      in pessoa_endereco.cd_cidade%type,
                         prm_nr_cep         in pessoa_endereco.nr_cep%type,
                         prm_ds_logradouro  in pessoa_endereco.ds_logradouro%type,
                         prm_ds_bairro      in pessoa_endereco.ds_bairro%type,
                         prm_ds_numero      in pessoa_endereco.ds_numero%type,
                         prm_ds_complemento in pessoa_endereco.ds_complemento%type,
                         prm_dm_situacao    in pessoa_endereco.dm_situacao%type,
                         prm_dm_status      in varchar2);

end k_pessoa;
/
create or replace package body k_pessoa is

  function f_buscar_nome(prm_cd_pessoa pessoa.cd_pessoa%type)
    return pessoa.ds_nome%type
    is
      aux_ds_nome pessoa.ds_nome%type;
    begin
      select nvl(p.ds_nome_social, p.ds_nome)
        into aux_ds_nome
        from pessoa p
       where p.cd_pessoa = prm_cd_pessoa;
      return aux_ds_nome;
    exception
      when no_data_found or too_many_rows then
        return null;
      when others then
        raise;
    end;
  
  function f_buscar_doc(prm_cd_pessoa    pessoa.cd_pessoa%type,
                        prm_cd_documento documento.cd_documento%type,
                        prm_vf_mask      boolean default false)
    return pessoa_documento.ds_documento%type
    is
      aux_ds_doc  pessoa_documento.ds_documento%type;
      aux_ds_mask documento.ds_mascara%type;
    begin
      select pd.ds_documento,
             d.ds_mascara
        into aux_ds_doc,
             aux_ds_mask
        from pessoa_documento pd,
             documento        d
       where d.cd_documento  = pd.cd_documento
         and pd.cd_pessoa    = prm_cd_pessoa
         and pd.cd_documento = prm_cd_documento;
      
      if prm_vf_mask and aux_ds_mask is not null then
        aux_ds_doc := f_aplicar_mascara(aux_ds_doc, aux_ds_mask);
      end if;
      
      return aux_ds_doc;
    exception
      when no_data_found or too_many_rows then
        return null;
      when others then
        raise;
    end;
    
  function f_buscar_tipo(prm_cd_pessoa pessoa.cd_pessoa%type)
    return pessoa.dm_tipo%type
    is
      aux_dm_tipo pessoa.dm_tipo%type;
    begin
      select p.dm_tipo
        into aux_dm_tipo
        from pessoa p
       where p.cd_pessoa = prm_cd_pessoa;
      return aux_dm_tipo;
    end f_buscar_tipo;
  
  procedure p_buscar_endereco(prm_cd_pessoa      in pessoa.cd_pessoa%type,
                              prm_nr_endereco    in pessoa_endereco.nr_sequencia%type default null,
                              prm_cd_pais        out pessoa_endereco.cd_pais%type,
                              prm_cd_estado      out pessoa_endereco.cd_estado%type,
                              prm_cd_cidade      out pessoa_endereco.cd_cidade%type,
                              prm_nr_cep         out pessoa_endereco.nr_cep%type,
                              prm_ds_logradouro  out pessoa_endereco.ds_logradouro%type,
                              prm_ds_bairro      out pessoa_endereco.ds_bairro%type,
                              prm_ds_numero      out pessoa_endereco.ds_numero%type,
                              prm_ds_complemento out pessoa_endereco.ds_complemento%type)
    is
      aux_nr_seq pessoa_endereco.nr_sequencia%type;
    begin
      if prm_nr_endereco is null then
        select min(pe.nr_sequencia)
          into aux_nr_seq
          from pessoa_endereco pe
         where pe.cd_pessoa   = prm_cd_pessoa
           and pe.dm_situacao = 'A';
      else
        aux_nr_seq := prm_nr_endereco;
      end if;
      
      select pe.cd_pais,
             pe.cd_estado,
             pe.cd_cidade,
             pe.nr_cep,
             pe.ds_logradouro,
             pe.ds_bairro,
             pe.ds_numero,
             pe.ds_complemento
        into prm_cd_pais,
             prm_cd_estado,
             prm_cd_cidade,
             prm_nr_cep,
             prm_ds_logradouro,
             prm_ds_bairro,
             prm_ds_numero,
             prm_ds_complemento
        from pessoa_endereco pe
       where pe.nr_sequencia = aux_nr_seq
         and pe.cd_pessoa    = prm_cd_pessoa;
         
    exception
      when no_data_found then
        return;
    end;
  
  function f_buscar_end(prm_cd_pessoa    pessoa.cd_pessoa%type,
                        prm_nr_sequencia pessoa_endereco.nr_sequencia%type default null,
                        prm_ds_opcao     varchar2)
    return varchar2
    is
      /*
      prm_ds_opcao
      CD_PAIS   -> Código do pais
      PAIS      -> Nome do país
      CD_ESTADO -> Cód IBGE do estado
      UF        -> Sigla do estado
      ESTADO    -> Nome do estado
      CD_CIDADE -> Cód IBGE da cidade
      CIDADE    -> Nome da cidade
      CEP       -> Cep
      LOGRAD    -> Logradouro
      BAIRRO    -> Bairro
      NUM       -> Número
      COMPL     -> Complemento
      */
      aux_ds_retorno     varchar2(256);
      aux_cd_pais        pessoa_endereco.cd_pais%type;
      aux_cd_estado      pessoa_endereco.cd_estado%type;
      aux_cd_cidade      pessoa_endereco.cd_cidade%type;
      aux_nr_cep         pessoa_endereco.nr_cep%type;
      aux_ds_logradouro  pessoa_endereco.ds_logradouro%type;
      aux_ds_bairro      pessoa_endereco.ds_bairro%type;
      aux_ds_numero      pessoa_endereco.ds_numero%type;
      aux_ds_complemento pessoa_endereco.ds_complemento%type;
    begin
      p_buscar_endereco(prm_cd_pessoa      => prm_cd_pessoa,
                        prm_nr_endereco    => prm_nr_sequencia,
                        prm_cd_pais        => aux_cd_pais,
                        prm_cd_estado      => aux_cd_estado,
                        prm_cd_cidade      => aux_cd_cidade,
                        prm_nr_cep         => aux_nr_cep,
                        prm_ds_logradouro  => aux_ds_logradouro,
                        prm_ds_bairro      => aux_ds_bairro,
                        prm_ds_numero      => aux_ds_numero,
                        prm_ds_complemento => aux_ds_complemento);
      
      if prm_ds_opcao = 'CD_PAIS' then
        return aux_cd_pais;
      elsif prm_ds_opcao = 'PAIS' then
        select p.ds_pais
          into aux_ds_retorno
          from pais p
         where p.cd_pais = aux_cd_pais;
        return aux_ds_retorno;
      end if;
      return null;
    end f_buscar_end;
    
  procedure p_salvar(prm_cd_pessoa       in out pessoa.cd_pessoa%type,
                     prm_dm_tipo         in pessoa.dm_tipo%type,
                     prm_ds_nome         in pessoa.ds_nome%type,
                     prm_ds_fantasia     in pessoa.ds_fantasia%type,
                     prm_ds_nome_social  in pessoa.ds_nome_social%type,
                     prm_dt_nascimento   in pessoa.dt_nascimento%type,
                     prm_dm_sexo         in pessoa.dm_sexo%type,
                     prm_dm_estado_civil in pessoa.dm_estado_civil%type)
    is
    begin
      if prm_cd_pessoa is null then
        insert
          into pessoa
              (dm_tipo,
               ds_nome,
               ds_fantasia,
               ds_nome_social,
               dt_nascimento,
               dm_sexo,
               dm_estado_civil,
               dt_cadastro)
        values(prm_dm_tipo,
               prm_ds_nome,
               prm_ds_fantasia,
               prm_ds_nome_social,
               prm_dt_nascimento,
               prm_dm_sexo,
               prm_dm_estado_civil,
               sysdate)
        returning cd_pessoa into prm_cd_pessoa;
      else
        update pessoa p
           set p.dm_tipo         = prm_dm_tipo,
               p.ds_nome         = prm_ds_nome,
               p.ds_fantasia     = prm_ds_fantasia,
               p.ds_nome_social  = prm_ds_nome_social,
               p.dt_nascimento   = prm_dt_nascimento,
               p.dm_sexo         = prm_dm_sexo,
               p.dm_estado_civil = prm_dm_estado_civil
         where p.cd_pessoa = prm_cd_pessoa;
      end if;
    end;
  
  procedure p_salvar_doc(prm_cd_pessoa    pessoa.cd_pessoa%type,
                         prm_cd_documento pessoa_documento.cd_documento%type,
                         prm_ds_documento pessoa_documento.ds_documento%type)
    is
      aux_nr_cont number;
    begin
      select count(1)
        into aux_nr_cont
        from pessoa_documento pd
       where pd.cd_pessoa    = prm_cd_pessoa
         and pd.cd_documento = prm_cd_documento;
      
      if nvl(aux_nr_cont, 0) = 0 then
        insert
          into pessoa_documento
              (cd_pessoa,
               cd_documento,
               ds_documento)
        values(prm_cd_pessoa,
               prm_cd_documento,
               prm_ds_documento);
      else
        update pessoa_documento pd
           set pd.ds_documento = prm_ds_documento
         where pd.cd_pessoa    = prm_cd_pessoa
           and pd.cd_documento = prm_cd_documento;
      end if;
      
    end;
  
  procedure p_salvar_doc(prm_cd_pessoa    pessoa.cd_pessoa%type,
                         prm_cd_documento pessoa_documento.cd_documento%type,
                         prm_ds_documento pessoa_documento.ds_documento%type,
                         prm_dm_status    varchar2)
    is
    begin
      if prm_dm_status = 'D' then
        delete
          from pessoa_documento pd
         where pd.cd_pessoa    = prm_cd_pessoa
           and pd.cd_documento = prm_cd_documento;
      else
        k_pessoa.p_salvar_doc(prm_cd_pessoa    => prm_cd_pessoa,
                              prm_cd_documento => prm_cd_documento,
                              prm_ds_documento => prm_ds_documento);
      end if;
    end;
  
  procedure p_salvar_cont(prm_nr_sequencia in out pessoa_contato.nr_sequencia%type,
                          prm_cd_pessoa    in pessoa.cd_pessoa%type,
                          prm_dm_tipo      in pessoa_contato.dm_tipo%type,
                          prm_ds_contato   in pessoa_contato.ds_contato%type)
    is
    begin
      if prm_nr_sequencia is null then
        insert
          into pessoa_contato
              (cd_pessoa,
               dm_tipo,
               ds_contato)
        values(prm_cd_pessoa,
               prm_dm_tipo,
               prm_ds_contato)
        returning nr_sequencia 
             into prm_nr_sequencia;
      else
        update pessoa_contato pc
           set pc.dm_tipo    = prm_dm_tipo,
               pc.ds_contato = prm_ds_contato
         where pc.nr_sequencia = prm_nr_sequencia;
      end if;
    end;
    
  procedure p_salvar_cont(prm_nr_sequencia in out pessoa_contato.nr_sequencia%type,
                          prm_cd_pessoa    in pessoa.cd_pessoa%type,
                          prm_dm_tipo      in pessoa_contato.dm_tipo%type,
                          prm_ds_contato   in pessoa_contato.ds_contato%type,
                          prm_ds_status    in varchar2)
    is
    begin
      if prm_ds_status = 'D' then
        delete
          from pessoa_contato pc
         where pc.nr_sequencia = prm_nr_sequencia;
      else
        k_pessoa.p_salvar_cont(prm_nr_sequencia => prm_nr_sequencia,
                               prm_cd_pessoa    => prm_cd_pessoa,
                               prm_dm_tipo      => prm_dm_tipo,
                               prm_ds_contato   => prm_ds_contato);
      end if;
    end;
  
  procedure p_salvar_end(prm_nr_sequencia   in out pessoa_endereco.nr_sequencia%type,
                         prm_cd_pessoa      in pessoa_endereco.cd_pessoa%type,
                         prm_cd_pais        in pessoa_endereco.cd_pais%type,
                         prm_cd_estado      in pessoa_endereco.cd_estado%type,
                         prm_cd_cidade      in pessoa_endereco.cd_cidade%type,
                         prm_nr_cep         in pessoa_endereco.nr_cep%type,
                         prm_ds_logradouro  in pessoa_endereco.ds_logradouro%type,
                         prm_ds_bairro      in pessoa_endereco.ds_bairro%type,
                         prm_ds_numero      in pessoa_endereco.ds_numero%type,
                         prm_ds_complemento in pessoa_endereco.ds_complemento%type,
                         prm_dm_situacao    in pessoa_endereco.dm_situacao%type)
    is
    begin
      if prm_nr_sequencia is null then
        insert
          into pessoa_endereco
              (cd_pessoa,
               cd_pais,
               cd_estado,
               cd_cidade,
               nr_cep,
               ds_logradouro,
               ds_bairro,
               ds_numero,
               ds_complemento,
               dm_situacao)
        values(prm_cd_pessoa,
               prm_cd_pais,
               prm_cd_estado,
               prm_cd_cidade,
               prm_nr_cep,
               prm_ds_logradouro,
               prm_ds_bairro,
               prm_ds_numero,
               prm_ds_complemento,
               prm_dm_situacao)
        returning nr_sequencia
             into prm_nr_sequencia;
      else
        update pessoa_endereco pe
           set pe.cd_pais        = prm_cd_pais,
               pe.cd_estado      = prm_cd_estado,
               pe.cd_cidade      = prm_cd_cidade,
               pe.nr_cep         = prm_nr_cep,
               pe.ds_logradouro  = prm_ds_logradouro,
               pe.ds_bairro      = prm_ds_bairro,
               pe.ds_numero      = prm_ds_numero,
               pe.ds_complemento = prm_ds_complemento,
               pe.dm_situacao    = prm_dm_situacao
         where pe.nr_sequencia = prm_nr_sequencia;
      end if;
    end;
  
  procedure p_salvar_end(prm_nr_sequencia   in out pessoa_endereco.nr_sequencia%type,
                         prm_cd_pessoa      in pessoa_endereco.cd_pessoa%type,
                         prm_cd_pais        in pessoa_endereco.cd_pais%type,
                         prm_cd_estado      in pessoa_endereco.cd_estado%type,
                         prm_cd_cidade      in pessoa_endereco.cd_cidade%type,
                         prm_nr_cep         in pessoa_endereco.nr_cep%type,
                         prm_ds_logradouro  in pessoa_endereco.ds_logradouro%type,
                         prm_ds_bairro      in pessoa_endereco.ds_bairro%type,
                         prm_ds_numero      in pessoa_endereco.ds_numero%type,
                         prm_ds_complemento in pessoa_endereco.ds_complemento%type,
                         prm_dm_situacao    in pessoa_endereco.dm_situacao%type,
                         prm_dm_status      in varchar2)
    is
    begin
      if prm_dm_status = 'D' then
        delete
          from pessoa_endereco pe
         where pe.nr_sequencia = prm_nr_sequencia;
      else
        k_pessoa.p_salvar_end(prm_nr_sequencia   => prm_nr_sequencia,
                              prm_cd_pessoa      => prm_cd_pessoa,
                              prm_cd_pais        => prm_cd_pais,
                              prm_cd_estado      => prm_cd_estado,
                              prm_cd_cidade      => prm_cd_cidade,
                              prm_nr_cep         => prm_nr_cep,
                              prm_ds_logradouro  => prm_ds_logradouro,
                              prm_ds_bairro      => prm_ds_bairro,
                              prm_ds_numero      => prm_ds_numero,
                              prm_ds_complemento => prm_ds_complemento,
                              prm_dm_situacao    => prm_dm_situacao);
      end if;
    end;

end k_pessoa;
/
