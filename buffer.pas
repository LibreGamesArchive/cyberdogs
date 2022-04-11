unit Buffer;


interface

  uses Globals, Elements;


const

  cSplitScreenNever  = 0;
  cSplitScreenAlways = 1;
  cSplitScreenOften  = 2;
  cSplitScreenSeldom = 3;

  cxSplitOften  = 140;
  cxSplitSeldom = 250;

  gSplitScreenMode : Byte = cSplitScreenSeldom;


function  InBuffer1( x, y, offset, w, h : Integer; var xOut, yOut : Integer ) : Boolean;
function  InBuffer2( x, y, offset, w, h : Integer; var xOut, yOut : Integer ) : Boolean;
function  CharacterVisible( c : PCharacter ) : Boolean;
procedure SetBuffer;
procedure CheckLOS;
procedure DrawBuffer;


implementation

  uses SPX_Txt, SPX_Fnc, Pics, GameArea,
       SPX_VGA;




const

  cxViewMax = 10;
  cyViewMax = 9;

  cxLittleViewMax = 5;

  cShade1Flag  = 256;
  cShade2Flag  = 512;
  cBlocks1Flag = 1024;
  cBlocks2Flag = 2048;

  cShadeXFlag  = 4096;
  cBlocksXFlag = 8192;


type

  PosRec =
    record
      x, y : Integer;
    end;

  BufferType = array [0..cxViewMax, 0..cyViewMax] of Word;


var

 uBuffer1,
 uBuffer2 : BufferType;

 uPos1,
 uPos2 : PosRec;

 uSplitScreen : Boolean;


procedure DetermineScreen;
var xSplit : Integer;
begin
  uSplitScreen := False;
  if (gHero1 <> nil) and
     (gHero2 <> nil) then
  begin
    if gSplitScreenMode = cSplitScreenOften then
      xSplit := cxSplitOften
    else
      xSplit := cxSplitSeldom;
    if (gSplitScreenMode <> cSplitScreenNever) and
       ((gSplitScreenMode = cSplitScreenAlways) or
        (Abs( gHero1^.x - gHero2^.x) > xSplit) or
        (Abs( gHero1^.y - gHero2^.y) > cMaxVerticalDistance)) then
    begin
      uSplitScreen := True;
      uPos1.x := gHero1^.x - 72;
      uPos1.y := gHero1^.y - 90;
      uPos2.x := gHero2^.x - 72;
      uPos2.y := gHero2^.y - 90;
    end
    else begin
      uPos1.x := (gHero1^.x + gHero2^.x) div 2 - 152;
      uPos1.y := (gHero1^.y + gHero2^.y) div 2 - 90;
    end;
  end
  else if gHero1 <> nil then
  begin
    uPos1.x := gHero1^.x - 152;
    uPos1.y := gHero1^.y - 90;
  end
  else if gHero2 <> nil then
  begin
    uPos1.x := gHero2^.x - 152;
    uPos1.y := gHero2^.y - 90;
  end;
end;


procedure SetOneBuffer( xMax : Integer; const p : PosRec; var b : BufferType );
var x, y, bx, by : Integer;
    x1, x2, y1, y2 : Integer;
begin
  bx := p.x div 32;
  by := p.y div 24;

  x1 := 0;
  x2 := xMax;
  y1 := 0;
  y2 := cyViewMax;
  if bx < cxMin then
    x1 := cxMin - bx;
  if by < cyMin then
    y1 := cyMin - by;
  if bx + xMax > cxMax then
    x2 := cxMax - bx;
  if by + cyViewMax > cyMax then
    y2 := cyMax - by;

  FillChar( b, SizeOf( b), 0);
  for x := x1 to x2 do
    for y := y1 to y2 do
      b[ x, y] := gWorld[ x + bx, y + by];
end;


procedure SetBuffer;
begin
  DetermineScreen;
  if uSplitScreen then
  begin
    SetOneBuffer( cxLittleViewMax, uPos1, uBuffer1);
    SetOneBuffer( cxLittleViewMax, uPos2, uBuffer2);
  end
  else
    SetOneBuffer( cxViewMax, uPos1, uBuffer1);
end;


procedure ShadeBuffer( xMax : Integer; const p : PosRec; var b : BufferType;
                       cx, cy : LongInt;
                       blocksFlag, shadeFlag : Word );

  procedure Test( x, y, dx, dy : Integer );
  begin
    if b[ x + dx, y + dy] and (shadeFlag or cNoWalk or cNoWalkLeft) <> 0 then
      b[ x, y] := b[ x, y] or (shadeFlag or blocksFlag);
    {else if b[ x + dx, y + dy] and (cNoWalk or cNoWalkLeft) <> 0 then
      b[ x, y] := b[ x, y] or (shadeFlag or blocksFlag);}
  end;

  procedure TestRight( x, y, dx, dy : Integer );
  begin
    if b[ x + dx, y + dy] and shadeFlag <> 0 then
      b[ x, y] := b[ x, y] or (shadeFlag or blocksFlag)
    else if b[ x + dx, y + dy] and (cNoWalk or cNoWalkLeft) <> 0 then
    begin
      b[ x, y] := b[ x, y] or (shadeFlag or blocksFlag);
      b[ x + dx, y + dy] := b[ x + dx, y + dy] or blocksFlag;
    end;
  end;

  procedure TestVertical( x, y, dx, dy : Integer );
  begin
    if b[ x + dx, y + dy] and (shadeFlag or cNoWalk) <> 0 then
      b[ x, y] := b[ x, y] or (shadeFlag or blocksFlag);
    {if b[ x + dx, y + dy] and shadeFlag <> 0 then
      b[ x, y] := b[ x, y] or (shadeFlag or blocksFlag)
    else if b[ x + dx, y + dy] and cNoWalk <> 0 then
      b[ x, y] := b[ x, y] or (shadeFlag or blocksFlag);}
  end;

  procedure TestRightEdge( x, y : Integer );
  begin
    if b[ x, y] and cNoWalkLeft <> 0 then
      b[ x, y] := b[ x, y] or blocksFlag;
  end;

var x, y : Integer;
begin
  cx := cx div 32 - p.x div 32;
  cy := cy div 24 - p.y div 24;

  if b[ cx, cy] and cNoWalk <> 0 then
    Inc( cy);

  for x := cx - 1 downto 0 do
  begin
    if cy > 0 then
      Test( x, cy-1, 1, 1);
    Test( x, cy, 1, 0);
    if cy < cyViewMax then
      Test( x, cy+1, 1, -1);
  end;
  for x := cx + 2 to xMax do
  begin
    if cy > 0 then
      TestRight( x, cy-1, -1, 1);
    TestRight( x, cy, -1, 0);
    if cy < cyViewMax then
      TestRight( x, cy+1, -1, -1);
  end;
  for y := cy - 2 downto 0 do
  begin
    if cx > 0 then
      Test( cx-1, y, 1, 1);
    TestVertical( cx, y, 0, 1);
    if cx < xMax then
      TestVertical( cx+1, y, -1, 1);
  end;
  for y := cy + 2 to cyViewMax do
  begin
    if cx > 0 then
      Test( cx-1, y, 1, -1);
    TestVertical( cx, y, 0, -1);
    if cx < xMax then
      TestVertical( cx+1, y, -1, -1);
    TestRightEdge( xMax, y);
  end;
  for x := cx - 2 downto 0 do
    for y := cy - 2 downto 0 do
      Test( x, y, 1, 1);
  for x := cx - 2 downto 0 do
    for y := cy + 2 to cyViewMax do
      Test( x, y, 1, -1);
  for x := cx + 2 to xMax do
    for y := cy - 2 downto 0 do
      TestRight( x, y, -1, 1);
  for x := cx + 2 to xMax do
    for y := cy + 2 to cyViewMax do
      TestRight( x, y, -1, -1);
  for x := cx + 1 to xMax do
  begin
    TestRightEdge( x, 0);
    TestRightEdge( x, cyViewMax);
  end;
  for y := 0 to cyViewMax do
    TestRightEdge( xMax, y);
end;

{
procedure FixBufferIntermediate( blocks, shadow, blocksFlag, shadeFlag : Word );
var x, y : Integer;
begin
  for x := 0 to cxViewMax do
    for y := 0 to cyViewMax do
    begin
      if gBuffer[ x, y] and shadow = shadow then
        gBuffer[ x, y] := (gBuffer[ x, y] and (not shadow)) or shadeFlag
      else
        gBuffer[ x, y] := (gBuffer[ x, y] and (not shadow));
      if gBuffer[ x, y] and blocks = blocks then
        gBuffer[ x, y] := (gBuffer[ x, y] and (not blocks)) or blocksFlag
      else
        gBuffer[ x, y] := (gBuffer[ x, y] and (not blocks));
    end;
end;
}


procedure FixBuffer( max, blocks, shadow : Word; var b : BufferType );
var x, y : Integer;
begin
  for x := 0 to max do
    for y := 0 to cyViewMax do
      if b[ x, y] and shadow = shadow then
        b[ x, y] := cBkgShadow
      else if b[ x, y] and (blocks or cNoWalkLeft) = (blocks or cNoWalkLeft) then
      begin
        case b[ x, y] and 255 of
          cBkgRightT:    b[ x, y] := cBkgShadowRightT;
          cBkgVert:      b[ x, y] := cBkgShadowVert;
          cBkgDownRight: b[ x, y] := cBkgShadowDownRight;
          cBkgDownEnd:   b[ x, y] := cBkgShadowDownEnd;
          cBkgUpRight:   b[ x, y] := cBkgShadowUpRight;
          cBkgUpEnd:     b[ x, y] := cBkgShadowUpEnd;
        end;
      end
      else
        b[ x, y] := b[ x, y] and cBkgFlagMask;
end;


procedure CheckLOS;
var shadow, blocks : Word;
    dx : Integer;
begin
  shadow := 0;
  blocks := 0;
  if gHero1 <> nil then
    with gHero1^ do
    begin
      case direction of
        cDirectionDown,
        cDirectionDownLeft,
        cDirectionLeft: dx := 3;
        cDirectionUp,
        cDirectionUpRight,
        cDirectionRight: dx := 12;
        else dx := 8;
      end;

      if uSplitScreen then
      begin
        ShadeBuffer( cxLittleViewMax, uPos1, uBuffer1,
                     x + dx, y + 10, cBlocks1Flag, cShade1Flag);
        FixBuffer( cxLittleViewMax, cBlocks1Flag, cShade1Flag, uBuffer1);
      end
      else
        ShadeBuffer( cxViewMax, uPos1, uBuffer1,
                     x + dx, y + 10, cBlocks1Flag, cShade1Flag);
      shadow := cShade1Flag;
      blocks := cBlocks1Flag;
    end;
  if gHero2 <> nil then
    with gHero2^ do
    begin
      case direction of
        cDirectionDown,
        cDirectionDownLeft,
        cDirectionLeft: dx := 3;
        cDirectionUp,
        cDirectionUpRight,
        cDirectionRight: dx := 12;
        else dx := 8;
      end;
      if uSplitScreen then
      begin
        ShadeBuffer( cxLittleViewMax, uPos2, uBuffer2,
                     x + dx, y + 10, cBlocks2Flag, cShade2Flag);
        FixBuffer( cxLittleViewMax, cBlocks2Flag, cShade2Flag, uBuffer2);
      end
      else
        ShadeBuffer( cxViewMax, uPos1, uBuffer1,
                     x + dx, y + 10, cBlocks2Flag, cShade2Flag);
      shadow := shadow or cShade2Flag;
      blocks := blocks or cBlocks2Flag;
    end;
  if not uSplitScreen then
    FixBuffer( cxViewMax, blocks, shadow, uBuffer1);
end;


procedure DrawOneBuffer( xMax, xOffs, yOffs : Integer; var b : BufferType );
var x, y,
    yMax,
    xc, yc : Integer;
    offset : Word;

  function GetPic( i : Integer ) : Pointer;
  begin
    if i in cBkgSpecial then
      case i of

        cBkgChaosBox and cBkgFlagMask:
          GetPic := gPics[ cBkgAnimated[ cBkgAnimatedChaosBox, (gFrameCounter div 8) and 3]];

        {cBkgChaosBox2 and cBkgFlagMask:
          GetPic := gPics[ cBkgAnimated[ cBkgAnimatedChaosBox2, (gFrameCounter div 16) and 3]];}

        cBkgExit:
          {if gTargetsLeft > 0 then
            GetPic := gPics[ cExitPic]
          else}
            GetPic := gPics[ cBkgAnimated[ cBkgAnimatedExit, (gFrameCounter div 4) and 3]];

        cBkgFloorFan:
          GetPic := gPics[ cBkgAnimated[ cBkgAnimatedFan, (gFrameCounter div 4) and 3]];

        cBkgBlueBox and cBkgFlagMask:
          GetPic := gPics[ cBlueBoxPic];

        cBkgGreyBox and cBkgFlagMask:
          GetPic := gPics[ cGreyBoxPic];

        cBkgBox and cBkgFlagMask:
          GetPic := gPics[ cBoxPic];

        else
          GetPic := gBkgPics[ cBkgFloorCrater];
      end
    else
      GetPic := gBkgPics[ i and cBkgFlagMask];
  end;

begin
  yc := yoffs;
  y := 0;

  xc := xOffs;
  x := 0;
  while x <= xMax do
  begin
    fPut_Clip( xc, yc, GetPic( b[ x, y])^, False);
    Inc( xc, 32);
    Inc( x);
  end;
  Inc( yc, 24);
  Inc( y);

  yMax := cyViewMax;
  if yc > 8 then
    Dec( yMax);

  while y < yMax do
  begin
    xc := xOffs;
    x := 0;

    fPut_Clip( xc, yc, GetPic( b[ x, y])^, False);
    Inc( xc, 32);
    Inc( x);
    offset := Pt( xc, yc);
    while x < xMax do
    begin
      fPutDW( offset, GetPic( b[ x, y])^);
      {fPut( xc, yc, gBkgPics[ b[ x, y]]^, False);}
      Inc( offset, 32);
      Inc( xc, 32);
      Inc( x);
    end;
    fPut_Clip( xc, yc, GetPic( b[ x, y])^, False);

    Inc( yc, 24);
    Inc( y);
  end;

  if yc < 200 then
  begin
    xc := xOffs;
    x := 0;
    while x <= xMax do
    begin
      fPut_Clip( xc, yc, GetPic( b[ x, y])^, False);
      Inc( xc, 32);
      Inc( x);
    end;
  end;
end;


procedure UpdateAutoMap( xc, yc, xMax : Integer; var b : BufferType );
var x, y : Integer;
begin
  for x := 0 to xMax do
    for y := 0 to cyViewMax do
      if b[ x, y] <> cBkgShadow then
        if not (b[ x, y] in cBkgHidden) or
           (gAutoMap[ x + xc, y + yc] = cBkgShadow) then
          gAutoMap[ x + xc, y + yc] := b[ x, y];
end;


procedure DrawBuffer;
begin
  if uSplitScreen then
  begin
    SetClipRange( 0, 0, 158, 199);
    DrawOneBuffer( cxLittleViewMax, - (uPos1.x and 31), - (uPos1.y mod 24), uBuffer1);
    UpdateAutoMap( uPos1.x div 32, uPos1.y div 24, cxLittleViewMax, uBuffer1);

    SetClipRange( 161, 0, 319, 199);
    DrawOneBuffer( cxLittleViewMax, 160 - (uPos2.x and 31), - (uPos2.y mod 24), uBuffer2);
    UpdateAutoMap( uPos2.x div 32, uPos2.y div 24, cxLittleViewMax, uBuffer2);

    SetClipRange( 0, 0, 319, 199);
    Line( 159, 0, 159, 199, 0);
    Line( 160, 0, 160, 199, 0);
  end
  else begin
    SetClipRange( 0, 0, 319, 199);
    DrawOneBuffer( cxViewMax, - (uPos1.x and 31), - (uPos1.y mod 24), uBuffer1);
    UpdateAutoMap( uPos1.x div 32, uPos1.y div 24, cxViewMax, uBuffer1);
  end;
end;


function InBuffer1( x, y, offset, w, h : Integer; var xOut, yOut : Integer ) : Boolean;
var xc, yc, xMax : Integer;
    b : Word;
begin
  InBuffer1 := False;
  if uSplitScreen then
    SetClipRange( 0, 0, 158, 199)
  else
    SetClipRange( 0, 0, 319, 199);
  xOut := x - uPos1.x;
  yOut := y - uPos1.y;

  if uSplitScreen then
    xMax := 160
  else
    xMax := 320;
  if not Range( xOut, yOut, -w, -h, xMax, 199) then
    Exit;
  xc := (x + w div 2) div 32 - uPos1.x div 32;
  yc := (y + offset) div 24 - uPos1.y div 24;
  if uSplitScreen then
    IFix( xc, 0, cxLittleViewMax)
  else
    IFix( xc, 0, cxViewMax);
  IFix( yc, 0, cxViewMax);

  b := uBuffer1[ xc, yc];
  InBuffer1 := (not (b in cBkgHidden)) or
               ((b <> cBkgShadow) and (x and 31 < 16));
end;


function InBuffer2( x, y, offset, w, h : Integer; var xOut, yOut : Integer ) : Boolean;
var x1, y1, x2, y2 : Integer;
    b : Word;
begin
  InBuffer2 := False;
  if not uSplitScreen then
    Exit;

  x1 := uPos2.x - w;
  y1 := uPos2.y - h;
  x2 := uPos2.x + 160;
  y2 := uPos2.y + 200;
  if not Range( x, y, x1, y1, x2, y2) then
    Exit;
  x1 := (x + w div 2) div 32 - uPos2.x div 32;
  y1 := (y + offset) div 24 - uPos2.y div 24;
  IFix( x1, 0, cxLittleViewMax);
  IFix( y1, 0, cxViewMax);

  b := uBuffer2[ x1, y1];
  if (not (b in cBkgHidden)) or
     ((b <> cBkgShadow) and (x and 31 < 16)) then
  begin
    InBuffer2 := True;
    xOut := 160 + x - uPos2.x;
    yOut := y - uPos2.y;
    SetClipRange( 161, 0, 319, 199);
  end;
end;


function CharacterVisible( c : PCharacter ) : Boolean;
var x, y : Integer;
begin
  CharacterVisible :=
      InBuffer1( c^.x, c^.y, 0, cCharacterWidth, cCharacterHeight, x, y) or
      InBuffer2( c^.x, c^.y, 0, cCharacterWidth, cCharacterHeight, x, y);
end;


end.
