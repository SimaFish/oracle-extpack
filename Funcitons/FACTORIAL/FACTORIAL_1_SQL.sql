-- =============================================================================
--  Function      : FACTORIAL
-- =============================================================================
--  Author        : Andriy (Andrii) Oseledko
--  Version       : 1.0
--  Creation date : 21.11.2019
--  Last modified : 21.11.2019
--  Language      : Oracle PL/SQL, SQL
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
    v_factorial PLS_INTEGER;
    NEGATIVE_ARGUMENT EXCEPTION;
BEGIN
    IF p_fact_num < 0 THEN
        RAISE NEGATIVE_ARGUMENT;
    END IF;

    WITH factorial (fact_num, fact_prod1, fact_prod2)
    AS (SELECT 0, 1, 1
          FROM DUAL
         UNION ALL
        SELECT fact_num + 1,
               fact_prod1 * (fact_num + 1),
               fact_prod1 * (fact_num + 1)
          FROM factorial
         WHERE fact_num < p_fact_num)

    SELECT fact_prod2
      INTO v_factorial
      FROM factorial
     WHERE fact_num = p_fact_num;

    RETURN v_factorial;
EXCEPTION
    WHEN NEGATIVE_ARGUMENT THEN
        RAISE_APPLICATION_ERROR(-20001, 'Negative argument ' || p_fact_num ||
            ' is not allowed to evaluate factorial.');
    WHEN OTHERS THEN
        IF SQLCODE = -01426 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Argument ' || p_fact_num ||
                ' is too large to evaluate factorial.');
        ELSE RAISE;
    END IF;
END;
/