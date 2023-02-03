codeunit 87401 "wan Bank Acc. Reconcil. Events"
{
    [EventSubscriber(ObjectType::Table, Database::"Bank Acc. Reconciliation Line", 'OnBeforeValidateEvent', 'Account No.', false, false)]
    local procedure OnBeforeValidateEventAccountNo(var Rec: Record "Bank Acc. Reconciliation Line"; var xRec: Record "Bank Acc. Reconciliation Line"; CurrFieldNo: Integer)
    var
        CantBeBankAccountNoErr: Label 'can''t be the same bank account No.';
    begin
        if (CurrFieldNo = Rec.Fieldno("Account No.")) and (Rec."Account Type" = Rec."Account Type"::"Bank Account") and (Rec."Account No." = Rec."Bank Account No.") then
            Rec.FieldError("Account No.", CantBeBankAccountNoErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Bank Acc. Reconciliation Post", 'OnPostPaymentApplicationsOnAfterInitGenJnlLine', '', false, false)]
    local procedure OnPostPaymentApplicationsOnAfterInitGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    begin
        if GenJournalLine.Description = '' then
            GenJournalLine.Description := BankAccReconciliationLine."Transaction Text";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Bank Acc. Reconciliation Post", 'OnTransferToPostPmtApplnOnBeforePostedPmtReconLineInsert', '', false, false)]
    local procedure OnTransferToPostPmtApplnOnBeforePostedPmtReconLineInsert(var PostedPmtReconLine: Record "Posted Payment Recon. Line"; BankAccReconLine: Record "Bank Acc. Reconciliation Line")
    begin
        if PostedPmtReconLine.Description = '' then
            PostedPmtReconLine.Description := BankAccReconLine."Transaction Text";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Bank Acc. Reconciliation Post", 'OnBeforePost', '', false, false)]
    local procedure OnBeforePost(var BankAccReconciliation: Record "Bank Acc. Reconciliation"; var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    var
        ImportedLinesAfterStatementDateMsg: Label 'There are lines on the imported bank statement with dates that are after the statement date.';
    begin
        BankAccReconciliationLine.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        BankAccReconciliationLine.SetRange("Statement No.", BankAccReconciliation."Statement No.");
        BankAccReconciliationLine.SetCurrentKey("Transaction Date");
        if BankAccReconciliationLine.IsEmpty then
            InsertNullLine(BankAccReconciliation, BankAccReconciliationLine)
        else
            if BankAccReconciliationLine.FindLast() and (BankAccReconciliation."Statement Date" < BankAccReconciliationLine."Transaction Date") then
                Message(ImportedLinesAfterStatementDateMsg);
    end;

    local procedure InsertNullLine(BankAccReconciliation: Record "Bank Acc. Reconciliation"; var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    begin
        BankAccReconciliationLine.Init();
        BankAccReconciliationLine."Statement Type" := BankAccReconciliation."Statement Type";
        BankAccReconciliationLine."Bank Account No." := BankAccReconciliation."Bank Account No.";
        BankAccReconciliationLine."Statement No." := BankAccReconciliation."Statement No.";
        BankAccReconciliationLine."Transaction Date" := BankAccReconciliation."Statement Date";
        BankAccReconciliationLine."Account Type" := BankAccReconciliationLine."Account Type"::"Bank Account";
        BankAccReconciliationLine."Account No." := BankAccReconciliation."Bank Account No.";
        BankAccReconciliationLine.Insert();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Bank Acc. Reconciliation", 'OnBeforeDeleteEvent', '', false, false)]
    local procedure OnBeforeDeleteEvent(var Rec: Record "Bank Acc. Reconciliation")
    var
        lRec: Record "Bank Acc. Reconciliation";
        MustBeTheLastOneErr: Label 'must be the last one for this bank account';
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        if Rec.IsTemporary then
            exit;
        BankAccReconciliationLine.SetRange("Statement Type", Rec."Statement Type");
        BankAccReconciliationLine.SetRange("Bank Account No.", Rec."Bank Account No.");
        BankAccReconciliationLine.SetRange("Statement No.", Rec."Statement No.");
        if BankAccReconciliationLine.IsEmpty then
            exit;
        lRec.SetCurrentKey("Statement Type", "Bank Account No.", "Statement Date");
        lRec.SetRange("Statement Type", Rec."Statement Type");
        lRec.SetRange("Bank Account No.", Rec."Bank Account No.");
        if lRec.FindLast() and (lRec."Statement No." <> Rec."Statement No.") then
            Rec.FieldError("Statement Date", MustBeTheLastOneErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Bank Acc. Recon. Post (Yes/No)", 'OnBeforeBankAccReconPostYesNo', '', false, false)]
    local procedure OnBeforeBankAccReconPostYesNo(var BankAccReconciliation: Record "Bank Acc. Reconciliation"; var Result: Boolean; var Handled: Boolean)
    var
        lRec: Record "Bank Acc. Reconciliation";
        MustBeTheFirstOneErr: Label 'must be the first one for this bank account';
    begin
        if BankAccReconciliation.IsTemporary then
            exit;
        lRec.SetCurrentKey("Statement Type", "Bank Account No.", "Statement Date");
        lRec.SetRange("Statement Type", BankAccReconciliation."Statement Type");
        lRec.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        if lRec.FindFirst() and (lRec."Statement No." <> BankAccReconciliation."Statement No.") then
            BankAccReconciliation.FieldError("Statement Date", MustBeTheFirstOneErr);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Match Bank Pmt. Appl.", 'OnBeforeOnRun', '', false, false)]
    local procedure OnBeforeOnRun(var BankAccReconciliation: Record "Bank Acc. Reconciliation"; var IsHandled: Boolean)
    begin
        Codeunit.Run(Codeunit::"wan Text to Account Mapping", BankAccReconciliation);
    end;
}