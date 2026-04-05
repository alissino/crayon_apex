create or replace package k_audit is
  
  cns_ins     constant char(1)      := k_utils.cns_ins;
  cns_upd     constant char(1)      := k_utils.cns_upd;
  cns_del     constant char(1)      := k_utils.cns_del;
  cns_sep     constant char(1)      := ';';
  cns_mask_dt constant varchar2(22) := 'dd/mm/yyyy hh24:mi:ss';
  cns_owner   constant varchar2(20) := 'CRAYON';
  
  procedure p_gerar_trigger(prm_ds_tabela varchar2);

end k_audit;
/
create or replace package body k_audit is

  procedure p_gerar_trigger(prm_ds_tabela varchar2)
    is
      cursor cur_col is
      select atc.column_name ds_coluna
        from all_tab_cols atc
       where atc.owner = cns_owner
         and atc.table_name = prm_ds_tabela
         and atc.data_type in ('VARCHAR2', 'VARCHAR', 'CHAR', 'NUMBER', 'INTEGER', 'DATE')
       order by atc.column_id;
       
      type typ_vt_cols is table of varchar(62);
      
      aux_vt_cols    typ_vt_cols;
      aux_ds_trigger varchar2(32000);
    begin
      
      aux_ds_trigger := 'create or replace trigger tga_'||lower(prm_ds_tabela)||chr(13)||
                        '  after insert or update or delete on '||lower(prm_ds_tabela)||chr(13)||
                        '  for each row'||chr(13)||
                        'declare'||chr(13)||
                        '  aux_audit t_audit := t_audit('''||prm_ds_tabela||''', inserting, updating, deleting);'||chr(13)||
                        'begin'||chr(13);
      open  cur_col;
      fetch cur_col bulk collect into aux_vt_cols;
      close cur_col;
      
      for col in 1 .. aux_vt_cols.count loop
        aux_ds_trigger := aux_ds_trigger||
                          '  aux_audit.p_add_coluna('''||aux_vt_cols(col)||
                          ''', :old.'||aux_vt_cols(col)||
                          ', :new.'||aux_vt_cols(col)||');'||chr(13);
      end loop;
      
      aux_ds_trigger := aux_ds_trigger||
                        '  aux_audit.p_salvar;'||chr(13)||
                        'end;';
      
      execute immediate aux_ds_trigger;
    
    end;
  
end k_audit;
/
