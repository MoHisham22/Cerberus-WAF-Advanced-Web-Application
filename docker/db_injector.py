import subprocess
import time
import random

# قائمة الهجمات مع إحداثيات الدول
ATTACKS = [
    ("114.114.114.114", "China", "Beijing", "Beijing", "35.8617", "104.1954", "SQL Injection", "1001"),
    ("46.17.46.213", "Russia", "Moscow", "Moscow", "61.5240", "105.3188", "XSS Attack", "1002"),
    ("198.51.100.5", "United States", "California", "San Francisco", "37.7749", "-122.4194", "Info Disclosure", "1003"),
    ("92.169.21.24", "France", "Ile-de-France", "Paris", "48.8566", "2.3522", "File Upload", "1004"),
    ("81.134.202.29", "UK", "England", "London", "51.5074", "-0.1278", "Brute Force", "1005"),
    ("122.1.2.3", "Japan", "Tokyo", "Tokyo", "35.6895", "139.6917", "Web Shell", "1006")
]

print("[*] Starting CerberusWAF Direct DB Injector for Live Map...")
print("[*] Press Ctrl+C to stop.\n")

try:
    while True:
        # اختيار هجوم عشوائي
        ip, country, province, city, lat, lon, exploit, rule_id = random.choice(ATTACKS)
        
        # أمر الحقن المباشر في الداتا بيز بتوقيت اللحظة NOW()
        query = f"INSERT INTO uuwaf.waf_logs (uid, rule_id, ip, host, url, exploit, request, country, province, city, latitude, longitude, updated_at) VALUES (1, {rule_id}, '{ip}', 'testwaf.com', '/attack_payload', '{exploit}', 'GET /attack_payload', '{country}', '{province}', '{city}', {lat}, {lon}, NOW());"
        
        # تنفيذ الأمر باستخدام Docker
        cmd = f'docker exec wafdb mysql -uroot -pStrongPass123456 -e "{query}"'
        subprocess.run(cmd, shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        
        print(f"[+] Live Attack Injected -> Country: {country} | IP: {ip} | Type: {exploit}")
        
        # انتظار عشوائي بين ثانية و 3 ثواني
        time.sleep(random.uniform(1, 3))
except KeyboardInterrupt:
    print("\n[-] Injector stopped.")