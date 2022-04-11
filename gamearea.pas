unit GameArea;


interface

  uses Globals;


const

  cNoWalk      = 128;
  cNoWalkLeft  = 64;
  cBkgFlagMask = 63;
  cTrigger     = 256;

  cBkgFloor               =  0;
  cBkgCross               =  1 or cNoWalk;
  cBkgRightT              =  2 or cNoWalkLeft;
  cBkgLeftT               =  3 or cNoWalk;
  cBkgUpT                 =  4 or cNoWalk;
  cBkgDownT               =  5 or cNoWalk;
  cBkgVert                =  6 or cNoWalkLeft;
  cBkgDownRight           =  7 or cNoWalkLeft;
  cBkgDownLeft            =  8 or cNoWalk;
  cBkgDownEnd             =  9 or cNoWalkLeft;
  cBkgUpRight             = 10 or cNoWalkLeft;
  cBkgUpLeft              = 11 or cNoWalk;
  cBkgUpEnd               = 12 or cNoWalkLeft;
  cBkgHorz                = 13 or cNoWalk;
  cBkgRightEnd            = 14 or cNoWalk;
  cBkgLeftEnd             = 15 or cNoWalk;
  cBkgBelowWall           = 16;
  cBkgRightOfWall         = 17;
  cBkgBelowAndRightOfWall = 18;
  cBkgHorzDoor            = 19 or cNoWalk;
  cBkgShadow              = 20;
  cBkgShadowRightT        = 21;
  cBkgShadowVert          = 22;
  cBkgShadowDownRight     = 23;
  cBkgShadowDownEnd       = 24;
  cBkgShadowUpRight       = 25;
  cBkgShadowUpEnd         = 26;
  cBkgFloorSkull          = 27;
  cBkgFloorBlood          = 28;
  cBkgFloorCrater         = 29;
  cBkgHorz1               = 31 or cNoWalk;
  cBkgHorz2               = 32 or cNoWalk;
  cBkgHorz3               = 33 or cNoWalk;
  cBkgHorz4               = 34 or cNoWalk;
  cBkgHorz5               = 35 or cNoWalk;
  cBkgFloorItem1          = 36;
  cBkgFloorItem2          = 37;
  cBkgFloorItem3          = 38;
  cBkgFloorItem4          = 39;
  cBkgFloorItem5          = 40;
  cBkgFloorItem6          = 41;
  cBkgFloorItem7          = 42;
  cBkgBlueBoxRemains      = 43;
  cBkgGreyBoxRemains      = 44;
  cBkgChaosBoxRemains     = 45;
  cBkgFloorDocs           = 46;
  cBkgBoxRemains          = 47;
  cBkgCrate               = 48 or cNoWalk;
  cBkgCrateRemains        = 49;
  cBkgFloorArmorAddOn     = 50;
  cBkgFloorAxe            = 51;
  cBkgFloorFolder         = 52;
  cBkgFloorDisk           = 53;
  cBkgFloorCircuit        = 54;
  cBkgFloorTeddy          = 55;

  cBkgPicMax = 55;

  cBkgChaosBox            = (cBkgPicMax + 1) or cNoWalk;
  cBkgExit                = (cBkgPicMax + 2);
  cBkgBlueBox             = (cBkgPicMax + 3) or cNoWalk;
  cBkgGreyBox             = (cBkgPicMax + 4) or cNoWalk;
  cBkgFloorFan            = (cBkgPicMax + 5);
  cBkgBox                 = (cBkgPicMax + 6) or cNoWalk;


  cBkgHidden = [cBkgShadow..cBkgShadowUpEnd];
  cBkgSpecial = [cBkgChaosBox and cBkgFlagMask, cBkgExit, cBkgFloorFan,
                 cBkgBlueBox and cBkgFlagMask, cBkgGreyBox and cBkgFlagMask,
                 cBkgBox and cBkgFlagMask];

  cwCharMap  = 16;
  chCharMap  = 24;
  cwWalkMap  = 16;
  chWalkMap  = 24;
  cwWorldMap = 32;
  chWorldMap = 24;


type

  WorldParams =
    record
      architectureStyle,
      wallCount,
      wallLength,
      roomCount,
      detailDensity : Integer;
    end;


procedure BuildWorld( params : WorldParams; mission, targets, objects : Integer );


const

  cxFlagMin = cxMin*2;
  cxFlagMax = cxMax*2 + 1;

type

  FlagMap = array [cxFlagMin..cxFlagMax, cyMin..cyMax] of Boolean;
  CounterMap = array [cxFlagMin..cxFlagMax, cyMin..cyMax] of Byte;
  StructureMap = array [cxMin..cxMax, cyMin..cyMax] of
                   record structure : Byte; wreckagePic : Integer end;


var

  gWorld        : array [cxMin..cxMax, cyMin..cyMax] of Word;
  gCharacterMap : ^CounterMap;
  gStructureMap : ^StructureMap;
  gNoWalk       : ^FlagMap;


implementation

  uses SPX_Fnc;


function FindPicIndex( x, y : Integer ) : Byte;

  function Anything( x, y : Integer ) : Boolean;
  begin
    if Range( x, y, cxMin, cyMin, cxMax, cyMax) then
      Anything := gWorld[ x, y] and (cNoWalk or cNoWalkLeft) <> 0
    else
      Anything := False;
  end;

var this : Byte;
    up, down, left, right : Boolean;
begin
  this := gWorld[ x, y];
  if this = 0 then
  begin
    if Anything( x, y-1) then
      FindPicIndex := cBkgBelowWall
    else
      FindPicIndex := cBkgFloor;
    Exit;
  end;

  up    := Anything( x, y-1);
  down  := Anything( x, y+1);
  left  := Anything( x-1, y);
  right := Anything( x+1, y);

  if up and down and left and right then
    FindPicIndex := cBkgCross
  else if up and down and left then
    FindPicIndex := cBkgRightT
  else if up and down and right then
    FindPicIndex := cBkgLeftT
  else if down and left and right then
    FindPicIndex := cBkgUpT
  else if up and left and right then
    FindPicIndex := cBkgDownT
  else if up and down then
    FindPicIndex := cBkgVert
  else if up and left then
    FindPicIndex := cBkgDownRight
  else if up and right then
    FindPicIndex := cBkgDownLeft
  else if up then
    FindPicIndex := cBkgDownEnd
  else if down and left then
    FindPicIndex := cBkgUpRight
  else if down and right then
    FindPicIndex := cBkgUpLeft
  else if down then
    FindPicIndex := cBkgUpEnd
  else if left and right then
    FindPicIndex := cBkgHorz
  else if left then
    FindPicIndex := cBkgRightEnd
  else
    FindPicIndex := cBkgLeftEnd;
end;


function AreaClear( xOrigin, yOrigin, width, height : Integer ) : Boolean;
var x, y : Integer;
begin
  for x := xOrigin to xOrigin + width do
    for y := yOrigin to yOrigin + height do
      if gWorld[ x, y] <> 0 then
      begin
        AreaClear := False;
        Exit;
      end;
  AreaClear := True;
end;


procedure Build( x, y, d, length : Integer );
var l,
    nx, ny,
    dx, dy : Integer;
begin
  if length <= 0 then
    Exit;

  dx := 0;
  dy := 0;
  case d of
    0: dx := -1;
    1: dx := 1;
    2: dy := -1;
    3: dy := 1;
  end;
  nx := 2*(x+dx);
  ny := 2*(y+dy);
  if Range( 2*x, 2*y, cxMin, cyMin, cxMax, cyMax) and
     Range( nx, ny, cxMin, cyMin, cxMax, cyMax) and
     Range( nx-dx, ny-dy, cxMin, cyMin, cxMax, cyMax) and
  	 (gWorld[ nx, ny] = 0) then
  begin
    gWorld[ 2*x, 2*y] := cNoWalk;
    gWorld[ nx-dx, ny-dy] := cNoWalk;
    gWorld[ nx, ny] := cNoWalk;
    Inc( x, dx);
    Inc( y, dy);
    Dec( length);
    if Random(4) = 0 then
    begin
      l := Random( length);
      Build( x, y, Random(4), l);
      Dec( length, l);
    end;
    Build( x, y, d, length);
  end;
end;


procedure BuildWall( wallLength : Integer );
var x, y, d : Integer;
begin
  x := (Random( cxMax - cxMin) + cxMin) div 2;
  y := (Random( cyMax - cyMin) + cyMin) div 2;
  if (gWorld[ 2*x, 2*y] = 0) or
     (x = cxMin) or (x = cxMax) or (y = cyMin) or (y = cyMax) then
    Build( x, y, Random( 4), wallLength);
end;


procedure MakeDoor( x, y, xOffs, yOffs : Integer );
begin
  {if (xOffs > 0) and not Odd( xOffs) then
    Dec( xOffs);
  if (yOffs > 0) and not Odd( yOffs) then
    Dec( yOffs);}
  gWorld[ x + xOffs, y + yOffs] := 1;
end;


procedure MakeRoom( xOrigin, yOrigin, width, height, doors : Integer );
var x, y : Integer;
begin
  for y := yOrigin to yOrigin + height do
  begin
    gWorld[ xOrigin, y] := cNoWalk;
    gWorld[ xOrigin + width, y] := cNoWalk;
  end;
  for x := xOrigin+1 to xOrigin + width-1 do
  begin
    gWorld[ x, yOrigin] := cNoWalk;
    gWorld[ x, yOrigin + height] := cNoWalk;
    for y := yOrigin+1 to yOrigin + height-1 do
      gWorld[ x, y] := 1;
  end;
  if doors and 1 <> 0 then
    MakeDoor( xOrigin, yOrigin, 0, height div 2);
  if doors and 2 <> 0 then
    MakeDoor( xOrigin + width, yOrigin, 0, height div 2);
  if doors and 4 <> 0 then
    MakeDoor( xOrigin, yOrigin, width div 2, 0);
  if doors and 8 <> 0 then
    MakeDoor( xOrigin, yOrigin + height, width div 2, 0);
end;


procedure BuildRoom;
var x, y, w, h : Integer;
begin
  x := Random( cxMax - cxMin - 10) + cxMin; if Odd( x) then Inc( x);
  y := Random( cyMax - cyMin - 10) + cyMin; if Odd( y) then Inc( y);
  w := 2*Random( 2) + 4;
  h := 2*Random( 2) + 4;
  if Range( x, y, cxMin + 2, cyMin + 2, cxMax - 2, cyMax - 2) and
     Range( x + w, y + h, cxMin + 2, cyMin + 2, cxMax - 2, cyMax - 2) and
     AreaClear( x, y, w, h) then
    MakeRoom( x, y, w, h, Random( 15) + 1);
end;



procedure RemoveFilling;
var x, y : Integer;
begin
  for x := cxMin to cxMax do
    for y := cyMin to cyMax do
      if gWorld[ x, y] = 1 then
        gWorld[ x, y] := 0;
end;


procedure FixWorld;
var x, y, pic : Integer;
begin
  RemoveFilling;
  for x := cxMin to cxMax do
    for y := cyMin to cyMax do
    begin
      pic := FindPicIndex( x, y);
      gWorld[ x, y] := pic;
    end;
  for x := cxMin to cxMax-1 do
    for y := cxMin to cyMax-1 do
    begin
      if gWorld[ x, y] = cBkgRightEnd then
      begin
        gWorld[ x+1, y] := cBkgRightOfWall;
        gWorld[ x+1, y+1] := cBkgBelowAndRightOfWall;
      end;
    end;
end;


procedure AddDetails( density : Integer );
var x, y, pic : Integer;
begin
  for x := cxMin+1 to cxMax-1 do
    for y := cxMin+1 to cyMax-1 do
    begin
      if gWorld[ x, y] = cBkgFloor then
        case Random( density) of
          1: gWorld[ x, y] := cBkgFloorSkull;
          2: gWorld[ x, y] := cBkgFloorBlood;
          3: gWorld[ x, y] := cBkgFloorCrater;
          4: if Odd( x) = Odd( y) then
               gWorld[ x, y] := cBkgFloorFan;
          5: if (gWorld[ x, y+1] and (cNoWalk or cNoWalkLeft) = 0) and
                (gWorld[ x, y-1] and (cNoWalk or cNoWalkLeft) = 0) then
             begin
               gWorld[ x, y] := cBkgBlueBox;
               gStructureMap^[ x, y].structure := 100;
               gStructureMap^[ x, y].wreckagePic := cBkgBlueBoxRemains;
             end;
          6: if (gWorld[ x, y+1] and (cNoWalk or cNoWalkLeft) = 0) and
                (gWorld[ x, y-1] and (cNoWalk or cNoWalkLeft) = 0) then
             begin
               gWorld[ x, y] := cBkgGreyBox;
               gStructureMap^[ x, y].structure := 25;
               gStructureMap^[ x, y].wreckagePic := cBkgGreyBoxRemains;
             end;
          7: if (gWorld[ x, y+1] and (cNoWalk or cNoWalkLeft) = 0) and
                (gWorld[ x, y-1] and (cNoWalk or cNoWalkLeft) = 0) then
             begin
               gWorld[ x, y] := cBkgCrate;
               gStructureMap^[ x, y].structure := 25;
               gStructureMap^[ x, y].wreckagePic := cBkgCrateRemains;
             end;
          8: if (gWorld[ x, y+1] and (cNoWalk or cNoWalkLeft) = 0) and
                (gWorld[ x, y-1] and (cNoWalk or cNoWalkLeft) = 0) then
             begin
               gWorld[ x, y] := cBkgBox;
               gStructureMap^[ x, y].structure := 10;
               gStructureMap^[ x, y].wreckagePic := cBkgBoxRemains;
             end;
        end
      else if gWorld[ x, y] = cBkgHorz then
        case Random( 15) of
          1: gWorld[ x, y] := cBkgHorz1;
          2: gWorld[ x, y] := cBkgHorz2;
          3: gWorld[ x, y] := cBkgHorz3;
          4: gWorld[ x, y] := cBkgHorz4;
          5: gWorld[ x, y] := cBkgHorz5;
        end;
    end;
end;


function AddOneObject( what, structure : Byte; wreckPic : Integer ) : Boolean;
var attempts,
    x, y : Integer;
begin
  AddOneObject := True;
  attempts := 0;
  repeat
    x := Random( cxMax - cxMin) + cxMin;
    y := Random( cyMax - cyMin) + cyMin;
    if gWorld[ x, y] = cBkgFloor then
    begin
      gWorld[ x, y] := what;
      gStructureMap^[ x, y].structure := structure;
      gStructureMap^[ x, y].wreckagePic := wreckPic;
      Exit;
    end;
    Inc( attempts);
  until attempts > 100;
  AddOneObject := False;
end;


procedure AddExit;
var i : Integer;
begin
  for i := 1 to 100 do
    if AddOneObject( cBkgExit, 0, 0) then
      Exit;
  gWorld[ cxMin + 1, cyMin + 1] := cBkgFloor;
  gWorld[ cxMin + 2, cyMin + 1] := cBkgFloor;
  gWorld[ cxMin + 3, cyMin + 1] := cBkgFloor;
  gWorld[ cxMin + 1, cyMin + 2] := cBkgFloor;
  gWorld[ cxMin + 2, cyMin + 2] := cBkgExit;
  gWorld[ cxMin + 3, cyMin + 2] := cBkgFloor;
  gWorld[ cxMin + 1, cyMin + 3] := cBkgFloor;
  gWorld[ cxMin + 2, cyMin + 3] := cBkgFloor;
  gWorld[ cxMin + 3, cyMin + 3] := cBkgFloor;
  FixWorld;
end;


procedure AddTargets( mission, targets : Integer );
var i : Integer;
begin
  for i := 1 to targets do
    if AddOneObject( cBkgChaosBox, 250, cBkgChaosBoxRemains) then
      Inc( gTargetsLeft);
end;


procedure AddObjects( mission, objects : Integer );

  function Max( a, b : Integer ) : Integer;
  begin
    if a > b then
      Max := a
    else
      Max := b;
  end;

var i, count : Integer;
begin
  count := 0;
  for i := 1 to Max( 3*objects, 10) do
    case Random( 5) of
      0: if AddOneObject( cBkgFloorDocs, 0, 0) then Inc( count);
      1: if AddOneObject( cBkgFloorFolder, 0, 0) then Inc( count);
      2: if AddOneObject( cBkgFloorDisk, 0, 0) then Inc( count);
      3: if AddOneObject( cBkgFloorCircuit, 0, 0) then Inc( count);
      4: if AddOneObject( cBkgFloorTeddy, 0, 0) then Inc( count);
    end;
  if count > objects*2 then
    gObjectsToCollect := objects
  else
    gObjectsToCollect := count div 2;

  for i := 1 to 4 do
    case Random( 5) of
      0: AddOneObject( cBkgFloorItem1, 0, 0);
      1: AddOneObject( cBkgFloorItem2, 0, 0);
      2: AddOneObject( cBkgFloorItem3, 0, 0);
      3: AddOneObject( cBkgFloorItem4, 0, 0);
      4: AddOneObject( cBkgFloorItem5, 0, 0);
    end;

  for i := 0 to mission do
    AddOneObject( cBkgFloorItem6, 0, 0);

  AddOneObject( cBkgFloorArmorAddOn, 0, 0);
  AddOneObject( cBkgFloorArmorAddOn, 0, 0);
  AddOneObject( cBkgFloorItem7, 0, 0);
  AddOneObject( cBkgFloorItem7, 0, 0);

  if gPlayerData[0].playing and gPlayerData[1].playing then
  begin
    for i := 1 to 4 do
      case Random( 5) of
        0: AddOneObject( cBkgFloorItem1, 0, 0);
        1: AddOneObject( cBkgFloorItem2, 0, 0);
        2: AddOneObject( cBkgFloorItem3, 0, 0);
        3: AddOneObject( cBkgFloorItem4, 0, 0);
        4: AddOneObject( cBkgFloorItem5, 0, 0);
      end;

    for i := 0 to mission do
      AddOneObject( cBkgFloorItem6, 0, 0);

    AddOneObject( cBkgFloorArmorAddOn, 0, 0);
    AddOneObject( cBkgFloorArmorAddOn, 0, 0);
    AddOneObject( cBkgFloorItem7, 0, 0);
    AddOneObject( cBkgFloorItem7, 0, 0);
  end;
end;


procedure SetupNoWalkMap;
var x, y : Integer;
begin
  FillChar( gNoWalk^, SizeOf( gNoWalk^), 0);
  for x := cxMin to cxMax do
    for y := cyMin to cyMax do
    begin
      if gWorld[ x, y] and (cNoWalkLeft or cNoWalk) <> 0 then
        gNoWalk^[ 2*x, y] := True;
      if gWorld[ x, y] and cNoWalk <> 0 then
        gNoWalk^[ 2*x + 1, y] := True;
    end;
  { Far right is a vertical wall, they do not have the cNoWalk flag set -
    technically there's room enough to walk immediately to the right of
    that "edge"-wall. However, I don't want any baddies to be placed there
    so mark it as occupied... }
  for y := cyMin to cyMax do
    gNoWalk^[ cxFlagMax, y] := True;
end;


procedure BuildWorld( params : WorldParams; mission, targets, objects : Integer );
var i : Integer;
begin
  FillChar( gWorld, SizeOf( gWorld), 0);
  FillChar( gStructureMap^, SizeOf( gStructureMap^), 0);
  for i := cyMin to cyMax do
  begin
    gWorld[ cxMin, i] := cNoWalk;
    gWorld[ cxMax, i] := cNoWalk;
  end;
  for i := cxMin to cxMax do
  begin
    gWorld[ i, cyMin] := cNoWalk;
    gWorld[ i, cyMax] := cNoWalk;
  end;

  for i := 1 to params.roomCount do
    BuildRoom;
  for i := 0 to params.wallCount do
    BuildWall( params.wallLength);

  FixWorld;
  AddExit;
  AddTargets( mission, targets);
  AddDetails( params.detailDensity);
  AddObjects( mission, objects);
  SetupNoWalkMap;
end;


end.
