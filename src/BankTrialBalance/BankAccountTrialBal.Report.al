report 87401 "wanaBank Account - Trial Bal."
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/BankTrialBalance/BankAccountTrialBalance.rdl';
    ApplicationArea = Basic, Suite;
    Caption = 'Bank Account - Trial Balance';
    PreviewMode = PrintLayout;
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Bank Account"; "Bank Account")
        {
            DataItemTableView = SORTING("Bank Acc. Posting Group");
            RequestFilterFields = "No.", "Date Filter", "Bank Acc. Posting Group";

            column(CompanyName; COMPANYPROPERTY.DISPLAYNAME)
            {
            }
            column(PeriodFilter; STRSUBSTNO(Text003, PeriodFilter))
            {
            }
            column(CustFieldCaptPostingGroup; STRSUBSTNO(Text005, FIELDCAPTION("Bank Acc. Posting Group")))
            {
            }
            column(CustTableCaptioncustFilter; TABLECAPTION + ': ' + CustFilter)
            {
            }
            column(CustFilter; CustFilter)
            {
            }
            column(EmptyString; '')
            {
            }
            column(PeriodStartDate; FORMAT(PeriodStartDate))
            {
            }
            column(PeriodFilter1; PeriodFilter)
            {
            }
            column(FiscalYearStartDate; FORMAT(FiscalYearStartDate))
            {
            }
            column(FiscalYearFilter; FiscalYearFilter)
            {
            }
            column(PeriodEndDate; FORMAT(PeriodEndDate))
            {
            }
            column(PostingGroup_BankAccount; "Bank Acc. Posting Group")
            {
            }
            column(YTDTotal; YTDTotal)
            {
                AutoFormatType = 1;
            }
            column(YTDCreditAmt; YTDCreditAmt)
            {
                AutoFormatType = 1;
            }
            column(YTDDebitAmt; YTDDebitAmt)
            {
                AutoFormatType = 1;
            }
            column(YTDBeginBalance; YTDBeginBalance)
            {
            }
            column(PeriodCreditAmt; PeriodCreditAmt)
            {
            }
            column(PeriodDebitAmt; PeriodDebitAmt)
            {
            }
            column(PeriodBeginBalance; PeriodBeginBalance)
            {
            }
            column(Name_BankAccount; Name)
            {
                IncludeCaption = true;
            }
            column(No_BankAccount; "No.")
            {
                IncludeCaption = true;
            }
            column(TotalPostGroup_BankAccount; Text004 + FORMAT(' ') + "Bank Acc. Posting Group")
            {
            }
            column(CustTrialBalanceCaption; CustTrialBalanceCaptionLbl)
            {
            }
            column(CurrReportPageNoCaption; CurrReportPageNoCaptionLbl)
            {
            }
            column(AmtsinLCYCaption; AmtsinLCYCaptionLbl)
            {
            }
            column(inclcustentriesinperiodCaption; inclcustentriesinperiodCaptionLbl)
            {
            }
            column(YTDTotalCaption; YTDTotalCaptionLbl)
            {
            }
            column(PeriodCaption; PeriodCaptionLbl)
            {
            }
            column(FiscalYearToDateCaption; FiscalYearToDateCaptionLbl)
            {
            }
            column(NetChangeCaption; NetChangeCaptionLbl)
            {
            }
            column(TotalinLCYCaption; TotalinLCYCaptionLbl)
            {
            }
            trigger OnAfterGetRecord()
            begin
                CalcAmounts(PeriodStartDate, PeriodEndDate, PeriodBeginBalance, PeriodDebitAmt, PeriodCreditAmt, YTDTotal);
                CalcAmounts(FiscalYearStartDate, PeriodEndDate, YTDBeginBalance, YTDDebitAmt, YTDCreditAmt, YTDTotal);
            end;

            trigger OnPreDataItem()
            begin
                // CurrReport.CREATETOTALS deprecated
                //CurrReport.CREATETOTALS(
                //  PeriodBeginBalance, PeriodDebitAmt, PeriodCreditAmt, YTDBeginBalance,
                //  YTDDebitAmt, YTDCreditAmt, YTDTotal);
            end;
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
    labels
    {
        PeriodBeginBalanceCaption = 'Beginning Balance';
        PeriodDebitAmtCaption = 'Debit';
        PeriodCreditAmtCaption = 'Credit';
    }
    trigger OnPreReport()
    begin
        PeriodFilter := "Bank Account".GETFILTER("Date Filter");
        PeriodStartDate := "Bank Account".GETRANGEMIN("Date Filter");
        PeriodEndDate := "Bank Account".GETRANGEMAX("Date Filter");
        "Bank Account".SETRANGE("Date Filter");
        CustFilter := "Bank Account".GETFILTERS;
        "Bank Account".SETRANGE("Date Filter", PeriodStartDate, PeriodEndDate);
        AccountingPeriod.SETRANGE("Starting Date", 0D, PeriodEndDate);
        AccountingPeriod.SETRANGE("New Fiscal Year", TRUE);
        IF AccountingPeriod.FINDLAST THEN
            FiscalYearStartDate := AccountingPeriod."Starting Date"
        ELSE
            ERROR(Text000, AccountingPeriod.FIELDCAPTION("Starting Date"), AccountingPeriod.TABLECAPTION);
        FiscalYearFilter := FORMAT(FiscalYearStartDate) + '..' + FORMAT(PeriodEndDate);
    end;

    var
        Text000: Label 'It was not possible to find a %1 in %2.';
        AccountingPeriod: Record 50;
        PeriodBeginBalance: Decimal;
        PeriodDebitAmt: Decimal;
        PeriodCreditAmt: Decimal;
        YTDBeginBalance: Decimal;
        YTDDebitAmt: Decimal;
        YTDCreditAmt: Decimal;
        YTDTotal: Decimal;
        PeriodFilter: Text;
        FiscalYearFilter: Text;
        CustFilter: Text;
        PeriodStartDate: Date;
        PeriodEndDate: Date;
        FiscalYearStartDate: Date;
        Text003: Label 'Period: %1';
        Text004: Label 'Total for';
        Text005: Label 'Group Totals: %1';
        CustTrialBalanceCaptionLbl: Label 'Bank Account - Trial Balance';
        CurrReportPageNoCaptionLbl: Label 'Page';
        AmtsinLCYCaptionLbl: Label 'Amounts in LCY';
        inclcustentriesinperiodCaptionLbl: Label 'Only includes bank accounts with entries in the period';
        YTDTotalCaptionLbl: Label 'Ending Balance';
        PeriodCaptionLbl: Label 'Period';
        FiscalYearToDateCaptionLbl: Label 'Fiscal Year-To-Date';
        NetChangeCaptionLbl: Label 'Net Change';
        TotalinLCYCaptionLbl: Label 'Total in LCY';

    local procedure CalcAmounts(DateFrom: Date;
    DateTo: Date;
    var BeginBalance: Decimal;
    var DebitAmt: Decimal;
    var CreditAmt: Decimal;
    var TotalBalance: Decimal)
    var
        BankAccountCopy: Record 270;
    begin
        BankAccountCopy.COPY("Bank Account");
        BankAccountCopy.SETRANGE("Date Filter", 0D, DateFrom - 1);
        BankAccountCopy.CALCFIELDS("Net Change (LCY)");
        BeginBalance := BankAccountCopy."Net Change (LCY)";
        BankAccountCopy.SETRANGE("Date Filter", DateFrom, DateTo);
        BankAccountCopy.CALCFIELDS("Debit Amount (LCY)", "Credit Amount (LCY)");
        DebitAmt := BankAccountCopy."Debit Amount (LCY)";
        CreditAmt := BankAccountCopy."Credit Amount (LCY)";
        TotalBalance := BeginBalance + DebitAmt - CreditAmt;
    end;
}
