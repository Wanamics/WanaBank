codeunit 87405 "wan Bank Acc. Reconcil. Import"
{
    TableNo = "Bank Acc. Reconciliation";

    trigger OnRun()
    var
        BankAccount: Record "Bank Account";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        DummyBankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        LastStatementNo: Code[20];
        NoTransactionsImportedMsg: Label 'No bank transactions were imported. For example, because the transactions were imported in other bank account reconciliations, or because they are already applied to bank account ledger entries. You can view the applied transactions on the Bank Account Statement List page and on the Posted Payment Reconciliations page.';
    begin
        if not SelectBankAccount(BankAccount) then
            Error(''); // Codeunit.Run return false to IsHandled then continue with standard processing
        //?????????????? BankAccount.LockTable();
        LastStatementNo := BankAccount."Last Statement No.";
        CreateNewBankPaymentAppBatch(BankAccount."No.", BankAccReconciliation);

        if not ImportStatement(BankAccReconciliation, BankAccount) then begin
            DeleteBankAccReconciliation(BankAccReconciliation, BankAccount, LastStatementNo);
            Message(NoTransactionsImportedMsg);
            exit;
        end;

        if DummyBankAccReconciliationLine.BankStatementLinesListIsEmpty(BankAccReconciliation."Statement No.", BankAccReconciliation."Statement Type".AsInteger(), BankAccReconciliation."Bank Account No.") then begin
            DeleteBankAccReconciliation(BankAccReconciliation, BankAccount, LastStatementNo);
            Message(NoTransactionsImportedMsg);
            exit;
        end;

        Commit();

        if BankAccount.Get(BankAccReconciliation."Bank Account No.") then
            if BankAccount."Disable Automatic Pmt Matching" then
                exit;

        ProcessStatement(BankAccReconciliation);
    end;

    local procedure SelectBankAccount(var BankAccount: Record "Bank Account") ReturnValue: Boolean
    begin
        BankAccount.SetFilter("wan Import Object ID", '<>0');
        case BankAccount.Count of
            0:
                ReturnValue := false;
            1:
                ReturnValue := BankAccount.FindFirst();
            else
                if Page.RunModal(Page::"Payment Bank Account List", BankAccount) = action::LookupOK then
                    ReturnValue := BankAccount.Get(BankAccount."No.");
        end;
        BankAccount.SetRange("wan Import Object ID");
    end;

    local procedure CreateNewBankPaymentAppBatch(BankAccountNo: Code[20]; var BankAccReconciliation: Record "Bank Acc. Reconciliation")
    begin
        BankAccReconciliation.Init();
        BankAccReconciliation."Statement Type" := BankAccReconciliation."Statement Type"::"Payment Application";
        BankAccReconciliation.Validate("Bank Account No.", BankAccountNo);
        BankAccReconciliation.Insert(true);
    end;

    local procedure ImportStatement(var BankAccReconciliation: Record "Bank Acc. Reconciliation"; BankAccount: Record "Bank Account"): Boolean
    // var
    //     ProcessBankAccRecLines: Codeunit "Process Bank Acc. Rec Lines";
    begin
        Case BankAccount."wan Import Object Type" of
            BankAccount."wan Import Object Type"::Report:
                // Report.RunModal(BankAccount."wan Import Object ID", false, false, BankAccReconciliation);
                BankAccount.FieldError("wan Import Object Type");
            BankAccount."wan Import Object Type"::Codeunit:
                Codeunit.Run(BankAccount."wan Import Object ID", BankAccReconciliation);
            BankAccount."wan Import Object Type"::XMLport:
                // Xmlport.Run(BankAccount."wan Import Object ID", false, true, BankAccReconciliation);
                BankAccount.FieldError("wan Import Object Type");
            else
                exit(false);
        End;
        exit(true);
    end;

    local procedure DeleteBankAccReconciliation(var BankAccReconciliation: Record "Bank Acc. Reconciliation"; var BankAccount: Record "Bank Account"; LastStatementNo: Code[20])
    begin
        BankAccReconciliation.Delete();
        BankAccount.Get(BankAccount."No.");
        BankAccount."Last Statement No." := LastStatementNo;
        BankAccount.Modify();
        Commit();
    end;

    procedure ProcessStatement(var BankAccReconciliation: Record "Bank Acc. Reconciliation")
    var
        MatchBankPmtAppl: Codeunit "Match Bank Pmt. Appl.";
    begin
        MatchBankPmtAppl.MatchNoOverwriteOfManualOrAccepted(BankAccReconciliation);
        if GuiAllowed then
            BankAccReconciliation.OpenWorksheet(BankAccReconciliation);
    end;
}
