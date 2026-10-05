import sys
import urllib.request

URL = "http://127.0.0.1:8000/health/"

try:
    with urllib.request.urlopen(URL, timeout=3) as response:
        if response.status == 200:
            sys.exit(0)
except Exception as exc:
    print(f"Healthcheck failed: {exc}")

sys.exit(1)
