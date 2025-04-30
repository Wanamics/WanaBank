pageextension 87411 "wan Direct Debit Collect. Ent." extends "Direct Debit Collect. Entries"
{
    actions
    {
        addlast(processing)
        {
            action(wanDDTransferDate)
            {
                ApplicationArea = Suite;
                Caption = 'Set Transfer Date';
                Ellipsis = true;
                Image = UpdateDescription;
                ToolTip = 'You can set a unique Transfer Date for all collection entries.';
                trigger OnAction()
                begin
                    Report.RunModal(Report::"WanaBank DD Set Transfer Date", true, false, Rec);
                    CurrPage.Update(false);
                end;
            }
            action(wanDDMandateID)
            {
                ApplicationArea = Suite;
                Caption = 'Set Default Mandate ID';
                Ellipsis = true;
                Image = UpdateDescription;
                ToolTip = 'You can set missing Mandate ID from the unique client''s one.';
                trigger OnAction()
                var
                    Selection: Record "Direct Debit Collection Entry";
                    ConfirmMsg: Label 'Do you want to set missing Mandate ID from the unique client''s one, for %1 line(s)?';
                begin
                    CurrPage.SetSelectionFilter(Selection);
                    Selection.SetRange("Mandate ID", '');
                    if Confirm(ConfirmMsg, false, Selection.Count) then
                        Codeunit.Run(Codeunit::"WanaBank DD Set Mandate ID", Selection);
                    // CurrPage.Update(false);
                end;
            }
        }
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
