

Step-by-Step: Clean and Configure Netplan with systemd-networkd.
Ensure are installed in the system netplan.io systemd-networkd systemd-resolved
Create a clean netplan including renderer networkd and ens35 as static ip 192.168.66.54 /24 

also give me test cases for eath of the application




Absolutely! Here's a complete step-by-step guide to cleanly configure your system to use only Netplan with systemd-networkd, and set a static IP on interface ens35. I’ll also include test cases to verify each component is working correctly.

---

## 🧼 Step-by-Step: Clean and Configure Netplan with systemd-networkd

### ✅ 1. Ensure Required Packages Are Installed

```bash
sudo apt update
sudo apt install -y netplan.io systemd-networkd systemd-resolved
```

---

### ✅ 2. Disable and Remove Conflicting Network Managers

```bash
sudo systemctl disable --now networking NetworkManager
sudo apt purge -y ifupdown network-manager
```

---

### ✅ 3. Enable Required Services

```bash
sudo systemctl enable --now systemd-networkd
sudo systemctl enable --now systemd-resolved
```

Fix DNS resolution:

```bash
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
```

---

### ✅ 4. Create a Clean Netplan Configuration

Create or edit the file:

```bash
sudo nano /etc/netplan/01-netcfg.yaml
```

Paste the following:

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens35:
      dhcp4: false
      addresses:
        - 192.168.66.54/24
      gateway4: 192.168.66.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
```

> Replace `192.168.66.1` with your actual gateway if different.

---

### ✅ 5. Apply the Configuration

```bash
sudo netplan generate
sudo netplan apply
```

---

## 🧪 Test Cases for Each Component

### 🔍 A. Test Netplan

| Test | Command | Expected Result |
|------|---------|-----------------|
| Validate config | `sudo netplan generate` | No errors |
| Apply config | `sudo netplan apply` | No output (success) |
| Check YAML | `cat /etc/netplan/01-netcfg.yaml` | Correct syntax and values |

---

### 🔍 B. Test systemd-networkd

| Test | Command | Expected Result |
|------|---------|-----------------|
| Service status | `systemctl status systemd-networkd` | Active (running) |
| Interface status | `networkctl status ens35` | Shows static IP `192.168.66.54` |
| IP address | `ip a show ens35` | Shows correct IP and UP state |
| Routing | `ip route` | Shows default route via `192.168.66.1` |

---

### 🔍 C. Test systemd-resolved

| Test | Command | Expected Result |
|------|---------|-----------------|
| Service status | `systemctl status systemd-resolved` | Active (running) |
| DNS status | `resolvectl status ens35` | Shows DNS servers `8.8.8.8`, `1.1.1.1` |
| DNS resolution | `ping google.com` | Resolves and pings successfully |
| Check resolv.conf | `cat /etc/resolv.conf` | Points to `127.0.0.53` |

---

Would you like to extend this setup with a second interface, VLAN, or bridge configuration?



Perfect! Let's extend your Netplan configuration to:

- ✅ Keep `ens35` with a static IP
- ✅ Add a VLAN interface on `ens35` with VLAN ID `340` (for OAM)
- ✅ Create a bridge interface that includes both `ens33` and `ens35`

---

## 🧩 Updated Netplan Configuration

```yaml
network:
  version: 2
  renderer: networkd

  ethernets:
    ens33: {}
    ens35:
      dhcp4: false
      addresses:
        - 192.168.66.54/24
      gateway4: 192.168.66.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1

  vlans:
    vlan340:
      id: 340
      link: ens35
      dhcp4: yes

  bridges:
    br-oam:
      interfaces: [ens33, ens35]
      dhcp4: no
      addresses:
        - 10.10.10.1/24
      parameters:
        stp: false
        forward-delay: 0
```

> 🔧 Notes:
> - `vlan340` is a VLAN interface on top of `ens35` with DHCP enabled (you can set static IP if needed).
> - `br-oam` is a bridge combining `ens33` and `ens35`, with a static IP `10.10.10.1/24`.

---

## 🚀 Apply the Configuration

```bash
sudo netplan generate
sudo netplan apply
```

---

## 🧪 Test Cases for VLAN and Bridge

### 🔍 VLAN 340 on ens35

| Test | Command | Expected Result |
|------|---------|-----------------|
| Interface exists | `ip link show vlan340` | Shows VLAN interface UP |
| IP assigned | `ip a show vlan340` | Shows DHCP-assigned IP |
| VLAN tag | `bridge vlan` or `ip -d link show vlan340` | Confirms VLAN ID 340 |

---

### 🔍 Bridge br-oam

| Test | Command | Expected Result |
|------|---------|-----------------|
| Interface exists | `ip link show br-oam` | Shows bridge UP |
| IP assigned | `ip a show br-oam` | Shows `10.10.10.1/24` |
| Members | `bridge link` or `bridge vlan` | Shows `ens33` and `ens35` as bridge ports |

---

Would you like to assign a static IP to the VLAN interface or enable STP on the bridge for redundancy?
