(function($) {
    jQuery.extend($.icescrum, {
                autoCompleteSearch:function(request, response, url, params) {
                    if (params.before) {
                        params.before();
                    }
                    $.ajax({
                                url: url,
                                data: {
                                    term: request.term,
                                    viewType:$.icescrum.getDefaultView()
                                },
                                success: function(data) {
                                    $('#' + params.update).html(data);
                                    response({});
                                    var obj = $(this);
                                    $.doTimeout(200, function() {
                                        $('#autoCmpTxt').focus()
                                    })
                                }
                            });
                },

                createCompleteResult:function(item, idfieldname, term) {
                    var res = '<div class="list-selectable-item ui-selectable" id="resultComplete-id-' + item.id + '">';
                    res += '<img class="ico" src="' + item.image + '" />';
                    res += '<p><strong>' + item.label + '</strong></p>';
                    res += '<p>' + item.extra + '</p>';
                    res += '<input class="id" type="hidden" name="_' + idfieldname + '" value="' + item.id + '"></input>';
                    res += '</div>';
                    return res;
                },

                createCompleteSelected:function(item, idfieldname, id) {
                    var res = '<div class="field-choose-list-item clearfix">';
                    res += '<span class=" button-s button-s-light clearfix"><span class="start"></span>';
                    res += '<span class="content">' + item + '<span class="button-action button-delete" style="display: none;">del</span></span>';
                    res += '<span class="end"></span></span>';
                    res += '<input class="id" type="hidden" name="' + idfieldname + '" value="' + id + '"></input>';
                    res += '</div>';
                    return res;
                    // elem list
                },

                chooseSelected:function(source, target, fieldname) {
                    var result = $("#" + target);
                    var id;
                    var input;
                    var label;
                    $("#" + source + " .ui-selected").each(function() {
                        input = $(this).find("input");
                        label = $(this).find("strong").html();
                        id = input.val();
                        if (!$('#' + target + ' input.id[value=' + id + ']').length > 0) {
                            result.append($.icescrum.createCompleteSelected(label, fieldname, id));
                        }
                        $(this).removeClass('ui-selected');
                    });
                    $('.button-s .button-action').click(function() {
                        $(this).parent().parent().parent().remove();
                    });
                    $('.button-s').hover(function() {
                        $(this).find('.button-action').show();
                    }, function() {
                        $(this).find('.button-action').hide();
                    });
                },

                autoCompleteChoose:function(request, response, url, params) {
                    var fieldname = params && params.idfieldname ? params.idfieldname : 'searchid';
                    $.ajax({
                                url: url,
                                data: {
                                    term: request.term
                                },
                                success: function(data) {
                                    var out = '';
                                    $.each(data, function(index, item) {
                                        out += $.icescrum.createCompleteResult(item, fieldname, request.term);
                                    });
                                    var selectNode = $('#' + params.selectId);
                                    selectNode.html(out);
                                    selectNode.selectable({
                                                filter:'.ui-selectable',
                                                selected:function(event, ui) {
                                                    $.icescrum.dblclickSelectable(ui, 300, function() {
                                                        $.icescrum.chooseSelected(params.selectId, params.listId, fieldname);
                                                        return false;
                                                    });
                                                }
                                            });
                                    $('.ui-selectable', selectNode).draggable({opacity: 0.8, helper: 'clone',handle:'.ico'});
                                    response({});
                                }
                            });
                }
            })
})(jQuery);