pageextension 87409 "wan Payment Rec Match Details" extends "Payment Rec Match Details"
{
    layout
    {
        addfirst(content)
        {
            field("Transaction Text"; Rec."Transaction Text")
            {
                ApplicationArea = All;
                MultiLine = true;
                ShowCaption = false;
            }
        }
    }
}
