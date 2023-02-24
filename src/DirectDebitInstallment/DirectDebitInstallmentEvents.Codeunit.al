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

    local procedure RemainingInstallments(CustLedgerEntry: Record "Cust. Ledger Entry"; NoOfInstallments: Integer): Integer
    var
        InstallmentAmount: Decimal;
    begin
        InstallmentAmount := Round(CustLedgerEntry."Original Amount" / NoOfInstallments);
        exit(Round(CustLedgerEntry."Remaining Amount" / InstallmentAmount, 1));
    end;
}
