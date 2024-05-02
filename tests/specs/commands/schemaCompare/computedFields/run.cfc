/**
 * My first spec file
 */
component extends="testbox.system.BaseSpec" {

    /*********************************** LIFE CYCLE Methods ***********************************/

    function beforeAll() {
        // setup the entire test bundle here
        variables.salvador = 1;
    }

    function afterAll() {
        // do cleanup here
    }

    /*********************************** BDD SUITES ***********************************/

    function run() {
        /**
         * describe() starts a suite group of spec tests. It is the main BDD construct.
         * You can also use the aliases: story(), feature(), scenario(), given(), when()
         * to create fluent chains of human-readable expressions.
         *
         * Arguments:
         *
         * @title    Required: The title of the suite, Usually how you want to name the desired behavior
         * @body     Required: A closure that will resemble the tests to execute.
         * @labels   The list or array of labels this suite group belongs to
         * @asyncAll If you want to parallelize the execution of the defined specs in this suite group.
         * @skip     A flag that tells TestBox to skip this suite group from testing if true
         * @focused A flag that tells TestBox to only run this suite and no other
         */
        describe('The computedFields command should', () => {
            /**
             * --------------------------------------------------------------------------
             * Runs before each spec in THIS suite group or nested groups
             * --------------------------------------------------------------------------
             */
            beforeEach(() => {
                fakeDatasource = mockData($num = 1, $type = 'words:1')[1];
                testbox = 0;
                testbox++;
                colDict = [];

                mockSupport = createMock(object = createmock('models.support'));
                mockSupport.$(method = 'obtainComputedFields', returns = colDict);
                mockPrint = createMock(object = createStub(callLogging = true));
                mockPrint.$(method = 'table');
                testobj = createObject('commands.schemaCompare.computedFields');
                testObj.setprint(mockPrint);
                testobj.setSupport(mockSupport);
                testme = testObj.run(fakeDatasource);
                // writeDump(mockPrint.$callLog());
            });

            /**
             * --------------------------------------------------------------------------
             * Runs after each spec in THIS suite group or nested groups
             * --------------------------------------------------------------------------
             */
            afterEach(() => {
                foo = 0;
            });

            /**
             * it() describes a spec to test. Usually the title is prefixed with the suite name to create an expression.
             * You can also use the aliases: then() to create fluent chains of human-readable expressions.
             *
             * Arguments:
             *
             * @title  The title of this spec
             * @body   The closure that represents the test
             * @labels The list or array of labels this spec belongs to
             * @skip   A flag or a closure that tells TestBox to skip this spec test from testing if true. If this is a closure it must return boolean.
             * @data   A struct of data you would like to bind into the spec so it can be later passed into the executing body function
             * @focused A flag that tells TestBox to only run this spec and no other
             */
            it('can test for equality', () => {
                expect(testbox).toBe(1);
            });

            it('Should call support.obtainComputedFields to be 1', () => {
                expect(mockSupport.$count('obtainComputedFields')).toBe(1);
            });
            it('If the returned array is empty, The headers in the print.table should be empty', () => {
                expect(mockPrint.$count('table')).toBe(1);
                expect(mockPrint.$callLog()).toHaveKey('table');
                expect(mockPrint.$callLog().table.len()).toBe(1);
                expect(mockPrint.$callLog().table[1]).toHaveKey('headerNames');
                expect(mockPrint.$callLog().table[1].headerNames).toBeTypeOf('array');
                expect(mockPrint.$callLog().table[1].headerNames.len()).toBe(0);
            });
            it('If the returned array is not empty , The headers should be the keys in the first item', () => {
                expect(mockPrint.$count('table')).toBe(1);
                expect(mockPrint.$callLog()).toHaveKey('table');
                expect(mockPrint.$callLog().table.len()).toBe(1);
                expect(mockPrint.$callLog().table[1]).toHaveKey('headerNames');
                expect(mockPrint.$callLog().table[1].headerNames).toBeTypeOf('array');
                expect(mockPrint.$callLog().table[1].headerNames.len()).toBe(0);
            });
        });
    }

    private function isLucee() {
        return (structKeyExists(server, 'lucee'));
    }

}
