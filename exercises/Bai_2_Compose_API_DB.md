# Bài 2 - Docker Compose cho API và Database

## Đề bài
Dùng Docker Compose tạo 2 service: `api` và `db`. Service `api` phải đọc biến môi trường `DB_HOST`, `DB_PORT` và kết nối tới database bằng service name.

## Lời giải minh họa

```yaml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: demo
      POSTGRES_USER: demo
      POSTGRES_PASSWORD: demo

  api:
    build: ./backend
    environment:
      DB_HOST: db
      DB_PORT: 5432
    depends_on:
      - db
    ports:
      - "8000:8000"
```

## Giải thích
Trong network mặc định của Docker Compose, container `api` có thể gọi database bằng hostname `db` vì `db` là tên service. Không dùng `localhost` vì `localhost` bên trong container `api` trỏ về chính container `api`, không phải container database.


## Ghi chú nâng cấp
Trong source demo thực tế, nhóm đặt service tên `backend` nhưng ý nghĩa tương đương `api`. Để chạy trực tiếp với project này, dùng `build: ./backend` thay vì `build: ./api`.
