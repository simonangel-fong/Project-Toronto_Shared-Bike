ALTER SESSION set container=CDB$ROOT;

BEGIN
    DW_PKG.drop_pdb;
    DW_PKG.init_dw;
    DW_PKG.create_data_dir;
END;
/
@04DW_Creation.sql
/