ĐỀ TÀI 5 - CONTAINERIZATION (DOCKER) AND DEPLOYMENT - BẢN NÂNG CẤP

Cách chạy bản production nâng cấp:
1. Mở terminal tại thư mục Source_Docker_Task_Manager
2. Chạy: cp .env.example .env
   PowerShell: Copy-Item .env.example .env
3. Chạy: docker compose -f docker-compose.prod.yml up --build -d
4. Mở: http://localhost:3000
5. Kiểm tra API qua Nginx: http://localhost:3000/api/tasks/
6. Xem container: docker compose -f docker-compose.prod.yml ps
7. Chạy smoke test PowerShell: .\scripts\smoke-test.ps1
8. Xem log: docker compose -f docker-compose.prod.yml logs backend
9. Dừng: docker compose -f docker-compose.prod.yml down
10. Xóa cả dữ liệu: docker compose -f docker-compose.prod.yml down -v

Nâng cấp đã thêm:
- Backend production bằng Gunicorn.
- docker-compose.prod.yml.
- Healthcheck cho db, backend, frontend.
- Frontend Nginx reverse proxy /api và /health sang backend.
- Backend không public port trong production, chỉ frontend public port 3000.
- Smoke test tự động bằng PowerShell và shell script.
- GitHub Actions CI kiểm tra Docker build + deployment.
- Script backup/restore PostgreSQL.
- Log rotation và giới hạn tài nguyên container.

Link video demo: DÁN LINK VIDEO DEMO CỦA NHÓM TẠI ĐÂY

Lưu ý: Không nộp kèm node_modules, venv, __pycache__, dist, build, .env thật hoặc file video trực tiếp trong file nén.
