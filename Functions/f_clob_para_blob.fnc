create or replace function f_clob_para_blob(prm_clob clob) 
return blob
is
  aux_blob blob;
  aux_nr_dest integer := 1;
  aux_nr_src  integer := 1;
  aux_nr_lang integer := dbms_lob.default_lang_ctx;
  aux_nr_warn integer;
begin
  dbms_lob.createtemporary(aux_blob, true, dbms_lob.session);
  dbms_lob.convertToBlob(dest_lob     => aux_blob,
                         src_clob     => prm_clob,
                         amount       => dbms_lob.getlength(prm_clob),
                         dest_offset  => aux_nr_dest,
                         src_offset   => aux_nr_src,
                         blob_csid    => dbms_lob.default_csid,
                         lang_context => aux_nr_lang,
                         warning      => aux_nr_warn);
  
  return aux_blob;
exception
  when others then
    if dbms_lob.istemporary(aux_blob) = 1 then
      dbms_lob.freetemporary(aux_blob);
    end if;
    raise;
end f_clob_para_blob;
/
