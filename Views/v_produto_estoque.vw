create or replace force view v_produto_estoque as
select p.cd_produto,
         l.cd_local,
         l.ds_local,
         nvl(pe.nr_quantidade, 0) qt_estoque,
         p.cd_unid_estoque
    from produto         p,
         local_estoque   l,
         produto_estoque pe
   where p.cd_produto = pe.cd_produto(+)
     and l.cd_local   = pe.cd_local(+);

