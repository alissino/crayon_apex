create or replace package k_utils is

  e_regra_negocio exception;
  pragma exception_init(e_regra_negocio, -20100);
  
  cns_ins constant char(1) := 'I';
  cns_upd constant char(1) := 'U';
  cns_del constant char(1) := 'D';
  
  procedure p_erro_regra(prm_ds_erro varchar2);
  
  procedure p_imprime_output(prm_ds_linha varchar2);
  
  function f_split_str(prm_ds_string varchar2, prm_ds_separador varchar2)
    return varchar2;
  
  function f_trata_erro(prm_ds_erro varchar2)
    return varchar2;

end k_utils;
/
create or replace package body k_utils is

  procedure p_erro_regra(prm_ds_erro varchar2)
    is
      aux_ds_erro varchar2(32000);
    begin
      raise_application_error(-20100, prm_ds_erro);
    end p_erro_regra;
  
  procedure p_imprime_output(prm_ds_linha varchar2)
    is
    begin
      dbms_output.put_line(prm_ds_linha);
    end p_imprime_output;
  
  function f_split_str(prm_ds_string varchar2, prm_ds_separador varchar2)
    return varchar2
    is
    begin
      return null;
    end f_split_str;
  
  function f_trata_erro(prm_ds_erro varchar2)
    return varchar2
    is
    begin
      if nvl(instr(prm_ds_erro, 'ORA-20100'), 0) > 0 then
        return substr(prm_ds_erro, 12, length(prm_ds_erro));
      end if;
      return prm_ds_erro;
    end f_trata_erro;

end k_utils;
/
