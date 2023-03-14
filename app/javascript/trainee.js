runOnLoad(() => {
    // Update params on a hidden field in the delete form when it is submitted
    // (cannot be done on page load as the search form changes the params)
    document.querySelectorAll(".modal.delete form").forEach(deleteForm => {
        deleteForm.addEventListener("submit", () => {
            deleteForm.querySelector("#redirect_params").value = window.location.search;
        });
    });

    // Updates the link for the new trainee button similarly
    let newTraineeBtn = document.getElementById("new-trainee-btn")
    newTraineeBtn.addEventListener("click", () => {
        newTraineeBtn.href = `${window.location.pathname}/new${window.location.search}`;
        console.log(newTraineeBtn.href);
    });
});

function closeTrainee(id) {
    // Regex removes the targeted ID from comma-separated list
    Turbo.visit(window.location.href.replace(new RegExp(`\\b${id}\\b,|,\\b${id}\\b(?=$|\\?)`), ""),
                {action: "replace"});
}
