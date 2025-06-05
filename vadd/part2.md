<table class="sphinxhide" width="100%">
 <tr>
   <td align="center"><img src="./images/copy.png" width="30%"/><h1>🔧 Environment Setup</h1>
   </td>
 </tr>
 <tr>
 <td>
 </td>
 </tr>
</table
# AHEAD Example Project: Vector Addition

Welcome to the AHEAD workshop! This section walks you through setting up and cloning the example project used in the hands-on sessions.

---

### 1. Connect to the server and lagin to a VNC session as desribed [here](https://github.com/AkshayMalige/AHEAD_2025/tree/main/VNC):

### 2. Open a terminal in your desired workspace location:
> (Right-click → **"Open Terminal Here"**)

```bash
cd ~
```

### 3. Source the Xilinx environment

Depending on the machine you're using, run the appropriate commands below.

#### 🔹 If you're on your local machine:

```bash
source /path_to_Vitis_installation/Xilinx/Vitis/2024.2/settings64.sh
source /opt/xilinx/xrt/setup.sh    //path to xrt installation
```

#### 🔹 If you're on `130.199.21.151`:

```bash
source /tools/Xilinx/Vitis/2024.2/settings64.sh
source /opt/xilinx/xrt/setup.sh
```

#### 🔹 If you're on `haiderbnldesktop`:

```bash
source /media/slowSSD/Xilinx_2024.1/Vitis/2024.1/settings64.sh
source /opt/xilinx/xrt/setup.sh
```

---

## 📂 Project Checkout

### 4. Create a working directory for AHEAD projects:

```bash
mkdir -p ~/AHEAD
cd ~/AHEAD
```

### 5. Clone the example repository:

```bash
git clone https://github.com/AkshayMalige/AHEAD_2025.git
```

You are now ready to begin working on the example vector addition project.

---

## Next Step

  **Click here to [Review the Host and Kernel Code](./part3.md)**
