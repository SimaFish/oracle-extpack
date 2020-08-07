-- =============================================================================
--  Function      : RANDOM_TIMESTAMP
-- =============================================================================
--  Author        : Andriy (Andrii) Oseledko
--  Version       : 1.0
--  Creation date : 07.08.2020
--  Last modified : 07.08.2020
--  Language      : Oracle PL/SQL, SQL
-- =============================================================================
--  Description   : This function generates a random TIMESTAMP value in a range
--                : between `p_tstamp_start` and `p_tstamp_end` (inclusively).
-- =============================================================================
--  Parameters    : > p_tstamp_start:
--                : Start timestamp, the left boundary in a range from which
--                : to generate a random timestamp. If not specified, value
--                : 01/01/0001 00:00:00 (DD/MM/YYYY HH24:MI:SS) used instead.
--                : ------------------------------------------------------------
--                : > p_tstamp_end:
--                : End timestamp, the right boundary in a range from which
--                : to generate a random timestamp. If not specified, value
--                : 31/12/9999 23:59:59 (DD/MM/YYYY HH24:MI:SS) used instead.
-- =============================================================================

CREATE OR REPLACE FUNCTION RANDOM_TIMESTAMP (p_tstamp_start IN TIMESTAMP DEFAULT NULL,
                                             p_tstamp_end   IN TIMESTAMP DEFAULT NULL)
RETURN TIMESTAMP
IS
    v_tstamp_start TIMESTAMP;
    v_tstamp_end   TIMESTAMP;
    v_tstamp_val   TIMESTAMP;
BEGIN
    v_tstamp_start := COALESCE(p_tstamp_start, TIMESTAMP '0001-01-01 00:00:00');
    v_tstamp_end := COALESCE(p_tstamp_end, TIMESTAMP '9999-12-31 23:59:59');

    IF (TRUNC(v_tstamp_start) = TRUNC(v_tstamp_end))
    THEN
        v_tstamp_val := TRUNC(v_tstamp_start) + DBMS_RANDOM.VALUE(TO_CHAR(v_tstamp_start, 'SSSSS'),
                                                                  TO_CHAR(v_tstamp_end, 'SSSSS')) / 86399;
    ELSE
        v_tstamp_val := TO_TIMESTAMP(TRUNC(DBMS_RANDOM.VALUE(TO_CHAR(v_tstamp_start, 'J'),
                                                             TO_CHAR(v_tstamp_end, 'J'))), 'J');

        v_tstamp_val := v_tstamp_val +
                        CASE v_tstamp_val
                           WHEN TRUNC(v_tstamp_start) THEN DBMS_RANDOM.VALUE(TO_CHAR(v_tstamp_start, 'SSSSS'), 86399)
                           WHEN TRUNC(v_tstamp_end) THEN DBMS_RANDOM.VALUE(0, TO_CHAR(v_tstamp_end, 'SSSSS'))
                           ELSE DBMS_RANDOM.VALUE(0, 86399)
                        END / 86399;
    END IF;

    RETURN v_tstamp_val;
END RANDOM_TIMESTAMP;
/