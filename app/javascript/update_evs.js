function getInputSum(traineeInfo, klass) {
    return [0, ...traineeInfo.querySelectorAll(klass)]
        .reduce((partialSum, input) => partialSum + (parseInt(input.value) || 0));
}

// Trainee UI behaves as 9th gen if none is selected. This doesn't affect search results.
function getGeneration() {
    return parseInt(document.getElementById("generation").value || 9);
}

// Returns the item(s) associated with the held item for a given trainee
function itemStat(traineeInfo) {
    return {
        "trainee_item_macho_brace": ["hp", "atk", "def", "spa", "spd", "spe"],
        "trainee_item_power_weight": "hp",
        "trainee_item_power_bracer": "atk",
        "trainee_item_power_belt": "def",
        "trainee_item_power_lens": "spa",
        "trainee_item_power_band": "spd",
        "trainee_item_power_anklet": "spe"
    }[traineeInfo.querySelector(".held-items input[type='radio']:checked").id];
}

// Sets EVs, checking for edge cases and optionally applying items (enabled by default)
function updateEvs(traineeInfo, iHp, iAtk, iDef, iSpA, iSpD, iSpe,
                   applyItemsAndPokerus=true, perStatLimit=null, goalAlertTrainee=null) {
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

        // Apply Pokérus last
        if (traineeInfo.querySelector("#trainee_pokerus").checked)
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
            } else
                input.value = newValue == 0 ? "" : newValue;
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

    // Grab the final values from the inputs and use them
    // to update the radar chart
    if (getInputSum(traineeInfo, ".ev-input") <= 510) {
        drawRadarChart("radar-chart-trainee_" + id,
            ...[...inputs].map(input => parseInt(input.value) || 0),
            ...[...traineeInfo.querySelectorAll(".goal-input")].map(input => parseInt(input.value) || 0));
    }

    setEvInputColor();
    checkGoals(goalAlertTrainee);
}

// Called by the kill buttons onclick, as well as from the swipe events
// allowMobile (true when from the swipe bindings) helps them not to clash
function killButton(iHp, iAtk, iDef, iSpA, iSpD, iSpe, allowMobile=false) {
    if (allowMobile || window.ontouchstart === undefined || screen.width > 509)
        document.querySelectorAll(".trainee-info")
            .forEach(traineeInfo => updateEvs(traineeInfo, iHp, iAtk, iDef, iSpA, iSpD, iSpe));
}

// Called by the consumables buttons onclick
function useConsumable(traineeInfo, itemType, stat) {
    let stats = { hp: 0, atk: 0, def: 0, spa: 0, spd: 0, spe: 0 };

    const generation = getGeneration();

    let evInput = traineeInfo.querySelector(`.point.${stat} .ev-input`);

    if (generation == 4 && itemType == "berries" && parseInt(evInput.value) > 110)
        evInput.value = "110";

    stats[stat] += {
        "vitamins": 10,
        "feathers": 1,
        "berries": -10
    }[itemType];

    updateEvs(traineeInfo, ...Object.values(stats), false,
              itemType == "vitamins" && generation < 8 ? 100 : null,
              traineeInfo);
}

// Checks total of all EVs and sets color of input borders accordingly
function setEvInputColor() {
    document.querySelectorAll(".trainee-info").forEach(traineeInfo => {
        sum = getInputSum(traineeInfo, ".ev-input");
        goalSum = getInputSum(traineeInfo, ".goal-input");

        traineeInfo.querySelectorAll(".ev-container").forEach(input => {
            if (sum > 510 || goalSum > 510 ||
                ![".ev-input", ".goal-input"].every(klass => input.querySelector(klass).checkValidity()))
                input.style.borderColor = "red";
            else if (sum == 510)
                input.style.borderColor = "green";
            else
                input.style.borderColor = "black";
        });
    });
}

// Displays an alert if the user's EV goals have been or are about to be exceeded
//
// @param onlyDisplayFor [Element within .trainee-info] only display if alert involves
//                                                       a specific trainee
function checkGoals(onlyDisplayFor=null) {
    const generation = getGeneration();

    // As the trainees' stats get iterated over, any that need an alert are added to
    // these arrays as objects w/ trainee (title), stat, evs, and goal
    let approaching = [];
    let onGoal = [];
    let over = [];

    document.querySelectorAll(".trainee-info").forEach(traineeInfo => {
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

                // Apply Pokérus last
                if (traineeInfo.querySelector("#trainee_pokerus").checked)
                    alertOffset *= 2;

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

            inputs.forEach(input => {input.style.color = inputTextColor});
            if (!hasAlert)
                deleteCookie(data.cookieName);
        });
    });

    // Now to generate the contents of the modal and display it
    // if conditions are met

    const goalData = [["approaching-goal", approaching],
                      ["on-goal", onGoal],
                      ["over-goal", over]];

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
