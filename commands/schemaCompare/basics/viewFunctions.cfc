/***
 * Displays a list of the functions in a datasource
 *
 * @datasource The datasource to use
 * @name An option name of a function to view more detailed information
 *
 *
 * */

component accessors="true" {

    property name="support" inject="support@schemaCompare";
    property name="print" inject="printBuffer";

    function run(required string datasource, string name = '') {
        var allFunctions = support.obtainFunctions(arguments.datasource, name);
        print.line('There are #allFunctions.len()# functions in #arguments.datasource#');
        if (name.len()) {
            print.line(allFunctions);
        } else {
            print.table(headerNames = allFunctions.len() ? allFunctions[1].keyArray() : [], data = allFunctions);
        }
    }

}
