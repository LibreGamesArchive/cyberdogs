unit BigFont;


interface


procedure BigText( x, y : Integer; s : String );
procedure FancyBigText( x, y : Integer; s : String; dx, dy : Integer; xInc, yInc : Integer );
function  CharWidth : Integer;
function  CharHeight : Integer;


implementation

  uses {$IFDEF XLIB} XSPX {$ELSE} SPX_VGA {$ENDIF},
       Pics, Fancy;


const

  cCapitalA = 140;
  cZero     = 166;
  cDot      = 176;


function ValidChar( c : Char ) : Boolean;
begin
  ValidChar := c in ['A'..'Z', 'a'..'z', '0'..'9', '.'];
end;


function PicIndex( c : Char ) : Integer;
begin
  if c = '.' then
    PicIndex := cDot
  else if c in ['0'..'9'] then
    PicIndex := Ord( c) - Ord( '0') + cZero
  else begin
    c := UpCase( c);
    PicIndex := Ord( c) - Ord( 'A') + cCapitalA;
  end;
end;


procedure BigText( x, y : Integer; s : String );
var i : Integer;
    w : Integer;
begin
  w := CharWidth;
  for i := 1 to Length( s) do
  begin
    if ValidChar( s[i]) then
      ftPut_Clip( x, y, gPics[ PicIndex( s[i])]^, True);
    Inc( x, w);
  end;
end;


procedure FancyBigText( x, y : Integer; s : String; dx, dy : Integer; xInc, yInc : Integer );
var i : Integer;
    w : Integer;
begin
  w := CharWidth;
  for i := 1 to Length( s) do
  begin
    if ValidChar( s[i]) then
    begin
      if (dx <= 0) and (dy <= 0) then
        ftPut_Clip( x, y, gPics[ PicIndex( s[i])]^, True)
      else
        FancyPut( x, y, gPics[ PicIndex( s[i])]^, True, dx, dy);
    end;
    Inc( dx, xInc);
    Inc( dy, yInc);
    Inc( x, w);
  end;
end;


function CharWidth : Integer;
var w, h : Integer;
begin
  ImageDims( gPics[ cCapitalA]^, w, h);
  CharWidth := w + 1;
end;


function CharHeight : Integer;
var w, h : Integer;
begin
  ImageDims( gPics[ cCapitalA]^, w, h);
  CharHeight := h + 5;
end;


end.
