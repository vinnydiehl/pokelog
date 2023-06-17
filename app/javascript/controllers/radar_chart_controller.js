/**
  * Loads/updates the stat charts on `trainees#show`.
  **/

import { Controller } from "@hotwired/stimulus"
import * as ac from "anychart-radar"

// Connects to data-controller="radar-chart"
export default class extends Controller {
  connect() {
    this.load();
  }

  load() {
    // Read EVs and goals from their inputs
    const evInfo = this.element;
    const [hp, atk, def, spa, spd, spe] = [...evInfo.querySelectorAll(".point")].
        map(point => parseInt(point.querySelector(".ev-input").value) || 0);
    const [hpGoal, atkGoal, defGoal, spaGoal, spdGoal, speGoal] = [...evInfo.querySelectorAll(".point")].
        map(point => parseInt(point.querySelector(".goal-input").value) || 0);

    // Are any goals set at all?
    const usingGoals = (hpGoal + atkGoal + defGoal + spaGoal + spdGoal + speGoal) > 0;

    // Display a zoomed chart
    let yMax = Math.max(hp, atk, def, spa, spd, spe,
        ...(usingGoals ? [hpGoal, atkGoal, defGoal, spaGoal, spdGoal, speGoal] : []));

    let chart = anychart.radar();

    // Credits in footer
    chart.credits().enabled(false);

    chart.interactivity().selectionMode("none");
    chart.tooltip().enabled(false);

    chart.xAxis().labels().enabled(false);
    chart.yAxis().labels().enabled(false);

    chart.yAxis().ticks().enabled(false);

    chart.area(this.#chartValues(yMax, hp, atk, def, spa, spd, spe));

    if (usingGoals)
        chart.line(this.#chartValues(yMax, hpGoal, atkGoal, defGoal, spaGoal, spdGoal, speGoal));

    // yMax needs to be positive or else the chart will
    // be filled when there are no EVs to show
    if (yMax <= 0)
        yMax++;

    chart.yScale().maximum(yMax).ticks({"interval": yMax / 4});

    const radarChart = this.element.querySelector(".radar-chart");

    // If the chart already exists due to it being cached, delete the existing
    // one before loading the new one
    let existingChart = document.querySelector("#" + radarChart.id + " div");
    if (existingChart)
        existingChart.remove();

    chart.container(radarChart.id);
    chart.draw();
  }

  #radarYValue(value, yMax) {
    const offset = yMax / 35.0;
    return value <= offset ? offset : value;
  }

  #chartValues(yMax, hp, atk, def, spa, spd, spe) {
    return [
      {x: "HP", value: this.#radarYValue(hp, yMax)},
      {x: "Atk", value: this.#radarYValue(atk, yMax)},
      {x: "Def", value: this.#radarYValue(def, yMax)},
      {x: "Spe", value: this.#radarYValue(spe, yMax)},
      {x: "Sp.D", value: this.#radarYValue(spd, yMax)},
      {x: "Sp.A", value: this.#radarYValue(spa, yMax)},
    ];
  }
}
