unit UFunctions;

interface

uses SysUtils, Classes, Windows, Sockets;

const
  nl= #13+#10;
  sep = '***************************';
  //send result
  SR_SENDED = 0;
  SR_NO_MORE_THEN_15 = 1;
  SR_UNKNOWN_ERROR = 255;
  SR_CANT_CONNECT = 2;
  //ProcessSMSText
  PSMST_OK = 0;
  PSMST_BIG_LEN = 1;
  //SMS-LENGTH
  SMS_LENGTH_TRANSLIT = 156;
  SMS_LENGTH_NOTRANSLIT = 66;
  SPLIT_SMS_IS_ZERO = 1;
  SPLIT_SMS_IS_BIG = 2;
  //FormWidth
  FW_NORMAL = 264;
  FW_EXTENDED = 563;
  //����� �� ���������� �����
  MAX_SMS_CNT_NOTRANS = 3; //������������ ����� ���������
  MAX_SMS_CNT_TRANS = 1;
  //
  MY_ATOM = 'SMS-Sender_ver_1.0_beta';


type
  //��������� CalSymCnt
  TCalcSymCnt = record
    sms_cnt: word;
    sym_cnt: word;
  end;
  //��������� SplitSMS
  PTSplitSMSInfo = ^TSplitSMSInfo;
  TSplitSMSInfo = record
    sms_cnt: word;
    sym_cnt_more: word; //��������� ���������� ��������
    split_res: byte; //��������� �������
    max_sms: word
  end;
  //������ ��������
  TContactRec = record
    name: string[50];
    phonenumber: string[11];
  end;
  //
  TPrepairSMSResult = record
    new_sms: string;
    new_len: integer;
  end;
  //������ ��������
  TSettingsRec = record
    savethehistory: boolean;
    signature: string[10];
    autosignat: boolean;
    useProxy: boolean;
    proxyAddress: String[20];
    proxyPort: string[6];
    DublicateOnMail: boolean; //��� �������
    Reserved1: integer; //���� �� ����� �������� ��������� ������ ������������������
    Reserved2: integer;
    Reserved3: integer;
  end;
  //������ �������
  THistoryRec = record
    DT: TDateTime;
    Number: string[11];
    MessageText: string[255];
  end;
  //����� ������-������� (HTTP)
  TConnectionData = record
    server: TSocketHost;
    port: TSocketPort;
  end;

  //export
  procedure ShowMyMessage(text: string);
  function isValidNumber(num: string): boolean;
  function SplitSMS(sms_text: string; trans_on: boolean; var split_info: TSplitSMSInfo): TStringList;
  function GetPrefByNumber(var num: string; cut: boolean=false): string;

implementation

//���������
procedure ShowMyMessage(text: string);
begin
  MessageBox(0,@text[1],'SMS-Sender',MB_OK);
end;

//��������� �������� �� ����� ����������
function isValidNumber(num: string): boolean;
begin
  result:= false;
  if (Length(Trim(num))<11) then
    exit;
  if num[1]<>'7' then
    exit;
  result:= true;
end;

//���������� ��� �������
function VesSimvola(symb: char; trans_on: boolean): byte;
const
  s_2_sim = '����������';
  s_3_sim = '��';
begin
  result:= 1;
  if trans_on = false then
    exit;
  if pos(symb,s_2_sim)>0 then
    Result:= 2
  else
    if pos(symb,s_3_sim)>0 then
      Result:= 3;
end;

//���������� sms ���������� �� �����
function SplitSMS(sms_text: string; trans_on: boolean; var split_info: TSplitSMSInfo): TStringList;
var n: integer;
    buf: string;
    head_str: string;
    sym_cnt, sms_cnt: word;
    max_sym: word;
begin
  Result:= nil;

  //�������� ����. ����� ��������
  if trans_on then
  begin
    max_sym:= SMS_LENGTH_TRANSLIT;
    split_info.max_sms:= MAX_SMS_CNT_TRANS
  end else begin
    max_sym:= SMS_LENGTH_NOTRANSLIT;
    split_info.max_sms:= MAX_SMS_CNT_NOTRANS
  end;

  if Trim(sms_text) = '' then
  begin
    split_info.split_res:= SPLIT_SMS_IS_ZERO; //��������� - ������ sms
    split_info.sym_cnt_more:= max_sym;
    exit
  end;

  //��������� ����� ��������� c ������ ��������������
  for n:= 1 to Length(sms_text) do
    inc(sym_cnt, VesSimvola(sms_text[n],trans_on));

  if sym_cnt > max_sym then
    dec(max_sym,4); //��� ���������� sms ������ 1 ����� ��������� ������. �� 4�

  //��������� ���������� sms
  sms_cnt:= (sym_cnt div max_sym);
  if (sym_cnt mod max_sym) <> 0 then
  begin
    inc(sms_cnt);
    split_info.sym_cnt_more:= max_sym - (sym_cnt mod max_sym)
  end else
    sym_cnt:= 0;

  split_info.sms_cnt:= sms_cnt;

  if sms_cnt > split_info.max_sms then
  begin
    split_info.split_res:= SPLIT_SMS_IS_BIG; //��������� - ������� ������� sms
    exit
  end;

  Result:= TStringList.Create;
  if sms_cnt = 1 then
  begin
    Result.Add(sms_text);
    exit;
  end;

  n:= 1;
  while Length(sms_text) > 0 do
  begin
    head_str:= IntToStr(sms_cnt)+'.'+IntToStr(n)+' '; //���� 3.1
    buf:= head_str + Copy(sms_text,1,max_sym);
    Result.Add(buf);
    delete(sms_text,1,max_sym);
    inc(n)
  end
end;

//���������� ������� ������
function GetPrefByNumber(var num: string; cut: boolean=false): string;
begin
  Result:= 'error';
  if not isValidNumber(num) then
    exit;
  Result:= Copy(num,1,4);
  if cut then
    num:= Copy(num,5,7);
end;

end.
