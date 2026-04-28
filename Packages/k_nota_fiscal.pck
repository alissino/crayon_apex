create or replace package k_nota_fiscal is

  procedure p_incluir_nf(prm_cd_nota    in out nota_fiscal.cd_nota%type,
                         prm_cd_estab   in nota_fiscal.cd_estab%type,
                         prm_cd_pessoa  in nota_fiscal.cd_pessoa%type,
                         prm_dt_emissao in nota_fiscal.dt_emissao%type,
                         prm_cd_cfop    in nota_fiscal.cd_cfop%type,
                         prm_cd_modelo  in nota_fiscal.cd_modelo_doc%type);
  
  procedure p_salvar_item(prm_cd_item    in out nota_fiscal_item.cd_nf_item%type,
                          prm_cd_nota    in nota_fiscal_item.cd_nota%type,
                          prm_cd_produto in nota_fiscal_item.cd_produto%type,
                          prm_qt_produto in nota_fiscal_item.qt_produto%type);
  
  procedure p_calc_nf(prm_cd_nota nota_fiscal.cd_nota%type);
  
  
  procedure p_buscar_dados_nota(prm_cd_nota            in  nota_fiscal.cd_nota%type,
                                prm_nr_serie           out nota_fiscal.nr_serie%type,
                                prm_nr_numero          out nota_fiscal.nr_numero%type,
                                prm_dm_status          out nota_fiscal.dm_status%type,
                                prm_dm_tipo_operacao   out nota_fiscal.dm_tipo_operacao%type,
                                prm_dt_emissao         out nota_fiscal.dt_emissao%type,
                                prm_dt_saida           out nota_fiscal.dt_saida%type,
                                prm_ds_estab           out varchar2,
                                prm_ds_cnpj_estab      out varchar2,
                                prm_ds_pessoa          out varchar2,
                                prm_ds_doc_pessoa      out varchar2,
                                prm_ds_cfop            out varchar2,
                                prm_ds_chave_acesso    out nota_fiscal.ds_chave_acesso%type,
                                prm_ds_protocolo_autor out nota_fiscal.ds_protocolo_autor%type,
                                prm_ds_modelo_doc      out varchar2);
  
  procedure p_buscar_totais_nota(prm_cd_nota       in  nota_fiscal.cd_nota%type,
                                 prm_vl_tot_nota   out number,
                                 prm_vl_tot_prod   out number,
                                 prm_vl_tot_icms   out number,
                                 prm_vl_tot_cofins out number,
                                 prm_vl_tot_pis    out number,
                                 prm_vl_tot_impos  out number);
                                 
  

end k_nota_fiscal;
/
create or replace package body k_nota_fiscal is
  -- Protected
  
  function f_gerar_chave(prm_cd_nota  nota_fiscal.cd_nota%type,
                         prm_dm_emiss varchar2 default 1)
    return nota_fiscal.ds_chave_acesso%type
    is
      aux_ds_chave nota_fiscal.ds_chave_acesso%type;
      
      aux_cd_estado  estado.cd_estado%type;
      aux_dt_emissao nota_fiscal.dt_emissao%type;
      aux_ds_cnpj    pessoa_documento.ds_documento%type;
      aux_cd_modelo  nota_fiscal.cd_modelo_doc%type;
      aux_nr_serie   nota_fiscal.nr_serie%type;
      aux_nr_numero  nota_fiscal.nr_numero%type;
      aux_nr_random  number(8) := dbms_random.value(10000000, 99999999);
      aux_nr_dv      number(1);
      
      function calcular_dv(p_chave varchar2) 
        return number 
        is
          v_soma number := 0;
          v_peso number := 2;
        begin
          for i in reverse 1 .. length(p_chave) loop
            v_soma := v_soma + to_number(substr(p_chave, i, 1)) * v_peso;
            v_peso := v_peso + 1;
            if v_peso > 9 then
                v_peso := 2;
            end if;
          end loop;

          v_soma := 11 - mod(v_soma, 11);

          if v_soma >= 10 then
            return 0;
          else
            return v_soma;
          end if;
        end;
      
    begin
      
      select k_pessoa.f_buscar_end(prm_cd_pessoa => k_empresa.f_buscar_cd_pess_estab(nf.cd_estab),
                                   prm_ds_opcao  => 'CD_ESTADO'),
             nf.dt_emissao,
             k_empresa.f_buscar_doc_estab(prm_cd_estab => nf.cd_estab,
                                          prm_cd_doc   => 'CNPJ',
                                          prm_vf_mask  => false),
             nf.nr_serie,
             nf.nr_numero,
             nf.cd_modelo_doc
        into aux_cd_estado,
             aux_dt_emissao,
             aux_ds_cnpj,
             aux_nr_serie,
             aux_nr_numero,
             aux_cd_modelo
        from nota_fiscal nf
       where nf.cd_nota = prm_cd_nota;
    
      aux_ds_chave := aux_cd_estado ||
                      to_char(aux_dt_emissao, 'RRMM') ||
                      aux_ds_cnpj ||
                      aux_cd_modelo ||
                      lpad(aux_nr_serie, 3, '0') ||
                      lpad(aux_nr_numero, 9, '0') ||
                      prm_dm_emiss ||
                      aux_nr_random;
      
      aux_ds_chave := aux_ds_chave || calcular_dv(aux_ds_chave);
      
      return aux_ds_chave;
      
    end f_gerar_chave;
  
  
  -- Sepecificação
  
  function f_buscar_estab_nota(prm_cd_nota nota_fiscal.cd_nota%type)
    return nota_fiscal.cd_estab%type
    is
      aux_cd_estab nota_fiscal.cd_estab%type;
    begin
      select nf.cd_estab
        into aux_cd_estab
        from nota_fiscal nf
       where nf.cd_nota = prm_cd_nota;
      return aux_cd_estab;
    end f_buscar_estab_nota;

  procedure p_incluir_nf(prm_cd_nota    in out nota_fiscal.cd_nota%type,
                         prm_cd_estab   in nota_fiscal.cd_estab%type,
                         prm_cd_pessoa  in nota_fiscal.cd_pessoa%type,
                         prm_dt_emissao in nota_fiscal.dt_emissao%type,
                         prm_cd_cfop    in nota_fiscal.cd_cfop%type,
                         prm_cd_modelo  in nota_fiscal.cd_modelo_doc%type)
    is
      aux_nr_numero   nota_fiscal.nr_numero%type;
      aux_nr_serie    nota_fiscal.nr_serie%type;
      aux_dm_operacao nota_fiscal.dm_tipo_operacao%type;
      aux_dm_status   nota_fiscal.dm_status%type   := 'DG';
      aux_vl_produtos nota_fiscal.vl_produtos%type := 0;
      aux_vl_nota     nota_fiscal.vl_nota%type     := 0;
      aux_ds_chave    nota_fiscal.ds_chave_acesso%type;
    begin
      k_empresa.p_buscar_num_serie_nf(prm_cd_estab  => prm_cd_estab,
                                      prm_nr_numero => aux_nr_numero,
                                      prm_nr_serie  => aux_nr_serie);
                                      
      aux_dm_operacao := k_cfop.f_buscar_dm_operacao(prm_cd_cfop);
      
      if prm_cd_nota is null then
        insert
          into nota_fiscal
              (cd_estab,
               cd_pessoa,
               nr_numero,
               nr_serie,
               dt_emissao,
               cd_cfop,
               dm_tipo_operacao,
               dm_status,
               vl_produtos,
               vl_nota,
               cd_modelo_doc)
        values(prm_cd_estab,
               prm_cd_pessoa,
               aux_nr_numero,
               aux_nr_serie,
               prm_dt_emissao,
               prm_cd_cfop,
               aux_dm_operacao,
               aux_dm_status,
               aux_vl_produtos,
               aux_vl_nota,
               prm_cd_modelo)
        returning cd_nota
             into prm_cd_nota;
        
        aux_ds_chave := f_gerar_chave(prm_cd_nota);
      
        update nota_fiscal nf
           set nf.ds_chave_acesso = aux_ds_chave
         where nf.cd_nota = prm_cd_nota;
        
      end if;
           
      
      
      
    
    end p_incluir_nf;
  
  procedure p_salvar_item(prm_cd_item    in out nota_fiscal_item.cd_nf_item%type,
                          prm_cd_nota    in nota_fiscal_item.cd_nota%type,
                          prm_cd_produto in nota_fiscal_item.cd_produto%type,
                          prm_qt_produto in nota_fiscal_item.qt_produto%type)
    is
      aux_nr_ordem   nota_fiscal_item.nr_ordem%type;
      aux_vl_produto nota_fiscal_item.vl_produto%type;
      aux_vl_total   nota_fiscal_item.vl_total%type;
      
      aux_cd_ncm     nota_fiscal_item.cd_ncm%type;
      aux_cd_cest    nota_fiscal_item.cd_cest%type;
      aux_cd_unid    nota_fiscal_item.cd_unidade%type;
      aux_ds_prod    nota_fiscal_item.ds_produto%type;
      
      aux_cd_estab   nota_fiscal.cd_estab%type;
      aux_dt_emiss   nota_fiscal.dt_emissao%type;
    begin
      
      if prm_cd_item is not null then
        return;
      end if;
      
      select max(nfi.nr_ordem)
        into aux_nr_ordem
        from nota_fiscal_item nfi
       where nfi.cd_nota = prm_cd_nota;
       
      select nf.cd_estab,
             nf.dt_emissao
        into aux_cd_estab,
             aux_dt_emiss
        from nota_fiscal nf
       where nf.cd_nota = prm_cd_nota;
      
      select pf.nr_ncm,
             pf.nr_cest,
             p.cd_unid_venda,
             p.ds_produto
        into aux_cd_ncm,
             aux_cd_cest,
             aux_cd_unid,
             aux_ds_prod
        from produto        p,
             produto_fiscal pf
       where pf.cd_produto(+) = p.cd_produto
         and p.cd_produto  = prm_cd_produto;
      
      aux_nr_ordem   := nvl(aux_nr_ordem, 0) + 1;
      aux_vl_produto := k_produto.f_buscar_preco(prm_cd_produto    => prm_cd_produto,
                                                 prm_cd_estab      => aux_cd_estab,
                                                 prm_dt_referencia => aux_dt_emiss);
      aux_vl_total   := aux_vl_produto * prm_qt_produto;
      
      insert
        into nota_fiscal_item
            (cd_nota,
             nr_ordem,
             cd_produto,
             vl_produto,
             qt_produto,
             vl_total,
             cd_ncm,
             cd_cest,
             cd_unidade,
             ds_produto)
      values(prm_cd_nota,
             aux_nr_ordem,
             prm_cd_produto,
             aux_vl_produto,
             prm_qt_produto,
             aux_vl_total,
             aux_cd_ncm,
             aux_cd_cest,
             aux_cd_unid,
             aux_ds_prod)
      returning cd_nf_item
           into prm_cd_item;
                                                 
    end p_salvar_item;
  
  procedure p_calc_nf(prm_cd_nota nota_fiscal.cd_nota%type)
    is
    begin
      null;
    end p_calc_nf;
    
  
  procedure p_buscar_dados_nota(prm_cd_nota            in  nota_fiscal.cd_nota%type,
                                prm_nr_serie           out nota_fiscal.nr_serie%type,
                                prm_nr_numero          out nota_fiscal.nr_numero%type,
                                prm_dm_status          out nota_fiscal.dm_status%type,
                                prm_dm_tipo_operacao   out nota_fiscal.dm_tipo_operacao%type,
                                prm_dt_emissao         out nota_fiscal.dt_emissao%type,
                                prm_dt_saida           out nota_fiscal.dt_saida%type,
                                prm_ds_estab           out varchar2,
                                prm_ds_cnpj_estab      out varchar2,
                                prm_ds_pessoa          out varchar2,
                                prm_ds_doc_pessoa      out varchar2,
                                prm_ds_cfop            out varchar2,
                                prm_ds_chave_acesso    out nota_fiscal.ds_chave_acesso%type,
                                prm_ds_protocolo_autor out nota_fiscal.ds_protocolo_autor%type,
                                prm_ds_modelo_doc      out varchar2)
    is
    begin
      select nf.nr_serie,
             nf.nr_numero,
             nf.dm_status,
             nf.dm_tipo_operacao,
             nf.dt_emissao,
             nf.dt_saida,
             nf.cd_estab || ' - ' || k_empresa.f_buscar_razao_social_estab(nf.cd_estab),
             k_pessoa.f_buscar_doc(prm_cd_pessoa    => k_empresa.f_buscar_cd_pess_estab(nf.cd_estab),
                                   prm_cd_documento => 'CNPJ',
                                   prm_vf_mask      => true),
             nf.cd_pessoa || ' - ' || k_pessoa.f_buscar_nome(nf.cd_pessoa),
             k_pessoa.f_buscar_doc(prm_cd_pessoa    => nf.cd_pessoa,
                                   prm_cd_documento => case k_pessoa.f_buscar_tipo(nf.cd_pessoa)
                                                         when 'PF' then 'CPF'
                                                         when 'PJ' then 'CNPJ'
                                                       end,
                                   prm_vf_mask      => true),
             nf.cd_cfop || ' - ' || k_cfop.f_buscar_desc(nf.cd_cfop),
             nf.ds_chave_acesso,
             nf.ds_protocolo_autor,
             (select nfm.cd_modelo||' - '||nfm.ds_descricao
                from nota_fiscal_modelo nfm
               where nfm.cd_modelo = nf.cd_modelo_doc)
        into prm_nr_serie,
             prm_nr_numero,
             prm_dm_status,
             prm_dm_tipo_operacao,
             prm_dt_emissao,
             prm_dt_saida,
             prm_ds_estab,
             prm_ds_cnpj_estab,
             prm_ds_pessoa,
             prm_ds_doc_pessoa,
             prm_ds_cfop,
             prm_ds_chave_acesso,
             prm_ds_protocolo_autor,
             prm_ds_modelo_doc
        from nota_fiscal nf
       where nf.cd_nota = prm_cd_nota;
    end p_buscar_dados_nota;
    
  procedure p_buscar_totais_nota(prm_cd_nota       in  nota_fiscal.cd_nota%type,
                                 prm_vl_tot_nota   out number,
                                 prm_vl_tot_prod   out number,
                                 prm_vl_tot_icms   out number,
                                 prm_vl_tot_cofins out number,
                                 prm_vl_tot_pis    out number,
                                 prm_vl_tot_impos  out number)
    is
    begin
      select v.vl_tot_nota,
             v.vl_tot_prod,
             v.vl_tot_icms,
             v.vl_tot_cofins,
             v.vl_tot_pis
        into prm_vl_tot_nota,
             prm_vl_tot_prod,
             prm_vl_tot_icms,
             prm_vl_tot_cofins,
             prm_vl_tot_pis
        from v_nota_fiscal_total v
       where v.cd_nota = prm_cd_nota;
      
      prm_vl_tot_impos := prm_vl_tot_icms + prm_vl_tot_cofins + prm_vl_tot_pis;
      
    end p_buscar_totais_nota;
  
end k_nota_fiscal;
/
