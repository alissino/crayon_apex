create or replace procedure p_apex_gerar_relat_redirect(prm_cd_relatorio relatorio.cd_relatorio%type,
                                                        prm_ds_params    varchar2)
is
  aux_cd_processo processo.cd_prcsso%type;
begin
  select r.cd_processo
    into aux_cd_processo
    from relatorio r
   where r.cd_relatorio = prm_cd_relatorio;
  
  p_apex_gerar_prcsso_redirect(aux_cd_processo, prm_ds_params);
  
end p_apex_gerar_relat_redirect;
/
