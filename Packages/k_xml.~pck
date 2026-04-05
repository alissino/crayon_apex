create or replace package k_xml 
is
  type typ_rc_param is record (cd_param varchar2(100),
                               ds_valor varchar2(255));
  type typ_vt_params is table of typ_rc_param;
  
  procedure p_gerar_atrib_xml(prm_cd_xml xml.cd_xml%type);
  
  procedure p_gerar_sub_atrib(prm_cd_xml_atrib xml_atributo.cd_xml_atrib%type);
  
  procedure p_gerar_arquivo(prm_cd_xml     in         xml.cd_xml%type,
                            prm_vt_prm     in         typ_vt_params,
                            prm_ds_arquivo out nocopy clob);

end k_xml;
/
create or replace package body k_xml is
  subtype typ_cd_atrib is varchar2(100);
  subtype typ_ds_valor is varchar2(255);
  type typ_vt_colunas is table of typ_ds_valor index by typ_cd_atrib;
       
  procedure p_gerar_atrib_xml(prm_cd_xml xml.cd_xml%type)
    is
      aux_ds_sql    xml.ds_sql%type;
      aux_cd_cursor integer;
      aux_vt_atribs dbms_sql.desc_tab;
      aux_qt_atribs number;
      aux_rc_atrib  dbms_sql.desc_rec;
    begin
      
      select x.ds_sql
        into aux_ds_sql
        from xml x
       where x.cd_xml = prm_cd_xml;
      
      if aux_ds_sql is null then
        p_mostra_erro('Não há SQL para o arquivo.');
      end if;
      
      aux_cd_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(aux_cd_cursor, aux_ds_sql, dbms_sql.native);
      dbms_sql.describe_columns(aux_cd_cursor, aux_qt_atribs, aux_vt_atribs);
      
      if nvl(aux_qt_atribs, 0) = 0 then
        p_mostra_erro('Não há atributos no SQL do arquivo.');
      end if;
      
      for aux_nr_atrib in 1 .. aux_qt_atribs loop
        aux_rc_atrib := aux_vt_atribs(aux_nr_atrib);
        p_imprimir_linha('Coluna: '||aux_rc_atrib.col_name);
        
        insert
          into xml_atributo
              (cd_xml,
               cd_atributo,
               nr_versao,
               fg_obigatorio,
               ds_descricao)
        values(prm_cd_xml,
               aux_rc_atrib.col_name,
               1,
               k_dominio.f_val_padrao(prm_cd_objeto   => 'xml_atributo',
                                      prm_cd_atributo => 'fg_obigatorio'),
               aux_rc_atrib.col_name);
      end loop;
      dbms_sql.close_cursor(aux_cd_cursor);
      commit;
    exception
      when others then
        if dbms_sql.is_open(aux_cd_cursor) then
          dbms_sql.close_cursor(aux_cd_cursor);
        end if;
        rollback;
        raise;
    end p_gerar_atrib_xml;
    
  procedure p_gerar_sub_atrib(prm_cd_xml_atrib xml_atributo.cd_xml_atrib%type)
    is
      aux_ds_sql    xml_atributo.ds_sql%type;
      aux_cd_xml    xml_atributo.cd_xml%type;
      aux_cd_cursor integer;
      aux_vt_atribs dbms_sql.desc_tab;
      aux_qt_atribs number;
      aux_rc_atrib  dbms_sql.desc_rec;
    begin
      
      select xa.cd_xml,
             xa.ds_sql
        into aux_cd_xml,
             aux_ds_sql
        from xml_atributo xa
       where xa.cd_xml_atrib = prm_cd_xml_atrib;
     
      if aux_ds_sql is null then
        p_mostra_erro('Não há SQL para o atributo do XML.');
      end if;
      
      aux_cd_cursor := dbms_sql.open_cursor;
      dbms_sql.parse(aux_cd_cursor, aux_ds_sql, dbms_sql.native);
      dbms_sql.describe_columns(aux_cd_cursor, aux_qt_atribs, aux_vt_atribs);
      
      if nvl(aux_qt_atribs, 0) = 0 then
        p_mostra_erro('Não há colunas para o SQL do atributo.');
      end if;
      
      for aux_nr_atrib in 1 .. aux_qt_atribs loop
        aux_rc_atrib := aux_vt_atribs(aux_nr_atrib);
        p_imprimir_linha('Coluna: '||aux_rc_atrib.col_name);
        
        insert
          into xml_atributo
              (cd_xml,
               cd_atributo,
               nr_versao,
               fg_obigatorio,
               ds_descricao,
               cd_atrib_superior)
        values(aux_cd_xml,
               aux_rc_atrib.col_name,
               1,
               k_dominio.f_val_padrao(prm_cd_objeto   => 'xml_atributo', 
                                      prm_cd_atributo => 'fg_obigatorio'),
               aux_rc_atrib.col_name,
               prm_cd_xml_atrib);
        
      end loop;
      
      dbms_sql.close_cursor(aux_cd_cursor);
      commit;
    exception
      when others then
        if dbms_sql.is_open(aux_cd_cursor) then
          dbms_sql.close_cursor(aux_cd_cursor);
        end if;
        rollback;
        raise;
    end p_gerar_sub_atrib;
    
  procedure p_exec_sql(prm_ds_sql in  varchar2,
                       prm_vt_prm in  typ_vt_params,
                       prm_vt_col out typ_vt_colunas)
    is
      aux_cd_cur   integer;
      aux_qt_ln    number;
      aux_vt_col   dbms_sql.desc_tab;
      aux_rc_col   dbms_sql.desc_rec;
      aux_qt_col   number;
      aux_ds_atrib varchar2(255);
    begin
      aux_cd_cur := dbms_sql.open_cursor;

      
      dbms_sql.parse(aux_cd_cur, prm_ds_sql, dbms_sql.native);
      
      for aux_nr_prm in 1 .. prm_vt_prm.count loop
        dbms_sql.bind_variable(aux_cd_cur, 
                               ':'||prm_vt_prm(aux_nr_prm).cd_param,
                               prm_vt_prm(aux_nr_prm).ds_valor);
      end loop;
      
      aux_qt_ln := dbms_sql.execute(aux_cd_cur);
      
      dbms_sql.describe_columns(aux_cd_cur, aux_qt_col, aux_vt_col);
      
      for aux_nr_col in 1 .. aux_qt_col loop
        dbms_sql.define_column(aux_cd_cur, aux_nr_col, aux_ds_atrib, 4000);
      end loop;
      
      while dbms_sql.fetch_rows(aux_cd_cur) > 0 loop
        for aux_nr_col in 1 .. aux_qt_col loop
          aux_rc_col := aux_vt_col(aux_nr_col);
          dbms_sql.column_value(aux_cd_cur, aux_nr_col, aux_ds_atrib);
          prm_vt_col(aux_rc_col.col_name) := aux_ds_atrib;
        end loop;
      end loop;
    end p_exec_sql;
    
  procedure p_montar_atrib(prm_ds_arq   in out nocopy blob,
                           prm_cd_atrib in     number,
                           prm_ds_atrib in     varchar2,
                           prm_ds_valor in     varchar2)
    is
      aux_ds_sql xml_atributo.ds_sql%type;
    begin
      select xa.ds_sql
        into aux_ds_sql
        from xml_atributo xa
       where xa.cd_xml_atrib = prm_cd_atrib;
       
      if prm_ds_valor is null and aux_ds_sql is null then
        goto fechar;
      end if;
      
      if aux_ds_sql is not null then
        prm_ds_arq := prm_ds_arq||'<'||prm_ds_atrib||'>'||chr(13);
        
      else
        prm_ds_arq := prm_ds_arq||'<'||prm_ds_atrib||'>'||prm_ds_valor;
      end if;
      
      
      <<fechar>>
      prm_ds_arq := prm_ds_arq||'</'||prm_ds_atrib||'>'||chr(13);
      
    end p_montar_atrib;
  
  procedure p_gerar_arquivo(prm_cd_xml     in         xml.cd_xml%type,
                            prm_vt_prm     in         typ_vt_params,
                            prm_ds_arquivo out nocopy clob)
    is
      aux_ds_arq clob;
      aux_ds_cab xml.ds_cabecalho%type;
      aux_ds_sql xml.ds_sql%type;
      
    begin
      select x.ds_cabecalho,
             x.ds_sql
        into aux_ds_cab,
             aux_ds_sql
        from xml x
       where x.cd_xml = prm_cd_xml;
      
      dbms_lob.createtemporary(aux_ds_arq, true, dbms_lob.session);
      dbms_lob.open(aux_ds_arq, dbms_lob.lob_readwrite);
      
      if aux_ds_cab is not null then
        dbms_lob.writeappend(aux_ds_arq, length(aux_ds_cab), aux_ds_cab);
      end if;
      
      
      prm_ds_arquivo := aux_ds_arq;
      dbms_lob.close(aux_ds_arq);
    exception
      when others then
        if dbms_lob.isopen(aux_ds_arq) = 1 then
          dbms_lob.close(aux_ds_arq);
        end if;
        raise;
    end p_gerar_arquivo;
  
end k_xml;
/
