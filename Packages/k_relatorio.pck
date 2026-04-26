create or replace package k_relatorio 
is
  
  type typ_vt_params is table of geracao_prcsso_prm.ds_valor%type;
  
  procedure p_gerar_relat_prcsso(prm_cd_geracao geracao_prcsso.nr_sequencia%type);
  
  procedure p_gerar_relatorio(prm_cd_relatorio relatorio.cd_relatorio%type,
                              prm_vt_params    typ_vt_params,
                              prm_cd_dir       varchar2,
                              prm_ds_arquivo   varchar2);

  procedure p_criar_prcsso_rel(prm_cd_relatorio relatorio.cd_relatorio%type,
                               prm_ds_nome_rel  relatorio.ds_nome%type,
                               prm_cd_processo  out relatorio.cd_processo%type);
                               
  procedure p_config_prcsso(prm_cd_relatorio in relatorio.cd_relatorio%type,
                            prm_ds_nome_rel  in relatorio.ds_nome%type,
                            prm_cd_processo  in out relatorio.cd_processo%type);
                            
  function f_get_val_itens_pagina(prm_nr_sequencia relatorio_pagina.nr_sequencia%type)
    return varchar2;
  
  procedure p_gerar_campos_secao(prm_nr_seq_secao relatorio_secao.cd_rel_secao%type);

end k_relatorio;
/
create or replace package body k_relatorio 
is
  type typ_vt_coluna is table of varchar2(256) index by varchar2(45);
  type typ_vt_result is table of typ_vt_coluna;
  
  function f_texto(prm_ds_texto varchar2)
    return varchar2
    is
    begin
      return convert(prm_ds_texto, 'WE8ISO8859P1', 'AL32UTF8');
    end;

  procedure p_exec_sql(prm_ds_sql    varchar2,
                       prm_vt_prm    typ_vt_params,
                       prm_vt_result out nocopy typ_vt_result)
    is
      aux_cd_cursor  integer;
      aux_ds_status  pls_integer;
      aux_qt_colunas pls_integer;
      aux_vt_desc    dbms_sql.desc_tab;
      aux_ds_coluna  varchar2(4000);
      aux_vt_coluna  typ_vt_coluna;
      aux_nr_linha   pls_integer := 1;
    begin
      aux_cd_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(aux_cd_cursor, prm_ds_sql, dbms_sql.native);
      dbms_sql.describe_columns(aux_cd_cursor, aux_qt_colunas, aux_vt_desc);
      
      for col in 1 .. aux_qt_colunas loop
        dbms_sql.define_column(aux_cd_cursor, col, aux_ds_coluna, 256);
      end loop;
      
      for prm in 1 .. prm_vt_prm.count loop
        begin
          dbms_sql.bind_variable(aux_cd_cursor, ':'||prm, prm_vt_prm(prm));
        exception
          when others then
            null;
        end;
      end loop;
      
      aux_ds_status := dbms_sql.execute(aux_cd_cursor);
      
      prm_vt_result := typ_vt_result();
      
      while dbms_sql.fetch_rows(aux_cd_cursor) > 0 loop
        aux_vt_coluna := typ_vt_coluna();
        for cab in 1 .. aux_qt_colunas loop
          dbms_sql.column_value(aux_cd_cursor, cab, aux_ds_coluna);
          aux_vt_coluna(aux_vt_desc(cab).col_name) := aux_ds_coluna;
        end loop;
        prm_vt_result.extend;
        prm_vt_result(aux_nr_linha) := aux_vt_coluna;
        aux_nr_linha := aux_nr_linha + 1;
      end loop;
      dbms_sql.close_cursor(aux_cd_cursor);
    exception
      when others then
        if dbms_sql.is_open(aux_cd_cursor) then
          dbms_sql.close_cursor(aux_cd_cursor);
        end if;
        p_mostra_erro('p_exec_sql'||sqlerrm);
    end;

  procedure p_gerar_relat_prcsso(prm_cd_geracao geracao_prcsso.nr_sequencia%type)
    is
      aux_cd_relatorio relatorio.cd_relatorio%type;
      aux_vt_params    typ_vt_params := typ_vt_params();
      aux_cd_dir_arq   geracao_prcsso_arq.cd_dir_oracle%type;
      aux_ds_arquivo   geracao_prcsso_arq.ds_nome%type;
      aux_ds_local     geracao_prcsso_arq.ds_local%type;
      aux_nr_seq_arq   geracao_prcsso_arq.nr_sequencia%type;
      cursor cur_params
          is select gpp.nr_seq_param,
                    nvl(gpp.ds_valor, pp.ds_val_padrao) ds_valor
               from geracao_prcsso_prm gpp,
                    geracao_prcsso     gp,
                    processo           p,
                    processo_param     pp
              where gp.nr_sequencia    = gpp.nr_seq_geracao
                and p.cd_prcsso        = gp.cd_prcsso
                and pp.cd_prcsso       = p.cd_prcsso
                and gpp.nr_seq_geracao = prm_cd_geracao;
    begin
      select r.cd_relatorio
        into aux_cd_relatorio
        from processo       p,
             relatorio      r,
             geracao_prcsso gp
       where p.cd_prcsso     = r.cd_processo
         and gp.cd_prcsso    = p.cd_prcsso
         and gp.nr_sequencia = prm_cd_geracao;
      
      for rec_param in cur_params loop
        aux_vt_params.extend;
        aux_vt_params(rec_param.nr_seq_param) := rec_param.ds_valor;
      end loop;
      
      aux_cd_dir_arq := 'DIR_TEMP';
      aux_ds_arquivo := 'rel'||aux_cd_relatorio||'_'||prm_cd_geracao||'.pdf';
      
      p_gerar_relatorio(prm_cd_relatorio => aux_cd_relatorio,
                        prm_vt_params    => aux_vt_params,
                        prm_cd_dir       => aux_cd_dir_arq,
                        prm_ds_arquivo   => aux_ds_arquivo);
                        
      select d.directory_path
        into aux_ds_local
        from all_directories d
       where d.directory_name = aux_cd_dir_arq;
      
      k_processo.p_salvar_arquivo(prm_cd_geracao    => prm_cd_geracao,
                                  prm_cd_dir_oracle => aux_cd_dir_arq,
                                  prm_ds_local      => aux_ds_local,
                                  prm_ds_nome       => aux_ds_arquivo,
                                  prm_ds_conteudo   => null,
                                  prm_cd_seq        => aux_nr_seq_arq);
    
    exception
      when others then
        k_processo.p_salvar_erro(prm_cd_geracao, sqlerrm||dbms_utility.format_error_backtrace);
      
    end;
  
  procedure p_gerar_relatorio(prm_cd_relatorio relatorio.cd_relatorio%type,
                              prm_vt_params    typ_vt_params,
                              prm_cd_dir       varchar2,
                              prm_ds_arquivo   varchar2)
    is
      aux_param     varchar2(4000);
      aux_dm_orient relatorio.dm_orientacao%type;
      aux_dm_unid   relatorio.dm_unid_medida%type;
      aux_dm_pagina relatorio.dm_pagina%type;
      aux_ds_titulo relatorio.ds_nome%type;
      aux_nr_mar_s  relatorio.nr_margem_sup%type;
      aux_nr_mar_i  relatorio.nr_margem_inf%type;
      aux_nr_mar_e  relatorio.nr_margem_esq%type;
      aux_nr_mar_d  relatorio.nr_margem_dir%type;
      procedure p_gerar_sec_dados(prm_nr_seq_sec number)
        is
          cursor cur_colunas
              is select rsc.ds_label,
                        rsc.ds_origem,
                        rsc.nr_largura,
                        rsc.nr_altura,
                        rsc.dm_alinhamento,
                        rsc.dm_fonte,
                        rsc.nr_tamanho_fonte
                   from relatorio_secao_campo rsc
                  where rsc.cd_rel_secao = prm_nr_seq_sec;
          
          type typ_vt_cabecalho is table of cur_colunas%rowtype;
          
          aux_rc_coluna   cur_colunas%rowtype;
          aux_vt_cabcalho typ_vt_cabecalho;
          aux_ds_select   relatorio_secao.ds_sql%type;
          aux_vt_result   typ_vt_result;
          aux_nr_alt      pls_integer;
          
          aux_ds_cor_cab  relatorio_secao.ds_cor_cabecalho%type;
          aux_ds_cor_alt  relatorio_secao.ds_cor_alterna%type;
        begin
          
          select nvl(rs.ds_sql, r.ds_sql),
                 rs.ds_cor_cabecalho,
                 rs.ds_cor_alterna
            into aux_ds_select,
                 aux_ds_cor_cab,
                 aux_ds_cor_alt
            from relatorio_secao rs,
                 relatorio       r
           where r.cd_relatorio  = rs.cd_relatorio
             and rs.cd_rel_secao = prm_nr_seq_sec;
          
          open  cur_colunas;
          fetch cur_colunas bulk collect into aux_vt_cabcalho;
          close cur_colunas;
        
          for cab in 1 .. aux_vt_cabcalho.count loop
            aux_rc_coluna := aux_vt_cabcalho(cab);
            pl_fpdf.SetFillColor(f_cor_hex_rgb(aux_ds_cor_cab, 'r'),
                                 f_cor_hex_rgb(aux_ds_cor_cab, 'g'),
                                 f_cor_hex_rgb(aux_ds_cor_cab, 'b'));
            pl_fpdf.SetFont(pfamily => aux_rc_coluna.dm_fonte,
                            psize  => aux_rc_coluna.nr_tamanho_fonte);
            pl_fpdf.Cell(pw      => aux_rc_coluna.nr_largura,
                         ph      => aux_rc_coluna.nr_altura,
                         ptxt    => f_texto(aux_rc_coluna.ds_label),
                         pborder => 1,
                         palign  => aux_rc_coluna.dm_alinhamento,
                         pfill   => 1);
            aux_nr_alt := aux_rc_coluna.nr_altura;
          end loop;
          
          pl_fpdf.SetFillColor(0);
          
          p_exec_sql(prm_ds_sql    => aux_ds_select,
                     prm_vt_prm    => prm_vt_params,
                     prm_vt_result => aux_vt_result);
          
          for ln in 1 .. aux_vt_result.count loop
            pl_fpdf.Ln(aux_nr_alt);
            pl_fpdf.SetFillColor(f_cor_hex_rgb(aux_ds_cor_alt, 'r'),
                                 f_cor_hex_rgb(aux_ds_cor_alt, 'g'),
                                 f_cor_hex_rgb(aux_ds_cor_alt, 'b'));
            for col in 1 .. aux_vt_cabcalho.count loop
              aux_rc_coluna := aux_vt_cabcalho(col);
              pl_fpdf.SetFont(pfamily => aux_rc_coluna.dm_fonte,
                              psize   => aux_rc_coluna.nr_tamanho_fonte);
              pl_fpdf.Cell(pw     => aux_rc_coluna.nr_largura,
                           ph     => aux_rc_coluna.nr_altura,
                           ptxt   => f_texto(aux_vt_result(ln)(upper(aux_rc_coluna.ds_origem))),
                           palign => aux_rc_coluna.dm_alinhamento,
                           pfill  => case mod(ln, 2)
                                       when 1 then 0
                                       else 1
                                     end);
            end loop;
          end loop;
          
        end;
      
    begin
      
      select r.dm_orientacao,
             r.dm_unid_medida,
             r.dm_pagina,
             r.ds_nome
        into aux_dm_orient,
             aux_dm_unid,
             aux_dm_pagina,
             aux_ds_titulo
        from relatorio r
       where r.cd_relatorio = prm_cd_relatorio;
      
      PL_FPDF.Init(p_orientation => aux_dm_orient,
                   p_unit        => aux_dm_unid,
                   p_format      => aux_dm_pagina);
      PL_FPDF.AddPage();
      pl_fpdf.SetUTF8Enabled(true);
      
      for secao in (select *
                      from relatorio_secao rs
                     where rs.cd_relatorio = prm_cd_relatorio)
      loop
        if secao.dm_tipo = 'D' then
          p_gerar_sec_dados(secao.cd_rel_secao);
        end if;
      end loop;
      
      pl_fpdf.SetTitle(aux_ds_titulo);
      pl_fpdf.SetCreator('Crayon (PL/SQL, PL_FPDF)');

      -- Salvar em diretório Oracle
      PL_FPDF.OutputFile(prm_ds_arquivo, prm_cd_dir);

      PL_FPDF.Reset();
    end;

  procedure p_criar_prcsso_rel(prm_cd_relatorio relatorio.cd_relatorio%type,
                               prm_ds_nome_rel  relatorio.ds_nome%type,
                               prm_cd_processo  out relatorio.cd_processo%type)
    is
      aux_cd_rotina processo.cd_rotina%type;
    begin
      prm_cd_processo := 'prcsso_relat_'||prm_cd_relatorio;
      aux_cd_rotina   := k_parametro.f_valor('rotina_padrao_gerar_rel');
      
      insert
        into processo
            (cd_prcsso,
             ds_prcsso,
             cd_rotina)
      values(prm_cd_processo,
             prm_ds_nome_rel,
             aux_cd_rotina);
      
      update relatorio r
         set r.cd_processo = prm_cd_processo
       where r.cd_relatorio = prm_cd_relatorio;
      
      commit;
    end;
  
  procedure p_config_prcsso(prm_cd_relatorio in relatorio.cd_relatorio%type,
                            prm_ds_nome_rel  in relatorio.ds_nome%type,
                            prm_cd_processo  in out relatorio.cd_processo%type)
    is
      aux_ds_url varchar2(32767);
    begin
      if prm_cd_processo is null then
        p_criar_prcsso_rel(prm_cd_relatorio => prm_cd_relatorio,
                           prm_ds_nome_rel  => prm_ds_nome_rel,
                           prm_cd_processo  => prm_cd_processo);
      end if;
      
      aux_ds_url := apex_page.get_url(p_page   => 11,
                                      p_items  => 'P11_CD_PRCSSO',
                                      p_values => prm_cd_processo);
      
      apex_util.redirect_url(aux_ds_url);
      
    end;
  
  function f_get_val_itens_pagina(prm_nr_sequencia relatorio_pagina.nr_sequencia%type)
    return varchar2
    is
      cursor cur_params
          is select rpp.cd_item_apex,
                    rpp.nr_seq_prcsso_prm
               from relatorio_pagina_param rpp
              where rpp.nr_seq_relat_pag = prm_nr_sequencia
              order by rpp.nr_seq_prcsso_prm;
      
      aux_ds_valores varchar2(32767);
    begin
      for prm in cur_params loop
        if prm.nr_seq_prcsso_prm > 1 then
          aux_ds_valores := aux_ds_valores || k_processo.cns_ds_sep;
        end if;
        aux_ds_valores := aux_ds_valores || apex_util.get_session_state(prm.cd_item_apex);
      end loop;
      
      return aux_ds_valores;
    end;
  
  procedure p_gerar_campos_secao(prm_nr_seq_secao relatorio_secao.cd_rel_secao%type)
    is
      aux_cd_cursor integer;
      aux_ds_select relatorio_secao.ds_sql%type;
      aux_vt_desc   dbms_sql.desc_tab;
      aux_qt_col    pls_integer;
      aux_nr_ordem  pls_integer := 10;
    begin
      select nvl(rs.ds_sql, r.ds_sql)
        into aux_ds_select
        from relatorio_secao rs,
             relatorio       r
       where r.cd_relatorio  = rs.cd_relatorio
         and rs.cd_rel_secao = prm_nr_seq_secao;
      
      if aux_ds_select is null then
        p_mostra_erro('Não há SQL na seção ou relatório.');
      end if;
      
      aux_cd_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(aux_cd_cursor, aux_ds_select, dbms_sql.native);
      dbms_sql.describe_columns(aux_cd_cursor, aux_qt_col, aux_vt_desc);
      dbms_sql.close_cursor(aux_cd_cursor);
      
      for col in 1 .. aux_qt_col loop
        insert
          into relatorio_secao_campo
              (cd_rel_secao,
               nr_ordem,
               dm_tipo_campo,
               ds_origem,
               ds_label,
               nr_posicao_x,
               nr_posicao_y,
               nr_largura,
               nr_altura,
               dm_alinhamento,
               ds_mascara,
               dm_fonte,
               nr_tamanho_fonte,
               dm_estilo_fonte,
               fg_borda_sup,
               fg_borda_inf,
               fg_borda_esq,
               fg_borda_dir)
        values(prm_nr_seq_secao,
               aux_nr_ordem,
               'C',
               aux_vt_desc(col).col_name,
               aux_vt_desc(col).col_name,
               null,
               null,
               10,
               8,
               k_dominio.f_val_padrao('relatorio_secao_campo', 'dm_alinhamento'),
               null,
               k_dominio.f_val_padrao('relatorio_secao_campo', 'dm_fonte'),
               10,
               k_dominio.f_val_padrao('relatorio_secao_campo', 'dm_estilo_fonte'),
               k_dominio.f_val_padrao('relatorio_secao_campo', 'fg_borda_sup'),
               k_dominio.f_val_padrao('relatorio_secao_campo', 'fg_borda_inf'),
               k_dominio.f_val_padrao('relatorio_secao_campo', 'fg_borda_esq'),
               k_dominio.f_val_padrao('relatorio_secao_campo', 'fg_borda_dir'));
        aux_nr_ordem := aux_nr_ordem + 10;
      end loop;
      
      commit;
    exception
      when others then
        if dbms_sql.is_open(aux_cd_cursor) then
          dbms_sql.close_cursor(aux_cd_cursor);
        end if;
        raise;
    end;

end k_relatorio;
/
