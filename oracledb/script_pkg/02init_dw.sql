ALTER SESSION set container=CDB$ROOT;

BEGIN
    DW_PKG.drop_pdb;
    DW_PKG.init_dw;
END;
/

@05ELT-Creation.sql;
@06MV_Creation.sql;
/