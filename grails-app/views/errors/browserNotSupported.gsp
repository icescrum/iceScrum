%{--
- Copyright (c) 2011 Kagilum SAS.
-
- This file is part of iceScrum.
-
- iceScrum is free software: you can redistribute it and/or modify
- it under the terms of the GNU Affero General Public License as published by
- the Free Software Foundation, either version 3 of the License.
-
- iceScrum is distributed in the hope that it will be useful,
- but WITHOUT ANY WARRANTY; without even the implied warranty of
- MERCHANTABILITY or FITNESS FOR A PARTICulAR PURPOSE.  See the
- GNU General Public License for more details.
-
- You should have received a copy of the GNU Affero General Public License
- along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
-
- Authors:
-
- Nicolas Noullet (nnoullet@kagilum.com)
--}%

<!DOCTYPE html>
<title>iceScrum - Outdated browser detected</title>

<style>
#container {
    margin: auto;
    margin-top: 20px;
    width: 700px;
}

#browser-detection {
    color: #333333;
    position: fixed;
    padding: 10px 15px;
    font-size: 13px;
    font-family: "Trebuchet MS", Arial, sans-serif;
}

#browser-detection p {
    width: auto;
    border: none;
}

#browser-detection h1 {
    padding-top: 0;
    margin-top: 0;
    line-height: 100%;
}

#browser-detection ul.browser-list, #browser-detection ul.browser-list li {
    padding: 0;
    margin: 0;
    float: left;
    list-style: none;
}

#browser-detection ul.browser-list {
    clear: both;
    margin-top: 3px;
    padding: 7px 0;
    border-top: 2px solid #5bc0de;
    border-bottom: 2px solid #5bc0de;
    width: 100%;
}

#browser-detection ul.browser-list li { text-align: left; }

#browser-detection ul.browser-list li a {
    width: 55px;
    height: 55px;
    display: block;
    color: #666666;
    padding: 10px 10px 0 65px;
    text-decoration: none;
}

#browser-detection ul.browser-list li a:hover { text-decoration: underline; }

#browser-detection ul.browser-list li.firefox a { background: url(../images/firefox.jpg) no-repeat left top; }

#browser-detection ul.browser-list li.chrome a { background: url(../images/chrome.jpg) no-repeat left top; }

#browser-detection ul.browser-list li.safari a { background: url(../images/safari.jpg) no-repeat left top; }

#browser-detection ul.browser-list li.opera a { background: url(../images/opera.jpg) no-repeat left top; }

#browser-detection ul.browser-list li.msie a { background: url(../images/msie.jpg) no-repeat left top; }
</style>

<div id="container">
    <div id="browser-detection">

        <h1>Outdated browser detected</h1>

        <p>iceScrum has detected that you are using an outdated browser.</p>

        <p>If you use Internet Explorer, be careful: you browser may be in "compatibility mode", thus passing itself off as an older version of IE. In such case, disable the IE compatibility mode.</p>

        <p><b>Otherwise an upgrade is required.</b> Use the links below to download a new browser or upgrade your existing browser.</b>
        </p>
        <ul class="browser-list">
            <li class="firefox"><a target="_blank" href="http://www.getfirefox.com/">Mozilla Firefox</a></li>
            <li class="chrome"><a target="_blank" href="http://www.google.com/chrome/">Google Chrome</a></li>
            <li class="safari"><a target="_blank" href="http://www.apple.com/safari/">Apple Safari</a></li>
            <li class="opera"><a target="_blank" href="http://www.opera.com/">Opera</a></li>
            <li class="msie"><a target="_blank" href="http://www.getie.com/">Internet Explorer</a></li>
        </ul>

        <div class="clear"></div>
    </div>
</div>
