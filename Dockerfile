# ----------- Stage 1: Builder ----------- #
FROM python:3.9-slim as builder

WORKDIR /app

# Install build dependencies
COPY app/requirements.txt .
RUN pip install --upgrade pip && pip install --prefix=/install -r requirements.txt

# ----------- Stage 2: Runtime ----------- #
FROM python:3.9-slim

WORKDIR /app

# Copy only necessary files from builder
COPY --from=builder /install /usr/local
COPY app/ .

# Add healthcheck
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD curl --fail http://localhost:5000/health || exit 1

CMD ["python", "app.py"]
