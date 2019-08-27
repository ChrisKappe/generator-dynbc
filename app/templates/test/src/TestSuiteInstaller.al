// https://dev.azure.com/businesscentralapps/HelloWorld

codeunit <%= testNextId %> "TestInstaller_<%= suffix %>"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    var
        TestSuite: Codeunit "TestSuiteMgmt_<%= suffix %>";
    begin
        TestSuite.Create('<%= testSuiteName %>', '<%= testStartId %>..<%= testEndId %>', false);
    end;
}