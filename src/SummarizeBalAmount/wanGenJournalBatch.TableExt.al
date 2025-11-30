namespace Wanamics.WanaBank.SummarizeBalAmount;

using Microsoft.Finance.GeneralLedger.Journal;

tableextension 87402 "wan Gen. Journal Batch" extends "Gen. Journal Batch"
{
    fields
    {
        field(87400; "Summarize Bal. Amount"; Boolean)
        {
            Caption = 'Summarize Bal. Amount';
            DataClassification = ToBeClassified;
        }
    }
}
