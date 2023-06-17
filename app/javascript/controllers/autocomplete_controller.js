/**
  * Controller for Materialize autocomplete.
  * https://materializecss.com/autocomplete.html
  **/

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="autocomplete"
export default class extends Controller {
  connect() {
    M.Autocomplete.init(this.element,
                        { data: JSON.parse(document.getElementById("autocomplete-data").value) });
  }
}
