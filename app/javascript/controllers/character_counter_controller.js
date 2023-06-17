/**
  * This controller adds a character counter to a text input. To do so, connect
  * the controller to the input, set the `data-length` to the max number of
  * characters, and if you would like the counter to hide when unfocused, add
  * an action "blur->character-counter#hide"
  **/

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="character-counter"
export default class extends Controller {
  connect() {
    M.CharacterCounter.init(this.element);
  }

  hide() {
    this.element.parentElement.querySelector(".character-counter").innerHTML = "";
  }
}
