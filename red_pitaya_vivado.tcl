################################################################################
# Vivado TCL script for building RedPitaya FPGA in non-project mode.
# 
# Usage:
# vivado -mode tcl -source red_pitaya_vivado.tcl
################################################################################

# Define paths to your source files.
# Note: Adjust these paths according to your project structure.
set path_rtl rtl
set path_ip  ip
set path_sdc sdc

# Define paths for output and SDK files.
set path_out out
set path_sdk sdk

# Create directories for output and SDK files, if they don't already exist.
file mkdir $path_out
file mkdir $path_sdk

# Define the target FPGA part for the project.
set part xc7z010clg400-1

# Set up an in-memory project with the specified part.
create_project -in_memory -part $part

# Create PS BD (Processing System Block Design).
# Source the system_bd.tcl file that presumably creates the block design.
# Note: Ensure that system_bd.tcl exists in the path specified by $path_ip.
if {[file exists "$path_ip/system_bd.tcl"]} {
    source $path_ip/system_bd.tcl
} else {
    puts "ERROR: system_bd.tcl not found in path $path_ip"
    return
}

# Generate SDK files from the block design.
# Write the hardware definition file.
generate_target all [get_files system.bd]
write_hwdef -file $path_sdk/red_pitaya.hwdef

# Read files including RTL design sources, IP database files, and constraints.
# Before reading each file, check if it exists.
# List of source files to be read.
set rtl_sources [list axi_master.v axi_slave.v axi_wr_fifo.v red_pitaya_ams.v red_pitaya_asg_ch.v red_pitaya_asg.v red_pitaya_dfilt1.v red_pitaya_hk.v red_pitaya_pid_block.v red_pitaya_pid.v red_pitaya_pll.sv red_pitaya_ps.v red_pitaya_pwm.sv red_pitaya_scope.v red_pitaya_top.v ssla.v]

# Read each source file if it exists.
foreach rtl_file $rtl_sources {
    if {[file exists "$path_rtl/$rtl_file"]} {
        read_verilog "$path_rtl/$rtl_file"
    } else {
        puts "ERROR: Source file $rtl_file not found in path $path_rtl"
        return
    }
}

# Read the constraints file if it exists.
if {[file exists "$path_sdc/red_pitaya.xdc"]} {
    read_xdc "$path_sdc/red_pitaya.xdc"
} else {
    puts "ERROR: Constraints file red_pitaya.xdc not found in path $path_sdc"
    return
}

# Run synthesis, report utilization and timing estimates, write checkpoint design.
# Synthesis options can be adjusted as necessary.
synth_design -top red_pitaya_top -flatten_hierarchy none -bufg 16 -keep_equivalent_registers
write_checkpoint -force $path_out/post_synth
report_timing_summary -file $path_out/post_synth_timing_summary.rpt
report_power -file $path_out/post_synth_power.rpt

# Run placement and logic optimization, report utilization and timing estimates, write checkpoint design.
opt_design
power_opt_design
place_design
phys_opt_design
write_checkpoint -force $path_out/post_place
report_timing_summary -file $path_out/post_place_timing_summary.rpt

# Run router, report actual utilization and timing, write checkpoint design, run DRC, write Verilog and XDC out.
route_design
write_checkpoint -force $path_out/post_route
report_timing_summary -file $path_out/post_route_timing_summary.rpt
report_timing -file $path_out/post_route_timing.rpt -sort_by group -max_paths 100 -path_type summary
report_clock_utilization -file $path_out/clock_util.rpt
report_utilization -file $path_out/post_route_util.rpt
report_power -file $path_out/post_route_power.rpt
report_drc -file $path_out/post_imp_drc.rpt

# Generate a bitstream.
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
write_bitstream -force $path_out/red_pitaya.bit

# Generate system definition.
write_sysdef -hwdef $path_sdk/red_pitaya.hwdef -bitfile $path_out/red_pitaya.bit -file $path_sdk/red_pitaya.sysdef

# End of the script.
exit
