runOnLoad(function () {
    // Hack fix for double loading of dynamic content
    if (!document.querySelector(".select-wrapper input")) {
        var elems = document.querySelectorAll("select");
        var instances = M.FormSelect.init(elems, {});
    }
});
