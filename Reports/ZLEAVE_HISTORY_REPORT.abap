*&---------------------------------------------------------------------*
*& Report  ZLEAVE_HISTORY_REPORT
*& Full logic removed for safety; only loops, conditionals, and partial logic shown
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zleave_applications_manager.

TABLES: zleave_histo.

 " Code removed here

DATA: it_hist TYPE STANDARD TABLE OF ty_hist,
      wa_hist LIKE LINE OF  it_hist.

DATA: v_empid TYPE zemp_official-empid,
      v_id    TYPE zemp_official-email_id.

DATA: it_fieldcat TYPE slis_t_fieldcat_alv,
      wa_fieldcat LIKE LINE OF it_fieldcat.

DATA: v_program TYPE sy-repid,
      v_title   TYPE lvc_title.

TYPE-POOLS icon.

 " Code removed here


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

 " Code removed here

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

   " Code removed here

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

  " Code removed here

ENDFORM.
