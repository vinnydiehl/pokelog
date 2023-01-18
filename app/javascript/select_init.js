runOnLoad(() => {
    // Hack fix for double loading of dynamic content
    if (!document.querySelector(".select-wrapper input")) {
        M.FormSelect.init(document.querySelectorAll("select"));
    }
});
