create or replace type t_lista_itm as object
(
  ds_item varchar2(32000),
  nr_item number,
  dt_item date,
  
  constructor function t_lista_itm return self as result,
  constructor function t_lista_itm(prm_ds_valor varchar2) return self as result,
  constructor function t_lista_itm(prm_ds_valor number) return self as result,
  constructor function t_lista_itm(prm_ds_valor date) return self as result
)
/
create or replace type body t_lista_itm is
  
  constructor function t_lista_itm return self as result
  is
  begin
    self.ds_item := null;
    self.nr_item := null;
    self.dt_item := null;
    return;
  end;
  
  constructor function t_lista_itm(prm_ds_valor varchar2) return self as result
  is
  begin
    self := t_lista_itm();
    self.ds_item := prm_ds_valor;
    return;
  end;
  
  constructor function t_lista_itm(prm_ds_valor number) return self as result
  is
  begin
    self := t_lista_itm();
    self.nr_item := prm_ds_valor;
    return;
  end;
  
  constructor function t_lista_itm(prm_ds_valor date) return self as result
  is
  begin
    self := t_lista_itm();
    self.dt_item := prm_ds_valor;
    return;
  end;
  
end;
/
