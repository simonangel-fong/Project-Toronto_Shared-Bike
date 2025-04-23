alter session set container=pdb1;
show con_name;

select *
from dw_schema.mv_user_segmentation;
/

create or replace function get_user_segmentation 
    return dw_schema.mv_user_segmentation%rowtype as p dw_schema.mv_user_segmentation%rowtype;
begin
    DBMS_OUTPUT.ENABLE;

    select * into p from dw_schema.mv_user_segmentation where rownum < 50;
    return p;

    EXCEPTION
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error in get_user_segmentation: ' || SQLERRM);
            RAISE;
END get_user_segmentation;
/

DECLARE
    l_cursor SYS_REFCURSOR;
    l_user_type VARCHAR2(50);
    l_year NUMBER;
    l_trip_count NUMBER;
    l_avg_duration NUMBER;
BEGIN
    -- Example 1: Filter by user type and year
    get_user_segmentation(
        p_user_type => 'Annual Member',
        p_year => 2019,
        p_result => l_cursor
    );
    
    -- Fetch and display results
    LOOP
        FETCH l_cursor INTO l_user_type, l_year, l_trip_count, l_avg_duration;
        EXIT WHEN l_cursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE('User Type: ' || l_user_type || 
                            ', Year: ' || l_year || 
                            ', Total Trip: ' || l_trip_count || 
                            ', Avg Duration: ' || l_avg_duration);
    END LOOP;
    CLOSE l_cursor;
END;