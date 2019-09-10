-- =============================================================================
--  Function      : STRING_SPLIT
-- =============================================================================
--  Author        : Andriy Oseledko
--  Creation date : 10.09.2019
--  Modifications : 10.09.2019
-- =============================================================================
--  Description   : Table-valued function that splits a string into rows of
--                : substrings, based on a specified separator expression.
--                : Returns a single-column table whose rows are the substrings.
-- =============================================================================
--  Parameters    : > p_src_str:
--                : Is a source string to be split into rows of substrings.
--                : ------------------------------------------------------------
--                : > p_val_sep:
--                : Is a character expression that is used as separator
--                : for concatenated substrings.
--                : ------------------------------------------------------------
--                : > p_trim_mode:
--                : Is an integer value in range [1..3].
--                : Specifies the way a substring is truncated after extraction.
--                : If this parameter is omitted, no substring truncation occurs.
--                : 
--                : Allowable values:
--                :   1: Remove all `p_trim_symb` characters from the left-hand
--                :      side of a substring value;
--                :   2: Remove all `p_trim_symb` characters from the right-hand
--                :      side of a substring value;
--                :   3: Remove all `p_trim_symb` characters from both sides
--                :      of a substring value.
--                : ------------------------------------------------------------
--                : > p_trim_symb:
--                : Is a character expression to remove from the specified side
--                : of a substring value. If this parameter is omitted,
--                : the default expression is a single space character.
-- =============================================================================

CREATE OR REPLACE TYPE T_STRING_SPLIT_VALUES IS TABLE OF VARCHAR2(32767);
/

CREATE OR REPLACE FUNCTION STRING_SPLIT (p_src_str   IN CLOB,
                                         p_val_sep   IN VARCHAR2,
                                         p_trim_mode IN PLS_INTEGER DEFAULT 0,
                                         p_trim_symb IN VARCHAR2 DEFAULT ' ')
RETURN T_STRING_SPLIT_VALUES
    PIPELINED
    DETERMINISTIC
AS
    v_value VARCHAR2(32767);
    v_symb_amt SIMPLE_INTEGER := 0;
    v_prev_pos SIMPLE_INTEGER := 0;
    v_next_pos SIMPLE_INTEGER := 0;
    c_sep_len CONSTANT SIMPLE_INTEGER := NVL(LENGTH(p_val_sep), 0);
    c_trim_symblen CONSTANT SIMPLE_INTEGER := NVL(LENGTH(p_trim_symb), 0);
    c_src_strlen CONSTANT SIMPLE_INTEGER := NVL(LENGTH(p_src_str), 0);
BEGIN
    IF c_sep_len = 0 AND c_src_strlen <> 0
    THEN
        PIPE ROW(SUBSTR(p_src_str, 1, 32767));
    ELSIF c_sep_len <> 0 AND c_src_strlen <> 0
    THEN
        LOOP
            v_prev_pos := CASE v_prev_pos
                             WHEN 0 THEN 1
                             ELSE v_next_pos + c_sep_len
                          END;

            v_next_pos := INSTR(p_src_str, p_val_sep, v_prev_pos + 1);

            v_next_pos := CASE
                             WHEN v_next_pos = 0 THEN c_src_strlen + 1
                             ELSE v_next_pos
                          END;

            v_symb_amt := v_next_pos - v_prev_pos;
            IF v_symb_amt > 32767
            THEN
                RAISE_APPLICATION_ERROR(-20200, 'Source string contains delimiters that are more than 32767 characters apart');
            END IF;

            v_value := SUBSTR(p_src_str, v_prev_pos, v_symb_amt);

            IF p_trim_mode > 0 AND c_trim_symblen > 0
            THEN
                PIPE ROW(CASE p_trim_mode
                            WHEN 1 THEN LTRIM(v_value, p_trim_symb)
                            WHEN 2 THEN RTRIM(v_value, p_trim_symb)
                            WHEN 3 THEN TRIM(BOTH p_trim_symb FROM v_value)
                            ELSE v_value
                         END);
            ELSE
                PIPE ROW(v_value);
            END IF;

            EXIT WHEN v_next_pos = c_src_strlen + 1;
        END LOOP;
    END IF;
END STRING_SPLIT;
/

ALTER FUNCTION STRING_SPLIT
    COMPILE PLSQL_CODE_TYPE = NATIVE
    PLSQL_OPTIMIZE_LEVEL = 3
    REUSE SETTINGS;
/