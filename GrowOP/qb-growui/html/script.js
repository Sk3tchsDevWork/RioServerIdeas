window.addEventListener("message", function (event) {
  if (event.data.type === "updatePlants") {
    const tracker = document.getElementById("tracker");
    tracker.innerHTML = "";
    event.data.plants.forEach((plant) => {
      const div = document.createElement("div");
      div.className = "plant";
      div.innerHTML = `
        <strong>${plant.cropType} [ID: ${plant.id}]</strong><br/>
        Stage: ${plant.stage}<br/>
        Time Left: ${plant.timeLeft}
      `;
      tracker.appendChild(div);
    });
  }
});
