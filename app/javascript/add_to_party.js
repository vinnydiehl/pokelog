runOnLoad(() => {
    document.querySelector("#confirm-add-to-party").addEventListener("click", () => {
        var selectedIds = Array.from(document.querySelectorAll("input[name='trainee_ids[]']:checked")).map(checkbox => {
            return checkbox.value;
        });
        if (selectedIds.length > 0) {
            window.location = location.pathname + "," + selectedIds.join(",") + location.search;
        }
    });
});
