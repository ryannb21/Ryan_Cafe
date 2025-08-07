FROM python:3.11-slim

#Installing only the Python dependencies
WORKDIR /app
COPY app/ryan_cafe_app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt gunicorn

#Copying the app resources
COPY app/ryan_cafe_app/ .

EXPOSE 5000
CMD [ "gunicorn", "--bind", "0.0.0.0:5000", "app:app" ]