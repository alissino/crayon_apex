create or replace package k_listagem is
  
  type typ_rc_colunas is record (cd_coluna      listagem_coluna.cd_coluna%type,
                                 nr_ordem       listagem_coluna.nr_ordem%type,
                                 ds_coluna      listagem_coluna.ds_coluna%type,
                                 dm_alinhamento listagem_coluna.dm_alinhamento%type,
                                 dm_expandir    listagem_coluna.dm_expandir%type,
                                 qt_tamanho     listagem_coluna.qt_tamanho%type,
                                 ds_mascara     listagem_coluna.ds_mascara%type,
                                 cd_dominio     listagem_coluna.cd_dominio%type,
                                 dm_tipo        listagem_coluna.dm_tipo%type);
  type typ_vt_colunas is table of typ_rc_colunas;
                                 
  cursor cur_colunas (prm_cd_listagem in listagem_coluna.cd_listagem%type)
  return typ_rc_colunas;
  
  function f_buscar_sql(prm_cd_listagem listagem.cd_listagem%type)
    return listagem.ds_sql%type;

  procedure p_criar_colunas(prm_cd_listagem listagem.cd_listagem%type);
  
  procedure p_obter_dados(prm_cd_listagem in listagem.cd_listagem%type,
                          prm_ds_params   in k_lista.typ_string);
                          
  function f_buscar_colunas(prm_cd_listagem in listagem.cd_listagem%type)
    return typ_vt_colunas pipelined;
    
  function f_buscar_retorno(prm_cd_listagem in listagem.cd_listagem%type)
    return varchar2;

end k_listagem;
/
create or replace package body k_listagem 
  is
  
  type typ_vt_sqls is table of listagem.ds_sql%type index by listagem.cd_listagem%type;
  aux_vt_sqls typ_vt_sqls;
  
  cursor cur_colunas (prm_cd_listagem in listagem_coluna.cd_listagem%type)
  return typ_rc_colunas
      is select lc.cd_coluna,
                lc.nr_ordem,
                lc.ds_coluna,
                lc.dm_alinhamento,
                lc.dm_expandir,
                lc.qt_tamanho,
                lc.ds_mascara,
                lc.cd_dominio,
                lc.dm_tipo
           from listagem_coluna lc
          where lc.cd_listagem = prm_cd_listagem
          order by lc.nr_ordem;
  
  procedure p_binds_padrao(prm_cd_cursor in out integer)
    is
      e_bind exception;
      pragma exception_init(e_bind, -01006);
      aux_ds_valor varchar2(255);
    begin
      for rec_bind in (select lbp.cd_parametro,
                              lbp.ds_sql
                         from listagem_bind_padrao lbp)
      loop
        execute immediate rec_bind.ds_sql into aux_ds_valor;
        begin
          dbms_sql.bind_variable(prm_cd_cursor, 
                                 ':'||rec_bind.cd_parametro,
                                 aux_ds_valor);
        exception
          when e_bind then
            null;
          when others then
            raise;
        end;
      end loop;
    end p_binds_padrao;
  
  function f_buscar_sql(prm_cd_listagem listagem.cd_listagem%type)
    return listagem.ds_sql%type
    is
      aux_sql         listagem.ds_sql%type;
      aux_sql_dominio varchar2(32767);
    begin
      if not aux_vt_sqls.exists(prm_cd_listagem) then
        select l.ds_sql
          into aux_sql
          from listagem l
         where l.cd_listagem = prm_cd_listagem;
        
        aux_sql_dominio := 'select '||chr(13);
        for rec_coluna in (select lc.cd_coluna,
                                  lc.cd_dominio,
                                  row_number() over (order by lc.nr_ordem) nr_col
                             from listagem_coluna lc
                            where lc.cd_listagem = prm_cd_listagem
                            order by lc.nr_ordem)
        loop
          if rec_coluna.nr_col > 1 then
            aux_sql_dominio := aux_sql_dominio || ', ' || chr(13);
          end if;
          if rec_coluna.cd_dominio is null then
            aux_sql_dominio := aux_sql_dominio || rec_coluna.cd_coluna;
          else
            aux_sql_dominio := aux_sql_dominio || 'k_dominio.f_mask(''' 
                                               || rec_coluna.cd_dominio || ''', ' 
                                               || rec_coluna.cd_coluna || ') ' 
                                               || rec_coluna.cd_coluna;
          end if;
        end loop;
        
        aux_sql_dominio := rtrim(aux_sql_dominio, ', ' || chr(13));
        aux_sql_dominio := aux_sql_dominio || chr(13) || 'from ('||aux_sql||')';
        
        aux_vt_sqls(prm_cd_listagem) := aux_sql_dominio;
      end if;
      return aux_vt_sqls(prm_cd_listagem);
    end f_buscar_sql;

  procedure p_criar_colunas(prm_cd_listagem listagem.cd_listagem%type)
    is
      aux_cd_cursor  integer;
      aux_vt_colunas dbms_sql.desc_tab;
      aux_rc_coluna  dbms_sql.desc_rec;
      aux_qt_colunas number;
      aux_rc_col     listagem_coluna%rowtype;
    begin
      aux_cd_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(aux_cd_cursor,
                     f_buscar_sql(prm_cd_listagem),
                     dbms_sql.native);
      dbms_sql.describe_columns(aux_cd_cursor,
                                aux_qt_colunas,
                                aux_vt_colunas);
      
      delete
        from listagem_coluna lc
       where lc.cd_listagem = prm_cd_listagem;
      
      for aux_nr_col in 1 .. aux_qt_colunas loop
        aux_rc_coluna := aux_vt_colunas(aux_nr_col);
        aux_rc_col    := null;
        aux_rc_col.cd_listagem    := prm_cd_listagem;
        aux_rc_col.cd_coluna      := lower(aux_rc_coluna.col_name);
        aux_rc_col.nr_ordem       := aux_nr_col * 10;
        aux_rc_col.ds_coluna      := initcap(replace(aux_rc_col.cd_coluna, '_', ' '));
        aux_rc_col.dm_alinhamento := k_dominio.f_val_padrao(prm_cd_objeto   => 'listagem_coluna', 
                                                            prm_cd_atributo => 'dm_alinhamento');
        aux_rc_col.dm_expandir    := k_dominio.f_val_padrao(prm_cd_objeto   => 'listagem_coluna', 
                                                            prm_cd_atributo => 'dm_expandir');
        aux_rc_col.fg_retorno     := k_dominio.f_val_padrao(prm_cd_objeto   => 'listagem_coluna', 
                                                            prm_cd_atributo => 'fg_retorno');
        aux_rc_col.dm_tipo        := case aux_rc_coluna.col_type
                                       when 2 then 'NUMBER'
                                       when 12 then 'DATE'
                                       else 'VARCHAR2'
                                     end;
        
        insert
          into listagem_coluna
        values aux_rc_col;
        
      end loop;
      commit;
    end p_criar_colunas;
  
  procedure p_obter_dados(prm_cd_listagem in  listagem.cd_listagem%type,
                          prm_ds_params   in  k_lista.typ_string)
    is
      e_bind          exception;
      pragma exception_init(e_bind, -01006);
      aux_cd_cursor   integer;
      aux_cursor      sys_refcursor;
      aux_qt_linhas   number;
      aux_vt_params   k_lista.typ_lista;
      aux_ds_param    k_lista.typ_valor;
      aux_ds_variavel k_lista.typ_valor;
      aux_ds_valor    k_lista.typ_valor;
    begin
      aux_cd_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(aux_cd_cursor, f_buscar_sql(prm_cd_listagem), dbms_sql.native);
      -- Binds padrão sys
      p_binds_padrao(aux_cd_cursor);
      
      -- Bind nos parâmetros passados
      k_lista.p_criar_lista(prm_ds_string => prm_ds_params, prm_vt_lista  => aux_vt_params);
      for aux_nr_prm in 1 .. aux_vt_params.count loop
        aux_ds_param    := aux_vt_params(aux_nr_prm);
        aux_ds_variavel := ':'||substr(aux_ds_param, 1, instr(aux_ds_param, '=', -1, 1) - 1);
        aux_ds_valor    := substr(aux_ds_param, instr(aux_ds_param, '=', -1, 1) + 1);
        begin
          dbms_sql.bind_variable(aux_cd_cursor, aux_ds_variavel, aux_ds_valor);
        exception
          when e_bind then
            null;
          when others then
            raise;
        end;
      end loop;
      
      aux_qt_linhas := dbms_sql.execute(aux_cd_cursor);
      aux_cursor    := dbms_sql.to_refcursor(aux_cd_cursor);
      dbms_sql.return_result(aux_cursor);
    end p_obter_dados;
    
  function f_buscar_colunas(prm_cd_listagem in listagem.cd_listagem%type)
    return typ_vt_colunas pipelined
    is
    begin
      for aux_rc_col in cur_colunas(prm_cd_listagem => prm_cd_listagem) loop
        pipe row (aux_rc_col);
      end loop;
      return;
    end f_buscar_colunas;
  
  function f_buscar_retorno(prm_cd_listagem in listagem.cd_listagem%type)
    return varchar2
    is
      aux_lista varchar2(255);
    begin
      select listagg(lc.cd_coluna, ';') within group (order by lc.nr_ordem)
        into aux_lista
        from listagem_coluna lc
       where lc.cd_listagem = prm_cd_listagem
         and lc.fg_retorno  = 'S';
      return aux_lista;
    end f_buscar_retorno;
  
end k_listagem;
/
