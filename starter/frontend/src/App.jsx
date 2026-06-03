import { useEffect, useState } from "react";

// In the browser the API is reachable on localhost:8000 (published by compose).
const API = import.meta.env.VITE_API_URL || "http://localhost:8000";

export default function App() {
  const [notes, setNotes] = useState([]);
  const [body, setBody] = useState("");
  const [error, setError] = useState("");

  const load = () =>
    fetch(`${API}/api/notes`)
      .then((r) => r.json())
      .then(setNotes)
      .catch(() => setError("Could not reach the API"));

  useEffect(() => {
    load();
  }, []);

  const add = () => {
    if (!body.trim()) return;
    fetch(`${API}/api/notes`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ body }),
    })
      .then(() => {
        setBody("");
        load();
      })
      .catch(() => setError("Could not save"));
  };

  return (
    <div style={{ fontFamily: "system-ui", maxWidth: 480, margin: "60px auto" }}>
      <h1>3-Tier Starter</h1>
      <p>React → FastAPI → Postgres, all in containers.</p>
      <div style={{ display: "flex", gap: 8 }}>
        <input
          value={body}
          onChange={(e) => setBody(e.target.value)}
          placeholder="Write a note"
          style={{ flex: 1, padding: 8 }}
        />
        <button onClick={add} style={{ padding: "8px 16px" }}>
          Add
        </button>
      </div>
      {error && <p style={{ color: "crimson" }}>{error}</p>}
      <ul>
        {notes.map((n) => (
          <li key={n.id}>{n.body}</li>
        ))}
      </ul>
    </div>
  );
}
