-- =============================================================================
--  Function      : BLOB_TO_CLOB
-- =============================================================================
--  Author        : Andriy (Andrii) Oseledko
--  Version       : 1.0
--  Creation date : 03.10.2019
--  Last modified : 03.10.2019
--  Language      : Oracle PL/SQL, SQL
-- =============================================================================
--  Description   : Converts BLOB binary data into CLOB string.
--                : 
--                : The function converts the binary data (BLOB) in the source
--                : instance to character data using the character set you
--                : specify, writes the character data to a destination CLOB.
-- =============================================================================
--  Parameters    : > p_blob_val:
--                : Any non-null BLOB hexadecimal value to convert into CLOB.
--                : If source BLOB is NULL - an empty CLOB is returned.
--                : ------------------------------------------------------------
--                : > p_blob_csid:
--                : Character set of the source data passed in the source BLOB.
--                : Use NLS_CHARSET_ID built-in function to determine the
--                : charset id by charset name.
--                : 
--                : If no character set id is specified, the function assumes
--                : that the BLOB contains character data in the default
--                : database character set.
-- =============================================================================

CREATE OR REPLACE FUNCTION BLOB_TO_CLOB (p_blob_val  IN BLOB,
                                         p_blob_csid IN NUMBER DEFAULT NULL)
RETURN CLOB
IS
    v_warning     INTEGER;
    v_src_offset  INTEGER := 1;
    v_dest_offset INTEGER := 1;
    v_clob_val    CLOB    := EMPTY_CLOB();
    v_file_size   INTEGER := DBMS_LOB.LOBMAXSIZE;
    v_lang_ctx    NUMBER  := DBMS_LOB.DEFAULT_LANG_CTX;
    v_blob_csid   NUMBER  := NVL(p_blob_csid, DBMS_LOB.DEFAULT_CSID);
BEGIN
    IF p_blob_val IS NOT NULL THEN
        DBMS_LOB.CREATETEMPORARY(lob_loc => v_clob_val,
                                 cache   => FALSE,
                                 dur     => DBMS_LOB.CALL);

        DBMS_LOB.CONVERTTOCLOB(dest_lob     => v_clob_val,
                               src_blob     => p_blob_val,
                               amount       => v_file_size,
                               dest_offset  => v_dest_offset,
                               src_offset   => v_src_offset,
                               blob_csid    => v_blob_csid,
                               lang_context => v_lang_ctx,
                               warning      => v_warning);

        IF v_warning = DBMS_LOB.WARN_INCONVERTIBLE_CHAR THEN
            DBMS_OUTPUT.PUT_LINE('Warning! Source contains character(s) that cannot be properly converted.');
        END IF;
    END IF;

    RETURN v_clob_val;
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