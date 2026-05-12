create or replace package k_forma_pagamento is

  type typ_rc_parcela is record (nr_parcela number,
                                 vl_parcela number(15,2),
                                 ds_parcela varchar2(100));
  
  type typ_vt_parcelas is table of typ_rc_parcela;
  
  function f_buscar_parcelas(prm_nr_sequencia forma_pagamento.nr_sequencia%type,
                             prm_vl_total     number)
    return typ_vt_parcelas pipelined;
  
  function f_parcela(prm_nr_sequencia forma_pagamento.nr_sequencia%type)
    return boolean;
  
  function f_troco(prm_nr_sequencia forma_pagamento.nr_sequencia%type)
    return boolean;

end k_forma_pagamento;
/
create or replace package body k_forma_pagamento is

  function f_buscar_parcelas(prm_nr_sequencia forma_pagamento.nr_sequencia%type,
                             prm_vl_total     number)
    return typ_vt_parcelas pipelined
    is
      aux_rc_parcela  typ_rc_parcela;
      aux_qt_parcelas forma_pagamento.nr_max_parcelas%type;
      aux_vl_parcela  number(15,2);
    begin
      select fp.nr_max_parcelas
        into aux_qt_parcelas
        from forma_pagamento fp
       where fp.nr_sequencia = prm_nr_sequencia
         and fp.fg_parcela   = 'S';
      
      for aux_nr_parcela in 1 .. aux_qt_parcelas loop
        
        aux_vl_parcela := prm_vl_total / aux_nr_parcela;
        
        aux_rc_parcela.nr_parcela := aux_nr_parcela;
        aux_rc_parcela.vl_parcela := aux_vl_parcela;
        aux_rc_parcela.ds_parcela := aux_nr_parcela || 'x de ' || to_char(aux_vl_parcela, 'FM999G999G990D00');
        
        pipe row (aux_rc_parcela);
      end loop;
      return;
    end;
    
  function f_parcela(prm_nr_sequencia forma_pagamento.nr_sequencia%type)
    return boolean
    is
      aux_fg_parcela forma_pagamento.fg_parcela%type;
    begin
      select max(fp.fg_parcela)
        into aux_fg_parcela
        from forma_pagamento fp
       where fp.nr_sequencia = prm_nr_sequencia;
      
      return nvl(aux_fg_parcela, 'N') = 'S';
    end f_parcela;
  
  function f_troco(prm_nr_sequencia forma_pagamento.nr_sequencia%type)
    return boolean
    is
      aux_fg_troco forma_pagamento.fg_troco%type;
    begin
      select max(fp.fg_troco)
        into aux_fg_troco
        from forma_pagamento fp
       where fp.nr_sequencia = prm_nr_sequencia;
      
      return nvl(aux_fg_troco, 'N') = 'S';
    end f_troco;

end k_forma_pagamento;
/
