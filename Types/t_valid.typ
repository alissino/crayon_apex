create or replace type t_valid as object(
  cd_tabela   varchar2(100),
  dm_operacao varchar2(1),
  vt_colunas  t_valid_col_vet,
  
  constructor function t_valid return self as result,
  constructor function t_valid(prm_cd_tabela varchar2, prm_dm_ins boolean, prm_dm_upd boolean, prm_dm_del boolean) return self as result,
  
  member function f_operacao(prm_dm_ins boolean, prm_dm_upd boolean, prm_dm_del boolean) return varchar2,
  
  member procedure p_add_coluna(prm_cd_coluna varchar2, prm_ds_old varchar2, prm_ds_new varchar2),
  member procedure p_add_coluna(prm_cd_coluna varchar2, prm_ds_old number, prm_ds_new number),
  member procedure p_add_coluna(prm_cd_coluna varchar2, prm_ds_old date, prm_ds_new date),
  
  member procedure p_validar
  
)
/
