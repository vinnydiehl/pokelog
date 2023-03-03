function radarYValue(value, yMax) {
    const offset = yMax / 35.0;
    return value <= offset ? offset : value;
}

function chartValues(yMax, hp, atk, def, spa, spd, spe) {
    return [
        {x: "HP", value: radarYValue(hp, yMax)},
        {x: "Atk", value: radarYValue(atk, yMax)},
        {x: "Def", value: radarYValue(def, yMax)},
        {x: "Spe", value: radarYValue(spe, yMax)},
        {x: "Sp.D", value: radarYValue(spd, yMax)},
        {x: "Sp.A", value: radarYValue(spa, yMax)},
    ];
}

function drawRadarChart(id, hp, atk, def, spa, spd, spe,
                        hpGoal=0, atkGoal=0, defGoal=0, spaGoal=0, spdGoal=0, speGoal=0) {
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

    chart.area(chartValues(yMax, hp, atk, def, spa, spd, spe));

    if (usingGoals)
        chart.line(chartValues(yMax, hpGoal, atkGoal, defGoal, spaGoal, spdGoal, speGoal));

    // yMax needs to be positive or else the chart will
    // be filled when there are no EVs to show
    if (yMax <= 0)
        yMax++;

    chart.yScale().maximum(yMax).ticks({"interval": yMax / 4});

    // If the chart already exists due to it being cached, delete the existing
    // one before loading the new one
    let existingChart = document.querySelector("#" + id + " div");
    if (existingChart)
        existingChart.remove();

    chart.container(id);
    chart.draw();
}
