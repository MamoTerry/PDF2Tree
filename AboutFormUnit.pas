unit AboutFormUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.Imaging.pngimage, Vcl.StdCtrls, Winapi.ShellAPI;

type
  TAboutForm = class(TForm)
    Image1: TImage;
    VerLabel: TLabel;
    LinkLabel: TLabel;
    procedure Image1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure LinkLabelClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private 宣言 }
  public
    { Public 宣言 }
  end;

var
  AboutForm: TAboutForm;

implementation

{$R *.dfm}

const
  Link='https://kennyterry.hatenablog.com/';

//-----------------------------------------------------------------------------
//  実際にアプリケーションのバージョン等の値を取得して表示するメソッド
//  引数はファイルのフルパス名
//-----------------------------------------------------------------------------
function VersionInfo(Lst:TStringList;FileName: string): Boolean;
type
  TLangAndCodePage = record
    wLanguage : WORD;
    wCodePage : WORD;
  end;
  PLangAndCodePage = ^TLangAndCodePage;

var
  dwHandle    : Cardinal;
  pInfo       : Pointer;
  pLangCode   : PLangAndCodePage;
  SubBlock    : String;
  InfoSize    : DWORD;
  pFileInfo   : Pointer;
  KeyName     : String;
  StrText     : String;
  i:integer;
const
  InfoStr =
    'Comments,'+//コメント
    'CompanyName,'+//社名
    'FileDescription,'+//説明
    'FileVersion,'+//ファイルバージョン
    'InternalName,'+//内部名
    'LegalCopyright,'+//著作権
    'LegalTrademarks,'+//商標
    'OriginalFilename,'+//正式ファイル名
    'PrivateBuild,'+//プライベートビルド情報
    'ProductName,'+//製品名
    'ProductVersion,'+//製品バージョン
    'SpecialBuild:string';//スペシャルビルド情報
begin
  Result := False;

  InfoSize := GetFileVersionInfoSize(PChar(FileName), dwHandle);
  if InfoSize = 0 then exit;

  GetMem(pInfo, InfoSize);
  try
    GetFileVersionInfo(PChar(FileName), 0, InfoSize, pInfo);

    //ロケール識別子とコードページを取得
    VerQueryValue(pInfo, '\VarFileInfo\Translation', Pointer(pLangCode), InfoSize);

    //上で取得した値を元に、
    //各種情報取得用に、VerQueryValue関数の第2引数で使用する文字列を作成
    SubBlock := IntToHex(pLangCode.wLanguage, 4) + IntToHex(pLangCode.wCodePage, 4);
    SubBlock := '\StringFileInfo\' + SubBlock + PathDelim;


    //取得する項目の名前を文字列配列に格納
    Lst.CommaText:=InfoStr;
    //項目名に相当するメンバーの値を順番に取得
    for i:=0 to Lst.Count-1 do
    begin
      KeyName:=Lst[i];
      if VerQueryValue(pInfo,
                          PChar(SubBlock + KeyName),
                          Pointer(pFileInfo),
                          InfoSize) then
                          begin
                            Lst[i]:=KeyName+ '='+PChar(pFileInfo)+#9;
                          end;
    end;

  finally
    Result := True;
    FreeMem(pInfo, InfoSize);
  end;
end;

procedure TAboutForm.FormCreate(Sender: TObject);
  function GetValue(Lst:TStringList;Value:string):string;
  var
    Idx:integer;
  begin
    Result:='';
    Idx:=Lst.IndexOfName(Value);
    if Idx>-1 then
    begin
      Result:=Lst[Idx];
      Result:=Copy(Result,Value.Length+2,Result.Length);
    end;
  end;
var
  Lst:TStringList;
  Idx:integer;
  S:string;
begin
  Lst:=TStringList.Create;
  try
    VersionInfo(Lst,Application.ExeName);
    VerLabel.Caption:='ProductVersion:'+GetValue(Lst,'ProductVersion');
    VerLabel.Hint:='FileVersion:'+GetValue(Lst,'FileVersion');
  finally
    Lst.Free;
  end;
  LinkLabel.Caption:=Link;
  LinkLabel.Left:=(ClientWidth-LinkLabel.Width) div 2;
end;

procedure TAboutForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_ESCAPE then ModalResult:=MrOk;
end;

procedure TAboutForm.Image1Click(Sender: TObject);
begin
  ModalResult:=MrOk;
end;

procedure TAboutForm.LinkLabelClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', PWideChar(Link), nil, nil, SW_SHOW);
end;

end.
