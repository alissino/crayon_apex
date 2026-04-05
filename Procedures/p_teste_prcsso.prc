create or replace procedure p_teste_prcsso(prm_cd_geracao in geracao_prcsso.nr_sequencia%type)
is
  aux_ds_nome      varchar2(45);
  aux_ds_sobrenome varchar2(45);
  aux_ds_erro      k_processo.typ_ds_erro;
begin
  
  k_processo.p_validar(prm_cd_geracao, aux_ds_erro);
  if aux_ds_erro is not null then
    raise k_processo.e_validacao;
  end if;
  
  k_processo.p_buscar_prm(prm_cd_geracao, 1, aux_ds_nome);
  k_processo.p_buscar_prm(prm_cd_geracao, 2, aux_ds_sobrenome);
  
  dbms_output.put_line('Olá '||aux_ds_nome||' '||aux_ds_sobrenome);
  
exception
  when k_processo.e_validacao then
    k_processo.p_salvar_erro(prm_cd_geracao, aux_ds_erro);
  when others then
    k_processo.p_salvar_erro(prm_cd_geracao, substr(dbms_utility.format_error_stack, 1, 4000));
end p_teste_prcsso;
/
