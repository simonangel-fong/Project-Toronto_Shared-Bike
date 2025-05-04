ALTER SESSION SET CONTAINER = toronto_shared_bike;

CREATE OR REPLACE PROCEDURE update_directory_for_year(p_year IN VARCHAR2) IS
    v_path VARCHAR2(1000);
    sql_stmt VARCHAR2(1000);
BEGIN
    -- Construct the directory path
    v_path := '/project/data/' || p_year;

    -- Create the new directory
    sql_stmt := 'CREATE OR REPLACE DIRECTORY dir_target AS ''' || v_path || '''';
    EXECUTE IMMEDIATE sql_stmt;

    -- Grant read privilege
    sql_stmt := 'GRANT READ ON DIRECTORY dir_target TO dw_schema';
    EXECUTE IMMEDIATE sql_stmt;

    DBMS_OUTPUT.PUT_LINE('Directory updated to: ' || v_path);
END;
/
