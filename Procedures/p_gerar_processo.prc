create or replace procedure p_gerar_processo(prm_cd_geracao in geracao_prcsso.nr_sequencia%type,
                                             prm_dm_modo    in char default 'I')
is
begin
  k_processo.p_processar(prm_cd_geracao => prm_cd_geracao, prm_dm_modo => prm_dm_modo);
end p_gerar_processo;
/
