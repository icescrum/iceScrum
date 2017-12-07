import org.icescrum.core.support.ApplicationSupport

/*
* Copyright (c) 2017 Kagilum SAS
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
* Vincent BARRIER (vbarrier@kagilum.com)
* Colin Bontemps (cbontemps@kagilum.com)
*
*/

databaseChangeLog = {
    changeSet(author: "vbarrier", id: "change_database_to_utf8mb4") {
        def databaseName = ApplicationSupport.getDatabaseName()
        preConditions(onFail: "MARK_RAN") {
            dbms(type: 'mysql')
            or {
                not {
                    sqlCheck(expectedResult: 'utf8mb4', 'SELECT SCHEMATA.`DEFAULT_COLLATION_NAME` FROM information_schema.SCHEMATA WHERE SCHEMA_NAME = "'+databaseName+'" LIMIT 1');
                }
                sqlCheck(expectedResult: '200', 'SELECT character_maximum_length FROM information_schema.columns WHERE table_name = "DATABASECHANGELOG" AND column_name = "FILENAME" and table_schema = "'+databaseName+'"')
            }
        }
        grailsChange {
            change {
                sql.execute("ALTER TABLE `DATABASECHANGELOG` CHANGE `ID` `ID` varchar(63) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `DATABASECHANGELOG` CHANGE `AUTHOR` `AUTHOR` varchar(63) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `DATABASECHANGELOG` CHANGE `EXECTYPE` `EXECTYPE` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `DATABASECHANGELOG` CHANGE `MD5SUM` `MD5SUM` varchar(35) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `DATABASECHANGELOG` CHANGE `DESCRIPTION` `DESCRIPTION` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `DATABASECHANGELOG` CHANGE `COMMENTS` `COMMENTS` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `DATABASECHANGELOG` CHANGE `TAG` `TAG` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `DATABASECHANGELOG` CHANGE `LIQUIBASE` `LIQUIBASE` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `DATABASECHANGELOGLOCK` CHANGE `LOCKEDBY` `LOCKEDBY` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `acl_class` CHANGE `class` `class` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `acl_sid` CHANGE `sid` `sid` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `attachmentable_attachment` CHANGE `content_type` `content_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `attachmentable_attachment` CHANGE `ext` `ext` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `attachmentable_attachment` CHANGE `input_name` `input_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `attachmentable_attachment` CHANGE `name` `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `attachmentable_attachment` CHANGE `poster_class` `poster_class` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `attachmentable_attachment` CHANGE `provider` `provider` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `attachmentable_attachment` CHANGE `url` `url` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `attachmentable_attachmentlink` CHANGE `attachment_ref_class` `attachment_ref_class` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `attachmentable_attachmentlink` CHANGE `type` `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `authority` CHANGE `authority` `authority` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `comment` CHANGE `poster_class` `poster_class` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `comment_link` CHANGE `type` `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_acceptance_test` CHANGE `description` `description` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_acceptance_test` CHANGE `name` `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_activity` CHANGE `code` `code` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_activity` CHANGE `field` `field` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_activity` CHANGE `parent_type` `parent_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_actor` CHANGE `name` `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_backlog` CHANGE `chart_type` `chart_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_backlog` CHANGE `code` `code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_backlog` CHANGE `filter` `filter` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_backlog` CHANGE `name` `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_backlog` CHANGE `notes` `notes` varchar(5000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_bugtracker` CHANGE `name` `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_bugtracker` CHANGE `password` `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_bugtracker` CHANGE `project_name` `project_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_bugtracker` CHANGE `project_tag` `project_tag` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_bugtracker` CHANGE `type` `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_bugtracker` CHANGE `url` `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_bugtracker` CHANGE `username` `username` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_bugtracker_import` CHANGE `name` `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_bugtracker_import` CHANGE `options_data` `options_data` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_bugtracker_import` CHANGE `tags` `tags` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_bugtracker_sync` CHANGE `field` `field` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_build` CHANGE `built_on` `built_on` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_build` CHANGE `built_on` `built_on` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_build` CHANGE `job_name` `job_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_build` CHANGE `name` `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_build` CHANGE `url` `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_event` CHANGE `name` `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_feature` CHANGE `color` `color` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_feature` CHANGE `description` `description` varchar(3000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_feature` CHANGE `name` `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_feature` CHANGE `notes` `notes` varchar(5000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_invitation` CHANGE `email` `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_invitation` CHANGE `token` `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_invitation` CHANGE `type` `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_project` CHANGE `name` `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_project` CHANGE `pkey` `pkey` varchar(10) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_project_preferences` CHANGE `daily_meeting_hour` `daily_meeting_hour` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_project_preferences` CHANGE `release_planning_hour` `release_planning_hour` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_project_preferences` CHANGE `sprint_planning_hour` `sprint_planning_hour` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_project_preferences` CHANGE `sprint_retrospective_hour` `sprint_retrospective_hour` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_project_preferences` CHANGE `sprint_review_hour` `sprint_review_hour` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_project_preferences` CHANGE `stake_holder_restricted_views` `stake_holder_restricted_views` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_project_preferences` CHANGE `timezone` `timezone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_release` CHANGE `name` `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_roadmap` CHANGE `code` `code` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_roadmap` CHANGE `name` `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_roadmap` CHANGE `notes` `notes` varchar(5000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_scm_commit` CHANGE `cid` `cid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_scm_commit` CHANGE `committer` `committer` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_scm_commit` CHANGE `url` `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_simple_project_app` CHANGE `app_definition_id` `app_definition_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_slack_preferences` CHANGE `url` `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_sprint` CHANGE `delivered_version` `delivered_version` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_story` CHANGE `affect_version` `affect_version` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_story` CHANGE `description` `description` varchar(3000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_story` CHANGE `name` `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_story` CHANGE `notes` `notes` varchar(5000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_story` CHANGE `origin` `origin` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_task` CHANGE `color` `color` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_task` CHANGE `description` `description` varchar(3000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_task` CHANGE `name` `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_task` CHANGE `notes` `notes` varchar(5000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_tbn_tpls` CHANGE `configs_data` `configs_data` varchar(5000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_tbn_tpls` CHANGE `footer` `footer` varchar(5000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_tbn_tpls` CHANGE `header` `header` varchar(5000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_tbn_tpls` CHANGE `name` `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_team` CHANGE `description` `description` varchar(1000) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_team` CHANGE `name` `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_team` CHANGE `uid` `uid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_template` CHANGE `item_class` `item_class` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_template` CHANGE `name` `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_up_widgets` CHANGE `type` `type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_up_widgets` CHANGE `widget_definition_id` `widget_definition_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_up_window` CHANGE `window_definition_id` `window_definition_id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_up_window` CHANGE `context` `context` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user` CHANGE `email` `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user` CHANGE `first_name` `first_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user` CHANGE `last_name` `last_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user` CHANGE `passwd` `passwd` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user` CHANGE `uid` `uid` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user` CHANGE `username` `username` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user_preferences` CHANGE `activity` `activity` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user_preferences` CHANGE `filter_task` `filter_task` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user_preferences` CHANGE `language` `language` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user_preferences` CHANGE `last_project_opened` `last_project_opened` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user_preferences_menu` CHANGE `menu_idx` `menu_idx` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user_preferences_menu` CHANGE `menu_elt` `menu_elt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user_preferences_menu_hidden` CHANGE `menu_hidden_idx` `menu_hidden_idx` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user_preferences_menu_hidden` CHANGE `menu_hidden_elt` `menu_hidden_elt` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user_tokens` CHANGE `id` `id` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user_tokens` CHANGE `name` `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `tag_links` CHANGE `type` `type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `tags` CHANGE `name` `name` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `comment` CHANGE `body` `body` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_activity` CHANGE `after_label` `after_label` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_activity` CHANGE `after_value` `after_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_activity` CHANGE `before_value` `before_value` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_activity` CHANGE `label` `label` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_availability` CHANGE `days_data` `days_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_cliche` CHANGE `data` `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_release` CHANGE `vision` `vision` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_roadmap` CHANGE `data` `data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_scm_commit` CHANGE `added_data` `added_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_scm_commit` CHANGE `message` `message` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_scm_commit` CHANGE `modified_data` `modified_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_scm_commit` CHANGE `removed_data` `removed_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_sprint` CHANGE `done_definition` `done_definition` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_sprint` CHANGE `retrospective` `retrospective` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_template` CHANGE `serialized_data` `serialized_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_timebox` CHANGE `description` `description` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_timebox` CHANGE `goal` `goal` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_up_widgets` CHANGE `settings_data` `settings_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_up_window` CHANGE `settings_data` `settings_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user_preferences` CHANGE `emails_settings_data` `emails_settings_data` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER DATABASE `"+ databaseName +"` CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `acl_class` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `acl_entry` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `acl_object_identity` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `acl_sid` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `attachmentable_attachment` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `attachmentable_attachmentlink` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `authority` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `comment` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `comment_link` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `DATABASECHANGELOGLOCK` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_acceptance_test` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_acceptance_test_is_activity` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_activity` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_actor` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_availability` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_availability_preferences` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_backlog` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_build` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_build_is_task` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_cliche` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_event` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_feature` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_feature_is_activity` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_invitation` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_mood` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_project` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_project_preferences` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_project_teams` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_release` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_roadmap` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_scm_commit` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_scm_commit_is_task` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_simple_project_app` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_slack_preferences` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_sprint` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_story` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_story_actors` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_story_is_activity` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_story_is_user` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_task` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_task_is_activity` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_task_is_user` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_tbn_tpls` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_team` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_team_members` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_template` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_timebox` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_timebox_is_activity` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_up_widgets` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_up_window` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user_preferences` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user_preferences_menu` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user_preferences_menu_hidden` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `is_user_tokens` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `tags` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `tag_links` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `user_authority` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `DATABASECHANGELOG` CHANGE `FILENAME` `FILENAME` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
                sql.execute("ALTER TABLE `DATABASECHANGELOG` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;");
            }
        }
    }
}