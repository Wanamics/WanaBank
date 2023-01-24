codeunit 87400 "wan Bank Rec. Import CFONB120"
{
    TableNo = "Bank Acc. Reconciliation";

    trigger OnRun()
    begin
        /*
        if pCompanyName = '' then
            ImportCFONB120.AllCompanies()
        else
            ImportCFONB120.OneCompany();
        */
        Xmlport.Run(XmlPort::"wan Bank Rec. Import CFONB120");
        if Rec.FindSet() then
            repeat
                if not Rec.Get(Rec."Statement Type", Rec."Bank Account No.", Rec."Statement No.") then
                    UpdateBankDescription(Rec);
            until Rec.Next() = 0;
    end;

    local procedure UpdateBankDescription(var pBankAccReconciliation: Record "Bank Acc. Reconciliation")
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        BankAccReconciliationLine.SetRange("Statement Type", pBankAccReconciliation."Statement Type");
        BankAccReconciliationLine.SetRange("Bank Account No.", pBankAccReconciliation."Bank Account No.");
        BankAccReconciliationLine.SetRange("Statement No.", pBankAccReconciliation."Statement No.");
        IF BankAccReconciliationLine.FindSet() then
            repeat
                if not Match(BankAccReconciliationLine."Transaction Text") then
                    FecthMapping(BankAccReconciliationLine);
            until BankAccReconciliationLine.Next() = 0;
    end;

    local procedure FecthMapping(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"): Boolean
    var
        DataExchField: Record "Data Exch. Field";
    begin
        DataExchField.SetRange("Data Exch. No.", BankAccReconciliationLine."Data Exch. Entry No.");
        DataExchField.SetRange("Line No.", BankAccReconciliationLine."Data Exch. Line No.");
        IF DataExchField.FindSet then
            repeat
                IF Match(DataExchField.Value) then begin
                    BankAccReconciliationLine."Transaction Text" := DataExchField.Value;
                    BankAccReconciliationLine.Modify;
                    DataExchField.Value := CopyStr('>' + DataExchField.Value, 1, MaxStrLen(DataExchField.Value));
                    DataExchField.Modify;
                    EXIT;
                end;
            UNTIL DataExchField.Next() = 0;
    end;

    local procedure Match(pValue: Text): Boolean
    var
        TextToAccountMapping: Record "Text-to-Account Mapping";
    begin
        IF TextToAccountMapping.FindSet then
            repeat
                if CopyStr(pValue, 1, StrLen(TextToAccountMapping."Mapping Text")) = TextToAccountMapping."Mapping Text" then EXIT(true);
            until TextToAccountMapping.Next() = 0;
    end;
}
