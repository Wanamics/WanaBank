report 81600 "wanaBank Account Reconcil."
{
    DefaultLayout = RDLC;
    RDLCLayout = './BankAccountReconciliation.rdl';
    ApplicationArea = All;
    CaptionML = ENU = 'Bank Account Reconciliation', FRA = 'Rapprochement bancaire';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(BankAccount; "Bank Account")
        {
            DataItemTableView = SORTING("Bank Acc. Posting Group");
            RequestFilterFields = "No.";

            column(ReportCaption; RequestOptionsPage.Caption())
            {
            }
            column(CompanyName; CompanyProperty.DisplayName())
            {
            }
            column(tPage; tPage)
            {
            }
            column(ReportID; CurrReport.ObjectId(false))
            {
            }
            column(PostingDate; Format(PostingDate, 0, 0))
            {
            }
            column(tPostingDate; tPostingDate)
            {
            }
            column(tAccountBalance; tAccountBalance)
            {
            }
            column(tSumOpenEntries; tSumOpenEntries)
            {
            }
            column(tBankBalance; tBankBalance)
            {
            }
            column(StatementDateFieldCaption; BankAccountStatement.FieldCaption("Statement Date"))
            {
            }
            column(BankAccPostingGroup; "Bank Acc. Posting Group")
            {
                IncludeCaption = true;
            }
            column(GLAccountNo; GLAccount."No.")
            {
            }
            column(GLAccountName; GLAccount.Name)
            {
            }
            column(BankAccountNo; "No.")
            {
                IncludeCaption = true;
            }
            column(BankAccountName; Name)
            {
                IncludeCaption = true;
            }
            column(BankAccountIBAN; IBAN)
            {
                IncludeCaption = true;
            }
            column(BankBalanceAtDate; "Balance at Date")
            {
                IncludeCaption = true;
            }
            column(TotalBankBalanceAtDate; TotalBalanceAtDate_BankAccPosting)
            {
            }
            dataitem(BankAccountLedgerEntry; "Bank Account Ledger Entry")
            {
                DataItemLink = "Bank Account No." = field("No.");
                DataItemTableView = sorting("Bank Account No.", "Posting Date");

                column(OpenTransactionDate; "Posting Date")
                {
                    IncludeCaption = true;
                }
                column(OpenDocumentType; "Document Type")
                {
                    IncludeCaption = true;
                }
                column(OpenDocumentNo; "Document No.")
                {
                    IncludeCaption = true;
                }
                column(OpenDescription; Description)
                {
                    IncludeCaption = true;
                }
                column(OpenStatementAmount; Amount)
                {
                    IncludeCaption = true;
                }
                column(OpenExternalDocumentNo; "External Document No.")
                {
                    IncludeCaption = true;
                }
                column(OpenStatementNo; "Statement No.")
                {
                    IncludeCaption = true;
                }
                column(OpenStatementDate; BankAccountStatement."Statement Date")
                {
                }
                trigger OnAfterGetRecord()
                begin
                    if Open then
                        BankAccountStatement."Statement Date" := 0D
                    else
                        Open := BankAccountStatement.Get("Bank Account No.", "Statement No.") and (BankAccountStatement."Statement Date" > PostingDate);
                    if not Open then CurrReport.Skip;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Posting Date", 0D, PostingDate);
                end;
            }
            trigger OnAfterGetRecord()
            var
                BankAccountPostingGroup: Record "Bank Account Posting Group";
            begin
                CalcFields("Balance at Date");
                BankAccountPostingGroup.GET("Bank Acc. Posting Group");
                GLAccount.GET(BankAccountPostingGroup."G/L Account No.");
                if CurrBankAccountPosting <> "Bank Acc. Posting Group" then begin
                    CurrBankAccountPosting := "Bank Acc. Posting Group";
                    TotalBalanceAtDate_BankAccPosting := 0;
                end;
                TotalBalanceAtDate_BankAccPosting += "Balance at Date"
            end;

            trigger OnPreDataItem()
            begin
                SetRange("Date Filter", 0D, PostingDate);
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
                field(PostingDate; PostingDate)
                {
                    ApplicationArea = All;
                    CaptionML = ENU = 'Reconciliation Date', FRA = 'Date rapprochement';
                }
            }
        }
        actions
        {
        }
    }
    labels
    {
        TotalCaption = 'Total';
    }
    var
        PostingDate: Date;
        tPage: TextConst ENU = 'Page', FRA = 'Page';
        GLAccount: Record "G/L Account";
        BankAccountStatement: Record "Bank Account Statement";
        tPostingDate: TextConst ENU = 'Reconciliation Date', FRA = 'Date rapprochement';
        tAccountBalance: TextConst ENU = 'Account Balance', FRA = 'Solde comptable';
        tSumOpenEntries: TextConst ENU = 'Open Entries Sum', FRA = 'Total non rapproché';
        tBankBalance: TextConst ENU = 'Bank Balance', FRA = 'Solde bancaire';
        TotalBalanceAtDate_BankAccPosting: Decimal;
        CurrBankAccountPosting: Code[20];
}
