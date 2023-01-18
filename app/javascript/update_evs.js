function updateEvs(hp, atk, def, spa, spd, spe) {
    switch (document.querySelector(".items-options input[type='radio']:checked").id) {
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
    if (document.getElementById("trainee_pokerus").checked) {
        hp *= 2; atk *= 2; def *= 2; spa *= 2; spd *= 2; spe *= 2;
    }

    var inputs = document.querySelectorAll(".point input");
    inputs.forEach(input => {
        intValue = input.value == "" ? 0 : parseInt(input.value);
        newValue = intValue + eval(input.parentElement.classList[1]);
        input.value = newValue == 0 ? "" : newValue;
    });
    inputs[0].dispatchEvent(new Event('input',{bubbles:true}));
}
