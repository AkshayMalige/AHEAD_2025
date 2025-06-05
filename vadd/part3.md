<table class="sphinxhide" width="100%">
 <tr>
   <td align="center">
     <img src="./images/copy.png" width="30%"/><h1>Vitis™ Example Tutorials</h1>
   </td>
 </tr>
 <tr>
   <td>
   </td>
 </tr>
</table

# AHEAD Example Project – Part 3: Component Build Instructions

This section shows you how to build the HLS kernel and host application components in Vitis™ (Classic or Unified). If you’ve completed [**Part 1**](./part1.md) (Essential Concepts) and [**Part 2**](./part2.md) (Project Setup & Vector Addition), you’re ready to compile the components for simulation or hardware.

---

## 1. Build the HLS Kernel (vadd)

1. **Open Vitis HLS 2024.2 (Classic GUI or Unified GUI)**  
   - In **Classic**, select **File → New → Project**, or click the “new project” icon.  
   - In **Unified**, click **+ Create Application Project**, then switch to HLS perspective.

2. **Create a New HLS Project**  
   - **Project name:** `vadd_kernel`  
   - **Solution name:** `vadd_solution`  
   - **RTL Language:** C++  
   - **Device:** Choose **xilinx_u250_gen3x16_xdma_4_1** (from your `u250.cfg`)  
   - **Part:** Should auto-detect `xcu250-figd2104-2L-e`.

3. **Add Kernel Sources**  
   - In the **Source** tab, click **Add Sources** → **Add New File**  
     - File name: `krnl_vadd.cpp`  
     - Paste the contents of your `krnl_vadd.cpp` (see `vadd_kernels/src/krnl_vadd.cpp`).  
   - Click **Add Existing File** and navigate to `vadd_kernels/src/krnl_vadd.h`.  
   - Make sure both files appear under **Solution “vadd_solution” → vadd_kernel**.

4. **Set Top Function**  
   - In the **Hierarchy** pane, right-click on `krnl_vadd.cpp` → **Set as Top Function**  
   - You should see `krnl_vadd` in green under **C Synthesis**.

5. **Run C Synthesis**  
   - Click the **C Synthesis** (play) button.  
   - Wait for the **Synthesis Done** message in the log window.  
   - Confirm there are no errors; warnings about latency or II are okay.

6. **Run C/RTL Cosimulation** (optional)  
   - Click **C/RTL Cosimulation**.  
   - If your testbench is set in `vadd_kernels/tb/vadd_tb.cpp`, make sure it’s added.  
   - Check the **Simulation Done** message.  

7. **Export Kernel as XO**  
   - In the **C Synthesis** view, click **Export RTL** → **Format: XO** → **OK**.  
   - Result: `vadd.xo` appears under `vadd_kernels/solution1/syn/vadd_kernel/` (or similar).

---

## 2. Build the Host Application

1. **Open Vitis 2024.2 (Classic or Unified GUI)**  
   - If already open, ensure you are in the **Application Project** perspective.

2. **Create a New Application Project**  
   - **Project name:** `vadd_host`  
   - **Platform:** Select **xilinx_u250_gen3x16_xdma_4_1** (should match the HLS project).  
   - **OS:** Choose **Standalone**, or **Linux** if running on a Linux target.  

3. **Add Host Source Files**  
   - Right-click `vadd_host` → **Add Sources** → **Add Existing File** → select `host.cpp` from `vadd_host/src/host.cpp`.  
   - Confirm that `host.cpp` appears under **vadd_host/src**.

4. **Add Include Path for Kernel Header**  
   - Right-click on `vadd_host` → **C/C++ Build Settings**  
   - Under **GCC Compiler → Includes**, click **Add**:  
     ```
     ../vadd_kernels/src
     ```  
   - This ensures `#include "krnl_vadd.h"` in `host.cpp` resolves correctly.

5. **Link XO File**  
   - Expand **vadd_host** → **System Configuration** → **Linker** → **Linker Flags**.  
   - Ensure `-L${XO_PATH}` is specified if needed, or simply use the GUI:  
     - Under **System Configuration → Linker**, click **Add** under **Load XO**.  
     - Navigate to `vadd_kernels/solution1/syn/vadd_kernel/vadd.xo`.  

6. **Specify the `.cfg` File for the U250 Platform**  
   - Still under **vadd_host → System Configuration**:  
     - Click **Platform** → **Edit** → **Advanced** → **Configuration File**.  
     - Browse to `vadd_kernels/platform/u250.cfg` (the `u250.cfg` you created).  
     - Click **OK**.

7. **Build the Host Application**  
   - Click **Build** (hammer icon) for `vadd_host`.  
   - Monitor the **Console**: it should compile without errors and generate `vadd_host.elf` (for emulator) or `.xclbin` for hardware.

---

## 3. Create the Binary Container

1. **System Link (Generate `.xclbin`)**  
   - In **vadd_host**, right-click → **Build Configurations → Set Active → Emulation-HW** (or **Hardware**).  
   - Click **Build** again.  
   - The **Console** will show:
     ```
     v++ --link ... --config ../vadd_kernels/platform/u250.cfg \
       --xo ../vadd_kernels/solution1/syn/vadd_kernel/vadd.xo \
       --out_dir ./vadd_system_hw_link/Emulation-SW ...
     ```
   - Wait for **Link Complete**; you’ll find `binary_container_1.xclbin` under `vadd_system_hw_link/Emulation-SW/`.

2. **Verify the `.xclbin`**  
   - Use:
     ```bash
     ls vadd_system_hw_link/Emulation-SW/binary_container_1.xclbin
     ```
   - If present, you’re ready to run either **X86 Emulation** or program the U250 card.

---

## 4. Run in Emulation (Optional)

1. **X86 Emulation**  
   - Switch **Run Configuration** to **Emulation-SW**.  
   - Click **Run** (green ▶️).  
   - The **Console** should show kernel load messages and final output (e.g., “Test PASSED”).

2. **Hardware Emulation** (If you have a U250 card connected)  
   - Switch **Run Configuration** to **Emulation-HW**.  
   - Click **Run**.  
   - You should see board detection, kernel programming, and data transfer logs.

---

## 5. (Optional) Command-Line Build

If you prefer **CLI**:

```bash
# From project root:
# 1. Build the HLS kernel:
v++ -c -t hw --platform xilinx_u250_gen3x16_xdma_4_1 \
    -k krnl_vadd \
    -I vadd_kernels/src \
    -o vadd_kernel.xo \
    vadd_kernels/src/krnl_vadd.cpp

# 2. Build the host executable:
g++ host/src/host.cpp -o host.exe \
    -I vadd_kernels/src \
    -lOpenCL -lpthread

# 3. Link into xclbin:
v++ -l -t hw --platform xilinx_u250_gen3x16_xdma_4_1 \
    --config vadd_kernels/platform/u250.cfg \
    --xo vadd_kernel.xo \
    -o vadd_system_hw_link/binary_container_1.xclbin

# 4. Run (must have $XCL_EMULATION_MODE set appropriately):
# For X86 emulation:
export XCL_EMULATION_MODE=sw_emu
./host.exe ./vadd_system_hw_link/binary_container_1.xclbin
