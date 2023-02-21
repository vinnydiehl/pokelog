// Update params on a hidden field in the delete form when it is submitted
// (cannot be done on page load as the search form changes the params)
runOnLoad(() => {
    document.querySelectorAll(".modal.delete form").forEach(deleteForm => {
        deleteForm.addEventListener("submit", () => {
            deleteForm.querySelector("#redirect_params").value = window.location.search;
        });
    });
});

function closeTrainee(id) {
    // Regex removes the targeted ID from comma-separated list
    Turbo.visit(window.location.href.replace(new RegExp(`\\b${id}\\b,|,\\b${id}\\b(?=$|\\?)`), ""),
                {action: "replace"});
}
