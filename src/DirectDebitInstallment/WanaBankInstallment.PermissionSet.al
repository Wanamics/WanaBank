permissionset 87410 "WanaBank_Installment"
{
    Assignable = true;
    Caption = 'WanaBank DD Installment'; //, MaxLength = 30;
    Permissions =
        table "wan Direct Debit Installment" = X,
        tabledata "wan Direct Debit Installment" = RMID;
}
