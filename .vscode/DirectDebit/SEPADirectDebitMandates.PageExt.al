pageextension 81606 "wan SEPA Direct Debit Mandates" extends "SEPA Direct Debit Mandates"
{
    layout
    {
        /*
                addlast(Group)
                {
                    field(NoOfAttachments; NoOfAttachments)
                    {
                        Caption = 'No. of Attachments';
                        ApplicationArea = All;
                        Editable = false;
                        DrillDown = true;
                        trigger OnDrillDown()
                        var
                            DocumentAttachment: Record "Document Attachment";
                            DocumentAttachmentDetails: Page "Document Attachment Details";
                        begin
                            DocumentAttachment.SetRange("Table ID", Database::"SEPA Direct Debit Mandate");
                            DocumentAttachment.SetRange("No.", CopyStr(Rec.ID, 1, MaxStrLen(DocumentAttachment."No.")));
                            DocumentAttachmentDetails.SetTableView(DocumentAttachment);
                            DocumentAttachment."Table ID" := Database::"SEPA Direct Debit Mandate";
                            DocumentAttachment."No." := CopyStr(Rec.ID, 1, MaxStrLen(DocumentAttachment."No."));
                            DocumentAttachmentDetails.RunModal();
                            CurrPage.Update(false);
                        end;
                    }
                }
                */
        addfirst(factboxes)
        {
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(Database::"SEPA Direct Debit Mandate"), "No." = FIELD(ID);
            }
        }
    }
    actions
    {
        addlast(Processing)
        {
            action(wanPrint)
            {
                ApplicationArea = All;
                Image = PrintCheck;
                RunObject = report "wan SEPA Direct Debit Mandate";
                Caption = 'Print';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                RunPageOnRec = true;
                PromotedIsBig = true;
                Scope = Repeater;
            }
            /*
            action(wanImport)
            {
                Caption = 'Import';
                ApplicationArea = All;
                Image = Import;
                Scope = Repeater;
                trigger OnAction()
                var
                    SDDMandateAttachment : Codeunit "wan SEPA Direct Debit Events";
                begin
                    SDDMandateAttachment.Import(Rec);
                end;
            }
            action(wanExport)
            {
                Caption = 'Export';
                ApplicationArea = All;
                Image = Export;
                Scope = Repeater;
                trigger OnAction()
                var
                    SDDMandateAttachment : Codeunit "wan SEPA Direct Debit Events";
                begin
                    SDDMandateAttachment.Export(Rec);
                end;
            }
            */
        }
    }
    /*
    local procedure NoOfAttachments(): Integer
    var
        DocumentAttachment: Record "Document Attachment";
        DocumentAttachmentDetails: Page "Document Attachment Details";
    begin
        DocumentAttachment.SetRange("Table ID", Database::"SEPA Direct Debit Mandate");
        DocumentAttachment.SetRange("No.", CopyStr(Rec.ID, 1, MaxStrLen(DocumentAttachment."No.")));
        exit(DocumentAttachment.Count);
    end;
    */
}
