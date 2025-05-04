ALTER SESSION SET container=toronto_shared_bike;

BEGIN
    update_directory_for_year(2024);
END;
/