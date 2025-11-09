import React, { useEffect, useState } from "react";

function Cards({ currentUser, onLogout, saveSearchToDB }) {
  const [pokemonList, setPokemonList] = useState([]);
  const [searchTerm, setSearchTerm] = useState("");
  const [filteredPokemon, setFilteredPokemon] = useState([]);
  const [visibleCount, setVisibleCount] = useState(8);

  // Load Pokemon
  useEffect(() => {
    const loadPokemons = async () => {
      try {
        const response = await fetch("https://pokeapi.co/api/v2/pokemon?limit=150");
        const data = await response.json();

        const details = await Promise.all(
          data.results.map(async (p) => {
            const res = await fetch(p.url);
            return await res.json();
          })
        );

        setPokemonList(details);
        setFilteredPokemon(details);
      } catch (error) {
        console.error("Error:", error);
      }
    };

    loadPokemons();
  }, []);

  // Function to search for Pokemon
  const handleSearch = async (event) => {
    const value = event.target.value.toLowerCase();
    setSearchTerm(value);

    if (value === "") {
      setFilteredPokemon(pokemonList);
      setVisibleCount(8);
    } else {
      const filtered = pokemonList.filter((p) => p.name.toLowerCase().includes(value));
      setFilteredPokemon(filtered);
      setVisibleCount(filtered.length);

      // Save search
      if (currentUser) {
        await saveSearchToDB(currentUser, value);
      }
    }
  };

  return (
    <div className="App">
      <h1>Pokemons - {currentUser}</h1>
      <button
        onClick={onLogout}
        style={{
          position: "absolute",
          top: "20px",
          right: "20px",
          padding: "8px 16px",
          background: "#dc3545",
          color: "white",
          border: "none",
          borderRadius: "4px",
          cursor: "pointer",
        }}
      >
        Log out
      </button>

      {/* Pokemon cards */}
      <div className="card-container">
        {filteredPokemon.slice(0, visibleCount).map((p, index) => (
          <div className="card" key={index}>
            <img
              src={p.sprites.front_default}
              alt={p.name}
              className="pokemon-img"
            />
            <h3>{p.name.charAt(0).toUpperCase() + p.name.slice(1)}</h3>
            <p>Type: {p.types.map((t) => t.type.name).join(", ")}</p>
            <p>Height: {p.height}</p>
            <p>Weight: {p.weight}</p>
          </div>
        ))}
      </div>

      <div className="search-area">
        <h2>Find your Pokémon</h2>
        <input
          type="text"
          placeholder="Search Pokémon..."
          value={searchTerm}
          onChange={handleSearch}
          className="search-input"
        />
      </div>
    </div>
  );
}

export default Cards;