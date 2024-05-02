/***
 * Creates a migration with a "catchup" script. i.e. migrations that are present but need to be listed as run on a database to which there is no direct access except a migration. Similar to backfill
 * @sourcePath The directory with the existing migrations
 * @datasourceName The datasource to use
 * @outputpath Where to write the migration with the catchup script *
 *
 *
 * **/
component {

    property name="support" inject="support@schemaCompare";


    function run( string sourcePath = getCwd() & '/resources/database/migrations', string outputPath = getCwd() & '/resources/database/migrations') {
        var allMigrations = directoryList(path = expandPath(arguments.sourcePath), type = 'file', filter = '*.cfc');
        var wholeScript = []

        var wholeScript = allMigrations.map((item) => {
            var migrationName = item.listlast('\').listfirst('.');
            return 'If not exists(select name from cfmigrations where name=''#migrationName#'') BEGIN 
            INSERT INTO [cfmigrations] ([name], [migration_ran]) VALUES (N''#migrationName#'', CAST(N''#dateTimeFormat(now(), 'yyyy-mm-ddTHH:nn:ss').replace('P', 'T')#'' AS DateTime2))
            END;'
        });
        var texter = 'queryExecute("#wholeScript.tolist(chr(10))#")';
        support.writeMigration(
            'catchUpScript',
            texter,
            arguments.outputPath.len() ? arguments.outputPath : arguments.path,
            'catchUp'
        );
    }

}
