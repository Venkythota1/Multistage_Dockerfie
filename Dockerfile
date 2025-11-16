# Stage 1: Builder - using Chainguard Python image
FROM cgr.dev/chainguard/python:latest AS builder

WORKDIR /build

# Copy requirements and install dependencies to a virtual environment
COPY requirements.txt .

RUN python -m venv /build/venv && \
    /build/venv/bin/pip install --no-cache-dir --upgrade pip && \
    /build/venv/bin/pip install --no-cache-dir -r requirements.txt


# Stage 2: Runtime - using minimal Chainguard Python image
FROM cgr.dev/chainguard/python:latest

WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /build/venv /venv

# Copy application code
COPY ./app /app

# Set environment variables
ENV PATH="/venv/bin:$PATH" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Create non-root user for security
USER nonroot

# Expose port for FastAPI
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')" || exit 1

# Run FastAPI application with Uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
