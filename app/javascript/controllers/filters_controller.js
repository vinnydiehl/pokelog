/**
  * Filters form on trainee/species page
  **/

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="filters"
export default class extends Controller {
  // Clears all checkboxes on the form
  clear() {
    this.element.querySelectorAll("input[type='checkbox']").forEach(box => box.checked = false);
    this.element.querySelector("#amount-yielded-slider").noUiSlider.set([1, 3]);

    // Update (clear) the search results
    this.application.getControllerForElementAndIdentifier(
      this.element.closest("form"),
      "form-submission"
    ).submit();
  }

  // Apply this to the click action on the checkboxes in a div to
  // ensure that only 2 are checked at a time
  check2Max(event) {
    if (event.target.closest("div").querySelectorAll("input:checked").length > 2 && event.target.checked)
      event.preventDefault();
  }
}
