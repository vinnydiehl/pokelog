function closeTrainee(id) {
    Turbo.visit(window.location.href.replace(new RegExp(`\\b${id}\\b,|,\\b${id}\\b(?=$|\\?)`), ""),
                {action: "replace"});
}
