table 87410 "wan Direct Debit Installment"
{
    Caption = 'Direct Debit Installment';
    DataClassification = ToBeClassified;
    DrillDownPageId = "wan Direct Debit Installments";
    LookupPageId = "wan Direct Debit Installments";

    fields
    {
        field(1; "Payment Method Code"; Code[10])
        {
            Caption = 'Payment Method Code';
            DataClassification = ToBeClassified;
            TableRelation = "Payment Method";
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = SystemMetadata;
        }
        field(3; "Due Date Calculation"; DateFormula)
        {
            Caption = 'Due Date Calculation';
        }
    }
    keys
    {
        key(PK; "Payment Method Code", "Line No.")
        {
            Clustered = true;
        }
    }
}
