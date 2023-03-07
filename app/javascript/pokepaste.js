// Enable Add button if paste input field contains content, disable otherwise
function enablePasteButton() {
    const pasteField = document.querySelector("#add-pokepaste #paste");

    if (pasteField.value.trim() === "")
        document.getElementById("confirm-pokepaste").classList.add("disabled");
    else
        document.getElementById("confirm-pokepaste").classList.remove("disabled");

    M.textareaAutoResize(pasteField);
}

// Fetch paste from https://pokepast.es and insert it into paste field
function updatePaste() {
    // 200ms timeout between input and update
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => {
        const pasteField = document.querySelector("#add-pokepaste #paste");
        const url = document.querySelector("#add-pokepaste #url").value.trim();

        // Only fetch the paste if the URL field is not empty
        if (url !== "") {
            let xhr = new XMLHttpRequest();
            xhr.open("POST", "/trainees/paste/fetch", true);

            xhr.setRequestHeader("X-CSRF-Token",
                document.querySelector('meta[name="csrf-token"]').getAttribute('content'));
            xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

            xhr.onreadystatechange = () => {
                // Update the paste field with the fetched data
                if (xhr.readyState === 4 && xhr.status === 200) {
                    pasteField.value = xhr.responseText;
                    M.updateTextFields();
                    M.textareaAutoResize(pasteField);
                    enablePasteButton();
                }
            };

            xhr.send("url=" + encodeURIComponent(url));
        }
    }, 200);
}

// GET /paste
function submitPaste() {
    Turbo.visit(
        `/trainees/paste?paste=${encodeURIComponent(document.querySelector('#add-pokepaste #paste').value)}`,
        {action: 'replace'}
    );
}
