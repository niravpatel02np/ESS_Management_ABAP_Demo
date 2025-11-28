*&---------------------------------------------------------------------*
*& Include           ZESS_TECH_APP_O01 (Demo)
*&---------------------------------------------------------------------*

MODULE status_0100 OUTPUT.
  SET PF-STATUS 'ZSTATUS_0100'.
  SET TITLEBAR 'ZTITLE_0100'.
ENDMODULE.

MODULE status_0300 OUTPUT.
  SET PF-STATUS 'ZSTATUS_0300'.
  SET TITLEBAR 'ZTITLE_0300'.
ENDMODULE.

MODULE show_emp_details OUTPUT.
  IF ok_code <> 'CANCEL'.
    " Code removed: SELECT personal & official information, domain description fetch
  ENDIF.
ENDMODULE.

MODULE status_0400 OUTPUT.
  SET PF-STATUS 'ZSTATUS_0400'.
  SET TITLEBAR 'ZTITLE_0400'.
ENDMODULE.

MODULE display_approver OUTPUT.
  IF ok_code <> 'CANCEL'.
    " Code removed: fetch approver email
  ENDIF.
ENDMODULE.

MODULE status_0200 OUTPUT.
  SET PF-STATUS 'ZSTATUS_0200'.
  SET TITLEBAR 'ZTITLE_0200'.
ENDMODULE.

MODULE modify_screen_0200 OUTPUT.
  IF wa_emp-zauthorization <> 'Manager'.
    LOOP AT SCREEN.
      IF screen-name = 'BOX2' OR screen-group1 = 'G1'.
        screen-invisible = 1.
        MODIFY SCREEN.
      ENDIF.
    ENDLOOP.
  ENDIF.

  " Code removed: display picture logic & fetch personal/official info
ENDMODULE.

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
      " Do nothing
  ENDCASE.
ENDMODULE.

MODULE status_0450 OUTPUT.
  SET PF-STATUS 'ZSTATUS_0450'.
  SET TITLEBAR 'ZTITLE_0450'.
ENDMODULE.

MODULE tc1_leave_change_tc_attr OUTPUT.
  " Code removed: update lines for table control
ENDMODULE.

MODULE tc1_leave_get_lines OUTPUT.
  g_tc1_leave_lines = sy-loopc.
ENDMODULE.

MODULE show_dp OUTPUT.
  " Code removed: display DP picture logic
ENDMODULE.
