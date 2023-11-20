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
            field(wanNoOfLines; wanNoOfLines())
            {
                Caption = 'No. of Lines';
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
                Caption = 'Import CFONB120';
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::"wan Bank Rec. Import CFONB120");
                end;
            }
            action(wanImportCFONB000)
            {
                ApplicationArea = All;
                Image = Import;
                Visible = false;
                Caption = 'Import CFONB120 (no separator)';
                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::"wan Bank Rec. Import CFONB000");
                end;
            }
        }
        addlast(Promoted)
        {
            actionref(wanImportCFONB120_Promoted; wanImportCFONB120) { }
            actionref(wanImportCFONB000_Promoted; wanImportCFONB000) { }
        }
    }
    local procedure wanNoOfLines(): Integer
    var
        BancAccReconcilisationLine: Record "Bank Acc. Reconciliation Line";
    begin
        BancAccReconcilisationLine.SetRange("Statement Type", Rec."Statement Type");
        BancAccReconcilisationLine.SetRange("Bank Account No.", Rec."Bank Account No.");
        BancAccReconcilisationLine.SetRange("Statement No.", Rec."Statement No.");
        Exit(BancAccReconcilisationLine.Count());
    end;
}
