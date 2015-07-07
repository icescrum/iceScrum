<script type="text/javascript">
    (function ($) {
        var ${tourName} = new Tour({
            steps: [
                {
                    element: "#elem_project",
                    title: "Dashboard",
                    placement: "bottom",
                    content: "You are now on your “Dashboard” ready to start your project and your first sprint!"
                },
                {
                    element: "#menu-chart-navigation-item",
                    title: "Dashboard",
                    placement: "right",
                    content: "charts:Here you can display various indicator charts like the burnup or the cumulative flow. It gives you indicators about how is going your project."
                },
                {
                    element: "#menu-documents-list",
                    title: "Dashboard",
                    placement: "right",
                    content: "documents : add documents from your computer or the cloud."
                },
                {
                    element: "#menu-report-navigation-item",
                    title: "Dashboard",
                    placement: "right",
                    content: "Publish as… allows you to print al the project views"
                },
                {
                    element: "#menu-reportall-navigation-item",
                    title: "Dashboard",
                    placement: "right",
                    content: "Publish stories as.. :idem stories"
                },
                {
                    element: "#chart-productBurnupChart",
                    title: "Dashboard",
                    content: "project"
                },
                {
                    element: "#chart-sprintBurnupStoriesChart",
                    title: "Dashboard",
                    content: "stories"
                },
                {
                    element: "#chart-sprintBurnupPointsChart",
                    title: "Dashboard",
                    content: "Point"
                },
                {
                    element: "#chart-sprintBurnupTasksChart",
                    title: "Dashboard",
                    content: "Tasks"
                },
                {
                    element: "#chart-sprintBurndownRemainingChart",
                    title: "Dashboard",
                    content: "Remainingtime"
                },
                {
                    element: "#panel-activity",
                    title: "Dashboard",
                    placement: "left",
                    content: "Activities : all the activity of your team is displayed in this panel"
                },
                {
                    element: "#panel-description",
                    title: "Dashboard",
                    placement: "left",
                    content: "Project description : you can edit your project practices by clicking here"
                },
                {
                    element: "#panel-vision-2",
                    title: "Dashboard",
                    placement: "left",
                    content: "Release vision: your vision of the project"
                },
                {
                    element: "#panel-doneDefinition-9", // panel-box panel-doneDefinition
                    title: "Dashboard",
                    placement: "left",
                    content: "current definition of done : in this box you can define the steps you have to achieve to declare a story as « done »"
                },
                {
                    element: "#panel-retrospective-9",
                    title: "Dashboard",
                    placement: "left",
                    content: "current retrospective : right your notes about the project  ",
                    onNext: function (${tourName}) {
                        $.icescrum.openWindow('sandbox');
                    },
                    onPrev: function (${tourName}) {
                        $.icescrum.openWindow('project');
                    }
                },
                {
                    element: "#elem_sandbox",
                    title: "Sandbox",
                    placement: "right",
                    content: "You are now on your “Sandbox” !",
                    onPrev: function (${tourName}) {
                        $.icescrum.openWindow('project');
                    }
                },
                {
                    element: "#postit-story-1",
                    title: "Sandbox",
                    placement: "left",
                    content: "Now you can see your story in your sandbox! This is the number of your story, if you click here, you can access all your story details and modify them if needed"
                },
                {
                    element: "#menu-postit-story-1",
                    title: "Sandbox",
                    placement: "left",
                    content: "Here you can manage your story.You can edit, accept or delete it. You can choose to accept it as a story/feature/urgent task. You can also directly access the comment box or add acceptance tests."
                },
                {
                    element: "#search-ui",
                    title: "Sandbox",
                    placement: "left",
                    content: "You are now on your “Sandbox” ready to start your project and your first sprint!",
                    onNext: function (${tourName}) {
                        $.icescrum.openWindow('backlog');
                    }
                },
                {
                    element: "#elem_backlog",
                    title: "Product-Backlog",
                    placement: "right",
                    content: "You are now on your “Backlog” !",
                    onPrev: function (${tourName}) {
                        $.icescrum.openWindow('sandbox');
                    }
                },
                {
                    element: "#stories-backlog-size",
                    title: "Product-Backlog",
                    placement: "bottom",
                    content: "Here is your accepted story!"
                },
                {
                    element: "#menu-postit-story-105",
                    title: "Product-Backlog",
                    placement: "right",
                    content: "As you can see you still have the options as in the Sandbox, but a new one appeared : « return to sandbox » in case you do not want this story anymore in your Product backlog."
                },
                {
                    element: "#postit-story-107",
                    title: "Product-Backlog",
                    placement: "right",
                    content: "Here you can see that your story is « accepted », and you can now estimate it. Click on the ? and choose the value you want to give it. To read more about values you can read our documentation.",
                    onNext: function (${tourName}) {
                        $.icescrum.openWindow('timeline')
                    }
                },
                {

                    element: "#elem_timeline",
                    title: "Timeline ",
                    placement: "bottom",
                    content: "You are now on your “timeline”",
                    onPrev: function (${tourName}) {
                        $.icescrum.openWindow('backlog');
                    }
                },
                {
                    element: "#rel-2",
                    title: "Timeline",
                    content: "Your project timeline is automatically set to 90 days and a number of sprints calculated in function of the sprint duration you chose."
                },
                {
                    element: "#rel-2",
                    title: "Timeline",
                    placement: "left",
                    content: "You can modify your release dates by clicking on “update”"
                },
                {
                    element: "#tape0-tl-0-0-e3",
                    title: "Timeline",
                    content: "You can access any sprint detail by clicking on it!",
                    onNext: function (${tourName}) {
                        $.icescrum.openWindow('releasePlan')
                    }
                },
                {
                    element: "#elem_releasePlan",
                    title: "releasePlan",
                    placement: "bottom",
                    content: "You are now on your “releasePlan”",
                    onPrev: function (${tourName}) {
                        $.icescrum.openWindow('project');
                    }
                },
                {
                    element: "#widget-button-backlog",
                    title: "releasePlan",
                    placement: "right",
                    content: "Your product Backlog appears here, with the accepted and estimated stories. You can now drag them into your first sprint!"
                },
                {
                    element: "#backlog-layout-plan-releasePlan-9",
                    title: "releasePlan",
                    placement: "left",
                    content: "Once you have added your first stories, you can start your sprint!"
                },
                {
                    element: "#menu-postit-sprint-9",
                    title: "releasePlan",
                    placement: "left",
                    content: "Click here to open the sprint plan view, you can also click on « sprint plan »to access the same view."
                },
                {
                    element: "#menu-postit-sprint-9",
                    title: "releasePlan",
                    placement: "left",
                    content: "Once your sprint is achieved you will have to close it. By clicking here you can close your sprint and choose what to do with the unfinished stories and tasks (declare them as done, or not done). The not done stories will be automatically moved to the next sprint. But do not try this now, you first have to plan and achieve your first sprint!!! Be careful once a sprint is closed, it is irreversible!",
                    onNext: function (${tourName}) {
                        $.icescrum.openWindow('sprintPlan');
                    }
                },
                {
                    element: "#elem_sprintPlan",
                    title: "SprintPlan",
                    placement: "bottom",
                    content: "You are now on your “sprintplan” !",
                    onPrev: function (${tourName}) {
                        $.icescrum.openWindow('releaseplan');
                    }
                },
                {
                    element: "#widget-button-backlog",
                    title: "releasePlan",
                    placement: "right",
                    content: "Your product Backlog appears here, with the accepted and estimated stories. You can now drag them into your first sprint!"
                },
                {
                    element: "#backlog-layout-plan-releasePlan-9",
                    title: "releasePlan",
                    placement: "left",
                    content: "Once you have added your first stories, you can start your sprint!"
                },
                {
                    element: "#menu-postit-sprint-9",
                    title: "releasePlan",
                    placement: "left",
                    content: "Click here to open the sprint plan view, you can also click on « sprint plan »to access the same view."
                },
                {
                    element: "#menu-postit-sprint-9",
                    title: "releasePlan",
                    placement: "left",
                    content: "Once your sprint is achieved you will have to close it. By clicking here you can close your sprint and choose what to do with the unfinished stories and tasks (declare them as done, or not done). The not done stories will be automatically moved to the next sprint. But do not try this now, you first have to plan and achieve your first sprint!!! Be careful once a sprint is closed, it is irreversible!",
                    onNext: function (${tourName}) {
                        $.icescrum.openWindow('features')
                    }
                },
                {
                    element: "#backlog-layout-window-feature",
                    title: "Features",
                    placement: "left",
                    content: "You are now on your “Features”"
                },
                {
                    element: "#features-size",
                    title: "Features",
                    placement: "right",
                    content: "Here you can suggest features, just like you did for stories. "
                },
                {
                    element: "#menu-postit-feature-1",
                    title: "Features",
                    placement: "left",
                    content: "Here you can copy or delete a feature. And you can also move it to the Product Backlog."
                }
            ]
        });
        <g:if test="${autoStart}">
        ${tourName}.
        restart();
        </g:if>
    })(jQuery);
</script>