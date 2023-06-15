import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="form-submission"
export default class extends Controller {
  searchSubmit() {
    clearTimeout(this.timeout);
    this.timeout = setTimeout(() => { this.element.requestSubmit() }, 200);
  }

  submit() {
    event.target.closest("form").requestSubmit();
  }

  // This select (in the filters modal) just sets a cookie and refreshes the form
  generationSubmit() {
    const gen = parseInt(document.getElementById("generation").value);

    // If a gen is selected, permanent cookie. Otherwise delete any existing cookie
    const expire_date = gen ? new Date(Date.now() + (20 * 365 * 24 * 60 * 60 * 1000))
                            : new Date(0);

    document.cookie = `generation=${gen}; path=/; SameSite=Lax; expires=${expire_date}`;

    M.Modal.getInstance(document.getElementById("species-filters")).close();

    // Reload entire page, this way we update the tooltips, etc.
    Turbo.visit(window.location.href, {action: "replace"});
  }
}
