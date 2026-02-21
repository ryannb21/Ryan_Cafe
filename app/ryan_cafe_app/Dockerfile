# syntax=docker/dockerfile:1

FROM python:3.12-slim@sha256:fa48eefe2146644c2308b909d6bb7651a768178f84fc9550dcd495e4d6d84d01 AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

#Creating a non-root user
RUN addgroup --system app && adduser --system --ingroup app app

#---------- WEB FRONTEND SECTION ----------
FROM base AS web_frontend

COPY services/web_frontend/requirements.txt /app/requirements.txt
RUN python -m pip install --upgrade pip \
 && pip install -r /app/requirements.txt gunicorn

COPY services/web_frontend/ /app/

#Setting Permissions & non-root access
RUN chown -R app:app /app
USER app

EXPOSE 5000
HEALTHCHECK --interval=30s --timeout=3s --start-period=20s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5000/health').read()" || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "--threads", "4", "--timeout", "60", "app:app"]


#---------- ORDERS SERVICE SECTION ----------
FROM base AS orders_service

COPY services/orders_service/requirements.txt /app/requirements.txt
RUN python -m pip install --upgrade pip \
 && pip install -r /app/requirements.txt gunicorn

COPY services/orders_service/ /app/

RUN chown -R app:app /app
USER app

EXPOSE 5001
HEALTHCHECK --interval=30s --timeout=3s --start-period=20s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:5001/health').read()" || exit 1

CMD ["gunicorn", "--bind", "0.0.0.0:5001", "--workers", "2", "--threads", "4", "--timeout", "60", "app:app"]
