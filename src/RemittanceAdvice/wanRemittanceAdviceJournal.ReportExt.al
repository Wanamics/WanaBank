reportextension 87401 "wan Remittance Advice-Journal" extends "Remittance Advice - Journal"
{
    WordLayout = './ReportLayouts/RemittanceAdviceJournal.docx';

    dataset
    {
        add(VendLoop)
        {
            column(wanCompanyPicture; CompanyInformation.Picture) { }
            column(wanCompanyAddress; CompanyAddress) { }
            column(wanCompanyContactInfo; CompanyContactInfo) { }
            column(wanCompanyLegalInfo; CompanyLegalInfo) { }
            column(wanVendor; SetVendor()) { }
            column(wanVendorAddress; RemittanceAdviceHelper.VendorAddress(Vendor)) { }
            column(wanRemittanceAdvice; RemittanceAdviceLbl) { }
            column(wanVendorBankAccountCaption; RecipientBankAccountLbl) { }
            column(wanPaymentMethodDescription; RemittanceAdviceHelper.GetPaymentMethod("Gen. Journal Line"."Payment Method Code", Vendor."Language Code")) { }
            column(wanVendorBankAccount; RemittanceAdviceHelper.GetRecipientBankAccount(VendorBankAccount, "Gen. Journal Line"."Account No.", "Gen. Journal Line"."Recipient Bank Account")) { }
            column(wanVendorBankAccountName; VendorBankAccount.Name) { }
            column(wanVendorBankAccountIBAN; VendorBankAccount.IBAN) { }
            column(wanDocumentDateCaption; "Vendor Ledger Entry".FieldCaption("Document Date")) { }
            column(wanDocumentTypeCaption; "Vendor Ledger Entry".FieldCaption("Document Type")) { }
            column(wanExternalDocumentNoCaption; "Vendor Ledger Entry".FieldCaption("External Document No.")) { }
            column(wanInitialAmountCaption; InitialAmountLbl) { }
            column(wanPaymentDiscAmountCaption; PaymentDiscountAmountLbl) { }
            column(wanPaymentAmountCaption; PaymentAmountLbl) { }
        }
    }
    requestpage
    {
        layout
        {
            // Copy from Canadian localization report 11383 "ExportElecPayments - Word"
            addlast(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    group(OutputOptions)
                    {
                        Caption = 'Output Options';
                        field(OutputMethod; SupportedOutputMethod)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Output Method';
                            OptionCaption = 'Print,Preview,PDF,Email,Word,XML - RDLC layouts only', Comment = 'Verbs - to print, to preview, to export to PDF, to email, to export to word, to export to XML (with note that it''s for RDLC layouts only)';
                            ToolTip = 'Specifies how the electronic payment is exported.';

                            trigger OnValidate()
                            begin
                                MapOutputMethod();
                            end;
                        }
                        field(ChosenOutputMethod; ChosenOutputMethod)
                        {
                            Visible = false;
                        }
                    }
                    group(EmailOptions)
                    {
                        Caption = 'Email Options';
                        Visible = ShowPrintIfEmailIsMissing;
                        field(PrintMissingAddresses; PrintIfEmailIsMissing)
                        {
                            ApplicationArea = Basic, Suite;
                            Caption = 'Print remaining statements';
                            ToolTip = 'Specifies that amounts remaining to be paid will be included.';
                        }
                    }
                }
            }
        }
    }
    trigger OnPreReport()
    begin
        RemittanceAdviceHelper.GetCompanyInfo(CompanyInformation, CompanyAddress, CompanyContactInfo, CompanyLegalInfo);
    end;

    var
        SupportedOutputMethod: Option Print,Preview,PDF,Email,Word,XML;
        // [InDataSet]
        ChosenOutputMethod: Integer;
        // [InDataSet]
        PrintIfEmailIsMissing: Boolean;
        // [InDataSet]
        ShowPrintIfEmailIsMissing: Boolean;
        CompanyInformation: Record "Company Information";
        CompanyAddress, CompanyContactInfo, CompanyLegalInfo : Text;
        RemittanceAdviceLbl: Label 'Remittance advice';
        InitialAmountLbl: Label 'Initial Amount';
        PaymentAmountLbl: Label 'Paid amount';
        PaymentDiscountAmountLbl: Label 'Pmt. Disc. Amount';
        RecipientBankAccountLbl: Label 'to your bank account:';
        VendorBankAccount: Record "Vendor Bank Account";
        RemittanceAdviceHelper: Codeunit "wan Remittance Advice Helper";

    local procedure MapOutputMethod()
    var
        CustomLayoutReporting: Codeunit "Custom Layout Reporting";
    begin
        ShowPrintIfEmailIsMissing := (SupportedOutputMethod = SupportedOutputMethod::Email);
        // Map the supported option (shown on the page) to the list of supported output methods
        case SupportedOutputMethod of
            SupportedOutputMethod::Print:
                ChosenOutputMethod := CustomLayoutReporting.GetPrintOption();
            SupportedOutputMethod::Preview:
                ChosenOutputMethod := CustomLayoutReporting.GetPreviewOption();
            SupportedOutputMethod::PDF:
                ChosenOutputMethod := CustomLayoutReporting.GetPDFOption();
            SupportedOutputMethod::Email:
                ChosenOutputMethod := CustomLayoutReporting.GetEmailOption();
            SupportedOutputMethod::Word:
                ChosenOutputMethod := CustomLayoutReporting.GetWordOption();
            SupportedOutputMethod::XML:
                ChosenOutputMethod := CustomLayoutReporting.GetXMLOption();
        end;
    end;

    local procedure SetVendor(): Text
    var
        Language: Codeunit Language;
    begin
        Vendor.Get("Gen. Journal Line"."Account No.");
        CurrReport.Language := Language.GetLanguageIdOrDefault(Vendor."Language Code");
    end;
}
