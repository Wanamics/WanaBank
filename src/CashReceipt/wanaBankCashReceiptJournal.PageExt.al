pageextension 87402 "wanaBank Cash Receipt Journal" extends "Cash Receipt Journal"
{
    layout
    {
        addafter(Description)
        {
            field(wanExternalDocumentNumber; Rec."External Document No.")
            {
                ApplicationArea = All;
            }
            field(wanAppliesToID; Rec."Applies-to ID")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        addlast(Reporting)
        {
            action(wanPrintCheckRemittanceReport)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Print Check Remittance Report';
                Image = PrintCheck;
                ToolTip = 'View a list of checks remitted to the bank. The header shows the names and addresses of the company and bank. The body shows the list of checks. The footer shows the total of the remittance and the number of checks. Typically, you give this report to your bank with the checks at remittance.';

                trigger OnAction()
                var
                    RecapitulationForm: Report "wan Recapitulation Form";
                begin
                    RecapitulationForm.SetTableView(Rec);
                    RecapitulationForm.RunModal();
                    Clear(RecapitulationForm);
                end;
            }
        }
    }
}
