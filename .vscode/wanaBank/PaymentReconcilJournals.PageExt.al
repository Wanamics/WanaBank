pageextension 81601 "wanaBank Payment Reconcil Jnls" extends "Pmt. Reconciliation Journals"
{
    layout
    {
        addafter("Statement No.")
        {
            field("Statement Date2"; rec."Statement Date")
            {
                ApplicationArea = One;
            }
        }
    }
    actions
    {
        addafter(ImportBankTransactionsToNew)
        {
            action(ImportCFONB120)
            {
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Caption = 'Import CFONB120';
                trigger OnAction()
                begin
                    codeunit.RUN(codeunit::"wanaBank Import CFONB120", rec)
                end;

            }
        }
    }

}