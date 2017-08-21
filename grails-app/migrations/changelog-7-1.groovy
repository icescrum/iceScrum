databaseChangeLog = {
    changeSet(author: "vbarrier", id: "add_notnull_constraint_backlog_chart_type") {
        sql.execute("UPDATE is_backlog SET chart_type = 'type' where code = 'sandbox' OR code = 'done'")
        sql.execute("UPDATE is_backlog SET chart_type = 'state' where code = 'backlog' OR code = 'all'")
        addNotNullConstraint(tableName: "is_backlog", columnName: "chart_type")
    }

    changeSet(author: "vbarrier", id: "drop_on_right_columnn") {
        preConditions(onFail: 'MARK_RAN') {
            columnExists(columnName: "on_right", tableName: "is_up_widgets")
        }
        dropColumn(columnName: "on_right", tableName: "is_up_widgets")
    }
}
