pageextension 87412 "wan Direct Debit Collections" extends "Direct Debit Collections"
{
    actions
    {
        modify(Post)
        {
            Visible = false;
        }
        addafter(Post)
        {
            action(wanPostBankSum)
            {
                ApplicationArea = Suite;
                Caption = 'Post Payment Receipts Sum';
                Ellipsis = true;
                Image = ReceivablesPayables;
                ToolTip = 'Post receipts of a payment for sales invoices. You can do this after the direct-debit collection is successfully processed by the bank.';

                trigger OnAction()
                var
                    PostDirectDebitCollection: Report "wan Post Direct Debit Collect.";
                begin
                    Rec.TestField(Status, Rec.Status::"File Created");
                    PostDirectDebitCollection.SetCollectionEntry(Rec."No.");
                    PostDirectDebitCollection.Run();
                end;
            }
        }
        modify(Post_Promoted)
        {
            Visible = false;
        }
        addafter(Post_Promoted)
        {
            actionref(wanPostBankSum_Promoted; wanPostBankSum)
            {
            }
        }
    }
}
