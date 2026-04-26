create or replace function f_cor_hex_rgb(prm_ds_hexa varchar2,
                                         prm_dm_rgb  char) 
return number
is
  aux_ds_h_red   varchar2(2) := substr(prm_ds_hexa, 2, 2);
  aux_ds_h_green varchar2(2) := substr(prm_ds_hexa, 4, 2);
  aux_ds_h_blue  varchar2(2) := substr(prm_ds_hexa, 6, 2);
begin
  if substr(prm_ds_hexa, 1, 1) <> '#' or length(prm_ds_hexa) <> 7 then
    p_mostra_erro('Cor haxadecimal inválida.');
  end if;
  
  return to_number(case upper(prm_dm_rgb)
                     when 'R' then aux_ds_h_red
                     when 'G' then aux_ds_h_green
                     when 'B' then aux_ds_h_blue
                   end, 'xx');
end f_cor_hex_rgb;
/
