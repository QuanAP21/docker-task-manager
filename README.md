# Docker Task Manager - Đề tài 5 nâng cấp

Mini-app minh họa cho đề tài **Containerization (Docker) and Deployment**.
Bản nâng cấp bổ sung production stack, Gunicorn, healthcheck, smoke test, logging, backup/restore và GitHub Actions CI.

## 1. Kiến trúc hệ thống

```text
Browser
  |
  | http://localhost:3000
  v
frontend - React build + Nginx
  |
  | /api/ -> backend:8000
  v
backend - Django REST API
  |
  | db:5432
  v
db - PostgreSQL + Docker volume
```

## 2. Yêu cầu môi trường

- Docker Desktop hoặc Docker Engine
- Docker Compose v2
- Windows PowerShell nếu dùng các script `.ps1`

Kiểm tra:

```bash
docker --version
docker compose version
```

## 3. Chạy bản development/demo

```bash
cp .env.example .env
docker compose up --build -d
```

Trên Windows PowerShell:

```powershell
Copy-Item .env.example .env
docker compose up --build -d
```

Truy cập:

```text
Frontend: http://localhost:3000
Backend direct health: http://localhost:8000/health/
Backend direct API: http://localhost:8000/api/tasks/
API qua Nginx: http://localhost:3000/api/tasks/
```

Dừng hệ thống:

```bash
docker compose down
```

Xóa cả dữ liệu database:

```bash
docker compose down -v
```

## 4. Chạy bản production nâng cấp

Bản production dùng `docker-compose.prod.yml` và `backend/Dockerfile.prod`.
Backend chạy bằng **Gunicorn**, không publish cổng 8000 ra host; frontend Nginx là cổng public duy nhất.

```bash
cp .env.example .env
docker compose -f docker-compose.prod.yml up --build -d
```

Truy cập:

```text
Frontend: http://localhost:3000
API qua reverse proxy: http://localhost:3000/api/tasks/
Backend health qua reverse proxy: http://localhost:3000/health/
```

Kiểm tra container:

```bash
docker compose -f docker-compose.prod.yml ps
```

Kết quả mong muốn:

```text
task_db_prod        Up (healthy)
task_backend_prod   Up (healthy)
task_frontend_prod  Up (healthy)
```

## 5. Smoke test tự động

### Windows PowerShell

```powershell
.\scripts\smoke-test.ps1
```

### Linux/macOS/GitHub Actions

```bash
scripts/smoke-test.sh docker-compose.prod.yml
```

Script kiểm tra:

- Docker Compose services
- PostgreSQL healthcheck
- Backend healthcheck nội bộ
- Frontend reachable
- Backend health qua Nginx reverse proxy
- GET/POST/PUT/DELETE API
- Docker DNS resolve service `db`
- Backend kết nối được `db:5432`

## 6. Kiểm tra thủ công bằng PowerShell

Tạo task:

```powershell
$body = @{
    title = "Hoc Docker"
    description = "Test Docker Compose"
    is_done = $false
} | ConvertTo-Json

Invoke-RestMethod `
  -Uri "http://localhost:3000/api/tasks/" `
  -Method Post `
  -ContentType "application/json" `
  -Body $body
```

Lấy danh sách task:

```powershell
Invoke-RestMethod -Uri "http://localhost:3000/api/tasks/" -Method Get
```

## 7. Backup và restore database

### Backup trên PowerShell

```powershell
.\scripts\backup-db.ps1
```

### Restore trên PowerShell

```powershell
.\scripts\restore-db.ps1 -File .\backups\taskdb_YYYYMMDD_HHMMSS.sql
```

### Backup trên Linux/macOS

```bash
scripts/backup-db.sh docker-compose.prod.yml
```

### Restore trên Linux/macOS

```bash
scripts/restore-db.sh backups/taskdb_YYYYMMDD_HHMMSS.sql docker-compose.prod.yml
```

Lưu ý: Docker volume giúp dữ liệu tồn tại sau khi xóa container, nhưng volume không thay thế chiến lược backup.

## 8. CI/CD với GitHub Actions

Workflow nằm tại:

```text
.github/workflows/docker-ci.yml
```

Khi push code lên nhánh `main`, workflow sẽ:

```text
checkout source
  -> cp .env.example .env
  -> docker compose -f docker-compose.prod.yml build
  -> docker compose -f docker-compose.prod.yml up -d
  -> chạy scripts/smoke-test.sh
  -> docker compose down -v
```

Nếu build hoặc smoke test lỗi, CI báo fail.

## 9. Các lệnh kiểm tra hữu ích

```bash
docker compose -f docker-compose.prod.yml ps
docker compose -f docker-compose.prod.yml logs backend
docker compose -f docker-compose.prod.yml exec backend getent hosts db
docker compose -f docker-compose.prod.yml exec backend nc -zv db 5432
docker stats
```

Vào PostgreSQL:

```bash
docker compose -f docker-compose.prod.yml exec db psql -U taskuser -d taskdb
```

Trong PostgreSQL:

```sql
\dt
SELECT * FROM tasks_task;
\q
```

## 10. Cấu trúc thư mục sau nâng cấp

```text
Source_Docker_Task_Manager/
├── .github/workflows/docker-ci.yml
├── backend/
│   ├── Dockerfile
│   ├── Dockerfile.prod
│   ├── entrypoint.sh
│   ├── entrypoint-prod.sh
│   ├── healthcheck.py
│   ├── manage.py
│   ├── requirements.txt
│   ├── config/
│   └── tasks/
├── frontend/
│   ├── Dockerfile
│   ├── nginx.conf
│   ├── package.json
│   └── src/
├── scripts/
│   ├── smoke-test.ps1
│   ├── smoke-test.sh
│   ├── backup-db.ps1
│   ├── backup-db.sh
│   ├── restore-db.ps1
│   └── restore-db.sh
├── exercises/
├── docker-compose.yml
├── docker-compose.prod.yml
├── .env.example
├── .gitignore
└── README.md
```

## 11. Ghi chú khi nộp bài

Không nộp các thư mục sinh tự động như `node_modules`, `venv`, `__pycache__`, `dist`, `build`, file `.env` thật hoặc file video trực tiếp trong file nén. Video demo nên upload riêng và chèn link vào `readme.txt` theo yêu cầu đề.
