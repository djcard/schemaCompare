/***
 * Displays a list of the dependencies for an object
 *
 * @objectName The name of the object whose dependencies are desired
 * @datasource The datasource to use
 *
 *
 * */

component {

    property name="support" inject="support@schemaCompare";

    function run(required string objectName, required string datasource) {
        var isDependentOn = support.obtainDependencies(objectName, datasource);
        print.line('#objectName# depends on these items: ');
        print.table(data = isDependentOn)

        var isADependencyOf = support.whatReferencesMe(objectName, datasource);
        print.line('');
        print.line('These items depend on #objectName#');
        print.table(isADependencyOf);
    }

}
