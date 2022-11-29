pageextension 81602 "wanaBank Cash Receipt Journal" extends "Cash Receipt Journal"
{
    layout
    {
        addafter(Description)
        {
            field(wanExternalDocumentNumber;Rec."External Document No.")
            {
                ApplicationArea = All;
            }
            field(wanAppliesToID;Rec."Applies-to ID")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        modify(PrintCheckRemittanceReport)
        {
            Promoted = true;
            PromotedCategory = Process;
            PromotedIsBig = true;
            PromotedOnly = true;
        }
    }
}
