*&---------------------------------------------------------------------*
*&  Include           ZESS_TECH_APP_O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.
  SET PF-STATUS 'ZSTATUS_0100'.
  SET TITLEBAR 'ZTITLE_0100'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0300  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0300 OUTPUT.
  SET PF-STATUS 'ZSTATUS_0300'.
  SET TITLEBAR 'ZTITLE_0300'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SHOW_EMP_DETAILS  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE show_emp_details OUTPUT.

******************************************************
*Display Personal Information
******************************************************
  IF  ok_code <> 'CANCEL'.
    CLEAR: wa_per.
    SELECT SINGLE * FROM zemp_personal INTO wa_per WHERE empid = wa_emp-empid.
    op_name = wa_per-prefer_name.
    "in_prefer_name = wa_per-prefer_name.

*Get the description for a fixed value in the domain
    SELECT SINGLE ddtext INTO lv_description
      FROM dd07t
      WHERE domname = 'Z120_PRONOUNS'
        AND ddlanguage = sy-langu
        AND domvalue_l = wa_per-pronouns.

    SELECT SINGLE ddtext INTO lv_sex
      FROM dd07t
      WHERE domname = 'Z120_SEX'
      AND ddlanguage = sy-langu
      AND domvalue_l = wa_per-sex.

    SELECT SINGLE ddtext INTO lv_gender
    FROM dd07t
    WHERE domname = 'Z120_GENDER'
    AND ddlanguage = sy-langu
    AND domvalue_l = wa_per-gender_expression.

    wa_per-pronouns = lv_description.
    wa_per-sex = lv_sex.
    wa_per-gender_expression = lv_gender.
  ENDIF.

******************************************************
*Display Official Information
******************************************************
  CLEAR: wa_off.
  SELECT SINGLE * FROM zemp_official INTO wa_off WHERE empid = wa_emp-empid.

ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0400  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0400 OUTPUT.
  SET PF-STATUS 'ZSTATUS_0400'.
  SET TITLEBAR 'ZTITLE_0400'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  DISPLAY_APPROVER  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE display_approver OUTPUT.

  IF ok_code <> 'CANCEL'.
    CLEAR: lv_approver, lv_email.
    SELECT SINGLE manager FROM zemp_official INTO lv_approver WHERE empid = wa_emp-empid.
    SELECT SINGLE email_id FROM zemp_official INTO lv_email WHERE empid = lv_approver.

    wa_leave-approver = lv_email.
  ENDIF.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0200 OUTPUT.
  SET PF-STATUS 'ZSTATUS_0200'.
  SET TITLEBAR 'ZTITLE_0200'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  MODIFY_SCREEN_0200  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE modify_screen_0200 OUTPUT.

  IF wa_emp-zauthorization <> 'Manager'.
    LOOP AT SCREEN.
      IF screen-name = 'BOX2' OR screen-group1 = 'G1'.
        screen-invisible = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

*  p_objid = 'ZEMP_IMG'.
*  "AT SELECTION-SCREEN.
*  SELECT COUNT(*) FROM wwwparams
*  WHERE objid = p_objid.
*  IF sy-subrc <> 0.
*    MESSAGE e001(00) WITH 'MIME Object not found'.
*  ENDIF.
*
*
*  "START-OF-SELECTION.
*
*  IF container IS INITIAL.
*
*    CREATE OBJECT container
*      EXPORTING
*        container_name              = 'CONT'
*        repid                       = sy-repid
*        dynnr                       = sy-dynnr
*      EXCEPTIONS
*        cntl_error                  = 1
*        cntl_system_error           = 2
*        create_error                = 3
*        lifetime_error              = 4
*        lifetime_dynpro_dynpro_link = 5
*        OTHERS                      = 6.
*    IF sy-subrc <> 0.
*      MESSAGE i001(00) WITH 'Error while creating container'.
*      LEAVE LIST-PROCESSING.
*    ENDIF.
*  ENDIF.
*  IF picture IS INITIAL.
*    CREATE OBJECT picture
*      EXPORTING
*        parent = container
*      EXCEPTIONS
*        error  = 1
*        OTHERS = 2.
*    IF sy-subrc <> 0.
*      MESSAGE i001(00) WITH 'Error while displaying picture'.
*      LEAVE LIST-PROCESSING.
*    ENDIF.
*  ENDIF.
*  IF picture IS NOT INITIAL.
*
*    CALL FUNCTION 'DP_PUBLISH_WWW_URL'
*      EXPORTING
*        objid    = p_objid
*        lifetime = cndp_lifetime_transaction
*      IMPORTING
*        url      = url
*      EXCEPTIONS
*        OTHERS   = 1.
*
*    IF sy-subrc = 0.
*      CALL METHOD picture->load_picture_from_url_async
*        EXPORTING
*          url = url.
*
*      CALL METHOD picture->set_display_mode
*        EXPORTING
*          display_mode = cl_gui_picture=>display_mode_fit.
*    ELSE.
*      MESSAGE i001(00) WITH 'Error while load picture'.
*      LEAVE LIST-PROCESSING.
*    ENDIF.
*  ENDIF.

  CALL METHOD cl_gui_cfw=>flush.

  CREATE OBJECT:  container EXPORTING container_name = 'CONT',
    picture EXPORTING parent = container.

  CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp
    EXPORTING
      p_object = 'GRAPHICS'
      p_name   = 'ZEMP_IMG'
      p_id     = 'BMAP'
      p_btype  = 'BCOL'
    RECEIVING
      p_bmp    = l_graphic_xstr
    EXCEPTIONS
      OTHERS   = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  graphic_size = xstrlen( l_graphic_xstr ).
  l_graphic_conv = graphic_size.
  l_graphic_offs = 0.

  WHILE l_graphic_conv > 255.
    graphic_table-line = l_graphic_xstr+l_graphic_offs(255).
    APPEND graphic_table.
    l_graphic_offs = l_graphic_offs + 255.
    l_graphic_conv = l_graphic_conv - 255.
  ENDWHILE.
  graphic_table-line = l_graphic_xstr+l_graphic_offs(l_graphic_conv).

  APPEND graphic_table.

  CALL FUNCTION 'DP_CREATE_URL'
    EXPORTING
      type     = 'IMAGE'
      subtype  = 'GIF'
      size     = graphic_size
      lifetime = 'T'
    TABLES
      data     = graphic_table
    CHANGING
      url      = url.
  CALL METHOD picture->load_picture_from_url EXPORTING url = url.
  CALL METHOD picture->set_display_mode
    EXPORTING
      display_mode = picture->display_mode_fit_center.

  CALL METHOD cl_gui_cfw=>flush.

  CLEAR: wa_per.
  SELECT SINGLE * FROM zemp_personal INTO wa_per WHERE empid = wa_emp-empid.
  op_name = wa_per-prefer_name.

  CLEAR: wa_off.
  SELECT SINGLE * FROM zemp_official INTO wa_off WHERE empid = wa_emp-empid.
  op_des = wa_off-designation.
  op_dc = wa_off-office_city.
ENDMODULE.


************************************************************************************************************
*Tabstrip Wizard generated code
************************************************************************************************************
*&SPWIZARD: OUTPUT MODULE FOR TS 'ZTAB_EMP'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: SETS ACTIVE TAB
MODULE ztab_emp_active_tab_set OUTPUT.
  ztab_emp-activetab = g_ztab_emp-pressed_tab.
  CASE g_ztab_emp-pressed_tab.
    WHEN c_ztab_emp-tab1.
      g_ztab_emp-subscreen = '0311'.
    WHEN c_ztab_emp-tab2.
      g_ztab_emp-subscreen = '0312'.
    WHEN c_ztab_emp-tab3.
      g_ztab_emp-subscreen = '0313'.
    WHEN OTHERS.
*&SPWIZARD:      DO NOTHING
  ENDCASE.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  STATUS_0450  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0450 OUTPUT.
  SET PF-STATUS 'ZSTATUS_0450'.
  SET TITLEBAR 'ZTITLE_0450'.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC1_LEAVE'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: UPDATE LINES FOR EQUIVALENT SCROLLBAR
MODULE tc1_leave_change_tc_attr OUTPUT.
  DESCRIBE TABLE it_leave_man LINES tc1_leave-lines.

  IF ok_code = 'LAPPROVE'.
    CLEAR: wa_off.
    SELECT SINGLE * FROM zemp_official INTO wa_off WHERE empid = wa_emp-empid.
    CLEAR: wa_leave_man.
    SELECT * FROM zleave_histo INTO CORRESPONDING FIELDS OF TABLE it_leave_man WHERE approver = wa_off-email_id AND status = 'Pending'.

    LOOP AT it_leave_man INTO wa_leave_man.
*Get the description for a fixed value in the domain
      SELECT SINGLE ddtext INTO lv_leave_type
        FROM dd07t
        WHERE domname = 'Z120_LEAVETYPE'
          AND ddlanguage = sy-langu
          AND domvalue_l = wa_leave_man-leave_type.
      wa_leave_man-leave_type = lv_leave_type.

      " io_status = wa_leave_man-status.
      MODIFY it_leave_man FROM wa_leave_man.
    ENDLOOP.
  ENDIF.
ENDMODULE.

*&SPWIZARD: OUTPUT MODULE FOR TC 'TC1_LEAVE'. DO NOT CHANGE THIS LINE!
*&SPWIZARD: GET LINES OF TABLECONTROL
MODULE tc1_leave_get_lines OUTPUT.
  g_tc1_leave_lines = sy-loopc.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  SHOW_DP  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE show_dp OUTPUT.

  DATA: v_name TYPE tdobname.
  CLEAR: v_name, l_graphic_xstr, graphic_size, l_graphic_conv, graphic_table, l_graphic_offs, url.

  CALL METHOD cl_gui_cfw=>flush.

  CREATE OBJECT:  container_dp EXPORTING container_name = 'CC_DP',
    picture_dp EXPORTING parent = container_dp.

  IF wa_emp-empid = '111111'.
    v_name = 'ZNIRAV_PATEL'.
  ENDIF.

  CALL METHOD cl_ssf_xsf_utilities=>get_bds_graphic_as_bmp
    EXPORTING
      p_object = 'GRAPHICS'
      p_name   = v_name
      p_id     = 'BMAP'
      p_btype  = 'BCOL'
    RECEIVING
      p_bmp    = l_graphic_xstr_dp
    EXCEPTIONS
      OTHERS   = 3.
  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  graphic_size_dp = xstrlen( l_graphic_xstr_dp ).
  l_graphic_conv_dp = graphic_size_dp.
  l_graphic_offs_dp = 0.

  WHILE l_graphic_conv_dp > 255.
    graphic_table_dp-line = l_graphic_xstr_dp+l_graphic_offs_dp(255).
    APPEND graphic_table_dp.
    l_graphic_offs_dp = l_graphic_offs_dp + 255.
    l_graphic_conv_dp = l_graphic_conv_dp - 255.
  ENDWHILE.
  graphic_table_dp-line = l_graphic_xstr_dp+l_graphic_offs_dp(l_graphic_conv_dp).

  APPEND graphic_table_dp.

  CALL FUNCTION 'DP_CREATE_URL'
    EXPORTING
      type     = 'IMAGE'
      subtype  = 'GIF'
      size     = graphic_size_dp
      lifetime = 'T'
    TABLES
      data     = graphic_table_dp
    CHANGING
      url      = url_dp.
  CALL METHOD picture_dp->load_picture_from_url EXPORTING url = url_dp.
  CALL METHOD picture_dp->set_display_mode
    EXPORTING
      display_mode = picture_dp->display_mode_fit_center.

  CALL METHOD cl_gui_cfw=>flush.
ENDMODULE.
