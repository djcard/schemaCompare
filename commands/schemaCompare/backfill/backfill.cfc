/***
 * Compares the migrations in a folder and the migrations already ran in a datasource according to its cfmigrations table and attempts to fill in the cfmigrations table with the migrations in the folder. Note: This does not run the migrations, only populates the DB as if they had been run. This is used when creating migrations for a DB which already exists and you want to use migrations going forward.
 *
 * @datasource The datasource to use
 * @path The directory where the migrations are housed
 * @displayAll Whether or not to display each item being analyzed during the process
 */

component accessors="true" {

    property name="support" inject="support@schemaCompare";

    function run(required string dataSourceName, required string path, boolean displayAll = false) {
        var allMigrations = directoryList(path = expandPath(arguments.path), type = 'file', filter = '*.cfc');

        var alreadyIn = support.obtainAlreadyRan(arguments.dataSourceName);

        var results = allMigrations.map((item) => {
            var res = {
                'name': item,
                'present': false,
                'added': false,
                'skipped': false
            };
            var migrationName = item.listlast('\').listfirst('.');
            if (!item.find('.cfc')) {
                res['skipped'] = true;
            } else if (alreadyIn.findNoCase(migrationName)) {
                res['present'] = true;
            } else {
                res['added'] = support.attemptBackfill(migrationName, datasourceName);
            }
            return res;
        });

        var displayResults = results.len() ? results.filter((item, idx) => {
            return displayAll ? true : item.added;
        }) : [
            {
                'name': 'All Items Correct',
                'present': '',
                'added': '',
                'skipped': ''
            }
        ];

        print.table(headerNames = ['name', 'present', 'added', 'skipped'], data = displayResults);
    }

}
