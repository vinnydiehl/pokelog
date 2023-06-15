/**
  * Controller for Materialize dropdowns.
  * https://materializecss.com/dropdown.html
  **/

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dropdown"
export default class extends Controller {
  connect() {
    M.Dropdown.init(this.element);
    M.Dropdown.getInstance(this.element).options.alignment = this.element.dataset.alignment;
  }
}
