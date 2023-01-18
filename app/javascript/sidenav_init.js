runOnLoad(() => {
    M.Sidenav.init(document.querySelectorAll(".sidenav"));
    if (window.innerWidth <= 992) {
        document.querySelector('#nav-full').style.transform = "translateX(-105%)";
        document.querySelector('#nav-full').style.display = "block";
    }
});
