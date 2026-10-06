set -e

echo "Waiting for database at ${DB_HOST}:${DB_PORT}..."
while ! nc -z "$DB_HOST" "$DB_PORT"; do
  sleep 1
done

echo "Database is ready. Running migrations..."
python manage.py migrate --noinput

echo "Starting Django server..."
python manage.py runserver 0.0.0.0:8000
