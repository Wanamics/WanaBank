xmlport 81600 "wanaBank Import CFONB120"
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
            tableelement(Table2000000026; 2000000026)
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
        GeneralLedgerSetup.GET;
        DataExch.INSERT(TRUE);
    end;

    var
        BankAccount: Record 270;
        BankAccReconciliation: Record 273;
        BankAccReconciliationLine: Record 274;
        LineNo: Integer;
        DetailLineNo: Integer;
        GeneralLedgerSetup: Record 98;
        DataExch: Record 1220;

    local procedure GetBankAccount(): Boolean
    begin
        IF (_BankBranchNo = COPYSTR(DELCHR(BankAccount.IBAN), 10, 5)) AND (_BankAccountNo = COPYSTR(DELCHR(BankAccount.IBAN), 15, 11)) THEN
            EXIT;
        IF BankAccount.FINDSET THEN
            REPEAT
            UNTIL (BankAccount.NEXT = 0) OR (_BankBranchNo = COPYSTR(DELCHR(BankAccount.IBAN), 10, 5)) AND (_BankAccountNo = COPYSTR(DELCHR(BankAccount.IBAN), 15, 11));
        if (_BankBranchNo <> COPYSTR(DELCHR(BankAccount.IBAN), 10, 5)) OR (_BankAccountNo <> COPYSTR(DELCHR(BankAccount.IBAN), 15, 11)) THEN
            clear(BankAccount)
        else
            IF _CurrencyCode <> GeneralLedgerSetup."LCY Code" THEN
                BankAccount.TESTFIELD("Currency Code", _CurrencyCode);
    end;

    local procedure StartingBalance()
    begin
        GetBankAccount;
        IF (BankAccount."No." = BankAccReconciliation."Bank Account No.") or (BankAccount."No." = '') THEN
            EXIT;
        BankAccount.TESTFIELD("Balance Last Statement", ToAmount(_Amount, _NoOfDecimals));
        CLEAR(BankAccReconciliation);
        BankAccReconciliation."Statement Type" := BankAccReconciliation."Statement Type"::"Payment Application";
        BankAccReconciliation.VALIDATE("Bank Account No.", BankAccount."No.");
        BankAccReconciliation.INSERT(TRUE);
    end;

    local procedure Operation()
    begin
        IF BankAccount."No." = '' THEN
            EXIT;
        BankAccReconciliationLine.INIT;
        BankAccReconciliationLine."Statement Type" := BankAccReconciliation."Statement Type";
        BankAccReconciliationLine."Bank Account No." := BankAccReconciliation."Bank Account No.";
        BankAccReconciliationLine."Statement No." := BankAccReconciliation."Statement No.";
        LineNo += 1;
        BankAccReconciliationLine."Statement Line No." := LineNo;
        EVALUATE(BankAccReconciliationLine."Transaction Date", _OperationDate);
        BankAccReconciliationLine."Transaction Text" := _Description;
        BankAccReconciliationLine."Statement Amount" := ToAmount(_Amount, _NoOfDecimals);

        IF _DocumentNo <> '0000000' THEN
            BankAccReconciliationLine."Check No." := _DocumentNo;
        BankAccReconciliationLine."Data Exch. Entry No." := DataExch."Entry No.";
        BankAccReconciliationLine."Data Exch. Line No." := LineNo;
        DetailLineNo := 0;
        BankAccReconciliationLine.INSERT(TRUE);
    end;

    local procedure Details()
    var
        DataExchField: Record 1221;
    begin
        IF BankAccount."No." = '' THEN
            EXIT;
        DetailLineNo += 1;
        DataExchField.InsertRec(DataExch."Entry No.", LineNo, DetailLineNo, _Description, '');
    end;

    local procedure EndingBalance()
    begin
        IF BankAccount."No." = '' THEN
            EXIT;
        EVALUATE(BankAccReconciliation."Statement Date", _OperationDate);
        BankAccReconciliation."Statement Ending Balance" := ToAmount(_Amount, _NoOfDecimals);
        BankAccReconciliation.MODIFY(TRUE);
    end;

    local procedure ToAmount(pTextAmount: Text; pNoOfDecimals: Text) ReturnValue: Decimal
    begin
        EVALUATE(ReturnValue, CONVERTSTR(pTextAmount, '{ABCDEFGHIJKLMNOPQR}', '01234567891234567890'));
        IF pTextAmount[14] IN ['J' .. 'R', '}'] THEN
            ReturnValue *= -1;
        CASE _NoOfDecimals OF
            '0':
                EXIT(ReturnValue);
            '1':
                EXIT(ReturnValue / 10);
            '2':
                EXIT(ReturnValue / 100);
            '3':
                EXIT(ReturnValue / 1000);
        END;
    end;
}

