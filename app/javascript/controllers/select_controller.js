/**
  * Controller for Materialize select.
  * https://materializecss.com/select.html
  **/

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="select"
export default class extends Controller {
  // If you try to call this on connect(), when Materialize initializes the select, it
  // recursively connects new select tags in an infinite loop. Perhaps, when hiding the
  // one which is actually there, it for some reason deletes and generates a new, hidden one?
  initialize() {
    M.FormSelect.init(this.element);
  }
}
