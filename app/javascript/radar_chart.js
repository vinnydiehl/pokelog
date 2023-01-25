function drawRadarChart(id, hp, atk, def, spa, spd, spe) {
    // Display a zoomed chart
    var y_max = Math.max(hp, atk, def, spa, spd, spe);
    // y_max needs to be at least 1 or else the chart will
    // be filled when there are no EVs to show
    if (y_max < 1) {
      y_max++;
    }

    var chart = anychart.radar();

    // Credits in footer
    chart.credits().enabled(false);

    // 255 needs to be hardcoded here
    chart.tooltip().format(`{%value} / 255`);

    chart.xAxis().labels().enabled(false);
    chart.yAxis().labels().enabled(false);

    chart.yAxis().ticks().enabled(false);

    chart.yScale().maximum(y_max).ticks({"interval": y_max / 4});

    chart.area([
      {x: "HP", value: hp},
      {x: "Atk", value: atk},
      {x: "Def", value: def},
      {x: "Spe", value: spe},
      {x: "Sp.D", value: spd},
      {x: "Sp.A", value: spa}
    ]);

    // If the chart already exists due to it being cached, delete the existing
    // one before loading the new one
    var existingChart = document.querySelector("#" + id + " div");
    if (existingChart)
      existingChart.remove();

    chart.container(id);
    chart.draw();
}
