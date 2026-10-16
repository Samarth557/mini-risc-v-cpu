##############################################################################################################
#####  
#####                                       Pegasus LVS COMPARISON
#####  
#####  Version                       :   25.13-s012
#####  NVN Run Start                 :   Sun Oct 11 23:56:13 2026
#####  Comparison Report File        :   chip_top.rep.cls
#####  Top Cell                      :   chip_top  <vs>  chip_top
#####  
#####                                :      @     @
#####                                :       @   @ 
#####                                :        @ @  
#####  Run Result                    :     MISMATCH
#####                                :        @ @  
#####                                :       @   @ 
#####                                :      @     @
#####  
#####  Run Summary                   :   [ERROR] Connectivity Mismatches
#####                                :   [INFO]  Some Sections Have Been Truncated
#####                                :   [INFO]  Unconnected Corresponding Top Cell Pin(s) Exists
#####  
#####  Layout Design                 :   check_drc_lib chip_top layout
#####  Schematic File                :   /nethome/sgupta943/physical-design-onboarding-F26/signoff/../resources/cadence_sky130/sky130_scl_9T_0.1.2/sky130_scl_9T_LP/cdl/sky130_scl_9T_LP.cdl (cdl)
#####  Schematic File                :   /nethome/sgupta943/physical-design-onboarding-F26/signoff/../resources/cadence_sky130/sky130_scl_9T_0.1.2/sky130_scl_9T_HS/cdl/sky130_scl_9T_HS.cdl (cdl)
#####  Schematic File                :   /nethome/sgupta943/physical-design-onboarding-F26/signoff/../resources/cadence_sky130/sky130_scl_9T_0.1.2/sky130_scl_9T_tech/cdl/sky130_scl_9T_phyCells.cdl (cdl)
#####  Schematic File                :   /nethome/sgupta943/physical-design-onboarding-F26/signoff/../resources/cadence_sky130/sky130_scl_9T_0.1.2/sky130_scl_9T/cdl/sky130_scl_9T.cdl (cdl)
#####  Schematic File                :   /nethome/sgupta943/physical-design-onboarding-F26/signoff/CF_SRAM_1024x32.cdl (cdl)
#####  Schematic File                :   /nethome/sgupta943/physical-design-onboarding-F26/signoff/../outputs/apr/DBS/chip_top.phy.v (verilog)
#####  Rules File                    :   /nethome/sgupta943/physical-design-onboarding-F26/signoff/../resources/cadence_sky130/sky130_release_0.1.0/Sky130_LVS/sky130.lvs.v0.0_1.1.pvl
#####  
#####  NVN CPU Time                  :   0h 0m 13s - (13s)               
#####  NVN Exec Time                 :   0h 0m 14s - (14s)               
#####  NVN Peak Memory Usage         :   0.00MB
#####  
##############################################################################################################


##############################################################################################################
#
#                                            CELL MATCH STATISTICS                                            
#
##############################################################################################################

Cell Statistic Descriptions                  | Count
---------------------------------------------+----------
Cells matched                                |         0
Cells expanded                               |         0
Cells not run                                |         0
Cells which mismatch                         |         1
---------------------------------------------+----------
Total                                        |         1


Cell Statistic Detail                        | Count
---------------------------------------------+----------
Cells with parameter mismatches              |         0
Cells with mismatched instance subtypes      |         0
Cells that have been blackboxed              |         0


##############################################################################################################
#
#                                             CELL MATCH SUMMARY                                              
#
##############################################################################################################

             |     Initial Pins     |     Compare Pins     |              | 
Cell         |   lay    :    sch    |   lay    :    sch    | Status       | Detail
-------------+----------+-----------+----------+-----------+--------------+--------------
chip_top     |       87 :        87 |       87 :        87 | mismatch     | truncated


##############################################################################################################
#
#                                                  LVS RULES                                                  
#
##############################################################################################################

Command Line LVS Rule Values
----------------------------

    layout_primary                          chip_top {-top_cell chip_top}
    schematic_primary                       chip_top {-source_top_cell chip_top}

LVS Rules Given in the Rules File
---------------------------------

    lvs_abort                               -softchk                               no  
    lvs_abort                               -supply_error                          no  
    layout_path                             /nethome/sgupta943/physical-design-onboarding-F26/signoff/runs/chip_top.gds.gz
    layout_format                           gdsii
    layout_primary                          TOPCELL
    schematic_path                          /nethome/sgupta943/physical-design-onboarding-F26/signoff/../resources/cadence_sky130/sky130_scl_9T_0.1.2/sky130_scl_9T_LP/cdl/sky130_scl_9T_LP.cdl
                                            cdl
    schematic_path                          /nethome/sgupta943/physical-design-onboarding-F26/signoff/../resources/cadence_sky130/sky130_scl_9T_0.1.2/sky130_scl_9T_HS/cdl/sky130_scl_9T_HS.cdl
                                            cdl
    schematic_path                          /nethome/sgupta943/physical-design-onboarding-F26/signoff/../resources/cadence_sky130/sky130_scl_9T_0.1.2/sky130_scl_9T_tech/cdl/sky130_scl_9T_phyCells.cdl
                                            cdl
    schematic_path                          /nethome/sgupta943/physical-design-onboarding-F26/signoff/../resources/cadence_sky130/sky130_scl_9T_0.1.2/sky130_scl_9T/cdl/sky130_scl_9T.cdl
                                            cdl
    schematic_path                          /nethome/sgupta943/physical-design-onboarding-F26/signoff/CF_SRAM_1024x32.cdl
                                            cdl
    schematic_path                          /nethome/sgupta943/physical-design-onboarding-F26/signoff/../outputs/apr/DBS/chip_top.phy.v
                                            verilog
    lvs_delete_cell_pin                     cap_vpp_02p4x04p6_m1m2_noshield b -source
    lvs_delete_cell_pin                     cap_vpp_02p7x06p1_m1m2m3m4_shieldl1_fingercap b -source
    lvs_delete_cell_pin                     cap_vpp_02p7x11p1_m1m2m3m4_shieldl1_fingercap b -source
    lvs_delete_cell_pin                     cap_vpp_02p7x21p1_m1m2m3m4_shieldl1_fingercap b -source
    lvs_delete_cell_pin                     cap_vpp_02p7x41p1_m1m2m3m4_shieldl1_fingercap b -source
    lvs_delete_cell_pin                     cap_vpp_02p9x06p1_m1m2m3m4_shieldl1_fingercap2 b -source
    lvs_delete_cell_pin                     cap_vpp_04p4x04p6_l1m1m2_noshield b -source
    lvs_delete_cell_pin                     cap_vpp_04p4x04p6_l1m1m2_shieldpo_floatm3 b -source
    lvs_delete_cell_pin                     cap_vpp_04p4x04p6_m1m2m3_shieldl1 b -source
    lvs_delete_cell_pin                     cap_vpp_04p4x04p6_m1m2m3_shieldl1m5_floatm4 b -source
    lvs_delete_cell_pin                     cap_vpp_04p4x04p6_m1m2_noshield b -source
    lvs_delete_cell_pin                     cap_vpp_04p4x04p6_m1m2_noshield_o2 b -source
    lvs_delete_cell_pin                     cap_vpp_04p4x04p6_m1m2_shieldl1 b -source
    lvs_delete_cell_pin                     cap_vpp_05p9x05p9_m1m2m3m4_shieldl1_wafflecap b -source
    lvs_delete_cell_pin                     cap_vpp_06p8x06p1_l1m1m2m3_shieldpom4 b -source
    lvs_delete_cell_pin                     cap_vpp_06p8x06p1_m1m2m3_shieldl1m4 b -source
    lvs_delete_cell_pin                     cap_vpp_08p6x07p8_l1m1m2_noshield b -source
    lvs_delete_cell_pin                     cap_vpp_08p6x07p8_l1m1m2_shieldpo_floatm3 b -source
    lvs_delete_cell_pin                     cap_vpp_08p6x07p8_m1m2m3_shieldl1 b -source
    lvs_delete_cell_pin                     cap_vpp_08p6x07p8_m1m2m3_shieldl1m5_floatm4 b -source
    lvs_delete_cell_pin                     cap_vpp_08p6x07p8_m1m2_noshield b -source
    lvs_delete_cell_pin                     cap_vpp_08p6x07p8_m1m2_shieldl1 b -source
    lvs_delete_cell_pin                     cap_vpp_11p3x11p3_m1m2m3m4_shieldl1_wafflecap b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_l1m1m2m3m4_shieldm5 b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_l1m1m2m3m4_shieldpom5 b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_l1m1m2m3_shieldm4 b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_l1m1m2m3_shieldpom4 b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_l1m1m2_noshield b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_l1m1m2_shieldpom3 b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_m1m2m3m4_shieldl1m5 b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_m1m2m3m4_shieldm5 b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_m1m2m3_shieldl1 b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_m1m2m3_shieldl1m5_floatm4 b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_m1m2_noshield b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_m1m2_shieldl1 b -source
    lvs_delete_cell_pin                     cap_vpp_11p5x11p7_m1m4_noshield b -source
    lvs_delete_cell_pin                     cap_vpp_04p4x04p6_l1m1m2_noshield top -source
    lvs_black_box                           cap_vpp_02p4x04p6_m1m2_noshield -black
    lvs_black_box                           cap_vpp_02p7x06p1_m1m2m3m4_shieldl1_fingercap -black
    lvs_black_box                           cap_vpp_02p7x11p1_m1m2m3m4_shieldl1_fingercap -black
    lvs_black_box                           cap_vpp_02p7x21p1_m1m2m3m4_shieldl1_fingercap -black
    lvs_black_box                           cap_vpp_02p7x41p1_m1m2m3m4_shieldl1_fingercap -black
    lvs_black_box                           cap_vpp_02p9x06p1_m1m2m3m4_shieldl1_fingercap2 -black
    lvs_black_box                           cap_vpp_04p4x04p6_l1m1m2_noshield -black
    lvs_black_box                           cap_vpp_04p4x04p6_l1m1m2_shieldpo_floatm3 -black
    lvs_black_box                           cap_vpp_04p4x04p6_m1m2m3_shieldl1 -black
    lvs_black_box                           cap_vpp_04p4x04p6_m1m2m3_shieldl1m5_floatm4 -black
    lvs_black_box                           cap_vpp_04p4x04p6_m1m2_noshield -black
    lvs_black_box                           cap_vpp_04p4x04p6_m1m2_noshield_o2 -black
    lvs_black_box                           cap_vpp_04p4x04p6_m1m2_shieldl1 -black
    lvs_black_box                           cap_vpp_05p9x05p9_m1m2m3m4_shieldl1_wafflecap -black
    lvs_black_box                           cap_vpp_06p8x06p1_l1m1m2m3_shieldpom4 -black
    lvs_black_box                           cap_vpp_06p8x06p1_m1m2m3_shieldl1m4 -black
    lvs_black_box                           cap_vpp_08p6x07p8_l1m1m2_noshield -black
    lvs_black_box                           cap_vpp_08p6x07p8_l1m1m2_shieldpo_floatm3 -black
    lvs_black_box                           cap_vpp_08p6x07p8_m1m2m3_shieldl1 -black
    lvs_black_box                           cap_vpp_08p6x07p8_m1m2m3_shieldl1m5_floatm4 -black
    lvs_black_box                           cap_vpp_08p6x07p8_m1m2_noshield -black
    lvs_black_box                           cap_vpp_08p6x07p8_m1m2_shieldl1 -black
    lvs_black_box                           cap_vpp_11p3x11p3_m1m2m3m4_shieldl1_wafflecap -black
    lvs_black_box                           cap_vpp_11p5x11p7_l1m1m2m3m4_shieldm5 -black
    lvs_black_box                           cap_vpp_11p5x11p7_l1m1m2m3m4_shieldpom5 -black
    lvs_black_box                           cap_vpp_11p5x11p7_l1m1m2m3_shieldm4 -black
    lvs_black_box                           cap_vpp_11p5x11p7_l1m1m2m3_shieldpom4 -black
    lvs_black_box                           cap_vpp_11p5x11p7_l1m1m2_noshield -black
    lvs_black_box                           cap_vpp_11p5x11p7_l1m1m2_shieldpom3 -black
    lvs_black_box                           cap_vpp_11p5x11p7_m1m2m3m4_shieldl1m5 -black
    lvs_black_box                           cap_vpp_11p5x11p7_m1m2m3m4_shieldm5 -black
    lvs_black_box                           cap_vpp_11p5x11p7_m1m2m3_shieldl1 -black
    lvs_black_box                           cap_vpp_11p5x11p7_m1m2m3_shieldl1m5_floatm4 -black
    lvs_black_box                           cap_vpp_11p5x11p7_m1m2_noshield -black
    lvs_black_box                           cap_vpp_11p5x11p7_m1m2_shieldl1 -black
    lvs_black_box                           cap_vpp_11p5x11p7_m1m4_noshield -black
                                             
    lvs_cdn_flow_options                    -cdl_use_scale
    lvs_ignore_ports                        no  
    lvs_find_shorts                         no  
    lvs_break_ambig_max                     32
    lvs_reduce_split_gates                  no  
    lvs_recognize_gates                     -none
    lvs_reduce                              no  -series_mos
    lvs_reduce                              yes -parallel_mos
    lvs_reduce_device                       MN ( nfet_20v0 ) -parallel ...
    lvs_reduce_device                       MN ( nfet_20v0_zvt ) -parallel ...
    lvs_reduce_device                       MP ( pfet_20v0 ) -parallel ...
    lvs_reduce_device                       Q -parallel yes ...
    lvs_expand_cell_on_error                no  
    lvs_check_property                      D ( diode_pd2nw_05v5 ) a a -tolerance 1
    lvs_check_property                      D ( diode_pd2nw_05v5 ) p p -tolerance 1
    lvs_check_property                      D ( diode_pw2nd_05v5 ) a a -tolerance 1
    lvs_check_property                      D ( diode_pw2nd_05v5 ) p p -tolerance 1
    lvs_check_property                      D ( diode_pd2nw_05v5_hvt ) a a -tolerance 1
    lvs_check_property                      D ( diode_pd2nw_05v5_hvt ) p p -tolerance 1
    lvs_check_property                      D ( diode_pd2nw_05v5_lvt ) a a -tolerance 1
    lvs_check_property                      D ( diode_pd2nw_05v5_lvt ) p p -tolerance 1
    lvs_check_property                      D ( diode_pd2nw_11v0 ) a a -tolerance 1
    lvs_check_property                      D ( diode_pd2nw_11v0 ) p p -tolerance 1
    lvs_check_property                      D ( diode_pw2nd_05v5_lvt ) a a -tolerance 1
    lvs_check_property                      D ( diode_pw2nd_05v5_lvt ) p p -tolerance 1
    lvs_check_property                      D ( diode_pw2nd_05v5_nvt ) a a -tolerance 1
    lvs_check_property                      D ( diode_pw2nd_05v5_nvt ) p p -tolerance 1
    lvs_check_property                      D ( diode_pw2nd_11v0 ) a a -tolerance 1
    lvs_check_property                      D ( diode_pw2nd_11v0 ) p p -tolerance 1
    lvs_check_property                      MN ( nfet_20v0 ) w w
    lvs_check_property                      MN ( nfet_20v0 ) l l
    lvs_check_property                      MN ( nfet_20v0_zvt ) w w
    lvs_check_property                      MN ( nfet_20v0_zvt ) l l
    lvs_check_property                      MP ( pfet_20v0 ) w w
    lvs_check_property                      MP ( pfet_20v0 ) l l
    lvs_check_property                      Q EA EA -tolerance 0
    lvs_check_property                      Q M M -tolerance 0
    lvs_check_property                      MP L l
    lvs_check_property                      MP W w
    lvs_check_property                      MN L l
    lvs_check_property                      MN W w
    lvs_check_property                      R W W
    lvs_check_property                      R L L
    lvs_check_property                      C L L
    lvs_check_property                      C W W
    lvs_report_file                         chip_top.rep
    lvs_report_max                          50 -mismatched_net_limit 100 
    lvs_short_equivalent_nodes              yes
    virtual_connect                         no  -colon
    virtual_connect                         yes -semicolon_as_colon
    virtual_connect                         no  -report
    virtual_connect                         -depth primary
    text_depth                              -primary

Default LVS Rule Values
-----------------------

    lvs_abort                               -check_device_for_property_rule no
    lvs_abort                               -missing_hcell no
    lvs_abort                               -erc_error yes
    lvs_abort                               -inconsistent_reduction yes
    layout_case_sensitive                   no
    // layout_cpf_file                       
    // schematic_cpf_file                    
    schematic_case_sensitive                no
    schematic_format                        cdl
    // hcell_file                            
    // hcell                                 
    // lvs_exclude_hcell                     
    // lvs_gen_hcells                        
    // lvs_delete_cell                       
    lvs_push_devices                        yes
    lvs_push_devices_properties             no
    lvs_netlist                             yes -substrate_comment
    lvs_netlist                             yes -box_contents
    lvs_netlist                             yes -unnamed_box_pins
    lvs_netlist                             no -allow_inconsistent_model
    lvs_netlist                             yes -properties_comment
    // lvs_write_netlist                     
    // lvs_write_netlist_reduced             
    // lvs_interposer                        
    lvs_spice                               yes -allow_floating_pins
    lvs_spice                               yes -allow_duplicate_subcircuit_names
    lvs_spice                               no  -conditional_ldd
    lvs_spice                               no  -prefer_pins
    lvs_spice                               no  -override_globals
    lvs_spice                               no  -redefine_param
    lvs_spice                               no  -replicate_devices
    lvs_spice                               no  -replicate_devices_enhanced
    lvs_spice                               yes -slash_is_space
    lvs_spice                               yes -keep_back_slash
    lvs_spice                               no  -allow_unquoted_strings
    lvs_spice                               no  -allow_inline_parameters
    lvs_spice                               no  -calculate_mos_area
    lvs_spice                               no  -strict_wl
    lvs_spice                               no  -cull_primitive_subcircuits
    lvs_spice                               no  -ignore_option_scale
    lvs_spice                               no  -show_neg_param_warning
    lvs_spice                               no  -scale_x_parameters
    lvs_spice                               yes -strict_subckts_order
    lvs_spice                               no  -ignore_higher_include_for_inst_master
    lvs_spice                               no  -ignore_black_box_connect
    lvs_spice                               no  -use_last_subckt_def
    lvs_spice                               no  -compare_empty_cell
    // lvs_spice_option                      
    lvs_reverse_wl                          no
    // lvs_spice_multiplier_name             
                                             
    lvs_compare_case                        no
    lvs_cname                               no  -cell
    lvs_cname                               yes -pin
    lvs_cname                               yes -net
    lvs_cname                               no  -instance
    lvs_non_user_name                       -port "^[0-9]+$"
    lvs_non_user_name                       -net  "^[0-9]+$"
    // lvs_non_user_name                    -instance 
    lvs_out_of_range_exclude_zero           no
    // lvs_group_models                      
    lvs_strict_subtypes                     no
    lvs_exact_subtypes                      no
    lvs_preserve_box_ports                  no
    // lvs_cpoint                            
    // lvs_power_name                        
    // lvs_ground_name                       
    // lvs_cell_list                         
    // lvs_device_type                       
    lvs_auto_pin_swap                       yes -swap_threshold 4000000
    lvs_swap_non_cpoint_pins                yes
    // lvs_swap_pins                         
    lvs_all_cap_pins_swappable              no
    lvs_builtin_device_pin_swap             yes
    // lvs_join_nets                         
    lvs_compare_port_names                  no
    lvs_global_sigs_are_ports               yes
    lvs_discard_pins                        no
    lvs_filter                              no  -bipolar
    lvs_filter                              no  -capacitors
    lvs_filter                              no  -diodes
    lvs_filter                              no  -mos
    lvs_filter                              no  -resistors
    // lvs_filter_option                     
    // lvs_filter_device                     
    // lvs_filter_device_keep_net            
    lvs_reduction_priority                  -parallel
    lvs_derive_logic                        yes -sram
    lvs_derive_logic                        no  -dram
    lvs_derive_logic                        no  -rom
    // lvs_recognize_gates_tolerance         
    lvs_reduce                              yes -parallel_bipolar
    lvs_reduce                              yes -parallel_caps
    lvs_reduce                              yes -series_caps
    lvs_reduce                              yes -parallel_diodes
    lvs_reduce                              no  -series_diodes
    lvs_reduce                              yes -parallel_resistors
    lvs_reduce                              yes -series_resistors
    // lvs_reduce_do_not_merge               
    lvs_expand_on_device_climbing           no
    lvs_expand_unbalanced_cells             yes
    // lvs_check_all_properties_by_name      
    // lvs_property_map                      
    // lvs_transfer_property                 
    lvs_warn_max                            50
    lvs_inconsistent_reduction_threshold    1000000
    // lvs_report_opt                        
    lvs_report_units                        yes
    lvs_keep_data                           no
    lvs_keep_source_cells                   no
    lvs_create_match_db                     no
    // lvs_map_device                        
    unit                                    -length u
    unit                                    -resistance ohm
    unit                                    -capacitance pf
    lvs_verilog_bus_map_by_position         no
    lvs_verilog_keep_backslash              no
    lvs_verilog_detect_buses                no
    lvs_do_not_normalize                    no
    // lvs_generic_device                    
    input_scale                             1000
    virtual_connect                         no  -colon
    virtual_connect                         yes -semicolon_as_colon
    // virtual_connect                      -name 
    virtual_connect                         no -report
    virtual_connect                         no -incremental
    lvs_preserve_parameterized_cells        no
    lvs_check_color                         no
    // lvs_schematic_color_path              
    // lvs_assign_conflict_layer             
    // lvs_conflict_layer_check             
    lvs_check_color_label                   no
    // lvs_preserve_cells                    
    port                                    -depth -primary
    lvs_high_shorts_max                     10000000

Effective LVS Rule Values
-------------------------

    lvs_swap_non_cpoint_pins                yes -unbound_pin_threshold 10000
    layout_primary                          chip_top
    lvs_recognize_gates                     -none
    virtual_connect                         no  -report


##############################################################################################################
#
#                                               CELL COMPARISON                                               
#
##############################################################################################################

                              ##################################################
                              #                                                #
                              #       ------->>> $ MISMATCH $ <<<-------       #
                              #                                                #
                              #            chip_top  <vs>  chip_top            #
                              #                                                #
                              #            CONNECTIVITY MISMATCHES             #
                              #                                                #
                              ##################################################
                              # * Some sections truncated                      #
                              ##################################################

+===[chip_top]================================================================================================
|                                                 STATISTICS                                                  
+=============================================================================================================


                                    |         Original         |         Reduced          |     Unmatched     
Cell                                |     lay     :    sch     |     lay     :    sch     |   lay   :   sch
------------------------------------+-------------+------------+-------------+------------+---------+---------
MP [4 pins]                         |             :            |             :            |         :         
 MP(PFET_01V8)                      |     *52,115 :     30,903 |      30,903 :     30,903 |       0 :        0
MN [4 pins]                         |             :            |             :            |         :         
 MN(NFET_01V8_LVT)                  |     *39,458 :     22,770 |      22,770 :     22,770 |       0 :        0
 MN(NFET_01V8)                      |     *12,317 :      8,133 |       8,133 :      8,133 |       0 :        0
(-, CF_SRAM_1024x32 [125 pins])     |             :            |             :            |         :         
 (-, CF_SRAM_1024x32())             |          *0 :          2 |          *0 :          2 |      *0 :        2
------------------------------------+-------------+------------+-------------+------------+---------+---------
Total                               |     103,890 :     61,808 |      61,806 :     61,808 |       0 :        2
====================================+=============+============+=============+============+=========+=========
Pins                                |             :            |          87 :         87 |       0 :        0
Nets                                |             :            |     *32,027 :     32,062 |      *0 :       33
====================================+=============+============+=============+============+=========+=========

+===[chip_top]================================================================================================
|                                      DEVICES REMOVED DURING REDUCTION                                       
+=============================================================================================================


                       |       Parallel       |      Series       |     Deleted Nets     
Cell                   |    lay     :   sch   |   lay   :   sch   |    lay    :   sch
-----------------------+------------+---------+---------+---------+-----------+----------
MP [4 pins]            |            :         |         :         |           :          
 MP(PFET_01V8)         |     21,212 :       - |       - :       - |         0 :         0
MN [4 pins]            |            :         |         :         |           :          
 MN(NFET_01V8_LVT)     |     16,688 :       - |       - :       - |         0 :         0
 MN(NFET_01V8)         |      4,184 :       - |       - :       - |         0 :         0
-----------------------+------------+---------+---------+---------+-----------+----------

+===[chip_top]================================================================================================
|                                           INITIAL CORRESPONDENCES                                           
+====================================================================================================truncated

Type | Name
-----+--------------------------------------------------------------------------------------------------------
Pin  | addr_i[0]<unconnected> addr_i[10] addr_i[11] addr_i[12] addr_i[13] addr_i[1]<unconnected> addr_i[2]
     | addr_i[3] addr_i[4] addr_i[5] addr_i[6] addr_i[7] addr_i[8] addr_i[9] clk_i cpu_halted_o en_cpu_i
     | halt_cpu_i r_en_i rdata_o[0] rdata_o[10] rdata_o[11] rdata_o[12] rdata_o[13] rdata_o[14] rdata_o[15]
     | rdata_o[16] rdata_o[17] rdata_o[18] rdata_o[19] rdata_o[1] rdata_o[20] rdata_o[21] rdata_o[22]
     | rdata_o[23] rdata_o[24] rdata_o[25] rdata_o[26] rdata_o[27] rdata_o[28] rdata_o[29] rdata_o[2]
     | rdata_o[30] rdata_o[31] rdata_o[3] rdata_o[4] rdata_o[5] rdata_o[6] rdata_o[7] rdata_o[8]


++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
++++++ Section truncated to 50 issues, adjust this using the lvs_report_max rule +++++++++++++++++++++++++++++
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


+===[chip_top]================================================================================================
|                                              SHORTS AND OPENS                                               
+=============================================================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 6023      | cpu/u_reg_file/clk_gate_registers_reg_6_/latch/TE
======================+============================================================(sao 1)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_8_/TIEHILO__LTIELO_NET
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 6018      | cpu/u_reg_file/clk_gate_registers_reg_15_/latch/TE
======================+============================================================(sao 2)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_19_/TIEHILO__LTIELO_NET
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 6005      | cpu/u_reg_file/clk_gate_registers_reg_5_/latch/TE
======================+============================================================(sao 3)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_29_/TIEHILO__LTIELO_NET
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 6028      | cpu/u_reg_file/clk_gate_registers_reg_4_/latch/TE
======================+============================================================(sao 4)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_25_/TIEHILO__LTIELO_NET
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5900      | cpu/u_reg_file/clk_gate_registers_reg_14_/latch/TE
======================+============================================================(sao 5)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_23_/TIEHILO__LTIELO_NET
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 6020      | data_memory/TIEHILO__LTIELO_NET
======================+============================================================(sao 6)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_11_/latch/TE
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5893      | cpu/u_reg_file/clk_gate_registers_reg_12_/latch/TE
======================+============================================================(sao 7)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_24_/TIEHILO__LTIELO_NET
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5890      | cpu/u_reg_file/clk_gate_registers_reg_9_/TIEHILO__LTIELO_NET
======================+============================================================(sao 8)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_9_/latch/TE
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5886      | cpu/u_reg_file/clk_gate_registers_reg_13_/latch/TE
======================+============================================================(sao 9)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_28_/TIEHILO__LTIELO_NET
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 6007      | cpu/u_reg_file/clk_gate_registers_reg_2_/latch/TE
======================+===========================================================(sao 10)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_4_/TIEHILO__LTIELO_NET
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5903      | cpu/u_reg_file/clk_gate_registers_reg_3_/latch/TE
======================+===========================================================(sao 11)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_14_/TIEHILO__LTIELO_NET
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5896      | instruction_memory/TIEHILO__LTIELO_NET
======================+===========================================================(sao 12)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_1_/latch/TE
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5754      | cpu/u_reg_file/clk_gate_registers_reg_5_/TIEHILO__LTIELO_NET
======================+===========================================================(sao 13)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_7_/latch/TE
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5749      | cpu/u_reg_file/clk_gate_registers_reg_17_/latch/TE
======================+===========================================================(sao 14)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_18_/TIEHILO__LTIELO_NET
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5751      | cpu/u_reg_file/clk_gate_registers_reg_6_/TIEHILO__LTIELO_NET
======================+===========================================================(sao 15)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_30_/latch/TE
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5746      | cpu/u_reg_file/clk_gate_registers_reg_15_/TIEHILO__LTIELO_NET
======================+===========================================================(sao 16)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_21_/latch/TE
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5737      | cpu/u_reg_file/clk_gate_registers_reg_1_/TIEHILO__LTIELO_NET
======================+===========================================================(sao 17)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_10_/latch/TE
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5600      | cpu/u_reg_file/clk_gate_registers_reg_2_/TIEHILO__LTIELO_NET
======================+===========================================================(sao 18)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_8_/latch/TE
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5598      | cpu/u_reg_file/clk_gate_registers_reg_19_/latch/TE
======================+===========================================================(sao 19)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_20_/TIEHILO__LTIELO_NET
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5596      | cpu/u_reg_file/clk_gate_registers_reg_20_/latch/TE
======================+===========================================================(sao 20)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_21_/TIEHILO__LTIELO_NET
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5586      | cpu/u_reg_file/clk_gate_registers_reg_7_/TIEHILO__LTIELO_NET
======================+===========================================================(sao 21)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_27_/latch/TE
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5743      | cpu/u_reg_file/clk_gate_registers_reg_23_/latch/TE
======================+===========================================================(sao 22)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_31_/TIEHILO__LTIELO_NET
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5592      | cpu/u_reg_file/clk_gate_registers_reg_3_/TIEHILO__LTIELO_NET
======================+===========================================================(sao 23)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_29_/latch/TE
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5581      | cpu/u_reg_file/clk_gate_registers_reg_16_/TIEHILO__LTIELO_NET
======================+===========================================================(sao 24)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_26_/latch/TE
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5578      | cpu/u_reg_file/clk_gate_registers_reg_22_/TIEHILO__LTIELO_NET
======================+===========================================================(sao 25)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_31_/latch/TE
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5575      | cpu/u_fetch/clk_gate_pc_o_reg/TIEHILO__LTIELO_NET
======================+===========================================================(sao 26)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_28_/latch/TE
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5448      | cpu/u_reg_file/clk_gate_registers_reg_22_/latch/TE
======================+===========================================================(sao 27)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_26_/TIEHILO__LTIELO_NET
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5434      | cpu/u_reg_file/clk_gate_registers_reg_25_/latch/TE
======================+===========================================================(sao 28)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_27_/TIEHILO__LTIELO_NET
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5432      | cpu/u_reg_file/clk_gate_registers_reg_12_/TIEHILO__LTIELO_NET
======================+===========================================================(sao 29)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_16_/latch/TE
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5427      | cpu/u_reg_file/clk_gate_registers_reg_13_/TIEHILO__LTIELO_NET
======================+===========================================================(sao 30)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_18_/latch/TE
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 5426      | cpu/u_reg_file/clk_gate_registers_reg_24_/latch/TE
======================+===========================================================(sao 31)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_30_/TIEHILO__LTIELO_NET
======================+===================================================================
                                                                                          
                                                                                          
                      | Schematic Net:
Layout Net: 870       | cpu/u_fetch/clk_gate_pc_o_reg/latch/TE
======================+===========================================================(sao 32)
        SHORT         | Schematic Net:
                      | cpu/u_reg_file/clk_gate_registers_reg_17_/TIEHILO__LTIELO_NET
======================+===================================================================
                                                                                          
                                                                                          
Layout Net: 2         | Schematic Net: VDD
======================+===========================================================(sao 33)
        SHORT         | Schematic Net:
                      | data_memory/TIEHILO__LTIEHI_NET
======================+===================================================================


+===[chip_top]================================================================================================
|                                            MISMATCHED INSTANCES                                             
+=============================================================================================================
                                                                                     
                                                                                     
Layout Inst : ** missing inst **     | Schematic Inst : data_memory/u_sram
Layout Model:                        | Schematic Model: CF_SRAM_1024x32
=====================================+=========================================(mi 1)
                                                                                     
                                                                                     
Layout Inst : ** missing inst **     | Schematic Inst : instruction_memory/u_sram
Layout Model:                        | Schematic Model: CF_SRAM_1024x32
=====================================+=========================================(mi 2)


##############################################################################################################
#
#                                                END OF REPORT                                                
#
##############################################################################################################

