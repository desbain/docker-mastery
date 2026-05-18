// frontend/src/components/Dashboard.js
export default function Dashboard({ stats, tasks }) {
  if (!stats) return <div className="loading"><p>Loading stats...</p></div>;

  const statCards = [
    { label: "Total Tasks",      value: stats.total_tasks,    color: "#3b82f6", icon: "📋" },
    { label: "In Progress",      value: stats.by_status.in_progress, color: "#f59e0b", icon: "🔄" },
    { label: "In Review",        value: stats.by_status.in_review, color: "#8b5cf6", icon: "👁" },
    { label: "Done",             value: stats.by_status.done, color: "#10b981", icon: "✅" },
    { label: "Critical Tasks",   value: stats.by_priority.critical, color: "#ef4444", icon: "🚨" },
    { label: "Completion Rate",  value: `${stats.completion_rate}%`, color: "#06b6d4", icon: "📈" },
  ];

  return (
    <div className="dashboard">
      <h2 className="dashboard-title">📊 Dashboard</h2>

      <div className="stat-grid">
        {statCards.map(card => (
          <div key={card.label} className="stat-card" style={{ borderTop: `3px solid ${card.color}` }}>
            <div className="stat-icon">{card.icon}</div>
            <div className="stat-value" style={{ color: card.color }}>{card.value}</div>
            <div className="stat-label">{card.label}</div>
          </div>
        ))}
      </div>

      <div className="dashboard-bottom">
        <div className="status-bar-section">
          <h3>Task Distribution</h3>
          <div className="status-bars">
            {Object.entries(stats.by_status).map(([status, count]) => (
              <div key={status} className="status-bar-row">
                <span className="status-bar-label">{status.replace("_", " ")}</span>
                <div className="status-bar-track">
                  <div
                    className="status-bar-fill"
                    style={{
                      width: stats.total_tasks
                        ? `${(count / stats.total_tasks) * 100}%`
                        : "0%",
                      background: {
                        backlog: "#64748b",
                        in_progress: "#3b82f6",
                        in_review: "#f59e0b",
                        done: "#10b981",
                      }[status],
                    }}
                  />
                </div>
                <span className="status-bar-count">{count}</span>
              </div>
            ))}
          </div>
        </div>

        <div className="activity-section">
          <h3>Recent Activity</h3>
          <div className="activity-list">
            {stats.recent_activity.length === 0 ? (
              <p className="no-activity">No recent activity</p>
            ) : (
              stats.recent_activity.map(log => (
                <div key={log.id} className="activity-item">
                  <span className="activity-action">{log.action}</span>
                  {log.field && (
                    <span className="activity-detail">
                      {log.field}: {log.old_value} → {log.new_value}
                    </span>
                  )}
                  <span className="activity-time">
                    {new Date(log.timestamp).toLocaleString()}
                  </span>
                </div>
              ))
            )}
          </div>
        </div>
      </div>
    </div>
  );
}
