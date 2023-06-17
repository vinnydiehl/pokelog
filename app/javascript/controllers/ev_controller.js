/**
  * These functions comprise the main business logic of `trainees#show`.
  * Kill buttons, items, and the colors of the EV inputs are handled here.
  **/

import { Controller } from "@hotwired/stimulus"
import { getGeneration } from "util/cookies"
import { getInputSum, itemStat } from "util/ev"

// Connects to data-controller="ev"
export default class extends Controller {
  killButton() {
    // Only allow swipes on mobile
    if (event.type == "click" && screen.width <= 509 && window.ontouchstart !== undefined)
      return;

    const data = event.currentTarget.dataset;

    this.element.querySelectorAll(".trainee-info")
      .forEach(traineeInfo => this.#update(
        traineeInfo, ...["hp", "atk", "def", "spa", "spd", "spe"].map(stat => parseInt(data[stat]))));
  }

  useConsumable() {
    const data = event.currentTarget.dataset;

    const traineeInfo = event.currentTarget.closest(".trainee-info");
    let evInput = traineeInfo.querySelector(`.point.${data.stat} .ev-input`);

    const generation = getGeneration();

    if (generation == 4 && data.itemType == "berries" && parseInt(evInput.value) > 110)
      evInput.value = "110";

    let stats = { hp: 0, atk: 0, def: 0, spa: 0, spd: 0, spe: 0 };
    stats[data.stat] += {
      "vitamins": 10,
      "feathers": 1,
      "berries": -10
    }[data.itemType];

    this.#update(traineeInfo, ...Object.values(stats), false,
                 data.itemType == "vitamins" && generation < 8 ? 100 : null);
  }

  setBorderColor() {
    const traineeInfo = event.currentTarget.closest(".trainee-info");

    const sum = getInputSum(traineeInfo, ".ev-input");
    const goalSum = getInputSum(traineeInfo, ".goal-input");

    traineeInfo.querySelectorAll(".ev-container").forEach(input => {
      if (sum > 510 || goalSum > 510 ||
        ![".ev-input", ".goal-input"].every(klass => input.querySelector(klass).checkValidity()))
        input.style.borderColor = "red";
      else if (sum == 510)
        input.style.borderColor = "green";
      else
        input.style.borderColor = "black";
    });
  }

  #update(traineeInfo, iHp, iAtk, iDef, iSpA, iSpD, iSpe,
          applyItemsAndPokerus=true, perStatLimit=null) {
    let stats = { hp: iHp, atk: iAtk, def: iDef, spa: iSpA, spd: iSpD, spe: iSpe };

    const generation = getGeneration();

    perStatLimit ||= generation > 5 ? 252 : 255;

    if (applyItemsAndPokerus) {
      // Find the item, if any
      const selectedItem = itemStat(traineeInfo);

      // If it's an array, it's a macho brace; double everything
      if (Array.isArray(selectedItem))
        selectedItem.forEach(stat => stats[stat] *= 2);
      // Power item boosts, varies by generation
      else if (selectedItem)
        stats[selectedItem] += generation > 6 ? 8 : 4;

      // Apply Pokérus last. The switch might not be there so check
      const pkrsSwitch = traineeInfo.querySelector("#trainee_pokerus");
      if (pkrsSwitch && pkrsSwitch.checked)
        for (const stat in stats)
          stats[stat] *= 2;
    }

    // You may be wondering what order these stats need to be applied in when
    // they're nearly at 510 but receiving yields of multiple stats. See issue
    // #1 for a deep dive into this; these elements load in the correct order
    // as applied by the game.
    let inputs = traineeInfo.querySelectorAll(".ev-input");
    inputs.forEach(input => {
      if (!input.disabled) {
        // Use the class of the input box to get the stat we're adding
        // (hp, atk, etc.) which is the name of the number we need
        let addend = stats[input.closest(".point").classList[1]];
        let intValue = parseInt(input.value) || 0;
        let newValue = intValue + addend;

        let evSum = getInputSum(traineeInfo, ".ev-input");

        if (evSum + addend > 510)
          input.value = Math.min(perStatLimit, intValue + (510 - evSum));
        else if (newValue < 0)
          input.value = 0;
        else if (newValue > perStatLimit) {
          // Do nothing if we're over the limit, otherwise the input will
          // e.g. reset back to 100 if you click a vitamin while over 100
          if (perStatLimit < 255 && intValue > perStatLimit)
            return;

          input.value = perStatLimit;
        } else {
          input.value = newValue == 0 ? "" : newValue;
        }
      }
    });

    const id = traineeInfo.id.split("_")[1];

    // Make the PATCH request and handle the response
    // The Stimulus controller struggles with this
    fetch("/trainees/" + id, {
      method: "PATCH",
      body: new FormData(traineeInfo),
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
      }
    });

    this.application.getControllerForElementAndIdentifier(
      traineeInfo.querySelector(".ev-info"),
      "radar-chart"
    ).load();

    // Poke an input to trigger setBorderColor()
    inputs[0].dispatchEvent(new Event("input"));
  }
}
