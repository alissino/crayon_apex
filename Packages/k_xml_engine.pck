create or replace package k_xml_engine is

  procedure p_gerar_xml(prm_cd_geracao geracao_prcsso.nr_sequencia%type);

end k_xml_engine;
/
create or replace package body k_xml_engine 
is
  
  aux_cd_geracao geracao_prcsso.nr_sequencia%type;
  aux_cd_xml     xml.cd_xml%type;
  
  function f_val(prm_ds_valor varchar2)
    return varchar2
    is
    begin
      return dbms_xmlgen.convert(prm_ds_valor);
    end f_val;
  
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
   
  function f_resover_valor(prm_cd_node xml_node.cd_xml_node%type)
    return varchar2
    is
      
    begin
      return null;
    
    end f_resover_valor;
  
  function f_valid_condicao(prm_ds_sql varchar2)
    return boolean
    is
      aux_nr_retorno number;
    begin
      return true;
    end f_valid_condicao;
  

  procedure p_gerar_xml(prm_cd_geracao geracao_prcsso.nr_sequencia%type)
    is
    begin
      aux_cd_geracao := prm_cd_geracao;
      
      select x.cd_xml
        into aux_cd_xml
        from geracao_prcsso gp,
             xml            x
       where x.cd_processo   = gp.cd_prcsso
         and gp.nr_sequencia = prm_cd_geracao;
      
    exception
      when others then
        k_processo.p_salvar_erro(prm_cd_geracao, sqlerrm);
    end p_gerar_xml;
  
end k_xml_engine;
/
