export function setCookie(name, value, days=(20 * 365)) {
    const expireDate = new Date(Date.now() + (days * 24 * 60 * 60 * 1000));
    document.cookie = `${name}=${value}; path=/; SameSite=Lax; expires=${expireDate}`
}

export function deleteCookie(name) {
    setCookie(name, null, 0);
}

export function getCookie(name) {
    name += "=";

    let value = null;
    decodeURIComponent(document.cookie).split(";").forEach(token => {
        token = token.trim();

        if (token.indexOf(name) == 0)
            value = token.substring(name.length, token.length);
    });

    return value;
}

export function getGeneration() {
  // Trainee UI behaves as 9th gen if none is selected. This doesn't affect search results.
  const generationCookie = document.cookie.split("; ")
    .find(row => row.startsWith("generation="))
    ?.split("=")[1];
  return parseInt(generationCookie) || 9;
}
