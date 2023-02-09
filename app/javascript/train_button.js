runOnLoad(() => {
    document.querySelector("#train-btn").addEventListener("click", () => {
        let selectedIds = Array.from(document.querySelectorAll("input[name='trainee_ids[]']:checked"))
            .map(checkbox => checkbox.value);

        if (selectedIds.length > 0)
            window.location = "/trainees/" + selectedIds.join(",");
    });
});
