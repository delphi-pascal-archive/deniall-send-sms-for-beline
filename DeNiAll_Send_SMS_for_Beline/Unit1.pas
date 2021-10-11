unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, ExtCtrls, Buttons, StdCtrls, XPMan, OleServer, WordXP,
  DB, ADODB, ImgList, Menus, CoolTrayIcon,UFunctions,Sockets, ActnList;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    ListView1: TListView;
    Panel3: TPanel;
    Splitter1: TSplitter;
    Panel4: TPanel;
    Panel5: TPanel;
    Label1: TLabel;
    Edit1: TEdit;
    Bevel1: TBevel;
    Panel6: TPanel;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    Bevel2: TBevel;
    SpeedButton3: TSpeedButton;
    Panel7: TPanel;
    SpeedButton4: TSpeedButton;
    Panel8: TPanel;
    Panel9: TPanel;
    StatusBar1: TStatusBar;
    RichEdit1: TRichEdit;
    Bevel3: TBevel;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    XPManifest1: TXPManifest;
    Splitter2: TSplitter;
    Panel10: TPanel;
    ListBox1: TListBox;
    Panel11: TPanel;
    WordApp: TWordApplication;
    ListBox2: TListBox;
    ListBox3: TListBox;
    WordDoc: TWordDocument;
    SpeedButton8: TSpeedButton;
    ADOConnection1: TADOConnection;
    ADOTable1: TADOTable;
    ADOTable1RN: TIntegerField;
    ADOTable1sName: TWideStringField;
    ADOTable1nIcon: TIntegerField;
    DataSource1: TDataSource;
    ImageList1: TImageList;
    ADOTable1sPhone: TWideStringField;
    CoolTrayIcon1: TCoolTrayIcon;
    PopupMenu1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    N6: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    ActionList1: TActionList;
    Action1: TAction;
    Action2: TAction;
    Action3: TAction;
    Action4: TAction;
    CheckBox1: TCheckBox;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    procedure SpeedButton5Click(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure N5Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure N1Click(Sender: TObject);
    procedure RichEdit1Change(Sender: TObject);
    procedure PopupMenu1Popup(Sender: TObject);
    procedure N6Click(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure SpeedButton7Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure Action1Execute(Sender: TObject);
    procedure Action2Execute(Sender: TObject);
    procedure Action3Execute(Sender: TObject);
    procedure Action4Execute(Sender: TObject);
    procedure CoolTrayIcon1BalloonHintClick(Sender: TObject);
    procedure N9Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  res:Boolean=false;
  CLI: TTcpClient;
  ConnectionData: TConnectionData;
  MES_MESSAGE_WILL_BE_SEND: string = 'Ваше сообщение отправлено';
  MES_SEND_MESSAGE_ERROR: string = 'Возникли ошибки в процессе отправки сообщения';
  MES_CANT_CONNECT_TO_SERVER: string = 'Ошибка'+nl+'Невозможно подключиться к серверу! Попробуйте ещё раз!';
implementation

{$R *.dfm}
uses Commctrl, Unit2, Unit3,mmsystem;

function ConnectToServer(): boolean;
begin
  CLI.RemoteHost:= ConnectionData.server;
  CLI.RemotePort:= ConnectionData.port;
  if not CLI.Connected then
    CLI.Open();
  Result:= CLI.Connected;
end;

function SendSMS(phone,msg: string; var resMessage: string): byte;
var header,content,trans,pref: string;
    n: integer;
begin
  Result:= SR_UNKNOWN_ERROR;
  Application.ProcessMessages();
  if not ConnectToServer then
  begin
    result:= SR_CANT_CONNECT;
    exit;
  end;

  pref:= GetPrefByNumber(phone,true);
  trans:= '';
  //формирование текста запроса
  //if not Form1.cb_translit.Checked then
  //  trans:= 'N';
  content:= 'number_sms=number_sms_send&termtype=G&translit='+trans+'&x=5&y=4&'+
    'prf='+pref+
    '&phone='+phone+
    '&message='+msg+
    '&count='+IntToStr(Length(msg))+
    '&B1=%CE%F2%EF%F0%E0%E2%E8%F2%FC&'+nl;
  header:= {POST http://www.beeonline.ru:80/servlet/send/sms HTTP/1.1}
  'POST http://www.beeonline.ru:80/servlet/send/sms HTTP/1.1'+nl+
  'Content-Type: application/x-www-form-urlencoded'+nl+
  'Content-Length: '+IntToStr(Length(content))+nl+
  'Cache-control: no-cache'+nl+
  'Proxy-Connection: keep-alive'+nl+
  'Host: www.beeonline.ru'+nl+
  'Accept: text/html, */*'+nl+
  'User-Agent: Mozilla/3.0 (compatible; Indy Library)'+nl;

  //отправка сообщения
  CLI.SendLn(header+nl+content+nl);
  //получение ответа
  resMessage:= '';
  SetLength(resMessage,1000);
  CLI.WaitForData(20000);
  n:= CLI.ReceiveBuf(resMessage[1],1000);
  SetLength(resMessage,n+1);
  CLI.Close();

  //вывод результата
  n:= Pos(#13#10#13#10,resMessage);
  if n>0 then
    resMessage:= Copy(resMessage,n,Length(resMessage)-n)
  else
    resMessage:= MES_SEND_MESSAGE_ERROR;

  if (pos('отправлено',resMessage)>0) then
    Result:= SR_SENDED
  else
    if Pos('ограничено',resMessage)>0 then
      Result:= SR_NO_MORE_THEN_15;

end;

Procedure ShowMSG(S:String; TType:Byte);
var B:TBalloonHintIcon;
begin
SetCurrentDir(ExtractFileDir(Application.ExeName));
case TType of
0: begin
    B:=bitInfo;
    form1.CoolTrayIcon1.ShowBalloonHint('DeNiAll Send SMS',S,B,10);
    PlaySound('Sounds\sndMsg.wav',0,0);
    Form1.RichEdit1.Clear;
   end;
1: begin
    B:=bitWarning;
    form1.CoolTrayIcon1.ShowBalloonHint('DeNiAll Send SMS',S,B,10);
    PlaySound('Sounds\sndSystem.wav',0,0);
   end;
2: begin
    B:=bitError;
    form1.CoolTrayIcon1.ShowBalloonHint('DeNiAll Send SMS',S,B,10);
    PlaySound('Sounds\sndSystem.wav',0,0);
   end;
end;

end;

Procedure BuildContactsList;
var i:Integer;
begin
Form1.ListView1.Clear;
for i:=1 to Form1.ADOTable1.RecordCount do
begin
  form1.ADOTable1.RecNo:=i;
  Form1.ListView1.Items.Add.Caption:=Form1.ADOTable1.Fields[1].AsString;
  form1.ListView1.Items[form1.ListView1.Items.Count-1].SubItems.Add(Form1.ADOTable1.Fields[3].AsString);
end;
end;

procedure ShowBalloonTip(Control: TWinControl; Icon: integer; Title: pchar;
  Text: PWideChar;
  BackCL, TextCL: TColor);
const
  TOOLTIPS_CLASS = 'tooltips_class32';
  TTS_ALWAYSTIP = $01;
  TTS_NOPREFIX = $02;
  TTS_BALLOON = $40;
  TTF_SUBCLASS = $0010;
  TTF_TRANSPARENT = $0100;
  TTF_CENTERTIP = $0002;
  TTM_ADDTOOL = $0400 + 50;
  TTM_SETTITLE = (WM_USER + 32);
  ICC_WIN95_CLASSES = $000000FF;
type
  TOOLINFO = packed record
    cbSize: Integer;
    uFlags: Integer;
    hwnd: THandle;
    uId: Integer;
    rect: TRect;
    hinst: THandle;
    lpszText: PWideChar;
    lParam: Integer;
  end;
var
  hWndTip: THandle;
  ti: TOOLINFO;
  hWnd: THandle;
begin
  hWnd := Control.Handle;
  hWndTip := CreateWindow(TOOLTIPS_CLASS, nil,
    WS_POPUP or TTS_NOPREFIX or TTS_BALLOON or TTS_ALWAYSTIP,
    0, 0, 0, 0, hWnd, 0, HInstance, nil);
  if hWndTip <> 0 then
  begin
    SetWindowPos(hWndTip, HWND_TOPMOST, 0, 0, 0, 0,
      SWP_NOACTIVATE or SWP_NOMOVE or SWP_NOSIZE);
    ti.cbSize := SizeOf(ti);
    ti.uFlags := TTF_CENTERTIP or TTF_TRANSPARENT or TTF_SUBCLASS;
    ti.hwnd := hWnd;
    ti.lpszText := Text;
    Windows.GetClientRect(hWnd, ti.rect);
    SendMessage(hWndTip, TTM_SETTIPBKCOLOR, BackCL, 0);
    SendMessage(hWndTip, TTM_SETTIPTEXTCOLOR, TextCL, 0);
    SendMessage(hWndTip, TTM_ADDTOOL, 1, Integer(@ti));
    SendMessage(hWndTip, TTM_SETTITLE, Icon mod 4, Integer(Title));
  end;
end;

function SearchForText_AndSelect(RichEdit: TRichEdit; SearchText: string): Boolean;
var 
  StartPos, Position, Endpos: Integer; 
begin
result:=False;
  StartPos := 0; 
  with RichEdit do 
  begin
    Endpos := Length(RichEdit.Text); 
    Lines.BeginUpdate; 
    while FindText(SearchText, StartPos, Endpos, [stMatchCase])<>-1 do 
    begin 
      Endpos   := Length(RichEdit.Text) - startpos; 
      Position := FindText(SearchText, StartPos, Endpos, [stMatchCase]); 
      Inc(StartPos, Length(SearchText)); 
      SetFocus; 
      SelStart  := Position; 
      SelLength := Length(SearchText);
      result:=true;
    end; 
    Lines.EndUpdate; 
  end; 
end;

procedure TForm1.SpeedButton5Click(Sender: TObject);
var
  colSpellErrors : ProofreadingErrors;
  colSuggestions : SpellingSuggestions;
  i,n : Integer;
  S:String;
  WRD:OLEVARIANT;
begin
if RichEdit1.Text='' then exit;
  RichEdit1.SelectAll;
  RichEdit1.SelAttributes.Color:=clBlack;
  WordApp.Connect;
  WordDoc.ConnectTo(WordApp.Documents.Addold(EmptyParam, EmptyParam));
  WordApp.Visible:=false;
  WordDoc.Tag:=7;
  if WordApp.Documents.Count>1 then
    WordApp.Visible:=true
  else
    WordApp.Visible:=false;
  WordDoc.Range.Delete(EmptyParam,EmptyParam);
  WordDoc.Range.Set_Text(RichEdit1.Text);
  colSpellErrors := WordDoc.SpellingErrors;
  listbox1.Clear;
  ListBox2.Clear;
  ListBox3.Clear;
  if colSpellErrors.Count <> 0 then
  begin
   for n:=1 to colSpellErrors.Count do
   begin
      colSuggestions := WordApp.GetSpellingSuggestions
      (colSpellErrors.Item(n).Get_Text);
      ListBox2.Items.Add(colSpellErrors.Item(n).Get_Text);
      SearchForText_AndSelect(RichEdit1,colSpellErrors.Item(n).Get_Text);
      RichEdit1.SelAttributes.Color:=clRed;
        for i:= 1 to colSuggestions.Count do
        begin
          listbox1.Items.Add(VarToStr(colSuggestions.Item(i)));
          ListBox3.Items.Add(IntToStr(Listbox2.count-1))
        end;
   end;
   end;
   StatusBar1.SimpleText:='Количество вариантов: '+Inttostr(Listbox1.Count);
   if ListBox1.Count-1 =-1 then
   begin
    ListBox1.Items.Add('Нет результата!');
    StatusBar1.SimpleText:='Нет результата!';
   end;

   WRD:=WordApp.Application;
   S:=ExtractFileDir(Application.ExeName)+'\Temp.doc';
   WRD.ActiveDocument.SaveAs(S);
   WordDoc.Close;
   WordDoc.Disconnect;
   Panel10.Visible:=True;
 // varFalse:=False;
 // WordApp.Quit(varFalse);

end;

procedure TForm1.ListBox1Click(Sender: TObject);
begin
if ListBox1.Items[ListBox1.ItemIndex]='Нет результата!' then exit;
  ListBox3.ItemIndex:=ListBox1.ItemIndex;
  SearchForText_AndSelect(RichEdit1,ListBox2.Items[StrToInt(ListBox3.Items[ListBox3.itemindex])]);
end;

procedure TForm1.ListBox1DblClick(Sender: TObject);
var S:String;
begin
if ListBox1.Items[ListBox1.ItemIndex]='Нет результата!' then exit;
  ListBox3.ItemIndex:=ListBox1.ItemIndex;
  S:=ListBox2.Items[StrToInt(ListBox3.items[ListBox3.itemindex])];
if  SearchForText_AndSelect(RichEdit1,S)=true then
begin
  RichEdit1.SelAttributes.Color:=clBlack;
  RichEdit1.SelText:=ListBox1.Items[ListBox1.itemindex];
end;
end;

procedure TForm1.SpeedButton8Click(Sender: TObject);
begin
  Panel10.Visible:=False;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
SetCurrentDir(ExtractFileDir(Application.ExeName));
Application.ShowMainForm:=False;
try
ADOConnection1.Connected:=true;
if ADOConnection1.Connected=true then
begin
  ADOTable1.Active:=True;
end;
except
  MessageDLG('Ошибка подключения БД',mtError,[mbOk],0);
end;

BuildContactsList;
ShowBalloonTip(Edit1,1,'Информация!','Введите номер телефона для отправки SMS',clMoneyGreen,
      clBlack);
ShowBalloonTip(ListView1,1,'Информация!','Список контактов',clMoneyGreen,
      clBlack);
  ConnectionData.server:= 'www.beeonline.ru';//'www.beeonline.ru';
  ConnectionData.port:= '80';
  CLI:= TTcpClient.Create(form1);
end;

procedure TForm1.SpeedButton1Click(Sender: TObject);
begin
res:=false;
ADOTable1.Append;
Form2.DBEdit1.Field.Clear;
Form2.DBEdit2.Field.Clear;
Form2.Caption:='Добавить контакт';
Form2.ShowModal;
if res=true then
begin
if (Form2.DBEdit1.Field.AsString<>'')or(Form2.DBEdit2.Field.AsString<>'') then
begin
  ADOTable1.Post;
  BuildContactsList;
  res:=false;
end;
end;
ADOTable1.Active:=False;
ADOTable1.Active:=True;
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
begin
if ListView1.SelCount=0 then exit;
if MessageDLG('&Вы действительно хотите удалить контакт '+ListView1.Selected.Caption+'?',mtConfirmation,[mbYes,mbNo],0)=mrYes then
begin
  ADOTable1.Active:=False;
  ADOTable1.Active:=True;
  ADOTable1.RecNo:=ListView1.ItemIndex+1;
  ADOTable1.Delete;
  Edit1.Clear;
  BuildContactsList;
end;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
if ListView1.SelCount=0 then exit;
  ADOTable1.Edit;
  Form2.Caption:='Изменить контакт';
  Form2.ShowModal;
  ADOTable1.Post;
  BuildContactsList;
end;

procedure TForm1.ListView1Click(Sender: TObject);
begin
if ListView1.SelCount=0 then exit;
ADOTable1.RecNo:=ListView1.ItemIndex+1;
Edit1.Text:=ListView1.Selected.SubItems.Strings[0];
end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
var res:Byte;
    tmp,S:string;
begin
if Edit1.Text='' then exit;
if RichEdit1.Text='' then exit;
StatusBar1.SimpleText:='Подождите пожалуйста выполняется отправка СМС...';
Form1.Hide;
res:=SendSMS(Edit1.Text,Form1.RichEdit1.Text,S);
case res of
    SR_SENDED: begin
                tmp:= nl+MES_MESSAGE_WILL_BE_SEND;
                ShowMSG(tmp,0);
               end;
    SR_CANT_CONNECT:begin
                    tmp:= nl+MES_CANT_CONNECT_TO_SERVER;
                   if CheckBox1.Checked=true then
                      SpeedButton4.Click
                    else
                      ShowMSG(tmp,2);
                    end;
    //SR_NO_MORE_THEN_15: tmp:= MES_NO_MORE_THEN_15;
else
begin
    tmp:= MES_SEND_MESSAGE_ERROR;
if CheckBox1.Checked=true then
  SpeedButton4.Click
else
  ShowMSG(tmp,2);
end;

end;
 StatusBar1.SimpleText:=tmp;
end;

procedure TForm1.N5Click(Sender: TObject);
begin
MessageDLG('Программа написана Гидиным Денисом Юрьевичем',mtInformation,[mbOk],0);
end;

procedure TForm1.N3Click(Sender: TObject);
begin
if messageDLG('Выйти из программы?',mtInformation,[mbYes,mbNo],0)=mrYes then
  application.Terminate;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Form1.Hide;
  Abort;
end;

procedure TForm1.N1Click(Sender: TObject);
begin
  Form1.Show;
end;

procedure TForm1.RichEdit1Change(Sender: TObject);
var i:Integer;
begin
i:=142-Length(RichEdit1.Text);
  StatusBar1.SimpleText:='Осталось символов: '+IntToStr(i);
end;

procedure TForm1.PopupMenu1Popup(Sender: TObject);
begin
if (Edit1.Text='') or (RichEdit1.Text='') then
  N6.Enabled:=False
else
  N6.Enabled:=True;
end;

procedure TForm1.N6Click(Sender: TObject);
begin
  SpeedButton4.Click;
end;

procedure TForm1.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
if Key=#13 then
SpeedButton4.Click;
end;

procedure TForm1.SpeedButton7Click(Sender: TObject);
begin
if OpenDialog1.Execute then
RichEdit1.Lines.LoadFromFile(OpenDialog1.FileName);
end;

procedure TForm1.SpeedButton6Click(Sender: TObject);
begin
if SaveDialog1.Execute then
RichEdit1.Lines.SaveToFile(SaveDialog1.FileName);
end;

procedure TForm1.Action1Execute(Sender: TObject);
begin
SpeedButton7.Click;
end;

procedure TForm1.Action2Execute(Sender: TObject);
begin
SpeedButton6.Click;
end;

procedure TForm1.Action3Execute(Sender: TObject);
begin
  SpeedButton5.Click;
end;

procedure TForm1.Action4Execute(Sender: TObject);
begin
SpeedButton4.Click;
end;

procedure TForm1.CoolTrayIcon1BalloonHintClick(Sender: TObject);
begin
Form1.Show;
end;

procedure TForm1.N9Click(Sender: TObject);
begin
if CheckBox1.Checked=false then
  CheckBox1.Checked:=True
else
  CheckBox1.Checked:=False;
  N9.Checked:=CheckBox1.Checked;
end;

end.
