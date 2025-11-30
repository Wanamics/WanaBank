namespace Wanamics.WanaBank.SummarizeBalAmount;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.Currency;
codeunit 87409 "wan Sum Bal. Bank Acct. Events"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", OnBeforeCode, '', false, false)]
    local procedure OnBeforeCode(var GenJournalLine: Record "Gen. Journal Line"; PreviewMode: Boolean; CommitIsSuppressed: Boolean)
    var
        GenJournalLine2: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        if PreviewMode or CommitIsSuppressed then
            exit;
        GenJournalBatch.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name");
        if not GenJournalBatch."Summarize Bal. Amount" then
            exit;
        GenJournalBatch.TestField("Bal. Account No.");
        GenJournalLine2.Copy(GenJournalLine);
        GenJournalLine2.SetRange("Bal. Account Type", GenJournalBatch."Bal. Account Type");
        GenJournalLine2.SetRange("Bal. Account No.", GenJournalBatch."Bal. Account No.");
        GenJournalLine2.SetRange("Check Printed", false);
        GenJournalLine2.SetRange("Exported to Payment File", true);
        if GenJournalLine2.Count() > 1 then
            SumBalBankAccount(GenJournalLine, GenJournalBatch);

        GenJournalLine2.SetRange("Exported to Payment File");
        GenJournalLine2.SetRange("Check Exported", true); // Set by Print Check Remittance
        if GenJournalLine2.Count() > 1 then
            SumBalBankAccount(GenJournalLine, GenJournalBatch);
    end;

    local procedure SumBalBankAccount(var pGenJournalLine: Record "Gen. Journal Line"; pGenJournalBatch: Record "Gen. Journal Batch")
    var
        SumBalBankAccount: Query "wan Sum Bal. Bank Acct.";
        TempRec: Record "Gen. Journal Line" temporary;
        Currency: Record Currency;
        AdjustAmountLCY: Decimal;
    begin
        SumBalBankAccount.SetRange(JournalTemplateName, pGenJournalLine."Journal Template Name");
        SumBalBankAccount.SetRange(JournalBatchName, pGenJournalLine."Journal Batch Name");
        SumBalBankAccount.SetRange(BalAccountType, pGenJournalBatch."Bal. Account Type");
        SumBalBankAccount.SetRange(BalAccountNo, pGenJournalBatch."Bal. Account No.");
        if SumBalBankAccount.Open() then begin
            pGenJournalLine.FindLast();
            TempRec := pGenJournalLine;
            while SumBalBankAccount.Read() do begin
                TempRec."Line No." += 10000;
                pGenJournalLine."Line No." := TempRec."Line No.";
                pGenJournalLine.InitNewLine(SumBalBankAccount.PostingDate, SumBalBankAccount.PostingDate, SumBalBankAccount.PostingDate, '', '', '', 0, '');
                pGenJournalLine."Source Code" := TempRec."Source Code";
                pGenJournalLine.Validate("Document Type", SumBalBankAccount."DocumentType");
                pGenJournalLine.Validate("Document No.", Format(SumBalBankAccount.PostingDate, 0, 9)); // PostingDate as temporary DocumentNo
                pGenJournalLine.Validate("Account Type", pGenJournalBatch."Bal. Account Type");
                pGenJournalLine.Validate("Account No.", pGenJournalBatch."Bal. Account No.");
                pGenJournalLine.Validate(Description, pGenJournalBatch.Description); //SumBalBankAccountLbl);
                pGenJournalLine.Validate("Currency Code", SumBalBankAccount.CurrencyCode);
                pGenJournalLine.Validate(Amount, -SumBalBankAccount.Amount);
                pGenJournalLine.Validate("Check Exported", SumBalBankAccount.CheckExported);
                pGenJournalLine.Validate("Exported to Payment File", SumBalBankAccount.ExportedToPaymentFile);
                pGenJournalLine.Insert(true);
                AdjustAmountLCY := -(pGenJournalLine."Amount (LCY)" + SumBalBankAccount.AmountLCY);
                if (pGenJournalLine."Currency Code" <> '') and (AdjustAmountLCY <> 0) and
                    (SumBalBankAccount.AccountType in [SumBalBankAccount.AccountType::Vendor, SumBalBankAccount.AccountType::Customer]) then begin
                    TempRec."Line No." += 10000;
                    pGenJournalLine."Line No." := TempRec."Line No.";
                    pGenJournalLine.InitNewLine(SumBalBankAccount.PostingDate, SumBalBankAccount.PostingDate, SumBalBankAccount.PostingDate, '', '', '', 0, '');
                    pGenJournalLine."Source Code" := TempRec."Source Code";
                    pGenJournalLine.Validate("Document Type", SumBalBankAccount."DocumentType");
                    pGenJournalLine.Validate("Document No.", Format(SumBalBankAccount.PostingDate, 0, 9)); // PostingDate as temporary DocumentNo
                    pGenJournalLine.Validate("Account Type", pGenJournalLine."Account Type"::"G/L Account");
                    Currency.Get(pGenJournalLine."Currency Code");
                    if pGenJournalLine.Amount > 0 then
                        pGenJournalLine.Validate("Account No.", Currency."Realized Losses Acc.")
                    else
                        pGenJournalLine.Validate("Account No.", Currency."Realized G/L Gains Account");
                    pGenJournalLine.Validate("Gen. Posting Type", pGenJournalLine."Gen. Posting Type"::" ");
                    pGenJournalLine.Validate("Gen. Bus. Posting Group", '');
                    pGenJournalLine.Validate("Gen. Prod. Posting Group", '');
                    pGenJournalLine.Validate("VAT Bus. Posting Group", '');
                    pGenJournalLine.Validate("VAT Prod. Posting Group", '');
                    pGenJournalLine.Validate(Description, pGenJournalBatch.Description); //SumBalBankAccountLbl);
                    pGenJournalLine.Validate(Amount, AdjustAmountLCY);
                    pGenJournalLine.Insert(true);
                end;
                SetTempDocumentNo(pGenJournalLine, SumBalBankAccount)
            end;
        end;
        Commit(); // Required before RenumberDocumentNo
        pGenJournalLine.RenumberDocumentNo();
        Commit(); // In case of posting error
    end;

    local procedure SetTempDocumentNo(pGenJournalLine: Record "Gen. Journal Line"; pSumBalBankAccount: Query "wan Sum Bal. Bank Acct.")
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date");
        GenJnlLine.SetRange("Journal Template Name", pGenJournalLine."Journal Template Name");
        GenJnlLine.SetRange("Journal Batch Name", pGenJournalLine."Journal Batch Name");
        GenJnlLine.SetRange("Posting Date", pSumBalBankAccount.PostingDate);
        GenJnlLine.SetRange("Document Type", pSumBalBankAccount.DocumentType);
        GenJnlLine.SetRange("Posting Date", pSumBalBankAccount.PostingDate);
        GenJnlLine.SetRange("Currency Code", pSumBalBankAccount.CurrencyCode);
        GenJnlLine.SetRange("Posting Group", pSumBalBankAccount.PostingGroup);
        if GenJnlLine.FindSet(true) then
            repeat
                GenJnlLine.Validate("Bal. Account No.", '');
                GenJnlLine.Validate("Currency Code", pSumBalBankAccount.CurrencyCode);
                GenJnlLine."Document No." := pGenJournalLine."Document No.";
                GenJnlLine.Modify(true);
            until GenJnlLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Gen. Journal Line", OnBeforeSkipRenumberDocumentNo, '', false, false)]
    local procedure OnBeforeSkipRenumberDocumentNo(GenJournalLine: Record "Gen. Journal Line"; var Result: Boolean; var IsHandled: Boolean)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name");
        IsHandled := GenJournalBatch."Summarize Bal. Amount";
    end;
}
