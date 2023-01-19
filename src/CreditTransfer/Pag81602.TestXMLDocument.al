page 87402 "Test XMLDocument"
{
    ApplicationArea = All;
    Caption = 'Test XMLDocument';
    PageType = List;
    SourceTable = "Payment Terms";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec."Code")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Due Date Calculation"; Rec."Due Date Calculation")
                {
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(TestXMLDocument)
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    iStream: InStream;
                    oStream: OutStream;
                    TempBlob: Codeunit "Temp Blob";
                    xDocument: XmlDocument;
                    xNodeList: XmlNodeList;
                    xnSvcLvl: XmlNode;
                    xnChrgBr: XmlNode;
                    xnCtgyPurp: XmlNode;
                    xeParent: XmlElement;
                    T: Text;
                    FileManagement: Codeunit "File Management";
                    i: Integer;
                    xeCtgyPurp, xeCd : XmlElement;
                begin
                    TempBlob.CreateOutStream(oStream);
                    Xmlport.Export(Xmlport::"Test XMLDocument Datatype", oStream, Rec);
                    TempBlob.CreateInStream(iStream);
                    XmlDocument.ReadFrom(iStream, xDocument);

                    xeCtgyPurp := XmlElement.Create('CtgyPurp');
                    xeCd := XmlElement.Create('Cd');
                    xeCd.Add(XmlText.Create('TREA'));
                    xeCtgyPurp.Add(xeCd);

                    xDocument.SelectNodes('/RootNodeName/PaymentTerms/SvcLvl', XNodeList);
                    for i := 1 to xNodeList.Count() do begin
                        xNodeList.Get(i, xnSvcLvl);
                        xnSvcLvl.GetParent(xeParent);
                        if xeParent.SelectSingleNode('DueDateCalculation', xnChrgBr) and xnChrgBr.AsXmlElement().InnerText.Contains('30D') then
                            xnSvcLvl.ReplaceWith(xeCtgyPurp);
                    end;
                    xDocument.WriteTo(t);
                    TempBlob.CreateOutStream(oStream);
                    oStream.Write(t);
                    FileManagement.BLOBExport(TempBlob, 'Test.xml', true);

                    /*
                    <RootNodeName>
                      <PaymentTerms>
                        <Code>30J</Code>
                        <Description>30 Jours date de facture</Description>
                        <DueDateCalculation>30D</DueDateCalculation>
                        <SvcLvl>
                          <Cd>SEPA</Cd>
                        </SvcLvl>
                        ...

                        If DueDateCalculation contains 30D, <SvcLvl> element is replaced by :
                        <CtgyPurp>
                            <Cd>TREA</Cd>
                        </CtgyPurp>
                    */
                end;
            }
        }
    }
}
