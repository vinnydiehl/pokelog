runOnLoad(() => {
    document.querySelector("#train-btn").addEventListener("click", () => {
        var selectedIds = Array.from(document.querySelectorAll("input[name='trainee_ids[]']:checked")).map(checkbox => {
            return checkbox.value;
        });
        if (selectedIds.length > 0) {
            window.location = "/trainees/" + selectedIds.join(",");
        }
    });
});
