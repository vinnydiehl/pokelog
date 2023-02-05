function clearAllFilters() {
    document.querySelector("#species-filters").querySelectorAll("input[type='checkbox']").
        forEach(checkbox => {
        checkbox.checked = false
    });

    document.getElementById("amount-yielded-slider").noUiSlider.set([1, 3]);
    document.getElementById("filters_min").dispatchEvent(new Event("input"));
}

runOnLoad(() => {
    // Prevent more than 2 Types filters from being selected
    document.querySelectorAll("#types-filters input").forEach(checkbox => {
        checkbox.addEventListener("click", event => {
            if (document.querySelectorAll("#types-filters input:checked").length > 2 && checkbox.checked)
                event.preventDefault();
        });
    });
});
