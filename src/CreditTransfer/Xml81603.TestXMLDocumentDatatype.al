xmlport 87403 "Test XMLDocument Datatype"
{
    Caption = 'Test XMLDocument Datatype';
    UseRequestPage = true;
    schema
    {
        textelement(RootNodeName)
        {
            tableelement(PaymentTerms; "Payment Terms")
            {
                fieldelement(Code; PaymentTerms."Code")
                {
                }
                fieldelement(Description; PaymentTerms.Description)
                {
                }
                fieldelement(DueDateCalculation; PaymentTerms."Due Date Calculation")
                {
                }
                textelement(SvcLvl)
                {
                    textelement(Cd)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            Cd := 'SEPA';
                        end;
                    }
                }
                /* to be replaced by
                    textelement(CtgyPurp)
                    {
                        textelement(Cd)
                        {
                            trigger OnBeforePassVariable()
                            begin
                                Cd := 'TREA'; // Virement de trésorerie
                            end;
                        }
                    }
                */
            }
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(GroupName)
                {
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
}
