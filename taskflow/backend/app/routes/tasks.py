"""backend/app/routes/tasks.py — full CRUD for tasks"""
from datetime import datetime
from flask import Blueprint, jsonify, request, current_app
from .. import db
from ..models import Task, AuditLog

tasks_bp = Blueprint("tasks", __name__)

VALID_STATUSES   = ["backlog", "in_progress", "in_review", "done"]
VALID_PRIORITIES = ["low", "medium", "high", "critical"]


def _log(task_id, action, field=None, old=None, new=None, user=None):
    db.session.add(AuditLog(
        task_id=task_id, action=action, field=field,
        old_value=str(old) if old else None,
        new_value=str(new) if new else None,
        user_name=user or "system"
    ))


def _invalidate_cache():
    try:
        r = current_app.config["REDIS_CLIENT"]
        for key in r.scan_iter("taskflow:*"):
            r.delete(key)
    except Exception:
        pass


def _get_cached(key):
    try:
        import json
        r = current_app.config["REDIS_CLIENT"]
        data = r.get(key)
        return json.loads(data) if data else None
    except Exception:
        return None


def _set_cache(key, data, ttl=30):
    try:
        import json
        r = current_app.config["REDIS_CLIENT"]
        r.setex(key, ttl, json.dumps(data))
    except Exception:
        pass


@tasks_bp.route("", methods=["GET"])
def list_tasks():
    status   = request.args.get("status")
    priority = request.args.get("priority")
    cache_key = f"taskflow:tasks:{status or 'all'}:{priority or 'all'}"

    cached = _get_cached(cache_key)
    if cached:
        return jsonify({"tasks": cached, "count": len(cached), "cached": True})

    q = Task.query.order_by(Task.created_at.desc())
    if status:
        q = q.filter_by(status=status)
    if priority:
        q = q.filter_by(priority=priority)

    tasks = [t.to_dict() for t in q.all()]
    _set_cache(cache_key, tasks)
    return jsonify({"tasks": tasks, "count": len(tasks), "cached": False})


@tasks_bp.route("/<int:task_id>", methods=["GET"])
def get_task(task_id):
    task = Task.query.get_or_404(task_id)
    return jsonify(task.to_dict())


@tasks_bp.route("", methods=["POST"])
def create_task():
    data = request.get_json(silent=True) or {}
    if not data.get("title"):
        return jsonify({"error": "title is required"}), 400
    if not data.get("created_by_id"):
        return jsonify({"error": "created_by_id is required"}), 400

    task = Task(
        title          = data["title"][:256],
        description    = data.get("description", "")[:2000],
        status         = data.get("status", "backlog"),
        priority       = data.get("priority", "medium"),
        assigned_to_id = data.get("assigned_to_id"),
        created_by_id  = data["created_by_id"],
        due_date       = datetime.fromisoformat(data["due_date"])
                         if data.get("due_date") else None,
    )
    db.session.add(task)
    db.session.flush()
    _log(task.id, "CREATE", user=str(data.get("created_by_id")))
    db.session.commit()
    _invalidate_cache()
    return jsonify(task.to_dict()), 201


@tasks_bp.route("/<int:task_id>", methods=["PUT"])
def update_task(task_id):
    task = Task.query.get_or_404(task_id)
    data = request.get_json(silent=True) or {}
    user = str(data.get("updated_by_id", "unknown"))

    updatable = {
        "title": 256, "description": 2000,
        "status": None, "priority": None,
        "assigned_to_id": None, "due_date": None,
    }

    for field, maxlen in updatable.items():
        if field not in data:
            continue
        old_val = getattr(task, field)
        new_val = data[field]

        if field == "status" and new_val not in VALID_STATUSES:
            return jsonify({"error": f"invalid status: {new_val}"}), 400
        if field == "priority" and new_val not in VALID_PRIORITIES:
            return jsonify({"error": f"invalid priority: {new_val}"}), 400
        if field == "due_date":
            new_val = datetime.fromisoformat(new_val) if new_val else None
        if maxlen and isinstance(new_val, str):
            new_val = new_val[:maxlen]

        if old_val != new_val:
            _log(task_id, "UPDATE", field=field, old=old_val, new=new_val, user=user)
            setattr(task, field, new_val)

    db.session.commit()
    _invalidate_cache()
    return jsonify(task.to_dict())


@tasks_bp.route("/<int:task_id>", methods=["DELETE"])
def delete_task(task_id):
    task = Task.query.get_or_404(task_id)
    _log(task_id, "DELETE", user="system")
    db.session.commit()
    db.session.delete(task)
    db.session.commit()
    _invalidate_cache()
    return jsonify({"message": f"task {task_id} deleted"}), 200


@tasks_bp.route("/<int:task_id>/audit", methods=["GET"])
def task_audit(task_id):
    logs = AuditLog.query.filter_by(task_id=task_id)\
                         .order_by(AuditLog.timestamp.desc()).all()
    return jsonify({"logs": [l.to_dict() for l in logs]})
