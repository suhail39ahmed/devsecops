FROM python:3.11-slim-bookworm

# Set work directory
WORKDIR /app

# Install system dependencies for psycopg2 and others
RUN apt-get update && apt-get install --no-install-recommends -y \
    dnsutils \
    libpq-dev \
    python3-dev \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Upgrade pip to a stable version
RUN python -m pip install --no-cache-dir --upgrade pip

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . /app/

# Run DB migrations (can also be handled at container startup instead of build time)
RUN python3 /app/manage.py migrate

# Expose port
EXPOSE 8000

# Switch to app directory
WORKDIR /app/pygoat/

# Run app with Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "6", "pygoat.wsgi"]
