create or replace trigger tgr_relatorio_pagina
  after insert
  on relatorio_pagina 
  for each row
declare
  cursor cur_params
      is select r.cd_processo,
                pp.nr_sequencia,
                pp.ds_val_padrao
           from processo_param pp,
                relatorio      r
          where r.cd_processo  = pp.cd_prcsso
            and r.cd_relatorio = :new.cd_relatorio;
begin
  delete
    from relatorio_pagina_param rpp
   where rpp.nr_seq_relat_pag = :new.nr_sequencia;
  
  for r_prm in cur_params loop
    insert
      into relatorio_pagina_param
          (nr_seq_relat_pag,
           cd_processo,
           nr_seq_prcsso_prm,
           ds_val_padrao)
    values(:new.nr_sequencia,
           r_prm.cd_processo,
           r_prm.nr_sequencia,
           r_prm.ds_val_padrao);
  end loop;
  
end tgr_relatorio_pagina;
/
