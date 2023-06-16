export function getInputSum(parent, klass) {
  return [0, ...parent.querySelectorAll(klass)]
    .reduce((partialSum, input) => partialSum + (parseInt(input.value) || 0));
}

export function itemStat(traineeInfo) {
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
