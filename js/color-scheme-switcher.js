console.log("Loaded")
const modes = {
    Dark = "dark",
    Light = "light",
}

function getCurrentMode() {
    return localStorage.getItem("theme");
}

const toggleColorSchemeBtn = document.getElementById("toggle-theme-btn");
const body = document.body;
const currentMode = getCurrentMode()
if (currentMode === modes.Light) {
	body.classList.toggle("dark-mode");

}

toggleColorSchemeBtn.addEventListener("click", () => {
    body.classList.toggle("dark-mode");

    if (body.classList.contains("dark-mode")) {
	localStorage.setItem("theme", modes.Dark);
    } else {
	localStorage.setItem("theme", modes.Light);
    }
})
