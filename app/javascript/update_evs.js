function getEvSum(traineeInfo) {
    return [0, ...traineeInfo.querySelectorAll(".ev-input")]
        .reduce((partialSum, input) => partialSum + (parseInt(input.value) || 0));
}

// Trainee UI behaves as 9th gen if none is selected. This doesn't affect search results.
function getGeneration() {
    return parseInt(document.getElementById("generation").value || 9);
}

// Sets EVs, checking for edge cases and optionally applying items (enabled by default)
function updateEvs(traineeInfo, iHp, iAtk, iDef, iSpA, iSpD, iSpe,
                   applyItemsAndPokerus=true, perStatLimit=null) {
    let stats = { hp: iHp, atk: iAtk, def: iDef, spa: iSpA, spd: iSpD, spe: iSpe };

    const generation = getGeneration();

    perStatLimit ||= generation > 5 ? 252 : 255;

    if (applyItemsAndPokerus) {
        // Find the item, if any
        const itemStat = {
            "trainee_item_macho_brace": Object.keys(stats),
            "trainee_item_power_weight": "hp",
            "trainee_item_power_bracer": "atk",
            "trainee_item_power_belt": "def",
            "trainee_item_power_lens": "spa",
            "trainee_item_power_band": "spd",
            "trainee_item_power_anklet": "spe"
        }[traineeInfo.querySelector(".held-items input[type='radio']:checked").id];

        // If it's an array, it's a macho brace; double everything
        if (Array.isArray(itemStat))
            itemStat.forEach(stat => stats[stat] *= 2);
        // Power item boosts, varies by generation
        else if (itemStat)
            stats[itemStat] += generation > 6 ? 8 : 4;

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
            let intValue = input.value == "" ? 0 : parseInt(input.value);
            let newValue = intValue + addend;

            let evSum = getEvSum(traineeInfo);
            console.log(evSum);

            if (evSum + addend > 510)
                input.value = Math.min(252, intValue + (510 - evSum));
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
    if (getEvSum(traineeInfo) <= 510) {
        final = [...inputs].map(input => input.value);
        drawRadarChart("radar-chart-trainee_" + id, ...final);
    }

    setEvInputColor();
}

// Called by the kill buttons onclick
function killButton(iHp, iAtk, iDef, iSpA, iSpD, iSpe, allowMobile=false) {
    if (allowMobile || (window.ontouchstart === undefined && screen.width > 509))
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
              itemType == "vitamins" && generation < 8 ? 100 : null);
}

// Checks total of all EVs and sets color of input borders accordingly
function setEvInputColor() {
    document.querySelectorAll(".trainee-info").forEach(traineeInfo => {
        sum = getEvSum(traineeInfo);
        traineeInfo.querySelectorAll(".ev-container").forEach(input => {
            if (sum > 510)
                input.style.borderColor = "red";
            else if (sum == 510)
                input.style.borderColor = "green";
            else
                input.style.borderColor = "black";
        });
    });
}
