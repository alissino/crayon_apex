create or replace procedure p_gerar_processo(prm_cd_geracao in geracao_prcsso.nr_sequencia%type)
is
begin
  k_processo.p_processar(prm_cd_geracao => prm_cd_geracao);
end p_gerar_processo;
/
