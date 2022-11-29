page 81600 "wanaData Exch Field Details"
{
    Caption = 'Bank transaction Details';
    DelayedInsert = true;
    Editable = false;
    PageType = ListPart;
    SourceTable = "Data Exch. Field";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Value; Rec.Value)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
    }
}
