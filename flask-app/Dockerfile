# Берем легкую версию Python
FROM python:3.9-slim

# Создаем рабочую папку внутри контейнера
WORKDIR /app

# Копируем зависимости и устанавливаем их
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Копируем сам код
COPY app.py .

# Открываем 80 порт
EXPOSE 80

# Запускаем приложение
CMD ["python", "app.py"]
