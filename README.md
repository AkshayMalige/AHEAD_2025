<table class="sphinxhide" width="100%">
   <td align="center"><img src="vadd/images/copy.png" width="70%"/>
   </td>

</table>


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


### 🖥️ [`VNC/`](./VNC)
Instructions and configuration notes for managing remote VNC environments on shared lab systems.

---

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

## 🧭 Getting Started

To prepare user environments for training/workshops:
- [`VNC/README.md`](./VNC/README.md)
  
To set up and explore the Vitis flow, start with:
- [`vadd/README.md`](./vadd/README.md)


---

## 🛠️ Requirements
- Ubuntu 20.04 or later or Windows (lab machines / VNC setup)
- Vitis Unified IDE 2024.2 or 2024.1
- AMD Alveo platform files (e.g., `xilinx_u250_gen3x16_xdma_4_1_202210_1`)
- XRT installed and configured

---

## 🔗 Related Repositories

- [Click here for Vitis Getting Started document](https://docs.amd.com/r/en-US/Vitis-Tutorials-Getting-Started/Vitis-Tutorials-Getting-Started-XD098)
- [Click here for Vitis HLS Tutorials](https://xilinx.github.io/Vitis-Tutorials/2022-1/build/html/docs/Getting_Started/Vitis_HLS/Getting_Started_Vitis_HLS.html)
- [Click here for Vitis Software Installation](https://docs.amd.com/r/en-US/ug1400-vitis-embedded/Vitis-Software-Platform-Installation)
- [Click here for XRT and Deployment Platform Installation Procedures on RedHat and CentOS](https://docs.amd.com/r/en-US/ug1301-getting-started-guide-alveo-accelerator-cards/XRT-and-Deployment-Platform-Installation-Procedures-on-RedHat-and-CentOS)

---
