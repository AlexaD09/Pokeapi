import React, { useState } from "react";
import './App.css';
import Login from "./components/Login";
import Cards from "./components/Cards";
const BACKEND_URL = window.RUNTIME_CONFIG?.BACKEND_URL || "/api";

console.log("Backend URL:", BACKEND_URL);


function App() {
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [currentUser, setCurrentUser] = useState("");
  const [loginError, setLoginError] = useState("");
  
  // Login function
  const handleLogin = async (username, password) => {
    setLoginError("");
    try {
      const response = await fetch(`${BACKEND_URL}/login`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username, password }),
      });
      const result = await response.json();
      if (result.success) {
        setIsLoggedIn(true);
        setCurrentUser(username);
      } else {
        setLoginError(result.message || "Invalid credentials");
      }
    } catch (error) {
      setLoginError("Connection error");
    }
  };

  // Function to register user
  const handleRegister = async (username, password) => {
    try {
      const response = await fetch(`${BACKEND_URL}/register`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username, password }),
      });
      const result = await response.json();
      alert(result.message);
    } catch (error) {
      alert("Connection error");
    }
  };

  // Save search in PostgreSQL
  const saveSearchToDB = async (username, query) => {
    await fetch(`${BACKEND_URL}/save-search`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ username, query }),
    });
  };

  // Render component based on login status
  return (
    <div className="app-container">
      {isLoggedIn ? (
        <Cards
          currentUser={currentUser}
          onLogout={() => {
            setIsLoggedIn(false);
            setCurrentUser("");
          }}
          saveSearchToDB={saveSearchToDB}
        />
      ) : (
        <Login
          onLogin={handleLogin}
          onRegister={handleRegister}
          error={loginError}
        />
      )}
    </div>
  );
}

export default App;