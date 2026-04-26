create or replace package k_ncm is

  procedure p_salvar_arquivo(prm_ds_arquivo varchar2,
                             prm_ds_nome    out varchar2);
  
  procedure p_carregar_json_ncm(prm_cd_geracao geracao_prcsso.nr_sequencia%type);
  
  function f_monta_descricao(prm_cd_ncm ncm.cd_ncm%type)
    return ncm.ds_descricao%type;

end k_ncm;
/
create or replace package body k_ncm is

  procedure p_salvar_arquivo(prm_ds_arquivo varchar2,
                             prm_ds_nome    out varchar2)
    is
      aux_bl_conteudo blob;
      aux_file        utl_file.file_type;
      aux_buffer      raw(32767);
      aux_amount      binary_integer := 32767;
      aux_pos         integer := 1;
      aux_blob_len    integer;
  begin
      -- 1. busca o conteúdo do arquivo enviado pelo apex
      select blob_content,
             filename
        into aux_bl_conteudo,
             prm_ds_nome
        from apex_application_temp_files
       where name = prm_ds_arquivo;

      aux_blob_len := dbms_lob.getlength(aux_bl_conteudo);
      
      aux_file := utl_file.fopen('DIR_TEMP', prm_ds_nome, 'wb', 32767);

      while aux_pos <= aux_blob_len loop
        dbms_lob.read(aux_bl_conteudo, aux_amount, aux_pos, aux_buffer);
        utl_file.put_raw(aux_file, aux_buffer, true);
        aux_pos := aux_pos + aux_amount;
      end loop;

      utl_file.fclose(aux_file);
    exception
      when others then
        if utl_file.is_open(aux_file) then
          utl_file.fclose(aux_file);
        end if;
        
    end;

  procedure p_carregar_json_ncm(prm_cd_geracao geracao_prcsso.nr_sequencia%type)
    is
      aux_ds_arquivo  varchar2(256);
      aux_bl_conteudo blob;
      aux_nr_cont     pls_integer;
      aux_bfile       bfile;
      aux_nr_offset_d integer := 1;
      aux_nr_offset_s integer := 1;
      cursor cur_ncms
          is select jt.codigo, 
                    jt.descricao, 
                    to_date(jt.data_inicio, 'DD/MM/YYYY') dt_inicio, 
                    to_date(jt.data_fim, 'DD/MM/YYYY')    dt_termino
               from json_table(aux_bl_conteudo, '$.Nomenclaturas[*]'
                               columns(codigo      varchar2(20)   path '$.Codigo',
                                       descricao   varchar2(4000) path '$.Descricao',
                                       data_inicio varchar2(10)   path '$.Data_Inicio',
                                       data_fim    varchar2(10)   path '$.Data_Fim')) jt;
      
    begin
      k_processo.p_buscar_prm(prm_cd_geracao, 1, aux_ds_arquivo);
      
      aux_bfile := bfilename('DIR_TEMP', aux_ds_arquivo);
      dbms_lob.createtemporary(aux_bl_conteudo, true);
      dbms_lob.fileopen(aux_bfile, dbms_lob.file_readonly);
      dbms_lob.loadblobfromfile(dest_lob    => aux_bl_conteudo,
                                src_bfile   => aux_bfile,
                                amount      => dbms_lob.lobmaxsize,
                                dest_offset => aux_nr_offset_d,
                                src_offset  => aux_nr_offset_s);
      
      for ncm in cur_ncms loop
        select count(1)
          into aux_nr_cont
          from ncm n
         where n.cd_ncm = ncm.codigo;
        
        if nvl(aux_nr_cont, 0) = 0 then
          insert
            into ncm
                (cd_ncm,
                 ds_descricao,
                 dt_inicio,
                 dt_termino)
          values(ncm.codigo,
                 ncm.descricao,
                 ncm.dt_inicio,
                 ncm.dt_termino);
        else
          update ncm n
             set n.ds_descricao = ncm.descricao,
                 n.dt_inicio    = ncm.dt_inicio,
                 n.dt_termino   = ncm.dt_termino
           where n.cd_ncm = ncm.codigo;
        end if;
        
      end loop;
      DBMS_LOB.FILECLOSE(aux_bfile);
      DBMS_LOB.FREETEMPORARY(aux_bl_conteudo);
      commit;
    exception
      when others then
        k_processo.p_salvar_erro(prm_cd_geracao, sqlerrm);
    
    end;
    
  function f_monta_descricao(prm_cd_ncm ncm.cd_ncm%type)
    return ncm.ds_descricao%type
    is
      aux_cd_limpo    ncm.cd_ncm%type;
      aux_ds_completa ncm.ds_descricao%type;
      aux_ds_nivel    ncm.ds_descricao%type;
    begin
      if prm_cd_ncm is null then
        return null;
      end if;
      aux_cd_limpo := replace(prm_cd_ncm, '.', '');
      
      for i in 1 .. length(aux_cd_limpo) / 2 loop
        declare
          aux_ds_prefixo ncm.cd_ncm%type;
          aux_nr_tamanho integer;
        begin
          aux_nr_tamanho := i * 2;
          aux_ds_prefixo := substr(aux_cd_limpo, 1, aux_nr_tamanho);
          
          select n.ds_descricao
            into aux_ds_nivel
            from ncm n
           where replace(n.cd_ncm, '.', '') = aux_ds_prefixo;
          
          aux_ds_completa := aux_ds_completa || ' ' || aux_ds_nivel;
        
        end;
      end loop;
      return aux_ds_completa;
    end;
    
end k_ncm;
/
