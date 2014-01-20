<underscore id="tpl-multiple-stories">
    <h3><a href="#">${message(code: "is.story")}</a></h3>
    <div id="right-story-container" class="right-properties">
        <div class="stack twisted">
            <div data-elemid="** story.id **" id="postit-story-** story.id **" class="postit story postit-story ui-selectee">
                <div class="postit-layout **# if(story.feature){ ** postit-** story.feature.color ** **# } **">
                    <p class="postit-id">
                        <a class="scrum-link" href="/icescrum/p/TESTPROJ#story/** story.id **">** story.id **</a>
                    </p>
                    <div class="icon-container"></div>
                    <p class="postit-label break-word">** story.name **</p>
                    <div class="postit-excerpt">** story.description **</div>
                    <span class="postit-ico ico-story-** story.type **"></span>
                    <div class="state task-state">
                        <span class="text-state">** $.icescrum.story.formatters.state(story) **</span>
                        <div class="dropmenu-action">
                            <div id="menu-postit-story-** story.id **"
                                 data-nowindows="false"
                                 data-offset="0"
                                 data-top="13"
                                 class="dropmenu"
                                 data-dropmenu="true">
                                <span class="dropmenu-arrow">!</span>
                                <div class="dropmenu-content ui-corner-all">
                                    <ul class="small">
                                        <li>
                                            <a data-ajax="true" data-ajax-notice="Story sent back to sandbox"
                                               data-ajax-trigger="returnToSandbox_story"
                                               href="/icescrum/p/1/story/returnToSandbox/** story.id **">return to sandbox</a>
                                        </li>
                                        <li>
                                            <a data-ajax="true"
                                               data-ajax-notice="The story has been successfully copied to the sandbox"
                                               data-ajax-trigger="add_story" href="/icescrum/p/1/story/copy/** story.id **">Copy</a>
                                        </li>
                                        <li>
                                            <a data-ajax="true" href="/icescrum/p/1/story/openDialogDelete/** story.id **">Delete</a>
                                        </li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</underscore>