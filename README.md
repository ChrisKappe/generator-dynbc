# Yeoman Generator for Dynamics 365 Business Central

A Yeoman generator to help get you started with Business Central extension development.
Example code is based on this Hello World repository: https://dev.azure.com/businesscentralapps/HelloWorld

## Getting started

* Install: `npm install -g generator-dynbc`
* Run: `yo dynbc`

## Commands

* `yo dynbc` shows a wizard for generating an app
* `yo dynbc <name> --skip-quiz` generates a new app with the name `<name>`
* `yo dynbc --help` shows available commands and options

## Options

* `--help,-h`: shows available commands and options
* `--skip-quiz`: skips wizard to use specified options instead
* `--start-id`: first Object ID of your range
* `--bcversion`: Business Central main version number, 14, 15 or 16
* `--range`: number of Objects
* `--suffix`: company suffix to be added to Object names
* `--publisher`: publisher name

## Usage

### A) Wizard

`yo dynbc MyNewApp`

Wizard questions:
```
? App name -> MyNewApp
? Business Central Main version -> v16.0 2020 April
? First Object ID -> 50000
? Number of Objects -> 10
? Publisher name -> My Company
? Preferred Object Suffix -> XXX
? Would you like to add Unit Testing? (Y/n) -> Y
? Test Suite Name -> DEFAULT
```
Output:
```
   create MyNewAppApp\app.json
   create MyNewAppApp\src\PageExt.HelloWorld.al
   create MyNewAppTest\Scenarios\ScenarioTemplate.ps1
   create MyNewAppTest\tests\HelloWorldTests.al
   create MyNewAppTest\app.json
   create MyNewAppTest\src\TestSuiteInstaller.al
   create MyNewAppTest\src\TestSuiteMgmt.al
   create MyNewApp.code-workspace
```

### B) Unattended mode

This mode automatically generates Unit Testing with "DEFAULT" Test Suite.

`yo dynbc MyNewApp --bcversion 15 --start-id 50000 --range 10 --publisher "My Company" --suffix DBC --skip-quiz`

Output:
```
unattended mode...
--skip-quiz selected, skipping wizard...
   create MyNewAppApp\app.json
   create MyNewAppApp\src\PageExt.HelloWorld.al
   create MyNewAppTest\Scenarios\ScenarioTemplate.ps1
   create MyNewAppTest\tests\HelloWorldTests.al
   create MyNewAppTest\app.json
   create MyNewAppTest\src\TestSuiteInstaller.al
   create MyNewAppTest\src\TestSuiteMgmt.al
   create MyNewApp.code-workspace
```

