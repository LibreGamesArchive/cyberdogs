unit Screen;


interface

  uses Globals, Elements, Sounds;


procedure Frame;
procedure DrawCharacter( x, y, d, fd, face, body, gunPic, facial, phase, gunPos : Integer );
procedure FillScreen( pic : Integer );
function  Distance( c1, c2 : PCharacter ) : LongInt;


type

  OffsetRec =
    record
      x, y : Integer;
    end;


const

  gVSync : Boolean = True;

  cMuzzleOfs : array [0..7] of OffsetRec =
    ( ( x: 14; y:  3 ),
      ( x: 21; y:  4 ),
      ( x: 23; y: 11 ),
      ( x:  9; y: 16 ),
      ( x:  1; y: 17 ),
      ( x: -5; y: 14 ),
      ( x: -9; y:  8 ),
      ( x: -2; y:  0 )
    );

  cMuzzleDXY : array [0..7] of OffsetRec =
    ( ( x:  0; y: -3 ),
      ( x:  2; y: -2 ),
      ( x:  3; y:  0 ),
      ( x:  2; y:  2 ),
      ( x:  0; y:  3 ),
      ( x: -2; y:  2 ),
      ( x: -3; y:  0 ),
      ( x: -2; y: -2 )
    );


implementation

  uses SPX_Txt, SPX_Fnc, Pics, Buffer, Fancy, GameArea,
       SPX_VGA, KeyBoard, Joystick, Stick;


const

  cHeadOfs : array [0..7] of OffsetRec =
    ( ( x: 3; y: 0 ),
      ( x: 3; y: 0 ),
      ( x: 3; y: 0 ),
      ( x: 3; y: 0 ),
      ( x: 3; y: 0 ),
      ( x: 3; y: 0 ),
      ( x: 3; y: 0 ),
      ( x: 3; y: 0 )
    );

  cBodyOfs : array [0..7] of OffsetRec =
    ( ( x: 0; y: 7 ),
      ( x: 0; y: 7 ),
      ( x: 3; y: 7 ),
      ( x: 0; y: 7 ),
      ( x: 0; y: 7 ),
      ( x: 0; y: 7 ),
      ( x: 2; y: 7 ),
      ( x: 2; y: 7 )
    );

  cGunOfs : array [0..7, 0..cMaxGunPosition] of OffsetRec =
    ( ( ( x: 12; y:  1 ), ( x: 12; y:  3 ), ( x: 12; y:  4 ) ),
      ( ( x: 11; y:  3 ), ( x: 11; y:  4 ), ( x: 10; y:  5 ) ),
      ( ( x: 10; y:  1 ), ( x: 10; y:  8 ), ( x:  9; y:  8 ) ),
      ( ( x: -1; y:  3 ), ( x:  1; y: 10 ), ( x:  0; y:  9 ) ),
      ( ( x: -1; y:  3 ), ( x: -1; y: 10 ), ( x: -1; y:  9 ) ),
      ( ( x: -6; y:  2 ), ( x: -7; y:  8 ), ( x: -6; y:  7 ) ),
      ( ( x: -5; y:  0 ), ( x: -9; y:  5 ), ( x: -8; y:  5 ) ),
      ( ( x: -1; y: -2 ), ( x: -3; y:  0 ), ( x: -2; y:  1 ) )
    );


procedure DrawBackground;
begin
  SetBuffer;
  CheckLOS;
  DrawBuffer;
end;


procedure DrawCharacter( x, y, d, fd, face, body, gunPic, facial, phase, gunPos : Integer );
begin
  case d of
    cDirectionLeft,
    cDirectionUpLeft:
      begin
        fTPut_Clip( x + cGunOfs[ d, gunPos].x, y + cGunOfs[ d, gunPos].y, gPics[ cGunPics[ gunPic, d, gunPos]]^, False);
        fTPut_Clip( x + cBodyOfs[ d].x, y + cBodyOfs[ d].y, gPics[ cBodyPics[ body, d, phase]]^, False);
        fTPut_Clip( x + cHeadOfs[ fd].x, y + cHeadOfs[ fd].y, gPics[ cFacePics[ face, fd, facial]]^, False);
      end;

    cDirectionUp,
    cDirectionUpRight:
      begin
        fTPut_Clip( x + cGunOfs[ d, gunPos].x, y + cGunOfs[ d, gunPos].y, gPics[ cGunPics[ gunPic, d, gunPos]]^, False);
        fTPut_Clip( x + cHeadOfs[ fd].x, y + cHeadOfs[ fd].y, gPics[ cFacePics[ face, fd, facial]]^, False);
        fTPut_Clip( x + cBodyOfs[ d].x, y + cBodyOfs[ d].y, gPics[ cBodyPics[ body, d, phase]]^, False);
      end;

    else
      begin
        fTPut_Clip( x + cBodyOfs[ d].x, y + cBodyOfs[ d].y, gPics[ cBodyPics[ body, d, phase]]^, False);
        fTPut_Clip( x + cHeadOfs[ fd].x, y + cHeadOfs[ fd].y, gPics[ cFacePics[ face, fd, facial]]^, False);
        fTPut_Clip( x + cGunOfs[ d, gunPos].x, y + cGunOfs[ d, gunPos].y, gPics[ cGunPics[ gunPic, d, gunPos]]^, False);
      end;
  end;
end;


procedure DrawDeadCharacter( x, y, dc : Integer );
begin
  fTPut_Clip( x - 8, y - 3, gPics[ cDeathPics[ dc]]^, False);
end;


function Distance( c1, c2 : PCharacter ) : LongInt;
begin
  if Abs( c1^.x - c2^.x) > Abs( c1^.y - c2^.y) then
    Distance := Abs( c1^.x - c2^.x)
  else
    Distance := Abs( c1^.y - c2^.y);
end;


procedure DrawCharacters;
var xScreen, yScreen : Integer;

  procedure DrawIt( c : PCharacter );
  begin
    with c^ do
    begin
      visible := True;
      if dead and (deathCount > 0) then
        DrawDeadCharacter( xScreen, yScreen, deathCount)
      else begin
        sleeping := False;
        if (invincibility <= 0) or Odd( gFrameCounter) then
          DrawCharacter( xScreen, yScreen,
                         direction, faceDir, face, body, gunPic,
                         facial, phase, gunPos);
      end;
    end;
  end;

var c : PCharacter;
    d : Integer;
begin
  gAlert1 := False;
  gAlert2 := False;
  c := gCharacters;
  while c <> nil do
  begin
    with c^ do
    begin
      visible := False;
      if InBuffer1( x, y, 12, cCharacterWidth, cCharacterHeight, xScreen, yScreen) then
        DrawIt( c);
      if InBuffer2( x, y, 12, cCharacterWidth, cCharacterHeight, xScreen, yScreen) then
        DrawIt( c);
      if id = cIdEvil then
      begin
        distanceToPlayer := cLargeDistance;
        if gHero1 <> nil then
        begin
          d := Distance( gHero1, c);
          if d < cProximityDistance then
            gAlert1 := True;
          distanceToPlayer := d;
        end;
        if gHero2 <> nil then
        begin
          d := Distance( gHero2, c);
          if d < cProximityDistance then
            gAlert2 := True;
          if d < distanceToPlayer then
            distanceToPlayer := d;
        end;
      end;
    end;
    c := c^.next;
  end;
end;



procedure DrawBullets;
var b : PBullet;
    xScreen, yScreen : Integer;
begin
  b := gBullets;
  while b <> nil do
  begin
    with b^ do
      if range <> 0 then
      begin
        if InBuffer1( x, y, 0, 0, 0, xScreen, yScreen) then
          fTPut_Clip( xScreen, yScreen, gPics[ cShotPics[ cGunStyles[ kind].bulletStyle, pic]]^, True);
        if InBuffer2( x, y, 0, 0, 0, xScreen, yScreen) then
          fTPut_Clip( xScreen, yScreen, gPics[ cShotPics[ cGunStyles[ kind].bulletStyle, pic]]^, True);
      end;
    b := b^.next;
  end;
end;


procedure DrawExplosions;
var i, b, pic, xScreen, yScreen : Integer;
    f : PFireBall;
begin
  f := gFireBalls;
  while f <> nil do
  begin
    with f^ do
    begin
      pic := stage;
      if (pic >= 0) and (pic <= cMaxFireBalls) then
      begin
        if InBuffer1( x, y, 0, 15, 15, xScreen, yScreen) then
          fTPut_Clip( xScreen, yScreen, gPics[ cExplosionPics[ pic]]^, True);
        if InBuffer2( x, y, 0, 15, 15, xScreen, yScreen) then
          fTPut_Clip( xScreen, yScreen, gPics[ cExplosionPics[ pic]]^, True);
      end;
  	end;
    f := f^.next;
  end;
end;


procedure DrawStatus;

  procedure ShowStatus( x : Integer; c : PCharacter; var data : PlayerData );
  var i : Integer;
      color : Byte;
  begin
    if c <> nil then
    begin
      {DrawLetter( x, 10, cWhite, cBlack, St( data.mission.targets));}
      if c^.armor < 10 then
        color := cRed
      else if c^.armor < 20 then
        color := cOrange
      else
        color := cYellow;
      Bar( x, 21, x + c^.armor*2, 25, color);
      Rectangle( x, 20, x + c^.armor*2, 26, cBlack);
      for i := 1 to c^.lives do
        fTPut( x + i*8, 30, gPics[ cFacePics[ c^.face, 4, 0]]^, False);
      if c^.gun.kind > 0 then
      begin
        fTPut( x, 40, gPics[ cGunStyles[ c^.gun.kind].pic]^, False);
        DrawLetter( x + 20, 55, cWhite, cBlack, St( c^.gun.ammo));
      end;
    end;
  end;

var objects, kills : Integer;
begin
  ShowStatus(  10, gHero1, gPlayerData[0]);
  ShowStatus( 160, gHero2, gPlayerData[1]);

  objects := gObjectsToCollect;
  kills := gMinimumKills;
  if gPlayerData[0].playing then
  begin
    Dec( objects, gPlayerData[0].mission.objects);
    Dec( kills, gPlayerData[0].mission.kills);
  end;
  if gPlayerData[1].playing then
  begin
    Dec( objects, gPlayerData[1].mission.objects);
    Dec( kills, gPlayerData[1].mission.kills);
  end;
  if gAlert1 then
    DrawLetter( 100, 40, cBrightRed, cBlack, 'ALERT');
  if gAlert2 then
    DrawLetter( 250, 40, cBrightRed, cBlack, 'ALERT');

  if objects > 0 then
    DrawLetter( 150, 10, cYellow, cBlack, St( objects));
  if kills > 0 then
    DrawLetter( 150, 20, cBrightRed, cBlack, St( kills));
  if gTargetsLeft > 0 then
    DrawLetter( 150, 30, cOrange, cBlack, St( gTargetsLeft));

  if (objects <= 0) and (kills <= 0) and (gTargetsLeft <= 0) and
     (gFrameCounter and 32 = 0) then
    DrawLetter( 120, 30, 14, cBlack, 'MISSION COMPLETED');

  DrawLetter( 160, 10, cWhite,  cBlack, St( gMissionTime div (60*60)) + ':' +
                                        Lz( (gMissionTime div 60) mod 60, 2));
  DrawLetter( 10, 190, cYellow, cBlack, St( gCyclesPerFrame));
end;


procedure DrawRadar;
var i : Integer;
begin
{
  Bar( 146, 170, 162, 186, cBlack);
  Rectangle( 146, 170, 162, 186, cWhite);
  with gCharacters[0] do
    if active then
      PSet( 147 + ((x div 32) - cxMin) div 4, 171 + ((y div 24) - cyMin) div 4, cWhite);
  with gCharacters[1] do
    if active then
      PSet( 147 + ((x div 32) - cxMin) div 4, 171 + ((y div 24) - cyMin) div 4, cYellow);

  for i := cBadguysStart to cMaxCharacters do
    with gCharacters[i] do
      if active then
        PSet( 147 + ((x div 32) - cxMin) div 4, 171 + ((y div 24) - cyMin) div 4, cDarkRed);
}
end;


function MapCommand : Boolean;
begin
  MapCommand := KeyDown( gMapKey) or
    ((gHero1 <> nil) and (gHero2 <> nil) and StickButton3Down( hero1Keys.stick, hero2Keys.stick))
    or
    ((gHero1 <> nil) and (gHero2 = nil) and StickButton3Down( hero1Keys.stick, 0))
    or
    ((gHero2 <> nil) and (gHero1 = nil) and StickButton3Down( 0, hero2Keys.stick));
end;

procedure ShowMap;
var p : RGBList;
    filter : RGBType;
    x, y : Integer;
    c : PCharacter;

  procedure SetRGB( var c : RGBType; r, g, b : Byte );
  begin
    c.red := r;
    c.green := g;
    c.blue := b;
  end;

  procedure Plot( c1, c2, c3, c4 : Integer );
  begin
    PSet( 80 + x*2, 20 + y*2, c1);
    PSet( 81 + x*2, 20 + y*2, c2);
    PSet( 80 + x*2, 21 + y*2, c3);
    PSet( 81 + x*2, 21 + y*2, c4);
  end;

  procedure Plot2( c1, c2 : Integer );
  begin
    PSet( 80 + x*2, 20 + y*2, c1);
    PSet( 80 + x*2, 21 + y*2, c2);
  end;

begin
  fGetColors( p);
  SetRGB( filter, 48, 0, 48);
  ColorsChange( p, filter);
  SetRGB( p[254], 63,  0,  0);
  SetRGB( p[253],  0, 63, 63);
  p[252] := gPalette[ cWallColorFirst];
  p[251] := gPalette[ cWallColorFirst + 4];
  {SetRGB( p[252],  0, 48, 48);
  SetRGB( p[251],  0, 24, 24);}
  p[250] := gPalette[ cBkgColorFirst];
  p[249] := gPalette[ cBkgColorFirst + 2];
  {SetRGB( p[250],  0,  0, 48);
  SetRGB( p[249],  0,  0, 24);}
  SetRGB( p[248], 63, 63, 63);
  SetRGB( p[247], 63, 63,  0);
  fSetColors( p);

  for y := cyMin to cyMax do
    for x := cxMin to cxMax do
    begin
      case gAutoMap[ x, y] of

        cBkgFloor,
        cBkgFloorSkull,
        cBkgFloorBlood,
        cBkgFloorCrater:
          Plot( 250, 250, 250, 250);

        cBkgBelowWall:
          Plot( 249, 249, 250, 250);

        cBkgRightOfWall:
          Plot( 250, 250, 249, 250);

        cBkgBelowAndRightOfWall:
          Plot( 249, 250, 250, 250);

        cBkgUpLeft and cBkgFlagMask,
        cBkgUpT and cBkgFlagMask,
        cBkgCross and cBkgFlagMask,
        cBkgLeftT and cBkgFlagMask:
          Plot( 252, 252, 252, 251);

        cBkgUpEnd and cBkgFlagMask,
        cBkgUpRight and cBkgFlagMask,
        cBkgVert and cBkgFlagMask,
        cBkgRightT and cBkgFlagMask:
          Plot( 252, 249, 252, 249);

        cBkgRightEnd and cBkgFlagMask,
        cBkgLeftEnd and cBkgFlagMask,
        cBkgDownT and cBkgFlagMask,
        cBkgDownLeft and cBkgFlagMask,
        cBkgHorz and cBkgFlagMask,
        cBkgHorz1 and cBkgFlagMask,
        cBkgHorz2 and cBkgFlagMask,
        cBkgHorz3 and cBkgFlagMask,
        cBkgHorz4 and cBkgFlagMask,
        cBkgHorz5 and cBkgFlagMask:
          Plot( 252, 252, 251, 251);

        cBkgDownRight and cBkgFlagMask,
        cBkgDownEnd and cBkgFlagMask:
          Plot( 252, 249, 251, 249);

        cBkgHorzDoor and cBkgFlagMask,
        cBkgShadow:;

        cBkgShadowRightT,
        cBkgShadowVert,
        cBkgShadowUpRight,
        cBkgShadowUpEnd:
          Plot2( 252, 252);

        cBkgShadowDownRight,
        cBkgShadowDownEnd:
          Plot2( 252, 251);

        cBkgFloorItem1,
        cBkgFloorItem2,
        cBkgFloorItem3,
        cBkgFloorItem4,
        cBkgFloorItem5,
        cBkgFloorItem6,
        cBkgFloorItem7,
        cBkgFloorArmorAddOn,
        cBkgFloorAxe:
          Plot( 253, 253, 249, 249);

        cBkgFloorDocs,
        cBkgFloorFolder,
        cBkgFloorDisk,
        cBkgFloorCircuit,
        cBkgFloorTeddy:
          Plot( 254, 254, 249, 249);

        cBkgChaosBox and cBkgFlagMask:
          Plot( 254, 254, 254, 254);

        cBkgExit:
          Plot( 253, 253, 253, 253);

        else
          Plot( 249, 249, 249, 249);

      end;
    end;

  if gHero1 <> nil then
    with gHero1^ do
    begin
      PSet( 80 + x div 16, 20 + y div 12, 248);
      PSet( 80 + x div 16, 21 + y div 12, 249);
      Rectangle( 69 + x div 16, 11 + y div 12,
                 91 + x div 16, 30 + y div 12, 248);
    end;
  if gHero2 <> nil then
    with gHero2^ do
    begin
      PSet( 80 + x div 16, 20 + y div 12, 247);
      PSet( 80 + x div 16, 21 + y div 12, 249);
      Rectangle( 69 + x div 16, 11 + y div 12,
                 91 + x div 16, 30 + y div 12, 247);
    end;

  PCopyDW( pages[2]^, pages[1]^);
  while MapCommand do
    PollSticks;
  gVBlankCounter := 0;
end;


procedure Frame;
begin
  SetPageActive(2);
  DrawBackground;
  DrawCharacters;
  DrawBullets;
  DrawExplosions;
  SetClipRange( 0, 0, 319, 199);
  DrawStatus;
  DrawRadar;

  if gVBlankCounter < 4 then
    VSinc;
  Dec( gVBlankCounter, 4);
  if gVBlankCounter < 0 then
    gVBlankCounter := 0;

  if MapCommand then
  begin
    ShowMap;
    PCopyDW( pages[2]^, pages[1]^);
    fSetColors( gPalette);
  end
  else
    PCopyDW( pages[2]^, pages[1]^);

  Inc( gFrameCounter);
end;


procedure FillScreen( pic : Integer );
var x, y : Integer;
    offset : Word;
    picPtr : Pointer;
    w, h   : Integer;
begin
  offset := 0;
  picPtr := gPics[ pic];
  ImageDims( picPtr^, w, h);
  if (w <> 32) or (h <> 20) then
    Exit;

  for y := 0 to 9 do
  begin
    for x := 0 to 9 do
    begin
      fPutDW( offset, picPtr^);
      {fPut( x*32, y*20, picPtr^, False);}
      Inc( offset, 32);
    end;
    Inc( offset, 320*19);
  end;
end;


end.
