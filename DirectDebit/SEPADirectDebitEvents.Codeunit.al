codeunit 81602 "wan SEPA Direct Debit Events"
{
    [EventSubscriber(ObjectType::Table, Database::"Document Attachment", 'OnAfterInitFieldsFromRecRef', '', false, false)]
    local procedure OnAfterInitFieldsFromRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        if RecRef.Number = Database::"SEPA Direct Debit Mandate" then begin
            FieldRef := RecRef.Field(1);
            RecNo := FieldRef.Value;
            DocumentAttachment.Validate("No.", RecNo);
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Factbox", 'OnBeforeDrillDown', '', false, false)]
    local procedure OnBeforeDrillDown(DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef)
    var
        SDDMandate: Record "SEPA Direct Debit Mandate";
    begin
        if DocumentAttachment."Table ID" = Database::"SEPA Direct Debit Mandate" then begin
            RecRef.Open(Database::"SEPA Direct Debit Mandate");
            if SDDMandate.Get(DocumentAttachment."No.") then
                RecRef.GetTable(SDDMandate);
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Document Attachment Details", 'OnAfterOpenForRecRef', '', false, false)]
    local procedure OnAfterOpenForRecRef(var DocumentAttachment: Record "Document Attachment"; var RecRef: RecordRef; var FlowFieldsEditable: Boolean)
    var
        FieldRef: FieldRef;
        RecNo: Code[20];
    begin
        if RecRef.Number = Database::"SEPA Direct Debit Mandate" then begin
            FieldRef := RecRef.Field(1);
            RecNo := FieldRef.Value;
            DocumentAttachment.SetRange("No.", RecNo);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"SEPA Direct Debit Mandate", 'OnBeforeRenameEvent', '', false, false)]
    local procedure OnBeforeRenameSDDMandate(var Rec: Record "SEPA Direct Debit Mandate"; var xRec: Record "SEPA Direct Debit Mandate"; RunTrigger: Boolean)
    begin
        Rec.TestField(Closed, false);
        Rec.TestField("Debit Counter", 0);
    end;

    [EventSubscriber(ObjectType::Table, Database::"SEPA Direct Debit Mandate", 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterRenameSDDMandate(var Rec: Record "SEPA Direct Debit Mandate"; var xRec: Record "SEPA Direct Debit Mandate"; RunTrigger: Boolean)
    var
        xDocAtt, DocAtt : Record "Document Attachment";
    begin
        xDocAtt.SetRange("Table ID", Database::"SEPA Direct Debit Mandate");
        xDocAtt.SetRange("No.", xRec.Id);
        if xDocAtt.FindSet(true, true) then
            repeat
                DocAtt.Copy(xDocAtt);
                DocAtt.Rename(Database::"SEPA Direct Debit Mandate", Rec.ID, xDocAtt."Document Type", xDocAtt."Line No.", xDocAtt.ID);
            until xDocAtt.Next() = 0;
    end;
}
