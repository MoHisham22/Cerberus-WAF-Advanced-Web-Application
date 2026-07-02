# Cerberus WAF — Setup Guide

## First-time Setup

After cloning the repo, follow these steps before running `docker-compose up -d`.

### 1. Create your `.env` file
```bash
cd docker
cp .env.example .env
```
Edit `.env` and set a strong password:
```
MYSQL_PASSWORD=YourStrongPasswordHere
```

### 2. Create your `waf_config/config.json`
```bash
cp waf_config/config.json.example waf_config/config.json
```
Edit `config.json` and update:
- `dsn`: Replace `YOUR_MYSQL_PASSWORD` with your actual password (must match `.env`)
- `jwt_key`: Generate a random 32-character string
- `api_token`: Generate a random token

### 3. Start the project
```bash
docker-compose up -d
```

### 4. Run the attack simulator (optional — for demo purposes)
```bash
pip install requests
python attack_simulator.py
```

---

## Re-starting after system reboot

The WAF and database start automatically via Docker's `restart: always` policy.

After reboot, just run the attack simulator if you want the Live Threat Map to show activity:
```bash
cd docker
python attack_simulator.py
```

---

## Troubleshooting: Database won't start

If MySQL fails with InnoDB errors after an unexpected shutdown:
```bash
# Delete corrupted InnoDB redo log files
Remove-Item docker/waf_data/ib_logfile0
Remove-Item docker/waf_data/ib_logfile1

# Then restart
docker-compose up -d
```
