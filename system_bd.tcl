set design_name system
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { $design_name eq "" } {
   set errMsg "ERROR: Please set the variable <design_name> to a non-empty value."
   set nRet 1
} elseif { $cur_design ne "" } {
   if { $list_cells eq "" || $cur_design eq $design_name } {
      puts "INFO: Constructing design in IPI design <$cur_design>..."
      if { $list_cells eq "" } {
         puts "INFO: Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
         set design_name [get_property NAME $cur_design]
      } else {
         set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
         set nRet 1
      }
   }
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   set errMsg "ERROR: Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2
} else {
   puts "INFO: Currently there is no design <$design_name> in project, so creating one..."
   create_bd_design $design_name
   puts "INFO: Making design <$design_name> as current_bd_design."
   current_bd_design $design_name
}

puts "INFO: Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   puts $errMsg
   return $nRet
}

proc create_root_design { parentCell } {
  set parentCell [expr {$parentCell eq "" ? [get_bd_cells /] : $parentCell}]
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj eq "" } {
     puts "ERROR: Unable to find parent cell <$parentCell>!"
     return
  }

  if { [get_property TYPE $parentObj] ne "hier" } {
     puts "ERROR: Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."
     return
  }
  current_bd_instance $parentObj
}

