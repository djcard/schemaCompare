/***
 * Sets up datasources, output paths, file sources and other settings.
 *
 *
 *
 *
 * */


component {

    property name="settings" inject="commandbox:configsettings";
    property name="support" inject="support@schemaCompare";

    function run(boolean force=false) {
        print.line('This command will help you set up a datasource to use with your project');
        var cont = ask(message = 'Continue? y/n : ', defaultResponse = 'y');
        if (cont == 'y') {
            //var pather = ask(message = 'Where should migrations be saved?: ', defaultResponse = '');
            //if (pather.len()) {
            //    command('config set modules.schemaCompare.migrationDirectory=#pather#').run();
            //}
            createDataSource( arguments.force );
        } else {
            print.line('Exiting');
        }
    }

    function createDataSource( force ) {
        var ds = {};
        ds.datasource = ask('What is the name of this datasource? : ');
        ds.type = multiselect('What type of DB is this? : ').options('mssql,mysql').ask();
        ds.dbName = ask('What is the database name? : ')
        ds.uname = ask('What is the username? : ')
        ds.pwd = ask(message='What is the password? : ',mask="*")
        ds.host = ask('What is the host of this datasource? : ');
        ds.port = ask('What is the port for this datasource? : ');
        ds.default = ask(
            message = 'Do you want to make #ucase(ds.type)# the default grammar for QB? y/n: ',
            defaultResponse = 'y'
        );
        if (ds.default == 'y') {
            var gramm = support.mapDBTypetoQBGrammar(ds.type);
            if (gramm.len()) {
                command('cfconfig set modules.qb.defaultGrammar=#gramm#');
            } else {
                print.line('That grammar was not found.').toConsole();
            }
        }
        ds.saver = ask(
            message = 'Do you want to write this datasource to the .env file to use with cfmigrations? y/n : ',
            defaultAnswer='y'
        );
        command('cbdatasource MakeNewDatasource')
            .params(
                datasource = ds.datasource,
                dbname = ds.dbName,
                dbtype = ds.type,
                password = ds.pwd,
                username = ds.uname,
                serveraddress = ds.host,
                force = arguments.force
            )
            .run();
            print.line("Datasource made").toConsole();
            if (ds.saver == 'y') {
                //command('config set modules.schemaCompare.datasources[#ds.datasource#]={}').run();
                command('cbdatasource publishToEnv').params(
                    name=ds.datasource,
                    type=ds.type
                ).run();
                print.line('Saved to .envFile');
            }
    }

}
