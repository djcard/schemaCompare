/***
 * Creates a migration for a single table in a DB
 *
 * @datasource The datasource to use to create the migration
 * @tablename The table for which to make the migration
 * @createmigration Whether to write the migration or not. Defaults to true.
 * @outputPath The location to write the migration. Defaults to the resources/database/migrations under the current folder to comply with the migrations convention.
 *
 *
 * */

component {

    property name="support" inject="support@schemaCompare";
    property name="settings" inject="commandbox:configsettings";

    function run(
        required string datasource,
        required string tableName,
        boolean createmigration = true,
        string outputPath = getcwd() & '/resources/database/migrations'
    ) {
        var pather = arguments.outputPath.len()
         ? arguments.outputPath
         : variables.settings.modules.schemaCompare.migrationDirectory.len()
         ? variables.settings.modules.schemaCompare.migrationDirectory
         : '';

        var x = support.createSchema(
            tableName,
            datasource,
            createmigration,
            pather
        );
        print.line('Complete');
    }

}
