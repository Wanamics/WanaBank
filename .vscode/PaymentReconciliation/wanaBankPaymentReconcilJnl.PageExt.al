pageextension 81600 "wanaBank Payment Reconcil Jnl." extends "Payment Reconciliation Journal"
{
    layout
    {
        addlast(FactBoxes)
        {
            part(DataExchDetails;"81600")
            {
                ApplicationArea = All;
                SubPageLink = "Data Exch. No."=FIELD("Data Exch. Entry No."), "Line No."=FIELD("Data Exch. Line No.");
            }
        }
    }
}
