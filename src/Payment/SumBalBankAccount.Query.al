query 87409 "wan Sum Bal. Bank Acct."
{
    QueryType = Normal;

    elements
    {
        dataitem(GenJournalLine; "Gen. Journal Line")
        {
            column(JournalTemplateName; "Journal Template Name") { }
            column(JournalBatchName; "Journal Batch Name") { }
            column(BalAccountType; "Bal. Account Type") { }
            column(BalAccountNo; "Bal. Account No.") { }
            column(PostingDate; "Posting Date") { }
            column(DocumentDate; "Document Date") { }
            column(VATReportingDate; "VAT Reporting Date") { }
            column(DocumentType; "Document Type") { }
            column(DueDate; "Due Date") { }
            column(Amount; Amount)
            {
                Method = Sum;
            }
        }
    }
}
