#######################################################
#                                                     
#  Innovus Command Logging File                     
#  Created on Sun Oct 11 20:20:22 2026                
#                                                     
#######################################################

#@(#)CDS: Innovus v25.11-s102_1 (64bit) 08/27/2025 13:03 (Linux 4.18.0-305.el8.x86_64)
#@(#)CDS: NanoRoute 25.11-s102_1 NR250730-0928/25_11-UB (database version 18.20.674) {superthreading v2.20}
#@(#)CDS: AAE 25.11-s028 (64bit) 08/27/2025 (Linux 4.18.0-305.el8.x86_64)
#@(#)CDS: CTE 25.11-s034_1 () Aug 18 2025 08:55:47 ( )
#@(#)CDS: SYNTECH 25.11-s013_1 () Jul 30 2025 05:18:51 ( )
#@(#)CDS: CPE v25.11-s029
#@(#)CDS: IQuantus/TQuantus 24.1.0-s290 (64bit) Sun Jul 20 21:40:56 PDT 2025 (Linux 4.18.0-305.el8.x86_64)

set_global _enable_mmmc_by_default_flow      $CTE::mmmc_default
suppressMessage ENCEXT-2799
getVersion
redirect -tee /nethome/sgupta943/physical-design-onboarding-F26/outputs/apr/LOG/step_init_apr.log {source /nethome/sgupta943/physical-design-onboarding-F26/scripts/apr/steps/step_init_apr.tcl}
checkTimingLibrary
all_setup_analysis_views
all_hold_analysis_views
getGenerateViaMode -auto -quiet
report_message -end_cmd
setAnalysisMode -analysisType onChipVariation
redirect -tee /nethome/sgupta943/physical-design-onboarding-F26/outputs/apr/LOG/step_floorplan.log {source /nethome/sgupta943/physical-design-onboarding-F26/scripts/apr/steps/step_floorplan.tcl}
redirect -tee /nethome/sgupta943/physical-design-onboarding-F26/outputs/apr/LOG/step_place_std_cells.log {source /nethome/sgupta943/physical-design-onboarding-F26/scripts/apr/steps/step_place_std_cells.tcl}
redirect -tee /nethome/sgupta943/physical-design-onboarding-F26/outputs/apr/LOG/step_place_ties.log {source /nethome/sgupta943/physical-design-onboarding-F26/scripts/apr/steps/step_place_ties.tcl}
redirect -tee /nethome/sgupta943/physical-design-onboarding-F26/outputs/apr/LOG/step_pre_cts_opt.log {source /nethome/sgupta943/physical-design-onboarding-F26/scripts/apr/steps/step_pre_cts_opt.tcl}
redirect -tee /nethome/sgupta943/physical-design-onboarding-F26/outputs/apr/LOG/step_cts.log {source /nethome/sgupta943/physical-design-onboarding-F26/scripts/apr/steps/step_cts.tcl}
set_ccopt_property target_max_trans 150ps
set_ccopt_property target_skew 150ps
set_ccopt_property buffer_cells {CLKBUFX2 CLKBUFX4 CLKBUFX8}
set_ccopt_property inverter_cells {CLKINVX1 CLKINVX2 CLKINVX4 CLKINVX8}
set_ccopt_property clock_gating_cells ICGX1
check_design -type timing -out_file /nethome/sgupta943/physical-design-onboarding-F26/outputs/apr/RPT/CTS/chip_top.check_design.timing
check_design -type cts -out_file /nethome/sgupta943/physical-design-onboarding-F26/outputs/apr/RPT/CTS/chip_top.check_design.cts
check_design -type opt -out_file /nethome/sgupta943/physical-design-onboarding-F26/outputs/apr/RPT/CTS/chip_top.check_design.opt
create_ccopt_clock_tree_spec
clock_opt_design -cts -outDir /nethome/sgupta943/physical-design-onboarding-F26/outputs/apr/RPT/CTS/
redirect -tee /nethome/sgupta943/physical-design-onboarding-F26/outputs/apr/LOG/step_post_cts_opt.log {source /nethome/sgupta943/physical-design-onboarding-F26/scripts/apr/steps/step_post_cts_opt.tcl}
redirect -tee /nethome/sgupta943/physical-design-onboarding-F26/outputs/apr/LOG/step_route.log {source /nethome/sgupta943/physical-design-onboarding-F26/scripts/apr/steps/step_route.tcl}
redirect -tee /nethome/sgupta943/physical-design-onboarding-F26/outputs/apr/LOG/step_fill.log {source /nethome/sgupta943/physical-design-onboarding-F26/scripts/apr/steps/step_fill.tcl}
redirect -tee /nethome/sgupta943/physical-design-onboarding-F26/outputs/apr/LOG/step_physical_verify.log {source /nethome/sgupta943/physical-design-onboarding-F26/scripts/apr/steps/step_physical_verify.tcl}
redirect -tee /nethome/sgupta943/physical-design-onboarding-F26/outputs/apr/LOG/step_extract.log {source /nethome/sgupta943/physical-design-onboarding-F26/scripts/apr/steps/step_extract.tcl}
