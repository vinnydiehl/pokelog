function getSelectedTraineeIDs() {
    return Array.from(document.querySelectorAll("input[name='trainee_ids[]']:checked"))
        .map(checkbox => checkbox.value);
}

// Train/delete buttons get selected IDs, join them with ',' and redirect
function visitSelectedTrainees(suffix="") {
    let selectedIDs = getSelectedTraineeIDs();

    if (selectedIDs.length > 0)
        Turbo.visit("/trainees/" + selectedIDs.join(",") + suffix);
}

function setButtonState() {
    if (getSelectedTraineeIDs().length > 0)
        for (let btn of ["train", "delete"])
            document.getElementById(`${btn}-btn`).classList.remove("disabled");
    else
        for (let btn of ["train", "delete"])
            document.getElementById(`${btn}-btn`).classList.add("disabled");
}

function setConfirmDeleteState() {
    if (document.getElementById("confirm-delete-checkbox").checked)
        document.getElementById("confirm-delete").classList.remove("disabled");
    else
        document.getElementById("confirm-delete").classList.add("disabled");
}

runOnLoad(() => {
    // Make sure buttons are set properly on load
    setButtonState();
    setConfirmDeleteState();

    // Disable/enable Train/Delete buttons as boxes are checked
    document.querySelectorAll("#trainee_ids_").forEach(checkbox => {
        checkbox.addEventListener("change", setButtonState);
    });

    // Disable/enable confirm delete button similarly
    document.querySelector("#confirm-delete-checkbox")
        .addEventListener("change", setConfirmDeleteState);

    document.querySelector("#train-btn").addEventListener("click", () => visitSelectedTrainees());
});
