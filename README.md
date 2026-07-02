# Cerberus WAF Advanced Web Application Firewall

<div align="center">
  <img src="docker/cerbrswaf_logo_assets/Picture1.png" alt="Cerberus WAF Logo" width="200"/>
  
  <br/>
  
  ![Docker](https://img.shields.io/badge/Docker-Compose-2496ED?logo=docker&logoColor=white)
  ![Nginx](https://img.shields.io/badge/Nginx-Lua_WAF-009639?logo=nginx&logoColor=white)
  ![MySQL](https://img.shields.io/badge/MySQL-5.7-4479A1?logo=mysql&logoColor=white)
  ![Python](https://img.shields.io/badge/Python-Simulator-3776AB?logo=python&logoColor=white)
  ![License](https://img.shields.io/badge/License-MIT-green)
</div>

---

## 📌 Overview

**Cerberus WAF** is a powerful, production-ready **Web Application Firewall** built on top of the OpenResty/Nginx stack with Lua-powered rule engine. It provides real-time threat detection, geo-based attack mapping, and an interactive dashboard for monitoring and managing web security.


---

## ✨ Features

| Feature | Description |
|---|---|
| 🛡️ **Real-time Blocking** | SQL Injection, XSS, LFI, RCE, Path Traversal |
| 🌍 **Live Threat Map** | GeoIP-based attack visualization dashboard |
| 🚫 **Auto-Ban** | Automatic IP blocking after repeated attacks |
| ⚡ **Cache Acceleration** | Nginx-powered static file caching rules |
| 🔒 **HTTPS Support** | Built-in SSL/TLS termination |
| 📊 **Analytics Dashboard** | Attack logs, top IPs, country statistics |
| 🤖 **Attack Simulator** | Built-in Python script to demo live attacks |

---

## 🏗️ Architecture

```
┌─────────────────┐      ┌──────────────────┐      ┌─────────────────┐
│   Browser /     │─────▶│  cerberus-proxy  │─────▶│    uuwaf WAF    │
│   Attacker      │      │  (Nginx Reverse  │      │  (Lua Engine +  │
│                 │      │   Proxy :80)     │      │   Rule Engine)  │
└─────────────────┘      └──────────────────┘      └────────┬────────┘
                                                            │
                                                   ┌────────▼────────┐
                                                   │  wafdb (MySQL)  │
                                                   │  Logs + Config  │
                                                   └─────────────────┘
```

---

## 📁 Project Structure

```
Cerberus WAF/
├── docker/
│   ├── docker-compose.yml       # Main deployment config
│   ├── nginx_override.conf      # Reverse proxy + UI customizations
│   ├── uuwaf.conf               # WAF Nginx config (real_ip, lua dicts)
│   ├── attack_simulator.py      # Demo attack simulator
│   ├── db_injector.py           # Utility: inject test data to DB
│   ├── manager.sh               # Helper management script
│   ├── waf_config/
│   │   ├── config.json.example  # WAF service config template
│   │   └── resolver.conf        # DNS resolver
│   └── cerbrswaf_logo_assets/   # Custom branding assets
├── rules/                       # WAF detection rules
├── plugins/                     # WAF plugins
├── docs/                        # Documentation
└── geo-ip-firewall/             # GeoIP firewall configs
```

---

## 🚀 Quick Start

### Prerequisites
- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed
- [Python 3.x](https://www.python.org/) (for attack simulator)
- `requests` Python library: `pip install requests`

### 1. Clone the repository
```bash
git clone
cd cerberus-waf/docker
```

### 2. Configure environment
```bash
# Copy and edit the environment file
cp .env.example .env

# Edit .env and set your MySQL password
# MYSQL_PASSWORD=YourStrongPasswordHere
```

### 3. Configure WAF service
```bash
# Copy and edit the WAF config
cp waf_config/config.json.example waf_config/config.json

# Edit config.json and fill in your credentials
```

### 4. Start the project
```bash
docker-compose up -d
```

### 5. Access the dashboard
Open your browser and go to: **http://localhost:4443**

Default credentials: `admin / admin123` *(change immediately)*

---

## 🎮 Attack Simulator

To see the Live Threat Map in action, run the attack simulator:

```bash
cd docker
python attack_simulator.py
```

This sends simulated attacks from various countries (China, Russia, UK, France, Japan, US) to populate the live geo map on the dashboard.

> ⚠️ **Note:** The simulator only targets `localhost`. Never use it against real systems.

---

## 🗺️ Live Threat Map

The dashboard includes a real-time geo-threat visualization map that shows:
- Countries of origin for attacks
- Attack count per country
- Attack types (SQLi, XSS, LFI, etc.)

The map is powered by the WAF's shared Lua memory (`/uuwaf/live`) and updates every few seconds.

---

## 🔧 Configuration

### WAF Modes
| Mode | Description |
|---|---|
| **Monitor** | Log attacks but allow traffic through |
| **Protection** | Block malicious requests with 403 response |

### Key Ports
| Port | Service |
|---|---|
| `4443` | Dashboard + WAF Admin |
| `80` | WAF traffic entry point |
| `6612` | MySQL (external access) |

---

## 🛡️ How the Blocking Works

1. Request arrives → `cerberus-proxy` forwards it to `uuwaf`
2. Lua `req_filter()` analyzes headers, URI, and body
3. Rule engine matches against 2000+ WAF rules
4. **If malicious:** GeoIP lookup → log to DB → update live map → return 403
5. **Auto-ban:** IPs exceeding threshold get added to `ipBlock` shared dict
6. **Banned IP:** Connection dropped immediately (no resource waste)

---

## 📜 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

## 👨‍💻 Authors

Developed as a Graduation Project — Computer Science Department.

> Built with ❤️ using OpenResty, Lua, Docker, MySQL, and Python.
