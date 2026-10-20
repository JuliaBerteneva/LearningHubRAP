*&---------------------------------------------------------------------*
*& Report zlh_cleanup_empty_categories
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zlh_cleanup_empty_categories.

DATA lv_deleted TYPE i.

START-OF-SELECTION.

  SELECT FROM zlh_skill_categ
    FIELDS category_id,
           category_key
    WHERE category_key IS INITIAL
    INTO TABLE @DATA(lt_categories).

  LOOP AT lt_categories INTO DATA(ls_category).

    SELECT SINGLE FROM zlh_skill_categt
      FIELDS name
      WHERE category_id = @ls_category-category_id
        AND language = @sy-langu
      INTO @DATA(lv_name).

    IF sy-subrc = 0 AND lv_name IS NOT INITIAL.
      CONTINUE.
    ENDIF.

    SELECT SINGLE FROM zlh_skills
      FIELDS skill_id
      WHERE category = @ls_category-category_id
      INTO @DATA(lv_skill_id).

    IF sy-subrc = 0.
      WRITE:
        / |Skipped { ls_category-category_id }: category is used by a skill|.
      CONTINUE.
    ENDIF.

    DELETE FROM zlh_skill_categt
      WHERE category_id = @ls_category-category_id.

    DELETE FROM zlh_skill_categ
      WHERE category_id = @ls_category-category_id.

    IF sy-subrc = 0.
      lv_deleted += 1.

      WRITE:
        / |Deleted empty category { ls_category-category_id }|.
    ENDIF.

  ENDLOOP.

  COMMIT WORK AND WAIT.

  WRITE:
    / |Deleted { lv_deleted } empty category row(s).|.
