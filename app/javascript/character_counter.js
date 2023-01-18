runOnLoad(() => {
    M.CharacterCounter.init(document.querySelectorAll("input.counter"));
});

// Make it go away when you click away (call onblur)
function hideCounter() {
    document.querySelectorAll(".character-counter").forEach(function(input) {
        input.innerHTML = "";
    });
}
