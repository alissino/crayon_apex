PL/SQL Developer Test script 3.0
645
-- ============================================================================
-- SCRIPT DE CONFIGURAÇÃO - ESTRUTURA XML NF-e 4.00
-- Executar como um bloco PL/SQL único
-- ============================================================================

DECLARE
  v_xml_id        xml.cd_xml%TYPE;
  v_root_id       xml_node.cd_xml_node%TYPE;
  v_infnfe_id     xml_node.cd_xml_node%TYPE;
  v_ide_id        xml_node.cd_xml_node%TYPE;
  v_emit_id       xml_node.cd_xml_node%TYPE;
  v_enderemit_id  xml_node.cd_xml_node%TYPE;
  v_det_id        xml_node.cd_xml_node%TYPE;
  v_prod_id       xml_node.cd_xml_node%TYPE;
  v_total_id      xml_node.cd_xml_node%TYPE;
  v_icmstot_id    xml_node.cd_xml_node%TYPE;
  
  -- Para receber os IDs dos inserts individuais
  v_node_id       xml_node.cd_xml_node%TYPE;
  v_val_id        xml_node_val.cd_xml_val%TYPE;
  v_atrib_id      xml_node_atributo.cd_atributo%TYPE;

BEGIN

  -- ==========================================================================
  -- 1. Cadastro do XML
  -- ==========================================================================
  INSERT INTO xml (
    cd_xml,
    ds_xml,
    ds_versao,
    ds_tag_raiz,
    ds_namespace,
    ds_descricao,
    dm_situacao,
    cd_processo
  ) VALUES (
    crayon.s_xml.nextval,
    'NF-e 4.00',
    '4.00',
    'NFe',
    'http://www.portalfiscal.inf.br/nfe',
    'Nota Fiscal Eletrônica - Layout 4.00',
    'A',
    NULL
  )
  RETURNING cd_xml INTO v_xml_id;

  -- ==========================================================================
  -- 2. ROOT: NFe
  -- ==========================================================================
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, NULL, 'NFe', 'ROOT', 
    1, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_root_id;

  -- ==========================================================================
  -- 3. GROUP: infNFe
  -- ==========================================================================
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_root_id, 'infNFe', 'GROUP', 
    1, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_infnfe_id;

  -- ==========================================================================
  -- GRUPO A - Identificação da NF-e
  -- ==========================================================================
  
  -- GROUP: ide
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_infnfe_id, 'ide', 'GROUP', 
    1, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_ide_id;

  -- FIELD: cUF
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_ide_id, 'cUF', 'FIELD', 
    1, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT uf.cd_uf FROM nf_nota_fiscal nf, gr_uf uf WHERE nf.cd_uf = uf.cd_uf AND nf.nr_sequencia = :1', 
    NULL);

  -- FIELD: cNF
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_ide_id, 'cNF', 'FIELD', 
    2, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT LPAD(nf.nr_nota, 8, ''0'') FROM nf_nota_fiscal nf WHERE nf.nr_sequencia = :1', 
    NULL);

  -- FIELD: natOp
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_ide_id, 'natOp', 'FIELD', 
    3, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT nf.ds_natureza_operacao FROM nf_nota_fiscal nf WHERE nf.nr_sequencia = :1', 
    NULL);

  -- FIELD: mod (FIXO)
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_ide_id, 'mod', 'FIELD', 
    4, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'FIX', NULL, '55');

  -- FIELD: serie
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_ide_id, 'serie', 'FIELD', 
    5, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT TO_CHAR(nf.nr_serie) FROM nf_nota_fiscal nf WHERE nf.nr_sequencia = :1', 
    NULL);

  -- FIELD: nNF
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_ide_id, 'nNF', 'FIELD', 
    6, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT TO_CHAR(nf.nr_nota) FROM nf_nota_fiscal nf WHERE nf.nr_sequencia = :1', 
    NULL);

  -- FIELD: dhEmi
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_ide_id, 'dhEmi', 'FIELD', 
    7, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT TO_CHAR(nf.dt_emissao, ''YYYY-MM-DD"T"HH24:MI:SS"T-03:00"'') FROM nf_nota_fiscal nf WHERE nf.nr_sequencia = :1', 
    NULL);

  -- FIELD: tpNF
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_ide_id, 'tpNF', 'FIELD', 
    8, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT DECODE(nf.fg_tipo, ''E'', ''1'', ''S'', ''0'') FROM nf_nota_fiscal nf WHERE nf.nr_sequencia = :1', 
    NULL);

  -- FIELD: tpEmis (FIXO)
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_ide_id, 'tpEmis', 'FIELD', 
    9, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'FIX', NULL, '1');

  -- ==========================================================================
  -- GRUPO B - Emitente
  -- ==========================================================================
  
  -- GROUP: emit
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_infnfe_id, 'emit', 'GROUP', 
    2, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_emit_id;

  -- FIELD: CNPJ (com condição: só gera se for CNPJ)
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_emit_id, 'CNPJ', 'FIELD', 
    1, NULL, 
    'SELECT COUNT(*) FROM nf_nota_fiscal nf, gr_pessoa pes WHERE nf.cd_emitente = pes.cd_pessoa AND nf.nr_sequencia = :1 AND LENGTH(pes.nr_cnpj_cpf) = 14', 
    'N', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT pes.nr_cnpj_cpf FROM nf_nota_fiscal nf, gr_pessoa pes WHERE nf.cd_emitente = pes.cd_pessoa AND nf.nr_sequencia = :1 AND LENGTH(pes.nr_cnpj_cpf) = 14', 
    NULL);

  -- FIELD: CPF (com condição: só gera se for CPF)
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_emit_id, 'CPF', 'FIELD', 
    2, NULL, 
    'SELECT COUNT(*) FROM nf_nota_fiscal nf, gr_pessoa pes WHERE nf.cd_emitente = pes.cd_pessoa AND nf.nr_sequencia = :1 AND LENGTH(pes.nr_cnpj_cpf) = 11', 
    'N', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT pes.nr_cnpj_cpf FROM nf_nota_fiscal nf, gr_pessoa pes WHERE nf.cd_emitente = pes.cd_pessoa AND nf.nr_sequencia = :1 AND LENGTH(pes.nr_cnpj_cpf) = 11', 
    NULL);

  -- FIELD: xNome (emitente)
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_emit_id, 'xNome', 'FIELD', 
    3, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT pes.ds_razao_social FROM nf_nota_fiscal nf, gr_pessoa pes WHERE nf.cd_emitente = pes.cd_pessoa AND nf.nr_sequencia = :1', 
    NULL);

  -- ==========================================================================
  -- GRUPO C - Endereço do Emitente
  -- ==========================================================================
  
  -- GROUP: enderEmit
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_emit_id, 'enderEmit', 'GROUP', 
    4, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_enderemit_id;

  -- FIELD: xLgr
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_enderemit_id, 'xLgr', 'FIELD', 
    1, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT ender.ds_endereco FROM nf_nota_fiscal nf, gr_pessoa_endereco ender WHERE nf.cd_emitente = ender.cd_pessoa AND ender.fg_principal = ''S'' AND nf.nr_sequencia = :1', 
    NULL);

  -- FIELD: nro
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_enderemit_id, 'nro', 'FIELD', 
    2, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT ender.nr_numero FROM nf_nota_fiscal nf, gr_pessoa_endereco ender WHERE nf.cd_emitente = ender.cd_pessoa AND ender.fg_principal = ''S'' AND nf.nr_sequencia = :1', 
    NULL);

  -- FIELD: xBairro
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_enderemit_id, 'xBairro', 'FIELD', 
    3, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT ender.ds_bairro FROM nf_nota_fiscal nf, gr_pessoa_endereco ender WHERE nf.cd_emitente = ender.cd_pessoa AND ender.fg_principal = ''S'' AND nf.nr_sequencia = :1', 
    NULL);

  -- FIELD: cMun
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_enderemit_id, 'cMun', 'FIELD', 
    4, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT TO_CHAR(mun.cd_municipio) FROM nf_nota_fiscal nf, gr_pessoa_endereco ender, gr_municipio mun WHERE nf.cd_emitente = ender.cd_pessoa AND ender.cd_municipio = mun.cd_municipio AND ender.fg_principal = ''S'' AND nf.nr_sequencia = :1', 
    NULL);

  -- FIELD: xMun
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_enderemit_id, 'xMun', 'FIELD', 
    5, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT mun.ds_municipio FROM nf_nota_fiscal nf, gr_pessoa_endereco ender, gr_municipio mun WHERE nf.cd_emitente = ender.cd_pessoa AND ender.cd_municipio = mun.cd_municipio AND ender.fg_principal = ''S'' AND nf.nr_sequencia = :1', 
    NULL);

  -- FIELD: UF
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_enderemit_id, 'UF', 'FIELD', 
    6, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT uf.sg_uf FROM nf_nota_fiscal nf, gr_pessoa_endereco ender, gr_municipio mun, gr_uf uf WHERE nf.cd_emitente = ender.cd_pessoa AND ender.cd_municipio = mun.cd_municipio AND mun.cd_uf = uf.cd_uf AND ender.fg_principal = ''S'' AND nf.nr_sequencia = :1', 
    NULL);

  -- FIELD: CEP
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_enderemit_id, 'CEP', 'FIELD', 
    7, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT ender.nr_cep FROM nf_nota_fiscal nf, gr_pessoa_endereco ender WHERE nf.cd_emitente = ender.cd_pessoa AND ender.fg_principal = ''S'' AND nf.nr_sequencia = :1', 
    NULL);

  -- ==========================================================================
  -- GRUPO H - Itens da NF-e (LOOP)
  -- ==========================================================================
  
  -- LOOP: det
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_infnfe_id, 'det', 'LOOP', 
    3, 
    'SELECT nfi.nr_item, nfi.cd_produto as cd_prod, prod.ds_produto, prod.nr_ncm, prod.cd_cfop, nfi.qt_item, nfi.vl_unitario, nfi.vl_total FROM nf_nota_fiscal_item nfi, gr_produto prod WHERE nfi.cd_nota_fiscal = :1 AND nfi.cd_produto = prod.cd_produto ORDER BY nfi.nr_item', 
    NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_det_id;

  -- Atributo: nItem
  INSERT INTO xml_node_atributo (cd_atributo, cd_xml_node, ds_atributo, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_atributo.nextval, v_det_id, 'nItem', 'COL', NULL, 'NR_ITEM');

  -- GROUP: prod
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_det_id, 'prod', 'GROUP', 
    1, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_prod_id;

  -- FIELD: cProd
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_prod_id, 'cProd', 'FIELD', 
    1, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'COL', NULL, 'CD_PROD');

  -- FIELD: xProd
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_prod_id, 'xProd', 'FIELD', 
    2, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'COL', NULL, 'DS_PRODUTO');

  -- FIELD: NCM
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_prod_id, 'NCM', 'FIELD', 
    3, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'COL', NULL, 'NR_NCM');

  -- FIELD: CFOP
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_prod_id, 'CFOP', 'FIELD', 
    4, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'COL', NULL, 'CD_CFOP');

  -- FIELD: uCom
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_prod_id, 'uCom', 'FIELD', 
    5, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'FIX', NULL, 'UN');

  -- FIELD: qCom
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_prod_id, 'qCom', 'FIELD', 
    6, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'COL', NULL, 'QT_ITEM');

  -- FIELD: vUnCom
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_prod_id, 'vUnCom', 'FIELD', 
    7, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'COL', NULL, 'VL_UNITARIO');

  -- FIELD: vProd
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_prod_id, 'vProd', 'FIELD', 
    8, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'COL', NULL, 'VL_TOTAL');

  -- ==========================================================================
  -- GRUPO W - Total da NF-e
  -- ==========================================================================
  
  -- GROUP: total
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_infnfe_id, 'total', 'GROUP', 
    4, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_total_id;

  -- GROUP: ICMSTot
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_total_id, 'ICMSTot', 'GROUP', 
    1, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_icmstot_id;

  -- FIELD: vBC
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_icmstot_id, 'vBC', 'FIELD', 
    1, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT NVL(SUM(nfi.vl_base_icms), 0) FROM nf_nota_fiscal_item nfi WHERE nfi.cd_nota_fiscal = :1', 
    NULL);

  -- FIELD: vICMS
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_icmstot_id, 'vICMS', 'FIELD', 
    2, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT NVL(SUM(nfi.vl_icms), 0) FROM nf_nota_fiscal_item nfi WHERE nfi.cd_nota_fiscal = :1', 
    NULL);

  -- FIELD: vProd (total)
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_icmstot_id, 'vProd', 'FIELD', 
    3, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT NVL(SUM(nfi.vl_total), 0) FROM nf_nota_fiscal_item nfi WHERE nfi.cd_nota_fiscal = :1', 
    NULL);

  -- FIELD: vNF
  INSERT INTO xml_node (
    cd_xml_node, cd_xml, cd_xml_node_pai, ds_nome_tag, dm_tipo, 
    nr_ordem, ds_sql_loop, ds_sql_condicao, fg_obrigatorio, dm_situacao
  ) VALUES (
    crayon.s_xml_node.nextval, v_xml_id, v_icmstot_id, 'vNF', 'FIELD', 
    4, NULL, NULL, 'S', 'A'
  )
  RETURNING cd_xml_node INTO v_node_id;
  
  INSERT INTO xml_node_val (cd_xml_val, cd_xml_node, dm_origem, ds_expressao, ds_valor)
  VALUES (crayon.s_xml_node_val.nextval, v_node_id, 'SQL', 
    'SELECT nf.vl_total_nota FROM nf_nota_fiscal nf WHERE nf.nr_sequencia = :1', 
    NULL);

  -- ==========================================================================
  -- Commit final
  -- ==========================================================================
  COMMIT;
  
  -- ==========================================================================
  -- Log informativo
  -- ==========================================================================
  DBMS_OUTPUT.PUT_LINE('========================================');
  DBMS_OUTPUT.PUT_LINE('XML NF-e 4.00 configurado com sucesso!');
  DBMS_OUTPUT.PUT_LINE('XML_ID: ' || v_xml_id);
  DBMS_OUTPUT.PUT_LINE('ROOT_ID (NFe): ' || v_root_id);
  DBMS_OUTPUT.PUT_LINE('infNFe_ID: ' || v_infnfe_id);
  DBMS_OUTPUT.PUT_LINE('ide_ID: ' || v_ide_id);
  DBMS_OUTPUT.PUT_LINE('emit_ID: ' || v_emit_id);
  DBMS_OUTPUT.PUT_LINE('enderEmit_ID: ' || v_enderemit_id);
  DBMS_OUTPUT.PUT_LINE('det_ID: ' || v_det_id);
  DBMS_OUTPUT.PUT_LINE('prod_ID: ' || v_prod_id);
  DBMS_OUTPUT.PUT_LINE('total_ID: ' || v_total_id);
  DBMS_OUTPUT.PUT_LINE('ICMSTot_ID: ' || v_icmstot_id);
  DBMS_OUTPUT.PUT_LINE('========================================');

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('ERRO: ' || SQLERRM);
    RAISE;
END;
0
0
