create or replace package k_estoque is

  function f_buscar_estoque(prm_cd_produto produto.cd_produto%type,
                            prm_cd_local   local_estoque.cd_local%type)
    return produto_estoque.nr_quantidade%type;
  
  procedure p_salvar_mov(prm_cd_produto   movimento_estoque.cd_produto%type,
                         prm_cd_local     movimento_estoque.cd_local%type,
                         prm_dm_movimento movimento_estoque.dm_movimento%type,
                         prm_qt_movimento movimento_estoque.qt_movimento%type,
                         prm_ds_movimento movimento_estoque.ds_movimento%type,
                         prm_cd_usuario   movimento_estoque.cd_usuario%type default null);

end k_estoque;
/
create or replace package body k_estoque is

  procedure p_atualizar_prodest(prm_cd_produto produto_estoque.cd_produto%type,
                                prm_cd_local   produto_estoque.cd_local%type,
                                prm_qt_estoque produto_estoque.nr_quantidade%type)
    is
      aux_existe number;
    begin
        
      select count(1)
        into aux_existe
        from produto_estoque pe
       where pe.cd_produto = prm_cd_produto
         and pe.cd_local   = prm_cd_local;
         
      if nvl(aux_existe, 0) = 0 then
        insert 
          into produto_estoque
              (cd_produto,
               cd_local,
               nr_quantidade)
        values(prm_cd_produto,
               prm_cd_local,
               0);
      end if;
      
      update produto_estoque pe
         set pe.nr_quantidade = prm_qt_estoque
       where pe.cd_produto = prm_cd_produto
         and pe.cd_local   = prm_cd_local;
      
    end;

  function f_buscar_estoque(prm_cd_produto produto.cd_produto%type,
                            prm_cd_local   local_estoque.cd_local%type)
    return produto_estoque.nr_quantidade%type
    is
      aux_qt_estoque produto_estoque.nr_quantidade%type;
    begin
      select v.qt_estoque
        into aux_qt_estoque
        from v_produto_estoque v
       where v.cd_produto = prm_cd_produto
         and v.cd_local   = prm_cd_local;
      return aux_qt_estoque;
    end;
  
  procedure p_salvar_mov(prm_cd_produto   movimento_estoque.cd_produto%type,
                         prm_cd_local     movimento_estoque.cd_local%type,
                         prm_dm_movimento movimento_estoque.dm_movimento%type,
                         prm_qt_movimento movimento_estoque.qt_movimento%type,
                         prm_ds_movimento movimento_estoque.ds_movimento%type,
                         prm_cd_usuario   movimento_estoque.cd_usuario%type default null)
    is
      aux_qt_atual  produto_estoque.nr_quantidade%type;
      aux_qt_antiga produto_estoque.nr_quantidade%type;
      aux_qt_nova   produto_estoque.nr_quantidade%type;
    begin
      aux_qt_atual  := f_buscar_estoque(prm_cd_produto, prm_cd_local);
      aux_qt_antiga := aux_qt_atual;
      
      if prm_dm_movimento = 'E' then
        aux_qt_nova := aux_qt_atual + prm_qt_movimento;
        
      elsif prm_dm_movimento = 'S' then
        aux_qt_nova := aux_qt_atual - prm_qt_movimento;
        
      end if;
      
      insert
        into movimento_estoque
            (cd_produto,
             cd_local,
             dm_movimento,
             qt_movimento,
             dt_movimento,
             ds_movimento,
             cd_usuario,
             qt_anterior,
             qt_posterior)
      values(prm_cd_produto,
             prm_cd_local,
             prm_dm_movimento,
             prm_qt_movimento,
             sysdate,
             prm_ds_movimento,
             nvl(prm_cd_usuario, f_buscar_usuario_ativo),
             aux_qt_antiga,
             aux_qt_nova);
             
      p_atualizar_prodest(prm_cd_produto => prm_cd_produto,
                          prm_cd_local   => prm_cd_local,
                          prm_qt_estoque => aux_qt_nova);
      
    end;
  
  
  
end k_estoque;
/
