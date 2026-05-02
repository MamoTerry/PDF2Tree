program PDF2Tree;

uses
  Vcl.Forms,
  PDF2TreeMainFormUnit in 'PDF2TreeMainFormUnit.pas' {PDF2TreeMainForm},
  AboutFormUnit in 'AboutFormUnit.pas' {AboutForm},
  OptionsFormUnit in 'OptionsFormUnit.pas' {OptionsForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'PDF to TreeText - PDF を階層化テキストに変換';
  Application.CreateForm(TPDF2TreeMainForm, PDF2TreeMainForm);
  Application.Run;
end.
