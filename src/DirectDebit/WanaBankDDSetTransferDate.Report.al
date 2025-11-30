report 87402 "WanaBank DD Set Transfer Date"
{
    Caption = 'DirectDebit Set Transfer Date';
    ProcessingOnly = true;
    ApplicationArea = All;
    UsageCategory = None;

    dataset
    {
        dataitem(DirectDebitCollectionEntry; "Direct Debit Collection Entry")
        {
            DataItemTableView = sorting("Direct Debit Collection No.", "Entry No.");
            // trigger OnPreDataItem()
            // begin
            //     SetFilter("Transfer Date", '<>%1', NewTransferDate);
            //     ModifyAll("Transfer Date", NewTransferDate, true);
            //     SetRange("Transfer Date");
            // end;
            trigger OnAfterGetRecord()
            begin
                Validate("Transfer Date", NewTransferDate);
                Modify(true);
                Codeunit.Run(Codeunit::"SEPA DD-Check Line", DirectDebitCollectionEntry);
                // if ("Transfer Date" <> NewTransferDate) or ("Mandate ID" = '') then begin
                //     Validate("Transfer Date", NewTransferDate);
                //     if "Mandate ID" = '' then
                //         SetDefaultMandateID(DirectDebitCollectionEntry);
                //     Modify(true);
                // end;
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(Content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(TransferDate; NewTransferDate)
                    {
                        Caption = 'New Transfer Date';
                        ApplicationArea = All;
                    }
                    // field(SetDefaultMandate; SetDefaultMandate)
                    // {
                    //     Caption = 'Set Default Mandate';
                    // }
                }
            }
        }
    }
    var
        NewTransferDate: Date;
    // SetDefaultMandate: Boolean;

    // local procedure SetDefaultMandateID(var pDirectDebitCollectionEntry: Record "Direct Debit Collection Entry")
    // var
    //     SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
    // begin
    //     SEPADirectDebitMandate.SetCurrentKey("Customer No.");
    //     SEPADirectDebitMandate.SetRange("Customer No.", pDirectDebitCollectionEntry."Customer No.");
    //     SEPADirectDebitMandate.SetFilter("Valid From", '<=%2', 0D, pDirectDebitCollectionEntry."Transfer Date");
    //     SEPADirectDebitMandate.SetFilter("Valid To", '%1|>=%2', 0D, pDirectDebitCollectionEntry."Transfer Date");
    //     SEPADirectDebitMandate.SetRange(Blocked, false);
    //     SEPADirectDebitMandate.SetRange(Closed, false);
    //     if SEPADirectDebitMandate.FindFirst() then
    //         pDirectDebitCollectionEntry.Validate("Mandate ID", SEPADirectDebitMandate.ID);
    // end;
}
