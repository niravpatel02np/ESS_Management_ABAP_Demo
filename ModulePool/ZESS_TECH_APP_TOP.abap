*&---------------------------------------------------------------------*
*& Include ZESS_TECH_APP_TOP                                 Module Pool      ZESS_TECH_APP
*& Full logic removed for safety; only loops, conditionals, and partial logic shown
*&
*&---------------------------------------------------------------------*
PROGRAM zess_tech_app.

******************************************************
*Table Declaration
******************************************************
  " Code removed

******************************************************
*Types
******************************************************
TYPE-POOLS: cndp.
TYPES pict_line(256) TYPE c.

******************************************************
*Data Declaration
******************************************************
DATA: w_lines TYPE i.

  " Code removed

******************************************************
*Screen fields Declaration
******************************************************
DATA: ok_code        TYPE sy-ucomm,
      in_loginid     TYPE zemp_credes-loginid,
      in_password    TYPE zemp_credes-password,
      op_name        TYPE zemp_personal-prefer_name,
      in_prefer_name TYPE zemp_personal-prefer_name,
      io_status      TYPE z120_status,
      op_des         TYPE zemp_official-designation,
      op_dc          TYPE zemp_official-office_city,

      p_objid        TYPE w3objid.

******************************************************
*Variables Declaration
******************************************************
  " Code removed

******************************************************
*Flags
******************************************************
DATA: flag_tab2 TYPE flag.

******************************************************
*Internal Tables and Work Area
******************************************************
DATA: wa_emp TYPE zemp_credes.

DATA: it_per TYPE STANDARD TABLE OF zemp_personal,
      wa_per LIKE LINE OF it_per.

DATA: it_off TYPE STANDARD TABLE OF zemp_official,
      wa_off LIKE LINE OF it_off.

TYPES: BEGIN OF ty_leave_man.
        INCLUDE STRUCTURE zleave_histo.
TYPES: mark,
       END OF ty_leave_man.

DATA: it_leave_man TYPE ty_leave_man OCCURS 0 WITH HEADER LINE,
      wa_leave_man LIKE LINE OF it_leave_man,
      wa_leave_app TYPE zleave_histo.

DATA: wa_bal TYPE zleave_score.

DATA: wa_proj TYPE zproject_secure.

******************************************************
*Tabstrip Wizard generated Declarations
******************************************************
CONSTANTS: cntl_true  TYPE i VALUE 1,
           cntl_false TYPE i VALUE 0.

*&SPWIZARD: FUNCTION CODES FOR TABSTRIP 'ZTAB_EMP'
CONSTANTS: BEGIN OF c_ztab_emp,
             tab1 LIKE sy-ucomm VALUE 'ZTAB_EMP_FC1',
             tab2 LIKE sy-ucomm VALUE 'ZTAB_EMP_FC2',
             tab3 LIKE sy-ucomm VALUE 'ZTAB_EMP_FC3',
           END OF c_ztab_emp.
*&SPWIZARD: DATA FOR TABSTRIP 'ZTAB_EMP'
CONTROLS:  ztab_emp TYPE TABSTRIP.
DATA:      BEGIN OF g_ztab_emp,
             subscreen   LIKE sy-dynnr,
             prog        LIKE sy-repid VALUE 'ZESS_TECH_APP',
             pressed_tab LIKE sy-ucomm VALUE c_ztab_emp-tab1,
           END OF g_ztab_emp.

*&SPWIZARD: DECLARATION OF TABLECONTROL 'TC1_LEAVE' ITSELF
CONTROLS: tc1_leave TYPE TABLEVIEW USING SCREEN 0450.

*&SPWIZARD: LINES OF TABLECONTROL 'TC1_LEAVE'
DATA:     g_tc1_leave_lines  LIKE sy-loopc.
