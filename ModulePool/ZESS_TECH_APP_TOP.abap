*&---------------------------------------------------------------------*
*& Include ZESS_TECH_APP_TOP                                 Module Pool      ZESS_TECH_APP
*&
*&---------------------------------------------------------------------*
PROGRAM zess_tech_app.

******************************************************
*Table Declaration
******************************************************
TABLES: zemp_credes, zemp_official, zemp_personal, zproject_secure.
TABLES: zleave_histo, zleave_score.

******************************************************
*Types
******************************************************
TYPE-POOLS: cndp.
TYPES pict_line(256) TYPE c.

******************************************************
*Data Declaration
******************************************************
DATA: w_lines TYPE i.

DATA :  container TYPE REF TO cl_gui_custom_container,
        editor    TYPE REF TO cl_gui_textedit,
        picture   TYPE REF TO cl_gui_picture,
        pict_tab  TYPE TABLE OF pict_line,
        url(255)  TYPE c.

DATA :  container_dp TYPE REF TO cl_gui_custom_container,
        picture_dp   TYPE REF TO cl_gui_picture.

DATA: graphic_url(255).
DATA: url_dp(255) TYPE c.

DATA: BEGIN OF graphic_table OCCURS 0,
        line(255) TYPE x,
      END OF graphic_table.

DATA: l_graphic_conv TYPE i.
DATA: l_graphic_offs TYPE i.
DATA: graphic_size TYPE i.
DATA: l_graphic_xstr TYPE xstring.

DATA: BEGIN OF graphic_table_dp OCCURS 0,
        line(255) TYPE x,
      END OF graphic_table_dp.

DATA: l_graphic_conv_dp TYPE i.
DATA: l_graphic_offs_dp TYPE i.
DATA: graphic_size_dp TYPE i.
DATA: l_graphic_xstr_dp TYPE xstring.

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
DATA: lv_key              TYPE z120_pronouns,
      lv_description      TYPE z120_pronouns,
      lv_sex              TYPE z120_sex,
      lv_gender           TYPE z120_gender,
      lv_answer           TYPE c,
      lv_approver         TYPE z120_empid,
      lv_email            TYPE z120_emailid,
      lv_leaveid          TYPE zleave_histo-leaveid,
      lv_bal              TYPE zleave_score-leave_balance,
      lv_balance          TYPE zleave_score-leave_balance,
      lv_upd_bal          TYPE zleave_score-leave_balance,
      lv_fieldname        TYPE fieldname,
      lv_date             TYPE sy-datum,
      lv_day              LIKE dtresr-weekday,
      lv_contains_weekend TYPE abap_bool VALUE abap_false,
      lv_leave_type       TYPE z120_leavetype,
      lv_no_days          TYPE p DECIMALS 2,
      lv_div              TYPE p DECIMALS 2 VALUE '2.0',
      v_empid             TYPE zemp_official-empid,
      v_id                TYPE zemp_official-email_id.

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

DATA: it_leave TYPE STANDARD TABLE OF zleave_histo,
      wa_leave TYPE zleave_histo.

DATA: it_score TYPE STANDARD TABLE OF zleave_score,
      wa_score LIKE LINE OF it_score.

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
