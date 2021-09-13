report 81600 "wanaBank Account Reconcil."
{
    // //PMT.RECONCILE
    DefaultLayout = RDLC;
    RDLCLayout = './BankAccountReconciliation.rdl';
    ApplicationArea = All;
    CaptionML = ENU='Bank Account Reconciliation', FRA='Rapprochement bancaire';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(DataItem800410000;270)
        {
            DataItemTableView = SORTING("Bank Acc. Posting Group");
            RequestFilterFields = "No.";

            column(ReportCaption;RequestOptionsPage.CAPTION)
            {
            }
            column(CompanyName;COMPANYPROPERTY.DISPLAYNAME)
            {
            }
            column(tPage;tPage)
            {
            }
            column(ReportID;CurrReport.OBJECTID(FALSE))
            {
            }
            column(PostingDate;FORMAT(PostingDate, 0, 0))
            {
            }
            column(tPostingDate;tPostingDate)
            {
            }
            column(tAccountBalance;tAccountBalance)
            {
            }
            column(tSumOpenEntries;tSumOpenEntries)
            {
            }
            column(tBankBalance;tBankBalance)
            {
            }
            column(StatementDateFieldCaption;BankAccountStatement.FIELDCAPTION("Statement Date"))
            {
            }
            column(BankAccPostingGroup;"Bank Acc. Posting Group")
            {
            IncludeCaption = true;
            }
            column(GLAccountNo;GLAccount."No.")
            {
            }
            column(GLAccountName;GLAccount.Name)
            {
            }
            column(BankAccountNo;"No.")
            {
            IncludeCaption = true;
            }
            column(BankAccountName;Name)
            {
            IncludeCaption = true;
            }
            column(BankAccountIBAN;IBAN)
            {
            IncludeCaption = true;
            }
            column(BankBalanceAtDate;"Balance at Date")
            {
            IncludeCaption = true;
            }
            column(TotalBankBalanceAtDate;TotalBalanceAtDate_BankAccPosting)
            {
            }
            dataitem(DataItem800410001;271)
            {
                DataItemLink = "Bank Account No."=FIELD("No.");
                DataItemTableView = SORTING("Bank Account No.", "Posting Date");

                column(OpenTransactionDate;"Posting Date")
                {
                IncludeCaption = true;
                }
                column(OpenDocumentType;"Document Type")
                {
                IncludeCaption = true;
                }
                column(OpenDocumentNo;"Document No.")
                {
                IncludeCaption = true;
                }
                column(OpenDescription;Description)
                {
                IncludeCaption = true;
                }
                column(OpenStatementAmount;Amount)
                {
                IncludeCaption = true;
                }
                column(OpenExternalDocumentNo;"External Document No.")
                {
                IncludeCaption = true;
                }
                column(OpenStatementNo;"Statement No.")
                {
                IncludeCaption = true;
                }
                column(OpenStatementDate;BankAccountStatement."Statement Date")
                {
                }
                trigger OnAfterGetRecord()begin
                    IF Open THEN BankAccountStatement."Statement Date":=0D
                    ELSE
                        Open:=BankAccountStatement.GET("Bank Account No.", "Statement No.") AND (BankAccountStatement."Statement Date" > PostingDate);
                    IF NOT Open THEN CurrReport.SKIP;
                end;
                trigger OnPreDataItem()begin
                    SETRANGE("Posting Date", 0D, PostingDate);
                end;
            }
            trigger OnAfterGetRecord()var lBankAccountPostingGroup: Record 277;
            begin
                CALCFIELDS("Balance at Date");
                lBankAccountPostingGroup.GET("Bank Acc. Posting Group");
                GLAccount.GET(lBankAccountPostingGroup."G/L Account No.");
                IF CurrBankAccountPosting <> "Bank Acc. Posting Group" THEN BEGIN
                    CurrBankAccountPosting:="Bank Acc. Posting Group";
                    TotalBalanceAtDate_BankAccPosting:=0;
                END;
                TotalBalanceAtDate_BankAccPosting+="Balance at Date" end;
            trigger OnPreDataItem()begin
                SETRANGE("Date Filter", 0D, PostingDate);
            end;
        }
    }
    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                field(PostingDate;PostingDate)
                {
                    ApplicationArea = One;
                    Caption = 'Posting Date';
                }
            }
        }
        actions
        {
        }
    }
    labels
    {
    TotalCaption='Total';
    }
    var PostingDate: Date;
    tPage: Label 'Page';
    GLAccount: Record 15;
    BankAccountStatement: Record 275;
    tPostingDate: Label 'Posting Date';
    tAccountBalance: Label 'Account Balance';
    tSumOpenEntries: Label 'Open Entries Sum';
    tBankBalance: Label 'Bank Balance';
    TotalBalanceAtDate_BankAccPosting: Decimal;
    CurrBankAccountPosting: Code[20];
}
