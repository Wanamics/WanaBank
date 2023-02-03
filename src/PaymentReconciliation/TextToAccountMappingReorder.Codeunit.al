codeunit 87404 "wan Text to Account Reorder"
{
    TableNo = "Text-to-Account Mapping";
    trigger OnRun()
    var
        NextRec : Record "Text-to-Account Mapping";
        i, j : Integer;
        Temp: Record "Text-to-Account Mapping" temporary;
    begin
        for i := 1 to Rec.Count do
            for j := 1 to Rec.Count - i do begin
                if j = 1 then begin
                    Rec.FindSet(true);
                    NextRec.FindSet(true);
                    NextRec.Next();
                end else begin
                    Rec.Next();
                    NextRec.Next();
                end;
                if StrLen(NextRec."Mapping Text") > StrLen(Rec."Mapping Text") then begin
                    Temp := Rec;
                    Rec."Mapping Text" := NextRec."Mapping Text";
                    Rec.Modify();
                    NextRec."Mapping Text" := Temp."Mapping Text";
                    NextRec.Modify();
                end;
            end;
    end;
}
