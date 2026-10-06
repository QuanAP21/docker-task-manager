# Bài 4 mở rộng - Smoke Test và CI/CD cho Docker Deployment

## Đề bài
Sau khi triển khai hệ thống bằng Docker Compose, hãy viết một script tự động kiểm tra các điểm quan trọng của deployment: container chạy, database healthy, frontend truy cập được, backend health endpoint hoạt động, CRUD API hoạt động và các service giao tiếp được bằng service name.

## Lời giải minh họa
Trong project này, nhóm bổ sung hai script:

```text
scripts/smoke-test.ps1   # chạy trên Windows PowerShell
scripts/smoke-test.sh    # chạy trên Linux/GitHub Actions
```

Chạy bản production:

```powershell
docker compose -f docker-compose.prod.yml up --build -d
```

Chạy smoke test trên PowerShell:

```powershell
.\scripts\smoke-test.ps1
```

Kết quả kỳ vọng:

```text
[PASS] PostgreSQL service is healthy
[PASS] Backend internal healthcheck passes
[PASS] Frontend is reachable
[PASS] GET /api/tasks/ via frontend reverse proxy
[PASS] POST /api/tasks/ creates task
[PASS] PUT /api/tasks/{id}/ updates task
[PASS] DELETE /api/tasks/{id}/ deletes task
SYSTEM STATUS: HEALTHY
```

## GitHub Actions
File `.github/workflows/docker-ci.yml` tự động build production stack, chạy container và gọi `scripts/smoke-test.sh`. Nếu một bước lỗi, workflow báo fail. Đây là cách kiểm tra deployment tự động trước khi nộp hoặc trước khi đưa lên server.