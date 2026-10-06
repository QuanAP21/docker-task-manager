import React, { useEffect, useState } from 'react';
import { createRoot } from 'react-dom/client';
import './styles.css';

const API_URL = '/api/tasks/';

function App() {
  const [tasks, setTasks] = useState([]);
  const [title, setTitle] = useState('');
  const [description, setDescription] = useState('');
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState('');

  async function loadTasks() {
    setLoading(true);
    try {
      const res = await fetch(API_URL);
      const data = await res.json();
      setTasks(data);
    } catch (err) {
      setMessage('Không thể tải danh sách công việc.');
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => {
    loadTasks();
  }, []);

  async function createTask(e) {
    e.preventDefault();
    if (!title.trim()) {
      setMessage('Tiêu đề không được để trống.');
      return;
    }
    const res = await fetch(API_URL, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ title, description, is_done: false }),
    });
    if (res.ok) {
      setTitle('');
      setDescription('');
      setMessage('Đã thêm công việc mới.');
      loadTasks();
    } else {
      setMessage('Thêm công việc thất bại.');
    }
  }

  async function toggleTask(task) {
    await fetch(`${API_URL}${task.id}/`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ ...task, is_done: !task.is_done }),
    });
    loadTasks();
  }

  async function deleteTask(id) {
    await fetch(`${API_URL}${id}/`, { method: 'DELETE' });
    setMessage('Đã xóa công việc.');
    loadTasks();
  }

  return (
    <main className="page">
      <section className="hero">
        <p className="eyebrow">Docker Compose Demo</p>
        <h1>Task Manager</h1>
        <p>React frontend + Django REST API + PostgreSQL chạy bằng Docker.</p>
      </section>

      <section className="panel">
        <h2>Thêm công việc</h2>
        <form onSubmit={createTask} className="form">
          <input
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="Tiêu đề công việc"
          />
          <textarea
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Mô tả ngắn"
          />
          <button type="submit">Thêm task</button>
        </form>
        {message && <div className="message">{message}</div>}
      </section>

      <section className="panel">
        <div className="section-header">
          <h2>Danh sách công việc</h2>
          <button className="secondary" onClick={loadTasks}>Refresh</button>
        </div>
        {loading ? <p>Đang tải...</p> : null}
        <div className="task-list">
          {tasks.map((task) => (
            <article className={`task ${task.is_done ? 'done' : ''}`} key={task.id}>
              <div>
                <h3>{task.title}</h3>
                <p>{task.description || 'Không có mô tả'}</p>
              </div>
              <div className="actions">
                <button onClick={() => toggleTask(task)}>
                  {task.is_done ? 'Hoàn tác' : 'Hoàn thành'}
                </button>
                <button className="danger" onClick={() => deleteTask(task.id)}>Xóa</button>
              </div>
            </article>
          ))}
          {!tasks.length && !loading ? <p>Chưa có công việc nào.</p> : null}
        </div>
      </section>
    </main>
  );
}

createRoot(document.getElementById('root')).render(<App />);