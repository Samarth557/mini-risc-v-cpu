if {![namespace exists ::IMEX]} { namespace eval ::IMEX {} }
set ::IMEX::dataVar [file dirname [file normalize [info script]]]
set ::IMEX::libVar ${::IMEX::dataVar}/libs

create_library_set -name typical_libs\
   -timing\
    [list ${::IMEX::libVar}/mmmc/sky130_tt_1.8_25_nldm.lib\
    ${::IMEX::libVar}/mmmc/sky130_scl_9T_phyCells.lib\
    ${::IMEX::libVar}/mmmc/sky130_tt_1.8_25_nldm.1.lib\
    ${::IMEX::libVar}/mmmc/CF_SRAM_1024x32_tt_180V_100C.lib]
create_op_cond -name sky130_typical_op -library_file ${::IMEX::libVar}/mmmc/sky130_tt_1.8_25_nldm.lib -P 1 -V 1.8 -T 25
create_rc_corner -name typical_rc\
   -preRoute_res 1\
   -postRoute_res 1\
   -preRoute_cap 1\
   -postRoute_cap 1\
   -postRoute_xcap 1\
   -preRoute_clkres 0\
   -preRoute_clkcap 0\
   -T 25\
   -qx_tech_file ${::IMEX::libVar}/mmmc/typical_rc/qrcTechFile
create_delay_corner -name typical_delay_corner\
   -library_set typical_libs\
   -opcond sky130_typical_op\
   -rc_corner typical_rc
create_constraint_mode -name default\
   -sdc_files\
    [list ${::IMEX::dataVar}/mmmc/modes/default/default.sdc]
create_analysis_view -name typical_analysis_view -constraint_mode default -delay_corner typical_delay_corner -latency_file ${::IMEX::dataVar}/mmmc/views/typical_analysis_view/latency.sdc
set_analysis_view -setup [list typical_analysis_view] -hold [list typical_analysis_view]
