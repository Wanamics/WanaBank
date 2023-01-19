codeunit 87404 "wan SEPA CT Events"
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SEPA CT-Fill Export Buffer", 'OnFillExportBufferOnBeforeInsertPaymentExportData', '', false, false)]
    local procedure OnFillExportBufferOnBeforeInsertPaymentExportData(var PaymentExportData: Record "Payment Export Data"; var TempGenJnlLine: Record "Gen. Journal Line" temporary)
    var
        Vendor: Record Vendor;
        Customer: Record Customer;
    begin
        case TempGenJnlLine."Account Type" of
            TempGenJnlLine."Account Type"::Vendor:
                if Vendor.Get(TempGenJnlLine."Account No.") and (Vendor."IC Partner Code" <> '') then
                    PaymentExportData.Validate("SEPA Charge Bearer", PaymentExportData."SEPA Charge Bearer"::SHAR);
            TempGenJnlLine."Account Type"::Customer:
                if Customer.Get(TempGenJnlLine."Account No.") and (Customer."IC Partner Code" <> '') then
                    PaymentExportData.Validate("SEPA Charge Bearer", PaymentExportData."SEPA Charge Bearer"::SHAR);
        end;
    end;
}
