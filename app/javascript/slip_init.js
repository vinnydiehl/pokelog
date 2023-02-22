runOnLoad(() => {
    let slipContainer = document.querySelector("#results");

    // Prevent multiple event bindings
    if (!slipContainer.swipeBound) {
        const breakpoint = 509;

        let slipInstance;

        // Initialize slip only on mobile screens
        if (window.innerWidth <= breakpoint)
            slipInstance = new Slip(slipContainer);

        // Add event listener to reinitialize slip on screen resize
        window.addEventListener("resize", () => {
            if (window.innerWidth <= breakpoint) {
                // Mobile: make an instance if there is none, otherwise we do nothing
                slipInstance ||= new Slip(slipContainer);
            } else if (slipInstance) {
                // Wide screen and there is an instance, detach it
                slipInstance.detach();
                slipInstance = null;
            }
        });

        slipContainer.addEventListener("slip:swipe", e => killButton(
            ...e.target.getAttribute("data-ev-yield").split(",").map(Number),
            true));

        slipContainer.swipeBound = true;
    }
});
