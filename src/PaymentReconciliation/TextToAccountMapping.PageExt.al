pageextension 87403 "wan Text-to-Account Mapping" extends "Text-to-Account Mapping"
{
    actions
    {
        addlast(Processing)
        {
            action(wanReorder)
            {
                ApplicationArea = All;
                Caption = 'Order by decreasing length';

                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"wan Text to Account Reorder", Rec);
                end;
            }
        }
        addlast(Promoted)
        {
            actionref(ReorderRef; wanReorder)
            {
            }
        }
    }
}
