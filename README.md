# SPI Memory Verification using Verilog, SystemVerilog, and UVM

## Project Overview
This project verifies an **SPI-based memory module** using **Verilog** for RTL and a **SystemVerilog UVM-based verification environment**. The verification covers SPI read/write operations, reset behavior, address validation, and protocol correctness.

Verification completeness is ensured using **SystemVerilog assertions**, **functional coverage**, and **code coverage**. Simulations and coverage analysis are performed using **QuestaSim**, with **TCL scripting** used to automate the verification flow.

---

## Design Under Test (DUT)
The Design Under Test is an **SPI memory module** that supports basic **read and write operations** controlled through a write-enable signal. The module interfaces with a memory array and provides status signaling to indicate operation completion and error conditions.

### Interface Signals
- **reset**  
  Active-high reset signal. When asserted, all internal states and outputs are cleared.

- **WR**  
  Operation control signal:  
  - `WR = 1` → Write operation  
  - `WR = 0` → Read operation  

- **addr**  
  Address input used to select the memory location for read or write operations.

- **din**  
  Data input used during write operations.

- **dout**  
  Data output used during read operations.

- **done**  
  Status signal indicating completion of a read or write operation.

- **error**  
  Error flag indicating an invalid operation due to an out-of-range address.

---

## SPI Functional / Operation Specification

### Functional Description
- The `WR` signal controls the operation mode:
  - `WR = 1` → Write operation
  - `WR = 0` → Read operation
- All operations are enabled only when `reset = 0`
- When `reset = 1`, all outputs and internal states are cleared to zero

### Write Operation
- Reset is deasserted (`reset = 0`)
- `WR` is set to `1`
- Address (`addr`) and input data (`din`) are applied
- Write operation is performed
- `done` is asserted high only after write completion

### Read Operation
- `WR` is set to `0`
- Address (`addr`) is applied
- Data is read from memory and observed on `dout`
- `done` is asserted high only after read completion

### Address Checking and Error Handling
- If `addr >= 31`, the `error` signal is asserted and `dout` is driven to zero
- If `addr < 31`, the `error` signal remains low and valid data is observed
- Address checking applies to both read and write operations

### Status Signaling
- `done` indicates completion of a read or write transaction
- `done` remains low during an active operation
- Outside completed transactions, `done` remains low

---

## Assertions
SystemVerilog assertions are used to continuously monitor correctness during simulation.

### Assertion Checks Implemented
- **Reset Assertion**
  - Ensures no read or write occurs when `reset = 1`
  - Verifies `done` and `error` remain low during reset

- **Operation Completion Assertion**
  - Ensures `done` is asserted only after valid read/write completion
  - Verifies `done` remains low during an active transaction

- **Address Range Assertion**
  - Asserts `error = 1` when `addr >= 31`
  - Ensures `error = 0` for valid addresses (`addr < 31`)

- **Valid Operation Assertion**
  - Ensures operations are enabled only when `reset = 0`

---

## Functional Coverage
Functional coverage is implemented to ensure all planned scenarios are exercised.

- Coverpoints created for all interface signals
- Coverpoints for valid and invalid address ranges
- Cross coverage for combined signal behavior

**Total Covergroup Coverage:** 100%  
**Covergroup Types:** 1

---

## Code Coverage

### Summary
Code coverage is collected using **QuestaSim** with **statement, branch, condition, FSM, and toggle coverage** enabled.

- Statement coverage ≈ 96.47%
- Branch coverage ≈ 95%
- Condition coverage = 100%
- FSM state coverage = 100%
- FSM transition coverage ≈ 75%
- Toggle coverage ≈ 70%
- Total RTL coverage (filtered view) ≈ 89.89%

**Note:**  
Partial code coverage is observed because default branches and idle-state transitions are not triggered under normal and valid SPI transaction scenarios.

---

## Tool & Automation

### Simulation Tool
- **Simulator:** QuestaSim  
- **Languages:** Verilog, SystemVerilog  
- **Verification Features Used:**
  - Assertions
  - Functional Coverage
  - Code Coverage (Branch, Condition, FSM, Toggle)

### Automation
- **TCL scripting** is used for:
  - Compilation of RTL and testbench
  - Design optimization with coverage enabled
  - Simulation execution
  - Coverage collection and reporting

Automation ensures repeatable simulations and consistent coverage results.

---

## Limitations
- Certain default branches and idle-state transitions are not exercised.
- FSM transition coverage is partial due to unreachable transitions in normal operation.
- Toggle coverage is limited for wide counters and rarely changing signals.
- Performance and stress testing are outside the current scope.

---

## Conclusion
This project verifies an **SPI memory design written in Verilog** using a **SystemVerilog UVM-based verification environment**. Functional correctness is validated through **directed stimulus, assertions, functional coverage, and code coverage** in **QuestaSim**.

**TCL-based automation** demonstrates a structured, repeatable, and industry-aligned verification workflow.
