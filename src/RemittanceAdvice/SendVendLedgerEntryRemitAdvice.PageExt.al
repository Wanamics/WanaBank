// Copy from Canadian localization pageextension 4023 SendVendLedgerEntryRemitAdvice extends "Vendor Ledger Entries"
pageextension 87408 "wan Vendor Ledger Entries" extends "Vendor Ledger Entries"
{
    actions
    {
        addlast("F&unctions")
        {
            action(wanSendRemittanceAdvice)
            {
                ApplicationArea = All;
                Caption = 'Send Remittance Advice';
                Image = SendToMultiple;
                ToolTip = 'Send the remittance advice before posting a payment journal or after posting a payment. The advice contains vendor invoice numbers, which helps vendors to perform reconciliations.';

                trigger OnAction()
                var
                    Selection: Record "Vendor Ledger Entry";
                begin
                    // Selection := Rec;
                    CurrPage.SetSelectionFilter(Selection);
                    Selection.SetRange("Document Type", Selection."Document Type"::Payment);
                    if not Selection.IsEmpty() then
                        SendVendorRecords(Selection);
                end;
            }
        }
    }
    local procedure SendVendorRecords(var pVendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        DummyReportSelections: Record "Report Selections";
        // ReportSelectionInteger: Integer;
        RemittanceAdviceTxt: Label 'Remittance Advice';
    begin
        /*
        if not VendorLedgerEntry.FindSet() then
            exit;
        DummyReportSelections.Usage := DummyReportSelections.Usage::"P.V.Remit.";
        ReportSelectionInteger := DummyReportSelections.Usage::"P.V.Remit.".AsInteger();

        DocumentSendingProfile.SendVendorRecords(
            ReportSelectionInteger, VendorLedgerEntry, RemittanceAdviceTxt, VendorLedgerEntry."Vendor No.", VendorLedgerEntry."Document No.",
            VendorLedgerEntry.FieldNo("Vendor No."), VendorLedgerEntry.FieldNo("Document No."));
        */
        DocumentSendingProfile.SendVendorRecords(
            DummyReportSelections.Usage::"P.V.Remit.".AsInteger(), pVendorLedgerEntry, RemittanceAdviceTxt, pVendorLedgerEntry."Vendor No.", pVendorLedgerEntry."Document No.",
            pVendorLedgerEntry.FieldNo("Vendor No."), pVendorLedgerEntry.FieldNo("Document No."));
    end;

}