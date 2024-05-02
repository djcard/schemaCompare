# Schema Compare

## Background

Schema compare is a collection of tools designed to make the creation of migrations and configuring the use of cfmigrations from both CommandBox and web based tools even easier. Additionaly, it contains many utilities that facilitate and encourage the ongoing maintenence of migrations in your projects.

Note: The tool is highly MSSQL focussed given the circumstances surrounding its origin but adapting it to work with other databases is certainly possible. 

## Key Elements

- Datasources: SchemaCompare has tools to create and manage datasources in Commandbox ( not web servers managed through CommandBox but CommandBox itself )
- QBSettings: Many migrations run on QB. SchemaCompare eases the creation of settings which might be tricky on CommandBox such as grammars. 
- SQL Scripts --> Migrations: SchemaCompare can "wrap" sql scripts, such as those generated from MSSQL Studio, in a migration making it easier to use the best tool for the job. 
- Output Paths: defaults to `resources/database/migrations` under the current directory in CommandBox in order follow conventions from cfmigrations. 
- .env Files: Can create or edit .env files with the needed keys and values to run cfmigrations from either CommandBox or via a web application such as ColdBox. 

## Commands

### Top Level

### snapshot

**Purpose**: Creates a migration for each schema, function, table, view, and sstored procedure in the database.  
**Use**: `SchemaCompare snapshot`.  
**Parameters**:  
    - datasource Required string The datasource to use  
    - outputPath Optional string The target location for migrations. Defaults to /resources/database/migrations under the current folder.  

### compare

**Purpose**: Compares between two datasources and creates migrations to bring the schema of the target up to date with the schema of the source.  
**Use**: `SchemaCompare compare`  
**Parameters**:  
    - sourceDS Required string  
    - targetDS Required string  
    - createmigrations boolean Optional Defaults to true  
    - type Optional string `full | table`. Defaults to `full`  
    - table Optional string  The name of the table to compare in a table type comparison.  
    - excludeSchemas array Optional The names of schemas to skip when comparing.Defaults to `['sys', 'INFORMATION_SCHEMA', 'tmp']`  
    - outputPath Optional string The target location for migrations. Defaults to /resources/database/migrations under the current folder.  

### configure datasource

**Purpose**: Configures a datasource for use within CommandBox and has options to save default grammar for QB and to publish datasource to a .env file  
**Use**: `schemaCompare configure datasource`  
**Parameters**:  
    - none but presents a "wizard". Should be refactored to simply accept paramters


### wrap directory

**Purpose**: scans a directory for files with .sql extensions and "wraps" them in a migration with some minimal changes to make them migration friendly. Note: changes based on scripts exported from MSSQL Studio.  
**Use**: `schemaCompare wrap directory`  
**Parameters**:  
    - sourcePath Required string The directory to be scanned and wrapped
    - outputPath Optional string The target location for migrations. Defaults to /resources/database/migrations under the current folder.  

### wrap file

**Purpose**: accepts a file with .sql extensions and "wraps" it in a migration with some minimal changes to make them migration friendly. Note: changes based on scripts exported from MSSQL Studio.  
**Use**: `schemaCompare wrap file`  
**Parameters**:  
    - filePath Required string Absolute path to the file to be wrapped
    - outputPath string Optional The target location for migrations. Defaults to /resources/database/migrations under the current folder. 

### basics viewComputerFields

**Purpose**: Displays a table with the computed fields in a table / database  
**Use**: `schemaCompare basics viewComputedFields`  
**Parameters**:  
    - datasource Required string The datasource to use   


### basics viewFunctions

**Purpose**: Displays a table with the functions in a database  
**Use**: `schemaCompare basics viewFunctions`  
**Parameters**:  
    - datasource string Required The datasource to use  
    - name string Optional If a name is submitted, a more detailed output is displayed of that single function.  

### basics viewDependencies

**Purpose**: Presents a table of dependencies and what is dependent on the submitted object name.
**Use**: `schemaCompare basics viewDependencies`  
**Paramters**:  
    - objectName Required string The name of the object in question.  
    - datasource Required string The name of the datasource to use.  

