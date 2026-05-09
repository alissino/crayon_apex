create or replace function f_split_str(prm_ds_string    varchar2,
                                       prm_nr_index     pls_integer,
                                       prm_ds_separador varchar2) 
  return varchar2
is
begin
  return regexp_substr(prm_ds_string, '[^'||prm_ds_separador||']+', 1, prm_nr_index);
end f_split_str;
/
