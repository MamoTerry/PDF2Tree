unit PDF2TreeMainFormUnit;
{
サンプルプログラム
E:\DELPHI\GIT\PdfiumLib\Example\MainFrm.pas
}
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  PdfiumCtrl, PdfiumLib,
  PdfiumCore, // 低レベルAPIへのアクセスに必須
  Vcl.Imaging.pngimage,
  System.JSON,
  System.Generics.Collections, System.Generics.Defaults,
  System.StrUtils, System.IOUtils,
  Vcl.ComCtrls, NewCtrls, System.Actions, Vcl.ActnList, System.ImageList,
  Vcl.ImgList, Vcl.ToolWin, Vcl.ExtCtrls, CuteSplt, Vcl.StdCtrls,
  Vcl.Menus, SysCtrls;

// 抽出した画像の一時保持用レコード
type
  TExtractedImage = record
    TopY: Single; // Y座標（大きいほど上）
    SavePath: string;
  end;

type
  TPDF2TreeMainForm = class(TForm)
    TreeView: TTreeView;
    FileDrop: TFileDrop;
    ToolBar: TToolBar;
    ToolButton1: TToolButton;
    ToolBarImageList: TImageList;
    ToolButton2: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ActionList1: TActionList;
    PrevAction: TAction;
    NextAction: TAction;
    FitWidthAction: TAction;
    FitHeightAction: TAction;
    FitAutoAction: TAction;
    OptionsAction: TAction;
    ToolButton8: TToolButton;
    ToolButton9: TToolButton;
    OutPutLawAction: TAction;
    ToolButton10: TToolButton;
    ToolButton3: TToolButton;
    OpenAction: TAction;
    ToolButton11: TToolButton;
    CuteSplitter1: TCuteSplitter;
    DebugAction: TAction;
    DebugMemo: TMemo;
    MainMenu: TMainMenu;
    F1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    V1: TMenuItem;
    FitAutoAction1: TMenuItem;
    N3: TMenuItem;
    M1: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    O1: TMenuItem;
    N6: TMenuItem;
    AboutMenu: TMenuItem;
    DebugMenu: TMenuItem;
    SingleInstance1: TSingleInstance;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FileDropFileDrop(Sender: TObject; Num: Integer; Files: TStrings;
      X, Y: Integer);
    procedure TreeViewClick(Sender: TObject);
    procedure PrevActionUpdate(Sender: TObject);
    procedure OutPutLawActionUpdate(Sender: TObject);
    procedure PrevActionExecute(Sender: TObject);
    procedure NextActionExecute(Sender: TObject);
    procedure FitWidthActionExecute(Sender: TObject);
    procedure OpenActionExecute(Sender: TObject);
    procedure DebugActionExecute(Sender: TObject);
    procedure OutPutLawActionExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShortCut(var Msg: TWMKey; var Handled: Boolean);
    procedure AboutMenuClick(Sender: TObject);
    procedure OptionsActionExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure DebugMenuClick(Sender: TObject);
  private
    { Private 宣言 }
    PdfControl: TPdfControl;
    FTargetPDFPath:string;
    FImageCounter: Integer;

    LinkTagsLaw:0..1;
    LinkStartTag,LinkEndTag:string;
    JsonFileName: string;
    procedure JsonRead;
    procedure JsonWrite;
    function GetSaveImagePath(const BaseName, ImageName: string): string;
    function MakeImageTag(const ImagePath, BaseTextPath: string): string;
    function ExtractImagesFromPage(Page: TPdfPage; const OutputTextPath: string): string;
    function HasImageObjects(Page: TPdfPage): Boolean;
    function RenderPageAsImage(Page: TPdfPage; const SavePath: string): Boolean;
    function LoadPDF(FileName:string):Boolean;
    procedure ExportDocTreeTxt(const Path: TFileName);
    function GetPageText(PageIndex:integer):string;
// 指定範囲のページテキストを取得する関数
    function GetPageTextRange(StartPage, EndPage: Integer; const OutputTextPath: string): string;
// 呼び出し元（PDF読み込み完了後に実行）
    procedure LoadBookmarksToTree;
// 再帰的なしおり探索処理
    procedure TraverseBookmark(DocHandle: FPDF_DOCUMENT; Bookmark: FPDF_BOOKMARK;
                ParentNode: TTreeNode);  public


    procedure WndProc(var Message: TMessage); override;
  public
    { Public 宣言 }
  end;

var
  PDF2TreeMainForm: TPDF2TreeMainForm;

implementation

{$R *.dfm}

uses AboutFormUnit, OptionsFormUnit;

type
  // 汎用プログレスダイアログ（DFM不要）
  TSmartProgress = record
  private
    FForm: TForm;
    FProg: TProgressBar;
    FLabel: TLabel;
  public
    procedure Start(AOwner: TComponent; const ATitle: string; AMax: Integer);
    procedure Step(const AMsg: string = '');
    procedure Finish;
  end;

{ TSmartProgress }

procedure TSmartProgress.Start(AOwner: TComponent; const ATitle: string; AMax: Integer);
begin
  // 動的にフォームを生成
  FForm := TForm.Create(AOwner);
  FForm.Position := poOwnerFormCenter;
  FForm.BorderStyle := bsDialog;
  FForm.BorderIcons :=[]; // 閉じるボタンを無効化（処理中の強制終了を防ぐ）
  FForm.Caption := ATitle;
  FForm.ClientWidth := 350;
  FForm.ClientHeight := 80;

  // メッセージ用ラベルの生成
  FLabel := TLabel.Create(FForm);
  FLabel.Parent := FForm;
  FLabel.SetBounds(10, 10, 330, 20);
  FLabel.AutoSize := False;
  FLabel.Caption := '処理中...';

  // プログレスバーの生成
  FProg := TProgressBar.Create(FForm);
  FProg.Parent := FForm;
  FProg.SetBounds(10, 35, 330, 25);
  FProg.Max := AMax;
  FProg.Position := 0;
  FProg.Step := 1;

  FForm.Show;
  Application.ProcessMessages; // UIを強制描画
end;

procedure TSmartProgress.Step(const AMsg: string = '');
begin
  if Assigned(FProg) then
  begin
    FProg.StepIt;
    if AMsg <> '' then
      FLabel.Caption := AMsg;

    // メインスレッドをブロックせず、UIの再描画を許可する
    Application.ProcessMessages;
  end;
end;

procedure TSmartProgress.Finish;
begin
  if Assigned(FForm) then
    FForm.Free;
end;

function SetForegroundWindowT(hWnd:HWND):Boolean;
var
  dwTargetTID,
  dwActiveTID:  DWORD;
begin
  dwTargetTID := GetWindowThreadProcessId(hWnd, nil);
  dwActiveTID := GetWindowThreadProcessId(GetForegroundWindow, nil);
  if dwTargetTID = dwActiveTID then
    Result := BringWindowToTop(hWnd)
  else
  begin
    AttachThreadInput(dwTargetTID, dwActiveTID, True);
    try
      Result := BringWindowToTop(hWnd);
    finally
      AttachThreadInput(hWnd, dwActiveTID, FALSE);
    end;
  end;
end;

// 行頭のピリオドを全角に置換するサニタイズ関数
function SanitizeTextForTree(const SourceText: string): string;
var
  SL: TStringList;
  i: Integer;
  LineStr: string;
begin
  if SourceText = '' then Exit('');

  SL := TStringList.Create;
  try
    SL.Text := SourceText;
    for i := 0 to SL.Count - 1 do
    begin
      LineStr := SL[i];
      if (LineStr <> '') and (LineStr[1] = '.') then
      begin
        LineStr[1] := '．'; // 全角ピリオドに置換
        SL[i] := LineStr;
      end;
    end;
    Result := SL.Text;
  finally
    SL.Free;
  end;
end;

procedure TPDF2TreeMainForm.AboutMenuClick(Sender: TObject);
begin
  with TAboutForm.Create(Self) do
  begin
    try
      ShowModal;
    finally
      Release;
    end;
  end;
end;

procedure TPDF2TreeMainForm.DebugActionExecute(Sender: TObject);
var
{  Page: TPdfPage;
  PageIndex,
  TotalChars: Integer;}
  Node: TTreeNode;
begin
  {$IFDEF DEBUG}
  DebugMemo.Visible:=True;



  if TreeView.Items.Count = 0 then exit;
  Node := TreeView.Items[0];
  ShowMessage(Node.Text);

{  PageIndex := Integer(TreeView.Selected.Data);
  if PageIndex >= 0 then
  begin
    PdfControl.PageIndex := PageIndex;

    Page := PdfControl.Document.Pages[PageIndex];
    TotalChars := Page.GetCharCount; // 総文字数を取得

    if TotalChars > 0 then
      Memo1.Text := Page.ReadText(0, TotalChars)
    else
      Memo1.Text := ''; // テキストが存在しない場合
  end;}
//  LoadPDF('C:\Program Files (x86)\JustSystems\ATOK27\ATOK2014.PDF');
//  ShowMessage(PdfControl.Document.Pages[0].ReadText(0,-1));
  {$ENDIF}
end;

procedure TPDF2TreeMainForm.DebugMenuClick(Sender: TObject);
begin
  DebugMemo.Visible:=not DebugMemo.Visible;
end;

procedure TPDF2TreeMainForm.ExportDocTreeTxt(const Path: TFileName);
var
  Node: TTreeNode;
  SL: TStringList;
  LastOutputPage: Integer;
  Progress: TSmartProgress; // ★追加
const
  LayeredMark = '.';

  procedure CreateText(Tier: Integer; CurrentNode: TTreeNode);
  var
    ChildNode, NextNode: TTreeNode;
    NodeText, TitleStr: string;
    StartPage, EndPage, P: Integer;
  begin
    while Assigned(CurrentNode) do
    begin
      // ★プログレスバーを1ステップ進め、現在処理中のノード名を表示
      Progress.Step('抽出中: ' + CurrentNode.Text);

      // 1. タイトルの抽出
      TitleStr := CurrentNode.Text;
      P := Pos(' (Page: ', TitleStr);
      if P > 0 then
        TitleStr := Copy(TitleStr, 1, P - 1);

      SL.Add(DupeString(LayeredMark, Tier) + TitleStr);

      // 2. ページ範囲の決定
      StartPage := Integer(CurrentNode.Data);
      if StartPage <= LastOutputPage then
        StartPage := LastOutputPage + 1;

      ChildNode := CurrentNode.GetFirstChild;

      if Assigned(ChildNode) and (Integer(ChildNode.Data) = Integer(CurrentNode.Data)) then
      begin
        EndPage := StartPage - 1;
      end
      else
      begin
        NextNode := CurrentNode.GetNext;
        while Assigned(NextNode) and (Integer(NextNode.Data) <= Integer(CurrentNode.Data)) do
        begin
          NextNode := NextNode.GetNext;
        end;

        if Assigned(NextNode) then
          EndPage := Integer(NextNode.Data) - 1
        else
          EndPage := PdfControl.Document.PageCount - 1;
      end;

      // 3. テキストと画像の取得
      if StartPage <= EndPage then
      begin
        NodeText := GetPageTextRange(StartPage, EndPage, Path);
        NodeText := SanitizeTextForTree(NodeText);
        if NodeText <> '' then
          SL.Add(NodeText);

        LastOutputPage := EndPage;
      end;

      // 4. 子ノードの処理（再帰）
      if Assigned(ChildNode) then
      begin
        CreateText(Tier + 1, ChildNode);
      end;

      CurrentNode := CurrentNode.GetNextSibling;
    end;
  end;

begin
  if TreeView.Items.Count = 0 then Exit;
  SL := TStringList.Create;
  Screen.Cursor := crHourGlass;

  // ★プログレスダイアログの開始（最大値はツリーの全ノード数）
  Progress.Start(Self, '階層化テキスト出力', TreeView.Items.Count);
  try
    LastOutputPage := -1;
    FImageCounter := 0; // 画像連番のリセット

    Node := TreeView.Items[0];
    CreateText(1, Node);
    SL.SaveToFile(Path, TEncoding.UTF8);
  finally
    // ★プログレスダイアログの破棄
    Progress.Finish;

    SL.Free;
    Screen.Cursor := crDefault;
  end;
end;

function TPDF2TreeMainForm.ExtractImagesFromPage(Page: TPdfPage;
  const OutputTextPath: string): string;
var
  ObjCount, i, Y: Integer;
  PageObj: FPDF_PAGEOBJECT;
  BmpHandle: FPDF_BITMAP;
  ImgWidth, ImgHeight, ImgStride, ImgFmt: Integer;
  ImgBuffer: Pointer;
  Bmp: TBitmap;
  Png: TPngImage;
  ImageName, SavePath: string;
  Src, Dest: PByte;
  Left, Bottom, Right, Top: Single;
  ImageList: TList<TExtractedImage>;
  ExtImg: TExtractedImage;
begin
  Result := '';
  ObjCount := FPDFPage_CountObjects(Page.Handle);
  if ObjCount = 0 then Exit;

  ImageList := TList<TExtractedImage>.Create;
  try
    for i := 0 to ObjCount - 1 do
    begin
      PageObj := FPDFPage_GetObject(Page.Handle, i);

      // 画像オブジェクトのみを対象とする
      if FPDFPageObj_GetType(PageObj) = 3 then // 3 = FPDF_PAGEOBJ_IMAGE
      begin
        // オブジェクトの座標とサイズ（PDFポイント単位）を取得
        if FPDFPageObj_GetBounds(PageObj, Left, Bottom, Right, Top)<>0 then
        begin
          // ★フィルタリング: 幅または高さが小さすぎる画像（アイコン等）は無視する
          // ※ 1ポイント ≒ 1/72インチ。50ポイントは約1.7cm
          if (Abs(Right - Left) < 50.0) or (Abs(Top - Bottom) < 50.0) then
            Continue;
        end
        else
          Top := 0; // 座標取得失敗時のフェイルセーフ

        BmpHandle := FPDFImageObj_GetBitmap(PageObj);
        if BmpHandle <> nil then
        begin
          try
            ImgWidth := FPDFBitmap_GetWidth(BmpHandle);
            ImgHeight := FPDFBitmap_GetHeight(BmpHandle);
            ImgStride := FPDFBitmap_GetStride(BmpHandle);
            ImgFmt := FPDFBitmap_GetFormat(BmpHandle);
            ImgBuffer := FPDFBitmap_GetBuffer(BmpHandle);

            if (ImgWidth > 0) and (ImgHeight > 0) and (ImgBuffer <> nil) then
            begin
              Bmp := TBitmap.Create;
              try
                if (ImgFmt = 3) or (ImgFmt = 4) then
                  Bmp.PixelFormat := pf32bit
                else if ImgFmt = 2 then
                  Bmp.PixelFormat := pf24bit
                else
                  Continue; // モノクロ等はスキップ（必要なら後日対応）

                Bmp.Width := ImgWidth;
                Bmp.Height := ImgHeight;

                Src := ImgBuffer;
                for Y := 0 to ImgHeight - 1 do
                begin
                  Dest := Bmp.ScanLine[Y];
                  Move(Src^, Dest^, ImgStride);
                  Inc(Src, ImgStride);
                end;

                Inc(FImageCounter);
                ImageName := System.SysUtils.Format('img_%.3d.png', [FImageCounter]);
                SavePath := GetSaveImagePath(OutputTextPath, ImageName);
                ForceDirectories(ExtractFilePath(SavePath));

                Png := TPngImage.Create;
                try
                  Png.Assign(Bmp);
                  Png.SaveToFile(SavePath);

                  // リストに追加（後でソートするため）
                  ExtImg.TopY := Top;
                  ExtImg.SavePath := SavePath;
                  ImageList.Add(ExtImg);
                finally
                  Png.Free;
                end;
              finally
                Bmp.Free;
              end;
            end;
          finally
            FPDFBitmap_Destroy(BmpHandle);
          end;
        end;
      end;
    end;

    // ★Y座標（TopY）の降順（上から下）でソート
    ImageList.Sort(TComparer<TExtractedImage>.Construct(
      function(const L, R: TExtractedImage): Integer
      begin
        if L.TopY > R.TopY then Result := -1
        else if L.TopY < R.TopY then Result := 1
        else Result := 0;
      end));

    // ソートされた順にタグを生成
    for ExtImg in ImageList do
    begin
      Result := Result + MakeImageTag(ExtImg.SavePath, OutputTextPath) + sLineBreak;
    end;

  finally
    ImageList.Free;
  end;
end;

procedure TPDF2TreeMainForm.FileDropFileDrop(Sender: TObject; Num: Integer;
  Files: TStrings; X, Y: Integer);
begin
  SetForegroundWindowT(Handle);
  if not LoadPDF(Files[0]) then ShowMessage('読み込みエラー');
end;

procedure TPDF2TreeMainForm.FitWidthActionExecute(Sender: TObject);
begin
  case (Sender as TAction).Tag of
    1: PdfControl.ScaleMode:=smFitWidth;
    2: PdfControl.ScaleMode:=smFitHeight;
  else PdfControl.ScaleMode:=smFitAuto;
  end;
end;

procedure TPDF2TreeMainForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  JsonWrite;
end;

procedure TPDF2TreeMainForm.FormCreate(Sender: TObject);
var
  S:string;
begin
  {$IFDEF DEBUG}
    DebugMenu.Visible:=True;
  {$ENDIF}
  Caption:=Application.Title;
  PdfControl := TPdfControl.Create(Self);
  PdfControl.Parent:=Self;
  PdfControl.Align:=alClient;

  AboutMenu.Caption:=ExtractFileName(ChangeFileExt(Application.ExeName,''))+' について(&A)';

  JsonFileName := TPath.ChangeExtension(Application.ExeName, '.json');
  JsonRead;

  if ParamCount=0 then exit;

  S:=ParamStr(1);
  if not TFile.Exists(S) then ShowMessage('ファイル'+#13+S+#13+'が見つかりません') else
    if not LoadPDF(S) then ShowMessage('読み込みエラー');
end;

procedure TPDF2TreeMainForm.FormDestroy(Sender: TObject);
begin
  PdfControl.Free;
end;

procedure TPDF2TreeMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  // Alt または F10 が押されたらメニューを表示
  if (Key = VK_MENU) or (Key = VK_F10) then
  begin
    if Menu = nil then
      Menu := MainMenu;
  end;
end;

procedure TPDF2TreeMainForm.FormShortCut(var Msg: TWMKey; var Handled: Boolean);
begin
  // メニューが非表示(nil)の状態でも、MainMenu1 のショートカットを評価させる
  if (Menu = nil) and Assigned(MainMenu) then
  begin
    Handled := MainMenu.IsShortCut(Msg);
  end;
end;

procedure TPDF2TreeMainForm.FormShow(Sender: TObject);
begin
  Menu := nil;
end;

function TPDF2TreeMainForm.GetPageText(PageIndex: integer): string;
var
  Page: TPdfPage;
  TotalChars: Integer;
begin
  Result:='';
  if PageIndex >= 0 then
  begin
    PdfControl.PageIndex := PageIndex;

    Page := PdfControl.Document.Pages[PageIndex];
    TotalChars := Page.GetCharCount; // 総文字数を取得

    if TotalChars > 0 then
      Result := Page.ReadText(0, TotalChars);
  end;
end;

function TPDF2TreeMainForm.GetPageTextRange(StartPage,
  EndPage: Integer; const OutputTextPath: string): string;
var
  Page: TPdfPage;
  TotalChars, i: Integer;
  PageText, ImageName, SavePath, ImageTags: string;
begin
  Result := '';
  if (StartPage < 0) or (StartPage > EndPage) then Exit;

  for i := StartPage to EndPage do
  begin
    Page := PdfControl.Document.Pages[i];

    // 1. テキストの抽出
    TotalChars := Page.GetCharCount;
    if TotalChars > 0 then
      PageText := Trim(Page.ReadText(0, TotalChars)) // Trimで空白のみのテキストを空文字にする
    else
      PageText := '';

    // 2. 画像抽出ロジックの分岐（ハイブリッド方式）
    if (PageText = '') and HasImageObjects(Page) then
    begin
      // ★パターンA: テキストが無く、画像が存在するページ
      // -> タイル分割を回避するため、ページ全体を1枚の画像としてレンダリング
      Inc(FImageCounter);
      ImageName := System.SysUtils.Format('img_%.3d.png', [FImageCounter]);
      SavePath := GetSaveImagePath(OutputTextPath, ImageName);

      if RenderPageAsImage(Page, SavePath) then
        ImageTags := MakeImageTag(SavePath, OutputTextPath) + sLineBreak
      else
        ImageTags := '';
    end
    else
    begin
      // ★パターンB: テキストが存在するページ（または画像が全く無いページ）
      // -> 意味のある画像オブジェクトのみを個別に抽出（前回の ExtractImagesFromPage）
      ImageTags := ExtractImagesFromPage(Page, OutputTextPath);
    end;

    // 3. 結合
    if PageText <> '' then
      Result := Result + PageText + sLineBreak;
    if ImageTags <> '' then
      Result := Result + ImageTags;
  end;

  Result := TrimRight(Result);
end;

// Markdownのリンクとして安全なファイル名/フォルダ名に変換する
function SanitizeForMarkdownPath(const SourceName: string): string;
var
  i:integer;
const
  BadString=' ()[]';
begin
  Result:=SourceName;
  for i:=1 to Length(BadString) do
    Result:=
      StringReplace(Result,
                    BadString[i],
                    '_',
                    [rfReplaceAll]);
end;

function TPDF2TreeMainForm.GetSaveImagePath(const BaseName,
  ImageName: string): string;
var
  SafeBaseName: string;
begin
  // 将来的に設定で変更可能にする。今回はEXEと同じ階層の「PDFファイル名_images」フォルダとする
  // ※実際の運用では、現在開いているPDFのファイル名をベースにするのが望ましい

  // ベースとなるPDFファイル名（拡張子なし）をサニタイズ
  SafeBaseName := SanitizeForMarkdownPath(ExtractFileName(ChangeFileExt(BaseName, '')));
  // 出力先ディレクトリ ＋ サニタイズ済みフォルダ名 ＋ 画像名
  Result := ExtractFilePath(BaseName) + SafeBaseName + '_Images\' + ImageName;
end;

function TPDF2TreeMainForm.HasImageObjects(Page: TPdfPage): Boolean;
var
  ObjCount, i: Integer;
  PageObj: FPDF_PAGEOBJECT;
begin
  Result := False;
  ObjCount := FPDFPage_CountObjects(Page.Handle);
  for i := 0 to ObjCount - 1 do
  begin
    PageObj := FPDFPage_GetObject(Page.Handle, i);
    if FPDFPageObj_GetType(PageObj) = 3 then // 3 = FPDF_PAGEOBJ_IMAGE
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TPDF2TreeMainForm.JsonRead;
var
  JsonText: string;
  JSON: TJSONObject;
begin
  // 1. デフォルト値の初期化（ファイルが存在しない、またはキーが欠損している場合のフェイルセーフ）
  LinkTagsLaw:=0;
  LinkStartTag:='<nlink>';
  LinkEndTag:='</nlink>';
  if not TFile.Exists(JsonFileName) then Exit;
  // 2. ファイルからテキストとして読み込む
  JsonText := TFile.ReadAllText(JsonFileName, TEncoding.UTF8);

  // 3. テキストをJSONオブジェクトにパースする
  JSON := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;
  if Assigned(JSON) then
  begin
    try
      // 4. JSONオブジェクトから値を取得し、変数に格納する
      // GetValue<T>の第2引数は、キーが存在しなかった場合のデフォルト値として機能する
      LinkTagsLaw := JSON.GetValue<Integer>('LinkTagsLaw', LinkTagsLaw);
      LinkStartTag := JSON.GetValue<string>('LinkStartTag', LinkStartTag);
      LinkEndTag := JSON.GetValue<string>('LinkEndTag', LinkEndTag);
    finally
      JSON.Free;
    end;
  end;
end;

procedure TPDF2TreeMainForm.JsonWrite;
var
  JSON: TJSONObject;
begin
  // 1. JSONオブジェクトを新規作成する
  JSON := TJSONObject.Create;
  try
    // 2. 変数の値をJSONオブジェクトにセットする
    JSON.AddPair('LinkTagsLaw', TJSONNumber.Create(LinkTagsLaw));
    JSON.AddPair('LinkStartTag', LinkStartTag);
    JSON.AddPair('LinkEndTag', LinkEndTag);

    // 3. JSONオブジェクトを文字列化し、ファイルに保存する
    // Format(2) を使用することで、インデントされた人間が読みやすい形式で保存される
    TFile.WriteAllText(JsonFileName, JSON.Format(2), TEncoding.UTF8);
  finally
    JSON.Free;
  end;
end;

procedure TPDF2TreeMainForm.LoadBookmarksToTree;
var
  DocHandle: FPDF_DOCUMENT;
  RootBookmark: FPDF_BOOKMARK;
begin
  if not Assigned(PdfControl.Document) then Exit;

  DocHandle := PdfControl.Document.Handle;

  // ルートの最初の子（第一階層の最初のしおり）を取得
  RootBookmark := FPDFBookmark_GetFirstChild(DocHandle, nil);
  if RootBookmark = nil then
  begin
    // しおりが存在しない
    Exit;
  end;

  TreeView.Items.BeginUpdate;
  try
    TreeView.Items.Clear;
    TraverseBookmark(DocHandle, RootBookmark, nil);
  finally
    TreeView.Items.EndUpdate;
  end;
end;

function TPDF2TreeMainForm.LoadPDF(FileName: string): Boolean;
var
  Pwd: string;
  Loaded: Boolean;
begin
  Result := False;
  Pwd := '';
  Loaded := False;

  while not Loaded do
  begin
    try
      // パスワードを指定してロード（初回は空文字）
      PdfControl.LoadFromFile(FileName, UTF8Encode(Pwd));
      Loaded := True;
    except
      on E: Exception do
      begin
        // エラーメッセージにパスワード関連の文字列が含まれるか判定
        // ※実際の例外メッセージはPdfiumLibの実装に依存するが、通常 'Password' が含まれる
        if Pos('Password', E.Message) > 0 then
        begin
          if not InputQuery('パスワード入力', 'このPDFは保護されています。パスワードを入力:', Pwd) then
            Exit; // ユーザーがキャンセルした場合は処理中断
        end
        else
        begin
          // パスワード以外のエラー（ファイル破損など）
          ShowMessage('PDFの読み込みに失敗: ' + E.Message);
          Exit;
        end;
      end;
    end;
  end;

  Result := True;
  FTargetPDFPath:=FileName;
  LoadBookmarksToTree;
end;

function TPDF2TreeMainForm.MakeImageTag(const ImagePath, BaseTextPath: string): string;
// 相対パスを用いたタグ生成
var
  RelPath: string;
begin
  // 出力先テキストのディレクトリを基準とした相対パスを取得
  RelPath := ExtractRelativePath(ExtractFilePath(BaseTextPath), ImagePath);

  // MarkdownやNanaTerryでの互換性のため、バックスラッシュをスラッシュに変換
  RelPath := StringReplace(RelPath, '\', '/', [rfReplaceAll]);

  if LinkTagsLaw=0 then//マークダウン記述
  begin
    Result := '![' + ExtractFileName(ImagePath) + '](' + RelPath + ')';
  end else  // 設定で '<nlink>' + RelPath + '</nlink>' 等に変更可能
  begin
    Result:=LinkStartTag+RelPath+LinkEndTag;
  end;
end;

procedure TPDF2TreeMainForm.NextActionExecute(Sender: TObject);
begin
  PdfControl.GotoNextPage;
end;

procedure TPDF2TreeMainForm.OpenActionExecute(Sender: TObject);
begin
  with TOpenDialog.Create(Self) do
  begin
    try
      Options:=[ofHideReadOnly,//［読み取り専用ファイルとして開く］チェックボックスを削除
                ofEnableSizing,//ダイアログサイズを変更できる
  //              ofAllowMultiSelect,//ユーザーがダイアログボックスで複数のファイルを選択できる
                ofFileMustExist//存在しないファイルを選択エラー
                ];
      Title:='PDF を開く';
      Filter:='PDF ファイル|*.pdf|全てのファイル|*.*';
  //    Filter:=GraphicFilter(TGraphic)+'|All Files|*.*';
      if not Execute then exit;
      if not LoadPDF(FileName) then ShowMessage('読み込みエラー');
    finally
      Free;
    end;
  end;
end;

procedure TPDF2TreeMainForm.OptionsActionExecute(Sender: TObject);
begin
  with TOptionsForm.Create(Self) do
  begin
    try
      PageControl.ActivePageIndex:=(Sender as TAction).Tag;
      LinkTagsRadioGroup.ItemIndex:=LinkTagsLaw;
      LinkTagsRadioGroup.OnClick(LinkTagsRadioGroup);
      LinkStartTagEdit.Text:=LinkStartTag;
      LinkEndTagEdit.Text:=LinkEndTag;

      ShowModal;
      if ModalResult<>mrOk then exit;

      LinkTagsLaw:=LinkTagsRadioGroup.ItemIndex;
      LinkStartTag:=LinkStartTagEdit.Text;
      LinkEndTag:=LinkEndTagEdit.Text;
      (Sender as TAction).Tag:=PageControl.ActivePageIndex;
    finally
      Release;
    end;
  end;
end;

procedure TPDF2TreeMainForm.OutPutLawActionExecute(Sender: TObject);
begin
  with TSaveDialog.Create(Self) do
  begin
    try
      Title:='階層化テキストへのエクスポート';
      Filter:='Text Files|*.txt|All Files|*.*';
      if TFile.Exists(FTargetPDFPath) then FileName:=ChangeFileExt(FTargetPDFPath,'.txt');
      Options:=[ofOverwritePrompt,//既存のファイルを上書きするかどうか尋ねる
                ofPathMustExist,//存在しないパスにエラーメッセージ
                ofNoReadOnlyReturn,//読み出し専用のファイルを選択エラー
                ofHideReadOnly,//［読み取り専用］チェックボックスを削除
                ofEnableSizing];//ダイアログサイズを変更できる
      if not Execute then exit;
  //★ここ★が DefaultExt 相当
      if ExtractFileExt(FileName)='' then
        FileName:=ChangeFileExt(FileName,'.txt');
      ExportDocTreeTxt(FileName);
      ShowMessage('正常に出力されました');
    finally
      Free;
    end;
  end;
end;

procedure TPDF2TreeMainForm.OutPutLawActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:=TreeView.Items.Count>0;
end;

procedure TPDF2TreeMainForm.PrevActionExecute(Sender: TObject);
begin
  PdfControl.GotoPrevPage;
end;

procedure TPDF2TreeMainForm.PrevActionUpdate(Sender: TObject);
begin
  with (Sender as TAction) do
  begin
    Enabled:=TreeView.Items.Count>1;
    if Enabled then
      case PdfControl.ScaleMode of
        smFitWidth: FitWidthAction.Checked:=True;
        smFitHeight: FitHeightAction.Checked:=True;
      else FitAutoAction.Checked:=True;
      end;
  end;
end;

function TPDF2TreeMainForm.RenderPageAsImage(Page: TPdfPage;
  const SavePath: string): Boolean;
// ページ全体を1枚の画像としてレンダリングして保存する
var
  Bmp: TBitmap;
  Png: TPngImage;
  Scale: Double;
  PixelWidth, PixelHeight: Integer;
begin
  Result := False;
  // 解像度スケール（1.0だと粗いため、2.0～3.0を推奨。大きくするほど高画質・大容量になる）
  Scale := 2.0;

  PixelWidth := Round(Page.Width * Scale);
  PixelHeight := Round(Page.Height * Scale);

  Bmp := TBitmap.Create;
  try
    Bmp.PixelFormat := pf32bit;
    Bmp.Width := PixelWidth;
    Bmp.Height := PixelHeight;

    // 背景を白でクリア（透過PDF対策）
    Bmp.Canvas.Brush.Color := clWhite;
    Bmp.Canvas.FillRect(Rect(0, 0, PixelWidth, PixelHeight));

    // ページをビットマップに描画 (PdfiumCoreの機能)
    Page.Draw(Bmp.Canvas.Handle, 0, 0, PixelWidth, PixelHeight);

    Png := TPngImage.Create;
    try
      Png.Assign(Bmp);
      ForceDirectories(ExtractFilePath(SavePath));
      Png.SaveToFile(SavePath);
      Result := True;
    finally
      Png.Free;
    end;
  finally
    Bmp.Free;
  end;
end;

procedure TPDF2TreeMainForm.TraverseBookmark(DocHandle: FPDF_DOCUMENT;
  Bookmark: FPDF_BOOKMARK; ParentNode: TTreeNode);
var
  TitleLen: Cardinal;
  Buffer: TBytes;
  TitleStr: string;
  Dest: FPDF_DEST;
  Action: FPDF_ACTION;
  PageIndex: Integer;
  CurrentNode: TTreeNode;
  ChildBookmark: FPDF_BOOKMARK;
  NextSibling: FPDF_BOOKMARK;
begin
  while Bookmark <> nil do
  begin
    // 1. タイトルの取得 (UTF-16LE)
    TitleLen := FPDFBookmark_GetTitle(Bookmark, nil, 0);
    if TitleLen > 2 then // Null終端(2バイト)より大きい場合
    begin
      SetLength(Buffer, TitleLen);
      FPDFBookmark_GetTitle(Bookmark, @Buffer[0], TitleLen);
      // バイト長から文字数へ変換 (Null終端分を引く)
      SetString(TitleStr, PWideChar(@Buffer[0]), (TitleLen div 2) - 1);
    end
    else
      TitleStr := 'No Title';

    // 2. リンク先ページ番号の取得
    PageIndex := -1;
    Dest := FPDFBookmark_GetDest(DocHandle, Bookmark);

    // Destが直接設定されていない場合、Action経由でDestを取得する（PDFの仕様による差異を吸収）
    if Dest = nil then
    begin
      Action := FPDFBookmark_GetAction(Bookmark);
      if Action <> nil then
        Dest := FPDFAction_GetDest(DocHandle, Action);
    end;

    if Dest <> nil then
      PageIndex := FPDFDest_GetDestPageIndex(DocHandle, Dest);

    // 3. ツリービューにノードを追加 (PageIndexは0ベースなので表示時は+1する)
    CurrentNode := TreeView.Items.AddChild(ParentNode, TitleStr + ' (Page: ' + IntToStr(PageIndex + 1) + ')');
    // DataプロパティにPageIndexをキャストして保存
    CurrentNode.Data := Pointer(PageIndex);
    // 4. 子ノードが存在すれば再帰呼び出し
    ChildBookmark := FPDFBookmark_GetFirstChild(DocHandle, Bookmark);
    if ChildBookmark <> nil then
      TraverseBookmark(DocHandle, ChildBookmark, CurrentNode);

    // 5. 次の兄弟ノードへ移動
    Bookmark := FPDFBookmark_GetNextSibling(DocHandle, Bookmark);
  end;
end;
procedure TPDF2TreeMainForm.TreeViewClick(Sender: TObject);
var
  PageIndex: Integer;
begin
  if TreeView.Selected = nil then Exit;

  // PointerからIntegerへキャストして復元
  PageIndex := Integer(TreeView.Selected.Data);

  // リンク先が設定されていないノード（親カテゴリ名のみ等）は -1 になる想定
  if PageIndex >= 0 then
  begin
    // ビューアのページを移動
    PdfControl.PageIndex := PageIndex;

    // 右ペイン（Memo等）にテキストを抽出して表示する場合の例
    // ※TPdfControl.Document.Pages[Index].Text で取得可能
//    Memo1.Text := GetPageText(PageIndex);
  {$IFDEF DEBUG}
    DebugMemo.Lines.Add(IntToStr(PageIndex));
  {$ENDIF}
  end;
end;

procedure TPDF2TreeMainForm.WndProc(var Message: TMessage);
begin
  // メニューが非表示(nil)の状態で WM_COMMAND が届いた場合の救済処理
  if (Message.Msg = WM_COMMAND) and (Menu = nil) and Assigned(MainMenu) then
  begin
    // メニューからのコマンドである条件 (lParam = 0, HIWORD(wParam) = 0)
    if (Message.LParam = 0) and (HIWORD(Message.WParam) = 0) then
    begin
      // MainMenu1 に直接コマンドをディスパッチして実行させる
      if MainMenu.DispatchCommand(LOWORD(Message.WParam)) then
      begin
        Message.Result := 0;
        Exit;
      end;
    end;
  end;

  inherited;

  // メニューループ（操作状態）から抜けた瞬間に即座にメニューを隠す
  if Message.Msg = WM_EXITMENULOOP then
  begin
    Menu := nil;
  end;
end;

end.
