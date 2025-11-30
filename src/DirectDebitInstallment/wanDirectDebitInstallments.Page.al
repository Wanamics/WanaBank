page 87410 "wan Direct Debit Installments"
{
    ApplicationArea = All;
    UsageCategory = None;
    Caption = 'Direct Debit Installments';
    PageType = List;
    SourceTable = "wan Direct Debit Installment";
    AutoSplitKey = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Payment Method Code"; Rec."Payment Method Code")
                {
                    ToolTip = 'Specifies the value of the Payment Method Code field.';
                    Visible = false;
                }
                field("Installment Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.';
                    Visible = false;
                }
                field("Due Date Calculation"; Rec."Due Date Calculation")
                {
                    ToolTip = 'Specifies the value of the Due Date Calculation field.';
                }
            }
        }
    }
}
