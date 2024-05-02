/***
 * Comnpares the migrations in a directory to see if they have been run on a datasource already or not.
 * 
 * @directory The path to teh directory with the list of migrations to check
 * @datasource The datasource to use
 * @unRunOnly To display only the migrations which have not been run vs vs the status of all migrations in the directory
 * 
 * 
 * 
 * */
component {

    property name="support" inject="support@schemaCompare";
    property name="print" inject="printBuffer";

    function run(required string directory, required string datasource, boolean unRunOnly = false) {
        var allFiles = directoryList(expandPath(arguments.directory));
        var allreadyRun = support.obtainAlreadyRan(arguments.datasource);

        var renderedResults = allFiles.map((fileName) => {
            return {filename: filename, hasBeenRun: allReadyRun.findNoCase(filename.listFirst('.').listlast('/\')) > 0};
        });

        print.line('There are #renderedResults.len()# files in the directory');
        if (arguments.unRunOnly) {
            print.table(
                renderedResults.filter((item) => {
                    return !item.hasBeenRun
                })
            )
        } else {
            print.table(renderedResults);
        };
    }

}
