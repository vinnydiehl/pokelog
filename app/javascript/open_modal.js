function openModal(id) {
    elem = document.querySelector(`#${id}`);
    M.Modal.init(elem);
    M.Modal.getInstance(elem).open();
}
