function getSelectedTraineeIDs() {
    return Array.from(document.querySelectorAll("input[name='trainee_ids[]']:checked"))
        .map(checkbox => checkbox.value);
}

runOnLoad(() => {
    // Disable/enable Train button as boxes are checked
    document.querySelectorAll("#trainee_ids_").forEach(checkbox => {
        checkbox.addEventListener("change", () => {
            if (getSelectedTraineeIDs().length > 0)
                document.getElementById("train-btn").classList.remove("disabled");
            else
                document.getElementById("train-btn").classList.add("disabled");
        });
    });


    // Train button gets selected IDs, joins them with ',' and redirects
    document.querySelector("#train-btn").addEventListener("click", () => {
        let selectedIDs = getSelectedTraineeIDs();

        if (selectedIDs.length > 0)
            Turbo.visit("/trainees/" + selectedIDs.join(","));
    });
});
