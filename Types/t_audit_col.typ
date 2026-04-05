create or replace type t_audit_col as object
(
  ds_coluna    varchar2(62),
  ds_valor_old varchar2(512),
  ds_valor_new varchar2(512),
  
  constructor function t_audit_col(prm_ds_coluna varchar2, prm_ds_val_old varchar2, prm_ds_val_new varchar2) return self as result,
  constructor function t_audit_col(prm_ds_coluna varchar2, prm_ds_val_old number, prm_ds_val_new number) return self as result,
  constructor function t_audit_col(prm_ds_coluna varchar2, prm_ds_val_old date, prm_ds_val_new date) return self as result
  
)
/
create or replace type body t_audit_col is
  
  constructor function t_audit_col(prm_ds_coluna varchar2, prm_ds_val_old varchar2, prm_ds_val_new varchar2) return self as result
  is
  begin
    self.ds_coluna    := upper(trim(prm_ds_coluna));
    self.ds_valor_old := substr(prm_ds_val_old, 1, 512);
    self.ds_valor_new := substr(prm_ds_val_new, 1, 512);
    return;
  end;
  
  constructor function t_audit_col(prm_ds_coluna varchar2, prm_ds_val_old number, prm_ds_val_new number) return self as result
  is
  begin
    self := t_audit_col(prm_ds_coluna, to_char(prm_ds_val_old), to_char(prm_ds_val_new));
    return;
  end;
  
  constructor function t_audit_col(prm_ds_coluna varchar2, prm_ds_val_old date, prm_ds_val_new date) return self as result
  is
  begin
    self := t_audit_col(prm_ds_coluna, to_char(prm_ds_val_old, k_audit.cns_mask_dt), to_char(prm_ds_val_new, k_audit.cns_mask_dt));
    return;
  end;
  
end;
/
