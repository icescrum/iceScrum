// -------------------------------------------------------------------
// markItUp!
// -------------------------------------------------------------------
// Copyright (C) 2008 Jay Salvat
// http://markitup.jaysalvat.com/
// -------------------------------------------------------------------
// Textile tags example
// http://en.wikipedia.org/wiki/Textile_(markup_language)
// http://www.textism.com/
// -------------------------------------------------------------------
// Feel free to add more tags
// -------------------------------------------------------------------
textileSettings = {
    previewParserPath:  '~/textileParser',
	onShiftEnter:		{keepDefault:false, replaceWith:'\n\n'},
	markupSet: [
        {
            name:'Text size', icon:'fa fa-text-height',
            dropMenu:[
                {name:'Heading 1', key:'1', openWith:'h1(!(([![Class]!]))!). ', placeHolder:'Your title here...' },
                {name:'Heading 2', key:'2', openWith:'h2(!(([![Class]!]))!). ', placeHolder:'Your title here...' },
                {name:'Heading 3', key:'3', openWith:'h3(!(([![Class]!]))!). ', placeHolder:'Your title here...' },
                {name:'Heading 4', key:'4', openWith:'h4(!(([![Class]!]))!). ', placeHolder:'Your title here...' },
                {name:'Heading 5', key:'5', openWith:'h5(!(([![Class]!]))!). ', placeHolder:'Your title here...' },
                {name:'Heading 6', key:'6', openWith:'h6(!(([![Class]!]))!). ', placeHolder:'Your title here...' }
            ]
        },
		{name:'Paragraph', icon:'fa fa-align-left', key:'P', openWith:'p(!(([![Class]!]))!). '},
		{name:'Bold', icon:'fa fa-bold', key:'B', closeWith:'*', openWith:'*'},
		{name:'Italic', icon:'fa fa-italic', key:'I', closeWith:'_', openWith:'_'},
		{name:'Stroke through', icon:'fa fa-strikethrough', key:'S', closeWith:'-', openWith:'-'},
		{name:'Bulleted list', icon:'fa fa-list-ul', key:'L', openWith:'(!(* |!|*)!)'},
		{name:'Numeric list', icon:'fa fa-list-ol', key:'N', openWith:'(!(# |!|#)!)'},
		{name:'Picture', icon:'fa fa-picture-o', key:'T', replaceWith:'![![Source:!:http://]!]([![Alternative text]!])!'},
		{name:'Link', icon:'fa fa-link', key:'U', openWith:'"', closeWith:'([![Title]!])":[![Link:!:http://]!]', placeHolder:'Your text to link here...' },
		{name:'Quotes', icon:'fa fa-quote-left', key:'Q', openWith:'bq(!(([![Class]!]))!). '},
		{name:'Code', icon:'fa fa-code', key:'O', openWith:'@', closeWith:'@'},
        {name:'BlockCode',icon:'fa fa-wrench', key:'K', openWith:'bc(!(([![Class]!]))!). '},
        {name:'Checkbox',icon:'fa fa-square-o', key:'E', openWith:'[] '},
        {name:'Checkbox with check',icon:'fa fa-check-square-o', key:'M', openWith:'[x] '}
	]
};