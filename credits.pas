unit Credits;


interface


procedure DisplayCredits;


implementation

  uses SPX_VGA, SPX_Txt, SPX_Fnc, Crt,
       Keyboard, Screen, Globals, Stick, BigFont, Pics, Sounds;



type

  Credit =
    record
      color : Byte;
      line  : String[60];
    end;

const

  cMaxCredits = 21;
  cCredits : array [1..cMaxCredits] of Credit =
    (
      (color: cYellow;    line: 'CyberDogs v1.0'),
      (color: cYellow;    line: 'Code and graphics by Ronny Wester'),
      (color: cBlack;     line: ''),
      (color: cOrange;    line: 'Written using:'),
      (color: cBlack;     line: ''),
      (color: cRed;       line: 'Borland Pascal 7.0'),
      (color: cBlack;     line: ''),
      (color: cRed;       line: 'SPX 2.0 by Scott Ramsay'),
      (color: cBlack;     line: ''),
      (color: cRed;       line: 'DSMI - Digital Sound and Music Interface'),
      (color: cRed;       line: 'by Otto Chrons and Jussi Lahdenniemi'),
      (color: cOrange;    line: 'Playtesters and other helpful people:'),
      (color: cBlack;     line: ''),
      (color: cRed;       line: 'Jouni Miettunen'),
      (color: cRed;       line: 'John Isidoro'),
      (color: cRed;       line: 'Christian Wagner'),
      (color: cRed;       line: 'Jan Olof Hendig'),
      (color: cRed;       line: 'Anders Torlind'),
      (color: cRed;       line: 'Victor Putz'),
      (color: cRed;       line: 'Niklas Wester'),
      (color: cRed;       line: 'Camilla Wester')
    );

procedure DisplayCredits;

  procedure ClearDisplay;
  begin
    Bar( 64, 60, 255, 179, cBlack);
  end;

  procedure WriteLine( y : Integer; s : String; c : Byte );
  var i : Integer;
      x : Integer;
  begin
    i := 1;
    x := 160 - StLen( s) div 2;
    while (i <= Length( s)) and not AnyKeyDown and not StickButtonPressed do
    begin
      PutLetter( x, y, cWhite, s[i]);
      VSinc;
      VSinc;
      PutLetter( x, y, cYellow, s[i]);
      VSinc;
      VSinc;
      PutLetter( x, y, c, s[i]);
      Inc( x, StLen( s[i]));
      Inc( i);
    end;
  end;

var y : Integer;
    i : Integer;
begin
  FadeOut( 5, gPalette);
  SetPageActive( 1);
  FillScreen( cSteelPlate);
  ClearDisplay;

  BigText( 50, 25, 'CREDITS');

  if gCreditsSong <> gMenuSong then
    PlayMusic( gCreditsSong);
  FadeIn( 20, gPalette);

  i := 1;
  y := 65;
  while not AnyKeyDown and not StickButtonPressed do
  begin
    while (i <= cMaxCredits) and (y < 175) do
    begin
      WriteLine( y, cCredits[i].line, cCredits[i].color);
      Inc( y, 10);
      Inc( i);
    end;
    if i > cMaxCredits then
      i := 1;
    if not AnyKeyDown and not StickButtonPressed then
      for y := 1 to 25 do
        VSinc;
    y := 65;
    ClearDisplay;
  end;
  FadeOut( 5, gPalette);
  if gCreditsSong <> gMenuSong then
    PlayMusic( gMenuSong);
end;


end.
