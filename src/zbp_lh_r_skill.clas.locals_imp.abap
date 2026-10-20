CLASS lhc_zlh_r_skill DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Skill RESULT result.

    METHODS suggestfor FOR MODIFY
      IMPORTING keys FOR ACTION Skill~suggestfor RESULT result..

    METHODS wanttolearn FOR MODIFY
      IMPORTING keys FOR ACTION Skill~wanttolearn RESULT result..

ENDCLASS.

CLASS lhc_zlh_r_skill IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD suggestFor.
    DATA: ls_failed   TYPE RESPONSE FOR FAILED   zlh_r_user_skill,
          ls_reported TYPE RESPONSE FOR REPORTED zlh_r_user_skill,
          ls_mapped   TYPE RESPONSE FOR MAPPED   zlh_r_user_skill.

    DATA lt_create TYPE TABLE FOR CREATE zlh_r_user_skill.
    DATA lt_update TYPE TABLE FOR UPDATE zlh_r_user_skill.

    DATA(lv_skill_id)   = keys[ 1 ]-SkillId.
    DATA(lt_colleagues) = keys[ 1 ]-%param-_colleagues.

    READ ENTITIES OF zlh_r_skill IN LOCAL MODE
      ENTITY Skill
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_skills).

    "validate that at least 1 colleague is chosen
    IF lt_colleagues IS INITIAL.
      APPEND VALUE #(
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = 'Please choose at least one colleague.' ) )
        TO reported-skill.
      APPEND VALUE #( %fail-cause = if_abap_behv=>cause-unspecific )
        TO failed-skill.
      RETURN.
    ENDIF.

    "validate that current user is team lead
    SELECT SINGLE @abap_true
      FROM zlh_user_rel
      WHERE parent_user     = @sy-uname
        AND relationship_id = 'LEADER_TO'
      INTO @DATA(lv_is_lead).

    IF sy-subrc <> 0.
      APPEND VALUE #(
        %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text     = |You are not the team lead.| ) )
        TO reported-skill.
      APPEND VALUE #( %fail-cause = if_abap_behv=>cause-unauthorized )
        TO failed-skill.
      RETURN.
    ENDIF.

    "read existing user-skill records for the chosen colleagues
    READ ENTITIES OF zlh_r_user_skill
      ENTITY UserSkill
      FIELDS ( ProposedForLearning )
      WITH VALUE #( FOR c IN lt_colleagues
                    ( SkillId = lv_skill_id UserId = c-Colleague ) )
      RESULT DATA(lt_existing).

    LOOP AT lt_colleagues INTO DATA(ls_target_colleague).
      DATA(lv_tabix) = sy-tabix.
      DATA(ls_existing) = VALUE #( lt_existing[ KEY entity
                                                SkillId = lv_skill_id
                                                UserId  = ls_target_colleague-Colleague ]
                                   OPTIONAL ).

      IF ls_existing IS NOT INITIAL.
        IF ls_existing-ProposedForLearning = abap_true.
          CONTINUE.
        ENDIF.

        APPEND VALUE #( %tky                = ls_existing-%tky
                        ProposedForLearning = abap_true )
          TO lt_update.
      ELSE.
        APPEND VALUE #( %cid                = |suggest_{ lv_tabix }|
                        SkillId             = lv_skill_id
                        UserId              = ls_target_colleague-Colleague
                        ProposedForLearning = abap_true )
          TO lt_create.
      ENDIF.
    ENDLOOP.

    IF lt_create IS INITIAL AND lt_update IS INITIAL.
      DATA(lv_skill_name) = VALUE string( lt_skills[ 1 ]-Name OPTIONAL ).

      DATA(lo_msg) = COND #(
        WHEN lines( lt_colleagues ) = 1
        THEN new_message( id       = 'ZLH_PERSONAL_GROWTH'
                          number   = '004'
                          severity = if_abap_behv_message=>severity-information
                          v1       = lv_skill_name
                          v2       = lt_colleagues[ 1 ]-FullName )
        ELSE new_message( id       = 'ZLH_PERSONAL_GROWTH'
                          number   = '005'
                          severity = if_abap_behv_message=>severity-information
                          v1       = lv_skill_name ) ).

      APPEND VALUE #( %msg = lo_msg ) TO reported-skill.
    ELSE.
      MODIFY ENTITIES OF zlh_r_user_skill
        ENTITY UserSkill
          CREATE FIELDS ( SkillId UserId ProposedForLearning )
            WITH lt_create
          UPDATE FIELDS ( ProposedForLearning )
            WITH lt_update
        FAILED ls_failed
        REPORTED ls_reported
        MAPPED ls_mapped.

      IF ls_failed IS NOT INITIAL.
        LOOP AT ls_failed-userskill INTO DATA(ls_fail).
          APPEND VALUE #(
            %msg = new_message_with_text(
              severity = if_abap_behv_message=>severity-error
              text     = |Could not suggest skill for { ls_fail-UserId }| ) )
            TO reported-skill.
        ENDLOOP.

        APPEND VALUE #( %fail-cause = if_abap_behv=>cause-unspecific )
          TO failed-skill.
        RETURN.
      ENDIF.
    ENDIF.

    result = VALUE #( FOR s IN lt_skills ( %tky = s-%tky %param = s ) ).
  ENDMETHOD.

  METHOD wantToLearn.
    DATA: ls_failed   TYPE RESPONSE FOR FAILED   zlh_r_my_skills,
          ls_reported TYPE RESPONSE FOR REPORTED zlh_r_my_skills,
          ls_mapped   TYPE RESPONSE FOR MAPPED   zlh_r_my_skills.

    DATA lt_existing TYPE TABLE FOR READ RESULT zlh_r_my_skills.
    DATA lt_create   TYPE TABLE FOR CREATE zlh_r_my_skills.
    DATA lt_update   TYPE TABLE FOR UPDATE zlh_r_my_skills.

    DATA(lv_skill_id) = keys[ 1 ]-SkillId.

    READ ENTITIES OF zlh_r_my_skills
        ENTITY Skills
        FIELDS ( SkillId UserId WantToLearn )
        WITH VALUE #( ( SkillId = lv_skill_id UserId = sy-uname ) )
        RESULT lt_existing.

    DATA(ls_existing) = VALUE #(
      lt_existing[ KEY entity SkillId = lv_skill_id UserId = sy-uname ]
      OPTIONAL ).

    IF ls_existing IS NOT INITIAL.
      IF ls_existing-WantToLearn = abap_false.
        APPEND VALUE #( %tky = ls_existing-%tky
                        WantToLearn = abap_true )
          TO lt_update.
      ENDIF.
    ELSE.
      APPEND VALUE #( %cid = 'want_to_learn_1'
                      SkillId = lv_skill_id
                      UserId = sy-uname
                      WantToLearn = abap_true )
        TO lt_create.
    ENDIF.

    IF lt_create IS NOT INITIAL OR lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF zlh_r_my_skills
          ENTITY Skills
          CREATE FIELDS ( SkillId UserId WantToLearn )
          WITH lt_create
          UPDATE FIELDS ( WantToLearn )
          WITH lt_update
          FAILED ls_failed
          REPORTED ls_reported
          MAPPED ls_mapped.

      IF ls_failed IS NOT INITIAL.
        APPEND VALUE #( %msg = new_message_with_text(
          severity = if_abap_behv_message=>severity-error
          text = 'This skill could not be added to your list.' ) )
          TO reported-skill.
        APPEND VALUE #( %fail-cause = if_abap_behv=>cause-unspecific )
          TO failed-skill.
      ENDIF.
    ENDIF.

    result = VALUE #( FOR ls_key IN keys
      ( %tky = ls_key-%tky ) ).

  ENDMETHOD.

ENDCLASS.
