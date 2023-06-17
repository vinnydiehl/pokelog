/**
  * Controller for Materialize tooltips.
  * https://materializecss.com/tooltips.html
  **/

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="tooltip"
export default class extends Controller {
  connect() {
    M.Tooltip.init(this.element);
  }
}
