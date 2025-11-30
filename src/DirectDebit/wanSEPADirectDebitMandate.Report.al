report 87406 "wan SEPA Direct Debit Mandate"
{
    Caption = 'SEPA Direct Debit Mandate';
    UsageCategory = None;
    DefaultLayout = Word;
    WordLayout = './ReportLayouts/SEPADirectDebitMandate.docx';
    dataset
    {
        dataitem("Company Information"; "Company Information")
        {
            DataItemTableView =;
            CalcFields = Picture;
            column(Comp_Name; Name) { }
            column(Comp_Address; FullAddress(CompAddress)) { }
            column(Comp_Picture; Picture) { }
            /*
            column(Comp_ICS; CISD) {} // Do not exists in W1
            */
            trigger OnAfterGetRecord()
            var
                TempCompanyInformation: Record "Company Information";
            begin
                TempCompanyInformation := "Company Information";
                TempCompanyInformation.Name := '';
                TempCompanyInformation."Name 2" := '';
                TempCompanyInformation."Contact Person" := '';
                FormatAddress.Company(CompAddress, TempCompanyInformation);
            end;
        }
        dataitem(SEPADirectDebitMandate; "SEPA Direct Debit Mandate")
        {
            RequestFilterFields = "Id", "Customer No.";
            column(Mand_ID; ID)
            {
                IncludeCaption = true;
            }
            column(Mand_TypeofPayment; "Type of Payment")
            {
                IncludeCaption = true;
            }
            column(Mand_DateOfSignature; "Date of Signature")
            {
                IncludeCaption = true;
            }
            column(Mand_ValidFrom; "Valid From")
            {
                IncludeCaption = true;
            }
            column(Mand_ValidTo; "Valid To")
            {
                IncludeCaption = true;
            }
            dataitem(Customer; Customer)
            {
                DataItemLink = "No." = field("Customer No.");
                column(Cust_No; "No.")
                {
                    IncludeCaption = true;
                }
                column(Cust_Name; Name)
                {
                    IncludeCaption = true;
                }
                column(Cust_Address; FullAddress(CustAddress))
                {
                }
                column(Cust_PartnerType_Customer; "Partner Type")
                {
                    IncludeCaption = true;
                }
                dataitem("Customer Bank Account"; "Customer Bank Account")
                {

                    DataItemLinkReference = Customer;
                    DataItemLink = "Customer No." = field("No.");
                    column(Bank_Name; Name)
                    {
                        IncludeCaption = true;
                    }
                    column(Bank_Address; FullAddress(BankAddress))
                    {
                    }
                    column(Bank_SWIFTCode; "SWIFT Code")
                    {
                        IncludeCaption = true;
                    }
                    column(Bank_IBAN; FormatIBAN(DelChr(IBAN)))
                    {
                    }
                    trigger OnPreDataItem()
                    begin
                        SetRange(Code, SEPADirectDebitMandate."Customer Bank Account Code");
                    end;

                    trigger OnAfterGetRecord()
                    var
                        TempCustomer: Record "Customer Bank Account";
                    begin
                        TempCustomer := "Customer Bank Account";
                        TempCustomer.Name := '';
                        TempCustomer."Name 2" := '';
                        TempCustomer."Contact" := '';
                        FormatAddress.CustBankAcc(BankAddress, "Customer Bank Account");
                    end;
                }
            }
            trigger OnAfterGetRecord()
            var
                TempCustomer: Record Customer;
            begin
                TempCustomer := Customer;
                TempCustomer.Name := '';
                TempCustomer."Name 2" := '';
                TempCustomer."Contact" := '';
                FormatAddress.Customer(CustAddress, Customer);
            end;
        }
    }
    var
        FormatAddress: Codeunit "Format Address";
        CompAddress, CustAddress, BankAddress : array[8] of Text[100];
    procedure LineFeed() ReturnValue: Text[2];
    begin
        ReturnValue[1] := 13;
        ReturnValue[2] := 10;
    end;

    procedure FullAddress(pAddress: array[8] of Text[100]) ReturnValue: Text;
    var
        i: Integer;
        LastOne: Integer;
    begin
        LastOne := 8;
        while (pAddress[LastOne] = '') and (LastOne > 1) do
            LastOne -= 1;
        ReturnValue := pAddress[1];
        for i := 2 to LastOne do
            ReturnValue += LineFeed() + pAddress[i];
    end;

    local procedure FormatIBAN(pIBAN: Text) ReturnValue: Text
    var
        i: Integer;
    begin
        for i := 1 to StrLen(pIBAN) do begin
            if (i - 1) mod 4 = 0 then
                ReturnValue += ' ';
            ReturnValue += pIBAN[i]
        end;
    end;
}
