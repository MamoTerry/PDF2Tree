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
  NewCtrls, SysCtrls,//「Delphi3Q&A150選」に付属していたコンポーネント`TFileDrop` `TSingleInstance`
  CuteSplt, //TSplitter から作成されたフリーコンポーネント`TCuteSplitter`
  Vcl.Imaging.pngimage,
  System.JSON,
  System.Generics.Collections, System.Generics.Defaults,
  System.StrUtils, System.IOUtils, System.Math,
  Vcl.ComCtrls, System.Actions, Vcl.ActnList, System.ImageList,
  Vcl.ImgList, Vcl.ToolWin, Vcl.ExtCtrls, Vcl.StdCtrls,
  Vcl.Menus, Vcl.AppEvnts;

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
    MainActionList: TActionList;
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
    EditNodeImageList: TImageList;
    EditNodeActionList: TActionList;
    MovePrevAction: TAction;
    MoveNextAction: TAction;
    MoveUpAction: TAction;
    MoveDownAction: TAction;
    EditNodeMenu: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    U1: TMenuItem;
    N9: TMenuItem;
    DeleteNodeAction: TAction;
    N10: TMenuItem;
    E1: TMenuItem;
    LeftToolBar: TToolBar;
    ToolButton12: TToolButton;
    ToolButton13: TToolButton;
    ToolButton14: TToolButton;
    ToolButton15: TToolButton;
    ToolButton16: TToolButton;
    EditNodePopupMenu: TPopupMenu;
    P1: TMenuItem;
    N11: TMenuItem;
    U2: TMenuItem;
    N12: TMenuItem;
    N13: TMenuItem;
    E2: TMenuItem;
    AddBookmarkAction: TAction;
    ToolButton17: TToolButton;
    A1: TMenuItem;
    N14: TMenuItem;
    PdfControlPopupMenu: TPopupMenu;
    A2: TMenuItem;
    N15: TMenuItem;
    SaveTreeAction: TAction;
    ReadTreeAction: TAction;
    N16: TMenuItem;
    N17: TMenuItem;
    ToolButton18: TToolButton;
    ToolButton19: TToolButton;
    EditTitleAction: TAction;
    ToolButton20: TToolButton;
    N18: TMenuItem;
    BookMarkEditModeMenu: TMenuItem;
    StatusBar: TStatusBar;
    ApplicationEvents: TApplicationEvents;
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
    procedure MovePrevActionUpdate(Sender: TObject);
    procedure MoveNextActionUpdate(Sender: TObject);
    procedure MoveUpActionUpdate(Sender: TObject);
    procedure MoveDownActionUpdate(Sender: TObject);
    procedure MovePrevActionExecute(Sender: TObject);
    procedure DeleteNodeActionExecute(Sender: TObject);
    procedure DeleteNodeActionUpdate(Sender: TObject);
    procedure AddBookmarkActionUpdate(Sender: TObject);
    procedure FitWidthActionUpdate(Sender: TObject);
    procedure AddBookmarkActionExecute(Sender: TObject);
    procedure SaveTreeActionUpdate(Sender: TObject);
    procedure ReadTreeActionExecute(Sender: TObject);
    procedure SaveTreeActionExecute(Sender: TObject);
    procedure EditTitleActionExecute(Sender: TObject);
    procedure EditTitleActionUpdate(Sender: TObject);
    procedure TreeViewEdited(Sender: TObject; Node: TTreeNode; var S: string);
    procedure TreeViewDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure TreeViewDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure BookMarkEditModeMenuClick(Sender: TObject);
    procedure ApplicationEventsHint(Sender: TObject);
  private
    { Private 宣言 }
    PdfControl: TPdfControl;
    FTargetPDFPath:string;
    FImageCounter: Integer;

    ExcludeSmallImages:Boolean;
    LinkTagsLaw:0..1;
    LinkStartTag,LinkEndTag:string;
    JsonFileName: string;
    TmpCount:integer;
    TreeDataFileName:string;
    TreeViewModified,
    FBookMarkEditMode:Boolean;
    procedure MoveNodeData(Dest:integer;Tree:TTreeView);
    procedure AddNewNode(Title:string;PageIndex:integer);
//マウスアップイベント
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
    procedure LoadTreeData(FileName:string);
    procedure SaveTreeData(FileName:string);
// 指定範囲のページテキストを取得する関数
    function GetPageTextRange(StartPage, EndPage: Integer; const OutputTextPath: string): string;
// 呼び出し元（PDF読み込み完了後に実行）
    procedure LoadBookmarksToTree;
// 再帰的なしおり探索処理
    procedure TraverseBookmark(DocHandle: FPDF_DOCUMENT; Bookmark: FPDF_BOOKMARK;
                ParentNode: TTreeNode);
    procedure SetBookMarkEditMode(const Value: Boolean);

    procedure WndProc(var Message: TMessage); override;
    procedure PdfControlPageChange(Sender: TObject);
  public
    { Public 宣言 }
    property BookMarkEditMode: Boolean read FBookMarkEditMode write SetBookMarkEditMode
      default False;
  end;

var
  PDF2TreeMainForm: TPDF2TreeMainForm;

implementation

{$R *.dfm}

uses AboutFormUnit, OptionsFormUnit;

const
  TreeDataFileExt='.p2t';

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

procedure TPDF2TreeMainForm.AddBookmarkActionExecute(Sender: TObject);
var
  SelectedText, Title: string;
begin
  // 目次作成モードでなければ何もしない（またはアクション自体をDisableにする）
  if not FBookMarkEditMode then Exit;
  if PdfControl.Document = nil then Exit;

  // 選択テキストを取得し、前後の空白や改行を除去
  SelectedText := Trim(PdfControl.SelText);
  Title := SelectedText;

  // ダイアログを表示（初期値として選択テキストを渡す）
  if not InputQuery('新しいブックマーク', 'タイトル:', Title) then Exit;

  if Trim(Title) = '' then
  begin
    ShowMessage('タイトルを入力してください。');
    Exit;
  end;

  // ノードの追加
  AddNewNode(Title, PdfControl.PageIndex);
end;

procedure TPDF2TreeMainForm.AddBookmarkActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:=FBookMarkEditMode and
                               (PdfControl.Document <> nil) and
                               (FTargetPDFPath<>'');
end;

procedure TPDF2TreeMainForm.AddNewNode(Title: string;PageIndex:integer);
var
  Node: TTreeNode;
begin
  Node:=TreeView.Selected;
  Node:=TreeView.Items.Add(Node,Title);
  Node.Data := Pointer(PageIndex);
  Node.Selected:=True;
  TreeViewModified:=True;
end;

procedure TPDF2TreeMainForm.ApplicationEventsHint(Sender: TObject);
begin
  StatusBar.Panels[1].Text := Application.Hint;
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
  ShowMessage(FTargetPDFPath);


{  if TreeView.Items.Count = 0 then exit;
  Node := TreeView.Items[0];
  ShowMessage(Node.Text);}

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

procedure TPDF2TreeMainForm.DeleteNodeActionExecute(Sender: TObject);
var
  Idx:integer;
  Node:TTreeNode;
begin
  if TreeView.IsEditing then exit;
  Idx:=TreeView.Selected.Index;
  if MessageDlg('削除していいですか？',mtConfirmation,mbOkCancel,0)=mrOk then
    TreeView.Selected.Delete else exit;
  TreeViewModified:=True;
  if TreeView.Items.Count=0 then exit;
  Node:=TreeView.Items[0];
  while Node <> nil do
  begin
    if Node.Level=Idx then
    begin
      Node.Selected:=True;
      exit;
    end;
    Node:=Node.GetNext;
  end;
end;

procedure TPDF2TreeMainForm.DeleteNodeActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:=FBookMarkEditMode and
                               (TreeView.Selected<>nil)and
                               (not TreeView.IsEditing);
end;

procedure TPDF2TreeMainForm.EditTitleActionExecute(Sender: TObject);
begin
  TreeView.Selected.EditText;
end;

procedure TPDF2TreeMainForm.EditTitleActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:=FBookMarkEditMode and
                               (TreeView.Selected<>nil)and
                               (not TreeView.IsEditing);
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

{      P := Pos(' (Page: ', TitleStr);// (Page: x)の付加を中止
      if P > 0 then
        TitleStr := Copy(TitleStr, 1, P - 1);}

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
type
  TImageInfo = record
    Bmp: TBitmap;
    Left, Bottom, Right, Top: Single;
    Width, Height: Single;
  end;
var
  ImageList: TList<TImageInfo>;
  MergeGroup: TList<TBitmap>;
  ImgInfo, PrevImg: TImageInfo;
  ObjCount, i: Integer;
  PageObj: FPDF_PAGEOBJECT;
  SavePath, ImageName: string;

  // ---------------------------------------------------------------------------
  // ローカル関数1: コンテナ再帰探索＆画像情報リスト化
  // ---------------------------------------------------------------------------
  procedure ProcessObject(TargetObj: FPDF_PAGEOBJECT);
  var
    ObjType, j, ChildCount: Integer;
    ChildObj: FPDF_PAGEOBJECT;
    BmpHandle: FPDF_BITMAP;
    ImgWidth, ImgHeight, ImgStride, ImgFmt, Y: Integer;
    ImgBuffer: Pointer;
    Src, Dest: PByte;
    Bmp: TBitmap;
    Left, Bottom, Right, Top: Single;
    Info: TImageInfo;
  begin
    ObjType := FPDFPageObj_GetType(TargetObj);

    if ObjType = 3 then // 3 = FPDF_PAGEOBJ_IMAGE
    begin
      if FPDFPageObj_GetBounds(TargetObj, Left, Bottom, Right, Top) = 0 then Exit;

      // ノイズフィルタリング（小さすぎる画像は除外）
      if (Abs(Right - Left) < 50.0) or (Abs(Top - Bottom) < 50.0) then Exit;

      BmpHandle := FPDFImageObj_GetBitmap(TargetObj);
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
            if (ImgFmt = 3) or (ImgFmt = 4) then Bmp.PixelFormat := pf32bit
            else if ImgFmt = 2 then Bmp.PixelFormat := pf24bit
            else
            begin
              Bmp.Free;
              Exit;
            end;

            Bmp.Width := ImgWidth;
            Bmp.Height := ImgHeight;
            Src := ImgBuffer;
            for Y := 0 to ImgHeight - 1 do
            begin
              Dest := Bmp.ScanLine[Y];
              Move(Src^, Dest^, ImgStride);
              Inc(Src, ImgStride);
            end;

            // リストに追加
            Info.Bmp := Bmp;
            Info.Left := Left;
            Info.Bottom := Bottom;
            Info.Right := Right;
            Info.Top := Top;
            Info.Width := Abs(Right - Left);
            Info.Height := Abs(Top - Bottom);
            ImageList.Add(Info);
          end;
        finally
          FPDFBitmap_Destroy(BmpHandle);
        end;
      end;
    end
    else if ObjType = 5 then // 5 = FPDF_PAGEOBJ_FORM (コンテナ)
    begin
      ChildCount := FPDFFormObj_CountObjects(TargetObj);
      for j := 0 to ChildCount - 1 do
      begin
        ChildObj := FPDFFormObj_GetObject(TargetObj, j);
        ProcessObject(ChildObj); // 再帰呼び出し
      end;
    end;
  end;

  // ---------------------------------------------------------------------------
  // ローカル関数2: グループ化された画像を結合して保存し、パスを返す
  // ---------------------------------------------------------------------------
  function SaveMergedGroup(const Group: TList<TBitmap>): string;
  var
    MergedBmp: TBitmap;
    TotalHeight, MaxWidth, k, CurrentY: Integer;
    Png: TPngImage;
    SPath, IName: string;
  begin
    Result := '';
    if Group.Count = 0 then Exit;

    TotalHeight := 0;
    MaxWidth := 0;
    for k := 0 to Group.Count - 1 do
    begin
      TotalHeight := TotalHeight + Group[k].Height;
      MaxWidth := Max(MaxWidth, Group[k].Width);
    end;

    MergedBmp := TBitmap.Create;
    try
      MergedBmp.PixelFormat := pf32bit;
      MergedBmp.Width := MaxWidth;
      MergedBmp.Height := TotalHeight;
      MergedBmp.Canvas.Brush.Color := clWhite;
      MergedBmp.Canvas.FillRect(Rect(0, 0, MaxWidth, TotalHeight));

      CurrentY := 0;
      for k := 0 to Group.Count - 1 do
      begin
        MergedBmp.Canvas.Draw(0, CurrentY, Group[k]);
        CurrentY := CurrentY + Group[k].Height;
      end;

      Inc(FImageCounter);
      IName := System.SysUtils.Format('img_%.3d.png', [FImageCounter]);
      SPath := GetSaveImagePath(OutputTextPath, IName);
      ForceDirectories(ExtractFilePath(SPath));

      Png := TPngImage.Create;
      try
        Png.Assign(MergedBmp);
        Png.SaveToFile(SPath);
        Result := SPath;
      finally
        Png.Free;
      end;
    finally
      MergedBmp.Free;
    end;
  end;

// -----------------------------------------------------------------------------
// ExtractImagesFromPage メイン処理
// -----------------------------------------------------------------------------
begin
  Result := '';
  ObjCount := FPDFPage_CountObjects(Page.Handle);
  if ObjCount = 0 then Exit;

  ImageList := TList<TImageInfo>.Create;
  MergeGroup := TList<TBitmap>.Create;
  try
    // 1. ページ内の全画像をリスト化（コンテナ内含む）
    for i := 0 to ObjCount - 1 do
    begin
      PageObj := FPDFPage_GetObject(Page.Handle, i);
      ProcessObject(PageObj);
    end;

    if ImageList.Count = 0 then Exit;

    // 2. Y座標（Top）の降順（上から下）でソート
    ImageList.Sort(TComparer<TImageInfo>.Construct(
      function(const L, R: TImageInfo): Integer
      begin
        if L.Top > R.Top then Result := -1
        else if L.Top < R.Top then Result := 1
        else Result := 0;
      end));

    // 3. 結合判定と保存
    PrevImg := ImageList[0];
    MergeGroup.Add(PrevImg.Bmp);

    for i := 1 to ImageList.Count - 1 do
    begin
      ImgInfo := ImageList[i];

      // 結合条件: 幅が一致 ＆ X座標が一致 ＆ Y座標が連続
      if (Abs(PrevImg.Width - ImgInfo.Width) <= 1.0) and
         (Abs(PrevImg.Left - ImgInfo.Left) <= 1.0) and
         (Abs(PrevImg.Bottom - ImgInfo.Top) <= 1.0) then
      begin
        MergeGroup.Add(ImgInfo.Bmp);
      end
      else
      begin
        // 条件を満たさないので、現在のグループを保存してタグを生成
        SavePath := SaveMergedGroup(MergeGroup);
        if SavePath <> '' then
          Result := Result + MakeImageTag(SavePath, OutputTextPath) + sLineBreak;

        MergeGroup.Clear;
        MergeGroup.Add(ImgInfo.Bmp);
      end;
      PrevImg := ImgInfo;
    end;

    // 最後のグループを保存してタグを生成
    if MergeGroup.Count > 0 then
    begin
      SavePath := SaveMergedGroup(MergeGroup);
      if SavePath <> '' then
        Result := Result + MakeImageTag(SavePath, OutputTextPath) + sLineBreak;
    end;

  finally
    // メモリ解放
    for i := 0 to ImageList.Count - 1 do
      ImageList[i].Bmp.Free;
    ImageList.Free;
    MergeGroup.Free;
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

procedure TPDF2TreeMainForm.FitWidthActionUpdate(Sender: TObject);
begin
  with (Sender as TAction) do
  begin
    Enabled:=PdfControl.PageCount>0;
    if Enabled then
      case PdfControl.ScaleMode of
        smFitWidth: FitWidthAction.Checked:=True;
        smFitHeight: FitHeightAction.Checked:=True;
      else FitAutoAction.Checked:=True;
      end;
  end;
end;

procedure TPDF2TreeMainForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
var
  Mess:string;
  SaveAs:Boolean;
begin
  SaveAs:=not TFile.Exists(TreeDataFileName);
  if SaveAs then
    Mess:='ブックマークが更新されています'+#13#10+'ブックマークファイルを保存しますか？' else
      Mess:='ブックマークが更新されています'+#13#10+'ブックマークファイルを上書きしますか？';
  if TreeViewModified then
    case MessageDlg(Mess,
      mtConfirmation,[mbYes, mbNo, mbCancel] ,0) of
      mrYes:    if SaveAs then
                  SaveTreeAction.OnExecute(SaveTreeAction) else
                    SaveTreeData(TreeDataFileName);
      mrCancel:
                begin
                  CanClose:=False;
                  exit;
                end;
    else TreeViewModified:=False;
    end;
  if TreeViewModified then CanClose:=False;
  if CanClose then JsonWrite;
end;

procedure TPDF2TreeMainForm.FormCreate(Sender: TObject);
var
  S:string;
begin
  {$IFDEF DEBUG}
    DebugMenu.Visible:=True;
    BookMarkEditModeMenu.Visible:=True;
  {$ENDIF}
  Caption:=Application.Title;
  PdfControl := TPdfControl.Create(Self);
  PdfControl.Parent:=Self;
  PdfControl.Align:=alClient;
  PdfControl.ChangePageOnMouseScrolling:=True;
  PdfControl.OnPageChange:=PdfControlPageChange;

  AboutMenu.Caption:=ExtractFileName(ChangeFileExt(Application.ExeName,''))+' について(&A)';

//初期値
  ExcludeSmallImages:=True;


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
  PageText, ImageTags: string;
begin
  Result := '';
  if (StartPage < 0) or (StartPage > EndPage) then Exit;

  for i := StartPage to EndPage do
  begin
    Page := PdfControl.Document.Pages[i];

    // 1. テキストの抽出
    TotalChars := Page.GetCharCount;
    if TotalChars > 0 then
      PageText := Trim(Page.ReadText(0, TotalChars))
    else
      PageText := '';

    // 2. 画像の抽出（コンテナ再帰探索版）
    ImageTags := ExtractImagesFromPage(Page, OutputTextPath);

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
// ページ内に画像オブジェクトが存在するか判定する（コンテナ内部も再帰探索）

  // Form XObject（コンテナ）の中身を再帰的に調べるローカル関数
  function CheckFormContainer(FormObj: FPDF_PAGEOBJECT): Boolean;
  var
    i, Count: Integer;
    ChildObj: FPDF_PAGEOBJECT;
    ObjType: Integer;
  begin
    Result := False;
    Count := FPDFFormObj_CountObjects(FormObj);
    for i := 0 to Count - 1 do
    begin
      ChildObj := FPDFFormObj_GetObject(FormObj, i);
      ObjType := FPDFPageObj_GetType(ChildObj);

      if ObjType = 3 then // 3 = FPDF_PAGEOBJ_IMAGE (画像を発見)
        Exit(True)
      else if ObjType = 5 then // 5 = FPDF_PAGEOBJ_FORM (さらに箱が入っている場合)
      begin
        if CheckFormContainer(ChildObj) then
          Exit(True);
      end;
    end;
  end;

var
  ObjCount, i: Integer;
  PageObj: FPDF_PAGEOBJECT;
  ObjType: Integer;
begin
  Result := False;
  ObjCount := FPDFPage_CountObjects(Page.Handle);
  for i := 0 to ObjCount - 1 do
  begin
    PageObj := FPDFPage_GetObject(Page.Handle, i);
    ObjType := FPDFPageObj_GetType(PageObj);

    if ObjType = 3 then // 直下に画像がある場合
      Exit(True)
    else if ObjType = 5 then // コンテナ（Form XObject）の場合、中身を調べる
    begin
      if CheckFormContainer(PageObj) then
        Exit(True);
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
      ExcludeSmallImages := JSON.GetValue<Boolean>('ExcludeSmallImages', ExcludeSmallImages);
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
    JSON.AddPair('ExcludeSmallImages', ExcludeSmallImages);

    // 3. JSONオブジェクトを文字列化し、ファイルに保存する
    // Format(2) を使用することで、インデントされた人間が読みやすい形式で保存される
    TFile.WriteAllText(JsonFileName, JSON.Format(2), TEncoding.UTF8);
  finally
    JSON.Free;
  end;
end;

procedure TPDF2TreeMainForm.BookMarkEditModeMenuClick(Sender: TObject);
begin
  BookMarkEditMode:=True;
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
    BookMarkEditMode:=True;
    Exit;
  end;
  BookMarkEditMode:=False;

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
  TreeView.Items.Clear;
  TreeViewModified:=False;
  TreeDataFileName:='';
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

procedure TPDF2TreeMainForm.LoadTreeData(FileName: string);
var
  JsonText: string;
  JSON: TJSONObject;
  JsonArray: TJSONArray;
  JsonItem: TJSONObject;
  i, Page, Level: Integer;
  PDFFileName,
  Title: string;
  ParentNode, NewNode: TTreeNode;
  LastNodes: array of TTreeNode; // 各階層の最後のノードを記憶する配列
begin
  if not TFile.Exists(FileName) then Exit;

  JsonText := TFile.ReadAllText(FileName, TEncoding.UTF8);
  JSON := TJSONObject.ParseJSONValue(JsonText) as TJSONObject;

  if Assigned(JSON) then
  begin
    try
      PDFFileName:=Json.GetValue<string>('PdfFileName', ExtractFileName(FTargetPDFPath));
      if CompareText(PDFFileName,ExtractFileName(FTargetPDFPath))<>0 then
        if MessageDlg('開いているPDF'+#13#10+
                      '『'+ExtractFileName(FTargetPDFPath)+'』'+#13#10#13#10+
                      'と、読み込もうとしている目次データ'+#13#10+
                      '『'+PDFFileName+'』'+#13#10#13#10+
                      'の名前が違いますが、本当に読み込みますか？',mtConfirmation,mbOkCancel,0)<>mrOk then exit;

      JsonArray := JSON.GetValue<TJSONArray>('Bookmarks');
      if not Assigned(JsonArray) then Exit;

      TreeView.Items.BeginUpdate;
      try
        TreeView.Items.Clear;
        SetLength(LastNodes, 100); // 最大100階層まで対応（通常は数階層で十分）

        for i := 0 to JsonArray.Count - 1 do
        begin
          JsonItem := JsonArray.Items[i] as TJSONObject;

          // 値の取得（キーが無い場合のデフォルト値も指定）
          Title := JsonItem.GetValue<string>('Title', 'No Title');
          Page := JsonItem.GetValue<Integer>('Page', 0);
          Level := JsonItem.GetValue<Integer>('Level', 0);

          // 安全対策：想定外に深い階層が来た場合は配列を拡張
          if Level >= Length(LastNodes) then
            SetLength(LastNodes, Level + 50);

          // 親ノードの決定
          if Level = 0 then
            ParentNode := nil // ルート階層
          else
            ParentNode := LastNodes[Level - 1]; // 1つ上の階層の最後のノードが親になる

          // ノードの追加とデータの復元
          NewNode := TreeView.Items.AddChild(ParentNode, Title);
          NewNode.Data := Pointer(Page);

          // 現在の階層の「最後のノード」を更新
          LastNodes[Level] := NewNode;
        end;

        // 読み込み完了後、すべてのノードを展開状態にする（お好みで）
        TreeView.FullExpand;
      finally
        TreeView.Items.EndUpdate;
      end;

      // 読み込み完了フラグのクリア
      TreeViewModified := False;
      TreeDataFileName:=FileName;
    finally
      JSON.Free;
    end;
  end;
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

procedure TPDF2TreeMainForm.MoveDownActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:=FBookMarkEditMode and
                               (TreeView.Selected<>nil)and
                               (TreeView.Selected.getPrevSibling<>nil);
end;

procedure TPDF2TreeMainForm.MoveNextActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:=FBookMarkEditMode and
                               (TreeView.Selected<>nil)and
                               (TreeView.Selected.getNextSibling<>nil);
end;

procedure TPDF2TreeMainForm.MoveNodeData(Dest: integer; Tree: TTreeView);
var
  N1, N2: TTreeNode;
begin
  if Tree.Selected = nil then Exit;

  with Tree do
  begin
    Items.BeginUpdate; // 描画停止（ちらつき防止）
    try
      case Dest of
        1: // ↑ (前の兄弟の前に挿入)
          begin
            N1 := Selected.getPrevSibling;
            if N1 <> nil then
              Selected.MoveTo(N1, naInsert);
          end;
        2: // ↓ (次の兄弟の後ろに挿入)
          begin
            N1 := Selected.getNextSibling;
            if N1 <> nil then
            begin
              N2 := N1.getNextSibling;
              if N2 <> nil then
                Selected.MoveTo(N2, naInsert)
              else
              begin
                if N1.Parent <> nil then
                  Selected.MoveTo(N1.Parent, naAddChild)
                else
                  Selected.MoveTo(N1, naAdd);
              end;
            end;
          end;
        3: // ← (親の次の兄弟の前に挿入 ＝ 階層を浅くする)
          begin
            if Selected.Parent <> nil then // ★親がnilでない（ルート階層ではない）ことの確認が必須
            begin
              N1 := Selected.Parent.GetNextSibling;
              if N1 <> nil then
                Selected.MoveTo(N1, naInsert)
              else
                Selected.MoveTo(Selected.Parent, naAdd); // 親と同じ階層の最後に追加
            end;
          end;
        4: // → (前の兄弟の子ノードの最後に追加 ＝ 階層を深くする)
          begin
            N1 := Selected.getPrevSibling;
            if N1 <> nil then
              Selected.MoveTo(N1, naAddChild);
          end;
      end;
    finally
      Items.EndUpdate;
    end;
  end;
end;

procedure TPDF2TreeMainForm.MovePrevActionExecute(Sender: TObject);
begin
  MoveNodeData((Sender as TAction).Tag,TreeView);
  TreeViewModified:=True;
end;

procedure TPDF2TreeMainForm.MovePrevActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:=FBookMarkEditMode and
                               (TreeView.Selected<>nil)and
                               (TreeView.Selected.getPrevSibling<>nil);
end;

procedure TPDF2TreeMainForm.MoveUpActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:=FBookMarkEditMode and
                               (TreeView.Selected<>nil)and
                               (TreeView.Selected.Level<>0);
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
      ExcludeSmallImagesCheckBox.Checked:=ExcludeSmallImages;

      ShowModal;
      if ModalResult<>mrOk then exit;

      LinkTagsLaw:=LinkTagsRadioGroup.ItemIndex;
      LinkStartTag:=LinkStartTagEdit.Text;
      LinkEndTag:=LinkEndTagEdit.Text;
      ExcludeSmallImages:=ExcludeSmallImagesCheckBox.Checked;
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
      if TFile.Exists(FTargetPDFPath) then FileName:=ExtractFileName(ChangeFileExt(FTargetPDFPath,'.txt'));
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

procedure TPDF2TreeMainForm.PdfControlPageChange(Sender: TObject);
begin
  StatusBar.Panels[0].Text := Format('%d/%d ページ',[PdfControl.PageIndex+1,PdfControl.PageCount]);
end;

procedure TPDF2TreeMainForm.PrevActionExecute(Sender: TObject);
begin
  PdfControl.GotoPrevPage;
end;

procedure TPDF2TreeMainForm.PrevActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:=PdfControl.PageCount>1;
end;

procedure TPDF2TreeMainForm.ReadTreeActionExecute(Sender: TObject);
begin
  if TreeViewModified then
    if MessageDlg('更新されていますが読み込みなおしますか？',
      mtConfirmation,mbOkCancel,0)<>mrOk then exit;
  with TOpenDialog.Create(Self) do
  begin
    try
      Options:=[ofHideReadOnly,//［読み取り専用ファイルとして開く］チェックボックスを削除
                ofEnableSizing,//ダイアログサイズを変更できる
                ofFileMustExist//存在しないファイルを選択エラー
                ];
      Title:='ブックマークファイル を開く';
      Filter:='ブックマークファイル|*'+TreeDataFileExt+'|全てのファイル|*.*';
      FileName:=ExtractFileName(ChangeFileExt(FTargetPDFPath,TreeDataFileExt));
      if not Execute then exit;
      LoadTreeData(FileName);
    finally
      Free;
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

procedure TPDF2TreeMainForm.SaveTreeActionExecute(Sender: TObject);
begin
  with TSaveDialog.Create(Self) do
  begin
    try
      Title:='ブックマークの保存';
      Filter:='ブックマークファイル|*'+TreeDataFileExt+'|All Files|*.*';
      FileName:=ExtractFileName(ChangeFileExt(FTargetPDFPath,TreeDataFileExt));
      Options:=[ofOverwritePrompt,//既存のファイルを上書きするかどうか尋ねる
                ofPathMustExist,//存在しないパスにエラーメッセージ
                ofNoReadOnlyReturn,//読み出し専用のファイルを選択エラー
                ofHideReadOnly,//［読み取り専用］チェックボックスを削除
                ofEnableSizing];//ダイアログサイズを変更できる
      if not Execute then exit;
  //★ここ★が DefaultExt 相当
      if ExtractFileExt(FileName)='' then
        FileName:=ChangeFileExt(FileName,TreeDataFileExt);
      SaveTreeData(FileName);
    finally
      Free;
    end;
  end;
end;

procedure TPDF2TreeMainForm.SaveTreeActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled:=FBookMarkEditMode and
                               (TreeView.Items.Count>0);
end;

procedure TPDF2TreeMainForm.SaveTreeData(FileName: string);
var
  JSON: TJSONObject;
  JsonArray: TJSONArray;
  JsonItem: TJSONObject;
  Node: TTreeNode;
  i: Integer;
begin
  if TreeView.Items.Count = 0 then Exit;

  JSON := TJSONObject.Create;
  try
    JSON.AddPair('PdfFileName', ExtractFileName(FTargetPDFPath));
    JsonArray := TJSONArray.Create;

    for i := 0 to TreeView.Items.Count - 1 do
    begin
      Node := TreeView.Items[i];
      JsonItem := TJSONObject.Create;
      JsonItem.AddPair('Title', Node.Text);
      JsonItem.AddPair('Page', TJSONNumber.Create(Integer(Node.Data)));
      JsonItem.AddPair('Level', TJSONNumber.Create(Node.Level));
      JsonArray.AddElement(JsonItem);
    end;
    JSON.AddPair('Bookmarks', JsonArray);

    try
      // ファイルへ書き込み
      TFile.WriteAllText(FileName, JSON.Format(2), TEncoding.UTF8);

      // 書き込みが成功した場合のみフラグをクリアし、ファイル名を記憶する
      TreeViewModified := False;
      TreeDataFileName := FileName;
    except
      on E: Exception do
      begin
        ShowMessage('ファイルの保存に失敗しました。' + sLineBreak + E.Message);
        // 例外を握りつぶすことで、アプリがクラッシュするのを防ぐ。
        // TreeViewModified は True のままなので、Form.OnCloseQuery から呼ばれた場合、終了はキャンセルされる。
      end;
    end;
  finally
    JSON.Free;
  end;
end;

procedure TPDF2TreeMainForm.SetBookMarkEditMode(const Value: Boolean);
begin
  if FBookMarkEditMode = Value then exit;
  FBookMarkEditMode := Value;
  LeftToolBar.Visible:=FBookMarkEditMode;
  EditNodeMenu.Visible:=FBookMarkEditMode;
  if FBookMarkEditMode then
  begin
    TreeView.PopupMenu:=EditNodePopupMenu;
    TreeView.Color:=clCream;
    PdfControl.PopupMenu:=PdfControlPopupMenu;
    LeftToolBar.Hint:='目次作成モード';
  end else
  begin
    TreeView.PopupMenu:=nil;
    TreeView.Color:=clWindow;
    PdfControl.PopupMenu:=nil;
    LeftToolBar.Hint:='';
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

    // 3. ツリービューにノードを追加 (PageIndexは0ベースなので表示時は+1する)// (Page: x)の付加を中止
    CurrentNode := TreeView.Items.AddChild(ParentNode, TitleStr{ + ' (Page: ' + IntToStr(PageIndex + 1) + ')'});
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
  end;
end;

procedure TPDF2TreeMainForm.TreeViewDragDrop(Sender, Source: TObject; X,
  Y: Integer);
var
  TargetNode: TTreeNode;
begin
  TargetNode := TreeView.DropTarget;
  if (TargetNode = nil) or (TreeView.Selected = nil) then Exit;

  // Shiftキーが押されているか判定 (最上位ビットが立っているか)
  if GetKeyState(VK_SHIFT) < 0 then
  begin
    // Shiftキー押下時: ターゲットの子ノードとして追加
    TreeView.Selected.MoveTo(TargetNode, naAddChild);
  end
  else
  begin
    // 通常時: ターゲットの次の兄弟として挿入
    if TargetNode.GetNextSibling <> nil then
      TreeView.Selected.MoveTo(TargetNode.GetNextSibling, naInsert)
    else
      TreeView.Selected.MoveTo(TargetNode, naAdd); // 兄弟の最後
  end;

  TreeViewModified := True;
end;

procedure TPDF2TreeMainForm.TreeViewDragOver(Sender, Source: TObject; X,
  Y: Integer; State: TDragState; var Accept: Boolean);
var
  TargetNode: TTreeNode;
begin
  Accept := False;
  if Sender <> Source then Exit;
  if TreeView.Selected = nil then Exit;

  TargetNode := TreeView.GetNodeAt(X, Y);

  // ドロップ先が存在し、かつ「自分自身」や「自分の子孫」ではない場合のみ許可
  if (TargetNode <> nil) and (TargetNode <> TreeView.Selected) and
     (not TargetNode.HasAsParent(TreeView.Selected)) then
  begin
    Accept := True;
  end;
end;

procedure TPDF2TreeMainForm.TreeViewEdited(Sender: TObject; Node: TTreeNode;
  var S: string);
begin
//空文字ブックマークは不可とする
  if S='' then S:=TreeView.Selected.Text;
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
