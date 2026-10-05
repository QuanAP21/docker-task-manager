# Bài 1 - Viết Dockerfile cho web app đơn giản

## Đề bài
Viết Dockerfile cho một web app Python/Django và chạy container ở cổng host 8080.

## Lời giải minh họa

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
```

Build image:

```bash
docker build -t simple-backend .
```

Run container:

```bash
docker run --name simple_backend -p 8080:8000 simple-backend
```

Kiểm tra từ máy host:

```text
http://localhost:8080
```

Giải thích: `8080:8000` nghĩa là cổng 8080 của host được ánh xạ vào cổng 8000 trong container.
