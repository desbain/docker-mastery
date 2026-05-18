// frontend/src/components/TaskBoard.js
import TaskCard from "./TaskCard";

const COLUMNS = [
  { id: "backlog",     label: "📥 Backlog",     color: "#64748b" },
  { id: "in_progress", label: "🔄 In Progress", color: "#3b82f6" },
  { id: "in_review",   label: "👁 In Review",   color: "#f59e0b" },
  { id: "done",        label: "✅ Done",         color: "#10b981" },
];

export default function TaskBoard({ tasks, onEdit, onDelete, onStatusChange }) {
  return (
    <div className="board">
      {COLUMNS.map(col => {
        const colTasks = tasks.filter(t => t.status === col.id);
        return (
          <div key={col.id} className="column">
            <div className="column-header" style={{ borderColor: col.color }}>
              <span className="column-title">{col.label}</span>
              <span className="column-count" style={{ background: col.color }}>
                {colTasks.length}
              </span>
            </div>
            <div className="column-body">
              {colTasks.length === 0 ? (
                <div className="empty-col">No tasks</div>
              ) : (
                colTasks.map(task => (
                  <TaskCard
                    key={task.id}
                    task={task}
                    onEdit={onEdit}
                    onDelete={onDelete}
                    onStatusChange={onStatusChange}
                  />
                ))
              )}
            </div>
          </div>
        );
      })}
    </div>
  );
}
