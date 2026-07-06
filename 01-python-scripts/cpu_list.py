servers = {
    "web-01": 45.2,
    "web-02": 92.1,
    "db-01": 78.9,
    "cache-01": 99.5
}
threshold = 90

for server_name, cpu in servers.items():
    status = "ALERT" if cpu > threshold else "OK"
    print(f"{server_name}: {cpu}% - {status}")
