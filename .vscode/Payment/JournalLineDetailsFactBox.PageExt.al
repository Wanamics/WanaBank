pageextension 81604 "wan Journal Line Details FactB" extends "Journal Line Details FactBox"
{
    layout
    {
        addafter(AccountName)
        {
            field(wanIBAN; GetIBAN)
            {
                ApplicationArea = All;
                Editable = false;
                CaptionML = ENU = 'IBAN', FRA = 'IBAN';
                //ShowCaption = false;
            }
        }
    }
    local procedure GetIBAN(): Text
    var
        CustomerBankAccount: Record "Customer Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
    begin
        if (Rec."Account No." = '') or (Rec."Recipient Bank Account" = '') then
            exit('');
        case Rec."Account Type" of
            Rec."Account Type"::Customer:
                if CustomerBankAccount.Get(Rec."Account No.", Rec."Recipient Bank Account") then
                    exit(CustomerBankAccount.IBAN);
            Rec."Account Type"::Vendor:
                if VendorBankAccount.Get(Rec."Account No.", Rec."Recipient Bank Account") then
                    exit(VendorBankAccount.IBAN);
        end;
    end;

}
