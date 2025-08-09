# Base Build Stage
FROM python:3.11-alpine3.21

RUN mkdir /app

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1 

RUN pip install --upgrade pip

COPY requirements.txt  ./

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
