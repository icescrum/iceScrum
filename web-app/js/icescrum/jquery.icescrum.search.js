/*
 * Copyright (c) 2013 Kagilum SAS.
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
 * Nicolas Noullet (nnoullet@kagilum.com)
 *
 */

$(document).on('domUpdate.icescrum', function (event, content) {

    $('.auto-complete-searchable', content).each(function () {

        var autocompletable = $(this);
        var update = autocompletable.data('update');
        var url = autocompletable.data('url');
        var tagUrl = autocompletable.data('tag-url');
        var minLength = autocompletable.data('min-length');
        var searchOnInit = autocompletable.data('search-on-init');

        function filterWindowContent(term) {
            $.ajax({
                url: url,
                data: {
                    term: term,
                    viewType: $.icescrum.getDefaultView()
                },
                success: function (data) {
                    $('#' + update).html(data);
                    autocompletable.trigger('autocompleteupdated');
                    $.doTimeout(200, function () {
                        autocompletable.focus()
                    })
                }
            });
        }

        autocompletable.autocomplete({
            minLength: minLength,
            source: function (request, response) {
                filterWindowContent(request.term);
                if (tagUrl) {
                    $.ajax({
                        url: tagUrl,
                        data: request,
                        dataType: "json",
                        success: function (data) {
                            response(data);
                        },
                        error: function () {
                            response([]);
                        }
                    });
                } else {
                    response({});
                }
            },
            select: function (event, ui) {
                filterWindowContent(ui.item.value);
            },
            focus: function (event, ui) {
                event.preventDefault(); // disable update of input content on focus
            },
            search: function (event, ui) {
                var searchButton = $('#search-ui').find('.search-button');
                if ($(this).val().length > 0) {
                    searchButton.addClass('active-search');
                } else {
                    searchButton.removeClass('active-search');
                }
            }
        });

        if (searchOnInit) {
            autocompletable.autocomplete('search');
        }
    });
});
