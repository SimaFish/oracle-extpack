-- =============================================================================
--  Function      : RANDOM_DATE
-- =============================================================================
--  Author        : Andriy (Andrii) Oseledko
--  Version       : 1.0
--  Creation date : 03.10.2019
--  Last modified : 03.10.2019
--  Language      : Oracle PL/SQL, SQL
-- =============================================================================
--  Description   : This function generates a random DATE value, greater than or
--                : equal to `p_date_start` and less than `p_date_end`.
-- =============================================================================
--  Parameters    : > p_date_start:
--                : Start date, the left boundary in a range from which
--                : to generate a random date. If not specified,
--                : value 01/01/0001 (DD/MM/YYYY) used instead.
--                : ------------------------------------------------------------
--                : > p_date_end:
--                : End date, the right boundary in a range from which
--                : to generate a random date. If not specified,
--                : value 31/12/9999 (DD/MM/YYYY) used instead.
-- =============================================================================

CREATE OR REPLACE FUNCTION RANDOM_DATE (p_date_start IN DATE DEFAULT NULL,
                                        p_date_end   IN DATE DEFAULT NULL)
RETURN DATE
IS
    v_date_start DATE;
    v_date_end   DATE;
BEGIN
    v_date_start := NVL(p_date_start, TO_DATE('01.01.0001', 'DD.MM.YYYY'));
    v_date_end := NVL(p_date_end, TO_DATE('31.12.9999', 'DD.MM.YYYY'));

    RETURN TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(v_date_start, 'J'),
                                           TO_CHAR(v_date_end, 'J'))), 'J');
END RANDOM_DATE;
/