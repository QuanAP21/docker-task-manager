# Bài 3 - Quy trình deploy bằng Docker

## Đề bài
Mô tả quy trình deploy một ứng dụng gồm `api` và `db` bằng Docker trên server Linux.

## Lời giải minh họa

1. Chuẩn bị server Ubuntu.
2. Cài Docker và Docker Compose.
3. Clone source code hoặc pull image từ registry.
4. Tạo file `.env` chứa biến môi trường production.
5. Chạy hệ thống:

```bash
docker compose up -d
```

6. Kiểm tra container:

```bash
docker compose ps
```

7. Kiểm tra log:

```bash
docker compose logs api
```

8. Kiểm tra API:

```bash
curl http://localhost:8000/health/
```

9. Cấu hình reverse proxy nếu cần public domain.

## Kết luận
Docker giúp quy trình deploy lặp lại được, dễ kiểm tra và ít phụ thuộc vào cấu hình thủ công trên server.
