/***
 * Displays the computed fields in a database
 * 
 * @datasource The datasource to use.
 * 
 * */
component accessors="true" {

    property name="support" inject="support@schemaCompare";

    function run(required datasource = 'target') {
        var allComp = support.obtainComputedFields(arguments.datasource);
        print.line('There are #allComp.len()# computed fields in #arguments.datasource#');
        print.table(headerNames = allComp.len() ? allComp[1].keyArray() : [], data = allComp);
    }

}
