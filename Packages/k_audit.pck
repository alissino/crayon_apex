create or replace package k_audit is
  
  cns_ins     constant char(1)      := k_utils.cns_ins;
  cns_upd     constant char(1)      := k_utils.cns_upd;
  cns_del     constant char(1)      := k_utils.cns_del;
  cns_sep     constant char(1)      := ';';
  cns_mask_dt constant varchar2(22) := 'dd/mm/yyyy hh24:mi:ss';
  cns_owner   constant varchar2(20) := 'CRAYON';
  
  procedure p_gerar_trigger(prm_ds_tabela varchar2);
  
  procedure p_prcsso_gerar_trg(prm_cd_geracao geracao_prcsso.nr_sequencia%type);
  
  procedure p_prcsso_gerar_trg_todas(prm_cd_geracao geracao_prcsso.nr_sequencia%type);

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
    
  procedure p_prcsso_gerar_trg(prm_cd_geracao geracao_prcsso.nr_sequencia%type)
    is
      aux_ds_tabela audit_tab.ds_tabela%type;
    begin
      k_processo.p_buscar_prm(prm_cd_geracao, 1, aux_ds_tabela);
      
      k_audit.p_gerar_trigger(aux_ds_tabela);
    
    exception
      when others then
        k_processo.p_salvar_erro(prm_cd_geracao, sqlerrm);
      
    end;
  
  procedure p_prcsso_gerar_trg_todas(prm_cd_geracao geracao_prcsso.nr_sequencia%type)
    is
      aux_ds_tabelas varchar2(4000);
      aux_dm_todas   char(1);
      aux_vt_tabelas k_lista.typ_lista;
      aux_cd_geracao geracao_prcsso.nr_sequencia%type;
      aux_bl_erro    boolean;
    begin
      k_processo.p_buscar_prm(prm_cd_geracao, 1, aux_dm_todas);
      k_processo.p_buscar_prm(prm_cd_geracao, 2, aux_ds_tabelas);
      
      if aux_dm_todas = 'N' then
        k_lista.p_criar_lista(prm_ds_string    => aux_ds_tabelas,
                              prm_vt_lista     => aux_vt_tabelas,
                              prm_ds_separador => ',');
        
        for i in 1 .. aux_vt_tabelas.count loop
          k_processo.p_processar_agora(prm_cd_prcsso     => 'gerar_trigger_audit_tab',
                                       prm_cd_prcsso_ori => prm_cd_geracao,
                                       prm_ds_params     => aux_vt_tabelas(i),
                                       prm_cd_geracao    => aux_cd_geracao,
                                       prm_vf_erro       => aux_bl_erro);
        end loop;
        
      else
        for tab in (select u.table_name
                      from user_tables u
                     where u.table_name not in (select upper(column_value)
                                                  from table(k_parametro.f_valor_lista_pipe('tabelas_nao_gerar_trg_audit'))))
        loop
          k_processo.p_processar_agora(prm_cd_prcsso     => 'gerar_trigger_audit_tab',
                                       prm_cd_prcsso_ori => prm_cd_geracao,
                                       prm_ds_params     => tab.table_name,
                                       prm_cd_geracao    => aux_cd_geracao,
                                       prm_vf_erro       => aux_bl_erro);
        end loop;
      end if;
      
    end;
  
end k_audit;
/
