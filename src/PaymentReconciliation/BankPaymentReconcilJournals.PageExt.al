pageextension 87401 "wan Payment Reconcil. Journals" extends "Pmt. Reconciliation Journals"
{
    layout
    {
        addafter("Statement No.")
        {
            field("Statement Date"; Rec."Statement Date")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addafter(ImportBankTransactionsToNew)
        {
            action(wanImportCFONB120)
            {
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Caption = 'Import CFONB120';

                trigger OnAction()
                var
                    BankImportCFONB120: Codeunit "wan Bank Rec. Import CFONB120";
                begin
                    BankImportCFONB120.ImportBankAccountReconciliation(Rec, CompanyName);
                end;
            }
        }
    }
}