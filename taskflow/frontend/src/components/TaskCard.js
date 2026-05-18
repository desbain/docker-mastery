// frontend/src/components/TaskCard.js

const PRIORITY_COLORS = {
  critical: { bg: "#450a0a", border: "#ef4444", text: "#fca5a5" },
  high:     { bg: "#431407", border: "#f97316", text: "#fdba74" },
  medium:   { bg: "#1c1917", border: "#eab308", text: "#fde047" },
  low:      { bg: "#052e16", border: "#22c55e", text: "#86efac" },
};

const NEXT_STATUS = {
  backlog: "in_progress",
  in_progress: "in_review",
  in_review: "done",
  done: "backlog",
};

const STATUS_LABELS = {
  backlog: "→ Start",
  in_progress: "→ Review",
  in_review: "→ Done",
  done: "→ Reopen",
};

export default function TaskCard({ task, onEdit, onDelete, onStatusChange }) {
  const p = PRIORITY_COLORS[task.priority] || PRIORITY_COLORS.medium;

  const isOverdue = task.due_date &&
    new Date(task.due_date) < new Date() &&
    task.status !== "done";

  return (
    <div
      className="task-card"
      style={{ borderLeft: `3px solid ${p.border}` }}
    >
      <div className="task-card-header">
        <span
          className="priority-badge"
          style={{ background: p.bg, color: p.text, border: `1px solid ${p.border}` }}
        >
          {task.priority.toUpperCase()}
        </span>
        <span className="task-id">#{task.id}</span>
      </div>

      <h3 className="task-title">{task.title}</h3>

      {task.description && (
        <p className="task-desc">{task.description.slice(0, 100)}
          {task.description.length > 100 ? "…" : ""}
        </p>
      )}

      {task.assigned_to && (
        <div className="task-assignee">
          <span className="avatar">{task.assigned_to.name[0]}</span>
          <span>{task.assigned_to.name}</span>
        </div>
      )}

      {task.due_date && (
        <div className={`task-due ${isOverdue ? "overdue" : ""}`}>
          📅 {new Date(task.due_date).toLocaleDateString()}
          {isOverdue && " — OVERDUE"}
        </div>
      )}

      <div className="task-actions">
        <button
          className="btn-move"
          onClick={() => onStatusChange(task.id, NEXT_STATUS[task.status])}
          title={`Move to ${NEXT_STATUS[task.status]}`}
        >
          {STATUS_LABELS[task.status]}
        </button>
        <button className="btn-edit"   onClick={() => onEdit(task)}>✏️</button>
        <button className="btn-delete" onClick={() => onDelete(task.id)}>🗑</button>
      </div>
    </div>
  );
}
