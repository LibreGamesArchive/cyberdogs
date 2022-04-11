unit Keyboard;


interface

  uses Dos;


const

  keySysReq      = $54;
  keyCapsLock    = $3A;
  keyNumLock     = $45;
  keyScrollLock  = $46;
  keyLeftCtrl    = $1D;
  keyLeftAlt     = $38;
  keyLeftShift   = $2A;
  keyRightCtrl   = $9D;
  keyAltGr       = $B8;
  keyRightShift  = $36;
  keyEsc         = $01;
  keyBackspace   = $0E;
  keyEnter       = $1C;
  keySpace       = $39;
  keyTab         = $0F;
  keyF1          = $3B;
  keyF2          = $3C;
  keyF3          = $3D;
  keyF4          = $3E;
  keyF5          = $3F;
  keyF6          = $40;
  keyF7          = $41;
  keyF8          = $42;
  keyF9          = $43;
  keyF10         = $44;
  keyF11         = $57;
  keyF12         = $58;
  keyA           = $1E;
  keyB           = $30;
  keyC           = $2E;
  keyD           = $20;
  keyE           = $12;
  keyF           = $21;
  keyG           = $22;
  keyH           = $23;
  keyJ           = $24;
  keyK           = $25;
  keyL           = $26;
  keyM           = $32;
  keyN           = $31;
  keyO           = $18;
  keyP           = $19;
  keyQ           = $10;
  keyR           = $13;
  keyS           = $1F;
  keyT           = $14;
  keyU           = $16;
  keyV           = $2F;
  keyW           = $11;
  keyX           = $2D;
  keyY           = $15;
  keyZ           = $2C;
  key1           = $02;
  key2           = $03;
  key3           = $04;
  key4           = $05;
  key5           = $06;
  key6           = $07;
  key7           = $08;
  key8           = $09;
  key9           = $0A;
  key0           = $0B;
  keyMinus       = $0C;
  keyEqual       = $0D;
  keyLBracket    = $1A;
  keyRBracket    = $1B;
  keySemicolon   = $27;
  keyTick        = $28;
  keyApostrophe  = $29;
  keyBackslash   = $2B;
  keyComma       = $33;
  keyPeriod      = $34;
  keySlash       = $35;
  keyInsert      = $D2;
  keyDelete      = $D3;
  keyHome        = $C7;
  keyEnd         = $CF;
  keyPageUp      = $C9;
  keyArrowLeft   = $CB;
  keyArrowRight  = $CD;
  keyArrowUp     = $C8;
  keyArrowDown   = $D0;
  keyKeypad0     = $52;
  keyKeypad1     = $4F;
  keyKeypad2     = $50;
  keyKeypad3     = $51;
  keyKeypad4     = $4B;
  keyKeypad5     = $4C;
  keyKeypad6     = $4D;
  keyKeypad7     = $47;
  keyKeypad8     = $48;
  keyKeypad9     = $49;
  keyKeypadComma = $53;
  keyKeypadStar  = $37;
  keyKeypadMinus = $4A;
  keyKeypadPlus  = $4E;
  keyKeypadEnter = $9C;
  keyCtrlPrtScr  = $B7;
  keyShiftPrtScr = $B7;
  keyKeypadSlash = $B5;

  keyNames : array [0..255] of PChar =
    ( { $00 } nil, 'Esc', '1', '2', '3', '4', '5', '6',
      { $08 } '7', '8', '9', '0', '+', 'Apostrophe', 'Backspace', 'Tab',
      { $10 } 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I',
      { $18 } 'O', 'P', 'è', '?', 'Enter', 'Left Ctrl', 'A', 'S',
      { $20 } 'D', 'F', 'G', 'H', 'J', 'K', 'L', 'ô',
      { $28 } 'é', '''', 'Left shift', '<', 'Z', 'X', 'C', 'V',
      { $30 } 'B', 'N', 'M', ',', '.', '-', 'Right shift', '* (pad)',
      { $38 } 'Alt', 'Space', 'Caps Lock', 'F1', 'F2', 'F3', 'F4', 'F5',
      { $40 } 'F6', 'F7', 'F8', 'F9', 'F10', 'Num Lock', 'Scroll Lock', '7 (pad)',
      { $48 } '8 (pad)', '9 (pad)', '- (pad)', '4 (pad)', '5 (pad)', '6 (pad)', '+ (pad)', '1 (pad)',
      { $50 } '2 (pad)', '3 (pad)', '0 (pad)', ', (pad)', 'SysRq', nil, nil, 'F11', 'F12',
      { $59 } nil, nil, nil, nil, nil, nil, nil,
      { $60 } nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
      { $70 } nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
      { $80 } nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
      { $90 } nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 'Enter (pad)', 'Right Ctrl', nil, nil,
      { $A0 } nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
      { $B0 } nil, nil, nil, nil, nil, '/ (pad)', nil, 'PrtScr', 'Alt Gr', nil, nil, nil, nil, nil, nil, nil,
      { $C0 } nil, nil, nil, nil, nil, nil, nil, 'Home',
      { $C8 } 'Up arrow', 'Page Up', nil, 'Left arrow', nil, 'Right arrow', nil, 'End',
      { $D0 } 'Down arrow', nil, 'Insert', 'Delete', nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
      { $E0 } nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil,
      { $F0 } nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
    );


procedure InstallKbdHandler;
procedure RemoveKbdHandler;
function  KeyDown( b : byte ) : Boolean;
function  AnyKeyDown : Boolean;
function  GetKeyDown : Byte;
procedure ClearKeys;


implementation


var

  uOldInt9  : Pointer;                   { saves location of old OldInt9 vector }
  uKeys     : array [0..255] of Boolean; { array that holds key values }
  e0Flag    : Byte;
  uExitProc : Pointer;


{$F+}
procedure NewInt9; interrupt; assembler;
asm
  cli
  in      al, $60                       { get scan code from keyboard port }
  cmp     al, $E0                       { al = $E0 key ? }
  jne     @@SetScanCode
  mov     [e0Flag], 128
  mov     al, 20h                       { Send 'generic' EOI to PIC }
  out     20h, al
  jmp     @@exit
@@SetScanCode:
  mov     bl, al                        { Save scancode in BL }
  and     bl, 01111111b
  add     bl, [e0Flag]
  xor     bh, bh
  and     al, 10000000b                 { keep break bit, if set }
  xor     al, 10000000b                 { flip bit, 1 means pressed, 0 no }
  rol     al, 1                         { move breakbit to bit 0 }
  mov     [offset uKeys + bx], al
  mov     [e0Flag], 0
  mov     al, 20h                       { send EOI to PIC }
  out     20h, al
@@exit:
  sti
end;
{$F-}


procedure InstallKbdHandler;
begin
  GetIntVec( $09, uOldInt9);           { save old location of INT 09 handler }
  SetIntVec( $09, Addr( NewInt9));     { point to new routine }
  FillChar( uKeys, SizeOf( uKeys), 0); { clear the keys array }
end;


procedure RemoveKbdHandler;
begin
  SetIntVec( $09, uOldInt9);         { point back to original routine }
  uOldInt9 := nil;
end;


function KeyDown( b : byte ) : Boolean;
begin
  KeyDown := uKeys[b];
end;


function AnyKeyDown : Boolean;
var b : Integer;
begin
  AnyKeyDown := True;
  for b := 0 to 255 do
    if uKeys[b] and (keyNames[b] <> nil) then
      Exit;
  AnyKeyDown := False;
end;


function GetKeyDown : Byte;
var b : Integer;
begin
  GetKeyDown := 0;
  for b := 1 to 255 do
    if uKeys[b] and (keyNames[b] <> nil) then
    begin
      GetKeyDown := b;
      Exit;
    end;
end;


procedure ClearKeys;
begin
  FillChar( uKeys, SizeOf( uKeys), 0); { clear the keys array }
end;


{$F+}
procedure CleanUp;
begin
  ExitProc := uExitProc;
  if uOldInt9 <> nil then
    RemoveKbdHandler;
end;
{$F-}


begin
  uExitProc := ExitProc;
  ExitProc := @CleanUp;
  uOldInt9 := nil;
end.
