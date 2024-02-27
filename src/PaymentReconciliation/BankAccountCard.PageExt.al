pageextension 87413 "wan Bank Account Card" extends "Bank Account Card"
{
    layout
    {
        addafter("Bank Statement Import Format")
        {
            field("wan Import Object Type"; Rec."wan Import Object Type")
            {
                ApplicationArea = All;
            }
            field("wan Import Object ID"; Rec."wan Import Object ID")
            {
                ApplicationArea = All;
            }
        }
    }
}
