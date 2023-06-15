/**
  * Controller for Materialize collapsible.
  * https://materializecss.com/collapsible.html
  **/

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="collapsible"
export default class extends Controller {
  connect() {
    M.Collapsible.init(this.element);
  }
}
