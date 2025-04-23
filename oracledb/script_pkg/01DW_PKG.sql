ALTER SESSION SET CONTAINER = CDB$ROOT;


CREATE OR REPLACE PACKAGE DW_PKG AS
    -- public var
    G_32K_CACHE_SIZE    CONSTANT VARCHAR2(3)    :=  '256';
    G_ORACLE_SID        CONSTANT VARCHAR2(32)   :=  'ORCLCDB';
    G_DATAFILE_PREFIX   CONSTANT VARCHAR2(32)   :=  '/opt/oracle/oradata';
    G_PDB_NAME          CONSTANT VARCHAR2(32)   :=  'pdb1';
    G_PDB_ADMIN         CONSTANT VARCHAR2(32)   :=  'pdb_admin';
    G_PDB_ADMIN_PWD     CONSTANT VARCHAR2(32)   :=  'Welcome!234';
    G_DIRECTORY_NAME    CONSTANT VARCHAR2(32)   :=  'data_dir';
    G_DATA_DIR          CONSTANT VARCHAR2(32)   :=  '/tmp/2019';
    
    -- switch container
    PROCEDURE switch_container(p_pdb_name IN VARCHAR2  DEFAULT G_PDB_NAME);
    -- create pdb
    PROCEDURE create_pdb(p_pdb_name IN VARCHAR2  DEFAULT G_PDB_NAME);
    -- drop pdb
    PROCEDURE drop_pdb(p_pdb_name IN VARCHAR2 DEFAULT G_PDB_NAME);
    -- create tbsp
    PROCEDURE create_tablespace(
        p_tbsp_name         IN  VARCHAR2,
        p_datafile_size     IN  VARCHAR2    DEFAULT '50M',
        p_datafile_next     IN  VARCHAR2    DEFAULT '25M',
        p_datafile_maxsize  IN  VARCHAR2    DEFAULT '5G',
        p_blocksize         IN  VARCHAR2    DEFAULT '8k'
    );
    -- create tbsp
    PROCEDURE drop_tablespace(
        p_tbsp_name     IN  VARCHAR2,
        p_pdb_name      IN  VARCHAR2    DEFAULT G_PDB_NAME
    );
    -- create user
    PROCEDURE create_user(
        p_username  IN  VARCHAR2,
        p_password  IN  VARCHAR2,
        p_pdb_name  IN  VARCHAR2    DEFAULT G_PDB_NAME
    );
    -- initialize data warehouse
    PROCEDURE init_dw;
    -- create dir
    PROCEDURE create_data_dir(
        p_dir_name  IN  VARCHAR2    DEFAULT G_DIRECTORY_NAME,
        p_data_dir  IN  VARCHAR2    DEFAULT G_DATA_DIR
    );

    -- -- procedure to query get_user_segmentation
    -- PROCEDURE get_user_segmentation(
    --     p_user_type     IN  VARCHAR2    DEFAULT NULL,
    --     p_year          IN  NUMBER      DEFAULT NULL,
    --     p_result        OUT SYS_REFCURSOR
    -- );

END DW_PKG;
/
--
CREATE OR REPLACE PACKAGE BODY DW_PKG AS

    -- switch container
    PROCEDURE switch_container(p_pdb_name IN VARCHAR2  DEFAULT G_PDB_NAME) IS
        v_sql  VARCHAR(2000);
    BEGIN
        DBMS_OUTPUT.ENABLE;
        
        -- Change container
        v_sql := 'ALTER SESSION SET CONTAINER=' || G_PDB_NAME ;
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('Switched to PDB ' || G_PDB_NAME);
    -- exception
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in create_tablespace: ' || SQLERRM);
            -- switch to root
            RAISE; -- raise

    END switch_container;

    -- Procedure to create PDB
    PROCEDURE create_pdb(p_pdb_name IN VARCHAR2 DEFAULT G_PDB_NAME) IS
        v_sql VARCHAR2(4000);
        v_pdb_exists NUMBER;
    BEGIN
        DBMS_OUTPUT.ENABLE;

        -- change container
        EXECUTE IMMEDIATE 'ALTER SESSION SET CONTAINER = CDB$ROOT';
        DBMS_OUTPUT.PUT_LINE('Switched to CDB$ROOT container');

        -- Check if pdb exits
        SELECT COUNT(*)
        INTO v_pdb_exists
        FROM v$pdbs
        WHERE name = UPPER(p_pdb_name);

        -- If exits
        IF v_pdb_exists = 1 THEN
            DBMS_OUTPUT.PUT_LINE('PDB ' || p_pdb_name || ' already exists');

           
        -- if not exits
        ELSE
            v_sql := '
                CREATE PLUGGABLE DATABASE ' || p_pdb_name || '
                ADMIN USER ' || G_PDB_ADMIN || ' IDENTIFIED BY "' || G_PDB_ADMIN_PWD || '"
                ROLES = (DBA)
                DEFAULT TABLESPACE USERS
                DATAFILE ''' || G_DATAFILE_PREFIX || '/' || G_ORACLE_SID || '/' || p_pdb_name || '/users01.dbf''
                SIZE 100M AUTOEXTEND ON NEXT 1G MAXSIZE 10G
                FILE_NAME_CONVERT = (''' || G_DATAFILE_PREFIX || '/' || G_ORACLE_SID || '/pdbseed/'', 
                                     ''' || G_DATAFILE_PREFIX || '/' || G_ORACLE_SID || '/' || p_pdb_name || '/'')
                STORAGE (MAXSIZE UNLIMITED)';
            
            -- create pdb
            EXECUTE IMMEDIATE v_sql;
            DBMS_OUTPUT.PUT_LINE('PDB ' || p_pdb_name || ' created successfully');
            
            -- open pdb
            EXECUTE IMMEDIATE 'ALTER PLUGGABLE DATABASE ' || p_pdb_name || ' OPEN';
            DBMS_OUTPUT.PUT_LINE('PDB ' || p_pdb_name || ' opened successfully');
            
            -- save state
            EXECUTE IMMEDIATE 'ALTER PLUGGABLE DATABASE ' || p_pdb_name || ' SAVE STATE';
            DBMS_OUTPUT.PUT_LINE('PDB ' || p_pdb_name || ' state saved');

        END IF;
    
    -- exdeption
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in create_pdb: ' || SQLERRM);
            RAISE; -- raise exception
    END create_pdb;
    
    -- Procedure to drop PDB
    PROCEDURE drop_pdb(p_pdb_name IN VARCHAR2 DEFAULT G_PDB_NAME) IS
        v_sql VARCHAR2(1000);
        v_pdb_exists NUMBER;
        v_pdb_status VARCHAR2(20);
    BEGIN
        
        -- Change current container
        EXECUTE IMMEDIATE 'ALTER SESSION SET CONTAINER = CDB$ROOT';

        -- Check if PDB exists
        SELECT COUNT(*)
        INTO v_pdb_exists
        FROM v$pdbs
        WHERE name = UPPER(p_pdb_name);
        
        -- if not exits
        IF v_pdb_exists = 0 THEN
            DBMS_OUTPUT.PUT_LINE('PDB ' || p_pdb_name || ' does not exist');
        -- if exits
        ELSE
            -- Check PDB status
            SELECT open_mode
            INTO v_pdb_status
            FROM v$pdbs
            WHERE name = UPPER(p_pdb_name);
            
            -- If open
            IF v_pdb_status != 'MOUNTED' THEN
                v_sql := 'ALTER PLUGGABLE DATABASE ' || p_pdb_name || ' CLOSE IMMEDIATE';
                -- close
                EXECUTE IMMEDIATE v_sql;
                DBMS_OUTPUT.PUT_LINE('PDB ' || p_pdb_name || ' closed successfully');
            END IF;
                
            -- Drop exits pdb
            v_sql := 'DROP PLUGGABLE DATABASE ' || p_pdb_name || ' INCLUDING DATAFILES';
            EXECUTE IMMEDIATE v_sql;
            DBMS_OUTPUT.PUT_LINE('PDB ' || p_pdb_name || ' dropped successfully');
        END IF;
    -- exception
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in drop_pdb: ' || SQLERRM);
            RAISE; -- raise exception
    END drop_pdb;
   
    -- Procedure to create table space
    PROCEDURE create_tablespace(
        p_tbsp_name         IN  VARCHAR2,
        p_datafile_size     IN  VARCHAR2    DEFAULT '50M',
        p_datafile_next     IN  VARCHAR2    DEFAULT '25M',
        p_datafile_maxsize  IN  VARCHAR2    DEFAULT '5G',
        p_blocksize         IN  VARCHAR2    DEFAULT '8k'
    ) IS
        v_sql VARCHAR2(2000);
        v_tbsp_exists NUMBER;
    BEGIN
        DBMS_OUTPUT.ENABLE;
        
        -- Change container
        v_sql := 'ALTER SESSION SET CONTAINER=' || G_PDB_NAME ;
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('Switched to PDB ' || G_PDB_NAME);
        
        -- Check if tablespace already exists
        SELECT COUNT(*)
        INTO v_tbsp_exists
        FROM dba_tablespaces
        WHERE tablespace_name = UPPER(p_tbsp_name);
        
        -- if exists
        IF v_tbsp_exists = 1 THEN
            DBMS_OUTPUT.PUT_LINE('Tablespace ' || p_tbsp_name || ' already exists');
        -- if not exits
        ELSE
            v_sql := '
                CREATE TABLESPACE ' || p_tbsp_name || '
                DATAFILE 
                    ''' || G_DATAFILE_PREFIX || '/' || G_ORACLE_SID || '/' || G_PDB_NAME || '/' || p_tbsp_name || '_01.dbf'' SIZE ' || p_datafile_size || '
                    AUTOEXTEND ON NEXT ' || p_datafile_next || ' MAXSIZE ' || p_datafile_maxsize || ',
                    ''' || G_DATAFILE_PREFIX || '/' || G_ORACLE_SID || '/' || G_PDB_NAME || '/' || p_tbsp_name || '_02.dbf'' SIZE ' || p_datafile_size || '
                    AUTOEXTEND ON NEXT ' || p_datafile_next || ' MAXSIZE ' || p_datafile_maxsize || '
                BLOCKSIZE ' || p_blocksize || '
                EXTENT MANAGEMENT LOCAL AUTOALLOCATE
                SEGMENT SPACE MANAGEMENT AUTO
                LOGGING
                ONLINE';
            
            -- Create tbsp
            EXECUTE IMMEDIATE v_sql;
            DBMS_OUTPUT.PUT_LINE('Tablespace ' || p_tbsp_name || ' created successfully');
        
        END IF;
        
        -- Switch to root
        EXECUTE IMMEDIATE 'ALTER SESSION SET CONTAINER = CDB$ROOT';
        DBMS_OUTPUT.PUT_LINE('Switched to CDB$ROOT container');
        
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in create_tablespace: ' || SQLERRM);
            -- switch to root
            EXECUTE IMMEDIATE 'ALTER SESSION SET CONTAINER = CDB$ROOT';
            DBMS_OUTPUT.PUT_LINE('Switched to CDB$ROOT container');
            RAISE; -- raise
    END create_tablespace;
    
    -- Procedure to drop table space
    PROCEDURE drop_tablespace(
        p_tbsp_name IN VARCHAR2,
        p_pdb_name IN VARCHAR2 DEFAULT G_PDB_NAME
    ) IS
        v_sql VARCHAR2(4000);
        v_tbsp_exists NUMBER;
    BEGIN
        DBMS_OUTPUT.ENABLE;
        
        -- Switch to the specified PDB
        EXECUTE IMMEDIATE 'ALTER SESSION SET CONTAINER = ' || p_pdb_name;
        DBMS_OUTPUT.PUT_LINE('Switched to PDB ' || p_pdb_name);
        
        -- Check if tablespace exists
        SELECT COUNT(*)
        INTO v_tbsp_exists
        FROM dba_tablespaces
        WHERE tablespace_name = UPPER(p_tbsp_name);
        
        -- if not exists
        IF v_tbsp_exists = 1 THEN
            DBMS_OUTPUT.PUT_LINE('Tablespace ' || p_tbsp_name || ' does not exist in PDB ' || p_pdb_name);
        -- if exits
        ELSE
            -- DROP TABLESPACE statement
            v_sql := 'DROP TABLESPACE ' || p_tbsp_name || ' INCLUDING CONTENTS AND DATAFILES';
            EXECUTE IMMEDIATE v_sql;
            DBMS_OUTPUT.PUT_LINE('Tablespace ' || p_tbsp_name || ' dropped successfully from PDB ' || p_pdb_name);
        END IF;
    
    -- exception
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in drop_tablespace: ' || SQLERRM);
            -- Switch to root
            EXECUTE IMMEDIATE 'ALTER SESSION SET CONTAINER = CDB$ROOT';
            DBMS_OUTPUT.PUT_LINE('Switched to CDB$ROOT container');
            RAISE;
    END drop_tablespace;
   
    -- Procedure to create user
    PROCEDURE create_user(
        p_username IN VARCHAR2,
        p_password IN VARCHAR2,
        p_pdb_name IN VARCHAR2 DEFAULT G_PDB_NAME
    ) IS
        v_sql VARCHAR2(2000);
        v_user_exists NUMBER;
    BEGIN
        DBMS_OUTPUT.ENABLE;
        
        -- Switch to PDB
        EXECUTE IMMEDIATE 'ALTER SESSION SET CONTAINER =' || p_pdb_name;
        DBMS_OUTPUT.PUT_LINE('Switched to PDB ' || p_pdb_name);
        
        -- Check if user exists
        SELECT COUNT(*)
        INTO v_user_exists
        FROM dba_users
        WHERE username = UPPER(p_username);
        
        -- if exits
        IF v_user_exists = 1 THEN
            DBMS_OUTPUT.PUT_LINE('User ' || p_username || ' already exists in PDB ' || p_pdb_name);
        ELSE
            -- Construct and execute the CREATE USER statement
            v_sql := '
                CREATE USER ' || p_username || '
                IDENTIFIED BY "' || p_password || '"
                DEFAULT TABLESPACE USERS
                TEMPORARY TABLESPACE TEMP';
            EXECUTE IMMEDIATE v_sql;
            DBMS_OUTPUT.PUT_LINE('User ' || p_username || ' created successfully in PDB ' || p_pdb_name);
        END IF;
    -- exception
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in create_user: ' || SQLERRM);
            RAISE; -- raise
    END create_user;


    PROCEDURE create_data_dir(
        p_dir_name  IN  VARCHAR2    DEFAULT G_DIRECTORY_NAME,
        p_data_dir  IN  VARCHAR2    DEFAULT G_DATA_DIR
    ) IS
        v_sql VARCHAR2(2000);
    BEGIN
        switch_container;

        -- Change container
        v_sql := 'CREATE OR REPLACE DIRECTORY ' || p_dir_name || ' AS ''' || p_data_dir || '''';
        -- DBMS_OUTPUT.PUT_LINE(v_sql);
        EXECUTE IMMEDIATE v_sql;
        DBMS_OUTPUT.PUT_LINE('Create Directory ' || p_dir_name || ' - ' || p_data_dir);
    -- exception
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in create_user: ' || SQLERRM);
            RAISE; --raise
    END create_data_dir;


    PROCEDURE init_dw IS
    BEGIN
        DBMS_OUTPUT.ENABLE;

        -- change container
        EXECUTE IMMEDIATE 'ALTER SESSION SET CONTAINER = CDB$ROOT';
        DBMS_OUTPUT.PUT_LINE('Switched to CDB$ROOT container');

        -- create pdb
        create_pdb();

        -- create fact_tbsp1 tbsp
        create_tablespace(
            p_tbsp_name         => 'FACT_TBSP',
            p_datafile_size     => '100M',
            p_datafile_next     => '1G',
            p_datafile_maxsize  => '50G',
            p_blocksize         => '32K'
        );

        -- create DIM_TBSP tbsp
        create_tablespace(
            p_tbsp_name         => 'DIM_TBSP'
        );

        -- create INDEX_TBSP tbsp
        create_tablespace(
            p_tbsp_name         => 'INDEX_TBSP'
        );

        -- create STAGING_TBSP tbsp
        create_tablespace(
            p_tbsp_name         => 'STAGING_TBSP',
            p_datafile_size     => '1G',
            p_datafile_next     => '500M',
            p_datafile_maxsize  => '10G'
        );

        -- create MV_TBSP tbsp
        create_tablespace(
            p_tbsp_name         => 'MV_TBSP'
        );
        
        create_data_dir;
        
        -- create schema
        create_user(
           p_username => 'DW_SCHEMA',
           p_password => 'Welcome!234'
        );

        EXECUTE IMMEDIATE 'ALTER USER DW_SCHEMA QUOTA UNLIMITED ON FACT_TBSP';
        EXECUTE IMMEDIATE 'ALTER USER DW_SCHEMA QUOTA UNLIMITED ON DIM_TBSP';
        EXECUTE IMMEDIATE 'ALTER USER DW_SCHEMA QUOTA UNLIMITED ON INDEX_TBSP';
        EXECUTE IMMEDIATE 'ALTER USER DW_SCHEMA QUOTA UNLIMITED ON STAGING_TBSP';
        EXECUTE IMMEDIATE 'ALTER USER DW_SCHEMA QUOTA UNLIMITED ON MV_TBSP';
        EXECUTE IMMEDIATE 'GRANT CREATE TABLE TO DW_SCHEMA';
        
        DBMS_OUTPUT.PUT_LINE('Alter quota!');
    -- exception
    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in create_user: ' || SQLERRM);
            drop_pdb();
    END init_dw;

  

BEGIN
    DBMS_OUTPUT.ENABLE;

    -- change container
    EXECUTE IMMEDIATE 'ALTER SESSION SET CONTAINER = CDB$ROOT';
    DBMS_OUTPUT.PUT_LINE('Switched to CDB$ROOT container');
    
    create_pdb();
END DW_PKG;
/
