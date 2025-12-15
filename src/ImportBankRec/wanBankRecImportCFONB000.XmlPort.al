xmlport 87402 "wan Bank Rec. Import CFONB000"
{
    Caption = 'Import Bank Statement (no separator)';
    Direction = Import;
    Format = FixedText;
    FormatEvaluate = Legacy;
    UseRequestPage = false;
    RecordSeparator = '<None>'; // This is the unique difference with xmlport 87401 "wan Bank Rec. Import CFONB120" 

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
                    MinOccurs = Zero;
                }
                textelement(_DocumentNo)
                {
                    Width = 7;
                    MinOccurs = Zero;
                }
                textelement(IndicationOfCommission)
                {
                    Width = 1;
                    MinOccurs = Zero;
                }
                textelement(IndicationOfIndisponibility)
                {
                    Width = 1;
                    MinOccurs = Zero;
                }
                textelement(_Amount)
                {
                    Width = 14;
                    MinOccurs = Zero;
                }
                textelement(ReferenceZone)
                {
                    Width = 16;
                    MinOccurs = Zero;
                }
                trigger OnBeforeInsertRecord()
                begin
                    case _EntryCode OF
                        '01':
                            StartingBalance;
                        '04':
                            Operation;
                        '05':
                            Details;
                        '07':
                            EndingBalance;
                    end;
                end;
            }
        }
    }
    var
        MultiCompBankAccount: Record "wan Company Bank Account";
        BankAccount: Record "Bank Account";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        LineNo: Integer;
        GeneralLedgerSetup: Record "General Ledger Setup";

    trigger OnPreXmlPort()
    begin
        MultiCompBankAccount.FillAllCompanies();
    end;

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

            GeneralLedgerSetup.ChangeCompany(MultiCompBankAccount."Company Name");
            GeneralLedgerSetup.Get();
            if _CurrencyCode <> GeneralLedgerSetup."LCY Code" then
                Clear(MultiCompBankAccount)
        end;
    end;

    local procedure StartingBalance()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccountStatement: Record "Bank Account Statement";
        DateOrBalanceDoesntMatchErr: Label '%1 %2 or %3 %4 doesn''t match last %5 ones %6 at %7 for Bank Account %8 in company %9.';
        ConfirmMsg: Label 'Do tou want to continue?';
        IsEmptyInCompanyLbl: Label 'is not defined in company %1';
    begin
        Clear(BankAccReconciliation);
        GetBankAccount;
        if (MultiCompBankAccount."No." = BankAccReconciliation."Bank Account No.") or (MultiCompBankAccount."No." = '') then
            exit;
        BankAccReconciliation.ChangeCompany(MultiCompBankAccount."Company Name");
        BankAccReconciliation.SetCurrentKey("Statement Type", "Bank Account No.", "Statement Date");
        BankAccReconciliation.SetRange("Bank Account No.", MultiCompBankAccount."No.");
        BankAccReconciliation.SetRange("Statement Type", BankAccReconciliation."Statement Type"::"Payment Application");
        if BankAccReconciliation.FindLast() then begin
            if (BankAccReconciliation."Statement Ending Balance" <> ToAmount(_Amount, _NoOfDecimals)) or
                // (BankAccReconciliation."Statement Date" <> ToDate(_OperationDate)) then
                (BankAccReconciliation."Statement Date" >= ToDate(_OperationDate)) then
                if not Confirm(DateOrBalanceDoesntMatchErr + '\' + ConfirmMsg, false,
                    BankAccReconciliation.FieldCaption("Balance Last Statement"), ToAmount(_Amount, _NoOfDecimals),
                    BankAccReconciliation.FieldCaption("Statement Date"), ToDate(_OperationDate),
                    BankAccReconciliation.TableCaption, BankAccReconciliation."Statement Ending Balance", BankAccReconciliation."Statement Date",
                    BankAccReconciliation."Bank Account No.", MultiCompBankAccount."Company Name") then
                    error('');
            BankAccReconciliationInsert(IncStr(BankAccReconciliation."Statement No."), ToDate(_OperationDate), ToAmount(_Amount, _NoOfDecimals));
        end else begin
            BankAccountStatement.ChangeCompany(MultiCompBankAccount."Company Name");
            BankAccountStatement.SetCurrentKey("Bank Account No.", "Statement Date");
            BankAccountStatement.SetRange("Bank Account No.", MultiCompBankAccount."No.");
            if BankAccountStatement.FindLast() then begin
                if (BankAccountStatement."Statement Ending Balance" <> ToAmount(_Amount, _NoOfDecimals)) or
                    // (BankAccountStatement."Statement Date" <> ToDate(_OperationDate)) then
                    (BankAccountStatement."Statement Date" >= ToDate(_OperationDate)) then
                    if not Confirm(DateOrBalanceDoesntMatchErr + '\' + ConfirmMsg, false,
                        BankAccountStatement.FieldCaption("Balance Last Statement"), ToAmount(_Amount, _NoOfDecimals),
                        BankAccountStatement.FieldCaption("Statement Date"), ToDate(_OperationDate),
                        BankAccountStatement.TableCaption, BankAccountStatement."Statement Ending Balance", BankAccountStatement."Statement Date",
                        BankAccountStatement."Bank Account No.", MultiCompBankAccount."Company Name") then
                        error('');
            end else
                if (BankAccount."Balance Last Statement" <> ToAmount(_Amount, _NoOfDecimals)) then
                    if not Confirm(DateOrBalanceDoesntMatchErr + '\' + ConfirmMsg, false,
                        BankAccount.FieldCaption("Balance Last Statement"), ToAmount(_Amount, _NoOfDecimals),
                        BankAccountStatement.FieldCaption("Statement Date"), ToDate(_OperationDate),
                        BankAccount.TableCaption, BankAccount."Balance Last Statement", 0D,
                        BankAccount."Bank Account No.", MultiCompBankAccount."Company Name") then
                        error('');
            if BankAccount."No." = '' then
                BankAccount.Get(MultiCompBankAccount."No.");
            if BankAccount."Last Statement No." = '' then
                BankAccount.FieldError("Last Statement No.", StrSubstNo(IsEmptyInCompanyLbl, MultiCompBankAccount."Company Name"));
            BankAccReconciliationInsert(IncStr(BankAccount."Last Statement No."), ToDate(_OperationDate), ToAmount(_Amount, _NoOfDecimals));
        end;
    end;

    local procedure Operation()
    begin
        if MultiCompBankAccount."No." = '' then
            exit;
        BankAccReconciliationLine.Init();
        BankAccReconciliationLine.Validate("Statement Type", BankAccReconciliation."Statement Type");
        BankAccReconciliationLine.Validate("Bank Account No.", BankAccReconciliation."Bank Account No.");
        BankAccReconciliationLine.Validate("Statement No.", BankAccReconciliation."Statement No.");
        LineNo += 1;
        BankAccReconciliationLine.Validate("Statement Line No.", LineNo);
        BankAccReconciliationLine.Validate("Transaction Date", ToDate(_OperationDate));
        BankAccReconciliationLine.Validate("Transaction Text", _Description);
        BankAccReconciliationLine.Validate("Statement Amount", ToAmount(_Amount, _NoOfDecimals));
        if _DocumentNo <> '0000000' then
            BankAccReconciliationLine.Validate("Check No.", _DocumentNo);
        BankAccReconciliationLine.Insert(false);
    end;

    local procedure Details()
    begin
        if MultiCompBankAccount."No." = '' then
            exit;
        BankAccReconciliationLine.Validate("Transaction Text", CopyStr(BankAccReconciliationLine."Transaction Text" + ' ' + _Description, 1, MaxStrLen(BankAccReconciliationLine."Transaction Text")));
        BankAccReconciliationLine.Modify();
    end;

    local procedure EndingBalance()
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        if MultiCompBankAccount."No." = '' then
            exit;
        if not BankAccReconciliationLine.LinesExist(BankAccReconciliation) then
            BankAccReconciliation.Delete()
        else begin
            Evaluate(BankAccReconciliation."Statement Date", _OperationDate);
            BankAccReconciliation."Statement Ending Balance" := ToAmount(_Amount, _NoOfDecimals);
            BankAccReconciliation.Modify(true);
        end;
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

    local procedure BankAccReconciliationInsert(pStatementNo: text; pStatementDate: Date; pBalanceLastStatement: decimal);
    begin
        BankAccReconciliation.Init();
        BankAccReconciliation."Statement Type" := BankAccReconciliation."Statement Type"::"Payment Application";
        BankAccReconciliation."Bank Account No." := MultiCompBankAccount."No.";
        BankAccReconciliation."Statement No." := pStatementNo;
        BankAccReconciliation."Statement Date" := pStatementDate;
        BankAccReconciliation."Balance Last Statement" := pBalanceLastStatement;
        BankAccReconciliation.TestField("Statement Date");
        BankAccReconciliation.Insert(false);
    end;
}
