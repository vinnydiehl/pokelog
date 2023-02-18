function radarYValue(value, y_max) {
    const offset = y_max / 35.0;
    return value <= offset ? offset : value;
}

function drawRadarChart(id, hp, atk, def, spa, spd, spe) {
    // Display a zoomed chart
    let y_max = Math.max(hp, atk, def, spa, spd, spe);

    let chart = anychart.radar();

    // Credits in footer
    chart.credits().enabled(false);

    chart.interactivity().selectionMode("none");
    chart.tooltip().enabled(false);

    chart.xAxis().labels().enabled(false);
    chart.yAxis().labels().enabled(false);

    chart.yAxis().ticks().enabled(false);

    chart.area([
        {x: "HP", value: radarYValue(hp, y_max)},
        {x: "Atk", value: radarYValue(atk, y_max)},
        {x: "Def", value: radarYValue(def, y_max)},
        {x: "Spe", value: radarYValue(spe, y_max)},
        {x: "Sp.D", value: radarYValue(spd, y_max)},
        {x: "Sp.A", value: radarYValue(spa, y_max)},
    ]);

    // y_max needs to be positive or else the chart will
    // be filled when there are no EVs to show
    if (y_max <= 0)
        y_max++;

    chart.yScale().maximum(y_max).ticks({"interval": y_max / 4});

    // If the chart already exists due to it being cached, delete the existing
    // one before loading the new one
    let existingChart = document.querySelector("#" + id + " div");
    if (existingChart)
        existingChart.remove();

    chart.container(id);
    chart.draw();
}
