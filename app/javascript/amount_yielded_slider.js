function updateYielded(inputType, value, checkWhen) {
    const input = document.getElementById(`filters_${inputType}`);
    input.value = value;
    input.checked = checkWhen(value);
}

runOnLoad(() => {
    let slider = document.getElementById("amount-yielded-slider");

    // Prevent double loading- delete and create a
    // new slider each time this script is run.
    if (slider.classList.contains("noUi-target"))
        slider.innerHTML = "";
    if (slider.noUiSlider)
        slider.noUiSlider.destroy();

    noUiSlider.create(slider, {
        start: [
            document.getElementById("filters_min").value,
            document.getElementById("filters_max").value
        ],
        connect: true,
        step: 1,
        range: {
            "min": 1,
            "max": 3
        },
        tooltips: [
            wNumb({ decimals: 0 }),
            wNumb({ decimals: 0 })
        ]
    });

    slider.noUiSlider.on("change", () => {
        const [min, max] = slider.noUiSlider.get();

        updateYielded("min", min, value => value > 1);
        updateYielded("max", max, value => value < 3);

        // Send input to trigger the controller
        document.getElementById("filters_min").dispatchEvent(new Event("input"));
    });
});
