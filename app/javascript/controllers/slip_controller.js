/**
  * Controller for the kill button list on mobile.
  *
  * https://kornel.ski/slip/
  * Customized to only allow swiping. See `vendor/javascript/slip.js`.
  **/

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="slip"
export default class extends Controller {
  connect() {
    let slipContainer = this.element;

    // Pixel width where screen switches to mobile mode
    const breakpoint = 509;

    const options = {
      minimumSwipeVelocity: 0.7,
      minimumSwipeTime: 1,
      keepSwipingPercent: 50
    };

    let slipInstance;

    // Initialize slip only on mobile screens
    if (window.innerWidth <= breakpoint)
      slipInstance = new Slip(slipContainer, options);

    // Add event listener to reinitialize slip on screen resize
    window.addEventListener("resize", () => {
      if (window.innerWidth <= breakpoint) {
        // Mobile: make an instance if there is none, otherwise we do nothing
        slipInstance ||= new Slip(slipContainer, options);
      } else if (slipInstance) {
        // Wide screen and there is an instance, detach it
        slipInstance.detach();
        slipInstance = null;
      }
    });
  }
}
