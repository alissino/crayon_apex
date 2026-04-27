create or replace force view v_pessoa as
select p.cd_pessoa,
         p.dm_tipo,
         k_pessoa.f_buscar_nome(p.cd_pessoa) ds_nome,
         p.ds_fantasia,
         p.dt_nascimento,
         k_pessoa.f_buscar_doc(p.cd_pessoa,
                               case p.dm_tipo
                                 when 'PF' then 'CPF'
                                 when 'PJ' then 'CNPJ'
                               end,
                               true) ds_documento,
         p.dm_sexo
    from pessoa p
   order by 3;

