create or replace trigger tgr_bi_forma_pagamento
  before insert
  on FORMA_PAGAMENTO 
  for each row
declare
  -- local variables here
begin
  :new.nr_sequencia := s_forma_pagamento.nextval;
end tgr_bi_forma_pagamento;
/
