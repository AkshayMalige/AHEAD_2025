<table class="sphinxhide" width="100%">
  <tr>
    <td align="center">
      <img src="../vadd/images/copy.png" width="30%"/><h1>🚀 AHEAD Workshop VNC Access Guide</h1>
    </td>
  </tr>
  <tr>
    <td></td>
  </tr>
</table


# Welcome to the AHEAD workshop! This single guide provides two ways to SSH and launch a VNC session on your assigned server—choose the option that applies to you:

1. **Option A: Connect via CERN (haiderbnldesktop.cern.ch) using ProxyJump**  
2. **Option B: Direct SSH to the server IP (130.199.21.151)**

Both methods assume you have a VNC password of `AHEADworkshop` and that your user account is named `ahead_userXX` (replace `XX` with your user number, e.g., `01`, `02`, etc.).  

---

## 📌 Option A: Connect via CERN (haiderbnldesktop.cern.ch)

Use this if you are on the CERN network or have SSH access through the CERN bastion (`lxtunnel.cern.ch`).

1. **Initial SSH (with ProxyJump)**  
   ```bash
   ssh -J <cern_username>@lxtunnel.cern.ch ahead_userXX@haiderbnldesktop.cern.ch
   ```
   - Replace `<cern_username>` with your CERN login (e.g., `jdoe`).  
   - Replace `XX` with your two-digit user number.  
   - **Password for haiderbnldesktop:** `AHEADworkshop`  
     > You will first be prompted for your CERN password, then for the VNC account password on `haiderbnldesktop.cern.ch`.

2. **Start VNC Server (on the remote machine)**  
   Once you’re logged in on `haiderbnldesktop.cern.ch`, run:  
   ```bash
   vncserver :XX
   ```  
   - This launches a VNC session on display `:XX` (port `5900 + XX`).  
   - If you already started it earlier, you can skip this step.

3. **Open a Local SSH Tunnel to Forward VNC Port**  
   In a separate local terminal (on your laptop/desktop), run:
   ```bash
   ssh -J <cern_username>@lxtunnel.cern.ch        -L 59XX:localhost:59XX        ahead_userXX@haiderbnldesktop.cern.ch        -N -f
   ```  
   - `-L 59XX:localhost:59XX` forwards **local port 59XX** → **remote port 59XX**.  
   - `-N -f` tells SSH to go to the background after setting up the tunnel.  

4. **Connect with Your VNC Viewer**  
   - Open your VNC client (e.g., TigerVNC, RealVNC, Remmina).  
   - Connect to:  
     ```
     localhost:59XX
     ```  
   - When prompted, enter the **VNC password**:  
     ```
     AHEADworkshop
     ```

5. **Stop the VNC Session (After the workshop)**  
   - SSH into the server again (using the same ProxyJump command) and run:  
     ```bash
     vncserver -kill :XX
     ```  
   - Close any remaining SSH tunnels if necessary:  
     ```bash
     pkill -f "59XX:localhost:59XX"
     ```

---

## 📌 Option B: Direct SSH to 130.199.21.151

Use this if you are on a network that can directly reach `130.199.21.151` (no CERN bastion needed).

1. **Initial SSH**  
   ```bash
   ssh ahead_userXX@130.199.21.151
   ```
   - Replace `XX` with your two-digit user number.  
   - **Password:** `AHEADworkshop`

2. **Start VNC Server (on the remote machine)**  
   Once logged in, run:
   ```bash
   vncserver :XX
   ```
   - Launches a VNC session on display `:XX` (port `5900 + XX`).

3. **Open a Local SSH Tunnel**  
   In a second local terminal, run:
   ```bash
   ssh -L 59XX:localhost:59XX ahead_userXX@130.199.21.151 -N -f
   ```
   - This forwards your local port `59XX` → remote port `59XX`.

4. **Connect with Your VNC Viewer**  
   - Open your VNC client.  
   - Connect to:
     ```
     localhost:59XX
     ```
   - Enter the **VNC password**:
     ```
     AHEADworkshop
     ```

5. **Stop the VNC Session (After the workshop)**  
   - SSH into `130.199.21.151` and run:
     ```bash
     vncserver -kill :XX
     ```
   - Close the SSH tunnel:
     ```bash
     pkill -f "59XX:localhost:59XX"
     ```

---

## 📩 Need Help?

If you encounter any issues (connection failures, permission errors, VNC not starting, etc.), please contact the workshop organizer for assistance.

---

## 🔑 Quick Reference

- **Username format:**  
  ```
  ahead_userXX
  ```  
  (Two-digit `XX`, e.g., `ahead_user10`, `ahead_user11`, …)

- **VNC password:**  
  ```
  AHEADworkshop
  ```

- **Display ↔ Port mapping:**  
  ```
  Display :XX ↔ TCP port 59XX
  ```

- **SSH details:**  
  - **Option A:**  
    ```
    ssh -J <cern_username>@lxtunnel.cern.ch ahead_userXX@haiderbnldesktop.cern.ch
    ```  
  - **Option B:**  
    ```
    ssh ahead_userXX@130.199.21.151
    ```

- **Starting VNC (remote):**  
  ```
  vncserver :XX
  ```

- **Creating SSH tunnel (local):**  
  ```
  ssh -L 59XX:localhost:59XX <ssh_target> -N -f
  ```

- **Stopping VNC (remote):**  
  ```
  vncserver -kill :XX
  ```

- **Killing tunnel (local):**  
  ```
  pkill -f "59XX:localhost:59XX"
  ```

Enjoy your workshop! 🚀
