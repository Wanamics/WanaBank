reportextension 81606 "wan Create Direct Debit Coll." extends "Create Direct Debit Collection"
{
    dataset
    {
        modify("Cust. Ledger Entry")
        {
            trigger OnAfterPreDataItem()
            begin
                "Cust. Ledger Entry".SetRange("On Hold", '');
            end;
        }
    }
}
