pageextension 87410 "wan Payment Methods" extends "Payment Methods"
{
    layout
    {
        addafter("Direct Debit Pmt. Terms Code")
        {
            field("wan Direct Debit Installments"; Rec."wan Direct Debit Installments")
            {
                ApplicationArea = All;
                Caption = 'Direct Debit Installments';
                ToolTip = 'Specifies the value of the Direct Debit Installments field.';
                trigger OnDrillDown()
                begin
                    wanDirectDebitInstallments();
                end;
            }
        }
    }
    actions
    {
        addlast(Navigation)
        {
            action(wanDirectDebitInstallments)
            {
                ApplicationArea = All;
                Caption = 'Direct Debit Installments';
                Image = Installments;
                RunObject = page "wan Direct Debit Installments";
                RunPageLink = "Payment method Code" = field(Code);
                trigger OnAction()
                var
                    DirectDebitInstallment: Record "wan Direct Debit Installment";
                begin
                    wanDirectDebitInstallments();
                end;
            }
        }
        addlast(Promoted)
        {
            actionref(wanDirectDebitInstallmentsRef; wanDirectDebitInstallments) { }
        }
    }
    local procedure wanDirectDebitInstallments()
    var
        DirectDebitInstallment: Record "wan Direct Debit Installment";
    begin
        Rec.TestField("Direct Debit", true);
        DirectDebitInstallment.SetRange("Payment Method Code", Rec.Code);
        Page.RunModal(Page::"wan Direct Debit Installments", DirectDebitInstallment);
        CurrPage.Update(false);
    end;
}
