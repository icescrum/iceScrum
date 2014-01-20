/*
 * Copyright (c) 2014 Kagilum SAS.
 *
 * This file is part of iceScrum.
 *
 * iceScrum is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as published by
 * the Free Software Foundation, either version 3 of the License.
 *
 * iceScrum is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with iceScrum.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *
 * Vincent Barrier (vbarrier@kagilum.com)
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */
(function($) {
    $.extend($.icescrum, {
        acceptancetest:{

            i18n:{
                noAcceptanceTest:'no acceptance test'
            },

            templates:{
                storyDetail:{
                    selector:'li.acceptance-test',
                    id:'acceptancetest-storydetail-tmpl',
                    view:'ul.list-acceptance-tests',
                    remove:function(tmpl) {
                        var acceptanceTests = $(tmpl.view);
                        var acceptanceTest = $(tmpl.selector + '[data-elemid=' + this.id + ']', acceptanceTests);
                        acceptanceTest.remove();
                        if ($(tmpl.selector, acceptanceTests).length == 0) {
                            acceptanceTests.html('<li class="panel-box-empty">' + $.icescrum.acceptancetest.i18n.noAcceptanceTest + '</li>');
                        }
                        acceptanceTests.find('li.last').removeClass('last');
                        acceptanceTests.find('li:last').addClass('last');
                    },
                    afterTmpl:function(tmpl, container){
                        container.find('li.last').removeClass('last');
                        container.find('li:last').addClass('last');
                    }
                }
            },

            add:function(template) {
                var tmpl = $.icescrum.acceptancetest.templates[template];
                var acceptanceTests = $(tmpl.view);
                if(acceptanceTests.find('li.panel-box-empty').length > 0) {
                    acceptanceTests.html('');
                }
                $(this).each(function() {
                    var acceptanceTest = $.icescrum.addOrUpdate(this, tmpl, $.icescrum.acceptancetest._postRendering);
                });
            },

            update:function(template) {
                $(this).each(function() {
                    $.icescrum.addOrUpdate(this, $.icescrum.acceptancetest.templates[template], $.icescrum.acceptancetest._postRendering);
                });
            },

            _postRendering:function(tmpl, acceptanceTest) {
                if (!$.icescrum.user.inProduct() || this.parentStory.state >= $.icescrum.story.STATE_DONE) {
                    acceptanceTest.find('.acceptance-test-menu').remove();
                }
                var description = $('.acceptance-test-description', acceptanceTest);
                if (this.description != null) {
                    description.load(jQuery.icescrum.o.baseUrl + 'textileParser', {data:this.description,withoutHeader:true});
                } else {
                    description.text('');
                }
                if (!$.icescrum.user.inProduct() || this.parentStory.state != $.icescrum.story.STATE_INPROGRESS) {
                    $('.acceptance-test-state', acceptanceTest).html(
                        '<div class="text-icon-acceptance-test icon-acceptance-test' +  this.state + '">' +
                            $.icescrum.acceptancetest.stateLabels[this.state] +
                            '</div>'
                    );
                }
                else {
                    var select = $('.acceptance-test-state-select', acceptanceTest);
                    select.val(this.state);
                }
            },

            remove:function(template) {
                var tmpl = $.icescrum.acceptancetest.templates[template];
                $(this).each(function() {
                    tmpl.remove.apply(this, [tmpl]);
                });
            }
        }
    })
})($);