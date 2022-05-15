page 81601 "wan Company Bank Statements"
{
    CaptionML = ENU = 'Imoorted Bank Statements', FRA = 'Relevés bancaires importés';
    PageType = List;
    SourceTable = "wan Company Bank Account Buf.";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                }
                field("Bank Account No."; Rec."Bank Account No.")
                {
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("Last Payment Statement No."; Rec."Last Payment Statement No.")
                {
                    ApplicationArea = All;
                }
                field("Last Statement No."; Rec."Last Statement No.")
                {
                    ApplicationArea = All;
                }
                field(IBAN; Rec.IBAN)
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}
