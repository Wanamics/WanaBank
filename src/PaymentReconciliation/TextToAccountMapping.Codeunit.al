codeunit 87400 "wan Text to Account Mapping"
{
    TableNo = "Bank Acc. Reconciliation";

    trigger OnRun()
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        if not FillMappingList() then
            exit;
        BankAccReconciliationLine.SetRange("Statement Type", Rec."Statement Type");
        BankAccReconciliationLine.SetRange("Bank Account No.", Rec."Bank Account No.");
        BankAccReconciliationLine.SetRange("Statement No.", Rec."Statement No.");
        if BankAccReconciliationLine.FindSet() then
            repeat
                if not Match(BankAccReconciliationLine."Transaction Text") then
                    FecthMapping(BankAccReconciliationLine);
            until BankAccReconciliationLine.Next() = 0;
    end;

    local procedure FillMappingList(): Boolean;
    var
        TextToAccountMapping: Record "Text-to-Account Mapping";
    begin
        if not TextToAccountMapping.FindSet then
            exit(false);
        repeat
            MappingList.Add(TextToAccountMapping."Mapping Text");
        until TextToAccountMapping.Next() = 0;
        OrderByDescLength(MappingList);
        exit(true);
    end;

    local procedure OrderByDescLength(var pList: List of [Text])
    var
        i, j : Integer;
        Hold: Text;
    begin
        for i := 1 to pList.Count do
            for j := 1 to pList.Count - i do
                if StrLen(pList.Get(j + 1)) > StrLen(pList.Get(j)) then begin
                    Hold := pList.Get(j);
                    pList.Set(j, pList.Get(j + 1));
                    pList.Set(j + 1, Hold);
                end;
    end;

    local procedure Match(pValue: Text): Boolean
    var
        i: Integer;
    begin
        for i := MappingList.Count downto 1 do
            if CopyStr(pValue, 1, StrLen(MappingList.Get(i))) = MappingList.Get(i) then
                exit(true);
    end;

    local procedure FecthMapping(BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"): Boolean
    var
        DataExchField: Record "Data Exch. Field";
        Hold: Text;
    begin
        DataExchField.SetRange("Data Exch. No.", BankAccReconciliationLine."Data Exch. Entry No.");
        DataExchField.SetRange("Line No.", BankAccReconciliationLine."Data Exch. Line No.");
        if DataExchField.FindSet then
            repeat
                if Match(DataExchField.Value) then begin
                    Hold := BankAccReconciliationLine."Transaction Text";
                    BankAccReconciliationLine."Transaction Text" := DataExchField.Value;
                    BankAccReconciliationLine.Modify;
                    DataExchField.Value := CopyStr('>' + DataExchField.Value, 1, MaxStrLen(DataExchField.Value));
                    DataExchField.Modify;
                    DataExchField."Column No." := 0;
                    DataExchField.Value := Hold;
                    if DataExchField.Insert() then;
                    exit;
                end;
            until DataExchField.Next() = 0;
    end;

    var
        MappingList: List of [Text];
}
