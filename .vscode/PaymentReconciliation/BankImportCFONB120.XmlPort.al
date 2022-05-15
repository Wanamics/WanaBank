xmlport 81601 "wanaBank Import CFONB120 Multi"
{
    // Quid s'il existe déjà un relevé pour le même compte (erreur ou compléter ?)
    // Quid si compte n'existe pas, skip ou erreur ?
    // Contrôle date début > celle du dernier relevé (ou skip si <=)
    CaptionML = ENU = 'Import Bank Statement', FRA = 'Import relevé bancaire';
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
    trigger OnPreXmlPort()
    begin
        FillCompanyBankAccountBuf();
        //GeneralLedgerSetup.Get();
        //DataExch.Insert(true);
    end;

    trigger OnPostXmlPort()
    begin
        CompanyBankAccountBuf.SetFilter("Last Payment Statement No.", '<>%1', '');
        page.RunModal(Page::"wan Company Bank Statements", CompanyBankAccountBuf);
    end;

    var
        CompanyBankAccountBuf: Record "wan Company Bank Account Buf.";
        BankAccount: Record "Bank Account";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        LineNo: Integer;
        DetailLineNo: Integer;
        GeneralLedgerSetup: Record "General Ledger Setup";
        DataExch: Record "Data Exch.";

    local procedure GetBankAccount(): Boolean
    /*
    var
        CurrencyErr : TextConst
            ENU = 'Foreign Currency not allowed',
            FRA = 'Devise étrangère non prise en charge par ce traitement'
    */
    begin
        if (_BankBranchNo = CompanyBankAccountBuf."Bank Branch No.") AND (_BankAccountNo = CompanyBankAccountBuf."Bank Account No.") then
            exit;
        if not CompanyBankAccountBuf.Get(_BankBranchNo, _BankAccountNo) then
            Clear(CompanyBankAccountBuf)
        else begin
            //if CompanyBankAccountBuf."Company Name" <> CompanyName then begin
            GeneralLedgerSetup.ChangeCompany(CompanyBankAccountBuf."Company Name");
            GeneralLedgerSetup.Get();
            BankAccount.ChangeCompany(CompanyBankAccountBuf."Company Name");
            BankAccReconciliation.ChangeCompany(CompanyBankAccountBuf."Company Name");
            BankAccReconciliationLine.ChangeCompany(CompanyBankAccountBuf."Company Name");
            DataExch.ChangeCompany(CompanyBankAccountBuf."Company Name");
            DataExch.Insert(true);
            //end;
            if _CurrencyCode <> GeneralLedgerSetup."LCY Code" then
                Clear(CompanyBankAccountBuf)
        end;
    end;

    local procedure StartingBalance()
    begin
        GetBankAccount;
        if (CompanyBankAccountBuf."No." = BankAccReconciliation."Bank Account No.") or (CompanyBankAccountBuf."No." = '') then
            exit;
        CompanyBankAccountBuf.TestField("Balance Last Statement", ToAmount(_Amount, _NoOfDecimals));
        Clear(BankAccReconciliation);
        BankAccReconciliationInsert(BankAccReconciliation."Statement Type"::"Payment Application");
    end;

    local procedure Operation()
    begin
        if CompanyBankAccountBuf."No." = '' then
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
        if CompanyBankAccountBuf."No." = '' then
            exit;
        DetailLineNo += 1;
        DataExchField.InsertRec(DataExch."Entry No.", LineNo, DetailLineNo, _Description, '');
    end;

    local procedure EndingBalance()
    begin
        if CompanyBankAccountBuf."No." = '' then
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

    local procedure FillCompanyBankAccountBuf()
    var
        Company: Record Company;
    begin
        if Company.FindSet() then
            repeat
                FillCompanyBankAccountBufForCompany(Company.Name);
            until Company.Next() = 0;
    end;

    internal procedure ThisCompanyOnly()
    begin
        FillCompanyBankAccountBufForCompany(CompanyName);
    end;

    local procedure FillCompanyBankAccountBufForCompany(pCompanyName: Text)
    var
        BankAccount: Record "Bank Account";
        IBANErr: TextConst
            ENU = 'IBAN is missing for bank account %1 of company %2',
            FRA = 'IBAN est manquant pour le compte bancaire %1 de la société %2';
        AlreadyExistsErr: TextConst
            ENU = 'Bank Account %1 of company %2 and %3 of %4 have the same %5 %6 and %7 %8',
            FRA = 'Les comptes bancaire % 1 de %2 et %3 de %4 ont les mêmes %5 %6 et %7 %8';
    begin
        BankAccount.ChangeCompany(pCompanyName);
        if BankAccount.FindSet() then
            repeat
                if BankAccount.IBAN = '' then
                    Error(IBANErr, BankAccount."No.", pCompanyName);
                CompanyBankAccountBuf.TransferFields(BankAccount);
                CompanyBankAccountBuf.IBAN := DelChr(CompanyBankAccountBuf.IBAN);
                CompanyBankAccountBuf."Company Name" := pCompanyName;
                CompanyBankAccountBuf."Bank Branch No." := CopyStr(CompanyBankAccountBuf.IBAN, 10, 5);
                CompanyBankAccountBuf."Bank Account No." := CopyStr(CompanyBankAccountBuf.IBAN, 15, 11);
                if CompanyBankAccountBuf.Get(CompanyBankAccountBuf."Bank Branch No.", CompanyBankAccountBuf."Bank Account No.") then
                    Error(AlreadyExistsErr,
                        BankAccount."No.", CompanyName,
                        CompanyBankAccountBuf."No.", CompanyBankAccountBuf."Company Name",
                        CompanyBankAccountBuf.FieldCaption("Bank Branch No."), CompanyBankAccountBuf."Bank Branch No.",
                        CompanyBankAccountBuf.FieldCaption("Bank Account No."), CompanyBankAccountBuf."Bank Account No.");
                CompanyBankAccountBuf."Last Payment Statement No." := '';
                CompanyBankAccountBuf."Last Statement No." := '';
                CompanyBankAccountBuf.Insert();
            until BankAccount.Next() = 0;
    end;

    local procedure BankAccReconciliationInsert(pStatementType: Option)
    begin
        BankAccReconciliation."Statement Type" := pStatementType;
        BankAccReconciliationValidateBankAccountNo();
        BankAccReconciliation.Insert(false);
        CompanyBankAccountBuf."Last Payment Statement No." := BankAccReconciliation."Statement No.";
        CompanyBankAccountBuf.Modify();
    end;

    local procedure BankAccReconciliationValidateBankAccountNo()
    begin
        // Copy from PerCompany "Bank Acc. Reconciliation Line" table, OnValidate("Bank Account No.")
        if BankAccReconciliation."Statement No." = '' then begin
            BankAccount.Get(CompanyBankAccountBuf."Bank Account No.");

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
