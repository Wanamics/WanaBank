codeunit 81600 "wanaBank Import CFONB120"
{
    TableNo = "Bank Acc. Reconciliation";

    trigger OnRun()
    begin
        ImportBankAccountReconciliation(Rec, '');
    end;

    procedure ImportBankAccountReconciliation(var Rec: Record "Bank Acc. Reconciliation"; pCompanyName: Text)
    var
        TempBankAccReconciliation: Record "Bank Acc. Reconciliation" temporary;
        ImportCFONB120: XmlPort "wanaBank Import CFONB120 Multi";
    begin
        Fill(TempBankAccReconciliation);
        if pCompanyName = '' then
            Xmlport.Run(Xmlport::"wanaBank Import CFONB120 multi", false, true)
        else
            ImportCFONB120.ThisCompanyOnly();
        if Rec.FindSet() then
            repeat
                if not TempBankAccReconciliation.GET(Rec."Statement Type", rec."Bank Account No.", Rec."Statement No.") then
                    UpdateBankDescription(Rec);
            until Rec.Next() = 0;
    end;

    local procedure Fill(var pTempRec: Record "Bank Acc. Reconciliation")
    var
        lRec: Record "Bank Acc. Reconciliation";
    begin
        IF lRec.FindSet() then
            repeat
                pTempRec := lRec;
                pTempRec.Insert();
            UNTIL lRec.Next() = 0;
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
                    DataExchField.Value := CopyStr('>' + DataExchField.Value, 1, MAXSTRLEN(DataExchField.Value));
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
                IF CopyStr(pValue, 1, STRLEN(TextToAccountMapping."Mapping Text")) = TextToAccountMapping."Mapping Text" then EXIT(true);
            UNTIL TextToAccountMapping.Next() = 0;
    end;
}
