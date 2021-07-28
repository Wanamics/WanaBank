codeunit 81608 "wanaBank Test"
{
    // [FEATURE]
    Subtype = Test;
    [Test]
    procedure MyTestError();
    begin
        // [SCENARIO #0001] ...
        // [GIVEN] ...

        // [WHEN] ...

        // [THEN]
        ERROR('MyError')

    end;

    procedure MyTestPass();
    begin
        // [SCENARIO #0001] ...
        // [GIVEN] ...

        // [WHEN] ...

        // [THEN]

    end;
}