window.addEventListener("message", (event) => {
  const data = event.data;
  if (data.action === "openUI") {
    fetchNUIData();
  }
});

function fetchNUIData() {
  fetch(`https://${GetParentResourceName()}/getSuspects`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
  })
    .then(res => res.json())
    .then(data => updateTable(data));
}

function updateTable(suspects) {
  const tbody = document.getElementById("suspectTable");
  tbody.innerHTML = "";

  suspects.forEach(suspect => {
    const row = document.createElement("tr");

    const name = document.createElement("td");
    name.textContent = suspect.name;
    row.appendChild(name);

    const heat = document.createElement("td");
    heat.textContent = suspect.heat;
    row.appendChild(heat);

    const dist = document.createElement("td");
    dist.textContent = Math.floor(suspect.distance) + "m";
    row.appendChild(dist);

    const action = document.createElement("td");

    const wpBtn = document.createElement("button");
    wpBtn.textContent = "📍 Set WP";
    wpBtn.style.marginRight = "5px";
    wpBtn.onclick = () => {
      fetch(`https://${GetParentResourceName()}/setWaypoint`, {
        method: "POST",
        body: JSON.stringify({ coords: suspect.coords })
      });
    };

    const raidBtn = document.createElement("button");
    raidBtn.textContent = "🚨 Mark";
    raidBtn.onclick = () => {
      fetch(`https://${GetParentResourceName()}/markRaid`, {
        method: "POST",
        body: JSON.stringify({ suspect: suspect })
      });
    };

    action.appendChild(wpBtn);
    action.appendChild(raidBtn);
    row.appendChild(action);

    tbody.appendChild(row);
  });
}

function closeUI() {
  fetch(`https://${GetParentResourceName()}/close`, { method: "POST" });
}
