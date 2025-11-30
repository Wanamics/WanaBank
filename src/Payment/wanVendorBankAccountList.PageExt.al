pageextension 87405 "wan Vendor Bank Account List" extends "Vendor Bank Account List"
{
    layout
    {
        modify(IBAN) { Visible = true; Width = 25; }
        moveafter(Name; IBAN)
    }
}
