create or replace procedure p_imprimir_linha(prm_ds_linha varchar2) 
is
begin
  k_utils.p_imprime_output(prm_ds_linha => prm_ds_linha);
end p_imprimir_linha;
/
