-- =============================================================================
--  Function      : RANDOM_DATE
-- =============================================================================
--  Author        : Andriy (Andrii) Oseledko
--  Version       : 1.0
--  Creation date : 03.10.2019
--  Last modified : 07.08.2020
--  Language      : Oracle PL/SQL, SQL
-- =============================================================================
--  Description   : This function generates a random DATE value in a range
--                : between `p_date_start` and `p_date_end` (inclusively).
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
BEGIN
    RETURN TO_DATE(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(COALESCE(p_date_start, DATE '0001-01-01'), 'J'),
                                           TO_CHAR(COALESCE(p_date_end, DATE '9999-12-31'), 'J'))), 'J');
END RANDOM_DATE;
/