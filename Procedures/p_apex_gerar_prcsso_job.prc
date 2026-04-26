create or replace procedure p_apex_gerar_prcsso_job(prm_cd_prcsso processo.cd_prcsso%type,
                                                    prm_ds_params varchar2) 
is
  aux_vt_lista   k_lista.typ_lista;
  aux_cd_geracao geracao_prcsso.nr_sequencia%type;
begin
  k_lista.p_criar_lista(prm_ds_string    => prm_ds_params,
                        prm_vt_lista     => aux_vt_lista,
                        prm_ds_separador => k_processo.cns_ds_sep,
                        prm_vf_trim      => false);
  
  k_processo.p_salvar(prm_cd_prcsso        => prm_cd_prcsso,
                      prm_dt_geracao       => sysdate,
                      prm_cd_usuario       => f_buscar_usuario_ativo,
                      prm_dm_geracao       => 'S',
                      prm_cd_prcsso_origem => null,
                      prm_cd_geracao       => aux_cd_geracao);
                      
  for aux_i in 1 .. aux_vt_lista.count loop
    k_processo.p_salvar_param(prm_cd_geracao => aux_cd_geracao,
                              prm_nr_seq_prm => aux_i,
                              prm_ds_valor   => aux_vt_lista(aux_i));
  end loop;
  
  commit;
  
  k_processo.p_processar(prm_cd_geracao => aux_cd_geracao);
  
  apex_application.g_print_success_message := 'Processo '||aux_cd_geracao||' será gerado em segundo plano.';
  
  commit;
  
end p_apex_gerar_prcsso_job;
/
