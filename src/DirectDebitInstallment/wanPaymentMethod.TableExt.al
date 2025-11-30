tableextension 87410 "wan Payment Method" extends "Payment Method"
{
    fields
    {
        field(87410; "wan Direct Debit Installments"; Integer)
        {
            Caption = 'Direct Debit Installments';
            FieldClass = FlowField;
            CalcFormula = count("wan Direct Debit Installment" where("Payment Method Code" = field("Code")));
            BlankZero = true;
            Editable = false;
        }
        modify("Direct Debit")
        {
            trigger OnAfterValidate()
            begin
                if xRec."Direct Debit" and not "Direct Debit" then begin
                    Rec.CalcFields("wan Direct Debit Installments");
                    Rec.Testfield("wan Direct Debit Installments", 0);
                end;
            end;
        }
    }
    trigger OnAfterDelete()
    var
        DirectDebitInstallment: Record "wan Direct Debit Installment";
    begin
        DirectDebitInstallment.SetRange("Payment Method Code", Code);
        DirectDebitInstallment.DeleteAll(true);
    end;
}
