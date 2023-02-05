import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    searchSubmit() {
        clearTimeout(this.timeout);
        this.timeout = setTimeout(() => { this.element.requestSubmit() }, 200);
    }

    submit() {
        event.target.closest("form").requestSubmit();
    }

    filterSubmit() {
        event.target.closest("form").requestSubmit();
        // Stops modal from bugging out and freezing when using
        // back/forward buttons while changing filters
        history.replaceState({}, '', window.location.href);
    }
}
