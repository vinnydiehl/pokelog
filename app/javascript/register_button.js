function activateRegisterButton() {
    const length = document.querySelector("#username").value.trim().length;
    document.querySelector("#register-btn").disabled = length < 1 || length > 20;
}
