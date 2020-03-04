'use strict';

const path = require('path');
const uuidv4 = require('uuid/v4');
const Generator = require('yeoman-generator');

String.prototype.ucFirst = function () {
    return this.charAt(0).toUpperCase() + this.slice(1);
}

module.exports = class extends Generator {
    constructor(args, opts) {
        super(args, opts);

        this.argument('name', {
            type: String,
            required: false,
            description: 'App name'
        });

        this.option('start-id', {
            type: Number,
            required: false,
            description: 'First Object ID'
        });

        this.option('range', {
            type: Number,
            required: false,
            description: 'Number of Objects'
        });

        this.option('suffix', {
            type: String,
            required: false,
            description: 'Preferred Object Suffix'
        });

        this.option('publisher', {
            type: String,
            required: false,
            description: 'Publisher name'
        });

        this.option('bcversion', {
            type: Number,
            required: false,
            description: 'Business Central Main version'
        });

        this.appname = this.appname.ucFirst();
        this.bcversion = 16;

        this.option('skip-quiz', {
            type: Boolean,
            description: 'Skip user-friendly wizard. Use this for background automation.',
            default: false
        });
    }

    async prompting() {
        if (this.options.skipQuiz) {
            this.answers = {};
            this.log('unattended mode...');
            this.log('--skip-quiz selected, skipping wizard...');
            return;
        }

        this.answers = await this.prompt([
            {
                type: "input",
                name: "name",
                message: "App name",
                default: `${this.options['name'] || this.appname}` // Default to current folder name
            },
            {
                type: "list",
                name: "bcversion",
                choices: [
                    { name: "v16.0 2020 April", value: 16 },
                    { name: "v15.0 2019 October", value: 15 },
                    { name: "v14.0 2019 April", value: 14 }
                ],
                message: "Business Central Main version",
                default: `${this.options['bcversion'] || this.bcversion}` // Default to current folder name
            },
            {
                type: "number",
                name: "startId",
                message: "First Object ID",
                default: 50000
            },
            {
                type: "number",
                name: "range",
                message: "Number of Objects",
                default: 10
            },
            {
                type: "input",
                name: "publisher",
                message: "Publisher name"
            },
            {
                type: "input",
                name: "suffix",
                message: "Preferred Object Suffix"
            },
            {
                type: "confirm",
                name: "testApp",
                message: "Would you like to add Unit Testing?",
                default: true
            },
            {
                type: "input",
                name: "testSuiteName",
                message: "Test Suite Name",
                default: "DEFAULT",
                when: (input) => {
                    return input.testApp;
                }
            }
        ]);
    }

    writing() {
        this.appname = this.answers.name || this.options['name'];
        this.bcversion = this.answers.bcversion || this.options['bcversion'];
        this.appFolderName = `${this.appname}App`;
        this.testFolderName = `${this.appname}Test`;
        this.suffix = this.answers.suffix || this.options.suffix || '';
        this.publisher = this.answers.publisher || this.options.publisher || '';
        this.appGuid = uuidv4();
        this.testGuid = uuidv4();
        this.startId = this.answers.startId || this.options.startId;
        this.range = this.answers.range || this.options.range;
        this.endId = this.startId + this.range - 1;
        if (this.endId < this.startId) {
            this.endId = this.startId + 10;
        }

        this.testApp = this.options.skipQuiz ? true : this.answers.testApp;
        this.testStartId = this.endId + 1;
        this.testEndId = this.testStartId + this.range - 1;
        this.testNextId = this.testStartId + 1;
        this.firstTestCuId = this.testNextId + 1;
        this.testSuiteName = this.answers.testSuiteName || 'DEFAULT';

        this.fs.copyTpl(
            this.templatePath(`${this.bcversion}/app/app.json`),
            this.destinationPath(`${this.appFolderName}/app.json`),
            {
                appGuid: this.appGuid,
                appname: this.appname,
                startId: this.startId,
                endId: this.endId,
                publisher: this.publisher
            }
        );

        this.fs.copyTpl(
            this.templatePath(`${this.bcversion}/app/src/PageExt.HelloWorld.al`),
            this.destinationPath(`${this.appFolderName}/src/PageExt.HelloWorld.al`),
            {
                startId: this.startId,
                suffix: this.suffix
            }
        );

        if (this.testApp) {
            this.fs.copy(
                this.templatePath(`${this.bcversion}/test/Scenarios/*`),
                this.destinationPath(path.join(this.testFolderName, 'Scenarios'))
            );

            this.fs.copy(
                this.templatePath(`${this.bcversion}/test/tests/*`),
                this.destinationPath(path.join(this.testFolderName, 'tests'))
            );

            this.fs.copyTpl(
                this.templatePath(`${this.bcversion}/test/app.json`),
                this.destinationPath(`${this.testFolderName}/app.json`),
                {
                    appGuid: this.appGuid,
                    appname: this.appname,
                    testGuid: this.testGuid,
                    testStartId: this.testStartId,
                    testEndId: this.testEndId,
                    publisher: this.publisher
                }
            );

            this.fs.copyTpl(
                this.templatePath(`${this.bcversion}/test/src/TestSuiteInstaller.al`),
                this.destinationPath(`${this.testFolderName}/src/TestSuiteInstaller.al`),
                {
                    testSuiteName: this.testSuiteName,
                    testStartId: this.testStartId,
                    testNextId: this.testNextId,
                    testEndId: this.testEndId,
                    suffix: this.suffix
                }
            );

            if (this.bcversion < 15) {
                this.fs.copyTpl(
                    this.templatePath(`${this.bcversion}/test/src/TestSuiteMgmt.al`),
                    this.destinationPath(`${this.testFolderName}/src/TestSuiteMgmt.al`),
                    {
                        testStartId: this.testStartId,
                        suffix: this.suffix
                    }
                );
            }

            this.fs.copyTpl(
                this.templatePath(`${this.bcversion}/test/tests/HelloWorldTests.al`),
                this.destinationPath(`${this.testFolderName}/tests/HelloWorldTests.al`),
                {
                    firstTestCuId: this.firstTestCuId,
                    testNextId: this.testNextId,
                    suffix: this.suffix
                }
            );
        }

        let testObjStr = `,
        {
            "path": "${this.testFolderName}"
        }`;

        if (!this.testApp) {
            testObjStr = '';
        }

        this.fs.copyTpl(
            this.templatePath(`${this.bcversion}/bc.code-workspace`),
            this.destinationPath(`${this.appname}.code-workspace`),
            {
                appFolderName: this.appFolderName,
                testFolder: testObjStr
            }
        );
    }
};