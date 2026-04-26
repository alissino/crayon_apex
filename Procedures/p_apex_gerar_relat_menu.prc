create or replace procedure p_apex_gerar_relat_menu(prm_nr_sequencia relatorio_pagina.nr_sequencia%type,
                                                    prm_ds_params    varchar2) 
is
  aux_dm_solic_param relatorio_pagina.dm_solic_param%type;
  aux_cd_processo    processo.cd_prcsso%type;
  aux_cd_geracao     geracao_prcsso.nr_sequencia%type;
  aux_vf_erro        boolean;
  aux_ds_url         varchar2(4000);
begin
  select rp.dm_solic_param,
         r.cd_processo
    into aux_dm_solic_param,
         aux_cd_processo
    from relatorio_pagina rp,
         relatorio        r
   where r.cd_relatorio  = rp.cd_relatorio
     and rp.nr_sequencia = prm_nr_sequencia;
  
  if aux_dm_solic_param = 'S' then
    aux_ds_url := apex_page.get_url(p_page        => 2,
                                    p_items       => 'P2_CD_PRCSSO,P2_DS_PARAMS',
                                    p_values      => aux_cd_processo||','||prm_ds_params,
                                    p_clear_cache => '2');
  else
    k_processo.p_processar_agora(prm_cd_prcsso     => aux_cd_processo,
                                 prm_cd_prcsso_ori => null,
                                 prm_ds_params     => prm_ds_params,
                                 prm_cd_geracao    => aux_cd_geracao,
                                 prm_vf_erro       => aux_vf_erro);
    
    aux_ds_url := apex_page.get_url(p_page   => 13,
                                    p_items  => 'P13_NR_SEQUENCIA',
                                    p_values => aux_cd_geracao);
  end if;
  
  apex_json.open_object;
  apex_json.write('url', aux_ds_url);
  apex_json.close_object;

  
end p_apex_gerar_relat_menu;
/
