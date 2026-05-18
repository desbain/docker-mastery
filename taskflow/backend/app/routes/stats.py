"""backend/app/routes/stats.py — dashboard statistics"""
from flask import Blueprint, jsonify, current_app
from .. import db
from ..models import Task, User, AuditLog

stats_bp = Blueprint("stats", __name__)

@stats_bp.route("", methods=["GET"])
def get_stats():
    try:
        import json
        r = current_app.config["REDIS_CLIENT"]
        cached = r.get("taskflow:stats")
        if cached:
            return jsonify({**json.loads(cached), "cached": True})
    except Exception:
        pass

    total      = Task.query.count()
    backlog    = Task.query.filter_by(status="backlog").count()
    in_progress = Task.query.filter_by(status="in_progress").count()
    in_review  = Task.query.filter_by(status="in_review").count()
    done       = Task.query.filter_by(status="done").count()
    critical   = Task.query.filter_by(priority="critical").count()
    high       = Task.query.filter_by(priority="high").count()
    users      = User.query.count()

    recent_activity = AuditLog.query\
        .order_by(AuditLog.timestamp.desc()).limit(10).all()

    stats = {
        "total_tasks":    total,
        "by_status": {
            "backlog":     backlog,
            "in_progress": in_progress,
            "in_review":   in_review,
            "done":        done,
        },
        "by_priority": {
            "critical": critical,
            "high":     high,
        },
        "total_users":    users,
        "completion_rate": round((done / total * 100) if total > 0 else 0, 1),
        "recent_activity": [a.to_dict() for a in recent_activity],
        "cached": False,
    }

    try:
        import json
        r = current_app.config["REDIS_CLIENT"]
        r.setex("taskflow:stats", 15, json.dumps(
            {k: v for k, v in stats.items() if k != "cached"}
        ))
    except Exception:
        pass

    return jsonify(stats)
