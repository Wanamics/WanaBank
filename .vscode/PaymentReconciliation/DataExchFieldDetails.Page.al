page 81600 "wanaData Exch Field Details"
{
    Caption = 'Data Exchange Field Details';
    DelayedInsert = true;
    Editable = false;
    PageType = ListPart;
    SourceTable = 1221;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Value;rec.Value)
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
