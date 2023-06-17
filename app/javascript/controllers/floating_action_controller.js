/**
  * Controller for Materialize floating action buttons.
  * https://materializecss.com/floating-action-button.html
  **/

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="floating-action"
export default class extends Controller {
  connect() {
    M.FloatingActionButton.init(this.element);
  }
}
