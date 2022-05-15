codeunit 81601 "wan Bank Account Rec. Events"
{
    [EventSubscriber(ObjectType::Table, Database::"Bank Acc. Reconciliation Line", 'OnBeforeValidateEvent', 'Account No.', false, false)]
    local procedure OnBeforeValidateEventAccountNo(var Rec: Record "Bank Acc. Reconciliation Line"; var xRec: Record "Bank Acc. Reconciliation Line"; CurrFieldNo: Integer)
    var
        CantBeBankAccountNoErr: TextConst ENU = 'can''t be the same bank account No.', FRA = 'doit être différent du compte bancaire';
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Bank Acc. Reconciliation Post", 'OnBeforePost', '', false, false)]
    local procedure OnBeforePost(var BankAccReconciliation: Record "Bank Acc. Reconciliation"; var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line")
    begin
        BankAccReconciliation.TestField("Statement Date");
    end;

}
