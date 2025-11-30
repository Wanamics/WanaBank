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
            action(WanaBankImport)
            {
                ApplicationArea = All;
                Image = Import;
                Visible = WanaBankImportVisible;
                ;
                Caption = 'WanaBank Import';
                trigger OnAction()
                begin
                    Codeunit.Run(Codeunit::"wan Bank Acc. Reconcil. Import", Rec);
                end;
            }
        }
        addlast(Category_Process)
        {
            actionref(wanImportCFONB120_Promoted; wanImportCFONB120) { }
            actionref(wanImportCFONB000_Promoted; wanImportCFONB000) { }
        }
        addlast(Promoted)
        {
            actionref(WanaBankImport_Promoted; WanaBankImport) { }
        }
    }
    local procedure wanNoOfLines(): Integer
    var
        BancAccReconcilisationLine: Record "Bank Acc. Reconciliation Line";
    begin
        BancAccReconcilisationLine.SetRange("Statement Type", Rec."Statement Type");
        BancAccReconcilisationLine.SetRange("Bank Account No.", Rec."Bank Account No.");
        BancAccReconcilisationLine.SetRange("Statement No.", Rec."Statement No.");
        exit(BancAccReconcilisationLine.Count());
    end;

    var
        WanaBankImportVisible: Boolean;

    trigger OnOpenPage()
    var
        BankAccount: Record "Bank Account";
    begin
        BankAccount.SetFilter("wan Import Object ID", '<> 0');
        WanaBankImportVisible := not BankAccount.IsEmpty;
    end;
}
