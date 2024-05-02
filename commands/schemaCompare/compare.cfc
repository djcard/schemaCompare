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
        string path = getCwd() & "/resources/database/migrations",
        tableName = ''
    ) {
        var pather = arguments.path.len()
         ? arguments.path
         : variables.settings.modules.schemaCompare.migrationDirectory.len()
         ? variables.settings.modules.schemaCompare.migrationDirectory
         : '';


        if (type == 'full') {
            var results = support.fullCompare(
                sourceds,
                targetDs,
                excludeSchemas,
                createMigrations,
                pather
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
                pather
            )
        }
    }

}
