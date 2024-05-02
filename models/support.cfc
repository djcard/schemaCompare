component {

    property name="print" inject="printBuffer";
    property name="qb" inject="provider:QueryBuilder@qb";
    property name="wirebox" inject="wirebox";

    ignoreSchemas = ['sys'];

    useColumnSizeTypes = ['char', 'varchar', 'nchar', 'nvarchar'];

    restoreAsFunction = ['getdate', 'newid']

    typeDict = {
        'int identity': 'integer',
        'int': 'integer',
        'varchar': 'string',
        'char': 'string',
        'bigint identity': 'bigInteger',
        'bigint': 'bigInteger',
        'smallint identity': 'smallInteger',
        'smallint': 'smallInteger',
        'bigint': 'bigInteger',
        'bigintidentity': 'bigInteger',
        'tinyint identity': 'tinyInteger',
        'tinyint': 'tinyInteger',
        'tinyintidentity': 'tinyInteger',
        'smallInt': 'smallInteger',
        'smallIntidentity': 'smallInteger',
        'float': 'float',
        'nvarchar': 'unicodeString',
        'nchar': 'unicodeString',
        'int': 'integer',
        'date': 'date',
        'datetime': 'datetime',
        'datetime2': 'timestamp',
        'datetimeoffset': 'datetimeTz',
        'bit': 'bit',
        'smallMoney': 'smallMoney',
        'money': 'money',
        'decimal': 'decimal',
        'uniqueidentifier': 'guid',
        'text': 'text',
        'real': 'real',
        'sysname': 'sysname',
        'smalldatetime': 'smalldatetime',
        'timestamp': 'timestamp',
        'varbinary': 'varbinary'
    };

    /***
     * Performs a full comparison between two datasources
     *
     * @sourceDS The datasource for the DB you are trying to match
     * @targetDS The datasource for the DB you trying to confirm is complete
     * @excludeSchemas Schemas you want to skip. Defaults to ['sys', 'INFORMATION_SCHEMA', 'tmp']
     * @migrations Whether to create migrations for the differences or not
     * @path Where you want the migrations to be written
     *
     **/
    function fullCompare(
        required string sourceDS,
        required string targetDS,
        excludeSchemas = ['sys', 'INFORMATION_SCHEMA', 'tmp'],
        boolean migrations = false,
        string path = ''
    ) {
        var computedCols = createComputedColDict(sourceDS);
        var sourceDS = obtainTableInfo(sourceDS);
        var schemasCreated = [];

        for (x in sourceDS) {
            if (x.TABLE_TYPE == 'TABLE' && !excludeSchemas.findNoCase(trim(x.TABLE_SCHEM)) && x.TABLE_NAME.left(1) != '_') {
                var tableName = x.TABLE_SCHEM & '.' & x.TABLE_NAME;
                print.line('prepping the #x.TABLE_TYPE# #tableName#').toConsole();
                var comp = compareColumns(tableName, arguments.sourceDS, arguments.targetDS);
                // print.line(tableName).toConsole();

                if (!comp.bothTableExist) {
                    createSchema(
                        tableName,
                        arguments.sourceDS,
                        true,
                        path,
                        x.TABLE_TYPE,
                        computedCols
                    );
                    schemasCreated.append({'name': tableName, 'type': 'Full'});
                } else {
                    if (comp.missingColumns.missingInTarget.len()) {
                        createChangeSchema(
                            tableName,
                            arguments.sourceDS,
                            arguments.targetDS,
                            true,
                            path,
                            computedCols
                        );
                        schemasCreated.append({'name': tableName, 'type': 'Change'});
                    }
                    if (comp.changed.len()) {
                        print.line('Changes').toConsole();
                        print.line(comp.changed).toConsole();
                    }
                }
            }
        }
    }


    function obtainTableInfo(sourceDS) {
        cfdbinfo(type = "tables", datasource = arguments.sourceDS, name = "data");
        return data;
    }

    function obtainColumnInfo(tableName, sourceDS) {
        cfdbinfo(
            type = "columns",
            table = arguments.tableName,
            datasource = arguments.sourceDS,
            name = "data"
        );
        return data;
    }



    function compareTables(sourceDS, targetDS) {
        var source = obtainTableInfo(arguments.sourceDS);
        var target = obtainTableInfo(arguments.targetDS);
        return tableCompare(tableConvertToArray(source), tableConvertToArray(target));
    }

    function tableConvertToArray(q) {
        var arr = [];
        for (var x in q) {
            if (!ignoreSchemas.findNoCase(x.TABLE_SCHEM)) {
                arr.append('#x.TABLE_TYPE#.#x.TABLE_CAT#.#x.TABLE_SCHEM#.#x.TABLE_NAME#');
            }
        }

        return arr;
    }

    function tableCompare(required array source, required array target) {
        var missingInSource = target.filter(function(item) {
            return !source.findNoCase(item);
        });

        var missingInTarget = source.filter(function(item) {
            return !target.findNoCase(item);
        });

        return {missingInSource: missingInSource, missingInTarget: missingInTarget};
    }

    function compareColumns(tableName, sourceDS, targetDS) {
        var retme = {};
        var source = {};
        try {
            var sourceData = obtainColumnInfo(tableName, arguments.sourceDS);
            // cfdbinfo(type = "columns", table = tableName, datasource = arguments.sourceDS, name = "sourceData");
            source = columnConvertToArray(sourceData);
        } catch (any err) {
        }
        var target = {};
        try {
            var targetData = obtainColumnInfo(arguments.tableName, arguments.targetDS);
            // cfdbinfo(type = "columns", table = tableName, datasource = arguments.targetDS, name = "targetData");
            target = columnConvertToArray(targetData);
        } catch (any err) {
            writeDump('#tableName# does not exist in the #targetDS# datasource ');
        }

        retme.bothTableExist = source.keyArray().len() && target.keyArray().len();
        var columnChanges = missingColumns(source, target);
        retme.missingColumns = columnChanges.missing;
        retme.changed = columnChanges.changed;

        return retme;
    }

    function columnConvertToArray(q) {
        var retme = {};
        for (var x in q) {
            retme[x.COLUMN_NAME] = x;
        }

        return retme;
    }

    function missingColumns(source, target) {
        var retme = {'missingInTarget': []};
        var propChanges = {};

        source
            .keyArray()
            .each(function(colName) {
                if (!target.keyExists(colname)) {
                    retme.missingInTarget.append(source[colName]);
                } else {
                    var rawChanges = dopropertyCompare(source[colName], target[colName]);
                    if (rawChanges.len()) {
                        propChanges[colName] = rawChanges
                    };
                }
                return;
            });
        retme['missingInSource'] = target
            .keyArray()
            .filter(function(colName) {
                return !source.keyExists(colname);
            });

        return {missing: retme, changed: propChanges};
    }

    function dopropertyCompare(source, target) {
        var retme = {};
        var compareArr = [
            'NULLABLE',
            'CHAR_OCTET_LENGTH',
            'IS_AUTOINCREMENT',
            'DATA_TYPE',
            'IS_FOREIGNKEY',
            'SS_DATA_TYPE',
            'IS_NULLABLE',
            'SS_IS_COMPUTED',
            'IS_PRIMARYKEY',
            'DECIMAL_DIGITS'
        ];
        source
            .keyArray()
            .each((item) => {
                if (compareArr.findNoCase(item) && source[item] != target[item]) {
                    retme[item] = {from: source[item], to: target[item]};
                }
            });
        return retme;
    }

    function createSchema(
        required string tableName,
        required string sourceDS,
        boolean migration = false,
        string outputPath = '',
        objectType = '',
        computedColumns = {}
    ) {
        var sourceData = obtainColumnInfo(arguments.tableName, arguments.sourceDS);
        var wholeScript = [];

        var pks = isolatePKs(sourceData);
        var hasCompoundPK = pks.recordCount;

        if (hasCompoundPK) {
            wholeScript.append(createAcompoundPK(pks));
        }


        for (var item in sourceData) {
            item.compoundPK = hasCompoundPK;
            var funcName = hasCompoundPK ? 'createA' & item.TYPE_NAME.listFirst(' ') : 'createA' & item.TYPE_NAME.replace(
                ' ',
                '',
                'all'
            );
            var funcCall = variables.keyExists(funcName) ? variables[funcName] : variables.createAgeneric;
            var addBase = funcCall(item);

            if (item.keyExists('SS_IS_COMPUTED') && item['SS_IS_COMPUTED']) {
                var compKey = '#item.TABLE_SCHEM#.#item.TABLE_NAME#.#item.COLUMN_NAME#';
                if (computedColumns.keyExists(compKey)) {
                    addBase = addBase & '.virtualAs("#computedColumns[compKey]#")';
                    // addbase = insert('.virtualAs("#computedColumns[compKey]#")', addBase, addBase.len()-2);
                }
            }
            wholeScript.append(addBase);
        }
        var final = wrapSchema(arguments.tableName, wholeScript);
        if (arguments.migration && outputPath.len()) {
            writeMigration(
                arguments.tableName,
                final,
                outputPath,
                objectType,
                objectType=="TABLE" ? 'schema.dropIfExists( "#arguments.tableName#" );' : ""
            );
        }

        return final;
    }

    function createChangeSchema(
        required string tableName,
        required string sourceDS,
        required string targetDS,
        boolean createMigration = false,
        string path,
        struct computedColumns
    ) {
        arguments.computedColumns = !isNull(arguments.computedColumns) ? arguments.computedColumns : createComputedColDict(
            sourceDS
        );
        var wholeScript = [];
        var changes = compareColumns(tableName, sourceDS, targetDS);
        if (
            changes.keyExists('missingColumns') && changes.missingColumns.keyExists('missingInTarget') && changes.missingColumns.missingInTarget.len()
        ) {
            changes.missingColumns.missingInTarget.each(function(item) {
                var addBase = '';
                var funcName = 'add' & item.TYPE_NAME.listFirst(' ');
                if (variables.keyExists(funcName)) {
                    var funcCall = variables[funcName];
                    addBase = funcCall(item);
                } else {
                    addBase = genericAdd(item);
                }

                if (item.keyExists('SS_IS_COMPUTED') && item['SS_IS_COMPUTED']) {
                    var compKey = '#item.TABLE_SCHEM#.#item.TABLE_NAME#.#item.COLUMN_NAME#';
                    if (computedColumns.keyExists(compKey)) {
                        addBase = insert('.virtualAs("#computedColumns[compKey]#")', addBase, addBase.len() - 2);
                    }
                }
                wholeScript.append(addBase);
            });
        }
        if (changes.keyExists('changed') && changes.changed.len()) {
            print.line(changes.changed).toConsole();
            // changes.changed.keyArray().each(function(key){
            //    if(changes.changed[key].len()){
            //        var funcName = variables["alter" & key.listFirst(" ")];
            //        wholeScript.append(funcName(item));
            //    }
            // });
        }

        var final = wrapAlter(tableName, wholeScript);
        if (arguments.createMigration) {
            writeMigration(arguments.tableName, final, path);
        }
        return final;
    }


    function wrapModify(tableName, textArray) {
        var line = 'schema.alter("' & arguments.tableName & '", function( table ){' & chr(10);
        line = line & textArray.tolist(';#chr(10)#');
        line = line & '} );#chr(10)#';
        return line;
    }


    function wrapAlter(tableName, textArray) {
        var line = 'schema.alter("' & arguments.tableName & '", function( table ){' & chr(10);
        line = line & textArray.tolist(';#chr(10)#');
        line = line & '} );#chr(10)#';
        return line;
    }


    function wrapSchema(tableName, textArray) {
        var line = 'schema.create("' & arguments.tableName & '", function( table ){' & chr(10);
        line = line & textArray.tolist(';#chr(10)#');
        line = line & '} );#chr(10)#';
        return line;
    }

    function wrapData(textArray) {
        var line = '//This file was empty';
        var contents = textArray.filter((item)=>{
            return trim(item).len();
        });
        if (contents.len()) {
            line = 'queryExecute("'
            line = line & contents.tolist(';#chr(10)#');
            line = line & '");#chr(10)#';
        }
        return line;
    }

    function isolateComputedColumns(data) {
        return data.filter((item) => {
            return item.keyExists('SS_IS_COMPUTED') && item.SS_IS_COMPUTED;
        });
    }

    function isolatePKs(data) {
        return data.filter((item) => {
            return item.IS_PRIMARYKEY
        });
    }

    function genericAdd(item) {
        var funcName = 'createA' & item.TYPE_NAME.listFirst(' ');
        var funcCall = variables.keyExists(funcName) ? variables[funcName] : variables.createAgeneric;
        var line = funcCall(item);
        return 'table.addColumn( #line# )';
    }

    function createAgeneric(item) {
        var size = useColumnSizeTypes.findNoCase(item.TYPE_NAME) && item.keyExists('COLUMN_SIZE')
         ? item.COLUMN_SIZE < 8000
         ? item.COLUMN_SIZE
         : 8000
         : '';

        var calldata = 'name="#item.COLUMN_NAME#"';
        calldata = isValid('numeric', size) || size.len() ? callData.listAppend('length="#size#"') : calldata;
        calldata = item.keyExists('IS_AUTOINCREMENT') && item.IS_AUTOINCREMENT ? calldata.listAppend('autoIncrement=1') : calldata;
        var line = '';
        line = 'table.#typeDict[item.TYPE_NAME]#(#calldata#)';

        line = line & (item['IS_NULLABLE'] == 'YES' ? '.nullable()' : '');

        if (item.keyExists('COLUMN_DEFAULT_VALUE') && item.COLUMN_DEFAULT_VALUE.len()) {
            var defaultContent = item.COLUMN_DEFAULT_VALUE
                .replace('(', '', 'all')
                .replace(')', '', 'all')
                .replace('''', '', 'all')
                .replace('''', '', 'all');
            defaultContent = restoreAsFunction.findNoCase(defaultContent)
             ? '#defaultContent#()'
             : isValid('numeric', defaultContent)
             ? defaultContent
             : '''#defaultcontent#''';
            line = line & (item['COLUMN_DEFAULT_VALUE'].len() ? '.default("' & defaultContent & '")' : '');
        }

        return line;
    }

    function createAcompoundPK(items) {
        var fields = [];
        var pks = items.each((item) => {
            fields.append('"' & item.COLUMN_NAME & '"');
        })
        return 'table.primaryKey([#fields.toList()#])';
    }

    function createAintidentity(item) {
        var line = 'table.#typeDict[item.TYPE_NAME]#(name="#item.COLUMN_NAME#",autoincrement="#item.IS_AUTOINCREMENT#")';
        line = line & (item['IS_NULLABLE'] == 'YES' ? '.nullable()' : '');
        line = line & (item['COLUMN_DEFAULT_VALUE'].len() ? '.default("#item.COLUMN_DEFAULT_VALUE#")' : '');
        return line;
    }

    function createAsmallintidentity(item) {
        var line = 'table.#typeDict[item.TYPE_NAME]#(name="#item.COLUMN_NAME#")';
        line = line & (item['IS_NULLABLE'] == 'YES' ? '.nullable()' : '');
        line = line & (item['COLUMN_DEFAULT_VALUE'].len() ? '.default("#item.COLUMN_DEFAULT_VALUE#")' : '');
        return line;
    }

    function createAbigidentity(item) {
        var line = 'table.#typeDict[item.TYPE_NAME]#(name="#item.COLUMN_NAME#")';
        line = line & (item['IS_NULLABLE'] == 'YES' ? '.nullable()' : '');
        line = line & (item['COLUMN_DEFAULT_VALUE'].len() ? '.default("#item.COLUMN_DEFAULT_VALUE#")' : '');
        return line;
    }

    function writeMigration(
        tableName,
        text,
        outputPath,
        objectType = '',
        downData=""
    ) {
        var base = migrationTemplate();
        var outputData = base.replace('***updata***', text).replace("***downData***",downData);
        print.line('Writing to #outputpath#').toConsole();
        writeFile(outputPath & '\' & generateFileName(arguments.tableName, objectType), outputdata);
        return true;
    }

    function generateFileName(tableName, objectType = '') {
        return dateTimeFormat(now(), 'yyyy_mm_dd_HHnnss') & '_' & objectType & '_' & arguments.tableName.replace(
            '.',
            '_',
            'all'
        ) & '.cfc';
    }

    function writeFile(path, content) {
        fileWrite(expandPath(path), content);
    }

    function migrationTemplate() {
        return 'component {
    
            function up( schema, qb ) {
                ***updata***
            }
        
            function down( schema, qb ) {
                ***downData***
            }
        
        }'
    }

    function createComputedColDict(datasource) {
        var dict = {};
        obtainComputedFields(arguments.datasource).each((item) => {
            dict['#item.Schema#.#item.Table#.#item['Computed Column']#'] = item.definition;
        })

        return dict;
    }

    array function obtainComputedFields(required string datasource) {
        print.line('Getting computed fields from datasource #datasource#').toConsole();
        return qb
            .from('sys.computed_columns cc')
            .selectRaw('SCHEMA_NAME(o.schema_id) AS [Schema],OBJECT_NAME(cc.object_id) AS [Table],cc.name AS [Computed Column],cc.definition')
            .join('sys.objects o', 'o.object_id', 'cc.object_id')
            .get(options = {datasource: arguments.datasource});
    }

    function createAllTableMigrations(
        required string datasource,
        required string outputPath,
        excludedSchemas = ['sys', 'tmp', 'INFORMATION_SCHEMA']
    ) {
        print.line(outputPath).toConsole();
        var allTables = obtainTableInfo(arguments.datasource);
        //print.line(allTables).toConsole();
        var computedCols = createComputedColDict(arguments.datasource);
        allTables.each((table) => {
           // print.line(table).toConsole();
            if (
                table.TABLE_TYPE == 'TABLE' && !excludedSchemas.findNoCase(trim(table.TABLE_SCHEM)) && table.TABLE_NAME.left(
                    1
                ) != '_' && table.TABLE_NAME != 'cfmigrations' && table.TABLE_NAME != 'sysdiagrams'
            ) {
                var tableName = table.TABLE_SCHEM & '.' & table.TABLE_NAME;
                print.line('prepping the #table.TABLE_TYPE# #tableName#').toConsole();
                createSchema(
                    tableName,
                    datasource,
                    true,
                    outputPath,
                    table.TABLE_TYPE,
                    computedCols
                );
            }
        })
    }

    function createSchemaMigrations(required string datasource, required string outputPath, skipDBO = true) {
        var allSchemas = obtainSchemas(datasource);
        allSchemas.each((item) => {
            if (skipDBO && item.name != 'dbo') {
                print.line('Prepping schema #item.name#').toConsole();
                writeMigration(
                    item.name,
                    cleanObjectScripts('create schema #item.name#'),
                    outputPath,
                    'schema'
                );
            }
        })
    }

    function obtainSchemas(string datasource) {
        return qb
            .from('sys.schemas')
            .where('principal_id', 1)
            .get(options = {datasource: datasource});
    }

    function createViewMigrations(string datasource, array views, outputPath = '') {
        var allViews = !isNull(views) ? arguments.views : obtainAllViews(arguments.datasource);
        allViews.each((item) => {
            print.line('prepping the view #item.name#').toConsole();
            var texter = cleanObjectScripts(item.definition);
            writeMigration(item.name, texter, outputPath, 'VIEW')
        });
    }

    function obtainAllViews(required string datasource) {
        return qb
            .from('sys.views v')
            .selectRaw('name,definition, SCHEMA_NAME(schema_id) AS [Schema], type, type_desc')
            .join('sys.sql_modules m', 'v.object_id', 'm.object_id')
            .get(options = {datasource: arguments.datasource})
    }

    function obtainAlreadyRan(required string dataSourceName) {
        return qb.from('cfmigrations').values(column = 'name', options = {datasource: arguments.dataSourceName});
    }

    function attemptBackfill(item, required string datasourceName) {
        // print.line(item);
        try {
            qb.from('cfmigrations')
                .insert(
                    values = {'name': arguments.item, 'migration_ran': dateTimeFormat(now(), 'yyyy-mm-dd HH:nn:ss')},
                    options = {datasource: arguments.datasourceName}
                );
            return true;
        } catch (any err) {
            return false;
        }
    }


    function obtainDependencies(required string name, required string datasource) {
        return qb
            .from('sys.sql_expression_dependencies sed')
            .selectRaw('OBJECT_NAME(referencing_id) AS referencing_entity_name,   
                o.type_desc AS referencing_desciption,   
                COALESCE(COL_NAME(referencing_id, referencing_minor_id), ''(n/a)'') AS referencing_minor_id,   
                referencing_class_desc, referenced_class_desc,  
                referenced_server_name, referenced_database_name, referenced_schema_name,  
                referenced_entity_name,   
                COALESCE(COL_NAME(referenced_id, referenced_minor_id), ''(n/a)'') AS referenced_column_name,  
                is_caller_dependent, is_ambiguous')
            .join('sys.objects o', 'referencing_id', 'o.object_id')
            .whereRaw('referencing_id=OBJECT_ID(N''#arguments.name#'')')
            .get(options = {datasource: arguments.datasource});
    }

    function whatReferencesMe(required string objectName, required string datasource) {
        return qb
            .select('referencing_schema_name, 
                referencing_entity_name, referencing_id, 
                referencing_class_desc, is_caller_dependent')
            .fromRaw('sys.dm_sql_referencing_entities (''#arguments.objectName#'', ''OBJECT'')')
            .get(options = {datasource: arguments.datasource})
    }

    function createFunctionMigrations(required string datasource, required string outputPath) {
        var allFunctions = obtainFunctions(datasource);
        allFunctions.each((item) => {
            print.line('Prepping #item.type# #item.object_name#').toConsole();
            writeMigration(
                item.object_name,
                cleanObjectScripts(item.definition),
                outputPath,
                item.type
            );
        })
    }

    function obtainFunctions(required string datasource, string name = '') {
        return qb
            .from('sys.sql_modules AS sm')
            .selectRaw('sm.object_id,
            OBJECT_NAME(sm.object_id) AS object_name,
            o.type,
            o.type_desc,
            sm.definition,
            sm.uses_ansi_nulls,
            sm.uses_quoted_identifier,
            sm.is_schema_bound,
            sm.execute_as_principal_id')
            .join('sys.objects AS o', 'sm.object_id', 'o.object_id')
            .orderby('o.type')
            .where('o.type', 'FN')
            .when(arguments.name.len(), (q) => {
                q.andWhereRaw('sm.object_id = OBJECT_ID(''#name#'')')
            })
            .get(options = {datasource: arguments.datasource});
    }

    function createStoredProcMigrations(required string datasource, required string outputPath) {
        var allStoredProcs = obtainStoredProcs(datasource);
        allStoredProcs.each((item) => {
            print.line('Prepping #item.type# #item.object_name#').toConsole();
            writeMigration(
                item.object_name,
                cleanObjectScripts(item.definition),
                outputPath,
                item.type
            );
        })
    }

    function obtainStoredProcs(required string datasource, string name = '') {
        return qb
            .from('sys.sql_modules AS sm')
            .selectRaw('sm.object_id,
            OBJECT_NAME(sm.object_id) AS object_name,
            o.type,
            o.type_desc,
            sm.definition,
            sm.uses_ansi_nulls,
            sm.uses_quoted_identifier,
            sm.is_schema_bound,
            sm.execute_as_principal_id')
            .join('sys.objects AS o', 'sm.object_id', 'o.object_id')
            .orderby('o.type')
            .where('o.type', 'P')
            .when(arguments.name.len(), (q) => {
                q.andWhereRaw('sm.object_id = OBJECT_ID(''#name#'')')
            })
            .get(options = {datasource: arguments.datasource});
    }

    function cleanObjectScripts(text) {
        var cleaned = text.replace('##', '####', 'all');
        return 'queryExecute("#cleaned#")';
    }

    function mapDBTypetoQBGrammar(type) {
        var types = {
            'mssql': 'SQLServerGrammar@qb',
            'mySql': 'MySQLGrammar@qb',
            'oracle': 'OracleGrammar@qb',
            'postgres': 'PostgresGrammar@qb',
            'sqlite': 'SQLiteGrammar@qb'
        };
        return types.keyExists(arguments.type) ? types[type] : '';
    }

    public function allDirectoriesMade(outputPath){
        try {
            //var newdirectorypath = replace(filename, #replace(arguments.destination,'\','\\','all')#, '');
            var testpathArr = outputPath.listtoarray('\/');
            arrayDeleteAt(testpathArr, arraylen(testpathArr));
            var testPath = #replace(arguments.outputPath,'\','\\','all')#;
            for (var x = 1; x <= arraylen(testpathArr); x = x + 1) {
                testPath = listappend(testPath, testpathArr[x], '\\');
                if (!directoryExists(testPath)) {
                    directoryCreate(testPath);
                }
            }
            return true;
        }
        catch(any err){
            return false;
        }
    }

}
