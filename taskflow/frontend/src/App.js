// frontend/src/App.js
import { useState, useEffect } from "react";
import Dashboard from "./components/Dashboard";
import TaskBoard from "./components/TaskBoard";
import TaskModal from "./components/TaskModal";
import Header from "./components/Header";
import { taskAPI, userAPI, statsAPI } from "./api/client";
import "./App.css";

export default function App() {
  const [view,       setView]       = useState("board");
  const [tasks,      setTasks]      = useState([]);
  const [users,      setUsers]      = useState([]);
  const [stats,      setStats]      = useState(null);
  const [loading,    setLoading]    = useState(true);
  const [error,      setError]      = useState(null);
  const [modalOpen,  setModalOpen]  = useState(false);
  const [editTask,   setEditTask]   = useState(null);
  const [filterStatus,   setFilterStatus]   = useState("");
  const [filterPriority, setFilterPriority] = useState("");

  const loadData = async () => {
    try {
      setLoading(true);
      setError(null);
      const params = {};
      if (filterStatus)   params.status   = filterStatus;
      if (filterPriority) params.priority = filterPriority;

      const [tasksRes, usersRes, statsRes] = await Promise.all([
        taskAPI.getAll(params),
        userAPI.getAll(),
        statsAPI.get(),
      ]);
      setTasks(tasksRes.data.tasks);
      setUsers(usersRes.data.users);
      setStats(statsRes.data);
    } catch (e) {
      setError("Failed to connect to API. Is the backend running?");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => { loadData(); }, [filterStatus, filterPriority]);

  const handleCreate = () => { setEditTask(null); setModalOpen(true); };
  const handleEdit   = (task) => { setEditTask(task); setModalOpen(true); };
  const handleDelete = async (id) => {
    if (!window.confirm("Delete this task?")) return;
    await taskAPI.delete(id);
    loadData();
  };
  const handleStatusChange = async (id, status) => {
    await taskAPI.update(id, { status, updated_by_id: 1 });
    loadData();
  };
  const handleSave = async (data) => {
    if (editTask) {
      await taskAPI.update(editTask.id, { ...data, updated_by_id: 1 });
    } else {
      await taskAPI.create({ ...data, created_by_id: 1 });
    }
    setModalOpen(false);
    loadData();
  };

  return (
    <div className="app">
      <Header
        view={view} setView={setView}
        onNewTask={handleCreate}
        filterStatus={filterStatus}   setFilterStatus={setFilterStatus}
        filterPriority={filterPriority} setFilterPriority={setFilterPriority}
      />
      <main className="main">
        {error && <div className="error-banner">{error}</div>}
        {loading ? (
          <div className="loading">
            <div className="spinner" />
            <p>Loading TaskFlow...</p>
          </div>
        ) : view === "dashboard" ? (
          <Dashboard stats={stats} tasks={tasks} />
        ) : (
          <TaskBoard
            tasks={tasks}
            onEdit={handleEdit}
            onDelete={handleDelete}
            onStatusChange={handleStatusChange}
          />
        )}
      </main>
      {modalOpen && (
        <TaskModal
          task={editTask}
          users={users}
          onSave={handleSave}
          onClose={() => setModalOpen(false)}
        />
      )}
    </div>
  );
}
