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
                    VendorLedgerEntry: Record "Vendor Ledger Entry";
                begin
                    VendorLedgerEntry := Rec;
                    CurrPage.SetSelectionFilter(VendorLedgerEntry);
                    VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Payment);
                    SendVendorRecords(VendorLedgerEntry);
                end;
            }
        }
    }
    local procedure SendVendorRecords(var VendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        DummyReportSelections: Record "Report Selections";
        ReportSelectionInteger: Integer;
    begin
        if not VendorLedgerEntry.FindSet() then
            exit;

        DummyReportSelections.Usage := DummyReportSelections.Usage::"P.V.Remit.";
        ReportSelectionInteger := DummyReportSelections.Usage.AsInteger();

        DocumentSendingProfile.SendVendorRecords(
            ReportSelectionInteger, VendorLedgerEntry, RemittanceAdviceTxt, VendorLedgerEntry."Vendor No.", VendorLedgerEntry."Document No.",
            VendorLedgerEntry.FieldNo("Vendor No."), VendorLedgerEntry.FieldNo("Document No."));
    end;

    var
        RemittanceAdviceTxt: Label 'Remittance Advice';
}