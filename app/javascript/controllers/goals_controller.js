/**
  * Controller for the goals entered on the right half of the EV input.
  **/

import { Controller } from "@hotwired/stimulus"
import { setCookie, getCookie, deleteCookie, getGeneration } from "../util/cookies"
import { itemStat } from "../util/ev"

// Connects to data-controller="goals"
export default class extends Controller {
  connect() {
    // In most cases all alerts will be shown already, but this sets the colors
    this.check();
  }

  check() {
    const generation = getGeneration();

    // As the trainees' stats get iterated over, any that need an alert are added to
    // these arrays as objects w/ trainee (title), stat, evs, and goal
    let approaching = [];
    let onGoal = [];
    let over = [];

    this.element.querySelectorAll(".trainee-info").forEach(traineeInfo => {
      const traineeTitle = traineeInfo.querySelector(".trainee-title").innerHTML;

      const usingGoals = Array.from(traineeInfo.querySelectorAll(".goal-input")).
        some(input => parseInt(input.value));

      // Each stat is in a .point div. This div also has a class with the name
      // of the stat which we will grab in a minute
      traineeInfo.querySelectorAll(".point").forEach(point => {
        const inputs = [".ev-input", ".goal-input"].map(klass => point.querySelector(klass));
        const stat = point.classList[1];
        const evs = parseInt(inputs[0].value) || 0;
        const goal = parseInt(inputs[1].value) || 0;
        const selectedItem = itemStat(traineeInfo);
        const offset = goal - evs;

        const data = {
          name: traineeTitle,
          cookieName: `${traineeInfo.id}_${stat}`,
          stat: point.dataset.formatStat,
          evs: evs,
          goal: goal
        }

        let inputTextColor = "black";
        let hasAlert = false;

        if (usingGoals) {
          // The expected offset starts at 3 and will be built upon based
          // on item and Pokérus
          let alertOffset = 3;

          // If itemStat is an array, it's a macho brace
          if (Array.isArray(selectedItem))
            alertOffset *= 2;
          // Power item boost only applied if it's for this stat
          else if (selectedItem == stat)
            alertOffset += generation > 6 ? 8 : 4;

          // Apply Pokérus last. The switch might not be there so check
          const pkrsSwitch = traineeInfo.querySelector("#trainee_pokerus");
          if (pkrsSwitch && pkrsSwitch.checked)
            alertOffset *= 2;

          // Populate the data arrays based on offset's relationship w/ 0,
            // preventing 0/0 from triggering alerts
          if (offset < 0) {
            over.push(data);
            inputTextColor = "darkred";
            hasAlert = true;
          } else if (offset == 0 && goal > 0) {
            onGoal.push(data);
            inputTextColor = "darkgreen";
            hasAlert = true;
          } else if (offset <= alertOffset && goal > 0) {
            approaching.push(data);
            inputTextColor = "darkgoldenrod";
            hasAlert = true;
          }
        }

        inputs.forEach(input => {
          input.style.color = inputTextColor;
          input.style.setProperty("--c", inputTextColor);
        });

        if (!hasAlert)
          deleteCookie(data.cookieName);
      });
    });

    // Now to generate the contents of the modal and display it
    // if conditions are met

    const goalData = [
      ["approaching-goal", approaching],
      ["on-goal", onGoal],
      ["over-goal", over]
    ];

    // Cookies prevent the same alert from the same stat from displaying twice
    let cookieCheck = false;
    goalData.flatMap(arr => arr[1]).forEach(dataSet => {
      if (parseInt(getCookie(dataSet.cookieName)) != dataSet.evs) {
        setCookie(dataSet.cookieName, dataSet.evs);
        cookieCheck = true;
      }
    });

    const nAlerts = approaching.length + onGoal.length + over.length;

    if (nAlerts > 0 && cookieCheck) {
      // Title varies based on number/type of alerts
      document.getElementById("goal-alerts-title").innerHTML =
        nAlerts > 1 ? "You have alerts!" :
        approaching.length > 0 ? "Almost there!" :
        onGoal.length > 0 ? "You've reached your goal!" :
        "Oh no, you went over!";

      const table = document.createElement("table");

      const tableHeader = table.createTHead();
      const headerRow = tableHeader.insertRow();
      ["Name", "Stat", "EVs"].forEach(headerLabel => {
        headerRow.appendChild(
          Object.assign(document.createElement("th"), {textContent: headerLabel}));
      });

      const tableBody = table.createTBody();
      goalData.forEach(([klass, dataSet]) => {
        if (dataSet.length > 0) {
          dataSet.forEach(entry => {
            const { name, cookieName, stat, evs, goal } = entry;

            const row = tableBody.insertRow();
            row.classList.add(klass);

            [name, stat, `${evs}/${goal}`].forEach(value => {
              row.insertCell().textContent = value;
            });
          });
        }
      });

      document.getElementById("goal-table").replaceChildren(table);

      openModal("goal-alert");
    }
  }
}
