create or replace package k_lista is
  
  subtype typ_separador is varchar2(3) not null;
  subtype typ_valor     is varchar2(4000);
  subtype typ_string    is varchar2(32767);  
  type    typ_lista     is table of typ_valor;
  type    typ_lista_i   is table of typ_valor index by pls_integer;
  type    typ_lista_v   is table of typ_valor index by varchar2(45);
  
  cns_ds_sep constant typ_separador := ';';
  
  procedure p_criar_lista(prm_ds_string    in  typ_string,
                          prm_vt_lista     out nocopy typ_lista,
                          prm_ds_separador in  typ_separador default cns_ds_sep,
                          prm_vf_trim      in  boolean       default true);
                          
  procedure p_criar_lista_i(prm_ds_string    in  typ_string,
                            prm_vt_lista     out typ_lista,
                            prm_ds_separador in  typ_separador default cns_ds_sep);
  
  procedure p_criar_lista_v(prm_ds_string    in  typ_string,
                            prm_vt_lista     out typ_lista,
                            prm_ds_separador in  typ_separador default cns_ds_sep);

end k_lista;
/
