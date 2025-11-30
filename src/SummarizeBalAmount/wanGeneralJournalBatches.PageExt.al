namespace Wanamics.WanaBank.SummarizeBalAmount;

using Microsoft.Finance.GeneralLedger.Journal;

pageextension 87418 "wan General Journal Batches" extends "General Journal Batches"
{
    layout
    {
        addlast(Control1)
        {
            field("wan Summarize Bal. Amount"; Rec."Summarize Bal. Amount")
            {
                ApplicationArea = All;
                Caption = 'Summarize Bal. Amount';
            }
        }
    }
}
