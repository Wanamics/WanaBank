namespace Wanamics.WanaBank.SummarizeBalAmount;

using Microsoft.Finance.GeneralLedger.Journal;
query 87409 "wan Sum Bal. Bank Acct."
{
    QueryType = Normal;

    elements
    {
        dataitem(GenJournalLine; "Gen. Journal Line")
        {
            column(JournalTemplateName; "Journal Template Name") { }
            column(JournalBatchName; "Journal Batch Name") { }
            column(AccountType; "Account Type") { }
            column(PostingGroup; "Posting Group") { }
            column(BalAccountType; "Bal. Account Type") { }
            column(BalAccountNo; "Bal. Account No.") { }
            column(CurrencyCode; "Currency Code") { }
            column(PostingDate; "Posting Date") { }
            // column(DocumentDate; "Document Date") { }
            // column(VATReportingDate; "VAT Reporting Date") { }
            column(DocumentType; "Document Type") { }
            // column(DueDate; "Due Date") { }
            column(CheckExported; "Check Exported") { }
            column(ExportedToPaymentFile; "Exported to Payment File") { }
            column(Amount; Amount)
            {
                Method = Sum;
            }
            column(AmountLCY; "Amount (LCY)")
            {
                Method = Sum;
            }
        }
    }
}
