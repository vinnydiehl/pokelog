/**
  * Functions for submitting forms.
  **/

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form-submission"
export default class extends Controller {
  // Submits after a 200ms delay, good for input events, as you don't want
  // to submit on every keypress
  searchSubmit() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => { this.element.requestSubmit() }, 200);
  }

  // Submits immediately
  submit() {
    event.target.closest("form").requestSubmit();
  }
}
