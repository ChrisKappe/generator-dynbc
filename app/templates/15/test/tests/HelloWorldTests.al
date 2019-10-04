// https://dev.azure.com/businesscentralapps/HelloWorld

codeunit <%= testNextId %> HelloWorldTests_<%= suffix %>
{
    Subtype = Test;

    var
        Assert: Codeunit Assert;

    [Test]
    procedure WorkingTest();
    begin
        Assert.AreEqual(2, 2, '2 should be 2');
    end;

    [Test]
    procedure FailingTest();
    begin
        Assert.AreEqual(2, 3, '2 should be 3');
    end;
}