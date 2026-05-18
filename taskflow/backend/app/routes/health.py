"""backend/app/routes/health.py"""
import os
from flask import Blueprint, jsonify, current_app
from .. import db

health_bp = Blueprint("health", __name__)

@health_bp.route("/health")
def health():
    return jsonify({"status": "healthy", "version": os.getenv("APP_VERSION", "1.0.0")}), 200

@health_bp.route("/ready")
def ready():
    try:
        db.session.execute(db.text("SELECT 1"))
        db_status = "connected"
    except Exception as e:
        return jsonify({"status": "not ready", "db": str(e)}), 503

    try:
        r = current_app.config["REDIS_CLIENT"]
        r.ping()
        redis_status = "connected"
    except Exception:
        redis_status = "unavailable"

    return jsonify({"status": "ready", "db": db_status, "redis": redis_status}), 200

@health_bp.route("/")
def index():
    return jsonify({"app": "TaskFlow API", "version": os.getenv("APP_VERSION", "1.0.0")}), 200
