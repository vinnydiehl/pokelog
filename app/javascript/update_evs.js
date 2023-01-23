function getEvSum() {
    var sum = 0;
    document.querySelectorAll(".ev-input").forEach(input => {
      sum += parseInt(input.value) || 0
    });

    return sum;
}

function updateEvs(iHp, iAtk, iDef, iSpa, iSpd, iSpe) {
    document.querySelectorAll(".trainee-info").forEach(traineeInfo => {
        // Locally scoped stats for each trainee
        var hp = iHp, atk = iAtk, def = iDef, spa = iSpa, spd = iSpd, spe = iSpe;

        switch (traineeInfo.querySelector(".items-options input[type='radio']:checked").id) {
        case "trainee_item_macho_brace":
            hp *= 2; atk *= 2; def *= 2; spa *= 2; spd *= 2; spe *= 2;
            break;
        case "trainee_item_power_weight":
            hp += 4;
            break;
        case "trainee_item_power_bracer":
            atk += 4;
            break;
        case "trainee_item_power_belt":
            def += 4;
            break;
        case "trainee_item_power_lens":
            spa += 4;
            break;
        case "trainee_item_power_band":
            spd += 4;
            break;
        case "trainee_item_power_anklet":
            spe += 4;
            break;
        default: break;
        }
        if (traineeInfo.querySelector("#trainee_pokerus").checked) {
            hp *= 2; atk *= 2; def *= 2; spa *= 2; spd *= 2; spe *= 2;
        }

        // You may be wondering what order these stats need to be applied in when
        // they're nearly at 510 but receiving yields of multiple stats. See issue
        // #1 for a deep dive into this; these elements load in the correct order
        // as applied by the game.
        var inputs = traineeInfo.querySelectorAll(".point input");
        inputs.forEach(input => {
            // Use the class of the input box to get the stat we're adding
            // (hp, atk, etc.) which is the variable name of the number we
            // need, passing into eval() gets the amount
            addend = eval(input.parentElement.classList[1]);
            intValue = input.value == "" ? 0 : parseInt(input.value);
            newValue = intValue + addend;

            if (getEvSum() + addend <= 510 && newValue <= 255) {
                input.value = newValue == 0 ? "" : newValue;
            }
        });
        inputs[0].dispatchEvent(new Event('input', {bubbles: true}));
    });
}

// Checks total of all EVs and sets color of input borders accordingly
function setEvInputColor() {
    sum = getEvSum();
    document.querySelectorAll(".ev-input").forEach(input => {
        if (sum > 510) {
          input.style.borderColor = "red";
        } else if (sum == 510) {
          input.style.borderColor = "green";
        } else {
          input.style.borderColor = "black";
        }
    });
}
