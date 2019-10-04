-- =============================================================================
--  Function      : CLOB_TO_BLOB
-- =============================================================================
--  Author        : Andriy (Andrii) Oseledko
--  Version       : 1.0
--  Creation date : 04.10.2019
--  Last modified : 04.10.2019
--  Language      : Oracle PL/SQL, SQL
-- =============================================================================
--  Description   : Converts CLOB string into BLOB binary data.
--                : 
--                : The function converts the source string (CLOB) in the source
--                : instance to binary data (BLOB) using the character set you
--                : specify, writes the resulting data to a destination BLOB.
-- =============================================================================
--  Parameters    : > p_clob_val:
--                : Any non-null CLOB hexadecimal value to convert into BLOB.
--                : If source CLOB is NULL - an empty BLOB instance is returned.
--                : ------------------------------------------------------------
--                : > p_blob_csid:
--                : Character set of the source data passed in the source CLOB.
--                : Use NLS_CHARSET_ID built-in function to determine the
--                : charset id by charset name.
--                : 
--                : If no character set id is specified, the function assumes
--                : that the CLOB contains character data encoded in the default
--                : database character set.
-- =============================================================================

CREATE OR REPLACE FUNCTION CLOB_TO_BLOB (p_clob_val  IN CLOB,
                                         p_blob_csid IN NUMBER DEFAULT NULL)
RETURN BLOB
AS
    v_warning     PLS_INTEGER;
    v_src_offset  SIMPLE_INTEGER := 1;
    v_dest_offset SIMPLE_INTEGER := 1;
    v_blob_val    BLOB           := EMPTY_BLOB();
    v_lang_ctx    PLS_INTEGER    := DBMS_LOB.DEFAULT_LANG_CTX;
    v_blob_csid   NUMBER         := NVL(p_blob_csid, DBMS_LOB.DEFAULT_CSID);
BEGIN
    IF p_clob_val IS NOT NULL THEN
        DBMS_LOB.CREATETEMPORARY(lob_loc => v_blob_val,
                                 cache   => FALSE,
                                 dur     => DBMS_LOB.CALL);

        DBMS_LOB.CONVERTTOBLOB(dest_lob     => v_blob_val,
                               src_clob     => p_clob_val,
                               amount       => DBMS_LOB.LOBMAXSIZE,
                               dest_offset  => v_dest_offset,
                               src_offset   => v_src_offset, 
                               blob_csid    => v_blob_csid,
                               lang_context => v_lang_ctx,
                               warning      => v_warning);

        IF v_warning = DBMS_LOB.WARN_INCONVERTIBLE_CHAR THEN
            DBMS_OUTPUT.PUT_LINE('Warning! Source contains character(s) that cannot be properly converted.');
        END IF;
    END IF;

    RETURN v_blob_val;
EXCEPTION
    WHEN DBMS_LOB.INVALID_ARGVAL THEN
        RAISE_APPLICATION_ERROR(-20200, 'Invalid or unsupported character set, CSID: ' || v_blob_csid || '.');
    WHEN OTHERS THEN
        IF SQLCODE = -01482 THEN
            RAISE_APPLICATION_ERROR(-20200, 'Invalid or unsupported character set, CSID: ' || v_blob_csid || '.');
        ELSE RAISE;
        END IF;
END;
/