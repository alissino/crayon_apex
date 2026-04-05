create or replace procedure p_gerar_arq_select(prm_cd_geracao geracao_prcsso.nr_sequencia%type)
is        
  aux_ds_select  processo.ds_select%type;
  aux_cd_cursor  integer;
  aux_qt_linhas  pls_integer;
  aux_qt_colunas pls_integer;
  aux_vt_desc    dbms_sql.desc_tab;
  aux_ds_coluna  varchar2(4000);
  aux_arquivo    t_arquivo;
  aux_nr_linha   number;
  
  
begin
  
  aux_arquivo := t_arquivo(prm_ds_nome     => 'arq_'||lpad(prm_cd_geracao, 10, '0'),
                           prm_ds_extencao => 'csv',
                           prm_ds_path     => null,
                           prm_ds_ora_dir  => 'DIR_TEMP');
  
  k_processo.p_buscar_select(prm_cd_geracao => prm_cd_geracao, 
                             prm_ds_select  => aux_ds_select);
  
  aux_cd_cursor := dbms_sql.open_cursor;
  dbms_sql.parse(aux_cd_cursor, aux_ds_select, dbms_sql.native);
  
  dbms_sql.describe_columns(aux_cd_cursor, aux_qt_colunas, aux_vt_desc);
  
  for col in 1 .. aux_qt_colunas loop
    dbms_sql.define_column(aux_cd_cursor, col, aux_ds_coluna, 4000);
  end loop;
  
  for rec_param in (select gpp.nr_seq_param nr_param
                      from geracao_prcsso_prm gpp
                     where gpp.nr_seq_geracao = prm_cd_geracao) 
  loop
    declare
      aux_ds_param geracao_prcsso_prm.ds_valor%type;
      aux_ds_bind  varchar2(11);
    begin
      k_processo.p_buscar_prm(prm_cd_geracao   => prm_cd_geracao,
                              prm_nr_sequencia => rec_param.nr_param,
                              prm_ds_valor     => aux_ds_param);
      aux_ds_bind := ':'||rec_param.nr_param;
      
      dbms_sql.bind_variable(aux_cd_cursor, aux_ds_bind, aux_ds_param);
      
    end;
  end loop;
  
  aux_qt_linhas := dbms_sql.execute(aux_cd_cursor);
  
  /* Monta o cabeçalho */
  for cab in 1 .. aux_qt_colunas loop
    if cab = 1 then
      aux_arquivo.p_add_linha(aux_vt_desc(cab).col_name, aux_nr_linha);
    else
      aux_arquivo.p_acr_linha(';'||aux_vt_desc(cab).col_name, aux_nr_linha);
    end if;
  end loop;
  
  /* dados do select */
  while dbms_sql.fetch_rows(aux_cd_cursor) > 0 loop
    aux_ds_coluna := '';
    
    for col in 1 .. aux_qt_colunas loop
      dbms_sql.column_value(aux_cd_cursor, col, aux_ds_coluna);
      if col = 1 then
        aux_arquivo.p_add_linha(aux_ds_coluna, aux_nr_linha);
      else
        aux_arquivo.p_acr_linha(';'||aux_ds_coluna, aux_nr_linha);
      end if;
    end loop;
  end loop;
  
  dbms_sql.close_cursor(aux_cd_cursor);
  
  aux_arquivo.p_salvar;
  
  aux_arquivo.p_criar;
  
  k_processo.p_salvar_arquivo(prm_cd_geracao => prm_cd_geracao,
                              prm_cd_arquivo => aux_arquivo.cd_arquivo);
  
  commit;

exception
  when others then
    if dbms_sql.is_open(aux_cd_cursor) then
      dbms_sql.close_cursor(aux_cd_cursor);
    end if;
    k_processo.p_salvar_erro(prm_cd_geracao => prm_cd_geracao,
                             prm_ds_erro    => sqlerrm||dbms_utility.format_error_backtrace);
  
end p_gerar_arq_select;
/
