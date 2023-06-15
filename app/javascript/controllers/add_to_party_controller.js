/**
  * The add to party menu on trainees#show.
  **/

import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="add-to-party"
export default class extends Controller {
  confirm() {
    let selectedIds = Array.from(this.element.querySelectorAll("input[name='trainee_ids[]']:checked"))
        .map(checkbox => checkbox.value);

    if (selectedIds.length > 0)
        Turbo.visit(location.pathname + "," + selectedIds.join(",") + location.search,
                    {action: "replace"});
  }
}
