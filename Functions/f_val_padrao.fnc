create or replace function f_val_padrao(prm_cd_objeto   varchar2,
                                        prm_cd_atributo varchar2) 
return varchar2 
is
  aux_ds_valor varchar2(256);
begin
  
  aux_ds_valor := k_dominio.f_val_padrao(prm_cd_objeto, prm_cd_atributo);
  
  if aux_ds_valor is null then
    select u.data_default
      into aux_ds_valor
      from user_tab_columns u
     where u.table_name = upper(trim(prm_cd_objeto))
       and u.column_name = upper(trim(prm_cd_atributo));
    if aux_ds_valor is not null then
      execute immediate 'select '||aux_ds_valor||' from dual'
         into aux_ds_valor;
    end if;
  end if;
  return aux_ds_valor;
exception
  when no_data_found or too_many_rows then
    return null;
  when others then
    raise;
end f_val_padrao;
/
