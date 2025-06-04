# 🚀 AHEAD Workshop VNC Access Guide
Connecting to haiderbnldesktop
---

## 📌 Initial Login (SSH)

From your terminal, connect to your assigned account:

```bash
ssh -J uname@lxtunnel.cern.ch ahead_userXX@haiderbnldesktop.cern.ch
```

- Replace `uname` with your CERN user name.
- Replace `XX` with your assigned user number.
- **Password:** `AHEADworkshop`
> **Note:** You will have enter your cern password first and then the password for haiderbnldesktop.cern.ch.


---

## 🚦 Starting the VNC Server

Once logged in, start your VNC session:

```bash
vncserver :XX
```

- Replace `:XX` with your assigned user number.
> **Note:** If your number start with '0', `ex : 05`, do `vncserver :5`.

> **Note:** You only need to start this once unless you manually stop your session.

To close your SSH connection safely:

```bash
exit
```

---

## 🌐 Connecting via SSH Tunnel

You must create an SSH tunnel from your local computer to securely connect your VNC session.

In your terminal:

```bash
ssh -J uname@lxtunnel.cern.ch -L 59XX:localhost:59XX ahead_userXX@haiderbnldesktop.cern.ch
```

- Replace `XX` with your user number.

Leave this SSH session open while using your VNC.

---

## 🖥️ Connecting Using VNC Viewer

### 🐧 **Ubuntu / Linux**

1. Open `Remmina`.
2. Change the protocol from **RDP** to **VNC**.
3. Enter:

```
localhost:59XX
```

- Replace `XX` with your user number.

4. Password:

```
workshop
```

---

### 🍎 **macOS**

1. Open `Finder`.
2. Press `⌘ + K` (or use `Go → Connect to Server`).
3. Enter:

```
vnc://localhost:59XX
```

- Replace `XX` with your user number.

4. Enter password:

```
workshop
```

---

### 🪟 **Windows**

1. Download and install a VNC client such as [TigerVNC](https://tigervnc.org/) or [RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/).
2. Launch your VNC viewer.
3. Enter server address:

```
localhost:59XX
```

- Replace `XX` with your user number.

4. Password:

```
workshop
```

---

## ❗ Important Notes

- Always keep your SSH tunnel open while working.
- If the connection fails, verify your VNC server is running and the SSH tunnel is active.

---

## 🔌 Stopping Your VNC Session (Optional)

To stop the VNC server when done:

```bash
ssh ahead_userXX@130.199.21.151
vncserver -kill :XX
exit
```

- Replace `XX` with your user number.

---

## 📩 Need Help?

Contact the workshop organizer for assistance.

---

Enjoy your workshop! 🚀

---

