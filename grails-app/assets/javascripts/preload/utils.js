var isSettings = {};
var savedColorScheme;

function isTouchOnlyDevice() { //not the best place... but there isn't a best place for that
    return /iP(ad|hone|od)/.test(navigator.userAgent) || navigator.userAgent.indexOf('Android') > 0;
}

function getColorScheme() {
    return savedColorScheme;
}

function setColorScheme(colorScheme, isInit) {
    savedColorScheme = colorScheme === 'dark' ? 'dark' : 'light';
    var css = colorScheme === 'dark' ? isSettings.darkMode : isSettings.lightMode;
    if (isInit) {
        document.write(css); //no angular / jquery here
        $(document).ready(function() {
            $('body').addClass(savedColorScheme + '-scheme');
        });
    } else {
        angular.element('#main-css').attr('href', css);
        angular.element('body').removeClass('dark-scheme light-scheme');
        angular.element('body').addClass(savedColorScheme + '-scheme');
    }
}

function darkOrLightMode(colorScheme) {
    var updateDarkOrLightMode = function(e) {
        setColorScheme(e.matches ? 'dark' : 'light');
    };
    if (window.matchMedia && !colorScheme) {
        var colorSchemeMedia = window.matchMedia('(prefers-color-scheme: dark)');
        if (colorSchemeMedia.addEventListener) {
            colorSchemeMedia.addEventListener("change", updateDarkOrLightMode);
        } else if (colorSchemeMedia.addListener) { //fallback
            colorSchemeMedia.addListener(updateDarkOrLightMode);
        }
        if (colorSchemeMedia.matches) {
            setColorScheme('dark', true);
            return;
        }
    }
    setColorScheme(colorScheme, true);
}

function togglePassword(element) {
    var $this = $(element);
    var $eyes = $this.find('.fa-eye').is(':visible');
    $this.find($eyes ? '.fa-eye-slash' : '.fa-eye').show();
    $this.find($eyes ? '.fa-eye' : '.fa-eye-slash').hide();
    $this.parent().parent().find('input').attr('type', $eyes ? 'text' : 'password');
}

function b64DecodeUnicode(str) {
    // Going backwards: from bytestream, to percent-encoding, to original string.
    return decodeURIComponent(atob(str).split('').map(function(c) {
        return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
    }).join(''));
}

var login = function(redirectTo) {
    redirectTo = redirectTo ? redirectTo : document.location.href;
    redirectTo = redirectTo.replace('#', '_HASH_');
    var query = isSettings.loginLink.indexOf('?') > 0 ? '&' : '?';
    redirectTo = query + isSettings.redirectToParameter + '=' + redirectTo;
    document.location.href = isSettings.loginLink + redirectTo;
    return false;
}

var logout = function(redirectTo) {
    if (redirectTo) {
        redirectTo = redirectTo ? redirectTo : document.location.href;
        redirectTo = redirectTo.replace('#', '_HASH_');
        var query = isSettings.logoutLink.indexOf('?') > 0 ? '&' : '?';
        redirectTo = query + isSettings.redirectToParameter + '=' + redirectTo;
    }
    document.location.href = isSettings.logoutLink + (redirectTo ? redirectTo : "");
    return false;
}