// frontend/src/api/client.js
import axios from "axios";

const api = axios.create({
  baseURL: "/api",
  timeout: 10000,
  headers: { "Content-Type": "application/json" },
});

export const taskAPI = {
  getAll:   (params) => api.get("/tasks", { params }),
  getOne:   (id)     => api.get(`/tasks/${id}`),
  create:   (data)   => api.post("/tasks", data),
  update:   (id, data) => api.put(`/tasks/${id}`, data),
  delete:   (id)     => api.delete(`/tasks/${id}`),
  getAudit: (id)     => api.get(`/tasks/${id}/audit`),
};

export const userAPI = {
  getAll:  ()     => api.get("/users"),
  create:  (data) => api.post("/users", data),
  getOne:  (id)   => api.get(`/users/${id}`),
};

export const statsAPI = {
  get: () => api.get("/stats"),
};

export default api;
