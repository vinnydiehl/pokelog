runOnLoad(() => {
    M.Sidenav.init(document.querySelectorAll(".sidenav"));
    if (window.innerWidth <= 992) {
        document.querySelector('#sidenav').style.transform = "translateX(-105%)";
        document.querySelector('#sidenav').style.display = "block";
    }
});
