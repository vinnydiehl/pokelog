runOnLoad(() => {
    var elems = document.querySelectorAll(".sidenav");
    var instances = M.Sidenav.init(elems);
    if (window.innerWidth <= 992) {
        document.querySelector('#nav-full').style.transform = "translateX(-105%)";
        document.querySelector('#nav-full').style.display = "block";
    }
});
