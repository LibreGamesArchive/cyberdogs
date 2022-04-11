unit HallFame;


interface


procedure DisplayHallOfFame;
procedure ApplyForHallOfFame( index : Integer );


implementation

  uses SPX_VGA, SPX_Txt, SPX_Fnc, Crt,
       Keyboard, Screen, Globals, Stick, BigFont, Pics, Sounds;


const

  cHallMax = 20;

  cHallOfFameScore       = 0;
  cHallOfFameMissions    = 0;
  cHallOfFameKills       = 0;
  cHallOfFameCloseCombat = 0;


type

  HallEntry =
    record
      name        : String[20];
      score,
      missions,
      kills,
      combat,
      shotsFired,
      hits,
      hitsTaken,
      campaign,
      demolition,
      cash        : LongInt;
    end;

  HallList = array [1..cHallMax] of HallEntry;
  HallPtr = ^HallList;


function LoadHallOfFame : HallPtr;
var h : HallPtr;
    f : File of HallEntry;
    i : Integer;
begin
  New( h);
  FillChar( h^, SizeOf( h^), 0);
  for i := 1 to cHallMax do
    h^[i].name := '---';
  LoadHallOfFame := h;

  Assign( f, 'DOGS.HI');
  Reset( f);
  if IOResult <> 0 then
    Exit;

  i := 1;
  while not Eof( f) do
  begin
    Read( f, h^[i]);
    Inc( i);
  end;
  Close( f);
end;


procedure WriteHallOfFame( h : HallPtr );
var f : File of HallEntry;
    i : Integer;
begin
  Assign( f, 'DOGS.HI');
  Rewrite( f);
  if IOResult <> 0 then
    Exit;

  for i := 1 to cHallMax do
    Write( f, h^[i]);
  Close( f);
end;


procedure SortHallOfFame( h : HallPtr; by : Byte );

  function LessEntry( i, j : Integer ) : Boolean;
  begin
    case by of
      cHallOfFameScore:
        LessEntry := h^[i].score < h^[j].score;
      {
      cHallOfFameMissions:
        Less := h^[i].score < h^[j].score;
      cHallOfFameScore:
        Less := h^[i].score < h^[j].score;
      cHallOfFameScore:
        Less := h^[i].score < h^[j].score;
      }
    end;
  end;

  procedure SwapEntry( i, j : Integer );
  var e : HallEntry;
  begin
    e := h^[i];
    h^[i] := h^[j];
    h^[j] := e;
  end;

var i, j : Integer;
begin
  for i := 1 to cHallMax - 1 do
    for j := i + 1 to cHallMax do
      if LessEntry( i, j) then
        SwapEntry( i, j);
end;


procedure DisplayHallOfFame;

  procedure ClearDisplay;
  begin
    Bar( 32, 60, 287, 179, cBlack);
  end;

  procedure WriteLine( var x, y : Integer; s : String; c : Byte );
  var i : Integer;
  begin
    i := 1;
    while (i <= Length( s)) and not AnyKeyDown and not StickButtonPressed do
    begin
      if s[i] < #127 then
      begin
        PutLetter( 40 + x, y, cWhite, s[i]);
        VSinc;
        VSinc;
        PutLetter( 40 + x, y, cYellow, s[i]);
        VSinc;
        VSinc;
        PutLetter( 40 + x, y, c, s[i]);
        Inc( x, StLen( s[i]));
      end
      else
        x := 5*(Ord( s[i]) - 127); {40*((x + 40) div 40);}
      Inc( i);
    end;
  end;

  procedure WriteOneEntry( var y : Integer; index : Integer; var h: HallEntry );
  var x : Integer;
  begin
    if h.score <= 0 then
      Exit;
    x := 0;
    WriteLine( x, y, St( index) + '. ', cBrightRed);
    WriteLine( x, y, h.name, cYellow);
    if AnyKeyDown or StickButtonPressed then
      Exit;
    x := 0;
    Inc( y, 8);
    WriteLine( x, y, 'Score: ', cOrange);
    WriteLine( x, y, St( h.score), cBrightRed);
    if AnyKeyDown or StickButtonPressed then
      Exit;
    x := 100;
    WriteLine( x, y, 'Missions: ', cOrange);
    WriteLine( x, y, St( h.missions), cBrightRed);
    if AnyKeyDown or StickButtonPressed then
      Exit;
    x := 0;
    Inc( y, 8);
    WriteLine( x, y, 'Kills: ', cOrange);
    WriteLine( x, y, St( h.kills), cBrightRed);
    if AnyKeyDown or StickButtonPressed then
      Exit;
    x := 50;
    WriteLine( x, y, 'Ninja: ', cOrange);
    WriteLine( x, y, St( h.combat), cBrightRed);
    if AnyKeyDown or StickButtonPressed then
      Exit;
    if h.shotsFired > 0 then
    begin
      x := 100;
      WriteLine( x, y, 'Accuracy: ', cOrange);
      WriteLine( x, y, St( h.hits), cBrightRed);
      WriteLine( x, y, '/', cOrange);
      WriteLine( x, y, St( h.shotsFired), cBrightRed);
      WriteLine( x, y, ', ', cOrange);
      WriteLine( x, y, St( (100*h.hits) div h.shotsFired), cBrightRed);
      WriteLine( x, y, '%', cOrange);
      if AnyKeyDown or StickButtonPressed then
        Exit;
    end;
    Inc( y, 10);
  end;

  procedure Display( h : HallPtr );
  var y : Integer;
      i : Integer;
  begin
    i := 1;
    while not AnyKeyDown and not StickButtonPressed do
    begin
      y := 65;
      while (i <= cHallMax) and (y < 160) do
      begin
        WriteOneEntry( y, i, h^[i]);
        Inc( i);
      end;
      if i > cHallMax then
        i := 1;
      if not AnyKeyDown and not StickButtonPressed then
        for y := 1 to 25 do
          VSinc;
      ClearDisplay;
    end;
  end;

var h : HallPtr;
begin
  SetPageActive( 1);
  FillScreen( cSteelPlate);
  ClearDisplay;

  BigText( 20, 25, 'MEAN DOGS');

  PlayMusic( gHallOfFameSong);
  FadeIn( 5, gPalette);

  h := LoadHallOfFame;
  SortHallOfFame( h, cHallOfFameScore);
  Display( h);
  Dispose( h);
  FadeOut( 5, gPalette);
end;


function EnterHallOfFame( h        : HallPtr;
                          by       : Byte;
                          index    : Integer;
                          name     : String ) : Boolean;


  function Less( i, index : Integer ) : Boolean;
  begin
    case by of
      cHallOfFameScore:
        Less := h^[i].score < gPlayerData[ index].total.score;
    end;
  end;

  procedure Insert( index, i : Integer );
  var j : Integer;
  begin
    for j := cHallMax downto i + 1 do
      h^[j] := h^[j-1];
    h^[i].name := name;
    h^[i].score := gPlayerData[ index].total.score;
    h^[i].missions := gPlayerData[ index].missions;
    h^[i].kills := gPlayerData[ index].total.kills;
    h^[i].combat := gPlayerData[ index].total.closeCombat;
    h^[i].campaign := gCampaign;
    h^[i].shotsFired := gPlayerData[ index].total.shotsFired;
    h^[i].hits := gPlayerData[ index].total.hits;
    h^[i].hitsTaken := gPlayerData[ index].total.hitsTaken;
    h^[i].demolition := gPlayerData[ index].total.demolition;
    h^[i].cash := gPlayerData[ index].cash;
  end;

var i : Integer;
begin
  i := 1;
  while i <= cHallMax do
  begin
    if Less( i, index) then
    begin
      if name <> '' then
        Insert( index, i);
      EnterHallOfFame := True;
      Exit;
    end;
    Inc( i);
  end;
  EnterHallOfFame := False;
end;


procedure ApplyForHallOfFame( index : Integer );

  function GetString( x, y, max : Integer ) : String;
  var key : Char;
  const s : String = '';
  begin
    PutLetter( x, y, cBrightRed, s + '_');
    repeat
      key := ReadKey;
      if key = #0 then
        ReadKey
      else begin
        if key = #8 then
        begin
          if s <> '' then
            Delete( s, Length( s), 1);
          PutLetter( x, y, cBrightRed, s);
          Bar( x + StLen( s), y, 255, y+10, cBlack);
          PutLetter( x, y, cBrightRed, s + '_');
        end
        else if (key >= ' ') and (key <= 'z') and (Length( s) < max) then
        begin
          Bar( x + StLen( s), y, 255, y+10, cBlack);
          s := s + key;
          PutLetter( x, y, cBrightRed, s + '_');
        end;
      end;
    until key = #13;
    if s = '' then
      s := 'Anonymous';
    GetString := s;
  end;

var h : HallPtr;
    name : String;
begin
  h := LoadHallOfFame;
  if EnterHallOfFame( h, cHallOfFameScore, index, '') then
  begin
    RemoveKbdHandler;
    FadeOut( 5, gPalette);
    SetPageActive( 1);
    FillScreen( cSteelPlate);
    BigText( 20, 25, 'WOOF WOOF');
    with cHeroInfo[ gPlayerData[ index].hero] do
    begin
      DrawCharacter( 10, 90, cDirectionDown, cDirectionDownRight, face, body, cGunDogs, cFaceNormal, 0, cGunIdle);
      DrawLetter( 12, 115, cWhite, cBlack, name);
    end;
    Bar( 64, 80, 255, 119, cBlack);
    PutLetter( 70, 90, cRed, 'You are one mean Dog! Enter your name');
    FadeIn( 5, gPalette);
    PlaySound( cBangSound);
    name := GetString( 70, 100, 20);
    PlaySound( cBigGunSound);
    EnterHallOfFame( h, cHallOfFameScore, index, name);
    WriteHallOfFame( h);
    InstallKbdHandler;
  end;
  Dispose( h);
end;


end.
