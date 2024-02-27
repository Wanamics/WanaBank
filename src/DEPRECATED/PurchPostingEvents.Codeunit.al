#if FALSE
codeunit 87405 "wanaBank Posting Events"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", OnPostInvoiceOnBeforePostBalancingEntry, '', false, false)]
    local procedure OnPostInvoiceOnBeforePostBalancingEntry(var PurchHeader: Record "Purchase Header"; var LineCount: Integer)
    begin
        // Error if Due Date is not within allowed Posting Dates
        if PurchHeader."Due Date" > PurchHeader."Posting Date" then begin
            PurchHeader."Posting Date" := PurchHeader."Due Date"; // Do not Validate to avoid Warning could affect amount
            PurchHeader."VAT Reporting Date" := PurchHeader."Due Date";
        end;
    end;
}
#endif
