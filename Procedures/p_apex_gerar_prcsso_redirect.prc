create or replace procedure p_apex_gerar_prcsso_redirect(prm_cd_processo processo.cd_prcsso%type,
                                                         prm_ds_params   varchar2) 
is
  aux_cd_geracao geracao_prcsso.nr_sequencia%type;
  aux_vf_erro    boolean;
  aux_ds_url     varchar2(4000);
begin
  
  k_processo.p_processar_agora(prm_cd_prcsso     => prm_cd_processo,
                               prm_cd_prcsso_ori => null,
                               prm_ds_params     => prm_ds_params,
                               prm_cd_geracao    => aux_cd_geracao,
                               prm_vf_erro       => aux_vf_erro);
                               
  aux_ds_url := apex_page.get_url(p_page   => 13,
                                  p_items  => 'P13_NR_SEQUENCIA',
                                  p_values => aux_cd_geracao);
  apex_util.redirect_url(aux_ds_url);
  
end p_apex_gerar_prcsso_redirect;
/
