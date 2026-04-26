create or replace package k_cfop is

  procedure p_importar_csv(prm_cd_geracao geracao_prcsso.nr_sequencia%type);
  
  function f_buscar_desc(prm_cd_cfop cfop.cd_cfop%type)
    return cfop.ds_cfop%type;
    
  

end k_cfop;
/
create or replace package body k_cfop is

  procedure p_importar_csv(prm_cd_geracao geracao_prcsso.nr_sequencia%type)
    is
      type typ_rc_cfop is record(cd_cfop cfop.cd_cfop%type,
                                 ds_cfop cfop.ds_cfop%type,
                                 dt_vig  cfop.dt_vigencia%type);
      
      aux_ds_arquivo   varchar2(400);
      aux_ds_separador char(1);
      aux_dm_cabecalho char(1);
      aux_cd_diretorio varchar2(45);
      aux_cursor       sys_refcursor;
      aux_conteudo     blob;
      aux_bfile        bfile;
      aux_nr_offset_d  integer := 1;
      aux_nr_offset_s  integer := 1;
      aux_rc_cfop      typ_rc_cfop;
      aux_nr_cont      pls_integer;
    begin
      k_processo.p_buscar_prm(prm_cd_geracao, 1, aux_ds_arquivo);
      k_processo.p_buscar_prm(prm_cd_geracao, 2, aux_ds_separador);
      k_processo.p_buscar_prm(prm_cd_geracao, 3, aux_dm_cabecalho);
      k_processo.p_buscar_prm(prm_cd_geracao, 4, aux_cd_diretorio);
      
      aux_bfile := bfilename(aux_cd_diretorio, aux_ds_arquivo);
      dbms_lob.createtemporary(aux_conteudo, true, dbms_lob.call);
      dbms_lob.fileopen(aux_bfile, dbms_lob.file_readonly);
      dbms_lob.loadblobfromfile(dest_lob    => aux_conteudo,
                                src_bfile   => aux_bfile,
                                amount      => dbms_lob.lobmaxsize,
                                dest_offset => aux_nr_offset_d,
                                src_offset  => aux_nr_offset_s);
      
      open aux_cursor for 
        select col001 cd_cfop,
               substr(col002, 1, 200) ds_cfop,
               to_date(col003, 'dd/mm/yyyy') dt_vig
          from table(apex_data_parser.parse(p_content           => aux_conteudo,
                                            p_file_name         => aux_ds_arquivo,
                                            p_csv_col_delimiter => aux_ds_separador,
                                            p_skip_rows         => case aux_dm_cabecalho
                                                                     when 'S' then 1
                                                                     else null
                                                                   end));
      
      loop
        fetch aux_cursor into aux_rc_cfop.cd_cfop,
                              aux_rc_cfop.ds_cfop,
                              aux_rc_cfop.dt_vig;
        exit when aux_cursor%notfound;
        
        select count(1)
          into aux_nr_cont
          from cfop
         where cd_cfop = aux_rc_cfop.cd_cfop;
        
        if nvl(aux_nr_cont, 0) = 0 then
          insert
            into cfop
                (cd_cfop,
                 ds_cfop,
                 dt_vigencia,
                 dm_situacao)
          values(aux_rc_cfop.cd_cfop,
                 aux_rc_cfop.ds_cfop,
                 aux_rc_cfop.dt_vig,
                 k_dominio.f_val_padrao('cfop', 'dm_situacao'));
        else
          update cfop c
             set c.ds_cfop     = aux_rc_cfop.ds_cfop,
                 c.dt_vigencia = aux_rc_cfop.dt_vig
           where c.cd_cfop     = aux_rc_cfop.cd_cfop;
        end if;
        
      end loop;
      
      close aux_cursor;
      
      dbms_lob.freetemporary(aux_conteudo);
      dbms_lob.fileclose(aux_bfile);
      commit;
    end p_importar_csv;
  
  function f_buscar_desc(prm_cd_cfop cfop.cd_cfop%type)
    return cfop.ds_cfop%type
    is
      aux_ds_cfop cfop.ds_cfop%type;
    begin
      select c.ds_cfop
        into aux_ds_cfop
        from cfop c
       where c.cd_cfop = prm_cd_cfop;
      return aux_ds_cfop;
    end f_buscar_desc;
    
  
end k_cfop;
/
