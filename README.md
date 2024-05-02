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
    - datasource string Required The datasource to use  
    - outputPath string Optional The target location for migrations. Defaults to /resources/database/migrations under the current folder.  

### compare

**Purpose**: Compares between two datasources and creates migrations to bring the schema of the target up to date with the schema of the source.  
**Use**: `SchemaCompare compare`  
**Parameters**:  
    - sourceDS required string  
    - targetDS required string  
    - createmigrations boolean optional Defaults to true  
    - type string optional `full | table`. Defaults to `full`  
    - table string optional The name of the table to compare in a table type comparison.  
    - excludeSchemas array optional The names of schemas to skip when comparing.Defaults to `['sys', 'INFORMATION_SCHEMA', 'tmp']`  
    - outputPath string Optional The target location for migrations. Defaults to /resources/database/migrations under the current folder.  

