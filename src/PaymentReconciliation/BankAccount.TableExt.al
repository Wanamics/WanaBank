tableextension 87401 "wan Bank Account" extends "Bank Account"
{
    fields
    {
        field(87400; "wan Import Object Type"; Option)
        {
            Caption = 'Import Object Type';
            DataClassification = SystemMetadata;
            // BlankZero = true;
            OptionCaption = ' ,,,Report,,Codeunit,XMLport', Locked = true;
            OptionMembers = " ",,,"Report",,"Codeunit","XMLport";
        }
        field(87401; "wan Import Object ID"; Integer)
        {
            Caption = 'Import Object ID';
            DataClassification = SystemMetadata;
            BlankZero = true;
            TableRelation = AllObjWithCaption."Object ID" where("Object Type" = field("wan Import Object Type"));
        }
    }
}
