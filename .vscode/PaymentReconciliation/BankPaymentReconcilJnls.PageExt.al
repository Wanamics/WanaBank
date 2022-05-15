pageextension 81601 "wanaBank Payment Reconcil Jnls" extends "Pmt. Reconciliation Journals"
{
    layout
    {
        addafter("Statement No.")
        {
            field("Statement Date2"; Rec."Statement Date")
            {
                ApplicationArea = One;
            }
        }
    }
    actions
    {
        addafter(ImportBankTransactionsToNew)
        {
            action(wanImportCFONB120Mono)
            {
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                CaptionML = ENU = 'Import CFONB120', FRA = 'Import CFNOB120';

                trigger OnAction()
                var
                    BankImportCFONB120: Codeunit "wanaBank Import CFONB120";
                begin
                    //codeunit.RUN(codeunit::"wanaBank Import CFONB120", Rec)
                    BankImportCFONB120.ImportBankAccountReconciliation(Rec, CompanyName);
                end;
            }
            action(wanImportCFONB120Multi)
            {
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                CaptionML = ENU = 'Import CFONB120 multi-sociétés', FRA = 'Import CFNOB120 multi-sociétés';

                trigger OnAction()
                var
                    BankImportCFONB120: Codeunit "wanaBank Import CFONB120";
                begin
                    codeunit.RUN(codeunit::"wanaBank Import CFONB120", Rec)
                end;
            }
        }
    }
}
