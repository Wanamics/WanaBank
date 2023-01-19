reportextension 87400 "wan Recapitulation Form" extends "Recapitulation Form" // 10843
{
    RDLCLayout = './RecapitulationForm.rdl';

    dataset
    {
        add("Bank Account")
        {
            column(wanBankAccount_IBAN; "IBAN")
            {
            }
            column(wanBankAccount_IBAN_Caption; FieldCaption("IBAN"))
            {
            }
        }
        add("Gen. Journal Line")
        {
            column(wanGenJnlLine_ExternalDocNumber; "External Document No.")
            {
            }
            column(wanGenJnlLine_ExternalDocNumber_Caption; FieldCaption("External Document No."))
            {
            }
            column(wanGenJnlLine_Description; Description)
            {
            }
            column(wanGenJnlLine_Description_Caption; FieldCaption(Description))
            {
            }
            column(wanAppliesToID; "Applies-to ID")
            {
            }
            column(wanAppliesToID_Caption; FieldCaption("Applies-to ID"))
            {
            }
        }
    }
    requestpage
    {
        // Add changes to the requestpage here
    }
}
