# ==================================================
# RTL DIRECTORY
# ==================================================
set RTL_DIR /home/student/Bhavyabansal/Verilog

# ==================================================
# LIBRARIES
# ==================================================
set_db library [list \
  /mnt/c2s/cadence/Analog_tools/FOUNDRY/scl_pdk/stdlib/fs120/spc/liberty/lib_flow_ff/tsl18fs120_scl_ff.lib \
]

set_db lef_library [list \
  /mnt/c2s/cadence/Analog_tools/FOUNDRY/scl_pdk/stdlib/fs120/tech_data/lef/tsl180l4.lef \
]

# ==================================================
# READ RTL FILES
# ==================================================
set RTL_FILES {
  aardonyx.v
  mkmuldiv.v
  module_decoder_func_32.v
  BRAM2BELoad.v
  mkpinmuxtop.v
  module_decode_word32.v
  ClockInverter.v
  mkpinmux.v
  module_fn_alu.v
  Counter.v
  mkplic.v
  module_fn_decompress.v
  FIFO10.v
  mkpwm_cluster.v
  module_fn_pmp_lookup.v
  FIFO1.v
  mkpwm.v
  RegFile.v
  FIFO20.v
  mkqspi.v
  ResetEither.v
  FIFO2.v
  mkriscvDebug013.v
  sdrc_bank_ctl.v
  FIFOL1.v
  mkriscv.v
  sdrc_bank_fsm.v
  MakeClock.v
  mkSencoder.v
  sdrc_bs_convert.v
  MakeReset0.v
  mkSoc.v
  sdrc_core.v
  MakeResetA.v
  mkspi_cluster.v
  sdrc_req_gen.v
  mkalu.v
  mkspi.v
  sdrc_top.v
  mkbootrom.v
  mkstage1.v
  sdrc_xfr_ctl.v
  mkcsrfile.v
  mkstage2.v
  SizedFIFO.v
  mkcsr.v
  mkstage3.v
  SyncFIFO1.v
  mkeclass_axi4lite.v
  SyncHandshake.v
  mkgpio.v
  mkuart_cluster.v
  SyncRegister.v
  mki2c.v
  mkuart.v
  SyncReset0.v
  mkjtagdtm.v
  module_address_valid.v
  SyncResetA.v
  mkmixed_cluster.v
  module_chk_interrupt.v
  UngatedClockMux.v
}

foreach f $RTL_FILES {
  read_hdl $RTL_DIR/$f
}

# ==================================================
# ELABORATE
# ==================================================
elaborate mkSoc
current_design mkSoc

# ==================================================
# READ CONSTRAINTS
# ==================================================
set sdc_file "/home/student/contraints.sdc"
read_sdc $sdc_file

# ==================================================
# SYNTHESIS
# ==================================================
syn_generic
syn_map
syn_opt

# ==================================================
# CELL + PORT SUMMARY REPORT
# ==================================================

set rpt_file [open cell_port_summary.rpt w]

puts $rpt_file "==============================================="
puts $rpt_file "        CELL TYPE SUMMARY"
puts $rpt_file "==============================================="

# Total Cells
set total_cells [llength [get_cells -hier]]
puts $rpt_file "Total Cells: $total_cells"

# Sequential Cells
set seq_cells [llength [get_cells -hier -filter "is_sequential==true"]]
puts $rpt_file "Sequential Cells: $seq_cells"

# Combinational Cells
set comb_cells [llength [get_cells -hier -filter "is_combinational==true"]]
puts $rpt_file "Combinational Cells: $comb_cells"

# DFF Count
set dff_cells [llength [get_cells -hier -filter "is_sequential==true && is_latch==false"]]
puts $rpt_file "DFF Count: $dff_cells"

# Latch Count
set latch_cells [llength [get_cells -hier -filter "is_latch==true"]]
puts $rpt_file "Latch Count: $latch_cells"

puts $rpt_file ""
puts $rpt_file "==============================================="
puts $rpt_file "            PORT SUMMARY"
puts $rpt_file "==============================================="

# Port Counts
set total_ports [llength [get_ports]]
puts $rpt_file "Total Ports: $total_ports"

set input_ports [llength [get_ports -filter "direction==in"]]
puts $rpt_file "Input Ports: $input_ports"

set output_ports [llength [get_ports -filter "direction==out"]]
puts $rpt_file "Output Ports: $output_ports"

set inout_ports [llength [get_ports -filter "direction==inout"]]
puts $rpt_file "Inout Ports: $inout_ports"

close $rpt_file

# ==================================================
# STANDARD REPORTS
# ==================================================
report_area   > area.rpt
report_timing > timing.rpt

# ==================================================
# WRITE LEC CLEAN NETLIST
# ==================================================
write_hdl -lec > final.v

# ==================================================
# GENERATE CONFORMAL DO FILE
# ==================================================
write_do_lec \
  -golden_design rtl \
  -revised_design final.v \
  > rtl_to_final.do

puts "==============================================="
puts "SYNTHESIS COMPLETED SUCCESSFULLY"
puts "Summary written to cell_port_summary.rpt"
puts "==============================================="