# Changelog nâng cấp Đề tài 5

## File thêm mới

- `backend/Dockerfile.prod`: Dockerfile production cho Django backend.
- `backend/entrypoint-prod.sh`: chờ database, migrate, collectstatic và chạy Gunicorn.
- `backend/healthcheck.py`: kiểm tra backend health endpoint từ bên trong container.
- `docker-compose.prod.yml`: compose production, chỉ public frontend, backend/database chạy nội bộ.
- `scripts/smoke-test.ps1`: smoke test tự động trên Windows PowerShell.
- `scripts/smoke-test.sh`: smoke test tự động trên Linux/GitHub Actions.
- `scripts/backup-db.ps1`, `scripts/backup-db.sh`: backup PostgreSQL.
- `scripts/restore-db.ps1`, `scripts/restore-db.sh`: restore PostgreSQL.
- `.github/workflows/docker-ci.yml`: pipeline CI build, run và smoke test production stack.
- `.gitignore`: loại bỏ file sinh tự động và file nhạy cảm.
- `exercises/Bai_4_Smoke_Test_CICD.md`: bài tập mở rộng về kiểm thử deployment.

## File đã chỉnh sửa

- `.env.example`: bổ sung biến production, CSRF trusted origins, Gunicorn workers/timeout.
- `backend/config/settings.py`: bổ sung `STATIC_ROOT`, `CSRF_TRUSTED_ORIGINS`, `SECURE_PROXY_SSL_HEADER`.
- `docker-compose.yml`: thêm healthcheck, logging, depends_on theo health condition.
- `exercises/Bai_2_Compose_API_DB.md`: sửa minh họa để chạy trực tiếp với `./backend`.
- `README.md`: cập nhật hướng dẫn chạy development, production, smoke test, CI/CD, backup/restore.
- `readme.txt`: cập nhật hướng dẫn nộp và demo bản nâng cấp.

## Ý nghĩa nâng cấp

Bản cũ đáp ứng yêu cầu Dockerfile + Compose. Bản nâng cấp bổ sung góc nhìn triển khai thực tế: production server Gunicorn, reverse proxy, health monitoring, automated verification, CI/CD, log rotation và backup dữ liệu.
