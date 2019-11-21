-- =============================================================================
--  Function      : FACTORIAL
-- =============================================================================
--  Author        : Andriy (Andrii) Oseledko
--  Version       : 1.0
--  Creation date : 21.11.2019
--  Last modified : 21.11.2019
--  Language      : Oracle PL/SQL
-- =============================================================================
--  Description   : Calculates Factorial number out from input argument.
--                : Any non-integer arguments will be ignored.
-- =============================================================================
--  Parameters    : > p_fact_num:
--                : Integer number to calculate Factorial number.
-- =============================================================================

CREATE OR REPLACE FUNCTION FACTORIAL (p_fact_num IN PLS_INTEGER)
RETURN PLS_INTEGER
RESULT_CACHE
IS
    NEGATIVE_ARGUMENT EXCEPTION;
    v_factorial SIMPLE_INTEGER := 1;
BEGIN
    IF p_fact_num < 0 THEN
        RAISE NEGATIVE_ARGUMENT;
    END IF;

    FOR i_fact_num IN 1..p_fact_num
    LOOP
        v_factorial := v_factorial * i_fact_num;
    END LOOP;

    RETURN v_factorial;
EXCEPTION
    WHEN NEGATIVE_ARGUMENT THEN
        RAISE_APPLICATION_ERROR(-20001, 'Negative argument ' || p_fact_num ||
            ' is not allowed to evaluate factorial.');
    WHEN OTHERS THEN
        IF SQLCODE = -06502 THEN
            RETURN NULL;
        ELSE RAISE;
    END IF;
END;
/

ALTER FUNCTION FACTORIAL
    COMPILE PLSQL_CODE_TYPE = NATIVE
    PLSQL_OPTIMIZE_LEVEL = 3
    REUSE SETTINGS;
/