create or replace package k_valid is

  procedure p_gerar_trigger(prm_cd_tabela varchar2);
  
  procedure p_validar(prm_tp_valid t_valid);

end k_valid;
/
create or replace package body k_valid is

  procedure p_gerar_trigger(prm_cd_tabela varchar2)
    is
      cursor cur_col is
      select utc.column_name
        from user_tab_cols utc
       where utc.table_name = prm_cd_tabela
         and utc.data_type in ('VARCHAR2', 'VARCHAR', 'CHAR', 'NUMBER', 'INTEGER', 'DATE')
      order by utc.column_id;
      
      type typ_vt_cols is table of varchar2(100);
      
      aux_vt_cols    typ_vt_cols;
      aux_ds_trigger varchar2(32000);
    begin
      aux_ds_trigger := 'create or replace trigger tgv_'||lower(prm_cd_tabela)||chr(13)||
                        '  after insert or update or delete on '||lower(prm_cd_tabela)||chr(13)||
                        '  for each row'||chr(13)||
                        'declare'||chr(13)||
                        '  aux_valid t_valid := t_valid('''||prm_cd_tabela||''', inserting, updating, deleting);'||chr(13)||
                        'begin'||chr(13);
      open  cur_col;
      fetch cur_col bulk collect into aux_vt_cols;
      close cur_col;
      
      for aux_nr in 1 .. aux_vt_cols.count loop
        aux_ds_trigger := aux_ds_trigger||
                          '  aux_valid.p_add_coluna('''||aux_vt_cols(aux_nr)||
                          ''', :old.'||aux_vt_cols(aux_nr)||
                          ', :new.'||aux_vt_cols(aux_nr)||');'||chr(13);
      end loop;
      
      aux_ds_trigger := aux_ds_trigger||
                        '  aux_valid.p_validar;'||chr(13)||
                        'end;';
      
      execute immediate aux_ds_trigger;
      
    end p_gerar_trigger;
    
  procedure p_valid_dominio(prm_cd_dominio dominio_valor.cd_dominio%type,
                            prm_ds_valor   dominio_valor.ds_valor%type)
    is
    begin
      if prm_cd_dominio is null then
        return;
      end if;
      
      k_dominio.p_validar_valor(prm_cd_dominio => prm_cd_dominio, 
                                prm_ds_valor   => prm_ds_valor);
      
    end p_valid_dominio;
  
  procedure p_valid_regra(prm_tp_coluna t_valid_col,
                          prm_tp_valid  t_valid)
    is
      cursor cur_valid is 
      select vt.ds_validacao,
             vt.ds_sql,
             vt.ds_valores
        from valid_tab vt
       where vt.cd_tabela   = prm_tp_coluna.cd_tabela
         and vt.cd_coluna   = prm_tp_coluna.cd_coluna
         and vt.dm_situacao = 'A';
         
      type typ_vt_valid is table of cur_valid%rowtype;
      aux_vt_valid  typ_vt_valid;
      aux_valid     cur_valid%rowtype;
      
      aux_cd_cursor integer;
      aux_qt_linhas number;
      e_bind        exception;
      
      aux_tp_coluna t_valid_col;
      
      pragma exception_init(e_bind, -01006);
      pragma autonomous_transaction;
    begin
      open  cur_valid;
      fetch cur_valid bulk collect into aux_vt_valid;
      close cur_valid;

      for aux_nr_regra in 1 .. aux_vt_valid.count loop
        aux_valid := aux_vt_valid(aux_nr_regra);
        
        if aux_valid.ds_sql is not null then
          aux_cd_cursor := dbms_sql.open_cursor;
          dbms_sql.parse(aux_cd_cursor, aux_valid.ds_sql, dbms_sql.native);
          
          for aux_nr_col in 1 .. prm_tp_valid.vt_colunas.count loop
            aux_tp_coluna := prm_tp_valid.vt_colunas(aux_nr_col);
            begin
              dbms_sql.bind_variable(aux_cd_cursor, 
                                     ':'||aux_tp_coluna.cd_coluna,
                                     aux_tp_coluna.ds_valor_new);
            exception
              when e_bind then
                null;
              when others then
                raise;
            end;
          end loop;
          aux_qt_linhas := dbms_sql.execute(aux_cd_cursor);
          
        end if;
      end loop;
    exception
      when others then
        if cur_valid%isopen then
          close cur_valid;
        end if;
        if dbms_sql.is_open(aux_cd_cursor) then
          dbms_sql.close_cursor(aux_cd_cursor);
        end if;
        raise;
    end p_valid_regra;
  
  procedure p_validar(prm_tp_valid t_valid)
    is
      aux_coluna t_valid_col;
      aux_nr_col number;
    begin
      if prm_tp_valid.dm_operacao <> 'D' then
        for aux_nr_col in 1 .. prm_tp_valid.vt_colunas.count loop
          aux_coluna := prm_tp_valid.vt_colunas(aux_nr_col);
          p_valid_dominio(aux_coluna.f_buscar_dominio, aux_coluna.ds_valor_new);
          
          p_valid_regra(aux_coluna, prm_tp_valid);
          
        end loop;
      end if;
    exception
      when k_utils.e_regra_negocio then
        p_mostra_erro('Erro de validação.'||chr(13)||
                      'Tab: '||aux_coluna.cd_tabela||' Col: '||aux_coluna.cd_coluna||chr(13)||
                      'Erro: '||k_utils.f_trata_erro(sqlerrm));
      when others then
        raise;
    end p_validar;
    
end k_valid;
/
