import requests
import time
import random

# إعدادات الهدف (Nginx Proxy اللي بيودي للـ WAF)
TARGET_URL = "http://127.0.0.1:80"
HOST_HEADER = "testwaf.com"

# IPs من الصين، روسيا، أمريكا، فرنسا، بريطانيا، اليابان
# قائمة بأول أرقام للـ IPs الخاصة بالدول عشان الخريطة تقرأها بشكل صحيح (الصين، روسيا، فرنسا، بريطانيا، اليابان)
IP_PREFIXES = [
    "114.114.", # China
    "46.17.",   # Russia
    "92.169.",  # France
    "81.134.",  # UK
    "122.1.",   # Japan
    "8.8."      # US
]

def generate_random_ip():
    prefix = random.choice(IP_PREFIXES)
    return f"{prefix}{random.randint(1, 254)}.{random.randint(1, 254)}"

# قائمة بهجمات مختلفة عشان الـ WAF يعملها Block
PAYLOADS = [
    "/?id=1' OR '1'='1",                  # SQL Injection
    "/?search=<script>alert(1)</script>", # XSS
    "/../../../etc/passwd",               # Path Traversal
    "/.env",                              # Info Disclosure
    "/wp-admin"                           # Brute Force Directory
]

print("[*] Starting CerberusWAF Live Attack Simulator...")
print("[*] Press Ctrl+C to stop.\n")

while True:
    try:
        target_ip = generate_random_ip()
        payload = random.choice(PAYLOADS)
        url = f"{TARGET_URL}{payload}"
        
# حقن الـ IP الوهمي في الهيدر الجديد
        headers = {
            "Host": HOST_HEADER,
            "X-Forwarded-For": target_ip,
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) CerberusWAF-Demo"
        }
        
        print(f"[+] Sending Attack from IP: {target_ip} -> Payload: {payload}")
        
        # إرسال الطلب
        response = requests.get(url, headers=headers, timeout=5)
        
        if response.status_code == 403:
            print("    -> [BLOCKED] CerberusWAF intercepted the attack!")
        else:
            print(f"    -> [STATUS] {response.status_code}")
            
        # انتظار عشوائي بين 4 و 8 ثواني عشان الهجمات تكون أبطأ
        time.sleep(random.uniform(4, 8))
        
    except KeyboardInterrupt:
        print("\n[-] Simulator stopped.")
        break
    except Exception as e:
        print(f"[!] Error: {e}")
        time.sleep(2)