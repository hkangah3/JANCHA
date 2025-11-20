/* ORDERED DORMS */
const dorms = [
    { id: 1, name: "University College" },
    { id: 4, name: "University Square" },
    { id: 3, name: "University View I" },
    { id: 8, name: "University View II" },
    { id: 6, name: "University Village I" },
    { id: 7, name: "University Village II" },
    { id: 2, name: "University Village III" },
    { id: 5, name: "University Village VI" }
];

/* ROOMS */
const rawRoomData = [
    { room_id: 1, dorm_id: 1, number: '101', capacity: 2, occupancy: 1 },
    { room_id: 2, dorm_id: 1, number: '102', capacity: 2, occupancy: 2 },
    { room_id: 3, dorm_id: 4, number: '204', capacity: 4, occupancy: 2 },
    { room_id: 4, dorm_id: 5, number: '1142', capacity: 4, occupancy: 4 },
    { room_id: 5, dorm_id: 6, number: '2114', capacity: 2, occupancy: 1 },
    { room_id: 6, dorm_id: 2, number: '1144', capacity: 4, occupancy: 0 },
    { room_id: 7, dorm_id: 6, number: '6838', capacity: 2, occupancy: 1 },
    { room_id: 8, dorm_id: 4, number: '142', capacity: 2, occupancy: 0 },
    { room_id: 9, dorm_id: 4, number: '104', capacity: 2, occupancy: 2 },
    { room_id: 10, dorm_id: 7, number: '6832', capacity: 4, occupancy: 1 },
    { room_id: 11, dorm_id: 4, number: '114', capacity: 3, occupancy: 1 }
];

/* ELEMENTS */
const classificationGroup = document.getElementById("classificationGroup");
const housingGroup = document.getElementById("housingGroup");
const roomGroup = document.getElementById("roomGroup");

const classDisplay = document.getElementById("classificationDisplay");
const housingDisplay = document.getElementById("housingDisplay");
const roomDisplay = document.getElementById("roomDisplay");

const classInput = document.getElementById("classificationInput");
const housingInput = document.getElementById("housingUnitInput");
const roomInput = document.getElementById("roomNumberInput");

/* HELPERS */
function clearGroup(el) { el.innerHTML = ""; }
function deselectAll(el) { el.querySelectorAll(".selected").forEach(b => b.classList.remove("selected")); }

function setDisplay(el, text) {
    el.value = text || "";
    el.classList.toggle("active", !!text);
}

/* BUILD HOUSING */
function buildHousing() {
    clearGroup(housingGroup);
    clearGroup(roomGroup);

    setDisplay(housingDisplay, "");
    setDisplay(roomDisplay, "");
    housingInput.value = "";
    roomInput.value = "";

    const cls = classInput.value;

    dorms.forEach(d => {
        let allowed =
            (cls === "Freshman" && d.name === "University College") ||
            (cls !== "Freshman" && d.name !== "University College");

        if (!allowed) return;

        const rooms = rawRoomData.filter(r => r.dorm_id === d.id);
        const available = rooms.filter(r => r.occupancy < r.capacity);

        const btn = document.createElement("button");
        btn.type = "button";
        btn.className = "choice-btn";
        btn.dataset.id = d.id;
        btn.textContent = d.name;

        if (available.length === 0) btn.classList.add("disabled");

        housingGroup.appendChild(btn);
    });
}

/* BUILD ROOMS (updated: show ONLY room number) */
function buildRooms(dormId) {
    clearGroup(roomGroup);
    setDisplay(roomDisplay, "");
    roomInput.value = "";

    rawRoomData.filter(r => r.dorm_id === dormId).forEach(r => {
        const btn = document.createElement("button");
        btn.type = "button";
        btn.className = "choice-btn";
        btn.dataset.room = r.room_id;

        const full = r.occupancy >= r.capacity;

        // SHOW ONLY THE ROOM NUMBER
        btn.textContent = r.number;

        // disable full rooms
        if (full) btn.classList.add("disabled");

        roomGroup.appendChild(btn);
    });
}

/* CLASSIFICATION CLICK */
classificationGroup.addEventListener("click", (e) => {
    const btn = e.target.closest(".choice-btn");
    if (!btn) return;

    if (btn.classList.contains("selected")) {
        btn.classList.remove("selected");

        classInput.value = "";
        setDisplay(classDisplay, "");

        clearGroup(housingGroup);
        clearGroup(roomGroup);

        setDisplay(housingDisplay, "");
        setDisplay(roomDisplay, "");

        housingInput.value = "";
        roomInput.value = "";
        return;
    }

    deselectAll(classificationGroup);
    btn.classList.add("selected");

    classInput.value = btn.dataset.value;
    setDisplay(classDisplay, btn.dataset.value);

    buildHousing();
});

/* HOUSING CLICK */
housingGroup.addEventListener("click", (e) => {
    const btn = e.target.closest(".choice-btn");
    if (!btn || btn.classList.contains("disabled")) return;

    if (btn.classList.contains("selected")) {
        btn.classList.remove("selected");

        housingInput.value = "";
        setDisplay(housingDisplay, "");

        clearGroup(roomGroup);
        setDisplay(roomDisplay, "");
        roomInput.value = "";
        return;
    }

    deselectAll(housingGroup);
    btn.classList.add("selected");

    housingInput.value = btn.dataset.id;
    setDisplay(housingDisplay, btn.textContent);

    buildRooms(Number(btn.dataset.id));
});

/* ROOM CLICK */
roomGroup.addEventListener("click", (e) => {
    const btn = e.target.closest(".choice-btn");
    if (!btn || btn.classList.contains("disabled")) return;

    if (btn.classList.contains("selected")) {
        btn.classList.remove("selected");
        roomInput.value = "";
        setDisplay(roomDisplay, "");
        return;
    }

    deselectAll(roomGroup);
    btn.classList.add("selected");

    roomInput.value = btn.dataset.room;
    setDisplay(roomDisplay, btn.textContent);
});
