unit OptionsFormUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ExtCtrls;

type
  TOptionsForm = class(TForm)
    PageControl: TPageControl;
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    TabSheet1: TTabSheet;
    LinkTagsGroupBox: TGroupBox;
    LinkTagsRadioGroup: TRadioGroup;
    LinkTagOptionsPageControl: TPageControl;
    TabSheet2: TTabSheet;
    ExMarkdownLabel: TLabel;
    Label1: TLabel;
    TabSheet3: TTabSheet;
    LinkStartTagEdit: TEdit;
    LinkEndTagEdit: TEdit;
    LinkTagSampleLabel: TLabel;
    Label2: TLabel;
    GroupBox1: TGroupBox;
    ExcludeSmallImagesCheckBox: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure LinkStartTagEditChange(Sender: TObject);
    procedure LinkTagsRadioGroupClick(Sender: TObject);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

var
  OptionsForm: TOptionsForm;

implementation

{$R *.dfm}

const
//![img_001.png](SaveName_Images/img_001.png)
  ExMarkdownHead='![';
  ExMarkdowNeck='](';
  ExMarkdownFoot=')';
  ExPath='SaveName_Images/';
  ExFileName='img_001.png';
  ExMarkdown=ExMarkdownHead+ExFileName+ExMarkdowNeck+ExPath+ExFileName+ExMarkdownFoot;

procedure TOptionsForm.FormCreate(Sender: TObject);
var
  i:integer;
begin
  with PageControl do
  begin
    for i := 0 to PageCount - 1 do Pages[i].TabVisible := False;
    Align:=alClient;
  end;
  with LinkTagOptionsPageControl do
    for i := 0 to PageCount - 1 do Pages[i].TabVisible := False;
  ExMarkdownLabel.Caption:=ExMarkdown;//![img_001.png](SaveName_Images/img_001.png)
end;

procedure TOptionsForm.LinkStartTagEditChange(Sender: TObject);
begin
  if (LinkStartTagEdit.Text='')or(LinkEndTagEdit.Text='') then
  begin
    LinkTagSampleLabel.Font.Color:=clRed;
    LinkTagSampleLabel.Caption:='タグを入力してください';
    exit;
  end;
  if LinkStartTagEdit.Text=LinkEndTagEdit.Text then
  begin
    LinkTagSampleLabel.Font.Color:=clRed;
    LinkTagSampleLabel.Caption:='タグが重複しています';
    exit;
  end;
  LinkTagSampleLabel.Font.Color:=clWindowText;
  LinkTagSampleLabel.Caption:=LinkStartTagEdit.Text+ExPath+ExFileName+LinkEndTagEdit.Text;
end;

procedure TOptionsForm.LinkTagsRadioGroupClick(Sender: TObject);
begin
  LinkTagOptionsPageControl.ActivePageIndex:=(Sender as TRadioGroup).ItemIndex;
end;

end.
