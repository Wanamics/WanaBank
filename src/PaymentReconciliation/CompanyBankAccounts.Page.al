page 87401 "wan Companies Bank Reconcil."
{
    ApplicationArea = All;
    Caption = 'Bank Account Reconcil. per Company';
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = Company;
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Name; Rec.Name)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Name';
                    Visible = false;
                }
                field("Display Name"; Rec."Display Name")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Display Name';
                    ToolTip = 'Specifies the name to display for the company in the user interface instead of the text that is specified in the Name field.';
                }
                field("Evaluation Company"; Rec."Evaluation Company")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Evaluation Company';
                    Editable = false;
                    ToolTip = 'Specifies that the company is for trial purposes only, and that a subscription has not been purchased. ';
                    Visible = false;
                }
                field(BankReconciliationCount; BankReconciliation.Count())
                {
                    Caption = 'No. of Bank Reconciliations';
                    ApplicationArea = All;
                    BlankZero = true;
                    trigger OnDrillDown()
                    begin
                        DrillDown(BankReconciliation."Statement Type"::"Bank Reconciliation");
                    end;
                }
                field(PaymentApplicationCount; PaymentApplication.Count())
                {
                    Caption = 'No. of Payment Application';
                    ApplicationArea = All;
                    BlankZero = true;
                    trigger OnDrillDown()
                    begin
                        DrillDown(PaymentApplication."Statement Type"::"Payment Application");
                    end;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Process)
            {
                Caption = 'Process';
                Image = "Action";
                action(EditJournal)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Open';
                    Image = OpenWorksheet;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    PromotedOnly = true;
                    ShortCutKey = 'Return';

                    trigger OnAction()
                    begin
                        DrillDown(PaymentApplication."Statement Type"::"Payment Application")
                    end;
                }
            }
            action(ImportCFONB120)
            {
                ApplicationArea = All;
                Image = Import;
                Promoted = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Caption = 'Import CFONB120';
                trigger OnAction()
                begin
                    //codeunit.Run(codeunit::"wan Bank Rec. Import CFONB120");
                    Xmlport.Run(Xmlport::"wan Bank Rec. Import CFONB120");
                    CurrPage.Update(false);
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin

    end;

    trigger OnAfterGetRecord()
    begin
        if Rec."Display Name" = '' then
            Rec."Display Name" := Rec.Name;
        BankReconciliation.ChangeCompany(Rec.Name);
        BankReconciliation.FilterGroup(2);
        BankReconciliation.SetRange("Statement Type", BankReconciliation."Statement Type"::"Bank Reconciliation");
        BankReconciliation.FilterGroup(0);
        PaymentApplication.ChangeCompany(Rec.Name);
        PaymentApplication.FilterGroup(2);
        PaymentApplication.SetRange("Statement Type", BankReconciliation."Statement Type"::"Payment Application");
        PaymentApplication.FilterGroup(0);
    end;

    var
        BankReconciliation, PaymentApplication : Record "Bank Acc. Reconciliation";

    local procedure DrillDown(pStatementType: Integer)
    var
        PageID: Integer;
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
    begin
        case pStatementType of
            BankReconciliation."Statement Type"::"Bank Reconciliation":
                PageID := Page::"Bank Acc. Reconciliation List";
            PaymentApplication."Statement Type"::"Payment Application":
                PageID := Page::"Pmt. Reconciliation Journals";
        end;
        if Rec."Name" = CompanyName then
            Page.RunModal(PageID)
        else
            Hyperlink(GetUrl(ClientType::Current, Rec."Name", ObjectType::Page, PageID));
    end;
}