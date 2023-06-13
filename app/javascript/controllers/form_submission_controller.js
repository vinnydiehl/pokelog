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
}
