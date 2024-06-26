/***
 * This is used to wrap existing SQL files (such as one generated by the SQL server and exported) in a folder into a migration using queryExecute.
 *
 * @sourcePath The directory containing all the SQL scripts
 * @outputPath The directory into which to save all of the migrations. Defaults to the resources/database/migrations under the current directory in order to comply with where cfmigrations looks by default.
 *
 * */

component {

    property name="support" inject="support@schemaCompare";

    function run(required string sourcePath = '', string outputPath = getcwd() & 'resources/database/migrations') {
        var files = [];
        print.line(expandPath(sourcePath));
        if (sourcePath.len() and directoryExists(expandPath(sourcePath))) {
            files = directoryList(expandPath(sourcePath))
        }
        print.line(files);
        files.each((item) => {
            var rawText = '';
            var rawText = '';
            var name = '';
            if (fileExists(item)) {
                name = item.listlast('/\');
                rawText = fileRead(item);
            }
            var queryArr = rawText
                .listToArray('GO', false, true)
                .filter((item) => {
                    return !item.findNoCase('USE [');
                });
            if (queryArr.len()) {
                var queryText = support.wrapData(queryArr);
                // if(!queryText.left(2)=="//"){
                support.writeMigration(name, queryText, outputPath);
                // }
            }
        })
    }

}
