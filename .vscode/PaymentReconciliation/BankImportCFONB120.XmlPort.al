xmlport 81601 "wanaBank Import CFONB120 Multi"
{
    // Quid s'il existe déjà un relevé pour le même compte (erreur ou compléter ?)
    // Quid si compte n'existe pas, skip ou erreur ?
    // Contrôle date début > celle du dernier relevé (ou skip si <=)
    Caption = 'Import Bank Statement';
    Direction = Import;
    Format = FixedText;
    FormatEvaluate = Legacy;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement(Integer; Integer)
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

    var
        MultiCompBankAccount: Record "wan MultiComp. Bank Account";
        BankAccount: Record "Bank Account";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        LineNo: Integer;
        DetailLineNo: Integer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        DataExch: Record "Data Exch.";
        DataExchField: Record "Data Exch. Field";

    local procedure GetBankAccount(): Boolean
    begin
        if MultiCompBankAccount."Account No." = _BankCode + _BankBranchNo + _BankAccountNo then
            exit;
        if not MultiCompBankAccount.Get(_BankCode + _BankBranchNo + _BankAccountNo) then
            Clear(MultiCompBankAccount)
        else begin
            BankAccount.ChangeCompany(MultiCompBankAccount."Company Name");
            BankAccount.Get(MultiCompBankAccount."No.");
            BankAccReconciliation.ChangeCompany(MultiCompBankAccount."Company Name");
            BankAccReconciliationLine.ChangeCompany(MultiCompBankAccount."Company Name");
            DataExch.ChangeCompany(MultiCompBankAccount."Company Name");
            if DataExch.FindLast() then;
            DataExch."Entry No." += 1; // AutoIncrement seems to be incompatible with ChangeCompany
            DataExch.Insert(true);
            DataExchField.ChangeCompany(MultiCompBankAccount."Company Name");

            GeneralLedgerSetup.ChangeCompany(MultiCompBankAccount."Company Name");
            GeneralLedgerSetup.Get();
            if _CurrencyCode <> GeneralLedgerSetup."LCY Code" then
                Clear(MultiCompBankAccount)
        end;
    end;

    local procedure StartingBalance()
    var
        BaknAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccountStatement: Record "Bank Account Statement";
        BalanceLastStatementErr: Label '%1 for bank account %2 of company %3 must be %4';
        LastBankAccReconciliationBalanceErr: Label 'Last reconciliation %1 for bank account %2 of company %3 must be %4';
        BankStatementDateMismatchErr: Label 'do not match the starting date of new statement of company %1';
    begin
        GetBankAccount;
        if (MultiCompBankAccount."No." = BankAccReconciliation."Bank Account No.") or (MultiCompBankAccount."No." = '') then
            exit;
        BankAccReconciliation.ChangeCompany(MultiCompBankAccount."Company Name");
        BankAccReconciliation.SetRange("Bank Account No.", MultiCompBankAccount."No.");
        if BankAccReconciliation.FindLast() then begin
            if BankAccReconciliation."Balance Last Statement" <> ToAmount(_Amount, _NoOfDecimals) then
                Error(LastBankAccReconciliationBalanceErr,
                    BankAccReconciliation.FieldCaption("Balance Last Statement"),
                    BankAccReconciliation."Bank Account No.",
                    MultiCompBankAccount."Company Name",
                    ToAmount(_Amount, _NoOfDecimals));
            if BankAccReconciliation."Statement Date" <> ToDate(_OperationDate) then
                BankAccReconciliation.FieldError("Statement Date", Strsubstno(BankStatementDateMismatchErr, MultiCompBankAccount."Company Name"));
        end else begin
            if BankAccount."Balance Last Statement" <> ToAmount(_Amount, _NoOfDecimals) then
                Error(BalanceLastStatementErr,
                    BankAccount.FieldCaption("Balance Last Statement"),
                    BankAccount."No.",
                    MultiCompBankAccount."Company Name",
                    ToAmount(_Amount, _NoOfDecimals));
            BankAccountStatement.ChangeCompany(MultiCompBankAccount."Company Name");
            BankAccountStatement.SetRange("Bank Account No.", MultiCompBankAccount."No.");
            if BankAccountStatement.FindLast() and (BankAccountStatement."Statement Date" <> ToDate(_OperationDate)) then
                BankAccountStatement.FieldError("Statement Date", Strsubstno(BankStatementDateMismatchErr, MultiCompBankAccount."Company Name"));
        end;
        BankAccReconciliationInsert(BankAccReconciliation."Statement Type"::"Payment Application");
    end;

    local procedure Operation()
    begin
        if MultiCompBankAccount."No." = '' then
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
        BankAccReconciliationLine.Insert(false);
    end;

    local procedure Details()
    begin
        if MultiCompBankAccount."No." = '' then
            exit;
        DetailLineNo += 1;
        DataExchField.InsertRec(DataExch."Entry No.", LineNo, DetailLineNo, _Description, '');
    end;

    local procedure EndingBalance()
    begin
        if MultiCompBankAccount."No." = '' then
            exit;
        Evaluate(BankAccReconciliation."Statement Date", _OperationDate);
        BankAccReconciliation."Statement Ending Balance" := ToAmount(_Amount, _NoOfDecimals);
        BankAccReconciliation.Modify(true);
    end;

    local procedure ToAmount(pTextAmount: Text; pNoOfDecimals: Text) ReturnValue: Decimal
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

    local procedure ToDate(pTextDate: Text) ReturnValue: Date
    begin
        Evaluate(ReturnValue, pTextDate);
    end;

    internal procedure AllCompanies()
    var
        Company: Record Company;
    begin
        if Company.FindSet() then
            repeat
                FillMultiCompBankAccountForCompany(Company.Name);
            until Company.Next() = 0;
    end;

    internal procedure OneCompany()
    begin
        FillMultiCompBankAccountForCompany(CompanyName);
    end;

    local procedure FillMultiCompBankAccountForCompany(pCompanyName: Text)
    var
        AlreadyExistsErr: Label 'Bank Account %1 of company %2 and %3 of %4 have the same %5 %6 and %7 %8';
    begin
        BankAccount.ChangeCompany(pCompanyName);
        BankAccount.SetFilter(IBAN, '<>%1', '');
        if BankAccount.FindSet() then
            repeat
                MultiCompBankAccount.TransferFields(BankAccount);
                MultiCompBankAccount."Company Name" := pCompanyName;
                MultiCompBankAccount."Account No." := CopyStr(DelChr(BankAccount.IBAN), 5, 21);
                if MultiCompBankAccount.Get(MultiCompBankAccount."Account No.") then
                    Error(AlreadyExistsErr,
                        BankAccount."No.", CompanyName,
                        MultiCompBankAccount."No.", MultiCompBankAccount."Company Name",
                        BankAccount.FieldCaption("IBAN"), BankAccount.IBAN);
                MultiCompBankAccount.Insert();
            until BankAccount.Next() = 0;
    end;

    local procedure BankAccReconciliationInsert(pStatementType: Option)
    begin
        BankAccReconciliation.Init();
        BankAccReconciliation."Statement Type" := pStatementType;
        BankAccReconciliation."Bank Account No." := MultiCompBankAccount."No.";
        BankAccReconciliationValidateBankAccountNo();
        BankAccReconciliation.Insert(false);
    end;

    local procedure BankAccReconciliationValidateBankAccountNo()
    begin
        // Copy from PerCompany "Bank Acc. Reconciliation" table, OnValidate("Bank Account No.")
        if BankAccReconciliation."Statement No." = '' then begin
            BankAccount.Get(MultiCompBankAccount."No.");

            if BankAccReconciliation."Statement Type" = BankAccReconciliation."Statement Type"::"Payment Application" then begin
                SetLastPaymentStatementNo(BankAccount);
                BankAccReconciliation."Statement No." := IncStr(BankAccount."Last Payment Statement No.");
            end else begin
                SetLastStatementNo(BankAccount);
                BankAccReconciliation."Statement No." := IncStr(BankAccount."Last Statement No.");
            end;

            BankAccReconciliation."Balance Last Statement" := BankAccount."Balance Last Statement";
        end;
    end;


    local procedure SetLastPaymentStatementNo(var BankAccount: Record "Bank Account")
    // Copy from PerCompany "Bank Acc. Reconciliation" Table
    begin
        if BankAccount."Last Payment Statement No." = '' then begin
            BankAccReconciliation.SetRange("Bank Account No.", BankAccount."No.");
            BankAccReconciliation.SetRange("Statement Type", BankAccReconciliation."Statement Type"::"Payment Application");
            if BankAccReconciliation.FindLast() then
                BankAccount."Last Payment Statement No." := IncStr(BankAccReconciliation."Statement No.")
            else
                BankAccount."Last Payment Statement No." := '0';

            BankAccount.Modify();
        end;
    end;

    local procedure SetLastStatementNo(var BankAccount: Record "Bank Account")
    // Copy from PerCompany "Bank Acc. Reconciliation" Table
    begin
        if BankAccount."Last Statement No." = '' then begin
            BankAccount."Last Statement No." := '0';
            BankAccount.Modify();
        end;
    end;
}
