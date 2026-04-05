create or replace procedure p_mostra_erro(prm_ds_erro varchar2) 
is
begin
  k_utils.p_erro_regra(prm_ds_erro => prm_ds_erro);
end p_mostra_erro;
/
