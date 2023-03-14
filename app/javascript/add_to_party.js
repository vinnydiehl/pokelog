runOnLoad(() => {
    document.querySelector("#confirm-add-to-party").addEventListener("click", () => {
        let selectedIds = Array.from(document.querySelectorAll("input[name='trainee_ids[]']:checked"))
            .map(checkbox => checkbox.value);

        if (selectedIds.length > 0)
            Turbo.visit(location.pathname + "," + selectedIds.join(",") + location.search,
                        {action: "replace"});
    });
});
