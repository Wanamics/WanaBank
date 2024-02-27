pageextension 87417 "wan Bank Deposit Subform" extends "Bank Deposit Subform"
{
    layout
    {
        moveafter("Document No."; "Applies-to Doc. Type")
        moveafter("Applies-to Doc. Type"; "Applies-to Doc. No.")
        modify("Applies-to Doc. Type") { Visible = true; }
        modify("Applies-to Doc. No.") { Visible = true; }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Account Type" := Rec."Account Type"::Customer;
        Rec."Document No." := '';
    end;
}
