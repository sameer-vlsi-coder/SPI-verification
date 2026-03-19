# Clean coverage outputs
file delete -force spi.ucdb

# Clean old compiled library if it exists
if {[file exists work]} {
    vdel -lib work -all
}

# Create fresh work library
vlib work
vmap work work


# Compile RTL for code coverage
vlog -sv -cover bcesft +acc top.sv

# Compile testbench normally
vlog -sv +acc tb.sv

# Simulate testbench (it instantiates RTL)
vsim -coverage work.tb

add wave -divider "DUT Signals"
add wave -r /tb/dut/*
add wave -divider "Interface"
add wave /tb/vif/clk
add wave /tb/vif/rst
add wave /tb/vif/wr
add wave /tb/vif/addr
add wave /tb/vif/din
add wave /tb/vif/dout
add wave /tb/vif/done
add wave /tb/vif/err

# Run simulation
run -all

# Save coverage
coverage save spi.ucdb

# Report coverage summary (optional)
coverage report -details
