permissionset 87410 "W_Bank_Installment"
{
    Assignable = true;
    Caption = 'WanaBank Installment', MaxLength = 30;
    Permissions =
        table "wan Direct Debit Installment" = X,
        tabledata "wan Direct Debit Installment" = RMID;
}
