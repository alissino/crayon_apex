create or replace procedure p_gerar_processo_agr(prm_cd_prcsso     in  geracao_prcsso.cd_prcsso%type,
                                                 prm_cd_prcsso_ori in  geracao_prcsso.cd_prcsso_origem%type,
                                                 prm_ds_params     in  varchar2,
                                                 prm_cd_geracao    out geracao_prcsso.nr_sequencia%type,
                                                 prm_vf_erro       out boolean) 
is
begin
  k_processo.p_processar_agora(prm_cd_prcsso     => prm_cd_prcsso,
                               prm_cd_prcsso_ori => prm_cd_prcsso_ori,
                               prm_ds_params     => prm_ds_params,
                               prm_cd_geracao    => prm_cd_geracao,
                               prm_vf_erro       => prm_vf_erro);
end p_gerar_processo_agr;
/
