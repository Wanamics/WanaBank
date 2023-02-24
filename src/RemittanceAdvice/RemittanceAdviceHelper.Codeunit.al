codeunit 87403 "wan Remittance Advice Helper"
{
    procedure GetCompanyInfo(var pCompanyInfo: Record "Company Information"; var pCompanyAddress: Text; var pCompanyContactInfo: Text; var pCompanyLegalInfo: Text)
    var
        Addr: array[8] of Text[100];
        FormatAddress: Codeunit "Format Address";
    begin
        pCompanyInfo.Get();
        pCompanyInfo.CalcFields(Picture);
        FormatAddress.Company(Addr, pCompanyInfo);
        pCompanyAddress := FullAddress(Addr);

        if pCompanyInfo."Phone No." <> '' then
            pCompanyContactInfo += pCompanyInfo."Phone No.";
        if pCompanyInfo."E-Mail" <> '' then
            pCompanyContactInfo += LineFeed() + pCompanyInfo."E-Mail";
        if pCompanyInfo."Home Page" <> '' then
            pCompanyContactInfo += LineFeed() + pCompanyInfo."Home Page";

        //if (pCompanyInfo."Legal Form" <> '') or (pCompanyInfo."Stock Capital" <> '') then
        //    pCompanyLegalInfo += pCompanyInfo."Legal Form" + ', ' + pCompanyInfo.FieldCaption("Stock Capital") + ' ' + pCompanyInfo."Stock Capital";
        if (pCompanyInfo."Registration No." <> '') then
            pCompanyLegalInfo += LineFeed() + pCompanyInfo.FieldCaption("Registration No.") + ' ' + pCompanyInfo."Registration No.";
        //if pCompanyInfo."APE Code" <> '' then
        //    pCompanyLegalInfo += LineFeed() + pCompanyInfo.FieldCaption("APE Code") + ' ' + pCompanyInfo."APE Code";
        //if pCompanyInfo."Trade Register" <> '' then
        //    pCompanyLegalInfo += LineFeed() + pCompanyInfo.FieldCaption("Trade Register") + ' ' + pCompanyInfo."Trade Register";
        if pCompanyInfo."VAT Registration No." <> '' then
            pCompanyLegalInfo += LineFeed() + pCompanyInfo.FieldCaption("VAT Registration No.") + ' ' + pCompanyInfo."VAT Registration No.";
    end;

    local procedure FullAddress(pAddr: array[8] of Text[100]) ReturnValue: Text;
    var
        i: Integer;
        LastOne: Integer;
    begin
        LastOne := 8;
        while (pAddr[LastOne] = '') and (LastOne > 1) do
            LastOne -= 1;
        ReturnValue := pAddr[1];
        for i := 2 to LastOne do
            ReturnValue += LineFeed() + pAddr[i];
    end;

    local procedure LineFeed() ReturnValue: Text[2];
    begin
        ReturnValue[1] := 13;
        ReturnValue[2] := 10;
    end;

    procedure VendorAddress(pVendor: Record Vendor): Text
    var
        Addr: array[8] of Text[100];
        FormatAddress: Codeunit "Format Address";
    begin
        FormatAddress.Vendor(Addr, pVendor);
        exit(FullAddress(Addr));
    end;

    procedure GetRecipientBankAccount(var pVendorBankAccount: Record "Vendor Bank Account"; pAccountNo: Code[20]; pRecipientBankAccount: code[20]): Text
    var
        CustomerBankAccount: Record "Customer Bank Account";
    begin
        if not pVendorBankAccount.Get(pAccountNo, pRecipientBankAccount) then
            Clear(pVendorBankAccount);
    end;

    procedure GetPaymentMethod(pPaymentMethodCode: Code[10]; pLanguageCode: Code[10]): Text
    var
        PaymentMethod: Record "Payment Method";
    begin
        if not PaymentMethod.Get(pPaymentMethodCode) then
            exit;
        PaymentMethod.TranslateDescription(pLanguageCode);
        exit(PaymentMethod.Description);
    end;
}
