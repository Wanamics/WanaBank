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
}

