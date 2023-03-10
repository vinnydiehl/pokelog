function setCookie(name, value, days=(20 * 365)) {
    const expireDate = new Date(Date.now() + (days * 24 * 60 * 60 * 1000));
    document.cookie = `${name}=${value}; path=/; SameSite=Lax; expires=${expireDate}`
}

function deleteCookie(name) {
    setCookie(name, null, 0);
}

function getCookie(name) {
    name += "=";

    let value = null;
    decodeURIComponent(document.cookie).split(";").forEach(token => {
        token = token.trim();

        if (token.indexOf(name) == 0)
            value = token.substring(name.length, token.length);
    });

    return value;
}
