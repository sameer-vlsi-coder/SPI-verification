# 🚀 UVM-Based Verification of Memory Interface with Error Injection

## 📌 Project Overview
This project verifies an **Verification of Memory Interface with Error Injection** using **Verilog** for RTL and a **SystemVerilog UVM-based verification environment**.  
The verification covers **SPI read/write operations**, **reset behavior**, **address validation**, and **protocol correctness**.

Verification completeness is ensured using:
- ✅ SystemVerilog Assertions  
- 📊 Functional Coverage  
- 📈 Code Coverage  

All simulations and coverage analysis are performed using **QuestaSim**, with **TCL scripting** used to automate the verification flow.

---

## 🧠 Design Under Test (DUT)
The Design Under Test is an **SPI memory module** that supports **read and write operations** controlled by a write-enable signal.  
The DUT interfaces with a memory array and provides status signaling for operation completion and error detection.

### 🔌 Interface Signals
- **reset**  
  🔹 Active-high reset. Clears all internal states and outputs.

- **WR**  
  🔹 Operation select signal  
  - `WR = 1` → ✍️ Write  
  - `WR = 0` → 📖 Read  

- **addr**  
  🔹 Address input for memory access

- **din**  
  🔹 Data input during write operations

- **dout**  
  🔹 Data output during read operations

- **done**  
  🔹 Indicates completion of read/write operation

- **error**  
  🔹 Indicates invalid access (out-of-range address)

---

## ⚙️ SPI Functional / Operation Specification

### 🧩 Functional Description
- `WR` selects operation mode (Read / Write)
- All operations are valid only when `reset = 0`
- When `reset = 1`, all outputs and states are cleared

### ✍️ Write Operation
- Deassert reset (`reset = 0`)
- Set `WR = 1`
- Apply `addr` and `din`
- Perform write
- `done` asserted after completion

### 📖 Read Operation
- Set `WR = 0`
- Apply `addr`
- Read data appears on `dout`
- `done` asserted after completion

### 🚨 Address Checking & Error Handling
- `addr >= 31` → `error = 1`, `dout = 0`
- `addr < 31` → valid operation
- Applies to both read and write

### ⏱️ Status Signaling
- `done` remains low during operation
- Asserted only after successful completion

---

## 🛡️ Assertions
SystemVerilog assertions continuously monitor protocol and control correctness.

### ✔️ Implemented Assertions
- 🔁 **Reset Assertion**
  - No operation during reset
  - `done = 0`, `error = 0`

- ✅ **Completion Assertion**
  - `done` asserted only after valid completion

- 🚫 **Address Range Assertion**
  - `error = 1` for `addr >= 31`
  - `error = 0` for valid addresses

- 🔐 **Valid Operation Assertion**
  - Operations allowed only when reset is deasserted

---

## 📊 Functional Coverage
Functional coverage ensures all planned scenarios are exercised.

- Coverpoints for all interface signals
- Coverpoints for valid & invalid address ranges
- Cross coverage for combined signal behavior

🎯 **Total Covergroup Coverage:** `100%`  
📦 **Covergroup Types:** `1`

---

## 📈 Code Coverage

### 📑 Summary
RTL code coverage is collected using **QuestaSim** with the following metrics enabled:
- Statement Coverage ≈ **96.47%**
- Branch Coverage ≈ **95%**
- Condition Coverage = **100%**
- FSM State Coverage = **100%**
- FSM Transition Coverage ≈ **75%**
- Toggle Coverage ≈ **70%**

🧮 **Total RTL Coverage:** ≈ **89.89%**

> ℹ️ Partial coverage exists due to default branches and idle-state transitions not triggered during valid SPI operation.

---

## 🔧 Tool & Automation

### 🧪 Simulation Tool
- **Simulator:** QuestaSim  
- **Languages:** Verilog, SystemVerilog  
- **Verification Features:** Assertions, Functional Coverage, Code Coverage  

### 🤖 Automation
- **TCL scripting** automates:
  - Compilation
  - Optimization with coverage
  - Simulation
  - Coverage reporting

Ensures **repeatability** and **consistency**.

---

## ⚠️ Limitations
- Default and idle-state paths are not exercised
- Some FSM transitions are unreachable in normal operation
- Toggle coverage limited for wide counters
- No stress or performance testing

---

## 🏁 Conclusion
This project demonstrates **end-to-end verification** of an SPI memory design written in **Verilog**, using a **SystemVerilog UVM-based environment**.  
The use of **assertions, functional coverage, code coverage**, and **TCL automation** reflects an **industry-aligned verification methodology**

---

