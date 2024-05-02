/***
 * Creates migrations for an entire database including schemas, tables, views, and stored procedures
 *
 * @datasource The datasource to use
 * @outputPath The folder to which to write the migrations. defaults to /resources/database/migrations in the current folder.
 *
 *
 * */

component {

    property name="support" inject="support@schemaCompare";

    function run(required string datasource, string outputPath = getcwd() & '/resources/database/migrations') {
        print.line("Checking if #outputpath# exists").toConsole();
        support.allDirectoriesMade(outputPath);
        print.line("Checking if #outputpath# exists or was created").toConsole();
        // Create All Schemas
        print.lineGreen('Starting Schemas');
        support.createSchemaMigrations(datasource = arguments.datasource, outputPath = arguments.outputPath);
        print.lineGreen('Schemas Complete');
        // Create all functions
        print.lineGreen('Starting Functions').toConsole();
        support.createFunctionMigrations(datasource = arguments.datasource, outputPath = arguments.outputPath);
        print.lineGreen('Functions Complete').toConsole();
        // Create all Tables
        print.lineGreen('Starting Tables').toConsole();
        support.createAllTableMigrations(datasource = arguments.datasource, outputPath = arguments.outputPath);
        print.lineGreen('Tables Complete').toConsole();
        // Create all Views
        print.lineGreen('Starting Views').toConsole();
        support.createViewMigrations(datasource = arguments.datasource, outputPath = arguments.outputPath);
        print.lineGreen('Views Complete').toConsole();

        // Create all stored Procs
        print.lineGreen('Starting Stored Procedures').toConsole();
        support.createStoredProcMigrations(datasource = arguments.datasource, outputPath = arguments.outputPath);
        print.lineGreen('Stored Procedures Complete').toConsole();
    }

}
