unit Game;


interface

  uses Globals, Elements;


procedure CheckIfGameLost;
procedure GetPlayerCommands( fastPhase : Boolean );
procedure MovePlayer( cmd : Integer; c, c2 : PCharacter; fastPhase : Boolean );
procedure MoveBadGuys( fastPhase : Boolean );
procedure MoveBullets( fastPhase : Boolean );
procedure MoveAllCharacters;
procedure UpdateCharacters( fastPhase, slowPhase : Boolean );
procedure UpdateExplosions( fastPhase : Boolean );
function  MakeBadGuy( baddieType : Byte; makeTarget : Boolean ) : Boolean;
function  MakeAnyBadGuy : Boolean;
procedure RelocateBadGuys;
procedure ClearAllPosFlags;
procedure SetPosFlag( c : PCharacter );


implementation

  uses Keyboard, Joystick, Stick, Pics, GameArea, Buffer, Screen, Sounds;



procedure ClearAllPosFlags;
begin
  FillChar( gCharacterMap^, SizeOf( gCharacterMap^), 0);
end;


function PotentialCollision( x, y : Integer ) : Boolean;
var f : Word;
    x1, x2, y1, y2 : Integer;
begin
  PotentialCollision := False;
  x1 := x div cwCharMap;
  x2 := (x + cCharacterWidth) div cwCharMap;
  y1 := y div chCharMap;
  y2 := (y + cCharacterHeight) div chCharMap;
  if (x1 < cxFlagMin) or (x2 > cxFlagMax) or
     (y1 < cyMin) or (y2 > cyMax) then
    Exit;
  f := gCharacterMap^[ x1, y1];
  f := f + gCharacterMap^[ x1, y2];
  f := f + gCharacterMap^[ x2, y1];
  f := f + gCharacterMap^[ x2, y2];
  PotentialCollision := f > 4;
end;


function PotentialHit( x, y, radius : Integer ) : Boolean;
var f : Word;
    x1, x2, y1, y2 : Integer;
begin
  x1 := (x - radius) div cwCharMap;
  x2 := (x + radius) div cwCharMap;
  y1 := (y - radius) div chCharMap;
  y2 := (y + radius) div chCharMap;
  f := gCharacterMap^[ x1, y1];
  f := f + gCharacterMap^[ x1, y2];
  f := f + gCharacterMap^[ x2, y1];
  f := f + gCharacterMap^[ x2, y2];
  PotentialHit := f > 0;
end;


procedure ClearPosFlag( c : PCharacter );
var x1, x2, y1, y2 : Integer;
begin
  x1 := c^.x div cwCharMap;
  x2 := (c^.x + cCharacterWidth) div cwCharMap;
  y1 := c^.y div chCharMap;
  y2 := (c^.y + cCharacterHeight) div chCharMap;
  Dec( gCharacterMap^[ x1, y1]);
  Dec( gCharacterMap^[ x1, y2]);
  Dec( gCharacterMap^[ x2, y1]);
  Dec( gCharacterMap^[ x2, y2]);
end;


procedure SetPosFlag( c : PCharacter );
var x1, x2, y1, y2 : Integer;
begin
  x1 := c^.x div cwCharMap;
  x2 := (c^.x + cCharacterWidth) div cwCharMap;
  y1 := c^.y div chCharMap;
  y2 := (c^.y + cCharacterHeight) div chCharMap;
  Inc( gCharacterMap^[ x1, y1]);
  Inc( gCharacterMap^[ x1, y2]);
  Inc( gCharacterMap^[ x2, y1]);
  Inc( gCharacterMap^[ x2, y2]);
end;


procedure KillCharacter( c : PCharacter; byChainSaw : Boolean );
var x, y : Integer;
begin
  if byChainSaw then
    DoSound( cChainSawSound)
  else
    DoSound( cScreamSound);
  if c^.isTarget then
    Dec( gTargetsLeft);

  x := (c^.x + cCharacterWidth div 2) div 32;
  y := (c^.y + 12) div 24;
  if gWorld[ x, y] = cBkgFloor then
  begin
    if c^.id < cIdEvil then
      gWorld[ x, y] := cBkgFloorSkull
    else
      gWorld[ x, y] := cBkgFloorBlood;
  end;
  ClearPosFlag( c);
  c^.armor := 0;
  c^.dead := True;
  c^.deathCount := 0;
end;


function HurtCharacter( c : PCharacter; attackerId : Byte; damage : Integer; closeCombat : Boolean ) : Boolean;
begin
  if (damage > 0) and (c^.invincibility = 0) then
  begin
    if attackerId < cIdEvil then
    begin
      if damage < c^.armor then
        Inc( gPlayerData[ attackerId].mission.score, damage)
      else
        Inc( gPlayerData[ attackerId].mission.score, c^.armor);
    end;
    Dec( c^.armor, damage);
    if c^.armor <= 0 then
    begin
      KillCharacter( c, closeCombat and (attackerId <> cIdEvil) and (damage > 1));
      if attackerId < cIdEvil then
      begin
        Inc( gPlayerData[ attackerId].mission.kills);
        if closeCombat then
          Inc( gPlayerData[ attackerId].mission.closeCombat);
      end;
    end;
  end;
end;


function CloseContact( c : PCharacter; x, y : LongInt ) : Boolean;
var c2 : PCharacter;
begin
  CloseContact := False;

  if PotentialCollision( x, y) then
  begin
    c2 := gCharacters;
    while c2 <> nil do
    begin
      if not c2^.dead and (c <> c2) and
         (Abs( x - c2^.x) <= cCharacterWidth) and
         (Abs( y - c2^.y) <= cCharacterHeight) then
      begin
        {if (c2^.id <> cIdEvil) and (c^.id = cIdEvil) and
           (c2^.invincibility > 0) then
          KillCharacter( c, False)
        else}
        if (c2^.invincibility <= 0) and
           ((c2^.id = cIdEvil) xor (c^.id = cIdEvil)) then
          HurtCharacter( c2, c^.id, c^.closeCombat, True);
        if (Abs( x - c2^.x) < Abs( c^.x - c2^.x)) or
            (Abs( y - c2^.y) < Abs( c^.y - c2^.y)) then
          CloseContact := True;
        Exit;
      end;
      c2 := c2^.next;
    end;
  end;
end;


function PositionOK( x, y : LongInt ) : Boolean;
{
  function WorldBlocked( x, y, xMod : Integer ) : Boolean;
  var w : Byte;
  begin
    w := gWorld[ x, y];
    if w and cNoWalk <> 0 then
      WorldBlocked := True
    else if (w and cNoWalkLeft <> 0) and (xMod < 16) then
      WorldBlocked := True
    else
      WorldBlocked := False;
  end;
}
var x1, y1,
    x2, y2 : Integer;
begin
  PositionOk := False;

  Inc( y, 10);
  x1 := x div cwWalkMap;
  y1 := y div chWalkMap;
  x2 := (x + cCharacterWidth) div cwWalkMap;
  y2 := (y + 12) div chWalkMap;

  if (x1 < cxFlagMin) or (x2 > cxFlagMax) or
     (y1 < cyMin) or (y2 > cyMax) then
    Exit;
  if gNoWalk^[ x1, y1] or
     gNoWalk^[ x1, y2] or
     gNoWalk^[ x2, y1] or
     gNoWalk^[ x2, y2] then
      Exit;

  PositionOk := True;
end;


function CheckPosition( c : PCharacter; dx, dy : Integer ) : Boolean;
var nx, ny : LongInt;
begin
  CheckPosition := True;
  nx := c^.x*8 + c^.xFrac + dx * c^.speed;
  ny := c^.y*8 + c^.yFrac + dy * c^.speed;

  if CloseContact( c, nx div 8, ny div 8) then
    Exit;

  if (dx <> 0) and (dy <> 0) and PositionOK( nx div 8, ny div 8) then
  begin
    ClearPosFlag( c);
    c^.x := nx div 8;
    c^.xFrac := nx and 7;
    c^.y := ny div 8;
    c^.yFrac := ny and 7;
    SetPosFlag( c);
  end
  else if (dx <> 0) and PositionOK( nx div 8, c^.y) then
  begin
    ClearPosFlag( c);
    c^.x := nx div 8;
    c^.xFrac := nx and 7;
    SetPosFlag( c);
  end
  else if (dy <> 0) and PositionOK( c^.x, ny div 8) then
  begin
    ClearPosFlag( c);
    c^.y := ny div 8;
    c^.yFrac := ny and 7;
    SetPosFlag( c);
  end
  else
    CheckPosition := False;
end;


function MoveCharacter( c : PCharacter; cmd : Byte; slowPhase : Boolean ) : Boolean;
var dx, dy : Integer;
begin
  MoveCharacter := False;
  dx := 0;
  dy := 0;

  if cmd and cCommandMoving <> 0 then
  begin
    if gFreeMovement or
       (cmd and cCommandFiring = 0) or
       (cmd and cCommandNoTurn <> 0) then
    begin
      if cmd and cCommandLeft <> 0 then
        dx := -1
      else if cmd and cCommandRight <> 0 then
        dx := 1;
      if cmd and cCommandUp <> 0 then
        dy := -1
      else if cmd and cCommandDown <> 0 then
        dy := 1;
      MoveCharacter := CheckPosition( c, dx, dy);

      if slowPhase then
        c^.phase := 1 + (c^.phase and 3);
    end;

    if cmd and cCommandNoTurn = 0 then
      c^.direction := cDirectionFromCmd[ cmd and cCommandMoving];
    c^.faceDir := c^.direction;
  end
  else if slowPhase then
    c^.phase := 0;
end;


procedure CheckIfGameLost;
begin
  if ((gHero1 = nil) or (gHero1^.dead)) and
     ((gHero2 = nil) or (gHero2^.dead)) then
    gGameOver := True;
end;


procedure PickPos( var x, y : Integer );
begin
  if (gHero1 <> nil) and (gHero2 <> nil) then
  begin
    if Random( 2) = 0 then
    begin
      x := gHero1^.x;
      y := gHero1^.y;
    end
    else begin
      x := gHero2^.x;
      y := gHero2^.y;
    end
  end
  else if gHero1 <> nil then
  begin
    x := gHero1^.x;
    y := gHero1^.y;
  end
  else if gHero2 <> nil then
  begin
    x := gHero2^.x;
    y := gHero2^.y;
  end;
  Inc( x, Random( 2*cRelocationDistance));
  Inc( y, Random( 2*cRelocationDistance));
  Dec( x, cRelocationDistance);
  Dec( y, cRelocationDistance);
end;


function MakeBadGuy( baddieType : Byte; makeTarget : Boolean ) : Boolean;
var c : PCharacter;

  function PlacementOk( c : PCharacter ) : Boolean;
  begin
    PlacementOk := False;
    if not PositionOK( c^.x, c^.y) then
      Exit;
    SetPosFlag( c);
    if CloseContact( c, c^.x, c^.y) or
       CharacterVisible( c) then
    begin
      ClearPosFlag( c);
      Exit;
    end;
    PlacementOk := True;
  end;

begin
  c := AddCharacter( cIdEvil);
  c^.direction := 4;
  c^.faceDir := c^.direction;
  c^.gunPos := cGunReady;
  PickPos( c^.x, c^.y);
  c^.gun.kind := cGoonGun;
  c^.gun.ammo := 10000;
  c^.gunPic := cGunDogs;
  c^.isTarget := makeTarget;
  if not c^.isTarget and (Random( 10) = 0) then
    c^.sleeping := False
  else
    c^.sleeping := True;

  if PlacementOk( c) then
  begin
    c^.gun.lock := 120;

    case baddieType of

      cBaddieKiller:
        begin
          c^.body := cRedBody;
          c^.face := cFaceGrunt2;
          c^.tracking := 15;
          c^.moving := 15;
          c^.shooting := 2;
          c^.actionDelay := 20;
          c^.speed := 12;
          c^.armor := 10;
          c^.closeCombat := 1;
          c^.gun.kind := cGoonGun2;
        end;

      cBaddieRobot:
        begin
          c^.body := cGreyBody;
          c^.face := cFaceMechGrunt;
          c^.tracking := 15;
          c^.moving := 15;
          c^.shooting := 5;
          c^.actionDelay := 25;
          c^.speed := 4;
          c^.armor := 20;
          c^.closeCombat := 1;
          c^.gun.kind := cGoonGun3;
        end;

      cBaddieLittleBad:
        begin
          c^.body := cBlackBody;
          c^.face := cFaceGrunt2;
          c^.tracking := 15;
          c^.moving := 15;
          c^.shooting := 1;
          c^.actionDelay := 10;
          c^.speed := 16;
          c^.armor := 10;
          c^.closeCombat := 2;
          c^.gun.kind := cGoonGun2;
        end;

      cBaddieMeanGoon:
        begin
          c^.body := cBrownBody;
          c^.face := cFaceBlondGrunt;
          c^.tracking := 15;
          c^.moving := 15;
          c^.shooting := 5;
          c^.actionDelay := 15;
          c^.speed := 8;
          c^.armor := 15;
          c^.closeCombat := 1;
          c^.gun.kind := cGoonGun2;
        end;

      cBaddieBigBad:
        begin
          c^.body := cBlackBody;
          c^.face := cFaceBigBadGuy;
          c^.tracking := 10;
          c^.moving := 10;
          c^.shooting := 5;
          c^.actionDelay := 10;
          c^.speed := 8;
          c^.armor := 20;
          c^.closeCombat := 3;
          c^.gun.kind := cGoonGun4;
        end;

      else
        begin
          c^.body := cBrownBody;
          c^.face := cFaceGrunt;
          c^.tracking := 10;
          c^.moving := 10;
          c^.shooting := 2;
          c^.actionDelay := 25;
          c^.speed := 6;
          c^.armor := 15;
        end;
    end;

    c^.invincibility := 30;

    MakeBadGuy := True;
  end
  else begin
    RemoveCharacter( c);
    MakeBadGuy := False;
  end;
end;


function MakeAnyBadGuy : Boolean;
var x : Integer;
    kind : Integer;
begin
  x := Random( 100);
  for kind := cBaddieGoon to cBaddieBigBad do
  begin
    if x < gBaddieProbs[ kind] then
    begin
      MakeAnyBadGuy := MakeBadGuy( kind, False);
      Exit;
    end;
    Dec( x, gBaddieProbs[ kind]);
  end;
  MakeAnyBadGuy := MakeBadGuy( cBaddieGoon, False);
end;


procedure Explode( cx, cy : LongInt; bigBang : Boolean );
var f : PFireBall;
    count,
    delay : Integer;
begin
  if bigBang then
    DoSound( cBangSound)
  else
    DoSound( cSmallBangSound);
  for count := 1 to cFireBallsPerExplosion do
  begin
    f := AddFireBall;
    with f^ do
      begin
        stage := 1 - count;
        x := cx - 16 + Random(32);
        y := cy - 16 + Random(32);
      end;
  end;
  cx := cx div cwWorldMap;
  cy := cy div chWorldMap;
  if gWorld[ cx, cy] = cBkgFloor then
    gWorld[ cx, cy] := cBkgFloorCrater;
end;


procedure UpdateCharacters( fastPhase, slowPhase : Boolean );

  function UpdateCharacter( c : PCharacter ) : Boolean;
  begin
    UpdateCharacter := True;
    with c^ do
    begin
      if gun.lock > 0 then
      begin
        if gun.lock > 1{gCyclesPerFrame} then
          Dec( gun.lock)
        else
          gun.lock := 0;
        if (gunPos = cGunRecoil) and (gun.lock + 5 < cGunStyles[ gun.kind].rate) then
          gunPos := cGunReady;
      end
      else begin
        facial := cFaceNormal;
        if id <> cIdEvil then
          gunPos := cGunIdle;
      end;

      if invincibility <> 0 then
        Dec( invincibility);

      if slowPhase and (c^.phase = 0) and (c^.gunPos = cGunIdle) and (Random( 6) = 0) then
        faceDir := (direction + Random( 3) + 7) and 7;

      if not dead then
        Exit;

      if not fastPhase then
        Exit;

      Inc( deathCount);
      if deathCount > cMaxDeath then
      begin
        if id = cIdEvil then
          UpdateCharacter := False
        else begin
          if lives > 1 then
          begin
            Dec( lives);
            armor := gPlayerData[ id].armor;
            dead := False;
            SetPosFlag( c);
            invincibility := 240;
          end
          else if (g2PlayerPool and cPoolLives <> 0) and
                  (gHero1 <> nil) and (gHero2 <> nil) and
                  ((gHero1^.lives > 1) or (gHero2^.lives > 1)) then
          begin
            if c = gHero1 then
              Dec( gHero2^.lives)
            else
              Dec( gHero1^.lives);
            armor := gPlayerData[ id].armor;
            dead := False;
            SetPosFlag( c);
            invincibility := 240;
          end
          else begin
            UpdateCharacter := False;
            CheckIfGameLost;
          end;
        end;
      end;
    end;
  end;

var c : PCharacter;
begin
  c := gCharacters;
  while c <> nil do
  begin
    if UpdateCharacter( c) then
      c := c^.next
    else
      c := RemoveCharacter( c);
  end;
end;


function HitWall( b : PBullet ) : Boolean;
var x, y1, y2 : Integer;
    flag : Byte;
begin
  x := b^.x div cwWalkMap;
  y1 := b^.y div chWalkMap;
  y2 := (b^.y + 10) div chWalkMap;

  HitWall := gNoWalk^[ x, y1] and gNoWalk^[ x, y2];
end;


procedure BlastCharacters( b : PBullet );
var c : PCharacter;
    radius : Integer;
begin
  b^.range := 0;
  Explode( b^.x, b^.y, True);
  c := gCharacters;
  while c <> nil do
  begin
    with c^ do
      if (invincibility <= 0) and not dead and
         ((id = cIdEvil) xor (b^.id = cIdEvil)) and
         (armor > 0) and
    	 (x + 8 > b^.x - 100) and (x + 8 < b^.x + 100) and
    	 (y + 10 > b^.y - 100) and (y + 10 < b^.y + 100) then
        HurtCharacter( c, b^.id, cGunStyles[ b^.kind].power, False);
    c := c^.next;
  end;
end;


function HitCharacter( b : PBullet ) : Boolean;
var c : PCharacter;
    r : Integer;
begin
  r := cGunStyles[ b^.kind].radius;
  if PotentialHit( b^.x, b^.y, r) then
  begin
    c := gCharacters;
    while c <> nil do
    begin
      with c^ do
        if ((b^.id = cIdEvil) xor (id = cIdEvil)) and
           (not dead) and
           (b^.y + r > y) and (b^.y - r < y + cCharacterHeight) and
           (b^.x + r > x) and (b^.x - r < x + cCharacterWidth) then
        begin
          if b^.kind <> cGrenade then
          begin
            {DoSound( cBulletHitSound);}
            if invincibility <= 0 then
              HurtCharacter( c, b^.id, cGunStyles[ b^.kind].power, False);
            if b^.id <> cIdEvil then
              Inc( gPlayerData[ b^.id].mission.hits)
            else if c^.id <> cIdEvil then
              Inc( gPlayerData[ c^.id].mission.hitsTaken);
          end
          else
            BlastCharacters( b);
          HitCharacter := True;
          Exit;
        end;
      c := c^.next;
    end;
  end;
  HitCharacter := False;
end;


procedure CheckForStructureDamage( b : PBullet );

  procedure TargetHit( x, y : Integer );
  begin
    Dec( gTargetsLeft);
    {gWorld[ x, y] := cBkgFloorCrater;
    gNoWalk^[ 2*x, y] := False;
    gNoWalk^[ 2*x + 1, y] := False;}
    if b^.id < cIdEvil then
    begin
      Inc( gPlayerData[ b^.id].mission.targets);
      Inc( gPlayerData[ b^.id].mission.score, 50);
    end;
  end;

  function CheckStructure( x, y : Integer ) : Boolean;
  begin
    CheckStructure := False;
    with gStructureMap^[ x, y] do
    begin
      if structure = 0 then
        Exit;
      CheckStructure := True;
      if cGunStyles[ b^.kind].power >= structure then
      begin
        if b^.id < cIdEvil then
          Inc( gPlayerData[ b^.id].mission.demolition, structure);
        structure := 0;
        Explode( x*cwWorldMap + cwWorldMap div 2, y*chWorldMap + chWorldMap div 2, gWorld[ x, y] in gMissionTargets);
        if gWorld[ x, y] in gMissionTargets then
          TargetHit( x, y);
        gWorld[ x, y] := wreckagePic;
        gNoWalk^[ 2*x, y] := (wreckagePic and (cNoWalk or cNoWalkLeft) <> 0);
        gNoWalk^[ 2*x + 1, y] := (wreckagePic and cNoWalk <> 0);
      end
      else begin
        Dec( structure, cGunStyles[ b^.kind].power);
        if b^.id < cIdEvil then
          Inc( gPlayerData[ b^.id].mission.demolition, cGunStyles[ b^.kind].power);
      end;
    end;

  end;

var x, y1, y2 : Integer;
begin
  {if b^.id = cIdEvil then
    Exit;}

  x := b^.x div cwWorldMap;
  y1 := b^.y div chWorldMap;
  y2 := (b^.y + 10) div chWorldMap;
  if not CheckStructure( x, y1) then
    CheckStructure( x, y2);
end;


procedure MoveBullets( fastPhase : Boolean );
var b : PBullet;

  procedure ShotConnected;
  begin
    with b^ do
    begin
      Inc( x, Random( 4));
      Dec( x, 2);
      Inc( y, Random( 4));
      Dec( y, 2);
      pic := cShotConnectPic;
      range := -3;
    end;
  end;

begin
  b := gBullets;
  while b <> nil do
  begin
    with b^ do
    begin
      if range > 0 then
      begin
        x := x*8 + xFrac;
        y := y*8 + yFrac;
        Inc( x, dx);
        Inc( y, dy);
        xFrac := x and 7;
        yFrac := y and 7;
        x := x div 8;
        y := y div 8;
        Dec( range);
        if range > 0 then
        begin
          if HitWall( b) then
          begin
            CheckForStructureDamage( b);
            if kind = cGrenade then
              BlastCharacters( b)
            else
              ShotConnected;
          end
          else if HitCharacter( b) then
            ShotConnected
          else if fastPhase and (cGunStyles[ kind].animated <> cAnimationNone) then
            pic := (pic + 1) and 7;
        end
        else if kind = cGrenade then
          BlastCharacters( b);
        b := b^.next;
      end
      else begin
        Inc( range);
        if range >= 0 then
          b := RemoveBullet( b)
        else
          b := b^.next;
      end;
    end;
  end;
end;


procedure UpdateExplosions( fastPhase : Boolean );
var f : PFireBall;
begin
  if not fastPhase then
    Exit;

  f := gFireBalls;
  while f <> nil do
    with f^ do
    begin
      Inc( stage);
      if stage > cMaxFireBalls + cFireBallsPerExplosion then
        f := RemoveFireBall( f)
      else
        f := f^.next;
    end;
end;


procedure Shoot( c : PCharacter );
var b : PBullet;
begin
  if (c^.gun.ammo = 0) or (c^.gun.lock <> 0) then
    Exit;

  b := AddBullet;
  with b^ do
  begin
    kind := c^.gun.kind;
    id := c^.id;
    if (c^.id <> cIdEvil) and (kind <> cGrenade) then
      Inc( gPlayerData[ c^.id].mission.shotsFired);
    DoSound( cGunStyles[ kind].sound);
    c^.gun.lock := cGunStyles[ kind].rate;
    c^.gunPos := cGunRecoil;
    c^.facial := cFaceHard;
    c^.faceDir := c^.direction;
    Dec( c^.gun.ammo);
    pic := c^.direction;
    range := cGunStyles[ kind].range;

    x := c^.x + cMuzzleOfs[ c^.direction].x;
    y := c^.y + cMuzzleOfs[ c^.direction].y;
    dx := cMuzzleDXY[ c^.direction].x * cGunStyles[ kind].speed;
    dy := cMuzzleDXY[ c^.direction].y * cGunStyles[ kind].speed;
    xFrac := 0;
    yFrac := 0;
  end;
end;


function LeavingOtherPlayer( cmd : Integer; c1, c2 : PCharacter ) : Boolean;
var x, y : LongInt;
begin
  if (gSplitScreenMode <> cSplitScreenNever) or
     (c1 = nil) or (c2 = nil) or
     c1^.dead or c2^.dead then
  begin
    LeavingOtherPlayer := False;
    Exit;
  end;
  LeavingOtherPlayer := True;

  x := c1^.x;
  y := c1^.y;

  if cmd and cCommandLeft <> 0 then
  begin
    Dec( x);
    if c2^.x - x > cMaxHorizontalDistance then
      Exit;
  end
  else if cmd and cCommandRight <> 0 then
  begin
    Inc( x);
    if x - c2^.x > cMaxHorizontalDistance then
      Exit;
  end;
  if cmd and cCommandUp <> 0 then
  begin
    Dec( y);
    if c2^.y - y > cMaxVerticalDistance then
      Exit;
  end
  else if cmd and cCommandDown <> 0 then
  begin
    Inc( y);
    if y - c2^.y > cMaxVerticalDistance then
      Exit;
  end;
  LeavingOtherPlayer := False;
end;


procedure CheckIfPickup( c : PCharacter );

  function AddWeapon( kind : Byte; ammo : Integer ) : Boolean;
  var i : Integer;
  begin
    AddWeapon := True;
    for i := 0 to cMaxWeaponry do
      if (gPlayerData[ c^.id].weapons[i].kind = kind) or
         (gPlayerData[ c^.id].weapons[i].kind <= 0) then
      begin
        gPlayerData[ c^.id].weapons[i].kind := kind;
        Inc( gPlayerData[ c^.id].weapons[i].ammo, ammo);
        if kind = c^.gun.kind then
          c^.gun.ammo := gPlayerData[ c^.id].weapons[i].ammo;
        Exit;
      end;
    AddWeapon := False;
  end;

var x, y  : Integer;
begin
  x := c^.x div cwWorldMap;
  y := (c^.y + 10) div chWorldMap;
  case gWorld[ x, y] of
    cBkgFloorItem1: if not AddWeapon( cPowerGun,   5) then Exit;
    cBkgFloorItem2: if not AddWeapon( cBlaster,   50) then Exit;
    cBkgFloorItem3: if not AddWeapon( cSprayer,  100) then Exit;
    cBkgFloorItem4: if not AddWeapon( cFlamer,    50) then Exit;
    cBkgFloorItem5: if not AddWeapon( cGrenade,    5) then Exit;
    cBkgFloorItem6: if c^.armor < gPlayerData[ c^.id].armor then
                      c^.armor := gPlayerData[ c^.id].armor
                    else
                      Exit;
    cBkgFloorItem7: Inc( c^.lives);
    cBkgFloorArmorAddOn:
      if c^.armor < 70 then
        c^.armor := 70
      else
        Exit;
    cBkgFloorAxe: Inc( c^.closeCombat, 10);
    cBkgFloorDocs,
    cBkgFloorFolder,
    cBkgFloorDisk,
    cBkgFloorCircuit,
    cBkgFloorTeddy:
      Inc( gPlayerData[ c^.id].mission.objects);

    else
      Exit;
  end;
  DoSound( cPickupSound);
  gWorld[ x, y] := cBkgFloor;
end;


procedure CheckIfExit( c : PCharacter );
var x, y, i : Integer;
begin
  x := c^.x div cwWorldMap;
  y := (c^.y + 10) div chWorldMap;
  if {(gTargetsLeft <= 0) and} (gWorld[ x, y] = cBkgExit) then
  begin
    if c^.gun.kind > 0 then
    begin
      i := 0;
      while gPlayerData[ c^.id].weapons[ i].kind <> c^.gun.kind do
        Inc( i);
      gPlayerData[ c^.id].weapons[ i].ammo := c^.gun.ammo;
    end;
    gPlayerData[ c^.id].completed := True;
    {if c^.lives < gPlayerData[ c^.id].lives then}
    gPlayerData[ c^.id].lives := c^.lives;
    gPlayerData[ c^.id].mission.time := gMissionTime div 60;
    RemoveCharacter( c);
    if (gHero1 = nil) and (gHero2 = nil) then
      gGameOver := True;
  end;
end;


procedure MovePlayer( cmd : Integer; c, c2 : PCharacter; fastPhase : Boolean );
begin
  if (c = nil) or c^.dead or LeavingOtherPlayer( cmd, c, c2) then
    Exit;

  c^.command := cmd;
  MoveCharacter( c, cmd, fastPhase);
  CheckIfPickup( c);
  CheckIfExit( c);

  if cmd and cCommandShoot <> 0 then
    Shoot( c);
end;


function GetStickCommand( const keys : KeyControls; c : PCharacter ) : Byte;
var cmd : Byte;
begin
  cmd := 0;
  if c = nil then
    Exit;

  if StickUp( keys.stick) then
    cmd := cmd or cCommandUp
  else if StickDown( keys.stick) then
    cmd := cmd or cCommandDown;
  if StickLeft( keys.stick) then
    cmd := cmd or cCommandLeft
  else if StickRight( keys.stick) then
    cmd := cmd or cCommandRight;

  if StickButton1( keys.stick) then
    cmd := cmd or cCommandShoot;
  if StickButton2( keys.stick) then
    cmd := cmd or cCommandSwitch;

  GetStickCommand := cmd;
end;


function GetKeybCommand( const keys : KeyControls; c : PCharacter ) : Byte;
var cmd : Byte;
begin
  cmd := 0;
  if c = nil then
    Exit;

  {
  if c^.delay > 0 then
    Dec( c^.delay);
  if keys.rotate then
  begin
    if KeyDown( keys.left) and (c^.delay = 0) then
    begin
      c^.direction := (c^.direction + 7) and 7;
      c^.delay := 6;
    end
    else if KeyDown( keys.right) and (c^.delay = 0) then
    begin
      c^.direction := (c^.direction + 1) and 7;
      c^.delay := 6;
    end;
    if KeyDown( keys.up) then
      cmd := cCmdFromDirection[ c^.direction]
    else if KeyDown( keys.down) then
      cmd := cCmdFromDirection[ (c^.direction + 4) and 7] or cCommandNoTurn;
  end
  }
  if KeyDown( keys.up) then
    cmd := cmd or cCommandUp
  else if KeyDown( keys.down) then
    cmd := cmd or cCommandDown;
  if KeyDown( keys.left) then
    cmd := cmd or cCommandLeft
  else if KeyDown( keys.right) then
    cmd := cmd or cCommandRight;

  if KeyDown( keys.shoot) then
    cmd := cmd or cCommandShoot;
  if KeyDown( keys.switch) then
    cmd := cmd or cCommandSwitch;

  GetKeybCommand := cmd;
end;


procedure SwitchWeapon( index : Integer; c : PCharacter );
var current, next : Integer;
begin
  current := 0;
  while gPlayerData[ index].weapons[ current].kind <> c^.gun.kind do
    Inc( current);
  next := current;
  repeat
    Inc( next);
    if (next > cMaxWeaponry) then
      next := 0;
  until (next = current) or
        ((gPlayerData[ index].weapons[ next].kind <> 0) and
         (gPlayerData[ index].weapons[ next].ammo > 0));

  if next <> current then
  begin
    DoSound( cSwitchSound);
    gPlayerData[ index].weapons[ current].ammo := c^.gun.ammo;
    c^.gun.kind := gPlayerData[ index].weapons[ next].kind;
    c^.gun.ammo := gPlayerData[ index].weapons[ next].ammo;
    c^.gun.lock := 0;
  end;
end;


procedure AdjustCommand( index : Integer; var command : Byte );
begin
  with gPlayerData[ index] do
  begin
    if command and cCommandSwitch <> 0 then
    begin
      button2Down := True;
      if command and cCommandMoving <> 0 then
      begin
        command := command or cCommandNoTurn;
        button2Movement := True;
      end;
      command := command and not cCommandSwitch;
    end
    else begin
      if button2Down and not button2Movement then
        command := command or cCommandSwitch;
      button2Down := False;
      button2Movement := False;
    end;
  end;
end;


procedure GetPlayerCommands( fastPhase : Boolean );
var command : Byte;
begin
  PollSticks;
  if hero1Keys.stick > 0 then
    command := GetStickCommand( Hero1Keys, gHero1)
  else
    command := GetKeybCommand( Hero1Keys, gHero1);
  AdjustCommand( 0, command);

  if command and cCommandSwitch <> 0 then
    SwitchWeapon( 0, gHero1);
  MovePlayer( command, gHero1, gHero2, fastPhase);

  if hero2Keys.stick > 0 then
    command := GetStickCommand( Hero2Keys, gHero2)
  else
    command := GetKeybCommand( Hero2Keys, gHero2);
  AdjustCommand( 1, command);

  if command and cCommandSwitch <> 0 then
    SwitchWeapon( 1, gHero2);
  MovePlayer( command, gHero2, gHero1, fastPhase);
end;


function Facing( c, c2 : PCharacter ) : Boolean;
begin
  case c^.direction of
    0: Facing := (c^.y > c2^.y);
    1: Facing := (c^.y > c2^.y) and (c^.x < c2^.x);
    2: Facing := (c^.x < c2^.x);
    3: Facing := (c^.y < c2^.y) and (c^.x < c2^.x);
    4: Facing := (c^.y < c2^.y);
    5: Facing := (c^.y < c2^.y) and (c^.x > c2^.x);
    6: Facing := (c^.x > c2^.x);
    7: Facing := (c^.y > c2^.y) and (c^.x > c2^.x);
    else Facing := False;
  end;
end;


function FacingPlayer( c : PCharacter ) : Boolean;
var c2 : PCharacter;
begin
  FacingPlayer := True;

  if (gHero1 <> nil) and (not gHero1^.dead) and Facing( c, gHero1) then
    Exit;
  if (gHero2 <> nil) and (not gHero2^.dead) and Facing( c, gHero2) then
    Exit;

  FacingPlayer := False;
end;


procedure GetTargetCoords( c : PCharacter; var x, y : LongInt );
begin
  if (gHero1 <> nil) and not gHero1^.dead and
     (gHero2 <> nil) and not gHero2^.dead then
  begin
    if Distance( c, gHero1) < Distance( c, gHero2) then
    begin
      x := gHero1^.x;
      y := gHero1^.y;
    end
    else begin
      x := gHero2^.x;
      y := gHero2^.y;
    end;
  end
  else if (gHero1 <> nil) and not gHero1^.dead then
  begin
    x := gHero1^.x;
    y := gHero1^.y;
  end
  else if (gHero2 <> nil) and not gHero2^.dead then
  begin
    x := gHero2^.x;
    y := gHero2^.y;
  end
  else begin
    x := c^.x;
    y := c^.y;
  end;
end;


function Hunt( c : PCharacter ) : Byte;
var cmd : Byte;
    x, y, dx, dy : LongInt;
begin
  cmd := 0;

  GetTargetCoords( c, x, y);
  {x := gHorzPos + 150;
  y := gVertPos + 90;}

  dx := Abs( x - c^.x);
  dy := Abs( y - c^.y);

  if 2*dx > dy then
  begin
    if c^.x < x then
      cmd := cmd or cCommandRight
    else if c^.x > x then
      cmd := cmd or cCommandLeft;
  end;
  if 2*dy > dx then
  begin
    if c^.y < y then
      cmd := cmd or cCommandDown
    else if c^.y > y then
      cmd := cmd or cCommandUp;
  end;

  Hunt := cmd;
end;


function DirectionOK( c : PCharacter; dir : Byte ) : Boolean;
begin
  case dir of
    cDirectionUp:
      DirectionOK := PositionOK( c^.x, c^.y - 8);
    cDirectionUpRight:
      DirectionOK := PositionOK( c^.x + 8, c^.y - 8);
    cDirectionRight:
      DirectionOK := PositionOK( c^.x + 8, c^.y);
    cDirectionDownRight:
      DirectionOK := PositionOK( c^.x + 8, c^.y + 8);
    cDirectionDown:
      DirectionOK := PositionOK( c^.x, c^.y + 8);
    cDirectionDownLeft:
      DirectionOK := PositionOK( c^.x - 8, c^.y + 8);
    cDirectionLeft:
      DirectionOK := PositionOK( c^.x - 8, c^.y);
    cDirectionUpLeft:
      DirectionOK := PositionOK( c^.x - 8, c^.y - 8);
  end;
end;


function BrightWalk( c : PCharacter ) : Byte;
begin
  if c^.tryRight then
  begin
    if DirectionOK( c, (c^.currentDir + 7) mod 8) then
    begin
      c^.currentDir := (c^.currentDir + 7) mod 8;
      Dec( c^.turns);
      if c^.turns = 0 then
        c^.detouring := False;
    end
    else if not DirectionOK( c, c^.currentDir) then
    begin
      c^.currentDir := (c^.currentDir + 1) mod 8;
      Inc( c^.turns);
      if c^.turns = 4 then
      begin
        c^.tryRight := False;
        c^.detouring := False;
        c^.turns := 0;
      end;
    end;
  end
  else begin
    if DirectionOK( c, (c^.currentDir + 1) mod 8) then
    begin
      c^.currentDir := (c^.currentDir + 1) mod 8;
      Dec( c^.turns);
      if c^.turns = 0 then
        c^.detouring := False;
    end
    else if not DirectionOK( c, c^.currentDir) then
    begin
      c^.currentDir := (c^.currentDir + 7) mod 8;
      Inc( c^.turns);
      if c^.turns = 4 then
      begin
        c^.tryRight := True;
        c^.detouring := False;
        c^.turns := 0;
      end;
    end;
  end;
  BrightWalk := cCmdFromDirection[ c^.currentDir];
end;


procedure Detour( c : PCharacter );
begin
  c^.detouring := True;
  c^.turns := 1;
  if c^.tryRight then
    c^.currentDir := (cDirectionFromCmd[ c^.command] + 1) mod 8
  else
    c^.currentDir := (cDirectionFromCmd[ c^.command] + 7) mod 8;
end;


procedure MoveBadGuys( fastPhase : Boolean );
var c    : PCharacter;
    roll : Integer;
begin
  c := gCharacters;
  while c <> nil do
  begin
    with c^ do
    begin
      if (id = cIdEvil) and
         not dead and
         (invincibility <= 0) and
         not sleeping then
      begin
        roll := Random( 16);
        if detouring then
          cmd := BrightWalk( c)
        else if delay > 0 then
          Dec( delay)
        else begin
          if roll < tracking then
            cmd := Hunt( c)
          else if roll < moving then
            cmd := cCmdFromDirection[ Random( 8)]
          else
            cmd := 0;
          delay := actionDelay;
        end;
        command := cmd;

        if visible and
           (gun.lock = 0) and
           (roll < shooting) and
      	   FacingPlayer( c) then
          Shoot( c)
        else begin
          if not visible then
            gun.lock := 40;
          if cmd <> 0 then
          begin
            if not MoveCharacter( c, cmd, fastPhase) and
               not detouring then
              Detour( c);
          end;
        end;
      end
      else if sleeping then
        gun.lock := 40;
    end;
    c := c^.next;
  end;
end;


procedure MoveAllCharacters;
var c : PCharacter;
begin
  c := gCharacters;
  while c <> nil do
  begin
    with c^ do
    begin
      if not dead and visible then
        MoveCharacter( c, command, False);
    end;
    c := c^.next;
  end;
end;


procedure RelocateBadGuys;
var c : PCharacter;
    count : Integer;
begin
  c := gCharacters;
  count := 0;
  while c <> nil do
  begin
    with c^ do
    begin
      if id = cIdEvil then
      begin
        if not dead and
           sleeping and
           not isTarget and
           (distanceToPlayer > cRelocationDistance) then
          c := RemoveCharacter( c)
        else begin
          Inc( count);
          c := next;
        end;
      end
      else
        c := next;
    end;
  end;
  while count < gBadGuyCount do
  begin
    MakeAnyBadGuy;
    Inc( count);
  end;
end;


end.
