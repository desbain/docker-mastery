from flask import Flask, jsonify
import os
import socket
import platform

app = Flask(__name__)

@app.route("/")
def home():
    return jsonify({
        "app":         "Docker Mastery — George Awa",
        "version":     os.getenv("APP_VERSION", "1.0.0"),
        "environment": os.getenv("APP_ENV", "development"),
        "hostname":    socket.gethostname(),
        "platform":    platform.system(),
    })

@app.route("/health")
def health():
    return jsonify({"status": "healthy"}), 200

@app.route("/ready")
def ready():
    return jsonify({"status": "ready"}), 200

@app.route("/info")
def info():
    return jsonify({
        "python":   platform.python_version(),
        "hostname": socket.gethostname(),
        "os":       platform.system(),
        "env":      os.getenv("APP_ENV", "development"),
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)  # nosec B104
