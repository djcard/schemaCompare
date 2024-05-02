/***
 * This is used to wrap an existing SQL file (such as one generated by the SQL server and exported) into a migration using queryExecute.
 *
 * @path The directory containing all the SQL scripts
 * @outputPath The directory into which to save all of the migrations. Defaults to the resources/database/migrations under the current directory in order to comply with where cfmigrations looks by default.
 *
 * */
component {

    property name="support" inject="support@schemaCompare";
    function run(filePath = '', outputPath = = getcwd() & 'resources/database/migrations') {
        var rawText = '';
        var name = filePath.listlast('/\');
        if (filePath.len() and fileExists(filePath)) {
            rawText = fileRead(filePath);
        }
        var queryArr = rawText
            .listToArray('GO', false, true)
            .filter((item) => {
                return !item.findNoCase('USE [');
            });
        var queryText = support.wrapData(queryArr);
        support.writeMigration(name, queryText, outputPath);
    }

}
