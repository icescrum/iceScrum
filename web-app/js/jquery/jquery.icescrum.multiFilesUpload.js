/*
 * Copyright (c) 2010 iceScrum Technologies.
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
 * Vincent Barrier (vincent.barrier@icescrum.com)
 *
 */

(function($) {

    $.fn.multiFilesUpload = function(options) {

        var settings = {
            width : 250,
            onSelect: function(input,form){},
            accept: null,
            size:23,
            multi:5,
            imageheight : 22,
            imagewidth : 65,
            name:'file',
            urlUpload:'/',
            progress:null,
            onUploadComplete:function(fileID){},
            i18n: {
                fileNotAccepted:"File type not accepted",
                fileAlReadyAdded:"File already added",
                fileUploaded:": successfully uploaded"
            }
        };

        if(options) {
            $.extend(settings, options);
        }

        //Elements
        var root = $(this);
        root.addClass("is-multifiles");

        var multiFilesUploadDiv = $('<div>').addClass("is-multifiles-select");
        var input = $('<input>').attr('type','file').attr('name','file').css({"position": "relative","height": settings.imageheight + "px","width": settings.width + "px","display": "inline","cursor": "pointer","opacity": "0.0"});
        var button = $("<div>").css({"width": settings.imagewidth + "px","height": settings.imageheight + "px","background": "url(" + settings.image + ") 0 0 no-repeat"}).addClass('is-multifiles-button');

        if((root.find('.is-multifiles-filename').size() >= settings.multi)){
            multiFilesUploadDiv.hide();
        }

        $(this).append(multiFilesUploadDiv);
        multiFilesUploadDiv.append(input);
        input.wrap(button);

        if ($.browser.mozilla) {
            if (/Win/.test(navigator.platform)) {
                input.css("margin-left", "-142px");
            } else {
                input.css("margin-left", "-168px");
            }
        } else {
            input.css("margin-left", settings.imagewidth - settings.width + "px");
        }

        input.bind("change", function() {
            var obj = $(this);
            //var form = input.parent().parent();
            var win = /.*\\(.*)/;
            var fileTitleC = obj.val().replace(win, "$1");
            var unix = /.*\/(.*)/;
            fileTitleC = fileTitleC.replace(unix, "$1");
            var extReg =/.*\.(.*)/;
            var ext = fileTitleC.replace(extReg, "$1");
            var fileTitle = fileTitleC;
            if (fileTitleC.length > settings.size){
                fileTitle = fileTitleC.substr(0,settings.size - 1)+"...";
            }
            var pos;
            if (ext){

                //File type not accepted ?
                if (settings.accept != null){
                    if($.inArray(ext, settings.accept) == -1){
                        $.icescrum.renderNotice(settings.i18n.fileNotAccepted+' ('+settings.accept+')',"error");
                        obj.val('');
                        return;
                    }
                }

                //Already added same file ?
                var identical = $(".is-multifiles-filename span[title$='"+fileTitleC+"']").size();
                if(identical){
                    $.icescrum.renderNotice(settings.i18n.fileAlReadyAdded,"error");
                    obj.val('');
                    return;
                }
                //remove button
                obj.parent().remove();
                //Move stuff to hidden form and process
                var fileID = 'fileID-'+new Date().getTime();
                var multiFilesUploadForm = $('<div>').attr("class","is-multifiles-form").attr('id',fileID);
                var url = settings.urlUpload+"?X-Progress-ID="+fileID;
                var form = $('<form>').attr('method',"post").attr('action',url).attr('target',fileID).attr('enctype','multipart/form-data');
                var iframe = $('<iframe name="'+fileID+'" src="" style="display: none"></iframe>');
                $(document.body).append(form);
                form.wrap(multiFilesUploadForm);
                form.append(input);
                form.after(iframe);

                //Create friendly filename div
                var filename = $('<div class="is-multifiles-filename">').css({"display": "none","margin-left": settings.imagewidth + 5 + "px"});
                filename.css('margin-left',0).css('display','inline-block').addClass('file-icon').addClass(ext.toLowerCase()+'-format');
                filename.append($('<span>').html(fileTitle).attr('title',fileTitleC));
                //Display filename & ext image
                multiFilesUploadDiv.append(filename);

                root.multiFilesUpload(settings);

                //Create an cancel button
                var cancel = $('<div class="ui-icon ui-icon-cancel"></div>');
                //Create an cancel upaload button
                cancel.bind('click',function(){
                    if(root.find(".is-multifiles-button :visible").size() == 0){
                        root.multiFilesUpload(settings);
                    }
                    $('#'+fileID+' form').remove();
                    $('#'+fileID+' iframe').remove();
                    setTimeout(function(){
                        $('#'+fileID).remove();
                    },50);
                    multiFilesUploadDiv.remove();
                });
                filename.append(cancel);

                //Setting progressbar
                settings.progress.startOn = form;
                settings.progress.startOnWhen = "submit";
                settings.progress.params = {'X-Progress-ID':fileID};
                settings.progress.timerID = fileID;
                //Create an hidden progress bar
                var progressBar = $('<span>').attr('id',fileID);

                //What we do on error
                progressBar.bind('error',function(event,ui,data){
                    $('#'+fileID+' form').remove();
                    $('#'+fileID+' iframe').remove();
                    multiFilesUploadDiv.remove();
                    setTimeout(function(){
                        $('#'+fileID).remove();
                    },50);
                    if (data.label != null){
                        $.icescrum.renderNotice(data.label,"error");
                    }else{
                        $.icescrum.renderNotice(data.notice.text,"error");
                    }
                    if(root.find(".is-multifiles-button :visible").size() == 0){
                        root.multiFilesUpload(settings);
                    }
                });

                //What we do on success
                progressBar.bind('complete',function(event,ui,data){
                    var wrap = $('<div>');
                    var filenameCloned = filename.clone(true);
                    filenameCloned.find('.ui-icon-cancel').remove();
                    multiFilesUploadDiv.replaceWith(wrap);
                    var checkbox = wrap.checkBoxFile(settings.name,fileID+':'+fileTitleC,settings);
                    checkbox.after(filenameCloned).attr('idFile',fileID);
                    $('#'+fileID+' form').remove();
                    $('#'+fileID+' iframe').remove();
                    setTimeout(function(){
                        $('#'+fileID).remove();
                    },50);
                    $.icescrum.renderNotice(fileTitleC+': '+settings.i18n.fileUploaded);
                    settings.onUploadComplete(fileID);
                });

                multiFilesUploadDiv.append(progressBar);
                progressBar.progress(settings.progress);
                form.submit();
            }
        });
    },

     $.fn.checkBoxFile = function(name,value,settings){
        $(this).addClass('is-multifiles-checkbox');
        var checkbox = $('<input>').attr('type','checkbox').attr('name',name).attr('value',value).attr('checked','checked').addClass('is-multifiles-uploaded');
        $(this).append(checkbox);
        checkbox.bind("change",function(){
            if (!checkbox.attr('checked')){
                if(checkbox.parents('.inputfile:first .is-multifiles-button :visible').size() == 0){
                    checkbox.parents('.inputfile:first .is-multifiles-select:hidden').first().show();
                }
                checkbox.parent().remove();
            }
        });
        checkbox.checkBox();
        return checkbox;
    };

})(jQuery);