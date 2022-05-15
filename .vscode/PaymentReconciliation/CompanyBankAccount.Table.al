table 81600 "wan Company Bank Account Buf."
{
    TableType = Temporary;

    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; Name; Text[100])
        {
        }
        field(3; "Company Name"; Text[30]) { }
        field(13; "Bank Account No."; Code[30])
        {
        }
        field(22; "Currency Code"; Code[10])
        {
        }
        field(37; Amount; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
        }
        field(39; Blocked; Boolean)
        {
        }
        field(41; "Last Statement No."; Code[20])
        {
        }
        field(42; "Last Payment Statement No."; Code[20])
        {

        }
        field(94; "Balance Last Statement"; Decimal)
        {
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
        }
        field(101; "Bank Branch No."; Code[20])
        {
        }
        field(110; IBAN; Code[50])
        {
        }
        field(111; "SWIFT Code"; Code[20])
        {
        }
    }

    keys
    {
        key(Key1; "Bank Branch No.", "Bank Account No.")
        {
            Clustered = true;
        }
        key(Key2; "Company Name", "No.")
        {
        }
    }
}

