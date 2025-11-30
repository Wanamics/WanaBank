
pageextension 87416 "wan Bank Deposit" extends "Bank Deposit"
{
    layout
    {
        addafter("Bank Account No.")
        {
            field("Posting Description"; Rec."Posting Description")
            {
                Visible = true;
                Editable = true;
                ApplicationArea = All;
            }
        }
        modify(Difference) { Importance = Additional; }
        modify("Post as Lump Sum") { Importance = Additional; }
        modify("Document Date") { Importance = Additional; }
        modify("Shortcut Dimension 1 Code") { Importance = Additional; }
        modify("Shortcut Dimension 2 Code") { Importance = Additional; }
        modify("Currency Code") { Importance = Additional; }
    }
}
