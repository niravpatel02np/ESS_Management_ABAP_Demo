*&---------------------------------------------------------------------*
*& Report  ZLEAVE_HISTORY_REPORT
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zleave_applications_manager.

TABLES: zleave_histo.

TYPES: BEGIN OF ty_hist,
         icon        TYPE char4,
         leaveid     LIKE zleave_histo-leaveid,
         begin_date  LIKE zleave_histo-begin_date,
         end_date    LIKE zleave_histo-end_date,
         applydate   LIKE zleave_histo-applydate,
         applytime   LIKE zleave_histo-applytime,
         day_type    LIKE zleave_histo-day_type,
         no_of_days  LIKE zleave_histo-no_of_days,
         leave_type  LIKE zleave_histo-leave_type,
         reason      LIKE zleave_histo-reason,
         approver    LIKE zleave_histo-approver,
         status      LIKE zleave_histo-status,
         approved_on LIKE zleave_histo-approved_on,
         zcomment    LIKE zleave_histo-zcomment,
       END OF ty_hist.

DATA: it_hist TYPE STANDARD TABLE OF ty_hist,
      wa_hist LIKE LINE OF  it_hist.

DATA: v_empid TYPE zemp_official-empid,
      v_id    TYPE zemp_official-email_id.

DATA: it_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat LIKE LINE OF it_fieldcat.

DATA: v_program TYPE sy-repid,
      v_title   TYPE lvc_title.

TYPE-POOLS icon.

CONSTANTS: c_green  TYPE icon-id VALUE '@08@',
           c_yellow TYPE icon-id VALUE '@09@',
           c_red    TYPE icon-id VALUE '@0A@'.


SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: p_empid  TYPE zleave_histo-empid.
PARAMETERS   c_team AS CHECKBOX DEFAULT ''.
SELECTION-SCREEN END OF BLOCK b1.
SKIP 2.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
PARAMETERS: p_status TYPE zleave_histo-status.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.
SELECT-OPTIONS: s_pdate FOR zleave_histo-approved_on,
                s_adate FOR zleave_histo-applydate.
SELECTION-SCREEN END OF BLOCK b3.

START-OF-SELECTION.
  PERFORM fetch_data.

END-OF-SELECTION.
  PERFORM set_fieldcat.
  PERFORM display_alv.

*&---------------------------------------------------------------------*
*&      Form  FETCH_DATA
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fetch_data .

  IMPORT v_id  FROM MEMORY ID 'ID5'.

  IF c_team IS INITIAL AND p_empid IS INITIAL.
    MESSAGE 'Please select the employee or team for whom you want to view applications' TYPE 'E'.
  ENDIF.

  IF p_status IS NOT INITIAL.
    IF c_team = 'X'.
      SELECT * FROM zleave_histo INTO CORRESPONDING FIELDS OF TABLE it_hist
  WHERE approver EQ v_id AND
  approved_on IN s_pdate AND
  applydate IN s_adate AND
        status EQ p_status.

    ELSE.
      SELECT * FROM zleave_histo INTO CORRESPONDING FIELDS OF TABLE it_hist
  WHERE approver EQ v_id AND
  approved_on IN s_pdate AND
  applydate IN s_adate AND
  empid EQ p_empid  AND
        status EQ p_status.
    ENDIF.
  ELSE.
    IF c_team = 'X'.
      SELECT * FROM zleave_histo INTO CORRESPONDING FIELDS OF TABLE it_hist
  WHERE approver EQ v_id AND
  approved_on IN s_pdate AND
  applydate IN s_adate.


    ELSE.
      SELECT * FROM zleave_histo INTO CORRESPONDING FIELDS OF TABLE it_hist
  WHERE approver EQ v_id AND
  approved_on IN s_pdate AND
  applydate IN s_adate AND
  empid EQ p_empid.

    ENDIF.
  ENDIF.

  IF it_hist IS INITIAL.
    MESSAGE 'No leave applications were submitted to you within the specified selection criteria.' TYPE 'I'.
  ELSE.
    SORT it_hist BY approved_on.
    LOOP AT it_hist INTO wa_hist.
      IF wa_hist-status = 'Pending'.
        MOVE c_yellow TO wa_hist-icon.
        MODIFY it_hist FROM wa_hist.
      ELSEIF wa_hist-status = 'Approved'.
        MOVE c_green TO wa_hist-icon.
        MODIFY it_hist FROM wa_hist.
      ELSEIF wa_hist-status = 'Rejected'.
        MOVE c_red TO wa_hist-icon.
        MODIFY it_hist FROM wa_hist.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  SET_FIELDCAT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM set_fieldcat .

***Building Fieldcatalog
  CLEAR: it_fieldcat.

  wa_fieldcat-fieldname = 'ICON'.
  wa_fieldcat-seltext_m = ' '.
  wa_fieldcat-col_pos = 1.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR: wa_fieldcat.

  wa_fieldcat-fieldname = 'LEAVEID'.
  wa_fieldcat-seltext_m = 'Leave ID'.
  wa_fieldcat-col_pos = 2.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR: wa_fieldcat.

  wa_fieldcat-fieldname = 'EMPID'.
  wa_fieldcat-seltext_m = 'Employee ID'.
  wa_fieldcat-col_pos = 2.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR: wa_fieldcat.

  wa_fieldcat-fieldname = 'APPROVED_ON'.
  wa_fieldcat-seltext_m = 'Processed On'.
  wa_fieldcat-col_pos = 3.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR: wa_fieldcat.

  wa_fieldcat-fieldname = 'ZCOMMENT'.
  wa_fieldcat-seltext_m = 'My Remark'.
  wa_fieldcat-col_pos = 4.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR: wa_fieldcat.

  wa_fieldcat-fieldname = 'APPLYDATE'.
  wa_fieldcat-seltext_m = 'Application Date'.
  wa_fieldcat-col_pos = 5.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR: wa_fieldcat.

  wa_fieldcat-fieldname = 'BEGIN_DATE'.
  wa_fieldcat-seltext_m = 'Leave From'.
  wa_fieldcat-col_pos = 6.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR: wa_fieldcat.

  wa_fieldcat-fieldname = 'END_DATE'.
  wa_fieldcat-seltext_m = 'Leave To'.
  wa_fieldcat-col_pos = 7.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR: wa_fieldcat.

  wa_fieldcat-fieldname = 'NO_OF_DAYS'.
  wa_fieldcat-seltext_l = 'Number of Days'.
  wa_fieldcat-col_pos = 8.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR: wa_fieldcat.

  wa_fieldcat-fieldname = 'LEAVE_TYPE'.
  wa_fieldcat-seltext_m = 'Leave Type'.
  wa_fieldcat-col_pos = 9.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR: wa_fieldcat.

  wa_fieldcat-fieldname = 'REASON'.
  wa_fieldcat-seltext_m = 'Leave Reason'.
  wa_fieldcat-col_pos = 10.
  APPEND wa_fieldcat TO it_fieldcat.
  CLEAR: wa_fieldcat.

  LOOP AT it_fieldcat INTO wa_fieldcat.
    wa_fieldcat-tabname = 'IT_HIST'.
    wa_fieldcat-just = 'C'.
    wa_fieldcat-outputlen = 15.
    wa_fieldcat-icon = 'X'.
    MODIFY it_fieldcat FROM  wa_fieldcat TRANSPORTING tabname just outputlen.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  DISPLAY_ALV
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM display_alv .

  CLEAR: v_program.
  v_program = sy-repid.

  IF it_hist IS NOT INITIAL.

    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        " i_callback_program = v_program
*       IS_LAYOUT     =
        it_fieldcat   = it_fieldcat
*       i_grid_title  = v_title
*       IT_EVENTS     =
*       IT_EVENT_EXIT =
* IMPORTING
*       E_EXIT_CAUSED_BY_CALLER           =
*       ES_EXIT_CAUSED_BY_USER            =
      TABLES
        t_outtab      = it_hist
      EXCEPTIONS
        program_error = 1
        OTHERS        = 2.
    IF sy-subrc <> 0.
* Implement suitable error handling here
      MESSAGE 'Some errors occurred while displaying ALV.' TYPE 'E'.
    ENDIF.
  ENDIF.

ENDFORM.
