pageextension 81600 "wanaBank Payment Reconcil Jnl." extends "Payment Reconciliation Journal"
{
    layout
    {
        addlast(FactBoxes)
        {
            part(DataExchDetails; "wanaData Exch Field Details")
            {
                ApplicationArea = All;
                SubPageLink = "Data Exch. No." = Field("Data Exch. Entry No."), "Line No." = Field("Data Exch. Line No.");
            }
        }
    }
}
