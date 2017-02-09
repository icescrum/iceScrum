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
*
*/

databaseChangeLog = {
    include file: "changelog-7.0.2.groovy"
}

databaseChangeLog = {

    changeSet(author: "noullet (generated)", id: "1486138528818-1") {
        createTable(tableName: "acl_class") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "class", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-2") {
        createTable(tableName: "acl_entry") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "ace_order", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "acl_object_identity", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "audit_failure", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "audit_success", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "granting", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "mask", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "sid", type: "BIGINT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-3") {
        createTable(tableName: "acl_object_identity") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "object_id_class", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "entries_inheriting", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "object_id_identity", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "owner_sid", type: "BIGINT")

            column(name: "parent_object", type: "BIGINT")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-4") {
        createTable(tableName: "acl_sid") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "principal", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "sid", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-5") {
        createTable(tableName: "attachmentable_attachment") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "content_type", type: "VARCHAR(255)")

            column(name: "date_created", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "ext", type: "VARCHAR(255)")

            column(name: "input_name", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "length", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "name", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "poster_class", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "poster_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "provider", type: "VARCHAR(255)")

            column(name: "url", type: "VARCHAR(1000)")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-6") {
        createTable(tableName: "attachmentable_attachmentlink") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "attachment_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "attachment_ref", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "attachment_ref_class", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "type", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-7") {
        createTable(tableName: "authority") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "authority", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-8") {
        createTable(tableName: "comment") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "body", type: "LONGTEXT") {
                constraints(nullable: "false")
            }

            column(name: "date_created", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "last_updated", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "poster_class", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "poster_id", type: "BIGINT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-9") {
        createTable(tableName: "comment_link") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "comment_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "comment_ref", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "type", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-10") {
        createTable(tableName: "is_acceptance_test") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "creator_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "date_created", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "description", type: "VARCHAR(1000)")

            column(name: "last_updated", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "name", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "parent_story_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "state", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "uid", type: "INT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-11") {
        createTable(tableName: "is_acceptance_test_is_activity") {
            column(name: "acceptance_test_activities_id", type: "BIGINT")

            column(name: "activity_id", type: "BIGINT")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-12") {
        createTable(tableName: "is_activity") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "after_label", type: "LONGTEXT")

            column(name: "after_value", type: "LONGTEXT")

            column(name: "before_value", type: "LONGTEXT")

            column(name: "code", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "date_created", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "field", type: "VARCHAR(255)")

            column(name: "label", type: "LONGTEXT") {
                constraints(nullable: "false")
            }

            column(name: "last_updated", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "parent_ref", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "parent_type", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "poster_id", type: "BIGINT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-13") {
        createTable(tableName: "is_actor") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "name", type: "VARCHAR(100)") {
                constraints(nullable: "false")
            }

            column(name: "parent_project_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "uid", type: "INT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-14") {
        createTable(tableName: "is_availability") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "days_data", type: "LONGTEXT") {
                constraints(nullable: "false")
            }

            column(name: "expected_availability", type: "DOUBLE") {
                constraints(nullable: "false")
            }

            column(name: "sprint_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "user_id", type: "BIGINT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-15") {
        createTable(tableName: "is_availability_preferences") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "default_availability", type: "DOUBLE") {
                constraints(nullable: "false")
            }

            column(name: "display_latitude", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "enable", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "high_lr", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "low_lr", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "medium_lr", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "parent_project_id", type: "BIGINT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-16") {
        createTable(tableName: "is_backlog") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "code", type: "VARCHAR(100)") {
                constraints(nullable: "false")
            }

            column(name: "filter", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "name", type: "VARCHAR(100)") {
                constraints(nullable: "false")
            }

            column(name: "notes", type: "VARCHAR(5000)")

            column(name: "owner_id", type: "BIGINT")

            column(name: "project_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "shared", type: "BIT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-17") {
        createTable(tableName: "is_bugtracker") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "enabled", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "name", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "password", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "project_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "projectid", type: "DECIMAL(19,2)") {
                constraints(nullable: "false")
            }

            column(name: "project_name", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "project_tag", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "type", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "url", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "username", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-18") {
        createTable(tableName: "is_bugtracker_import") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "allow_duplicate", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "bt_config_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "feature_id", type: "BIGINT")

            column(name: "name", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "options_data", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "pull", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "state", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "tags", type: "VARCHAR(255)")

            column(name: "type", type: "INT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-19") {
        createTable(tableName: "is_bugtracker_sync") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "bt_config_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "field", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "on_state", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "options", type: "LONGTEXT")

            column(name: "value", type: "LONGTEXT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-20") {
        createTable(tableName: "is_build") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "built_on", type: "VARCHAR(255)")

            column(name: "date", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "job_name", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "name", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "number", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "project_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "status", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "url", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-21") {
        createTable(tableName: "is_build_is_task") {
            column(name: "build_tasks_id", type: "BIGINT")

            column(name: "task_id", type: "BIGINT")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-22") {
        createTable(tableName: "is_cliche") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "data", type: "LONGTEXT") {
                constraints(nullable: "false")
            }

            column(name: "date_prise", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "parent_time_box_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "type", type: "INT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-23") {
        createTable(tableName: "is_feature") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "backlog_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "color", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "date_created", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "description", type: "VARCHAR(3000)")

            column(name: "last_updated", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "name", type: "VARCHAR(100)") {
                constraints(nullable: "false")
            }

            column(name: "notes", type: "VARCHAR(5000)")

            column(name: "parent_release_id", type: "BIGINT")

            column(name: "rank", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "todo_date", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "type", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "uid", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "value", type: "INT")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-24") {
        createTable(tableName: "is_feature_is_activity") {
            column(name: "feature_activities_id", type: "BIGINT")

            column(name: "activity_id", type: "BIGINT")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-25") {
        createTable(tableName: "is_invitation") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "date_created", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "email", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "future_role", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "project_id", type: "BIGINT")

            column(name: "team_id", type: "BIGINT")

            column(name: "token", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "type", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-26") {
        createTable(tableName: "is_mood") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "feeling", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "feeling_day", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "user_id", type: "BIGINT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-27") {
        createTable(tableName: "is_project") {
            column(name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "name", type: "VARCHAR(200)")

            column(name: "pkey", type: "VARCHAR(10)")

            column(name: "planning_poker_game_type", type: "INT")

            column(name: "preferences_id", type: "BIGINT")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-28") {
        createTable(tableName: "is_project_preferences") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "archived", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "assign_on_begin_task", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "assign_on_create_task", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "auto_create_task_on_empty_story", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "auto_done_story", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "daily_meeting_hour", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "display_recurrent_tasks", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "display_urgent_tasks", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "estimated_sprints_duration", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "hidden", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "hide_weekend", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "limit_urgent_tasks", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "no_estimation", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "release_planning_hour", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "sprint_planning_hour", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "sprint_retrospective_hour", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "sprint_review_hour", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "stake_holder_restricted_views", type: "VARCHAR(255)")

            column(name: "timezone", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "webservices", type: "BIT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-29") {
        createTable(tableName: "is_project_teams") {
            column(defaultValueNumeric: "0", name: "project_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "team_id", type: "BIGINT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-30") {
        createTable(tableName: "is_release") {
            column(name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "done_date", type: "DATETIME")

            column(name: "first_sprint_index", type: "INT")

            column(name: "in_progress_date", type: "DATETIME")

            column(name: "name", type: "VARCHAR(255)")

            column(name: "parent_project_id", type: "BIGINT")

            column(name: "state", type: "INT")

            column(name: "vision", type: "LONGTEXT")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-31") {
        createTable(tableName: "is_scm_commit") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "added_data", type: "LONGTEXT") {
                constraints(nullable: "false")
            }

            column(name: "author_id", type: "BIGINT")

            column(name: "cid", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "committer", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "date", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "message", type: "LONGTEXT") {
                constraints(nullable: "false")
            }

            column(name: "modified_data", type: "LONGTEXT") {
                constraints(nullable: "false")
            }

            column(name: "removed_data", type: "LONGTEXT") {
                constraints(nullable: "false")
            }

            column(name: "url", type: "VARCHAR(255)")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-32") {
        createTable(tableName: "is_scm_commit_is_task") {
            column(name: "commit_tasks_id", type: "BIGINT")

            column(name: "task_id", type: "BIGINT")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-33") {
        createTable(tableName: "is_scm_preferences") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "enable", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "enable_build", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "parent_project_id", type: "BIGINT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-34") {
        createTable(tableName: "is_sprint") {
            column(name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "capacity", type: "DOUBLE")

            column(name: "daily_work_time", type: "DOUBLE")

            column(name: "delivered_version", type: "VARCHAR(255)")

            column(name: "done_date", type: "DATETIME")

            column(name: "done_definition", type: "LONGTEXT")

            column(name: "in_progress_date", type: "DATETIME")

            column(name: "initial_remaining_time", type: "FLOAT")

            column(name: "parent_release_id", type: "BIGINT")

            column(name: "retrospective", type: "LONGTEXT")

            column(name: "state", type: "INT")

            column(name: "velocity", type: "DOUBLE")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-35") {
        createTable(tableName: "is_story") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "accepted_date", type: "DATETIME")

            column(name: "actor_id", type: "BIGINT")

            column(name: "affect_version", type: "VARCHAR(255)")

            column(name: "backlog_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "creator_id", type: "BIGINT")

            column(name: "date_created", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "depends_on_id", type: "BIGINT")

            column(name: "description", type: "VARCHAR(3000)")

            column(name: "done_date", type: "DATETIME")

            column(name: "effort", type: "DECIMAL(5,2)")

            column(name: "estimated_date", type: "DATETIME")

            column(name: "feature_id", type: "BIGINT")

            column(name: "in_progress_date", type: "DATETIME")

            column(name: "last_updated", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "name", type: "VARCHAR(100)") {
                constraints(nullable: "false")
            }

            column(name: "notes", type: "VARCHAR(5000)")

            column(name: "origin", type: "VARCHAR(255)")

            column(name: "parent_sprint_id", type: "BIGINT")

            column(name: "planned_date", type: "DATETIME")

            column(name: "rank", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "state", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "suggested_date", type: "DATETIME")

            column(name: "todo_date", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "type", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "uid", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "value", type: "INT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-36") {
        createTable(tableName: "is_story_is_activity") {
            column(name: "story_activities_id", type: "BIGINT")

            column(name: "activity_id", type: "BIGINT")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-37") {
        createTable(tableName: "is_story_is_user") {
            column(name: "story_followers_id", type: "BIGINT")

            column(name: "user_id", type: "BIGINT")

            column(name: "story_voters_id", type: "BIGINT")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-38") {
        createTable(tableName: "is_task") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "backlog_id", type: "BIGINT")

            column(name: "blocked", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "color", type: "VARCHAR(255)")

            column(name: "creator_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "date_created", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "description", type: "VARCHAR(3000)")

            column(name: "done_date", type: "DATETIME")

            column(name: "estimation", type: "FLOAT")

            column(name: "in_progress_date", type: "DATETIME")

            column(name: "initial", type: "FLOAT")

            column(name: "last_updated", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "name", type: "VARCHAR(100)") {
                constraints(nullable: "false")
            }

            column(name: "notes", type: "VARCHAR(5000)")

            column(name: "parent_project_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "parent_story_id", type: "BIGINT")

            column(name: "rank", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "responsible_id", type: "BIGINT")

            column(name: "state", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "todo_date", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "type", type: "INT")

            column(name: "uid", type: "INT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-39") {
        createTable(tableName: "is_task_is_activity") {
            column(name: "task_activities_id", type: "BIGINT")

            column(name: "activity_id", type: "BIGINT")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-40") {
        createTable(tableName: "is_task_is_user") {
            column(name: "task_participants_id", type: "BIGINT")

            column(name: "user_id", type: "BIGINT")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-41") {
        createTable(tableName: "is_team") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "date_created", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "description", type: "VARCHAR(1000)")

            column(name: "last_updated", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "name", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "uid", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "velocity", type: "INT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-42") {
        createTable(tableName: "is_team_members") {
            column(name: "user_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "team_id", type: "BIGINT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-43") {
        createTable(tableName: "is_template") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "item_class", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "name", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "parent_project_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "serialized_data", type: "LONGTEXT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-44") {
        createTable(tableName: "is_timebox") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "date_created", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "description", type: "LONGTEXT")

            column(name: "end_date", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "goal", type: "LONGTEXT")

            column(name: "last_updated", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "order_number", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "start_date", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "todo_date", type: "DATETIME") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-45") {
        createTable(tableName: "is_timebox_is_activity") {
            column(name: "time_box_activities_id", type: "BIGINT")

            column(name: "activity_id", type: "BIGINT")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-46") {
        createTable(tableName: "is_up_widgets") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "on_right", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "position", type: "INT") {
                constraints(nullable: "false")
            }

            column(name: "settings_data", type: "LONGTEXT")

            column(name: "user_preferences_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "widget_definition_id", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-47") {
        createTable(tableName: "is_user") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "account_expired", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "account_external", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "account_locked", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "date_created", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "email", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "enabled", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "first_name", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "last_login", type: "DATETIME")

            column(name: "last_name", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "last_updated", type: "DATETIME") {
                constraints(nullable: "false")
            }

            column(name: "passwd", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "password_expired", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "preferences_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "uid", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "username", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-48") {
        createTable(tableName: "is_user_preferences") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "activity", type: "VARCHAR(255)")

            column(name: "display_full_project_tour", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "display_welcome_tour", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "display_whats_new", type: "BIT") {
                constraints(nullable: "false")
            }

            column(name: "emails_settings_data", type: "LONGTEXT")

            column(name: "filter_task", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "language", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }

            column(name: "last_project_opened", type: "VARCHAR(255)")

            column(name: "last_read_activities", type: "DATETIME") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-49") {
        createTable(tableName: "is_user_preferences_menu") {
            column(name: "menu", type: "BIGINT")

            column(name: "menu_idx", type: "VARCHAR(255)")

            column(name: "menu_elt", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-50") {
        createTable(tableName: "is_user_preferences_menu_hidden") {
            column(name: "menu_hidden", type: "BIGINT")

            column(name: "menu_hidden_idx", type: "VARCHAR(255)")

            column(name: "menu_hidden_elt", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-51") {
        createTable(tableName: "tag_links") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "tag_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "tag_ref", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "type", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-52") {
        createTable(tableName: "tags") {
            column(autoIncrement: "true", name: "id", type: "BIGINT") {
                constraints(nullable: "false", primaryKey: "true")
            }

            column(name: "version", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "name", type: "VARCHAR(255)") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-53") {
        createTable(tableName: "user_authority") {
            column(name: "authority_id", type: "BIGINT") {
                constraints(nullable: "false")
            }

            column(name: "user_id", type: "BIGINT") {
                constraints(nullable: "false")
            }
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-54") {
        addPrimaryKey(columnNames: "project_id, team_id", tableName: "is_project_teams")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-55") {
        addPrimaryKey(columnNames: "team_id, user_id", tableName: "is_team_members")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-56") {
        addPrimaryKey(columnNames: "authority_id, user_id", tableName: "user_authority")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-135") {
        createIndex(indexName: "UK_iy7ua5fso3il3u3ymoc4uf35w", tableName: "acl_class", unique: "true") {
            column(name: "class")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-136") {
        createIndex(indexName: "unique_ace_order", tableName: "acl_entry", unique: "true") {
            column(name: "acl_object_identity")

            column(name: "ace_order")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-137") {
        createIndex(indexName: "unique_object_id_identity", tableName: "acl_object_identity", unique: "true") {
            column(name: "object_id_class")

            column(name: "object_id_identity")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-138") {
        createIndex(indexName: "unique_principal", tableName: "acl_sid", unique: "true") {
            column(name: "sid")

            column(name: "principal")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-139") {
        createIndex(indexName: "UK_nrgoi6sdvipfsloa7ykxwlslf", tableName: "authority", unique: "true") {
            column(name: "authority")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-140") {
        createIndex(indexName: "act_name_index", tableName: "is_actor", unique: "false") {
            column(name: "name")

            column(name: "parent_project_id")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-141") {
        createIndex(indexName: "unique_nameisactor", tableName: "is_actor", unique: "true") {
            column(name: "parent_project_id")

            column(name: "name")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-142") {
        createIndex(indexName: "unique_code", tableName: "is_backlog", unique: "true") {
            column(name: "project_id")

            column(name: "code")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-143") {
        createIndex(indexName: "bug_conf_index", tableName: "is_bugtracker", unique: "false") {
            column(name: "name")

            column(name: "project_id")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-144") {
        createIndex(indexName: "unique_nameisbugtracker", tableName: "is_bugtracker", unique: "true") {
            column(name: "project_id")

            column(name: "name")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-145") {
        createIndex(indexName: "unique_nameisbugtrackerimport", tableName: "is_bugtracker_import", unique: "true") {
            column(name: "bt_config_id")

            column(name: "name")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-146") {
        createIndex(indexName: "sync_rule_index", tableName: "is_bugtracker_sync", unique: "false") {
            column(name: "field")

            column(name: "on_state")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-147") {
        createIndex(indexName: "unique_on_state", tableName: "is_bugtracker_sync", unique: "true") {
            column(name: "bt_config_id")

            column(name: "field")

            column(name: "on_state")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-148") {
        createIndex(indexName: "unique_nameisfeature", tableName: "is_feature", unique: "true") {
            column(name: "backlog_id")

            column(name: "name")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-149") {
        createIndex(indexName: "unique_feeling_day", tableName: "is_mood", unique: "true") {
            column(name: "user_id")

            column(name: "feeling_day")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-150") {
        createIndex(indexName: "UK_gcdvyw9ni607np6jjbsgibrdc", tableName: "is_project", unique: "true") {
            column(name: "pkey")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-151") {
        createIndex(indexName: "p_key_index", tableName: "is_project", unique: "false") {
            column(name: "pkey")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-152") {
        createIndex(indexName: "p_name_index", tableName: "is_project", unique: "false") {
            column(name: "name")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-153") {
        createIndex(indexName: "rel_name_index", tableName: "is_release", unique: "false") {
            column(name: "name")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-154") {
        createIndex(indexName: "unique_name", tableName: "is_release", unique: "true") {
            column(name: "parent_project_id")

            column(name: "name")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-155") {
        createIndex(indexName: "unique_nameisstory", tableName: "is_story", unique: "true") {
            column(name: "backlog_id")

            column(name: "name")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-156") {
        createIndex(indexName: "unique_nameistask", tableName: "is_task", unique: "true") {
            column(name: "backlog_id")

            column(name: "name")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-157") {
        createIndex(indexName: "UK_joplui1h2lxa8segeo32qe9vv", tableName: "is_team", unique: "true") {
            column(name: "name")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-158") {
        createIndex(indexName: "unique_nameistemplate", tableName: "is_template", unique: "true") {
            column(name: "parent_project_id")

            column(name: "name")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-159") {
        createIndex(indexName: "up_wdi_index", tableName: "is_up_widgets", unique: "false") {
            column(name: "user_preferences_id")

            column(name: "widget_definition_id")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-160") {
        createIndex(indexName: "UK_4df3sax6nqy447209fmms37m6", tableName: "is_user", unique: "true") {
            column(name: "email")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-161") {
        createIndex(indexName: "UK_pf9tt1u18mb4ij95mvdxmqt5f", tableName: "is_user", unique: "true") {
            column(name: "username")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-162") {
        createIndex(indexName: "username_index", tableName: "is_user", unique: "false") {
            column(name: "username")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-163") {
        createIndex(indexName: "UK_t48xdq560gs3gap9g7jg36kgc", tableName: "tags", unique: "true") {
            column(name: "name")
        }
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-57") {
        addForeignKeyConstraint(baseColumnNames: "acl_object_identity", baseTableName: "acl_entry", baseTableSchemaName: "icescrum", constraintName: "FK_fhuoesmjef3mrv0gpja4shvcraclobjectidentity", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "acl_object_identity", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-58") {
        addForeignKeyConstraint(baseColumnNames: "sid", baseTableName: "acl_entry", baseTableSchemaName: "icescrum", constraintName: "FK_i6xyfccd4y3wlwhgwpo4a9rm1aclsid", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "acl_sid", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-59") {
        addForeignKeyConstraint(baseColumnNames: "object_id_class", baseTableName: "acl_object_identity", baseTableSchemaName: "icescrum", constraintName: "FK_6c3ugmk053uy27bk2sred31lfaclclass", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "acl_class", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-60") {
        addForeignKeyConstraint(baseColumnNames: "owner_sid", baseTableName: "acl_object_identity", baseTableSchemaName: "icescrum", constraintName: "FK_nxv5we2ion9fwedbkge7syoc3aclsid", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "acl_sid", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-61") {
        addForeignKeyConstraint(baseColumnNames: "parent_object", baseTableName: "acl_object_identity", baseTableSchemaName: "icescrum", constraintName: "FK_6oap2k8q5bl33yq3yffrwedhfaclobjectidentity", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "acl_object_identity", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-62") {
        addForeignKeyConstraint(baseColumnNames: "attachment_id", baseTableName: "attachmentable_attachmentlink", baseTableSchemaName: "icescrum", constraintName: "FK_b0dc7e5vilne4lg2tc8ewt1kfattachmentableattachment", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "attachmentable_attachment", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-63") {
        addForeignKeyConstraint(baseColumnNames: "comment_id", baseTableName: "comment_link", baseTableSchemaName: "icescrum", constraintName: "FK_6ul0vto6h9tv1ufx9in1uxp98comment", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "comment", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-64") {
        addForeignKeyConstraint(baseColumnNames: "creator_id", baseTableName: "is_acceptance_test", baseTableSchemaName: "icescrum", constraintName: "FK_pak4trau36sfupwdg7qk09x68isuser", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_user", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-65") {
        addForeignKeyConstraint(baseColumnNames: "parent_story_id", baseTableName: "is_acceptance_test", baseTableSchemaName: "icescrum", constraintName: "FK_8sj4la83tlvs5jp1nca2xsgocisstory", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_story", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-66") {
        addForeignKeyConstraint(baseColumnNames: "acceptance_test_activities_id", baseTableName: "is_acceptance_test_is_activity", baseTableSchemaName: "icescrum", constraintName: "FK_cwir8pr5jyntkmvj08gegccxg", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_acceptance_test", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-67") {
        addForeignKeyConstraint(baseColumnNames: "activity_id", baseTableName: "is_acceptance_test_is_activity", baseTableSchemaName: "icescrum", constraintName: "FK_43uc40v2780i8mfo1hm42u05q", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_activity", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-68") {
        addForeignKeyConstraint(baseColumnNames: "poster_id", baseTableName: "is_activity", baseTableSchemaName: "icescrum", constraintName: "FK_pmu2va0nmu7jgysiwnd0yokdpisuser", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_user", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-69") {
        addForeignKeyConstraint(baseColumnNames: "parent_project_id", baseTableName: "is_actor", baseTableSchemaName: "icescrum", constraintName: "FK_q176mpxf3qm6r8nn7me5cw15cisproject", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_project", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-70") {
        addForeignKeyConstraint(baseColumnNames: "sprint_id", baseTableName: "is_availability", baseTableSchemaName: "icescrum", constraintName: "FK_14nabsy7310mg6yqipio6k2f9issprint", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_sprint", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-71") {
        addForeignKeyConstraint(baseColumnNames: "user_id", baseTableName: "is_availability", baseTableSchemaName: "icescrum", constraintName: "FK_peqpq8d7rxah9efa9tcpcth3isuser", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_user", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-72") {
        addForeignKeyConstraint(baseColumnNames: "parent_project_id", baseTableName: "is_availability_preferences", baseTableSchemaName: "icescrum", constraintName: "FK_pt9m3cr5t6vuo2yo077xhqvbkisproject", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_project", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-73") {
        addForeignKeyConstraint(baseColumnNames: "owner_id", baseTableName: "is_backlog", baseTableSchemaName: "icescrum", constraintName: "FK_6sj0ea9l16o0ia0j29gkbsnygisuser", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_user", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-74") {
        addForeignKeyConstraint(baseColumnNames: "project_id", baseTableName: "is_backlog", baseTableSchemaName: "icescrum", constraintName: "FK_gl8q6vj4ge6qrwho648twkvooisproject", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_project", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-75") {
        addForeignKeyConstraint(baseColumnNames: "project_id", baseTableName: "is_bugtracker", baseTableSchemaName: "icescrum", constraintName: "FK_s5c1unb2168pwmkcnnj9rpyulisproject", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_project", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-76") {
        addForeignKeyConstraint(baseColumnNames: "bt_config_id", baseTableName: "is_bugtracker_import", baseTableSchemaName: "icescrum", constraintName: "FK_simt7234ndg3nvyqume58o6qnisbugtracker", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_bugtracker", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-77") {
        addForeignKeyConstraint(baseColumnNames: "feature_id", baseTableName: "is_bugtracker_import", baseTableSchemaName: "icescrum", constraintName: "FK_aqx5oruvul0ib4ktdn8v7o6u9isfeature", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_feature", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-78") {
        addForeignKeyConstraint(baseColumnNames: "bt_config_id", baseTableName: "is_bugtracker_sync", baseTableSchemaName: "icescrum", constraintName: "FK_sfwqt2x9l4xgl8nsk436ox20kisbugtracker", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_bugtracker", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-79") {
        addForeignKeyConstraint(baseColumnNames: "project_id", baseTableName: "is_build", baseTableSchemaName: "icescrum", constraintName: "FK_60idapqyudjxf8y6i7dhowyl5isproject", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_project", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-80") {
        addForeignKeyConstraint(baseColumnNames: "build_tasks_id", baseTableName: "is_build_is_task", baseTableSchemaName: "icescrum", constraintName: "FK_5oxielyhrw0vmqdfos8d8tq4", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_build", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-81") {
        addForeignKeyConstraint(baseColumnNames: "task_id", baseTableName: "is_build_is_task", baseTableSchemaName: "icescrum", constraintName: "FK_3g1huxf3rs637sor1d7x4m73e", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_task", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-82") {
        addForeignKeyConstraint(baseColumnNames: "parent_time_box_id", baseTableName: "is_cliche", baseTableSchemaName: "icescrum", constraintName: "FK_afudo5o6d4oopg2fd6dde08l5istimebox", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_timebox", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-83") {
        addForeignKeyConstraint(baseColumnNames: "backlog_id", baseTableName: "is_feature", baseTableSchemaName: "icescrum", constraintName: "FK_loldya75qojxvhhyhp2nld63uisproject", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_project", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-84") {
        addForeignKeyConstraint(baseColumnNames: "backlog_id", baseTableName: "is_feature", baseTableSchemaName: "icescrum", constraintName: "FK_loldya75qojxvhhyhp2nld63uistimebox", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_timebox", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-85") {
        addForeignKeyConstraint(baseColumnNames: "parent_release_id", baseTableName: "is_feature", baseTableSchemaName: "icescrum", constraintName: "FK_n0sy646l26phavp3l5ggjyi14isrelease", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_release", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-86") {
        addForeignKeyConstraint(baseColumnNames: "activity_id", baseTableName: "is_feature_is_activity", baseTableSchemaName: "icescrum", constraintName: "FK_q5lk0hsfhgk7lunp06ketigyb", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_activity", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-87") {
        addForeignKeyConstraint(baseColumnNames: "feature_activities_id", baseTableName: "is_feature_is_activity", baseTableSchemaName: "icescrum", constraintName: "FK_2w0u83mdilqch5m7q1jfgmqc3", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_feature", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-88") {
        addForeignKeyConstraint(baseColumnNames: "project_id", baseTableName: "is_invitation", baseTableSchemaName: "icescrum", constraintName: "FK_lyuqd9nip0uic96br21vwhujkisproject", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_project", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-89") {
        addForeignKeyConstraint(baseColumnNames: "team_id", baseTableName: "is_invitation", baseTableSchemaName: "icescrum", constraintName: "FK_png1imjhec8ad6yust5gb4hyvisteam", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_team", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-90") {
        addForeignKeyConstraint(baseColumnNames: "user_id", baseTableName: "is_mood", baseTableSchemaName: "icescrum", constraintName: "FK_ixvbvporcod1j1rlbtiai71udisuser", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_user", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-91") {
        addForeignKeyConstraint(baseColumnNames: "id", baseTableName: "is_project", baseTableSchemaName: "icescrum", constraintName: "FK_shl39mx85nyxcq80m8ndks03q", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_timebox", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-92") {
        addForeignKeyConstraint(baseColumnNames: "preferences_id", baseTableName: "is_project", baseTableSchemaName: "icescrum", constraintName: "FK_oyu95s1texejmf7ph0sncrf2c", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_project_preferences", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-93") {
        addForeignKeyConstraint(baseColumnNames: "project_id", baseTableName: "is_project_teams", baseTableSchemaName: "icescrum", constraintName: "FK_75gk5eg8tkkadsp2q2woegqfn", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_project", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-94") {
        addForeignKeyConstraint(baseColumnNames: "team_id", baseTableName: "is_project_teams", baseTableSchemaName: "icescrum", constraintName: "FK_tocgu5tlo864uy8n3j4erusos", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_team", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-95") {
        addForeignKeyConstraint(baseColumnNames: "id", baseTableName: "is_release", baseTableSchemaName: "icescrum", constraintName: "FK_4cnlhtaklkg3kp0g76pxptjd5", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_timebox", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-96") {
        addForeignKeyConstraint(baseColumnNames: "parent_project_id", baseTableName: "is_release", baseTableSchemaName: "icescrum", constraintName: "FK_g05vssuidycv6dau0nuubh4mr", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_project", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-97") {
        addForeignKeyConstraint(baseColumnNames: "author_id", baseTableName: "is_scm_commit", baseTableSchemaName: "icescrum", constraintName: "FK_71bgrvkrtjix8tijqlr5or0mnisuser", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_user", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-98") {
        addForeignKeyConstraint(baseColumnNames: "commit_tasks_id", baseTableName: "is_scm_commit_is_task", baseTableSchemaName: "icescrum", constraintName: "FK_4cq1cuoob9x5yam31bhu7l8bk", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_scm_commit", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-99") {
        addForeignKeyConstraint(baseColumnNames: "task_id", baseTableName: "is_scm_commit_is_task", baseTableSchemaName: "icescrum", constraintName: "FK_qowxooj855tik5an8w4rexllj", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_task", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-100") {
        addForeignKeyConstraint(baseColumnNames: "parent_project_id", baseTableName: "is_scm_preferences", baseTableSchemaName: "icescrum", constraintName: "FK_jwgbflnkxq9eaxr8l2yjsyw32isproject", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_project", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-101") {
        addForeignKeyConstraint(baseColumnNames: "id", baseTableName: "is_sprint", baseTableSchemaName: "icescrum", constraintName: "FK_6l2lxxj25ub2bm85rl6q44sh3", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_timebox", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-102") {
        addForeignKeyConstraint(baseColumnNames: "parent_release_id", baseTableName: "is_sprint", baseTableSchemaName: "icescrum", constraintName: "FK_6rgaxat7cc4jrmenaqnlqgx7k", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_release", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-103") {
        addForeignKeyConstraint(baseColumnNames: "actor_id", baseTableName: "is_story", baseTableSchemaName: "icescrum", constraintName: "FK_awvhbkkfwdba0qmhrhm7iu840isactor", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_actor", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-104") {
        addForeignKeyConstraint(baseColumnNames: "backlog_id", baseTableName: "is_story", baseTableSchemaName: "icescrum", constraintName: "FK_bhg2ntutavsue8te6ru7fpgd9isproject", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_project", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-105") {
        addForeignKeyConstraint(baseColumnNames: "backlog_id", baseTableName: "is_story", baseTableSchemaName: "icescrum", constraintName: "FK_bhg2ntutavsue8te6ru7fpgd9istimebox", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_timebox", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-106") {
        addForeignKeyConstraint(baseColumnNames: "creator_id", baseTableName: "is_story", baseTableSchemaName: "icescrum", constraintName: "FK_ngwgbduys7sk3lphnk2w4iu3oisuser", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_user", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-107") {
        addForeignKeyConstraint(baseColumnNames: "depends_on_id", baseTableName: "is_story", baseTableSchemaName: "icescrum", constraintName: "FK_dc704gjlv9jiu4db7ifq9vvhtisstory", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_story", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-108") {
        addForeignKeyConstraint(baseColumnNames: "feature_id", baseTableName: "is_story", baseTableSchemaName: "icescrum", constraintName: "FK_3bt4umu1u1wefkmiejeau0cmeisfeature", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_feature", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-109") {
        addForeignKeyConstraint(baseColumnNames: "parent_sprint_id", baseTableName: "is_story", baseTableSchemaName: "icescrum", constraintName: "FK_faeclppx2svbru1e9moantfaissprint", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_sprint", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-110") {
        addForeignKeyConstraint(baseColumnNames: "activity_id", baseTableName: "is_story_is_activity", baseTableSchemaName: "icescrum", constraintName: "FK_jttxer34dveug198ym95986nx", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_activity", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-111") {
        addForeignKeyConstraint(baseColumnNames: "story_activities_id", baseTableName: "is_story_is_activity", baseTableSchemaName: "icescrum", constraintName: "FK_mi2ay9wwqbv6ord6nxmmcwsjh", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_story", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-112") {
        addForeignKeyConstraint(baseColumnNames: "story_followers_id", baseTableName: "is_story_is_user", baseTableSchemaName: "icescrum", constraintName: "FK_cbom8qi725qgp0myp8ed1iwfw", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_story", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-113") {
        addForeignKeyConstraint(baseColumnNames: "story_voters_id", baseTableName: "is_story_is_user", baseTableSchemaName: "icescrum", constraintName: "FK_pkxas3koanbqkgtyk7bkpfhi2", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_story", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-114") {
        addForeignKeyConstraint(baseColumnNames: "user_id", baseTableName: "is_story_is_user", baseTableSchemaName: "icescrum", constraintName: "FK_5trx60swuw62ibk712fbk7kxn", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_user", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-115") {
        addForeignKeyConstraint(baseColumnNames: "backlog_id", baseTableName: "is_task", baseTableSchemaName: "icescrum", constraintName: "FK_qv2vf1ba7ouh3s81i95u2b7f1issprint", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_sprint", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-116") {
        addForeignKeyConstraint(baseColumnNames: "backlog_id", baseTableName: "is_task", baseTableSchemaName: "icescrum", constraintName: "FK_qv2vf1ba7ouh3s81i95u2b7f1istimebox", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_timebox", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-117") {
        addForeignKeyConstraint(baseColumnNames: "creator_id", baseTableName: "is_task", baseTableSchemaName: "icescrum", constraintName: "FK_hu5akfet2n4wyleqtl9402fjjisuser", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_user", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-118") {
        addForeignKeyConstraint(baseColumnNames: "parent_project_id", baseTableName: "is_task", baseTableSchemaName: "icescrum", constraintName: "FK_5cb93vxljn35lj47njklp3f3xisproject", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_project", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-119") {
        addForeignKeyConstraint(baseColumnNames: "parent_story_id", baseTableName: "is_task", baseTableSchemaName: "icescrum", constraintName: "FK_6n8froprvd72kaxdwuyjvc9ysisstory", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_story", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-120") {
        addForeignKeyConstraint(baseColumnNames: "responsible_id", baseTableName: "is_task", baseTableSchemaName: "icescrum", constraintName: "FK_hc78ybcdg3baupyoixav1fjeyisuser", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_user", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-121") {
        addForeignKeyConstraint(baseColumnNames: "activity_id", baseTableName: "is_task_is_activity", baseTableSchemaName: "icescrum", constraintName: "FK_g2wmr3to68rsucgkyxxq8f6sg", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_activity", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-122") {
        addForeignKeyConstraint(baseColumnNames: "task_activities_id", baseTableName: "is_task_is_activity", baseTableSchemaName: "icescrum", constraintName: "FK_t3ugp3hll7ovhbd08c8fn4evk", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_task", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-123") {
        addForeignKeyConstraint(baseColumnNames: "task_participants_id", baseTableName: "is_task_is_user", baseTableSchemaName: "icescrum", constraintName: "FK_t0vshmmqexrdqhl0xni03ea0t", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_task", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-124") {
        addForeignKeyConstraint(baseColumnNames: "user_id", baseTableName: "is_task_is_user", baseTableSchemaName: "icescrum", constraintName: "FK_cdia0egi35pghf3ife0pmxspl", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_user", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-125") {
        addForeignKeyConstraint(baseColumnNames: "team_id", baseTableName: "is_team_members", baseTableSchemaName: "icescrum", constraintName: "FK_b0gl45wd01suyssgxmykfmv99", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_team", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-126") {
        addForeignKeyConstraint(baseColumnNames: "user_id", baseTableName: "is_team_members", baseTableSchemaName: "icescrum", constraintName: "FK_q5nffdqevuflp5grt7fpafbwn", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_user", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-127") {
        addForeignKeyConstraint(baseColumnNames: "parent_project_id", baseTableName: "is_template", baseTableSchemaName: "icescrum", constraintName: "FK_tqlv8t2s043mec6obp7f2k69nisproject", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_project", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-128") {
        addForeignKeyConstraint(baseColumnNames: "activity_id", baseTableName: "is_timebox_is_activity", baseTableSchemaName: "icescrum", constraintName: "FK_4nk7b7gwwy0h15shmpsb1gasr", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_activity", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-129") {
        addForeignKeyConstraint(baseColumnNames: "time_box_activities_id", baseTableName: "is_timebox_is_activity", baseTableSchemaName: "icescrum", constraintName: "FK_tdikn951sm5pshjoeavuirybq", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_timebox", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-130") {
        addForeignKeyConstraint(baseColumnNames: "user_preferences_id", baseTableName: "is_up_widgets", baseTableSchemaName: "icescrum", constraintName: "FK_ml7xvqvvhyvh0dyuc3xx7fe12isuserpreferences", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_user_preferences", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-131") {
        addForeignKeyConstraint(baseColumnNames: "preferences_id", baseTableName: "is_user", baseTableSchemaName: "icescrum", constraintName: "FK_kexf01yt25seb8tn1fyso82sdisuserpreferences", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_user_preferences", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-132") {
        addForeignKeyConstraint(baseColumnNames: "tag_id", baseTableName: "tag_links", baseTableSchemaName: "icescrum", constraintName: "FK_lmil1jg72pjc8ei5p6kk5g9untags", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "tags", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-133") {
        addForeignKeyConstraint(baseColumnNames: "authority_id", baseTableName: "user_authority", baseTableSchemaName: "icescrum", constraintName: "FK_r26d2qfcm6jm4jykhho6kn3u6authority", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "authority", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }

    changeSet(author: "noullet (generated)", id: "1486138528818-134") {
        addForeignKeyConstraint(baseColumnNames: "user_id", baseTableName: "user_authority", baseTableSchemaName: "icescrum", constraintName: "FK_5losscgu02yaej7prap7o6g5sisuser", deferrable: "false", initiallyDeferred: "false", onDelete: "NO ACTION", onUpdate: "NO ACTION", referencedColumnNames: "id", referencedTableName: "is_user", referencedTableSchemaName: "icescrum", referencesUniqueColumn: "false")
    }
}
