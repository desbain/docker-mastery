// frontend/src/components/TaskModal.js
import { useState } from "react";

export default function TaskModal({ task, users, onSave, onClose }) {
  const [form, setForm] = useState({
    title:          task?.title          || "",
    description:    task?.description    || "",
    status:         task?.status         || "backlog",
    priority:       task?.priority       || "medium",
    assigned_to_id: task?.assigned_to?.id || "",
    due_date:       task?.due_date
      ? new Date(task.due_date).toISOString().split("T")[0]
      : "",
  });
  const [saving, setSaving] = useState(false);
  const [error,  setError]  = useState("");

  const handle = e => setForm(f => ({ ...f, [e.target.name]: e.target.value }));

  const submit = async e => {
    e.preventDefault();
    if (!form.title.trim()) { setError("Title is required"); return; }
    setSaving(true);
    try {
      await onSave({
        ...form,
        assigned_to_id: form.assigned_to_id || null,
        due_date:       form.due_date || null,
      });
    } catch (err) {
      setError(err.response?.data?.error || "Save failed");
      setSaving(false);
    }
  };

  return (
    <div className="modal-overlay" onClick={e => e.target === e.currentTarget && onClose()}>
      <div className="modal">
        <div className="modal-header">
          <h2>{task ? "Edit Task" : "New Task"}</h2>
          <button className="modal-close" onClick={onClose}>✕</button>
        </div>

        <form onSubmit={submit} className="modal-form">
          {error && <div className="form-error">{error}</div>}

          <label>Title *
            <input
              name="title" value={form.title} onChange={handle}
              placeholder="What needs to be done?" required
            />
          </label>

          <label>Description
            <textarea
              name="description" value={form.description} onChange={handle}
              placeholder="Add more details..." rows={3}
            />
          </label>

          <div className="form-row">
            <label>Status
              <select name="status" value={form.status} onChange={handle}>
                <option value="backlog">Backlog</option>
                <option value="in_progress">In Progress</option>
                <option value="in_review">In Review</option>
                <option value="done">Done</option>
              </select>
            </label>
            <label>Priority
              <select name="priority" value={form.priority} onChange={handle}>
                <option value="low">Low</option>
                <option value="medium">Medium</option>
                <option value="high">High</option>
                <option value="critical">Critical</option>
              </select>
            </label>
          </div>

          <div className="form-row">
            <label>Assign To
              <select name="assigned_to_id" value={form.assigned_to_id} onChange={handle}>
                <option value="">Unassigned</option>
                {users.map(u => (
                  <option key={u.id} value={u.id}>{u.name} ({u.role})</option>
                ))}
              </select>
            </label>
            <label>Due Date
              <input
                type="date" name="due_date"
                value={form.due_date} onChange={handle}
              />
            </label>
          </div>

          <div className="modal-footer">
            <button type="button" className="btn-secondary" onClick={onClose}>
              Cancel
            </button>
            <button type="submit" className="btn-primary" disabled={saving}>
              {saving ? "Saving..." : task ? "Update Task" : "Create Task"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
