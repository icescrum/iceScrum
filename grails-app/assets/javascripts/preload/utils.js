function isTouchOnlyDevice() { //not the best place... but there isn't a best place for that
    return /iP(ad|hone|od)/.test(navigator.userAgent) || navigator.userAgent.indexOf('Android') > 0;
}