/*
xmlport 81600 "wanaBank Import CFONB120 Mono"
{
    // Quid s'il existe déjà un relevé pour le même compte (erreur ou compléter ?)
    // Quid si compte n'existe pas, skip ou erreur ?
    // Contrôle date début > celle du dernier relevé (ou skip si <=)
    Caption = 'Import Bank Entries';
    Direction = Import;
    Format = FixedText;
    FormatEvaluate = Legacy;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement(Table2000000026;
            2000000026)
            {
                AutoReplace = false;
                AutoSave = false;
                AutoUpdate = false;
                MinOccurs = Zero;
                XmlName = 'Integer';

                textelement(_EntryCode)
                {
                    Width = 2;
                }
                textelement(_BankCode)
                {
                    Width = 5;
                }
                textelement(InternalOperationCode)
                {
                    Width = 4;
                }
                textelement(_BankBranchNo)
                {
                    Width = 5;
                }
                textelement(_CurrencyCode)
                {
                    Width = 3;
                }
                textelement(_NoOfDecimals)
                {
                    Width = 1;
                }
                textelement(CurrencySource)
                {
                    Width = 1;
                }
                textelement(_BankAccountNo)
                {
                    Width = 11;
                }
                textelement(_CFONB)
                {
                    Width = 2;
                }
                textelement(_OperationDate)
                {
                    Width = 6;
                }
                textelement(DischargeReasonCode)
                {
                    Width = 2;
                }
                textelement(DateValue)
                {
                    Width = 6;
                }
                textelement(_Description)
                {
                    Width = 31;
                }
                textelement(ReservedZone2)
                {
                    Width = 2;
                }
                textelement(_DocumentNo)
                {
                    Width = 7;
                }
                textelement(IndicationOfCommission)
                {
                    Width = 1;
                }
                textelement(IndicationOfIndisponibility)
                {
                    Width = 1;
                }
                textelement(_Amount)
                {
                    Width = 14;
                }
                textelement(ReferenceZone)
                {
                    MinOccurs = Zero;
                    Width = 16;
                }
                trigger OnBeforeInsertRecord()
                var
                    lRetour: Integer;
                begin
                    CASE _EntryCode OF
                        '01':
                            StartingBalance;
                        '04':
                            Operation;
                        '05':
                            Details;
                        '07':
                            EndingBalance;
                    END;
                end;
            }
        }
    }
    requestpage
    {
        layout
        {
        }
        actions
        {
        }
    }
    trigger OnPreXmlPort()
    begin
        GeneralLedgerSetup.Get();
        DataExch.Insert(true);
    end;

    var
        BankAccount: Record "Bank Account";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        LineNo: Integer;
        DetailLineNo: Integer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        DataExch: Record "Data Exch.";

    local procedure GetBankAccount(): Boolean
    begin
        if (_BankBranchNo = CopyStr(DelChr(BankAccount.IBAN), 10, 5)) AND (_BankAccountNo = CopyStr(DelChr(BankAccount.IBAN), 15, 11)) then
            exit;
        if BankAccount.FindSet() then
            repeat
            until (BankAccount.Next() = 0) OR (_BankBranchNo = CopyStr(DelChr(BankAccount.IBAN), 10, 5)) AND (_BankAccountNo = CopyStr(DelChr(BankAccount.IBAN), 15, 11));
        if (_BankBranchNo <> CopyStr(DelChr(BankAccount.IBAN), 10, 5)) OR (_BankAccountNo <> CopyStr(DelChr(BankAccount.IBAN), 15, 11)) then
            clear(BankAccount)
        else
            if _CurrencyCode <> GeneralLedgerSetup."LCY Code" then
                BankAccount.TestField("Currency Code", _CurrencyCode);
    end;

    local procedure StartingBalance()
    begin
        GetBankAccount;
        if (BankAccount."No." = BankAccReconciliation."Bank Account No.") or (BankAccount."No." = '') then
            exit;
        BankAccount.TestField("Balance Last Statement", ToAmount(_Amount, _NoOfDecimals));
        Clear(BankAccReconciliation);
        BankAccReconciliation."Statement Type" := BankAccReconciliation."Statement Type"::"Payment Application";
        BankAccReconciliation.Validate("Bank Account No.", BankAccount."No.");
        BankAccReconciliation.Insert(true);
    end;

    local procedure Operation()
    begin
        if BankAccount."No." = '' then
            exit;
        BankAccReconciliationLine.Init();
        BankAccReconciliationLine."Statement Type" := BankAccReconciliation."Statement Type";
        BankAccReconciliationLine."Bank Account No." := BankAccReconciliation."Bank Account No.";
        BankAccReconciliationLine."Statement No." := BankAccReconciliation."Statement No.";
        LineNo += 1;
        BankAccReconciliationLine."Statement Line No." := LineNo;
        Evaluate(BankAccReconciliationLine."Transaction Date", _OperationDate);
        BankAccReconciliationLine."Transaction Text" := _Description;
        BankAccReconciliationLine."Statement Amount" := ToAmount(_Amount, _NoOfDecimals);
        if _DocumentNo <> '0000000' then
            BankAccReconciliationLine."Check No." := _DocumentNo;
        BankAccReconciliationLine."Data Exch. Entry No." := DataExch."Entry No.";
        BankAccReconciliationLine."Data Exch. Line No." := LineNo;
        DetailLineNo := 0;
        BankAccReconciliationLine.Insert(true);
    end;

    local procedure Details()
    var
        DataExchField: Record "Data Exch. Field";
    begin
        if BankAccount."No." = '' then
            exit;
        DetailLineNo += 1;
        DataExchField.InsertRec(DataExch."Entry No.", LineNo, DetailLineNo, _Description, '');
    end;

    local procedure EndingBalance()
    begin
        if BankAccount."No." = '' then
            exit;
        Evaluate(BankAccReconciliation."Statement Date", _OperationDate);
        BankAccReconciliation."Statement Ending Balance" := ToAmount(_Amount, _NoOfDecimals);
        BankAccReconciliation.Modify(true);
    end;

    local procedure ToAmount(pTextAmount: Text;
    pNoOfDecimals: Text) ReturnValue: Decimal
    begin
        Evaluate(ReturnValue, ConvertStr(pTextAmount, '{ABCDEFGHIJKLMNOPQR}', '01234567891234567890'));
        if pTextAmount[14] in ['J' .. 'R', '}'] then
            ReturnValue *= -1;
        case _NoOfDecimals of
            '0':
                exit(ReturnValue);
            '1':
                exit(ReturnValue / 10);
            '2':
                exit(ReturnValue / 100);
            '3':
                exit(ReturnValue / 1000);
        end;
    end;
}
*/