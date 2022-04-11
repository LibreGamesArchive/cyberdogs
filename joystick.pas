unit Joystick;


interface


type

  JoyRec =
    record
      present : Boolean;
      x, y : Word;
      button1,
      button2,
      button3,
      button4 : Boolean;
    end;

var

  gSticks : array [1..2] of JoyRec;


procedure PollSticks;
procedure InitSticks;


implementation


const

  cVGAPort   = $03DA;
  cStickPort = $0201;


procedure HSync;
begin
  while Port[ cVGAPort] and 1 = 0 do;
  while Port[ cVGAPort] and 1 <> 0 do;
end;


procedure PollSticks;
var b : Byte;
    mask : Byte;
    laps : Word;
begin
  mask := 0;
  if gSticks[1].present then
    mask := 3;
  if gSticks[2].present then
    mask := mask or 12;
  FillChar( gSticks, SizeOf( gSticks), 0);
  laps := 0;

  asm cli end;

  {HSync;}
  Port[ cStickPort] := $FF; { Write anything to trigger countdown }
  repeat
    {HSync;}
    b := Port[ cStickPort];
    if b and 1 <> 0 then
      Inc( gSticks[1].x);
    if b and 2 <> 0 then
      Inc( gSticks[1].y);
    if b and 4 <> 0 then
      Inc( gSticks[2].x);
    if b and 8 <> 0 then
      Inc( gSticks[2].y);
    Inc( laps);
  until (b and mask = 0) or (laps > 60000);

  asm sti end;

  gSticks[1].present := b and 3 = 0;
  gSticks[2].present := b and 12 = 0;

  if gSticks[1].present then
  begin
    gSticks[1].button1 := b and 16 = 0;
    gSticks[1].button2 := b and 32 = 0;
    gSticks[1].button3 := b and 64 = 0;
    gSticks[1].button4 := b and 128 = 0;
  end;

  if gSticks[2].present then
  begin
    gSticks[2].button1 := b and 64 = 0;
    gSticks[2].button2 := b and 128 = 0;
    gSticks[2].button3 := b and 16 = 0;
    gSticks[2].button4 := b and 32 = 0;
  end;
end;


procedure InitSticks;
begin
  gSticks[1].present := True;
  gSticks[2].present := True;
  PollSticks;
end;


end.
