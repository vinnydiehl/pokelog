import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="modal"
export default class extends Controller {
  connect() {
    const target = document.querySelector(`#${this.element.dataset.target}`);
    this.modal = M.Modal.getInstance(target);

    if (!this.modal) {
        M.Modal.init(target);
        this.modal = M.Modal.getInstance(target);
    }
  }

  open() {
    if (!this.modal.isOpen)
        this.modal.open();
  }
}
