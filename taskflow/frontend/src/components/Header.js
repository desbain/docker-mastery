// frontend/src/components/Header.js
export default function Header({
  view, setView, onNewTask,
  filterStatus, setFilterStatus,
  filterPriority, setFilterPriority,
}) {
  return (
    <header className="header">
      <div className="header-left">
        <div className="logo">
          <span className="logo-icon">⚡</span>
          <span className="logo-text">TaskFlow</span>
          <span className="logo-sub">DevSecOps Task Manager</span>
        </div>
      </div>
      <nav className="header-nav">
        <button
          className={`nav-btn ${view === "board" ? "active" : ""}`}
          onClick={() => setView("board")}
        >📋 Board</button>
        <button
          className={`nav-btn ${view === "dashboard" ? "active" : ""}`}
          onClick={() => setView("dashboard")}
        >📊 Dashboard</button>
      </nav>
      <div className="header-right">
        <select
          className="filter-select"
          value={filterStatus}
          onChange={e => setFilterStatus(e.target.value)}
        >
          <option value="">All Statuses</option>
          <option value="backlog">Backlog</option>
          <option value="in_progress">In Progress</option>
          <option value="in_review">In Review</option>
          <option value="done">Done</option>
        </select>
        <select
          className="filter-select"
          value={filterPriority}
          onChange={e => setFilterPriority(e.target.value)}
        >
          <option value="">All Priorities</option>
          <option value="critical">Critical</option>
          <option value="high">High</option>
          <option value="medium">Medium</option>
          <option value="low">Low</option>
        </select>
        <button className="btn-primary" onClick={onNewTask}>+ New Task</button>
      </div>
    </header>
  );
}
