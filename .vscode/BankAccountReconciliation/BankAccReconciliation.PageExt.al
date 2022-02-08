pageextension 81603 "wan Bank Acc. Reconciliation" extends "Bank Acc. Reconciliation"
{
    actions
    {
        /* à revoir
        addafter(ImportBankStatement)
        {
            action(wanImportCFONB120)
            {
                ApplicationArea = All;
                CaptionML = ENU = 'Import CFONB120', FRA = 'Importer CFONB120';
                Image = ImportCodes;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                ToolTip = 'Import electronic bank statements from your bank to populate with data about actual bank transactions.';

                trigger OnAction()
                begin
                    CurrPage.Update();
                    Codeunit.Run(Codeunit::"wanaBank Import CFONB120", Rec);
                    CheckStatementDate();
                    UpdateBankAccountLedgerEntrySubpage(Rec."Statement Date");
                    //RecallEmptyListNotification();
                end;
            }
        }
        */
    }
    //[ Copy from page 379 "Bank Acc. Reconciliation"
    local procedure CheckStatementDate()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        BankAccReconciliationLine.SetFilter("Bank Account No.", Rec."Bank Account No.");
        BankAccReconciliationLine.SetFilter("Statement No.", Rec."Statement No.");
        BankAccReconciliationLine.SetCurrentKey("Transaction Date");
        BankAccReconciliationLine.Ascending := false;
        if BankAccReconciliationLine.FindFirst() then begin
            BankAccReconciliation.GetBySystemId(Rec.SystemId);
            if BankAccReconciliation."Statement Date" = 0D then begin
                if Confirm(StrSubstNo(StatementDateEmptyMsg, Format(BankAccReconciliationLine."Transaction Date"))) then begin
                    Rec."Statement Date" := BankAccReconciliationLine."Transaction Date";
                    Rec.Modify();
                end;
            end else
                if BankAccReconciliation."Statement Date" < BankAccReconciliationLine."Transaction Date" then
                    Message(ImportedLinesAfterStatementDateMsg);
        end;
    end;

    local procedure UpdateBankAccountLedgerEntrySubpage(StatementDate: Date)
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        FilterDate: Date;
    begin
        BankAccountLedgerEntry.SetRange("Bank Account No.", Rec."Bank Account No.");
        BankAccountLedgerEntry.SetRange(Open, true);
        BankAccountLedgerEntry.SetRange(Reversed, false);
        BankAccountLedgerEntry.SetFilter("Statement Status", StrSubstNo('%1|%2|%3', Format(BankAccountLedgerEntry."Statement Status"::Open), Format(BankAccountLedgerEntry."Statement Status"::"Bank Acc. Entry Applied"), Format(BankAccountLedgerEntry."Statement Status"::"Check Entry Applied")));
        FilterDate := wanMatchCandidateFilterDate();
        if StatementDate > FilterDate then
            FilterDate := StatementDate;
        if FilterDate <> 0D then
            BankAccountLedgerEntry.SetFilter("Posting Date", StrSubstNo('<=%1', FilterDate));
        if BankAccountLedgerEntry.FindSet() then;
        CurrPage.ApplyBankLedgerEntries.Page.SetTableView(BankAccountLedgerEntry);
        CurrPage.ApplyBankLedgerEntries.Page.Update();
    end;

    procedure wanMatchCandidateFilterDate(): Date
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        BankAccReconciliationLine.SetRange("Statement Type", Rec."Statement Type");
        BankAccReconciliationLine.SetRange("Statement No.", Rec."Statement No.");
        BankAccReconciliationLine.SetRange("Bank Account No.", Rec."Bank Account No.");
        BankAccReconciliationLine.SetCurrentKey("Transaction Date");
        BankAccReconciliationLine.Ascending := false;
        if BankAccReconciliationLine.FindFirst() then
            if BankAccReconciliationLine."Transaction Date" > Rec."Statement Date" then
                exit(BankAccReconciliationLine."Transaction Date");

        exit(Rec."Statement Date");
    end;

    var
        ImportedLinesAfterStatementDateMsg: Label 'There are lines on the imported bank statement with dates that are after the statement date.';
        StatementDateEmptyMsg: Label 'The bank account reconciliation does not have a statement date. %1 is the latest date on a line. Do you want to use that date for the statement?', Comment = '%1 - statement date';
    //]

}
