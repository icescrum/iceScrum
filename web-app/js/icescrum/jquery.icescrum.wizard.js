(function($) {
    $.extend($.icescrum, {
                updateWizardDate:function(datepicker) {
                    var startDate = $(datepicker).datepicker('getDate');
                    var endDateProject = new Date(startDate.getTime() + 3 * 24 * 60 * 60 * 1000);
                    var endDate = new Date(startDate.getTime() + 90 * 24 * 60 * 60 * 1000);
                    var endDateFirstSprint = new Date(startDate.getTime() + 88 * 24 * 60 * 60 * 1000);
                    var $endDate = $('#datepicker-productendDate');
                    var $firstSprint = $('#datepicker-firstSprint');
                    $endDate.datepicker('option', {minDate:endDateProject,defaultDate:endDate,maxDate:null});
                    $endDate.datepicker('setDate', endDate);
                    $endDate.datepicker('option', {minDate:startDate,defaultDate:startDate,maxDate:endDateFirstSprint});
                    $endDate.datepicker('setDate', startDate);
                }
            });

    $.fn.isWizard = function(options) {
        options = $.extend({
                    disableNext: [],
                    submitButton: "",
                    nextButton:"",
                    previousButton:"",
                    cancelButton:"",
                    submitFunction:"",
                    validateStep:false
                }, options);

        var element = this;
        var steps = $(element).find(".panel");
        var count = steps.size();

        $(element).wrap("<div class='wizard clearfix'></div>");

        var wrapper = $("<div class='wizard-buttons'></div>");

        $(element).parent().parent().append(wrapper);
        $(element).before("<div id='wizard-left'><ul id='steps'></ul></div>");

        steps.each(function(i) {
            var step = $(this).wrap("<div id='step" + i + "'></div>");
            wrapper.append("<p id='step" + i + "commands' class='wizard-commands clearfix'></p>");
            var section = $(this).find("h3");
            section.hide();
            var name = section.html();
            $("#steps").append("<li id='stepDesc" + i + "'><p>" + (i + 1) + '.' + " <span>" + name + "</span></p></li>");
            step.prepend("<p class='field-information field-information-nobordertop'>" + $(this).attr('description') + "</p>");

            if (i == 0) {
                createCancelButton(i);
                createNextButton(i);
                selectStep(i);
            }
            else if (i == count - 1) {
                $("#step" + i).hide();
                $("#step" + i + "commands").hide();
                createCancelButton(i);
                createFinishButton(i);
                createPrevButton(i);
            }
            else {
                $("#step" + i).hide();
                $("#step" + i + "commands").hide();
                createCancelButton(i);
                createNextButton(i);
                createPrevButton(i);
            }
        });

        function createCancelButton(i) {
            if(options.cancelButton) {
                var stepName = "step" + i;
                $("#" + stepName + "commands").append("<button class='ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only prev' id='" + stepName + "Cancel' class='prev'><span class='ui-button-text'>" + options.cancelButton + "</span></button>");
                $("#" + stepName + "Cancel").bind("click", function (e) {
                    $('#dialog').dialog('close');
                });
            }
        }

        function createPrevButton(i) {
            var stepName = "step" + i;
            $("#" + stepName + "commands").append("<button class='ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only prev' id='" + stepName + "Prev' class='prev'><span class='ui-button-text'>" + options.previousButton + "</span></button>");

            $("#" + stepName + "Prev").bind("click", function(e) {
                $("#" + stepName).hide();
                $("#step" + (i - 1)).show();
                $("#step" + i + "commands").hide();
                $("#step" + (i - 1) + "commands").show();
                selectStep(i - 1);
            });
        }

        function createNextButton(i) {
            var stepName = "step" + i;
            var disabled = options.disableNext.indexOf(i) != -1;
            var disabledAttribute = disabled ? 'disabled="disabled"' : '';
            var disabledClass = disabled ? 'ui-state-disabled' : '';
            $("#" + stepName + "commands").append("<button " + disabledAttribute + " class='ui-button ui-widget ui-state-default " + disabledClass + " ui-corner-all ui-button-text-only next' id='" + stepName + "Next'><span class='ui-button-text'>" + options.nextButton + "</span></button>");

            $("#" + stepName + "Next").bind("click", function(e) {
                if (options.validateStep){
                    $.post(options.validateStep, $(':input', $("#" + stepName)).serialize() + '&step=' + i, function(data) {
                        if(data.result){
                            $("#" + stepName).hide();
                            $("#step" + i + "commands").hide();
                            $("#step" + (i + 1) + "commands").show();
                            $("#step" + (i + 1)).show();
                            selectStep(i + 1);
                        }
                    });
                } else {
                    $("#" + stepName).hide();
                    $("#step" + i + "commands").hide();
                    $("#step" + (i + 1) + "commands").show();
                    $("#step" + (i + 1)).show();
                    selectStep(i + 1);
                }
            });
        }

        function createFinishButton(i) {
            var stepName = "step" + i;
            $("#" + stepName + "commands").append("<button class='ui-button ui-widget ui-state-default ui-corner-all ui-button-text-only next' id='" + stepName + "Next'><span class='ui-button-text'>" + options.submitButton + "</span></button>");

            $("#" + stepName + "Next").bind("click", function(e) {
                options.submitFunction();
            });
            $("#" + stepName + "Cancel").bind("click", function(e) {
                $('#dialog').dialog('close');
            });
        }

        function selectStep(i) {
            var $steps = $("#steps").find("li");
            $steps.removeClass("current");
            $steps.removeClass("old");
            $steps.removeClass("validated");
            $("#stepDesc" + i).addClass("current");

            for (var j = i - 1; j >= 0; j--) {
                $("#stepDesc" + j).addClass("old");
                if(options.validateStep){
                    $("#stepDesc" + j).addClass("validated");
                }
            }
        }

    };

})($);