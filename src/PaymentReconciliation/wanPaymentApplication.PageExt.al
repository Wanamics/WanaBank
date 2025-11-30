pageextension 87414 "wan Payment Application" extends "Payment Application"
{
    layout
    {
        modify(BankAccReconLineDescription)
        {
            Visible = false;
        }
        addafter(BankAccReconLineDescription)
        {
            field(wanBankAccReconLineDescription; BankAccReconLine."Transaction Text")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Transaction Text';
                Editable = false;
                ToolTip = 'Specifies the text that was entered on the payment when the payment was made to the electronic bank account.';
                MultiLine = true;
            }
        }
    }
}
