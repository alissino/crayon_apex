create or replace function f_aplicar_mascara (
    p_valor   varchar2,
    p_mascara varchar2
) return varchar2
is
    v_resultado varchar2(4000) := '';
    v_valor     varchar2(4000) := p_valor;
    v_indice    number := 1;
    v_char_mask char(1);
    v_char_val  char(1);

    -- funções auxiliares
    function eh_numero(p_char char) return boolean is
    begin
        return regexp_like(p_char, '[0-9]');
    end;

    function eh_letra(p_char char) return boolean is
    begin
        return regexp_like(p_char, '[A-Za-z]');
    end;

begin
    for i in 1 .. length(p_mascara) loop
        v_char_mask := substr(p_mascara, i, 1);
        v_char_val  := substr(v_valor, v_indice, 1);

        case v_char_mask

            -- número obrigatório
            when '9' then
                if eh_numero(v_char_val) then
                    v_resultado := v_resultado || v_char_val;
                    v_indice := v_indice + 1;
                else
                    return null; -- erro de validação
                end if;

            -- número opcional
            when '0' then
                if eh_numero(v_char_val) then
                    v_resultado := v_resultado || v_char_val;
                    v_indice := v_indice + 1;
                end if;

            -- letra obrigatória
            when 'A' then
                if eh_letra(v_char_val) then
                    v_resultado := v_resultado || v_char_val;
                    v_indice := v_indice + 1;
                else
                    return null;
                end if;

            -- letra opcional
            when 'a' then
                if eh_letra(v_char_val) then
                    v_resultado := v_resultado || v_char_val;
                    v_indice := v_indice + 1;
                end if;

            -- qualquer obrigatório
            when '*' then
                if v_char_val is not null then
                    v_resultado := v_resultado || v_char_val;
                    v_indice := v_indice + 1;
                else
                    return null;
                end if;

            -- qualquer opcional
            when '#' then
                if v_char_val is not null then
                    v_resultado := v_resultado || v_char_val;
                    v_indice := v_indice + 1;
                end if;

            -- literal
            else
                v_resultado := v_resultado || v_char_mask;

        end case;
    end loop;

    return v_resultado;
end;
/
