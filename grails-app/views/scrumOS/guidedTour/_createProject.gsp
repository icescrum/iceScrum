<script type="text/javascript">
(function ($) {
    var ${tourName} = new Tour({
        template:"${message(code:'is.ui.guidedTour.template').encodeAsJavaScript()}",
        steps: [
            {
                element: "#stepDesc0",
                title: "${message(code:'is.ui.guidedTour.title.project').encodeAsJavaScript()}",
                placement: "left",
                content: "${message(code:'is.ui.guidedTour.creation.project.step1').encodeAsJavaScript()}"
            },
            {
                element: "#stepDesc1",
                placement: "left",
                title: "Choose a team ",
                content: "${message(code:'is.ui.guidedTour.creation.project.step2').encodeAsJavaScript()}"
            },
            {
                element: "#stepDesc2",
                placement: "left",
                title: "Choose a team",
                content: "${message(code:'is.ui.guidedTour.creation.project.step3').encodeAsJavaScript()}"
            },
            {
                element: "#stepDesc3",
                title: "${message(code:'is.ui.guidedTour.title.project').encodeAsJavaScript()}",
                placement: "left",
                content: "${message(code:'is.ui.guidedTour.creation.project.step4').encodeAsJavaScript()}"
            },
            {
                element: "#stepDesc4",
                title: "${message(code:'is.ui.guidedTour.title.project').encodeAsJavaScript()}",
                placement: "left",
                content:  "${message(code:'is.ui.guidedTour.creation.project.step5').encodeAsJavaScript()}"
            }
        ]
    });
    $('#menu-project').find('ul li a[data-shortcut="ctrl+shift+n"]').one('click', function () {
        $.doTimeout(1000, function () {
            ${tourName}.restart();
            $('#step0Next').click(function () {
                ${tourName}.goTo(1);
            });
            $('#step1Next').click(function () {
                ${tourName}.goTo(2);
            });
            $('#step2Next').click(function () {
                ${tourName}.goTo(3);
            });
            $('#step3Next').click(function () {
                ${tourName}.goTo(4);
            });
            $('#step4Next').click(function () {
                ${tourName}.goTo(5);
            });
            $('#step1Prev').click(function () {
                ${tourName}.goTo(0);
            });
            $('#step2Prev').click(function () {
                ${tourName}.goTo(1);
            });
            $('#step3Prev').click(function () {
                ${tourName}.goTo(2);
            });
            $('#step4Prev').click(function () {
                ${tourName}.goTo(3);
            });
            $('#step5Prev').click(function () {
                ${tourName}.goTo(4);
            });
        });
    });
    <g:if test="${autoStart}">
    $('#menu-project').find('ul li a[data-shortcut="ctrl+shift+n"]').click();
    </g:if>
})(jQuery);
</script>