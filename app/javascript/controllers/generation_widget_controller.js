import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="generation-widget"
export default class extends Controller {
  // This just sets a cookie and refreshes the page
  submit(event) {
    const gen = parseInt(event.currentTarget.innerText.trim());

    // If a gen is selected, permanent cookie. Otherwise delete any existing cookie
    const expire_date = gen ? new Date(Date.now() + (20 * 365 * 24 * 60 * 60 * 1000))
                            : new Date(0);

    document.cookie = `generation=${gen}; path=/; SameSite=Lax; expires=${expire_date}`;

    // Reload entire page, this way we update the tooltips, etc.
      Turbo.visit(window.location.href, {action: "replace"});
  }
}
