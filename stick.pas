unit Stick;


interface


function  StickDown( s : Byte ) : Boolean;
function  StickUp( s : Byte ) : Boolean;
function  StickLeft( s : Byte ) : Boolean;
function  StickRight( s : Byte ) : Boolean;
function  StickAnyButton( s : Byte ) : Boolean;
function  StickButton1( s : Byte ) : Boolean;
function  StickButton2( s : Byte ) : Boolean;
function  StickAction( s : Byte ) : Boolean;
function  StickButtonPressed : Boolean;
function  StickButton3Down( stick1, stick2 : Integer ) : Boolean;


const

  gStickLeft  : array [1..2] of Integer = ( 10, 10);
  gStickRight : array [1..2] of Integer = ( 25, 25);
  gStickUp    : array [1..2] of Integer = ( 10, 10);
  gStickDown  : array [1..2] of Integer = ( 25, 25);


implementation

  uses Joystick;


function StickDown( s : Byte ) : Boolean;
begin
  if s = 0 then
    StickDown := StickDown( 1) or StickDown( 2)
  else
    StickDown := gSticks[s].present and (gSticks[ s].y > gStickDown[ s]);
end;

function StickUp( s : Byte ) : Boolean;
begin
  if s = 0 then
    StickUp := StickUp( 1) or StickUp( 2)
  else
    StickUp := gSticks[s].present and (gSticks[s].y < gStickUp[s]);;
end;

function StickLeft( s : Byte ) : Boolean;
begin
  if s = 0 then
    StickLeft := StickLeft( 1) or StickLeft( 2)
  else
    StickLeft := gSticks[s].present and (gSticks[ s].x < gStickLeft[ s]);
end;

function StickRight( s : Byte ) : Boolean;
begin
  if s = 0 then
    StickRight := StickRight( 1) or StickRight( 2)
  else
    StickRight := gSticks[s].present and (gSticks[ s].x > gStickRight[ s]);
end;

function StickAnyButton( s : Byte ) : Boolean;
begin
  if s = 0 then
    StickAnyButton := StickAnyButton(1) or StickAnyButton(2)
  else
    StickAnyButton := gSticks[s].present and
                      (gSticks[s].button1 or gSticks[s].button2);
end;

function StickButton1( s : Byte ) : Boolean;
begin
  if s = 0 then
    StickButton1 := StickButton1(1) or StickButton1(2)
  else
    StickButton1 := gSticks[s].present and gSticks[s].button1;
end;

function StickButton2( s : Byte ) : Boolean;
begin
  if s = 0 then
    StickButton2 := StickButton2(1) or StickButton2(2)
  else
    StickButton2 := gSticks[s].present and gSticks[s].button2;
end;

function StickAction( s : Byte ) : Boolean;
begin
  StickAction := StickUp( s) or StickDown( s) or
                 StickLeft( s) or StickRight( s) or
                 StickAnyButton( s);
end;

function StickButtonPressed : Boolean;
begin
  PollSticks;
  StickButtonPressed := StickAnyButton( 0);
end;


function StickButton3Down( stick1, stick2 : Integer ) : Boolean;
begin
  StickButton3Down := False;
  if ((stick1 <> 0) and (stick2 <> 0)) or
     ((stick1 = 0) and (stick2 = 0)) then
    Exit;
  if stick1 <> 0 then
    StickButton3Down := gSticks[stick1].button3
  else
    StickButton3Down := gSticks[stick2].button3;
end;


end.
