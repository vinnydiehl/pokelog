import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="trainees-index"
export default class extends Controller {
  connect() {
    // Make sure buttons are set properly on load e.g. after a refresh
    this.setConfirmDeleteState();
    this.setButtonState();
  }

  train() {
    this.#visitSelectedTrainees();
  }

  delete() {
    this.#visitSelectedTrainees("/delete");
  }

  // Disable/enable Train/Delete buttons as boxes are checked
  setButtonState() {
    if (this.#getSelectedTraineeIDs().length > 0)
      for (let btn of ["train", "delete"])
        document.getElementById(`${btn}-btn`).classList.remove("disabled");
    else
      for (let btn of ["train", "delete"])
        document.getElementById(`${btn}-btn`).classList.add("disabled");
  }

  // Disable/enable confirm delete button as the confirmation box is checked
  setConfirmDeleteState() {
    if (document.getElementById("confirm-delete-checkbox").checked)
      document.getElementById("confirm-delete").classList.remove("disabled");
    else
      document.getElementById("confirm-delete").classList.add("disabled");
  }

  #visitSelectedTrainees(suffix="") {
    let selectedIDs = this.#getSelectedTraineeIDs();

    if (selectedIDs.length > 0)
      Turbo.visit("/trainees/" + selectedIDs.join(",") + suffix);
  }

  #getSelectedTraineeIDs() {
    return Array.from(document.querySelectorAll("input[name='trainee_ids[]']:checked"))
      .map(checkbox => checkbox.value);
  }
}
