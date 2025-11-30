pageextension 87403 "wan Text-to-Account Mapping" extends "Text-to-Account Mapping"
{
    layout
    {
        modify("Bal. Source No.")
        {
            Visible = false;
        }
        addafter("Bal. Source No.")
        {
            field("wan Bal. Source No."; Rec."Bal. Source No.")
            {
                ApplicationArea = Basic, Suite;
                Enabled = wanEnableBalSourceNo;
                ToolTip = 'Specifies the balancing account to post amounts on payments or incoming documents that have this text to account mapping. The Bank Account option in the Bal. Source Type cannot be used in payment reconciliation journals.';
            }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(wanReorder)
            {
                ApplicationArea = All;
                Caption = 'Order by decreasing length';
                Image = SortDescending;

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

    var
        wanEnableBalSourceNo: Boolean;

    trigger OnAfterGetCurrRecord()
    begin
        wanEnableBalSourceNo := not (Rec."Bal. Source Type" in [Rec."Bal. Source Type"::"G/L Account" /*, "Bal. Source Type"::"Bank Account"]*/]);
    end;

}
