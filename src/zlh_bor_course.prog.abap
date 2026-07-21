*****           Implementation of object type ZLHCOURSE            *****
INCLUDE <object>.
BEGIN_DATA OBJECT. " Do not change.. DATA is generated
* only private members may be inserted into structure private
DATA:
" begin of private,
"   to declare private attributes remove comments and
"   insert private attributes here ...
" end of private,
  BEGIN OF KEY,
      COURSE_KEY LIKE ZLH_COURSE-COURSE_KEY,
  END OF KEY,
      _ZLH_COURSE LIKE ZLH_COURSE.
END_DATA OBJECT. " Do not change.. DATA is generated

TABLES zlh_course.
*
get_table_property zlh_course.
DATA subrc LIKE sy-subrc.
* Fill TABLES ZLH_COURSE to enable Object Manager Access to Table
* Properties
PERFORM select_table_zlh_course USING subrc.
IF subrc NE 0.
  exit_object_not_found.
ENDIF.
end_property.
*
* Use Form also for other(virtual) Properties to fill TABLES ZLH_COURSE
FORM select_table_zlh_course USING subrc LIKE sy-subrc.
* Select single * from ZLH_COURSE, if OBJECT-_ZLH_COURSE is initial
  IF object-_zlh_course-client IS INITIAL
  AND object-_zlh_course-course_id IS INITIAL.
    SELECT SINGLE * FROM zlh_course CLIENT SPECIFIED
        WHERE client = sy-mandt.
    subrc = sy-subrc.
    IF subrc NE 0. EXIT. ENDIF.
    object-_zlh_course = zlh_course.
  ELSE.
    subrc = 0.
    zlh_course = object-_zlh_course.
  ENDIF.
ENDFORM.

begin_method course_approve changing container.
zcl_lh_course_workflow=>COURSE_APPROVE( ).
end_method.
