create or replace type t_valid_col as object
(
  cd_tabela    varchar2(100),
  cd_coluna    varchar2(100),
  ds_valor_new varchar2(256),
  ds_valor_old varchar2(256),
  
  constructor function t_valid_col return self as result,
  constructor function t_valid_col(prm_cd_tabela varchar2, prm_cd_coluna varchar2) return self as result,
  constructor function t_valid_col(prm_cd_tabela varchar2, prm_cd_coluna varchar2, prm_ds_new varchar2, prm_ds_old varchar2) return self as result,
  constructor function t_valid_col(prm_cd_tabela varchar2, prm_cd_coluna varchar2, prm_ds_new number, prm_ds_old number) return self as result,
  constructor function t_valid_col(prm_cd_tabela varchar2, prm_cd_coluna varchar2, prm_ds_new date, prm_ds_old date) return self as result,
  
  member function f_buscar_dominio return varchar2
  
)
/
create or replace type body t_valid_col is
  
  constructor function t_valid_col 
    return self as result
    is
    begin
      self.cd_tabela    := null;
      self.cd_coluna    := null;
      self.ds_valor_new := null;
      self.ds_valor_old := null;
      return;
    end t_valid_col;
    
  constructor function t_valid_col(prm_cd_tabela varchar2, 
                                   prm_cd_coluna varchar2) 
    return self as result
    is
    begin
      self := t_valid_col();
      self.cd_tabela := upper(trim(prm_cd_tabela));
      self.cd_coluna := upper(trim(prm_cd_coluna));
      return;
    end t_valid_col;
    
  constructor function t_valid_col(prm_cd_tabela varchar2, 
                                   prm_cd_coluna varchar2, 
                                   prm_ds_new    varchar2,
                                   prm_ds_old    varchar2) 
    return self as result
    is
    begin
      self := t_valid_col(prm_cd_tabela, prm_cd_coluna);
      self.ds_valor_new := prm_ds_new;
      self.ds_valor_old := prm_ds_old;
      return;
    end t_valid_col;
    
  constructor function t_valid_col(prm_cd_tabela varchar2, 
                                   prm_cd_coluna varchar2, 
                                   prm_ds_new    number,
                                   prm_ds_old    number)
    return self as result
    is
    begin
      self := t_valid_col(prm_cd_tabela, prm_cd_coluna);
      self.ds_valor_new := to_char(prm_ds_new);
      self.ds_valor_old := to_char(prm_ds_old);
      return;
    end t_valid_col;
    
  constructor function t_valid_col(prm_cd_tabela varchar2, 
                                   prm_cd_coluna varchar2, 
                                   prm_ds_new    date,
                                   prm_ds_old    date)
    return self as result
    is
    begin
      self := t_valid_col(prm_cd_tabela, prm_cd_coluna);
      self.ds_valor_new := to_char(prm_ds_new, 'dd/mm/yyyy hh24:mi:ss');
      self.ds_valor_old := to_char(prm_ds_old, 'dd/mm/yyyy hh24:mi:ss');
      return;
    end t_valid_col;
    
  member function f_buscar_dominio 
    return varchar2
    is
    begin
      begin
        return k_dominio.f_dm_relac(prm_cd_objeto   => self.cd_tabela, 
                                    prm_cd_atributo => self.cd_coluna);
      exception
        when no_data_found or too_many_rows then
          return null;
        when others then
          raise;
      end;
    end;
  
end;
/
