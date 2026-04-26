create or replace procedure p_upload_arquivo_apex(prm_cd_arquivo   in     apex_application_temp_files.name%type,
                                                  prm_cd_diretorio in out varchar2,
                                                  prm_ds_nome      out    varchar2) 
is
  aux_conteudo blob;
  aux_file     utl_file.file_type;
  aux_buffer   raw(32767);
  aux_amount   binary_integer := 32767;
  aux_pos      integer := 1;
  aux_blob_len integer;
begin
  
  prm_cd_diretorio := nvl(prm_cd_diretorio, 'DIR_TEMP');
  
  -- 1. busca o conteúdo do arquivo enviado pelo apex
  select blob_content,
         filename
    into aux_conteudo,
         prm_ds_nome
    from apex_application_temp_files
   where name = prm_cd_arquivo;

  aux_blob_len := dbms_lob.getlength(aux_conteudo);
        
  aux_file := utl_file.fopen(prm_cd_diretorio, prm_ds_nome, 'wb', 32767);

  while aux_pos <= aux_blob_len loop
    dbms_lob.read(aux_conteudo, aux_amount, aux_pos, aux_buffer);
    utl_file.put_raw(aux_file, aux_buffer, true);
    aux_pos := aux_pos + aux_amount;
  end loop;

  utl_file.fclose(aux_file);
exception
  when others then
    if utl_file.is_open(aux_file) then
      utl_file.fclose(aux_file);
    end if;
end p_upload_arquivo_apex;
/
