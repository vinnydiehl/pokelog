/**
  * This controller is for input validations that activate/deactivate buttons.
  *
  * You can set it on an input directly and set a `data-target` attribute with the
  * ID of the button, as well as an appropriate `data-action`.
  *
  * You can also put this controller on a parent element with `data-length-input`
  * and `data-email-input` and you can then call `validateAll()` from a
  * `data-action` on both of the inputs, and they will both be checked for
  * validity when either of them is modified.
  **/

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="button-enable"
export default class extends Controller {
  validateAll() {
    const data = this.element.dataset;

    this.#target().disabled =
      !this.#validateLength(document.getElementById(data.lengthInput)) ||
      !this.#validateEmail(document.getElementById(data.emailInput));
  }

  validateLength() {
    this.#target().disabled = !this.#validateLength(this.element);
  }

  validateEmail() {
    this.#target().disabled = !this.#validateEmail(this.element);
  }

  #validateLength(input) {
    const length = input.value.trim().length;
    return length >= input.minLength && length <= input.maxLength;
  }

  #validateEmail(input) {
    return this.#isValidEmail(input.value) &&
           (!input.dataset.originalValue || input.value != input.dataset.originalValue);
  }

  #target() {
    return document.getElementById(this.element.dataset.target);
  }

  #isValidEmail(input) {
    return input.match(/(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9][0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])/) != null;
  }
}
