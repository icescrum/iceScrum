databaseChangeLog = {
    changeSet(author: "vbarrier", id: "drop_webservices_columnn") {
        preConditions(onFail: 'MARK_RAN') {
            columnExists(columnName: "webservices", tableName: "is_project_preferences")
        }
        dropColumn(columnName: "webservices", tableName: "is_project_preferences")
    }
}
