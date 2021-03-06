transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+D:/Lines/Quartus/Digital\ System\ Design\ ELEN30010_2020_SM1/WS5/Exercise3 {D:/Lines/Quartus/Digital System Design ELEN30010_2020_SM1/WS5/Exercise3/Exercise3.v}

vlog -vlog01compat -work work +incdir+D:/Lines/Quartus/Digital\ System\ Design\ ELEN30010_2020_SM1/WS5/Exercise3 {D:/Lines/Quartus/Digital System Design ELEN30010_2020_SM1/WS5/Exercise3/test_Exercise3.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cyclonev_ver -L cyclonev_hssi_ver -L cyclonev_pcie_hip_ver -L rtl_work -L work -voptargs="+acc"  test_MyLock

add wave *
view structure
view signals
run -all
