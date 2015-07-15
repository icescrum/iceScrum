{
    element: "#stepDesc0.current",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.createProject.step1').encodeAsJavaScript()}",
    onPrev: function() {
        $('#dialog').dialog('close');
    },
    onNext:function(){
        $('#step0Next:not([disabled])').click();
    },
    onShown: function(tour) {
        $('#step0Next').unbind('click.guidedTour').one('click.guidedTour',function(){
            tour.goTo(tour.getCurrentStep() + 1);
        });
        $('#step0Next').unbind('click.guidedTour').one('click.guidedTour',function(){
            tour.goTo(tour.getCurrentStep() + 1);
        });
        $('#step0Cancel').unbind('click.guidedTour').one('click.guidedTour',function(){
            $('#step-'+tour.getCurrentStep()+'.popover').remove();
            tour.end();
        });
    }
},
{
    element: "#stepDesc1.current",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.createProject.step2').encodeAsJavaScript()}",
    onPrev:function(){
        $('#step1Prev:not([disabled])').click();
    },
    onNext:function(tour){
        var btn = $('#step1Next:not([disabled])');
        if(btn.length > 0){
            btn.click();
        } else {
            tour.goTo(tour.getCurrentStep());
        }
    },
    onShown: function(tour) {
        var btnNext = $('#step1Next');
        btnNext.unbind('click.guidedTour').one('click.guidedTour',function(){
            tour.goTo(tour.getCurrentStep() + 1);
        });
        $('#step1Prev').unbind('click.guidedTour').one('click.guidedTour',function(){
            tour.goTo(tour.getCurrentStep() - 1);
        });
        $('#step1Cancel').unbind('click.guidedTour').one('click.guidedTour',function(){
            $('#step-'+tour.getCurrentStep()+'.popover').remove();
            tour.end();
        });
        var guidedTourNext = $('#step-' + tour.getCurrentStep() + ' [data-role="next"]');
        tour.intervalCheckTeamButton = setInterval(function(){
            if(btnNext.is(':hidden')){
                clearInterval(btnNext);
            } else {
                guidedTourNext.prop('disabled',btnNext.prop('disabled'));
            }
        }, 150);
    }
},
{
    element: "#stepDesc2.current",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.createProject.step3').encodeAsJavaScript()}",
    onPrev:function(){
        $('#step2Prev:not([disabled])').click();
    },
    onNext:function(){
        $('#step2Next:not([disabled])').click();
    },
    onShown: function(tour) {
        $('#step2Next').unbind('click.guidedTour').one('click.guidedTour',function(){
            tour.goTo(tour.getCurrentStep() + 1);
        });
        $('#step2Prev').unbind('click.guidedTour').one('click.guidedTour',function(){
            tour.goTo(tour.getCurrentStep() - 1);
        });
        $('#step2Cancel').unbind('click.guidedTour').one('click.guidedTour',function(){
            $('#step-'+tour.getCurrentStep()+'.popover').remove();
            tour.end();
        });
    }
},
{
    element: "#stepDesc3.current",
    title: "${title}",
    placement: "left",
    content: "${message(code:'is.ui.guidedTour.createProject.step4').encodeAsJavaScript()}",
    onPrev:function(){
        $('#step3Prev:not([disabled])').click();
    },
    onNext:function(){
        $('#step3Next:not([disabled])').click();
    },
    onShown: function(tour) {
        $('#step3Next').unbind('click.guidedTour').one('click.guidedTour',function(){
            tour.goTo(tour.getCurrentStep() + 1);
        });
        $('#step3Prev').unbind('click.guidedTour').one('click.guidedTour',function(){
            tour.goTo(tour.getCurrentStep() - 1);
        });
        $('#step3Cancel').unbind('click.guidedTour').one('click.guidedTour',function(){
            $('#step-'+tour.getCurrentStep()+'.popover').remove();
            tour.end();
        });
    }
},
{
    element: "#stepDesc4.current",
    title: "${title}",
    placement: "left",
    content:  "${message(code:'is.ui.guidedTour.createProject.step5').encodeAsJavaScript()}",
    onPrev:function(){
        $('#step4Prev:not([disabled])').click();
    },
    onShown: function(tour) {
        $('#step4Prev').unbind('click.guidedTour').one('click.guidedTour',function(){
            tour.goTo(tour.getCurrentStep() - 1);
        });
        $('#step4Cancel').unbind('click.guidedTour').one('click.guidedTour',function(){
            $('#step-'+tour.getCurrentStep()+'.popover').remove();
            tour.end();
        });
    }
}