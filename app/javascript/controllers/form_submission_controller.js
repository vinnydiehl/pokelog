import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    searchSubmit() {
        clearTimeout(this.timeout);
        this.timeout = setTimeout(() => { this.element.requestSubmit() }, 200);
    }

    submit() {
        event.target.closest("form").requestSubmit();
    }
}
