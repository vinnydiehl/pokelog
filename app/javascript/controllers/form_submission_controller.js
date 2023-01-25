import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    searchSubmit() {
        clearTimeout(this.timeout);
        this.timeout = setTimeout(() => { this.element.requestSubmit() }, 200);
    }

    submit() {
        console.log("--");
        console.log(this.element);
        console.log("--");
        console.log(event.target.closest("form"));
        event.target.closest("form").requestSubmit();
    }
}
