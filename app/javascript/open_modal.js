// Opens a modal with the given ID. All of the logic in here is to prevent
// the modal from opening twice, which appears to close normally but
// then you can't scroll...
function openModal(id) {
    const elem = document.querySelector(`#${id}`);
    let instance = M.Modal.getInstance(elem);

    if (!instance) {
        M.Modal.init(elem);
        instance = M.Modal.getInstance(elem);
    }

    if (!instance.isOpen)
        instance.open();
}
