codeunit 87409 "wan Sum Bal. Bank Acct. Events"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnBeforeCode', '', false, false)]
    local procedure OnBeforeCode(var GenJournalLine: Record "Gen. Journal Line"; PreviewMode: Boolean; CommitIsSuppressed: Boolean)
    var
        GenJournalLine2: Record "Gen. Journal Line";
    begin
        if PreviewMode or CommitIsSuppressed then
            exit;
        GenJournalLine2.Copy(GenJournalLine);
        GenJournalLine2.SetRange("Bal. Account Type", GenJournalLine2."Bal. Account Type"::"Bank Account");
        GenJournalLine2.SetFilter("Bal. Account No.", '<>%1', '');
        GenJournalLine2.SetRange("Exported to Payment File", true);
        if not GenJournalLine2.IsEmpty then
            SumBalBankAccount(GenJournalLine);
    end;

    local procedure SumBalBankAccount(var GenJournalLine: Record "Gen. Journal Line")
    var
        SumBalBankAccount: Query "wan Sum Bal. Bank Acct.";
        TempRec: Record "Gen. Journal Line" temporary;
        SumBalBankAccountLbl: Label 'Sum. Bal. Bank Account';
    begin
        SumBalBankAccount.SetRange(JournalTemplateName, GenJournalLine."Journal Template Name");
        SumBalBankAccount.SetRange(JournalBatchName, GenJournalLine."Journal Batch Name");
        SumBalBankAccount.SetRange(BalAccountType, GenJournalLine."Bal. Account Type"::"Bank Account");
        if SumBalBankAccount.Open() then begin
            GenJournalLine.FindLast();
            TempRec := GenJournalLine;
            while SumBalBankAccount.Read() do begin
                TempRec."Line No." += 10000;
                GenJournalLine."Line No." := TempRec."Line No.";
                GenJournalLine.InitNewLine(SumBalBankAccount.PostingDate, SumBalBankAccount.DocumentDate, SumBalBankAccount.VATReportingDate, '', '', '', 0, '');
                GenJournalLine."Document Type" := TempRec."Document Type";
                GenJournalLine."Source Code" := TempRec."Source Code";
                GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"Bank Account");
                GenJournalLine.Validate("Account No.", SumBalBankAccount.BalAccountNo);
                GenJournalLine.Validate(Description, SumBalBankAccountLbl);
                GenJournalLine.Validate(Amount, -SumBalBankAccount.Amount);
                GenJournalLine.Insert(true);
            end;
            GenJournalLine.SetRange("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
            GenJournalLine.ModifyAll("Bal. Account No.", '', true);
            GenJournalLine.SetRange("Bal. Account Type");
            if GenJournalLine.FindSet() then
                repeat
                    GenJournalLine."Document No." := format(GenJournalLine."Posting Date", 0, 9);
                    GenJournalLine.Modify();
                until GenJournalLine.Next = 0;
            Commit(); // Required before RenumberDocumentNo
            GenJournalLine.RenumberDocumentNo();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", 'OnBeforeSkipRenumberDocumentNo', '', false, false)]
    local procedure OnBeforeSkipRenumberDocumentNo(GenJournalLine: Record "Gen. Journal Line"; var Result: Boolean; var IsHandled: Boolean)
    var
        GenJournalLine2: Record "Gen. Journal Line";
    begin
        GenJournalLine2.Copy(GenJournalLine);
        GenJournalLine2.SetRange("Bal. Account Type", GenJournalLine2."Bal. Account Type"::"Bank Account");
        GenJournalLine2.SetRange("Exported to Payment File", true);
        if not GenJournalLine2.IsEmpty then
            IsHandled := true;
    end;
}
