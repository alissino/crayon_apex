create or replace type t_lista as object
(
  vt_lista t_lista_itm_vet,
  
  constructor function t_lista return self as result,
  constructor function t_lista(prm_ds_lista varchar2, prm_ds_separador varchar2 default ',') return self as result,
  
  member procedure p_add_item(prm_ds_item varchar2, prm_nr_index integer default 0),
  member procedure p_add_item(prm_ds_item number, prm_nr_index integer default 0),
  member procedure p_add_item(prm_ds_item date, prm_nr_index integer default 0),
  
  member procedure p_del_item(prm_ds_item varchar2),
  member procedure p_del_item(prm_ds_item number),
  member procedure p_del_item(prm_ds_item date),
  
  member procedure p_del_index(prm_nr_index integer),
  
  member function f_existe(prm_ds_item varchar2) return boolean,
  member function f_existe(prm_ds_item number) return boolean,
  member function f_existe(prm_ds_item date) return boolean,
  
  member function f_index(prm_ds_item varchar2) return integer,
  member function f_index(prm_ds_item number) return integer,
  member function f_index(prm_ds_item date) return integer,
  
  member function f_qtd_itens return integer,
  
  member function f_item_ds(prm_nr_index integer) return varchar2,
  member function f_item_nr(prm_nr_index integer) return number,
  member function f_item_dt(prm_nr_index integer) return date,
  
  member procedure p_crescente,
  member procedure p_decrescente,
  
  member function f_para_string(prm_ds_separador varchar2 default ',') return varchar2,
  member procedure p_de_string(prm_ds_lista varchar2, prm_ds_separador varchar2 default ','),
  
  member procedure p_limpar
  
)
/
create or replace type body t_lista is
  
  constructor function t_lista return self as result
  is
  begin
    self.vt_lista := t_lista_itm_vet();
    return;
  end;
  
  constructor function t_lista(prm_ds_lista varchar2, prm_ds_separador varchar2 default ',') return self as result
  is
  begin
    self := t_lista();
    -- ler a lista
    return;
  end;
  
  member procedure p_add_item(prm_ds_item varchar2, prm_nr_index integer default 0)
  is
  begin
    null;
  end;
  
  member procedure p_add_item(prm_ds_item number, prm_nr_index integer default 0)
  is
  begin
    null;
  end;
  
  member procedure p_add_item(prm_ds_item date, prm_nr_index integer default 0)
  is
  begin
    null;
  end;
  
  member procedure p_del_item(prm_ds_item varchar2)
  is
  begin
    if f_existe(prm_ds_item) then
      p_del_index(f_index(prm_ds_item));
    end if;
  end;
  
  member procedure p_del_item(prm_ds_item number)
  is
  begin
    if f_existe(prm_ds_item) then
      p_del_index(f_index(prm_ds_item));
    end if;
  end;
  
  member procedure p_del_item(prm_ds_item date)
  is
  begin
    if f_existe(prm_ds_item) then
      p_del_index(f_index(prm_ds_item));
    end if;
  end;
  
  member procedure p_del_index(prm_nr_index integer)
  is
  begin
    self.vt_lista.delete(prm_nr_index);
  end;
  
  member function f_existe(prm_ds_item varchar2) return boolean
  is
  begin
    if nvl(f_index(prm_ds_item), 0) > 0 then
      return true;
    end if;
    return false;
  end;
  
  member function f_existe(prm_ds_item number) return boolean
  is
  begin
    if nvl(f_index(prm_ds_item), 0) > 0 then
      return true;
    end if;
    return false;
  end;
  
  member function f_existe(prm_ds_item date) return boolean
  is
  begin
    if nvl(f_index(prm_ds_item), 0) > 0 then
      return true;
    end if;
    return false;
  end;
  
  member function f_index(prm_ds_item varchar2) 
    return integer
  is
    aux_nr_index integer;
  begin
    if f_qtd_itens() > 0 then
      aux_nr_index := self.vt_lista.first;
      while aux_nr_index is not null loop
        if self.vt_lista(aux_nr_index).ds_item = prm_ds_item then
          return aux_nr_index;
        end if;
        aux_nr_index := self.vt_lista.next(aux_nr_index);
      end loop;
    end if;
    return 0;
  end;
  
  member function f_index(prm_ds_item number) 
    return integer
  is
    aux_nr_index integer;
  begin
    if f_qtd_itens() > 0 then
      aux_nr_index := self.vt_lista.first;
      while aux_nr_index is not null loop
        if self.vt_lista(aux_nr_index).nr_item = prm_ds_item then
          return aux_nr_index;
        end if;
        aux_nr_index := self.vt_lista.next(aux_nr_index);
      end loop;
    end if;
    return 0;
  end;
  
  member function f_index(prm_ds_item date) 
    return integer
  is
    aux_nr_index integer;
  begin
    if f_qtd_itens() > 0 then
      aux_nr_index := self.vt_lista.first;
      while aux_nr_index is not null loop
        if self.vt_lista(aux_nr_index).dt_item = prm_ds_item then
          return aux_nr_index;
        end if;
        aux_nr_index := self.vt_lista.next(aux_nr_index);
      end loop;
    end if;
    return 0;
  end;
  
  
  member function f_qtd_itens 
    return integer
  is
  begin
    return self.vt_lista.count;
  end;
  
  member function f_item_ds(prm_nr_index integer) 
    return varchar2
  is
  begin
    return self.vt_lista(prm_nr_index).ds_item;
  end;
  
  member function f_item_nr(prm_nr_index integer) 
    return number
  is
  begin
    return self.vt_lista(prm_nr_index).nr_item;
  end;
  
  member function f_item_dt(prm_nr_index integer) 
    return date
  is
  begin
    return self.vt_lista(prm_nr_index).dt_item;
  end;
  
  member procedure p_crescente
  is
  begin
    null;
  end;
  
  member procedure p_decrescente
  is
  begin
    null;
  end;
  
  member function f_para_string(prm_ds_separador varchar2 default ',') 
    return varchar2
  is
  begin
    return null;
  end;
  
  member procedure p_de_string(prm_ds_lista varchar2, prm_ds_separador varchar2 default ',')
  is
  begin
    null;
  end;
  
  member procedure p_limpar
  is
  begin
    self.vt_lista.delete;
  end;
  
end;
/
