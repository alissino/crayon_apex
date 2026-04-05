create or replace trigger tg_tabela_db
  after create or alter or rename on schema
  when (ora_dict_obj_type = 'TABLE')
declare
  aux_cd_tabela varchar2(100);
begin
  k_utils.p_imprime_output(ora_dict_obj_type||'|'||ora_dict_obj_name);
  if ora_dict_obj_type = 'TABLE' then
    aux_cd_tabela := upper(ora_dict_obj_name);
    if aux_cd_tabela <> 'AUDIT_TAB' then
      --k_audit.p_gerar_trigger(aux_cd_tabela);
      null;
    end if;
    --k_valid.p_gerar_trigger(aux_cd_tabela);
  end if;
end;
/
