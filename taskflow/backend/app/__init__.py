"""
backend/app/__init__.py
TaskFlow — Flask application factory
"""

import os
import json
import logging
from datetime import datetime

from flask import Flask, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_cors import CORS
import redis

# ── Extensions ────────────────────────────────────────────────────────────
db      = SQLAlchemy()
migrate = Migrate()

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(name)s %(message)s"
)
logger = logging.getLogger(__name__)


def get_secret(path: str, default: str = "") -> str:
    """Read Docker secret from /run/secrets/ or fall back to env var."""
    try:
        with open(f"/run/secrets/{path}") as f:
            return f.read().strip()
    except FileNotFoundError:
        return os.getenv(path.upper(), default)


def create_app() -> Flask:
    app = Flask(__name__)

    # ── Database config ───────────────────────────────────────────────────
    db_password = get_secret("db_password", "devpassword")
    db_host     = os.getenv("DB_HOST", "localhost")
    db_port     = os.getenv("DB_PORT", "5432")
    db_name     = os.getenv("DB_NAME", "taskflow")
    db_user     = os.getenv("DB_USER", "taskflow")

    app.config["SQLALCHEMY_DATABASE_URI"] = (
        f"postgresql://{db_user}:{db_password}@{db_host}:{db_port}/{db_name}"
    )
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    app.config["SQLALCHEMY_ENGINE_OPTIONS"] = {
        "pool_pre_ping":  True,
        "pool_recycle":   300,
        "connect_args":   {"connect_timeout": 5},
    }

    # ── Redis config ──────────────────────────────────────────────────────
    redis_host     = os.getenv("REDIS_HOST", "localhost")
    redis_port     = int(os.getenv("REDIS_PORT", "6379"))
    app.config["REDIS_CLIENT"] = redis.Redis(
        host=redis_host, port=redis_port,
        decode_responses=True, socket_connect_timeout=3
    )

    # ── Init extensions ───────────────────────────────────────────────────
    db.init_app(app)
    migrate.init_app(app, db)
    CORS(app, origins=["http://localhost:3000", "http://localhost:80",
                        "http://localhost"])

    # ── Register blueprints ───────────────────────────────────────────────
    from .routes.tasks   import tasks_bp
    from .routes.users   import users_bp
    from .routes.health  import health_bp
    from .routes.stats   import stats_bp

    app.register_blueprint(health_bp)
    app.register_blueprint(tasks_bp,  url_prefix="/api/tasks")
    app.register_blueprint(users_bp,  url_prefix="/api/users")
    app.register_blueprint(stats_bp,  url_prefix="/api/stats")

    # ── Create tables on first run ────────────────────────────────────────
    with app.app_context():
        try:
            db.create_all()
            _seed_initial_data()
            logger.info("Database ready")
        except Exception as e:
            logger.warning("DB not ready yet: %s", e)

    return app


def _seed_initial_data():
    """Seed initial users if none exist."""
    from .models import User, Task
    if User.query.count() == 0:
        users = [
            User(name="George Awa",    email="george@taskflow.io",  role="admin"),
            User(name="Alice Chen",    email="alice@taskflow.io",   role="developer"),
            User(name="Bob Martinez",  email="bob@taskflow.io",     role="developer"),
            User(name="Carol Smith",   email="carol@taskflow.io",   role="devops"),
        ]
        db.session.add_all(users)
        db.session.flush()

        tasks = [
            Task(title="Set up CI/CD pipeline",
                 description="Configure GitHub Actions with SAST, Trivy, and EKS deploy",
                 priority="critical", status="in_progress",
                 assigned_to_id=users[3].id, created_by_id=users[0].id),
            Task(title="Implement JWT authentication",
                 description="Add JWT-based auth to the Flask API",
                 priority="high", status="backlog",
                 assigned_to_id=users[1].id, created_by_id=users[0].id),
            Task(title="Write API documentation",
                 description="Document all REST endpoints with examples",
                 priority="medium", status="backlog",
                 assigned_to_id=users[2].id, created_by_id=users[0].id),
            Task(title="Set up monitoring stack",
                 description="Deploy Prometheus + Grafana + cAdvisor",
                 priority="high", status="in_review",
                 assigned_to_id=users[3].id, created_by_id=users[0].id),
            Task(title="Fix login page styling",
                 description="Align form elements on mobile screens",
                 priority="low", status="done",
                 assigned_to_id=users[1].id, created_by_id=users[1].id),
        ]
        db.session.add_all(tasks)
        db.session.commit()
        logger.info("Seeded initial data")
