<table class="sphinxhide" width="100%">
 <tr>
   <td align="center"><img src="vadd/images/copy.png" width="30%"/><h1>AHEAD_2025</h1>
   </td>
 </tr>
 <tr>
 <td>
 </td>
 </tr>
</table>

# AHEAD_2025 Project

Welcome to the AHEAD_2025 workspace! This repository organizes several components used for FPGA-based acceleration and remote user setup. Each directory focuses on a specific part of the workflow.

---

## 📂 Project Structure Overview
```
AHEAD_2025/
├── accounts      # Scripts for creating/deleting user accounts and VNC setup
├── vadd          # Vector addition kernel project with documentation and source
├── VNC           # Notes/documentation specific to VNC environments
├── README.md     # This file
```

---

## 📜 Component Details

### 🔧 [`vadd/`](./vadd)
This folder contains the example project for hardware acceleration using Vitis Unified IDE 2024.2.  
Includes a multi-part walkthrough:
- [`part1.md`](./vadd/part1.md): Introduction to Vitis Flow
- [`part2.md`](./vadd/part2.md): Environment Setup  
- [`part3.md`](./vadd/part3.md): Code review
- [`part4.md`](./vadd/part4.md): HLS component steps  
- [`part5.md`](./vadd/part5.md): Host and system project

📁 See [vadd/src](./vadd/src) for the actual HLS and host source files.

---

### 👤 [`accounts/`](./accounts)
Scripts to manage temporary user accounts and set up VNC sessions.

<!-- Includes:
- `user_create.sh` / `user_delete.sh`: User management
- `user_vnc.sh`: VNC setup per user
- `README.md`: Details for system admins -->

---

### 🖥️ [`VNC/`](./VNC)
Instructions and configuration notes for managing remote VNC environments on shared lab systems.

---

## 🧭 Getting Started

To set up and explore the Vitis flow, start with:
- [`vadd/README.md`](./vadd/README.md)

To prepare user environments for training/workshops:
- [`accounts/README.md`](./accounts/README.md)

---

## 🛠️ Requirements
- Ubuntu 20.04 or later or Windows (lab machines / VNC setup)
- Vitis Unified IDE 2024.2 or 2024.1
- AMD Alveo platform files (e.g., `xilinx_u250_gen3x16_xdma_4_1_202210_1`)
- XRT installed and configured

---

## 🔗 Related Repositories

- 

---
