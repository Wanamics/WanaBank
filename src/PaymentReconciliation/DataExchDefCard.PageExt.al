pageextension 87415 "wan Bank Data Exch Def Card" extends "Data Exch Def Card"
{
    layout
    {
        addbefore("Column Separator")
        {
            field("Line Separator"; Rec."Line Separator") { Visible = false; }
        }
    }
}
