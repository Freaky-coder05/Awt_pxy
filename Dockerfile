# Use a lightweight Alpine Linux image with Python
FROM python:3.10-alpine

# Install necessary build dependencies
RUN apk add --no-cache git gcc musl-dev libffi-dev

# Clone the lightweight Python MTProto Proxy repository
RUN git clone https://github.com/alexbers/mtprotoproxy.git /app
WORKDIR /app

# Install high-performance cryptography modules
RUN pip install cryptography uvloop

# Create a startup script to link Koyeb environment variables to the proxy config
RUN echo "import os" > start.py && \
    echo "port = int(os.environ.get('PORT', 8080))" >> start.py && \
    echo "secret = 'a1b2c3d4e5f678901a2b3c4d5e6f7a8b'" >> start.py && \
    echo "with open('config.py', 'w') as f:" >> start.py && \
    echo "    f.write(f'PORT = {port}\\n')" >> start.py && \
    echo "    f.write(f\"USERS = {{'koyeb_user': '{secret}'}}\\n\")" >> start.py && \
    echo "os.execvp('python', ['python', 'mtprotoproxy.py'])" >> start.py

# Expose the port
EXPOSE 8080

# Start the proxy dynamically
CMD ["python", "start.py"]
