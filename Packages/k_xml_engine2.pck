create or replace package k_xml_engine2 is
  
  type typ_vt_param is table of varchar2(256) index by varchar2(45);

  procedure p_gerar_xml(prm_cd_geracao geracao_prcsso.nr_sequencia%type);
  
  procedure p_gerar_xml_clob(prm_cd_xml xml.cd_xml%type,
                             prm_vt_prm typ_vt_param,
                             prm_ds_txt out nocopy clob);
                             
  procedure p_assinar_xml(prm_ds_path_xml  varchar2,
                          prm_ds_path_cert varchar2);

end k_xml_engine2;
/
create or replace package body k_xml_engine2
is
  
  -- Variáveis globais da geração atual
  aux_cd_geracao geracao_prcsso.nr_sequencia%type;
  aux_cd_xml     xml.cd_xml%type;
  aux_vt_param   typ_vt_param;
  
  -------------------------------------------------------------------------------
  -- Forward declarations (declarações antecipadas)
  -------------------------------------------------------------------------------
  
  procedure p_gerar_node(prm_cd_node  xml_node.cd_xml_node%type,
                         prm_nr_nivel number default 0,
                         prm_xml_out  in out nocopy clob,
                         prm_contexto varchar2 default null);
  
  function f_montar_str_param
    return varchar2
    is
      aux_ds_param varchar2(32767);
      cursor cur_param is
      select *
        from geracao_prcsso_prm gpp
       where gpp.nr_seq_geracao = aux_cd_geracao;
    begin
      for prm in cur_param loop
        if aux_ds_param is not null then
          aux_ds_param := aux_ds_param || k_sql_dinamico.aux_ds_separador;
        end if;
        
        aux_ds_param := aux_ds_param || ':' || prm.nr_seq_param || 
                        k_sql_dinamico.aux_ds_igual || prm.ds_valor;
        
      end loop;
      return aux_ds_param;
    end f_montar_str_param;
  
  -------------------------------------------------------------------------------
  -- Funções auxiliares
  -------------------------------------------------------------------------------
  
  function f_val(prm_ds_valor varchar2)
    return varchar2
  is
  begin
    return dbms_xmlgen.convert(prm_ds_valor);
  end f_val;
  
  -------------------------------------------------------------------------------
  
  function f_buscar_param(prm_cd_param geracao_prcsso_prm.nr_seq_param%type)
    return geracao_prcsso_prm.ds_valor%type
  is
    aux_ds_valor geracao_prcsso_prm.ds_valor%type;
  begin
    k_processo.p_buscar_prm(prm_cd_geracao   => aux_cd_geracao,
                            prm_nr_sequencia => prm_cd_param,
                            prm_ds_valor     => aux_ds_valor);
    return aux_ds_valor;
  end f_buscar_param;
  
  -------------------------------------------------------------------------------
   
  function f_resover_valor(prm_cd_node  xml_node.cd_xml_node%type,
                           prm_contexto varchar2 default null)
    return varchar2
  is
    aux_ds_valor varchar2(4000);
    
    cursor cur_val is
      select xnv.dm_origem,
             xnv.ds_expressao,
             xnv.ds_valor
        from xml_node_val xnv
       where xnv.cd_xml_node = prm_cd_node
       order by xnv.cd_xml_val;
       
  begin
    for r_val in cur_val loop
      
      case r_val.dm_origem
        when 'FIX' then
          aux_ds_valor := r_val.ds_valor;
          
        when 'PRM' then
          aux_ds_valor := f_buscar_param(to_number(r_val.ds_valor));
          
        when 'COL' then
          if prm_contexto = 'LOOP' then
            aux_ds_valor := k_xml_context.get_value(r_val.ds_valor);
          else
            -- Fora de loop, tenta resolver como se fosse fixo
            aux_ds_valor := r_val.ds_valor;
          end if;
          
        when 'SQL' then
          aux_ds_valor := k_sql_dinamico.f_buscar_val(r_val.ds_expressao, f_montar_str_param);
          
        else
          k_processo.p_salvar_erro(aux_cd_geracao, 
            'Origem inválida no node ' || prm_cd_node || ': ' || r_val.dm_origem);
          aux_ds_valor := null;
      end case;
      
      exit when aux_ds_valor is not null;
    end loop;
    
    return f_val(aux_ds_valor);
    
  exception
    when others then
      k_processo.p_salvar_erro(aux_cd_geracao, 
        'Erro ao resolver valor do node ' || prm_cd_node || ': ' || sqlerrm);
      return null;
  end f_resover_valor;
  
  -------------------------------------------------------------------------------
  
  function f_valid_condicao(prm_ds_sql varchar2)
    return boolean
  is
    aux_nr_retorno number;
  begin
    aux_nr_retorno := nvl(to_number(k_sql_dinamico.f_buscar_val(prm_ds_sql, f_montar_str_param)), 0);
    return aux_nr_retorno > 0;
  exception
    when others then
      return false;
  end f_valid_condicao;
  
  -------------------------------------------------------------------------------
  
  function f_buscar_atributos(prm_cd_node xml_node.cd_xml_node%type)
    return varchar2
  is
    aux_ds_val   varchar2(4000);
    aux_ds_atrib varchar2(32767);
    
    cursor cur_atrib is
      select xna.ds_atributo,
             xna.dm_origem,
             xna.ds_expressao,
             xna.ds_valor
        from xml_node_atributo xna
       where xna.cd_xml_node = prm_cd_node
       order by xna.cd_atributo;
       
  begin
    for r_atrib in cur_atrib loop
      
      case r_atrib.dm_origem
        when 'FIX' then
          aux_ds_val := f_val(r_atrib.ds_valor);
          
        when 'PRM' then
          aux_ds_val := f_val(f_buscar_param(to_number(r_atrib.ds_valor)));
          
        when 'COL' then
          aux_ds_val := f_val(k_xml_context.get_value(r_atrib.ds_valor));
        
        when 'SQL' then
          aux_ds_val := f_val(k_sql_dinamico.f_buscar_val(r_atrib.ds_expressao, f_montar_str_param));
        
        else
          k_processo.p_salvar_erro(aux_cd_geracao,
            'Origem inválida no atributo: ' || r_atrib.dm_origem);
          aux_ds_val := null;
      end case;
      
      if aux_ds_val is not null then
        aux_ds_atrib := aux_ds_atrib || ' ' || r_atrib.ds_atributo || '="' || aux_ds_val || '"';
      end if;
    
    end loop;
    
    return aux_ds_atrib;
    
  exception
    when others then
      k_processo.p_salvar_erro(aux_cd_geracao, 
        'Erro ao buscar atributos do node ' || prm_cd_node || ': ' || sqlerrm);
      return null;
  end f_buscar_atributos;
  
  -------------------------------------------------------------------------------
  -- Processamento do LOOP
  -------------------------------------------------------------------------------
  
  procedure p_processar_loop(prm_cd_node     xml_node.cd_xml_node%type,
                             prm_ds_nome_tag xml_node.ds_nome_tag%type,
                             prm_ds_sql_loop xml_node.ds_sql_loop%type,
                             prm_nr_nivel    number,
                             prm_xml_out     in out nocopy clob)
  is
    type typ_vt_colunas is table of varchar2(100) index by pls_integer;
    aux_cd_cursor  integer;
    aux_nr_status  integer;
    aux_qt_cols    number;
    aux_ds_valor   varchar2(4000);
    aux_ds_indent  varchar2(100);
    aux_vt_colunas typ_vt_colunas;
    aux_vt_desc    dbms_sql.desc_tab;
  begin
    aux_ds_indent := lpad(' ', prm_nr_nivel * 2);
    
    -- Abre cursor dinâmico
    aux_cd_cursor := dbms_sql.open_cursor;
    
    begin
      dbms_sql.parse(aux_cd_cursor, prm_ds_sql_loop, dbms_sql.native);
      
      for prm in (select ':' || gpp.nr_seq_param ds_param,
                         gpp.ds_valor            ds_valor
                    from geracao_prcsso_prm gpp
                   where gpp.nr_seq_geracao = aux_cd_geracao)
      loop
        begin
          dbms_sql.bind_variable(aux_cd_cursor, prm.ds_param, prm.ds_valor);
        exception
          when others then
            null;
        end;
      end loop;
      
      -- Descreve as colunas do cursor
      dbms_sql.describe_columns(aux_cd_cursor, aux_qt_cols, aux_vt_desc);
      
      -- Define as colunas para receber os valores como string
      for i in 1..aux_qt_cols loop
        aux_vt_colunas(i) := aux_vt_desc(i).col_name;
        dbms_sql.define_column(aux_cd_cursor, i, aux_ds_valor, 4000);
      end loop;
      
      -- Executa o cursor
      aux_nr_status := dbms_sql.execute(aux_cd_cursor);
      
      -- Loop nos registros
      loop
        exit when dbms_sql.fetch_rows(aux_cd_cursor) = 0;
        
        -- Carrega contexto com valores das colunas
        k_xml_context.clear_context;
        
        for i in 1..aux_qt_cols loop
          dbms_sql.column_value(aux_cd_cursor, i, aux_ds_valor);
          k_xml_context.set_value(aux_vt_colunas(i), aux_ds_valor);
        end loop;
        
        -- Abre tag do loop
        prm_xml_out := prm_xml_out || aux_ds_indent || 
                       '<' || prm_ds_nome_tag || f_buscar_atributos(prm_cd_node) || '>' || chr(10);
        
        -- Processa filhos do loop recursivamente
        p_gerar_node(prm_cd_node  => prm_cd_node,
                     prm_nr_nivel => prm_nr_nivel + 1,
                     prm_xml_out  => prm_xml_out,
                     prm_contexto => 'LOOP');
        
        -- Fecha tag do loop
        prm_xml_out := prm_xml_out || aux_ds_indent || 
                       '</' || prm_ds_nome_tag || '>' || chr(10);
        
      end loop;
      
      -- Limpa contexto após processar todos os registros
      k_xml_context.clear_context;
      
    exception
      when others then
        if dbms_sql.is_open(aux_cd_cursor) then
          dbms_sql.close_cursor(aux_cd_cursor);
        end if;
        raise;
    end;
    
    dbms_sql.close_cursor(aux_cd_cursor);
    
  exception
    when others then
      k_processo.p_salvar_erro(aux_cd_geracao, 
        'Erro no loop ' || prm_ds_nome_tag || ': ' || sqlerrm || 
        ' - SQL: ' || substr(prm_ds_sql_loop, 1, 500));
      raise;
  end p_processar_loop;
  
  -------------------------------------------------------------------------------
  -- Procedimento recursivo principal
  -------------------------------------------------------------------------------
  
  procedure p_gerar_node(prm_cd_node  xml_node.cd_xml_node%type,
                         prm_nr_nivel number default 0,
                         prm_xml_out  in out nocopy clob,
                         prm_contexto varchar2 default null)
  is
    cursor cur_nodes is
      select xn.cd_xml_node,
             xn.ds_nome_tag,
             xn.dm_tipo,
             xn.fg_obrigatorio,
             xn.ds_sql_loop,
             xn.ds_sql_condicao,
             xn.cd_xml,
             xn.cd_xml_node_pai
        from xml_node xn
       where xn.cd_xml          = aux_cd_xml
         and nvl(xn.cd_xml_node_pai, 0) = nvl(prm_cd_node, 0)
         and xn.dm_situacao     = 'A'
       order by xn.nr_ordem;
    
    aux_ds_indent    varchar2(100);
    aux_ds_atributos varchar2(32767);
    aux_ds_valor     varchar2(4000);
    aux_ds_namespace varchar2(512);
    aux_rc_node      cur_nodes%rowtype;
    
  begin
    aux_ds_indent := lpad(' ', prm_nr_nivel * 2);
    
    open cur_nodes;
    loop
      fetch cur_nodes into aux_rc_node;
      exit when cur_nodes%notfound;
      
      -- Valida condição de exibição
      if aux_rc_node.ds_sql_condicao is not null then
        begin
          if not f_valid_condicao(aux_rc_node.ds_sql_condicao) then
            if aux_rc_node.fg_obrigatorio = 'S' then
              k_processo.p_salvar_erro(aux_cd_geracao, 
                'Condição não atendida para nó obrigatório: ' || aux_rc_node.ds_nome_tag);
            end if;
            continue;
          end if;
        exception
          when others then
            k_processo.p_salvar_erro(aux_cd_geracao, 
              'Erro ao validar condição do nó ' || aux_rc_node.ds_nome_tag || ': ' || sqlerrm);
            if aux_rc_node.fg_obrigatorio = 'S' then
              raise;
            else
              continue;
            end if;
        end;
      end if;
      
      -- Busca atributos do nó
      aux_ds_atributos := nvl(f_buscar_atributos(aux_rc_node.cd_xml_node), '');
      
      -- Processa conforme o tipo do nó
      case aux_rc_node.dm_tipo
      
        when 'ROOT' then
          -- Adiciona declaração XML
          prm_xml_out := '<?xml version="1.0" encoding="UTF-8"?>' || chr(10);
          
          -- Busca namespace da raiz
          begin
            select ds_namespace
              into aux_ds_namespace
              from xml
             where cd_xml = aux_rc_node.cd_xml;
          exception
            when no_data_found then
              aux_ds_namespace := null;
          end;
          
          -- Abre tag raiz com namespace
          prm_xml_out := prm_xml_out || '<' || aux_rc_node.ds_nome_tag;
          
          if aux_ds_namespace is not null then
            prm_xml_out := prm_xml_out || ' xmlns="' || aux_ds_namespace || '"';
          end if;
          
          prm_xml_out := prm_xml_out || aux_ds_atributos || '>' || chr(10);
          
          -- Processa filhos da raiz
          p_gerar_node(prm_cd_node  => aux_rc_node.cd_xml_node,
                       prm_nr_nivel => prm_nr_nivel + 1,
                       prm_xml_out  => prm_xml_out,
                       prm_contexto => prm_contexto);
          
          -- Fecha tag raiz
          prm_xml_out := prm_xml_out || '</' || aux_rc_node.ds_nome_tag || '>';
          
        when 'GROUP' then
          -- Grupo: apenas contém outros nós
          prm_xml_out := prm_xml_out || aux_ds_indent || 
                         '<' || aux_rc_node.ds_nome_tag || aux_ds_atributos || '>' || chr(10);
          
          -- Processa filhos do grupo
          p_gerar_node(prm_cd_node  => aux_rc_node.cd_xml_node,
                       prm_nr_nivel => prm_nr_nivel + 1,
                       prm_xml_out  => prm_xml_out,
                       prm_contexto => prm_contexto);
          
          -- Fecha grupo
          prm_xml_out := prm_xml_out || aux_ds_indent || 
                         '</' || aux_rc_node.ds_nome_tag || '>' || chr(10);
          
        when 'FIELD' then
          -- Campo: contém valor
          aux_ds_valor := f_resover_valor(prm_cd_node  => aux_rc_node.cd_xml_node,
                                          prm_contexto => prm_contexto);
          
          -- Se valor nulo e não obrigatório, omite a tag
          if aux_ds_valor is null and aux_rc_node.fg_obrigatorio = 'N' then
            null;
          else
            prm_xml_out := prm_xml_out || aux_ds_indent || 
                           '<' || aux_rc_node.ds_nome_tag || aux_ds_atributos || '>' ||
                           nvl(aux_ds_valor, '') ||
                           '</' || aux_rc_node.ds_nome_tag || '>' || chr(10);
          end if;
          
        when 'LOOP' then
          -- Valida se tem SQL definido
          if aux_rc_node.ds_sql_loop is null then
            k_processo.p_salvar_erro(aux_cd_geracao, 
              'Loop ' || aux_rc_node.ds_nome_tag || ' sem SQL definido');
            if aux_rc_node.fg_obrigatorio = 'S' then
              raise_application_error(-20001, 'Loop obrigatório sem SQL: ' || aux_rc_node.ds_nome_tag);
            end if;
          else
            p_processar_loop(prm_cd_node     => aux_rc_node.cd_xml_node,
                             prm_ds_nome_tag => aux_rc_node.ds_nome_tag,
                             prm_ds_sql_loop => aux_rc_node.ds_sql_loop,
                             prm_nr_nivel    => prm_nr_nivel,
                             prm_xml_out     => prm_xml_out);
          end if;
          
        else
          k_processo.p_salvar_erro(aux_cd_geracao, 
            'Tipo de nó inválido: ' || aux_rc_node.dm_tipo || ' no nó ' || aux_rc_node.ds_nome_tag);
          
      end case;
      
    end loop;
    close cur_nodes;
    
  exception
    when others then
      if cur_nodes%isopen then
        close cur_nodes;
      end if;
      k_processo.p_salvar_erro(aux_cd_geracao, 
                               'Erro ao processar nó: ' || sqlerrm || ' - ' || 
                               dbms_utility.format_error_backtrace);
      raise;
  end p_gerar_node;
  
  -------------------------------------------------------------------------------
  -- Procedimento principal
  -------------------------------------------------------------------------------
  
  procedure p_gerar_xml(prm_cd_geracao geracao_prcsso.nr_sequencia%type)
  is
    aux_ds_xml     clob;
    aux_ds_arquivo varchar2(256);
    aux_nr_cont    number;
    aux_cd_arquivo geracao_prcsso_arq.nr_sequencia%type;
  begin
    -- Inicializa variáveis globais
    aux_cd_geracao := prm_cd_geracao;
    
    -- Busca o XML vinculado ao processo
    begin
      select x.cd_xml
        into aux_cd_xml
        from geracao_prcsso gp,
             xml            x
       where x.cd_processo   = gp.cd_prcsso
         and gp.nr_sequencia = prm_cd_geracao;
    exception
      when no_data_found then
        k_processo.p_salvar_erro(prm_cd_geracao, 
          'Nenhum XML vinculado ao processo da geração ' || prm_cd_geracao);
        raise_application_error(-20002, 'XML não encontrado para a geração');
    end;
    
    -- Verifica se existem nós configurados
    select count(*)
      into aux_nr_cont
      from xml_node
     where cd_xml = aux_cd_xml
       and dm_situacao = 'A';
       
    if aux_nr_cont = 0 then
      k_processo.p_salvar_erro(prm_cd_geracao, 
        'Nenhum nó configurado para o XML ' || aux_cd_xml);
      raise_application_error(-20003, 'XML sem nós configurados');
    end if;
    
    -- Inicializa CLOB temporário
    dbms_lob.createtemporary(aux_ds_xml, true, dbms_lob.session);
    
    -- Gera XML recursivamente a partir da raiz
    p_gerar_node(prm_cd_node  => null,  -- null = busca nós raiz (sem pai)
                 prm_nr_nivel => 0,
                 prm_xml_out  => aux_ds_xml,
                 prm_contexto => null);
    
    -- Define nome do arquivo
    aux_ds_arquivo := 'XML_' || aux_cd_geracao || '_' || 
                  to_char(sysdate, 'YYYYMMDD_HH24MISS') || '.xml';
                  
    -- Salva arquivo na tabela (conteúdo na tabela, sem salvar em disco)
    
    k_processo.p_salvar_arquivo(prm_cd_geracao    => aux_cd_geracao,
                                prm_cd_dir_oracle => null,   -- NULL = salvar apenas na tabela
                                prm_ds_local      => null,   -- NULL = salvar apenas na tabela
                                prm_ds_nome       => aux_ds_arquivo,
                                prm_ds_conteudo   => f_clob_para_blob(aux_ds_xml),
                                prm_cd_seq        => aux_cd_arquivo);
    
    -- Libera CLOB temporário
    dbms_lob.freetemporary(aux_ds_xml);
    
    p_assinar_xml('nada', 'nada2');
    
  exception
    when others then
      -- Libera recursos em caso de erro
      if dbms_lob.istemporary(aux_ds_xml) = 1 then
        dbms_lob.freetemporary(aux_ds_xml);
      end if;
      
      -- Registra erro
      k_processo.p_salvar_erro(prm_cd_geracao, 
        'Erro fatal na geração XML: ' || sqlerrm || ' - ' || 
        dbms_utility.format_error_backtrace);
      raise;
  end p_gerar_xml;
  
  procedure p_gerar_xml_clob(prm_cd_xml xml.cd_xml%type,
                             prm_vt_prm typ_vt_param,
                             prm_ds_txt out nocopy clob)
    is
    begin
      null;
    end;
  
  procedure p_assinar_xml(prm_ds_path_xml  varchar2,
                          prm_ds_path_cert varchar2)
    is
      aux_ds_job varchar2(45) := 'j_ass_xml';
    begin
      dbms_scheduler.create_job(job_name            => aux_ds_job,
                                program_name        => 'PRG_ASSINAR_XML',
                                enabled             => false,
                                auto_drop           => true);
      
      dbms_scheduler.set_job_argument_value(job_name       => aux_ds_job,
                                            argument_name  => 'prm_xml',
                                            argument_value => prm_ds_path_xml);
                                            
      dbms_scheduler.set_job_argument_value(job_name       => aux_ds_job,
                                            argument_name  => 'prm_cert',
                                            argument_value => prm_ds_path_cert);
      
      dbms_scheduler.enable(aux_ds_job);
      
      dbms_scheduler.run_job(job_name            => aux_ds_job,
                             use_current_session => true);
    
    end;
  
end k_xml_engine2;
/
