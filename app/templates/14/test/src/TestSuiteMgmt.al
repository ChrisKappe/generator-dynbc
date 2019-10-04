// https://dev.azure.com/businesscentralapps/HelloWorld

codeunit <%= testStartId %> "TestSuiteMgmt_<%= suffix %>"
{
    procedure Create(TestSuiteName: code[10]; TestCodeunitFilter: Text; EmptyTestSuite: Boolean)
    var
        CALTestLine: Record "CAL Test Line";
        TempAllObjWithCaption: Record AllObjWithCaption temporary;
    begin
        TryInsertTestSuite(TestSuiteName);

        CALTestLine.SETRANGE("Test Suite", TestSuiteName);
        IF EmptyTestSuite THEN
            CALTestLine.DELETEALL(TRUE);

        IF GetTestCodeunits(TestCodeunitFilter, TempAllObjWithCaption) THEN
            RefreshSuite(TestSuiteName, TempAllObjWithCaption);
    end;

    local procedure TryInsertTestSuite(TestSuiteName: code[10])
    var
        CALTestSuite: Record "CAL Test Suite";
    begin
        if CALTestSuite.Get(TestSuiteName) then
            exit;

        with CALTestSuite do begin
            init();

            VALIDATE(Name, TestSuiteName);
            VALIDATE(Description, TestSuiteName);
            VALIDATE(Export, FALSE);
            INSERT(TRUE);
        end;

    end;

    local procedure GetTestCodeunits(TestCodeunitFilter: Text; VAR ToAllObjWithCaption: Record AllObjWithCaption): Boolean;
    var
        FromAllObjWithCaption: Record AllObjWithCaption;
    begin
        WITH ToAllObjWithCaption DO BEGIN
            FromAllObjWithCaption.SETRANGE("Object Type", "Object Type"::Codeunit);
            FromAllObjWithCaption.SetFilter("Object ID", TestCodeunitFilter);
            FromAllObjWithCaption.SETRANGE("Object Subtype", 'Test');
            IF FromAllObjWithCaption.FIND('-') THEN
                REPEAT
                    ToAllObjWithCaption := FromAllObjWithCaption;
                    Insert();
                UNTIL FromAllObjWithCaption.NEXT() = 0;
        END;

        EXIT(ToAllObjWithCaption.FIND('-'));
    end;

    local procedure RefreshSuite(CALTestSuiteName: code[10]; VAR AllObjWithCaption: Record AllObjWithCaption);
    var
        CALTestLine: Record "CAL Test Line";
        LineNo: Integer;
    begin
        WITH CALTestLine DO BEGIN
            LineNo := LineNo + 10000;

            INIT();
            VALIDATE("Test Suite", CALTestSuiteName);
            VALIDATE("Line No.", LineNo);
            VALIDATE("Line Type", "Line Type"::Group);
            VALIDATE(Name, CALTestSuiteName);
            VALIDATE(Run, TRUE);
            if not INSERT(TRUE) then;

            AddTestCodeunits(CALTestSuiteName, AllObjWithCaption);
        END;
    end;

    local procedure AddTestCodeunits(CALTestSuiteName: Code[10]; VAR AllObjWithCaption: Record AllObjWithCaption);
    var
        TestLineNo: Integer;
    begin
        IF AllObjWithCaption.FIND('-') THEN BEGIN
            TestLineNo := GetLastTestLineNo(CALTestSuiteName);
            REPEAT
                TestLineNo := TestLineNo + 10000;
                AddTestLine(CALTestSuiteName, AllObjWithCaption."Object ID", TestLineNo);
            UNTIL AllObjWithCaption.NEXT() = 0;
        END;
    end;

    local procedure GetLastTestLineNo(TestSuiteName: Code[10]) LineNo: Integer;
    var
        CALTestLine: Record "CAL Test Line";
    begin
        CALTestLine.SETRANGE("Test Suite", TestSuiteName);
        IF CALTestLine.FINDLAST() THEN
            LineNo := CALTestLine."Line No.";
    end;

    local procedure AddTestLine(TestSuiteName: Code[10]; TestCodeunitId: Integer; LineNo: Integer);
    var
        CALTestLine: Record "CAL Test Line";
        AllObj: Record AllObj;
        CALTestMgmt: Codeunit "CAL Test Management";
        CodeunitIsValid: Boolean;
        ObjectNotCompiledErr: Label 'Object not compiled';
    begin
        WITH CALTestLine DO BEGIN
            TestLineExists(TestSuiteName, TestCodeunitId);

            INIT();
            VALIDATE("Test Suite", TestSuiteName);
            VALIDATE("Line No.", LineNo);
            VALIDATE("Line Type", "Line Type"::Codeunit);
            VALIDATE("Test Codeunit", TestCodeunitId);
            VALIDATE(Run, TRUE);

            INSERT(TRUE);

            AllObj.SETRANGE("Object Type", AllObj."Object Type"::Codeunit);
            AllObj.SETRANGE("Object ID", TestCodeunitId);
            IF FORMAT(AllObj."App Package ID") <> '' THEN
                CodeunitIsValid := TRUE;

            IF CodeunitIsValid THEN BEGIN
                CALTestMgmt.SETPUBLISHMODE();
                SETRECFILTER();
                CODEUNIT.RUN(CODEUNIT::"CAL Test Runner", CALTestLine);
            END ELSE BEGIN
                VALIDATE(Result, Result::Failure);
                VALIDATE("First Error", ObjectNotCompiledErr);
                MODIFY(TRUE);
            END;
        END;
    end;

    local procedure TestLineExists(TestSuiteName: Code[10]; TestCodeunitId: Integer): Boolean;
    var
        CALTestLine: Record "CAL Test Line";
    begin
        CALTestLine.SETRANGE("Test Suite", TestSuiteName);
        CALTestLine.SETRANGE("Test Codeunit", TestCodeunitId);
        if NOT CALTestLine.ISEMPTY() then
            CALTestLine.DeleteAll();
    end;
}