import React, { useState } from "react";

function Register({ onRegister }) {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  const handleSubmit = (e) => {
    e.preventDefault();
    onRegister(username, password);
  };

  return (
    <div style={{ padding: "50px", textAlign: "center", fontFamily: "sans-serif" }}>
      <h1>📝 Register</h1>
      <div style={{ maxWidth: "300px", margin: "0 auto", padding: "20px", border: "1px solid #ccc", borderRadius: "8px" }}>
        <form onSubmit={handleSubmit}>
          <input
            type="text"
            placeholder="User"
            style={{ width: "100%", padding: "10px", marginBottom: "10px" }}
            value={username}
            onChange={(e) => setUsername(e.target.value)}
          />
          <input
            type="password"
            placeholder="Password"
            style={{ width: "100%", padding: "10px", marginBottom: "10px" }}
            value={password}
            onChange={(e) => setPassword(e.target.value)}
          />
          <button
            type="submit"
            style={{ width: "100%", padding: "10px", backgroundColor: "#28a745", color: "white", border: "none", borderRadius: "4px" }}
          >
            Register
          </button>
        </form>
      </div>
    </div>
  );
}

export default Register;