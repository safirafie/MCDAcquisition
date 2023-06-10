################################################################################
# Vivado tcl script for building RedPitaya FPGA in non-project mode (TCL)
# Comments: You need to check all paths and files
# Usage: vivado -mode batch -source red_pitaya_vivado_project.tcl
################################################################################

# Set paths to source files
# Note: Adjust these paths according to your project structure
set path_ip  ip
set path_sdc sdc
set path_rtl rtl

# Set the target part for the FPGA project
set part xc7z010clg400-1

# Create a new project with the specified part. Use -force to overwrite if the project already exists.
create_project -part $part -force redpitaya ./project

# Create PS BD (Processing System Block Design)
# Source the system_bd.tcl file that presumably creates the block design
# Note: Ensure that the system_bd.tcl file is in the path specified by $path_ip
source $path_ip/system_bd.tcl

# Generate the SDK files from the block design
# Note: Ensure that the system.bd file exists in the project
if {[file exists "./project/redpitaya.srcs/sources_1/bd/system/system.bd"]} {
    generate_target all [get_files system.bd]
} else {
    puts "ERROR: system.bd file not found"
    return
}

# Read RTL design sources, IP database files and constraints
# Add the system_wrapper.v file to the project
# Note: Ensure that the system_wrapper.v file exists in the specified path
if {[file exists "./project/redpitaya.srcs/sources_1/bd/system/hdl/system_wrapper.v"]} {
    read_verilog "./project/redpitaya.srcs/sources_1/bd/system/hdl/system_wrapper.v"
} else {
    puts "ERROR: system_wrapper.v file not found"
    return
}

# Define a list of source files to be added to the project
set rtl_sources [list axi_master.v axi_slave.v axi_wr_fifo.v red_pitaya_ams.v red_pitaya_asg_ch.v red_pitaya_asg.v red_pitaya_dfilt1.v red_pitaya_hk.v red_pitaya_pid_block.v red_pitaya_pid.v red_pitaya_pll.sv red_pitaya_ps.v red_pitaya_pwm.sv red_pitaya_scope.v red_pitaya_top.v ssla.v]

# Add each source file to the project
foreach rtl_file $rtl_sources {
    if {[file exists "$path_rtl/$rtl_file"]} {
        add_files $path_rtl/$rtl_file
    } else {
        puts "ERROR: Source file $rtl_file not found in path $path_rtl"
    }
}

# Add constraints file to the project
if {[file exists "$path_sdc/red_pitaya.xdc"]} {
    add_files -fileset constrs_1 $path_sdc/red_pitaya.xdc
} else {
    puts "ERROR: Constraints file red_pitaya.xdc not found in path $path_sdc"
    return
}

# Force import of the files
import_files -force

# Update the compile order of the source files
update_compile_order -fileset sources_1

# Uncomment the following line to start the Vivado GUI if you're running this script in command line mode
# start_gui
