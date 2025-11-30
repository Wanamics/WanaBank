codeunit 87410 "wan DirectDebit Instal. Events"
{
    [EventSubscriber(ObjectType::Table, Database::"Direct Debit Collection Entry", 'OnCreateNewOnBeforeInsert', '', false, false)]
    local procedure OnCreateNewOnBeforeInsert(CustLedgerEntry: Record "Cust. Ledger Entry"; var DirectDebitCollectionEntry: Record "Direct Debit Collection Entry")
    var
        DirectDebitInstallment: Record "wan Direct Debit Installment";
        InstallmentAmount: Decimal;
    begin
        if CustLedgerEntry."Payment Method Code" = '' then
            exit;
        DirectDebitInstallment.SetRange("Payment Method Code", CustLedgerEntry."Payment Method Code");
        if DirectDebitInstallment.IsEmpty then
            exit;
        CustLedgerEntry.CalcFields("Original Amount");
        InstallmentAmount := Round(CustLedgerEntry."Original Amount" / (DirectDebitInstallment.Count + 1));
        if DirectDebitCollectionEntry."Transfer Amount" > InstallmentAmount + 0.01 then
            DirectDebitCollectionEntry.Validate("Transfer Amount", InstallmentAmount);
    end;
    /*
        [EventSubscriber(ObjectType::Report, Report::"Post Direct Debit Collection", 'OnAfterCreateJnlLine', '', false, false)]
        local procedure OnAfterCreateJnlLine(var GenJournalLine: Record "Gen. Journal Line"; DirectDebitCollectionEntry: Record "Direct Debit Collection Entry")
        var
            CustLedgerEntry: Record "Cust. Ledger Entry";
            DirectDebitInstallment: Record "wan Direct Debit Installment";
            i: Integer;
        begin
            CustLedgerEntry.Get(DirectDebitCollectionEntry."Applies-to Entry No.");
            DirectDebitInstallment.SetRange("Payment Method Code", CustLedgerEntry."Payment Method Code");
            if DirectDebitInstallment.IsEmpty then
                exit;
            CustLedgerEntry.CalcFields("Original Amount", "Remaining Amount");
            if CustLedgerEntry."Original Amount" = CustLedgerEntry."Remaining Amount" then
                DirectDebitInstallment.FindFirst()
            else begin
                DirectDebitInstallment.Ascending(false);
                DirectDebitInstallment.FindSet();
                for i := 1 to RemainingInstallments(CustLedgerEntry, DirectDebitInstallment.Count + 1) - 1 do
                    if DirectDebitInstallment.Next() = 0 then
                        exit;
            end;
            CustLedgerEntry.Validate("Due Date", CalcDate(DirectDebitInstallment."Due Date Calculation", CustLedgerEntry."Due Date"));
            CustLedgerEntry.Modify();
        end;
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnAfterOldCustLedgEntryModify', '', false, false)]
    local procedure OnAfterOldCustLedgEntryModify(var CustLedgEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    var
        DirectDebitInstallment: Record "wan Direct Debit Installment";
        i: Integer;
    begin
        DirectDebitInstallment.SetRange("Payment Method Code", CustLedgEntry."Payment Method Code");
        if DirectDebitInstallment.IsEmpty then
            exit;
        CustLedgEntry.CalcFields("Original Amount", "Remaining Amount");
        if CustLedgEntry."Original Amount" = CustLedgEntry."Remaining Amount" then
            DirectDebitInstallment.FindFirst()
        else begin
            DirectDebitInstallment.Ascending(false);
            DirectDebitInstallment.FindSet();
            for i := 1 to RemainingInstallments(CustLedgEntry, DirectDebitInstallment.Count + 1) - 1 do
                if DirectDebitInstallment.Next() = 0 then
                    exit;
        end;
        CustLedgEntry.Validate("Due Date", CalcDate(DirectDebitInstallment."Due Date Calculation", CustLedgEntry."Due Date"));
        CustLedgEntry.Modify();
    end;
        */
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnApplyCustLedgEntryOnBeforeCopyFromCustLedgEntry', '', false, false)]
    local procedure OnApplyCustLedgEntryOnBeforeCopyFromCustLedgEntry(var GenJournalLine: Record "Gen. Journal Line"; var OldCVLedgerEntryBuffer: Record "CV Ledger Entry Buffer"; var TempOldCustLedgEntry: Record "Cust. Ledger Entry"; var NewCVLedgEntryBuf: Record "CV Ledger Entry Buffer")
    var
        DirectDebitInstallment: Record "wan Direct Debit Installment";
        i: Integer;
    begin
        DirectDebitInstallment.SetRange("Payment Method Code", TempOldCustLedgEntry."Payment Method Code");
        if DirectDebitInstallment.IsEmpty then
            exit;
        TempOldCustLedgEntry.CalcFields("Original Amount", "Remaining Amount");
        if TempOldCustLedgEntry."Original Amount" = TempOldCustLedgEntry."Remaining Amount" then
            DirectDebitInstallment.FindFirst()
        else begin
            DirectDebitInstallment.Ascending(false);
            DirectDebitInstallment.FindSet();
            for i := 1 to RemainingInstallments(TempOldCustLedgEntry, DirectDebitInstallment.Count + 1) - 1 do
                if DirectDebitInstallment.Next() = 0 then
                    exit;
        end;
        TempOldCustLedgEntry.Validate("Due Date", CalcDate(DirectDebitInstallment."Due Date Calculation", TempOldCustLedgEntry."Due Date"));
        TempOldCustLedgEntry.Modify();
    end;

    local procedure RemainingInstallments(CustLedgerEntry: Record "Cust. Ledger Entry"; NoOfInstallments: Integer): Integer
    var
        InstallmentAmount: Decimal;
    begin
        InstallmentAmount := Round(CustLedgerEntry."Original Amount" / NoOfInstallments);
        exit(Round(CustLedgerEntry."Remaining Amount" / InstallmentAmount, 1));
    end;
}
