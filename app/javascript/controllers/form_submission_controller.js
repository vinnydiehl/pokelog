import { Controller } from "@hotwired/stimulus"

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
        const gen = document.getElementById("generation").value;

        // If a gen is selected, permanent cookie. Otherwise delete any existing cookie
        const expire_date = gen ? new Date(Date.now() + (20 * 365 * 24 * 60 * 60 * 1000))
                                : new Date(0);

        document.cookie = `generation=${gen}; path=/; SameSite=Lax; expires=${expire_date}`;

        // Stop "generation" from showing in params
        document.getElementById("generation").disabled = true;
        this.submit(event);

        // It looks like this gets re-enabled on submit, but if you go back
        // then forward, it would break
        document.getElementById("generation").disabled = false;
    }
}
