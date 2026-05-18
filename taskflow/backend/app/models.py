"""
backend/app/models.py
TaskFlow — SQLAlchemy models
"""

from datetime import datetime
from . import db


class User(db.Model):
    __tablename__ = "users"

    id         = db.Column(db.Integer, primary_key=True)
    name       = db.Column(db.String(128), nullable=False)
    email      = db.Column(db.String(256), unique=True, nullable=False)
    role       = db.Column(db.String(64), default="developer")
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    assigned_tasks = db.relationship("Task", foreign_keys="Task.assigned_to_id",
                                     backref="assigned_to", lazy="dynamic")
    created_tasks  = db.relationship("Task", foreign_keys="Task.created_by_id",
                                     backref="created_by", lazy="dynamic")

    def to_dict(self):
        return {
            "id":         self.id,
            "name":       self.name,
            "email":      self.email,
            "role":       self.role,
            "created_at": self.created_at.isoformat(),
        }


class Task(db.Model):
    __tablename__ = "tasks"

    id             = db.Column(db.Integer, primary_key=True)
    title          = db.Column(db.String(256), nullable=False)
    description    = db.Column(db.Text, default="")
    status         = db.Column(db.String(32), default="backlog")
    priority       = db.Column(db.String(32), default="medium")
    due_date       = db.Column(db.DateTime, nullable=True)
    assigned_to_id = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=True)
    created_by_id  = db.Column(db.Integer, db.ForeignKey("users.id"), nullable=False)
    created_at     = db.Column(db.DateTime, default=datetime.utcnow)
    updated_at     = db.Column(db.DateTime, default=datetime.utcnow,
                               onupdate=datetime.utcnow)

    audit_logs = db.relationship("AuditLog", backref="task", lazy="dynamic")

    def to_dict(self):
        return {
            "id":          self.id,
            "title":       self.title,
            "description": self.description,
            "status":      self.status,
            "priority":    self.priority,
            "due_date":    self.due_date.isoformat() if self.due_date else None,
            "assigned_to": self.assigned_to.to_dict() if self.assigned_to else None,
            "created_by":  self.created_by.to_dict() if self.created_by else None,
            "created_at":  self.created_at.isoformat(),
            "updated_at":  self.updated_at.isoformat(),
        }


class AuditLog(db.Model):
    __tablename__ = "audit_logs"

    id         = db.Column(db.Integer, primary_key=True)
    task_id    = db.Column(db.Integer, db.ForeignKey("tasks.id"), nullable=True)
    action     = db.Column(db.String(64), nullable=False)
    field      = db.Column(db.String(64), nullable=True)
    old_value  = db.Column(db.String(256), nullable=True)
    new_value  = db.Column(db.String(256), nullable=True)
    user_name  = db.Column(db.String(128), nullable=True)
    timestamp  = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id":        self.id,
            "task_id":   self.task_id,
            "action":    self.action,
            "field":     self.field,
            "old_value": self.old_value,
            "new_value": self.new_value,
            "user_name": self.user_name,
            "timestamp": self.timestamp.isoformat(),
        }
