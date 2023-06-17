/**
  * Controller for Materialize sidenav.
  * https://materializecss.com/sidenav.html
  **/

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sidenav"
export default class extends Controller {
  connect() {
    M.Sidenav.init(this.element);
    if (window.innerWidth <= 992) {
        this.element.style.transform = "translateX(-105%)";
        this.element.style.display = "block";
    }
  }
}
