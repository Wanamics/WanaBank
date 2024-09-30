pageextension 87417 "wan Bank Deposit Subform" extends "Bank Deposit Subform"
{
    layout
    {
        movefirst(Control1020000; "Document No.")
        moveafter("Document No."; "Document Date")
        moveafter("Document Date"; "Credit Amount")
        moveafter("Credit Amount"; "Account Type")
        moveafter("Account Type"; "Account No.")
        moveafter("Account No."; "Applies-to Doc. Type")
        moveafter("Applies-to Doc. Type"; "Applies-to Doc. No.")
        moveafter("Applies-to Doc. No."; Description)
        modify("Document Type") { Visible = false; }
        modify("Applies-to Doc. Type") { Visible = true; }
        modify("Applies-to Doc. No.") { Visible = true; }
        modify(TotalDepositLines) { Caption = 'Total Deposit Lines'; }
        addafter(Control1020000)
        {
            grid(Totals)
            {
                GridLayout = Columns;
                field(NoOfLines; Rec.Count) { ApplicationArea = All; Caption = 'No. of Lines'; }
            }
        }
        movefirst(Totals; TotalDepositLines)
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.Validate("Account Type", Rec."Account Type"::Customer);
        Rec.Validate("Document No.", '');
        Rec.Validate("Document Date", 0D);
    end;
}
