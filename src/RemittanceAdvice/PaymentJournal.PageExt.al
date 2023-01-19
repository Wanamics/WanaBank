// Copy from pageextension 4022 SendPmtJnlRemitAdvice extends "Payment Journal"
pageextension 87407 "wan Payment Journal" extends "Payment Journal"
{
    actions
    {
        addlast("&Payments")
        {
            action(wanSendRemittanceAdvice)
            {
                ApplicationArea = All;
                Caption = 'Send Remittance Advice';
                Image = SendToMultiple;
                ToolTip = 'Send the remittance advice before posting a payment journal or after posting a payment. The advice contains vendor invoice numbers, which helps vendors to perform reconciliations.';

                trigger OnAction()
                var
                    GenJournalLine: Record "Gen. Journal Line";
                begin
                    GenJournalLine := Rec;
                    CurrPage.SetSelectionFilter(GenJournalLine);
                    SendVendorRecords(GenJournalLine);
                end;
            }
        }
    }
    local procedure SendVendorRecords(var GenJournalLine: Record "Gen. Journal Line")
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        DummyReportSelections: Record "Report Selections";
        DummyReportSelectionsInteger: Integer;
    begin
        if not GenJournalLine.FindSet() then
            exit;

        DummyReportSelections.Usage := DummyReportSelections.Usage::"V.Remittance";
        DummyReportSelectionsInteger := DummyReportSelections.Usage.AsInteger();

        DocumentSendingProfile.SendVendorRecords(
            DummyReportSelectionsInteger, GenJournalLine, RemittanceAdviceTxt, GenJournalLine."Account No.", GenJournalLine."Document No.",
            GenJournalLine.FieldNo("Account No."), GenJournalLine.FieldNo("Document No."));
    end;

    var
        RemittanceAdviceTxt: Label 'Remittance Advice';
}
