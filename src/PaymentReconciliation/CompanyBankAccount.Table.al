table 87400 "wan Company Bank Account"
// Copy from table 270 "Bank Account"
{
    TableType = Temporary;
    Caption = 'MultiComp. Bank Account';

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
        }
        field(13; "Account No."; Code[30])
        {
        }
        field(22; "Currency Code"; Code[10])
        {
        }
        field(81600; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
        }
    }

    keys
    {
        key(Key1; "Account No.")
        {
            Clustered = true;
        }
        key(Key2; "Company Name", "No.")
        {
        }
    }
    internal procedure FillAllCompanies()
    var
        Company: Record Company;
    begin
        if Company.FindSet() then
            repeat
                FillForCompany(Company.Name);
            until Company.Next() = 0;
    end;

    internal procedure FillForCompany(pCompanyName: Text)
    var
        AlreadyExistsErr: Label 'Bank Account %1 of company %2 and %3 of %4 have the same %5 %6';
        BankAccount: Record "Bank Account";
    begin
        BankAccount.ChangeCompany(pCompanyName);
        BankAccount.SetFilter(IBAN, '<>%1', '');
        if BankAccount.FindSet() then
            repeat
                TransferFields(BankAccount);
                "Company Name" := pCompanyName;
                "Account No." := CopyStr(DelChr(BankAccount.IBAN), 5, 21);
                if Get("Account No.") then
                    Error(AlreadyExistsErr,
                        BankAccount."No.", pCompanyName,
                        "No.", "Company Name",
                        BankAccount.FieldCaption("IBAN"), BankAccount.IBAN);
                Insert();
            until BankAccount.Next() = 0;
    end;
}
