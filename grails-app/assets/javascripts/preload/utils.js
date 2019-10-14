var isSettings = {};

function isTouchOnlyDevice() { //not the best place... but there isn't a best place for that
    return /iP(ad|hone|od)/.test(navigator.userAgent) || navigator.userAgent.indexOf('Android') > 0;
}

function darkOrLightMode(colorScheme) {
    if (window.matchMedia && !colorScheme) {
        var colorSchemeMedia = window.matchMedia('(prefers-color-scheme: dark)');
        if (colorSchemeMedia.addEventListener) {
            colorSchemeMedia.addEventListener("change", updateDarkOrLightMode);
        } else if (colorSchemeMedia.addListener) { //fallback
            colorSchemeMedia.addListener(updateDarkOrLightMode);
        }
        if (colorSchemeMedia.matches) {
            document.write(isSettings.darkMode); //no angular / jquery here
            return;
        }
    }
    document.write(colorScheme === 'dark' ? isSettings.darkMode : isSettings.lightMode); //no angular / jquery here
}

function updateDarkOrLightMode(e) {
    angular.element("#main-css").attr("href", e.matches ? isSettings.darkMode : isSettings.lightMode);
}