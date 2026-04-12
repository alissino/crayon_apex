create or replace procedure p_log_sistema(prm_ds_log varchar2) 
is
  pragma autonomous_transaction;
begin
  insert
    into log_systema
        (cd_usuario,
         ds_log,
         ds_callstack)
  values(f_buscar_usuario_ativo,
         prm_ds_log,
         substr(dbms_utility.format_call_stack, 1, 4000));
  commit;
end p_log_sistema;
/
