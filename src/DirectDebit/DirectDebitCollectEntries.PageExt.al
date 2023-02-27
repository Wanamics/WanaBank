pageextension 87411 "wan Direct Debit Collect. Ent." extends "Direct Debit Collect. Entries"
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
                    DirectDebitCollection: Record "Direct Debit Collection";
                    PostDirectDebitCollection: Report "wan Post Direct Debit Collect.";
                begin
                    Rec.TestField("Direct Debit Collection No.");
                    DirectDebitCollection.Get(Rec."Direct Debit Collection No.");
                    DirectDebitCollection.TestField(Status, DirectDebitCollection.Status::"File Created");
                    PostDirectDebitCollection.SetCollectionEntry(Rec."Direct Debit Collection No.");
                    PostDirectDebitCollection.SetTableView(Rec);
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
