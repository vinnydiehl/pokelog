/**
  * Scripts for UI management features such as closing/deleting/adding on `trainees#show`.
  **/

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="trainee"
export default class extends Controller {
  addNew() {
    Turbo.visit(`${window.location.pathname}/new${window.location.search}`, { action: "replace" });
  }

  close() {
    const id = event.currentTarget.closest(".trainee-info").dataset.id;
    // Regex removes the targeted ID from comma-separated list
    Turbo.visit(window.location.href.replace(new RegExp(`\\b${id}\\b,|,\\b${id}\\b(?=$|\\?)`), ""),
                { action: "replace" });
  }

  setDeleteRedirect() {
    event.currentTarget.querySelector("#redirect_params").value = window.location.search;
  }
}
