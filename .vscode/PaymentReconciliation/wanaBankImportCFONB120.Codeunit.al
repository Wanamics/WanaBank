codeunit 81600 "wanaBank Import CFONB120"
{
    TableNo = 273;

    trigger OnRun()begin
        ImportBankAccountReconciliation(rec);
    end;
    local procedure ImportBankAccountReconciliation(var Rec: Record 273)var TempBankAccReconciliation: Record 273 temporary;
    begin
        Fill(TempBankAccReconciliation);
        XMLPORT.RUN(XMLPORT::"wanaBank Import CFONB120", FALSE, TRUE);
        IF rec.FINDSET THEN REPEAT IF NOT TempBankAccReconciliation.GET(rec."Statement Type", rec."Bank Account No.", rec."Statement No.")THEN UpdateBankDescription(Rec);
            UNTIL rec.NEXT = 0;
    end;
    local procedure Fill(var pTempRec: Record 273)var lRec: Record 273;
    begin
        IF lRec.FINDSET THEN REPEAT pTempRec:=lRec;
                pTempRec.INSERT;
            UNTIL lRec.NEXT = 0;
    end;
    local procedure UpdateBankDescription(var pBankAccReconciliation: Record 273)var BankAccReconciliationLine: Record 274;
    begin
        BankAccReconciliationLine.SETRANGE("Statement Type", pBankAccReconciliation."Statement Type");
        BankAccReconciliationLine.SETRANGE("Bank Account No.", pBankAccReconciliation."Bank Account No.");
        BankAccReconciliationLine.SETRANGE("Statement No.", pBankAccReconciliation."Statement No.");
        IF BankAccReconciliationLine.FINDSET THEN REPEAT IF NOT Match(BankAccReconciliationLine."Transaction Text")THEN FecthMapping(BankAccReconciliationLine);
            UNTIL BankAccReconciliationLine.NEXT = 0;
    end;
    local procedure FecthMapping(BankAccReconciliationLine: Record 274): Boolean var DataExchField: Record 1221;
    begin
        DataExchField.SETRANGE("Data Exch. No.", BankAccReconciliationLine."Data Exch. Entry No.");
        DataExchField.SETRANGE("Line No.", BankAccReconciliationLine."Data Exch. Line No.");
        IF DataExchField.FINDSET THEN REPEAT IF Match(DataExchField.Value)THEN BEGIN
                    BankAccReconciliationLine."Transaction Text":=DataExchField.Value;
                    BankAccReconciliationLine.MODIFY;
                    DataExchField.Value:=COPYSTR('>' + DataExchField.Value, 1, MAXSTRLEN(DataExchField.Value));
                    DataExchField.MODIFY;
                    EXIT;
                END;
            UNTIL DataExchField.NEXT = 0;
    end;
    local procedure Match(pValue: Text): Boolean var TextToAccountMapping: Record 1251;
    begin
        IF TextToAccountMapping.FINDSET THEN REPEAT IF COPYSTR(pValue, 1, STRLEN(TextToAccountMapping."Mapping Text")) = TextToAccountMapping."Mapping Text" THEN EXIT(TRUE);
            UNTIL TextToAccountMapping.NEXT = 0;
    end;
}
