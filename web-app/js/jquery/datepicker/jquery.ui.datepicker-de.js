/* English/UK initialisation for the jQuery UI date picker plugin. */
/* Written by Stuart. */
jQuery(function($){
	$.datepicker.regional['de'] = {
		closeText: 'Fertig',
		prevText: 'Zur\u00fcck',
		nextText: 'Weiter',
		currentText: 'Heute',
		monthNames: ['Januar','Februar','M\u00e4rz','April','Mai','Juni',
		'Juli','August','September','Oktober','November','Dezember'],
		monthNamesShort: ['Jan', 'Feb', 'M\u00e4r', 'Apr', 'Mai', 'Jun',
		'Jul', 'Aug', 'Sep', 'Okt', 'Nov', 'Dez'],
		dayNames: ['Sonntag', 'Montag', 'Dienstag', 'Mittwoch', 'Donnerstag', 'Freitag', 'Samstag'],
		dayNamesShort: ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'],
		dayNamesMin: ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'],
		weekHeader: 'Wo',
		dateFormat: 'dd.mm.yy',
		firstDay: 1,
		isRTL: false,
		showMonthAfterYear: false,
		yearSuffix: ''};
	$.datepicker.setDefaults($.datepicker.regional['de']);
});