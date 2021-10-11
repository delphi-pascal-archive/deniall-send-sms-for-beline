unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, XPMan, StdCtrls, ExtCtrls, ComCtrls;

type
  TForm3 = class(TForm)
    Label1: TLabel;
    XPManifest1: TXPManifest;
    ProgressBar1: TProgressBar;
    Timer1: TTimer;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;

implementation

uses Unit1;

{$R *.dfm}

procedure TForm3.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Form1.Hide;
  Form3.Hide;
  Abort;
end;

procedure TForm3.Timer1Timer(Sender: TObject);
begin
  Progressbar1.position:=Random(100);
end;

end.
