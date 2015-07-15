<g:include view="scrumOS/guidedTour/_project.gsp" model="[title:message(code:'is.ui.guidedTour.project.title').encodeAsJavaScript()]" />,
<g:include view="scrumOS/guidedTour/_feature.gsp" model="[title:message(code:'is.ui.guidedTour.feature.title').encodeAsJavaScript()]" />,
<g:include view="scrumOS/guidedTour/_actor.gsp" model="[title:message(code:'is.ui.guidedTour.actor.title').encodeAsJavaScript()]" />,
<g:include view="scrumOS/guidedTour/_sandbox.gsp" model="[title:message(code:'is.ui.guidedTour.sandbox.title').encodeAsJavaScript()]" />,
<g:include view="scrumOS/guidedTour/_backlog.gsp" model="[title:message(code:'is.ui.guidedTour.backlog.title').encodeAsJavaScript()]" />,
<g:include view="scrumOS/guidedTour/_timeline.gsp" model="[title:message(code:'is.ui.guidedTour.timeline.title').encodeAsJavaScript()]" />,
<g:include view="scrumOS/guidedTour/_releasePlan.gsp" model="[title:message(code:'is.ui.guidedTour.releasePlan.title').encodeAsJavaScript()]" />,
<g:include view="scrumOS/guidedTour/_sprintPlan.gsp" model="[title:message(code:'is.ui.guidedTour.sprintPlan.title').encodeAsJavaScript()]" />
<entry:point id="${controllerName}-${actionName}-fullProject"/>
