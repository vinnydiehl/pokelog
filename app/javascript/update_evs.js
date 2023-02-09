function getEvSum(traineeInfo) {
    return [0, ...traineeInfo.querySelectorAll(".ev-input")]
        .reduce((partialSum, input) => partialSum + (parseInt(input.value) || 0));
}

function updateEvs(iHp, iAtk, iDef, iSpA, iSpD, iSpe) {
    document.querySelectorAll(".trainee-info").forEach((traineeInfo, index) => {
        // Locally scoped stats for each trainee
        let stats = { hp: iHp, atk: iAtk, def: iDef, spa: iSpA, spd: iSpD, spe: iSpe };

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

        // If it's an array, it's a macho brace, double everything
        if (Array.isArray(itemStat))
            itemStat.forEach(stat => stats[stat] *= 2);
        else if (itemStat)
            stats[itemStat] += 4;

        // Apply Pokérus last
        if (traineeInfo.querySelector("#trainee_pokerus").checked)
            for (const stat in stats)
                stats[stat] *= 2;

        // You may be wondering what order these stats need to be applied in when
        // they're nearly at 510 but receiving yields of multiple stats. See issue
        // #1 for a deep dive into this; these elements load in the correct order
        // as applied by the game.
        let inputs = traineeInfo.querySelectorAll(".point input");
        inputs.forEach(input => {
            // Use the class of the input box to get the stat we're adding
            // (hp, atk, etc.) which is the variable name of the number we
            // need, passing into eval() gets the amount
            addend = stats[input.parentElement.classList[1]];
            intValue = input.value == "" ? 0 : parseInt(input.value);
            newValue = intValue + addend;

            if (getEvSum(traineeInfo) + addend <= 510 &&
                newValue <= 255 && !input.disabled) {
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
    });
}

// Checks total of all EVs and sets color of input borders accordingly
function setEvInputColor() {
    document.querySelectorAll(".trainee-info").forEach(traineeInfo => {
        sum = getEvSum(traineeInfo);
        traineeInfo.querySelectorAll(".ev-input").forEach(input => {
            if (sum > 510)
                input.style.borderColor = "red";
            else if (sum == 510)
                input.style.borderColor = "green";
            else
                input.style.borderColor = "black";
        });
    });
}
