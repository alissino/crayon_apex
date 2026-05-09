create or replace package k_xml_context is
  -- Tipo para armazenar valores de colunas do loop atual
  type t_context_data is table of varchar2(4000) index by varchar2(100);
  
  -- Contexto atual (válido durante um loop)
  g_context t_context_data;
  
  procedure set_value(prm_column varchar2, prm_value varchar2);
  function get_value(prm_column varchar2) return varchar2;
  procedure clear_context;

end k_xml_context;
/
create or replace package body k_xml_context is
 
  procedure set_value(prm_column varchar2, prm_value varchar2) is
  begin
    g_context(upper(trim(prm_column))) := prm_value;
  end;
  
  function get_value(prm_column varchar2) return varchar2 is
  begin
    return g_context(upper(trim(prm_column)));
  exception
    when no_data_found then
      return null;
  end;
  
  procedure clear_context is
  begin
    g_context.delete;
  end;
  
end k_xml_context;
/
