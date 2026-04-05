create or replace type t_arquivo as object
(
  cd_arquivo      number,
  ds_nome         varchar2(100),
  ds_extencao     varchar2(10),
  ds_path         varchar2(256),
  ds_ora_dir      varchar2(20),
  ds_quebra_linha varchar2(5),
  vt_linhas       t_arquivo_linha_vet,
  
  constructor function t_arquivo return self as result,
  constructor function t_arquivo(prm_cd_arquivo number) return self as result,
  constructor function t_arquivo(prm_ds_nome varchar2, prm_ds_extencao varchar2, prm_ds_path varchar2, prm_ds_ora_dir varchar2) return self as result,

  member procedure p_add_linha(prm_ds_linha clob, prm_nr_linha out number),
  
  member procedure p_sub_linha(prm_ds_linha clob, prm_nr_linha number),
  
  member procedure p_acr_linha(prm_ds_valor clob, prm_nr_linha number),
  
  member procedure p_del_linha(prm_nr_linha number),
  
  member procedure p_salvar,
  member procedure p_criar,
  
  member procedure p_carregar,
  
  member function f_valid_linha(prm_nr_linha number) return boolean,
  
  member procedure p_valid_linha_err(prm_nr_linha number),

  member function f_nome return varchar2,
  
  member function f_path return varchar2
  
)
/
create or replace type body t_arquivo is
  
  constructor function t_arquivo 
    return self as result
    is
    begin
      self.cd_arquivo      := null;
      self.ds_nome         := null;
      self.ds_extencao     := null;
      self.ds_path         := null;
      self.ds_ora_dir      := null;
      self.ds_quebra_linha := chr(13)||chr(10);
      self.vt_linhas       := t_arquivo_linha_vet();
      
      return;
    end;
    
  constructor function t_arquivo(prm_cd_arquivo number) 
    return self as result
    is
    begin
      self := t_arquivo;
      if prm_cd_arquivo is null then
        p_mostra_erro('Código do arquivo não informado.');
      end if;
      
      self.p_carregar;
      
      return;
    end;
    
  constructor function t_arquivo(prm_ds_nome     varchar2, 
                                 prm_ds_extencao varchar2, 
                                 prm_ds_path     varchar2, 
                                 prm_ds_ora_dir  varchar2) 
    return self as result
    is
    begin
      self := t_arquivo;
      self.ds_nome     := prm_ds_nome;
      self.ds_extencao := prm_ds_extencao;
      self.ds_path     := prm_ds_path;
      self.ds_ora_dir  := upper(prm_ds_ora_dir);
      if prm_ds_path is null then
        select ad.directory_path
          into self.ds_path
          from all_directories ad
         where ad.directory_name = self.ds_ora_dir;
      end if;
      return;
    end;
    

  member procedure p_add_linha(prm_ds_linha clob, prm_nr_linha out number)
    is
    begin
      self.vt_linhas.extend;
      prm_nr_linha := self.vt_linhas.count;
      self.vt_linhas(prm_nr_linha) := prm_ds_linha;
    end;
  
  member procedure p_sub_linha(prm_ds_linha clob, prm_nr_linha number)
    is
    begin
      self.p_valid_linha_err(prm_nr_linha);
      
      self.vt_linhas(prm_nr_linha) := prm_ds_linha;
      
    end;
  
  member procedure p_acr_linha(prm_ds_valor clob, prm_nr_linha number)
    is
      aux_ds_temp  clob;
    begin
    
      p_valid_linha_err(prm_nr_linha);  
    
      dbms_lob.createtemporary(aux_ds_temp, 
                               true, 
                               dbms_lob.call);
      dbms_lob.writeappend(lob_loc => aux_ds_temp, 
                           amount  => dbms_lob.getlength(self.vt_linhas(prm_nr_linha)), 
                           buffer  => self.vt_linhas(prm_nr_linha));
      dbms_lob.writeappend(lob_loc => aux_ds_temp,
                           amount  => dbms_lob.getlength(prm_ds_valor),
                           buffer  => prm_ds_valor);
      
      self.vt_linhas(prm_nr_linha) := aux_ds_temp;
      
      dbms_lob.freetemporary(aux_ds_temp);
    
    exception
      when others then
        if nvl(dbms_lob.istemporary(aux_ds_temp), 0) <> 0 then
          dbms_lob.freetemporary(aux_ds_temp);
        end if;
        raise;
      
    end;
    
  
  member procedure p_del_linha(prm_nr_linha number)
    is
      aux_vt_linhas t_arquivo_linha_vet := t_arquivo_linha_vet();
      aux_nr_linha  number;
    begin
      self.p_valid_linha_err(prm_nr_linha);
      self.vt_linhas.delete(prm_nr_linha);
      
      if prm_nr_linha = self.vt_linhas.last + 1 or self.vt_linhas.count = 0 then
        return;
      end if;
      
      aux_nr_linha := self.vt_linhas.first;
      
      while aux_nr_linha is not null loop
        aux_vt_linhas.extend;
        aux_vt_linhas(aux_vt_linhas.count) := self.vt_linhas(aux_nr_linha);
        aux_nr_linha := self.vt_linhas.next(aux_nr_linha);
      end loop;
      self.vt_linhas := aux_vt_linhas;
      
    end;
    
  
  member procedure p_salvar
    is
      aux_cd_arquivo number;
      aux_qt_linhas  number;
    begin
      if self.vt_linhas is null or self.vt_linhas.count = 0 then
        p_mostra_erro('Não há dados no arquivo.');  
      end if;
      
      aux_qt_linhas := self.vt_linhas.count;
      
      if self.cd_arquivo is null then
        insert
          into arquivo
              (ds_nome,
               ds_extencao,
               ds_path,
               ds_ora_dir,
               ds_quebra_linha)
        values(self.ds_nome,
               self.ds_extencao,
               self.ds_path,
               self.ds_ora_dir,
               self.ds_quebra_linha)
        returning cd_arquivo into aux_cd_arquivo;
        
        for linha in 1 .. aux_qt_linhas loop
          insert
            into arquivo_linha
                (cd_arquivo,
                 nr_linha,
                 ds_linha)
          values(aux_cd_arquivo,
                 linha,
                 self.vt_linhas(linha));
        end loop;
        self.cd_arquivo := aux_cd_arquivo;
      else
        update arquivo a
           set a.ds_nome         = self.ds_nome,
               a.ds_extencao     = self.ds_extencao,
               a.ds_path         = self.ds_path,
               a.ds_ora_dir      = self.ds_ora_dir,
               a.ds_quebra_linha = self.ds_quebra_linha
         where a.cd_arquivo      = self.cd_arquivo;
        
        for linha in 1 .. aux_qt_linhas loop
          update arquivo_linha al
             set al.ds_linha   = self.vt_linhas(linha)
           where al.cd_arquivo = self.cd_arquivo
             and al.nr_linha   = linha;
          if sql%rowcount = 0 then
            insert
              into arquivo_linha
                  (cd_arquivo,
                   nr_linha,
                   ds_linha)
            values(self.cd_arquivo,
                   linha,
                   self.vt_linhas(linha));
          end if;
        end loop;
        delete
          from arquivo_linha al
         where al.cd_arquivo = self.cd_arquivo
           and al.nr_linha   > aux_qt_linhas;
      end if;
    exception
      when others then
        raise;
    end;
    
  member procedure p_criar
    is
      cns_nr_limt    constant number := 32767;
      aux_tp_arquivo utl_file.file_type;
      aux_ds_linha   clob;
      aux_nr_pos     number;
      aux_nr_tamanho number;
      aux_ds_buffer  varchar2(cns_nr_limt);
    begin
      if self.vt_linhas is null or self.vt_linhas.count = 0 then
        p_mostra_erro('Não há dados para o arquivo.');
      end if;
      
      aux_tp_arquivo := utl_file.fopen(location     => self.ds_ora_dir,
                                       filename     => self.f_path,
                                       open_mode    => 'w',
                                       max_linesize => cns_nr_limt);
      
      if self.vt_linhas.count > 0 then
        for linha in 1 .. self.vt_linhas.count loop
          if self.vt_linhas.exists(linha) then
            aux_nr_pos     := 1;
            aux_nr_tamanho := dbms_lob.getlength(self.vt_linhas(linha));
            
            dbms_lob.createtemporary(lob_loc => aux_ds_linha,
                                     cache   => true,
                                     dur     => dbms_lob.call);
            dbms_lob.write(lob_loc => aux_ds_linha,
                           amount  => aux_nr_tamanho,
                           offset  => 1,
                           buffer  => self.vt_linhas(linha));
            
            while aux_nr_pos <= aux_nr_tamanho loop
              aux_ds_buffer := dbms_lob.substr(lob_loc => aux_ds_linha,
                                               amount  => cns_nr_limt,
                                               offset  => aux_nr_pos);
              aux_nr_pos := aux_nr_pos + cns_nr_limt;
              utl_file.put(file   => aux_tp_arquivo, 
                           buffer => aux_ds_buffer);
            end loop;
            dbms_lob.freetemporary(aux_ds_linha);
          end if;
          utl_file.new_line(file => aux_tp_arquivo);
          utl_file.fflush(aux_tp_arquivo);
        end loop;
      end if;
      utl_file.fclose(aux_tp_arquivo);
    exception
      when others then
        if utl_file.is_open(aux_tp_arquivo) then
          utl_file.fclose(aux_tp_arquivo);
        end if;
        if nvl(dbms_lob.istemporary(aux_ds_linha), 0) <> 0 then
          dbms_lob.freetemporary(aux_ds_linha);
        end if;
        raise;
    end;
  
  member procedure p_carregar
   is
   begin
     null;
   end;
   
  member function f_valid_linha(prm_nr_linha number) 
    return boolean
    is
    begin
      if prm_nr_linha between 1 and self.vt_linhas.count then
        return true;
      end if;
      return false;
    exception
      when others then
        return false;
    end;
  
  member procedure p_valid_linha_err(prm_nr_linha number)
    is
    begin
      if self.f_valid_linha(prm_nr_linha) then
        return;
      end if;
      p_mostra_erro('Linha '||prm_nr_linha||' não encontrada.');
    end;
  
  member function f_nome
    return varchar2
    is
    begin
      return self.ds_nome || '.' || self.ds_extencao;
    end;
    
  member function f_path
    return varchar2
    is
    begin
      return self.ds_path || '/' || f_nome;
    end;
  
end;
/
