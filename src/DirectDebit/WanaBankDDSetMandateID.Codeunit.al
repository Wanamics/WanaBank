codeunit 87406 "WanaBank DD Set Mandate ID"
{
    TableNo = "Direct Debit Collection Entry";

    trigger OnRun()
    begin
        if Rec.FindSet() then
            repeat
                SetDefaultMandateID(Rec);
            until Rec.Next() = 0;

    end;

    local procedure SetDefaultMandateID(var pDirectDebitCollectionEntry: Record "Direct Debit Collection Entry")
    var
        SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
    begin
        SEPADirectDebitMandate.SetCurrentKey("Customer No.");
        SEPADirectDebitMandate.SetRange("Customer No.", pDirectDebitCollectionEntry."Customer No.");
        SEPADirectDebitMandate.SetFilter("Valid From", '<=%2', 0D, pDirectDebitCollectionEntry."Transfer Date");
        SEPADirectDebitMandate.SetFilter("Valid To", '%1|>=%2', 0D, pDirectDebitCollectionEntry."Transfer Date");
        SEPADirectDebitMandate.SetRange(Blocked, false);
        SEPADirectDebitMandate.SetRange(Closed, false);
        if SEPADirectDebitMandate.Count = 1 then
            if SEPADirectDebitMandate.FindFirst() then begin
                pDirectDebitCollectionEntry.Validate("Mandate ID", SEPADirectDebitMandate.ID);
                pDirectDebitCollectionEntry.Modify(true);
            end;
    end;
}
