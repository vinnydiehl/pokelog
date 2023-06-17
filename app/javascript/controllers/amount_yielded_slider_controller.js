/**
  * The noUiSlider in the filters dialog.
  **/

import { Controller } from "@hotwired/stimulus"
import * as noUi from "nouislider"

// Connects to data-controller="amount-yielded-slider"
export default class extends Controller {
  connect() {
    let slider = this.element;

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

      this.#updateYielded("min", min, value => value > 1);
      this.#updateYielded("max", max, value => value < 3);

      // Send input to trigger the controller
      document.getElementById("filters_min").dispatchEvent(new Event("input"));
    });
  }

  #updateYielded(inputType, value, checkWhen) {
    const input = document.getElementById(`filters_${inputType}`);
    input.value = value;
    input.checked = checkWhen(value);
  }
}
