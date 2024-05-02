/***
 * Runs a comparison between two databases or tables
 * @sourceds The source datasource. Acts as the 'source of truth'
 * @targetDs.hint The target datasource. The one you want to make "like the source"
 * @type.hint The type of comparison. Full is the entire database. Table is one table vs another. Defaults to full.
 * @type.options Full,Table
 * @excludeSchemas Schemas to exclude in a full comparison. Defaults to 'sys', 'INFORMATION_SCHEMA', 'tmp'
 * @createMigrations Whether the system should create migrations to bring the target to match the source
 * */

component {

    property name="support" inject="support@schemaCompare";
    property name="settings" inject="commandbox:configsettings";

    function run(
        sourceDs,
        targetDs,
        type = 'full',
        excludeSchemas = ['sys', 'INFORMATION_SCHEMA', 'tmp'],
        createMigrations = true,
        string outputPath = getCwd() & '/resources/database/migrations',
        tableName = ''
    ) {
        if (type == 'full') {
            var results = support.fullCompare(
                sourceds,
                targetDs,
                excludeSchemas,
                createMigrations,
                outputPath
            );
        } else if (type == 'TABLE') {
            if (!tableName.len()) {
                print.line('Please specifiy a table name to do a table compare')
            };
            var results = support.createChangeSchema(
                tableName,
                sourceds,
                targetDs,
                createMigrations,
                outputPath
            )
        }
    }

}
