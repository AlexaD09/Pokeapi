import React, { useState } from "react";
import "../App.css";

function Login({ onLogin, onRegister, error }) {
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");

  return (
    <div className="auth-container">
      <h1>🔐 Pokémon</h1>
      <form
        onSubmit={(e) => {
          e.preventDefault();
          onLogin(username, password);
        }}
      >
        <input
          type="text"
          className="auth-input"
          placeholder="Username"
          value={username}
          onChange={(e) => setUsername(e.target.value)}
        />
        <input
          type="password"
          className="auth-input"
          placeholder="Password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
        />
        <button type="submit" className="auth-button login">
          Login
        </button>
      </form>

      <button
        onClick={() => onRegister(username, password)}
        className="auth-button register"
      >
        Register
      </button>

      {error && <p className="error-text">{error}</p>}
    </div>
  );
}

export default Login;
