"""backend/app/routes/users.py"""
from flask import Blueprint, jsonify, request
from .. import db
from ..models import User

users_bp = Blueprint("users", __name__)

@users_bp.route("", methods=["GET"])
def list_users():
    users = User.query.order_by(User.name).all()
    return jsonify({"users": [u.to_dict() for u in users]})

@users_bp.route("", methods=["POST"])
def create_user():
    data = request.get_json(silent=True) or {}
    if not data.get("name") or not data.get("email"):
        return jsonify({"error": "name and email required"}), 400
    if User.query.filter_by(email=data["email"]).first():
        return jsonify({"error": "email already exists"}), 409
    user = User(
        name=data["name"][:128],
        email=data["email"][:256],
        role=data.get("role", "developer")
    )
    db.session.add(user)
    db.session.commit()
    return jsonify(user.to_dict()), 201

@users_bp.route("/<int:user_id>", methods=["GET"])
def get_user(user_id):
    user = User.query.get_or_404(user_id)
    return jsonify(user.to_dict())
