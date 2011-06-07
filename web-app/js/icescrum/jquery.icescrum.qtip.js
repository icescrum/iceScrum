$.fn.qtip.styles.classic = {
    border: {
        width: 0,
        radius: 5,
        color: '#fffdc0'
    },
    title: {
        background: '#fffca2',
        color: '#221f03',
        'font-weight': 'bold',
        padding:'2px 5px'
    },

    background: '#fffca2',
    color: '#221f03',

    width: {
        min: '200',
        max: '400'
    },
    name: 'light' // Inherit the rest of the attributes from the preset light style
};

$.fn.qtip.styles.icescrum = {
    classes: {
        title: 'qtip-title break-word',
        content: 'qtip-title break-word',
        tooltip: 'css3-shadow qtip-icescrum'
    },
    name: 'classic'
};

$.fn.qtip.styles.timeline = {
    classes: {
        title: 'qtip-title',
        content: 'qtip-title',
        tooltip: 'css3-shadow qtip-icescrum'
    },
    name: 'classic'
};