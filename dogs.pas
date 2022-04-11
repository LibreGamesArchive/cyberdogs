Program Dogs;

  uses Crt, Strings,
       SPX_VGA,
       SPX_Fnc, SPX_Txt,
       Keyboard, Joystick, Stick,
       Pics, Globals, Fancy, BigFont,
       GameArea, Screen, Game, Sounds,
       MainMenu, Equip, HallFame,
       TimeServ,
       Elements, Ini;


const

  cDogsPics = 'DOGS.PX';
  cDogsIni  = 'DOGS';


procedure Intro;
var x, y : Integer;
begin
  repeat
    x := Random( cxMax - cxMin - 2) + cxMin + 1;
    y := Random( cyMax - cyMin - 2) + cyMin + 1;
  until gWorld[ x, y] = cBkgFloor;

  if gHero1 <> nil then
  begin
    gHero1^.direction := 4;
    gHero1^.x := x*32;
    gHero1^.y := y*24;
    SetPosFlag( gHero1);
  end;

  if gHero2 <> nil then
  begin
    gHero2^.direction := 4;
    gHero2^.x := x*32 + 16;
    gHero2^.y := y*24;
    SetPosFlag( gHero2);
  end;

  Frame;
  FadeIn( 15, gPalette);
end;


function MissionBonusTime : Integer;
var time : Integer;
begin
  time := 60 + gObjectsToCollect*7 + gMinimumKills*3 + gTargetsLeft*15;
  if gPlayerData[0].playing and gPlayerData[1].playing then
    time := (2*time) div 3;
  MissionBonusTime := time;
end;


procedure MissionIntro( mission : Integer );
var time  : Integer;

  procedure MissionOrders;
  begin
    if gObjectsToCollect > 0 then
    begin
      fPut(  64, 24*2 + 40, gBkgPics[ cBkgFloorDocs]^, False);
      fPut(  96, 24*2 + 40, gBkgPics[ cBkgFloorFolder]^, False);
      fPut( 128, 24*2 + 40, gBkgPics[ cBkgFloorDisk]^, False);
      fPut( 160, 24*2 + 40, gBkgPics[ cBkgFloorCircuit]^, False);
      fPut( 192, 24*2 + 40, gBkgPics[ cBkgFloorTeddy]^, False);
    end;
    if gMinimumKills > 0 then
    begin
      fPut(  64, 24*3 + 40, gBkgPics[ cBkgFloorSkull]^, False);
      fPut( 128, 24*3 + 40, gBkgPics[ cBkgFloorBlood]^, False);
      fPut( 192, 24*3 + 40, gBkgPics[ cBkgFloorBlood]^, False);
      fPut( 32*3, 40, gBkgPics[ cBkgHorz1 and cBkgFlagMask]^, False);
      fPut( 32*4, 40, gBkgPics[ cBkgHorz2 and cBkgFlagMask]^, False);
      fPut( 32*5, 40, gBkgPics[ cBkgHorz4 and cBkgFlagMask]^, False);
      fPut( 32*6, 40, gBkgPics[ cBkgHorz3 and cBkgFlagMask]^, False);
    end;
    if gTargetsLeft > 0 then
    begin
      fPut( 224, 24*3 + 40, gBkgPics[ cBkgChaosBoxRemains]^, False);
      fPut( 224, 24*4 + 40, gBkgPics[ cBkgFloorCrater]^, False);
    end;
    if mission < 9 then
      DrawLetter( 80, 45, cWhite, cBlack, 'Mission #'+St(mission+1))
    else
      DrawLetter( 80, 45, cBrightRed, cBlack, 'The Final Showdown!');
    if gObjectsToCollect > 0 then
      DrawLetter( 70, 55, cYellow, cBlack, 'Retrieve at least '+St( gObjectsToCollect)+' objects');
    if gMinimumKills > 0 then
      DrawLetter( 70, 65, cBrightRed, cBlack, 'Eliminate at least '+St(gMinimumKills)+' enemies');
    if gTargetsLeft > 0 then
      DrawLetter( 70, 75, cOrange, cBlack, 'Blow up '+St( gTargetsLeft)+' enemy structure(s)');
    time := MissionBonusTime;
    DrawLetter( 70, 85, cWhite, cBlack, 'Bonus deadline: '+ St( time div 60) + ':' + Lz( time mod 60, 2));
  end;

  procedure DrawBaddie( count, face, body, percentage : Integer );
  begin
    DrawCharacter( 32 + 32*(1 + count) + 10, 24*3 + 40,
                   cDirectionDown, cDirectionDown,
                   face, body, cGunDogs, 0, 0, cGunIdle);
    DrawLetter( 32 + 32*(1 + count) + 12, 24*3 + 60, cWhite, cBlack, St( percentage) + '%');
  end;

var x, y : Integer;
    count : Integer;
begin
  SetPageActive( 1);
  FillScreen( cSteelPlate);

  for x := 1 to 8 do
    for y := 0 to 4 do
      fPut( x*32, y*24 + 40, gBkgPics[ cBkgFloor]^, False);

  fPut( 32, 24*4 + 40, gBkgPics[ cBkgDownEnd and cBkgFlagMask]^, False);
  fPut( 32, 24*3 + 40, gBkgPics[ cBkgVert and cBkgFlagMask]^, False);
  fPut( 32, 24*2 + 40, gBkgPics[ cBkgVert and cBkgFlagMask]^, False);
  fPut( 32, 24*1 + 40, gBkgPics[ cBkgVert and cBkgFlagMask]^, False);
  fPut( 32, 40, gBkgPics[ cBkgUpLeft and cBkgFlagMask]^, False);
  for x := 2 to 6 do
  begin
    fPut( 32*x, 40, gBkgPics[ cBkgHorz and cBkgFlagMask]^, False);
    fPut( 32*x, 24 + 40, gBkgPics[ cBkgBelowWall and cBkgFlagMask]^, False);
  end;
  fPut( 32*7, 40, gBkgPics[ cBkgRightEnd and cBkgFlagMask]^, False);
  fPut( 32*7, 24 + 40, gBkgPics[ cBkgBelowWall and cBkgFlagMask]^, False);
  fPut( 32*8, 40, gBkgPics[ cBkgRightOfWall and cBkgFlagMask]^, False);
  fPut( 32*8, 24 + 40, gBkgPics[ cBkgBelowAndRightOfWall and cBkgFlagMask]^, False);

  MissionOrders;

  count := 0;
  if gBaddieProbs[ cBaddieGoon] > 0 then
  begin
    DrawBaddie( count, cFaceGrunt, cBrownBody, gBaddieProbs[ cBaddieGoon]);
    Inc( count);
  end;
  if gBaddieProbs[ cBaddieMeanGoon] > 0 then
  begin
    DrawBaddie( count, cFaceBlondGrunt, cBrownBody, gBaddieProbs[ cBaddieMeanGoon]);
    Inc( count);
  end;
  if gBaddieProbs[ cBaddieKiller] > 0 then
  begin
    DrawBaddie( count, cFaceGrunt2, cRedBody, gBaddieProbs[ cBaddieKiller]);
    Inc( count);
  end;
  if gBaddieProbs[ cBaddieRobot] > 0 then
  begin
    DrawBaddie( count, cFaceMechGrunt, cGreyBody, gBaddieProbs[ cBaddieRobot]);
    Inc( count);
  end;
  if gBaddieProbs[ cBaddieLittleBad] > 0 then
  begin
    DrawBaddie( count, cFaceGrunt2, cBlackBody, gBaddieProbs[ cBaddieLittleBad]);
    Inc( count);
  end;
  if gBaddieProbs[ cBaddieBigBad] > 0 then
  begin
    DrawBaddie( count, cFaceBigBadGuy, cBlackBody, gBaddieProbs[ cBaddieBigBad]);
    Inc( count);
  end;

  FadeIn( 20, gPalette);
  while not (AnyKeyDown or StickButtonPressed) do;
  while (AnyKeyDown or StickButtonPressed) do;
  FadeOut( 5, gPalette);
end;


procedure ClearPlayerData( var data : PlayerData );
begin
  FillChar( data.total, SizeOf( data.total), 0);
  data.missions := 0;
  FillChar( data.weapons, SizeOf( data.weapons), 0);
  data.lives := 2;
  data.armor := 20;
  data.closeCombat := 1;
  data.cash := 10000;
end;


procedure UpdatePlayerData( index : Integer );
var i : Integer;
begin
  with gPlayerData[ index] do
  begin
    {
    FillChar( weapons, SizeOf( weapons), 0);
    armor := 15;
    lives := 2;
    closeCombat := 1;}
  end;
end;


procedure MissionSummary( var mission : Integer );

  procedure MissionObjectives( var success : Boolean );
  var objects, kills, targets : Integer;
  begin
    objects := 0;
    kills := 0;
    targets := 0;
    if gPlayerData[0].playing then
    begin
      Inc( objects, gPlayerData[0].mission.objects);
      Inc( kills, gPlayerData[0].mission.kills);
      Inc( targets, gPlayerData[0].mission.targets);
    end;
    if gPlayerData[1].playing then
    begin
      Inc( objects, gPlayerData[1].mission.objects);
      Inc( kills, gPlayerData[1].mission.kills);
      Inc( targets, gPlayerData[1].mission.targets);
    end;
    if gObjectsToCollect > 0 then
    begin
      DrawLetter(  70, 45, cYellow, cBlack, 'Objects collected: ' + St( objects));
      DrawLetter( 170, 45, cYellow, cBlack, 'Required: ' + St( gObjectsToCollect));
    end;
    if gMinimumKills > 0 then
    begin
      DrawLetter(  70, 55, cBrightRed, cBlack, 'Enemies eliminated: ' + St( kills));
      DrawLetter( 170, 55, cBrightRed, cBlack, 'Required: ' + St( gMinimumKills));
    end;
    if (targets > 0) or (gTargetsLeft > 0) then
    begin
      DrawLetter(  70, 65, cOrange, cBlack, 'Targets destroyed: ' + St( targets));
      DrawLetter( 170, 65, cOrange, cBlack, 'Required: ' + St( targets + gTargetsLeft));
    end;
    success := (objects >= gObjectsToCollect) and (kills >= gMinimumKills) and (gTargetsLeft <= 0);
  end;

  procedure OutputResult( c : PCharacter; x, index : Integer; success : Boolean );
  var value : LongInt;
      s     : String;
  begin
    if gPlayerData[ index].playing then
    begin
      with cHeroInfo[ gPlayerData[ index].hero] do
        if index = 0 then
          DrawCharacter( 35, 50,
                         cDirectionDown, cDirectionDown,
                         face, body, cGunDogs, 0, 0, cGunIdle)
        else
          DrawCharacter( 285, 50,
                         cDirectionDown, cDirectionDown,
                         face, body, cGunDogs, 0, 0, cGunIdle);
      with gPlayerData[ index].mission do
      begin
        if gPlayerData[ index].completed then
          DrawLetter( x,  80, cWhite, cBlack, 'TIME: ' + St( time div 60) + ':' + Lz( time mod 60, 2));
        DrawLetter( x,  88, cWhite, cBlack, 'SCORE: ' + St( score));
        DrawLetter( x,  96, cWhite, cBlack, 'OBJECTS: ' + St( objects));
        DrawLetter( x, 104, cWhite, cBlack, 'KILLS: ' + St( kills));
        DrawLetter( x, 112, cWhite, cBlack, 'DEMOLITION: ' + St( demolition) + 'Cr');
        s := 'ACCURACY: ' + St( hits) + '/' + St( shotsFired);
        if shotsFired > 0 then
        begin
          value := (100*hits) div shotsFired;
          s := s + ', ' + St( value) + '%';
          if value > 50 then
          begin
            s := s + ' ' + St( (value-50)*shotsFired) + 'Cr';
            Inc( gPlayerData[ index].cash, (value-50)*shotsFired);
          end;
        end;
        DrawLetter( x, 120, cWhite, cBlack, s);
      end;
      if success and gPlayerData[ index].completed then
      begin
        DrawLetter( x + 50, 104, cWhite, cBlack, 'x50 = ' + St( gPlayerData[ index].mission.kills*50) + 'Cr');
        DrawLetter( x + 50, 96, cWhite, cBlack, 'x100 = ' + St( gPlayerData[ index].mission.objects*100) + 'Cr');
        Inc( gPlayerData[ index].cash, gPlayerData[ index].mission.kills*50);
        Inc( gPlayerData[ index].cash, gPlayerData[ index].mission.objects*100);

        Inc( gPlayerData[ index].cash, 1000);
        value := (MissionBonusTime - gPlayerData[ index].mission.time)*5;
        if value > 0 then
        begin
          DrawLetter( x, 128, cOrange, cBlack, 'TIME BONUS: ' + St( value div 5) + 'secs x50 = ' + St( value*10)+'Cr');
          Inc( gPlayerData[ index].mission.score, value);
          Inc( gPlayerData[ index].cash, value*10);
        end;
        Inc( gPlayerData[ index].missions);
      end;
      Inc( gPlayerData[ index].cash, gPlayerData[ index].mission.demolition);

      Inc( gPlayerData[ index].total.time, gPlayerData[ index].mission.time);
      Inc( gPlayerData[ index].total.score, gPlayerData[ index].mission.score);
      Inc( gPlayerData[ index].total.objects, gPlayerData[ index].mission.objects);
      Inc( gPlayerData[ index].total.kills, gPlayerData[ index].mission.kills);
      Inc( gPlayerData[ index].total.closeCombat, gPlayerData[ index].mission.closeCombat);
      Inc( gPlayerData[ index].total.demolition, gPlayerData[ index].mission.demolition div 10);
      Inc( gPlayerData[ index].total.shotsFired, gPlayerData[ index].mission.shotsFired);
      Inc( gPlayerData[ index].total.hits, gPlayerData[ index].mission.hits);
      Inc( gPlayerData[ index].total.hitsTaken, gPlayerData[ index].mission.hitsTaken);
      DrawLetter( x, 140, cGray, cBlack, 'MISSIONS: ' + St( gPlayerData[ index].missions));
      if gPlayerData[ index].missions >= 10 then
      begin
        DrawLetter( x + 50, 140, cYellow, cBlack, 'Campaign Bonus: ' + St( gPlayerData[ index].total.score div 3));
        Inc( gPlayerData[ index].total.score, gPlayerData[ index].total.score div 3);
        gPlayerData[ index].completed := False;
      end;
      with gPlayerData[ index].total do
      begin
        DrawLetter( x, 148, cGray, cBlack, 'Score: ' + St( score));
        DrawLetter( x + 70, 148, cGray, cBlack, 'Time: ' + St( time div 60) + ':' + Lz( time mod 60, 2));
        DrawLetter( x, 156, cGray, cBlack, 'Objects: ' + St( objects));
        DrawLetter( x, 164, cGray, cBlack, 'Kills: ' + St( kills));
        DrawLetter( x + 70, 164, cGray, cBlack, 'Ninja: ' + St( closeCombat));
        DrawLetter( x, 172, cGray, cBlack, 'Demolition: ' + St( demolition));
        if shotsFired > 0 then
          DrawLetter( x + 70, 172, cGray, cBlack, 'Accuracy: ' + St( (100*hits) div shotsFired) + '%');
      end;

      DrawLetter( x, 180, cYellow, cBlack, 'Cash: ' + St( gPlayerData[ index].cash) + 'Cr');
    end;
  end;

  procedure HallOfFameCandidate( index : Integer );
  begin
    if not gPlayerData[ index].playing then
      Exit;

    if not gPlayerData[ index].completed then
    begin
      ApplyForHallOfFame( index);
      ClearPlayerData( gPlayerData[ index]);
    end
    else
      UpdatePlayerData( index);
  end;

var won : Boolean;
begin
  FadeOut( 10, gPalette);
  SetPageActive( 1);
  FillScreen( cSteelPlate);

  MissionObjectives( won);
  if gPlayerData[ 0].completed or gPlayerData[ 1].completed then
  begin
    if won then
    begin
      if mission < 9 then
        BigText( 50, 20, 'SUCCESS')
      else
        BigText( 50, 20, 'VICTORY');
      PlayMusic( gSuccessSong);
    end
    else begin
      BigText( 30, 20, 'INCOMPLETE');
      PlayMusic( gFailureSong);
    end;
  end
  else begin
    won := False;
    BigText( 60, 20, 'DEFEAT');
    PlayMusic( gFailureSong);
  end;

  OutputResult( gHero1, 25, 0, won);
  OutputResult( gHero2, 175, 1, won);

  FadeIn( 10, gPalette);
  while not (AnyKeyDown or StickButtonPressed) do;

  HallOfFameCandidate( 0);
  HallOfFameCandidate( 1);

  FadeOut( 10, gPalette);
  if won then
    Inc( mission);
end;



procedure SetPlayerData( c : PCharacter; var data : PlayerData );
begin
  data.completed := False;

  if c = nil then
    Exit;

  c^.gunPic := cGunDogs;
  c^.face := cHeroInfo[ data.hero].face;
  c^.body := cHeroInfo[ data.hero].body;
  c^.gunPos := cGunIdle;
  c^.gun.kind := data.weapons[0].kind;
  c^.gun.ammo := data.weapons[0].ammo;
  c^.armor := data.armor;
  c^.lives := data.lives;
  c^.closeCombat := data.closeCombat;

  c^.direction := 4;
  c^.faceDir := 4;
  c^.speed := 8;
end;



procedure SetupPlayers;
var cash : LongInt;
begin
  FillChar( gPlayerData[0].mission, SizeOf( gPlayerData[0].mission), 0);
  FillChar( gPlayerData[1].mission, SizeOf( gPlayerData[1].mission), 0);

  if gPlayerData[0].playing then
    gHero1 := AddCharacter( 0);
  if gPlayerData[1].playing then
    gHero2 := AddCharacter( 1);

  if gPlayerData[0].playing and
     gPlayerData[1].playing and
     (g2PlayerPool and cPoolCash <> 0) then
  begin
    cash := gPlayerData[0].cash + gPlayerData[1].cash;
    GetEquipment( 0, cash);
    GetEquipment( 1, cash);
    gPlayerData[0].cash := cash div 2;
    gPlayerData[1].cash := cash - gPlayerData[0].cash;
  end
  else begin
    GetEquipment( 0, gPlayerData[0].cash);
    GetEquipment( 1, gPlayerData[1].cash);
  end;

  SetPlayerData( gHero1, gPlayerData[0]);
  SetPlayerData( gHero2, gPlayerData[1]);
end;


procedure InitializeGame;
begin
  gPlayerData[0].playing := True;
  gPlayerData[1].playing := False;
  gPlayerData[0].hero := cHeroIce;
  gPlayerData[1].hero := cHeroWarBaby;
  ClearPlayerData( gPlayerData[0]);
  ClearPlayerData( gPlayerData[1]);
end;


procedure SetupAutoMap;
var x, y : Integer;
    c : PCharacter;
begin
  FillChar( gAutoMap, SizeOf( gAutoMap), cBkgShadow);
  for x := cxMin to cxMax do
    for y := cxMin to cxMax do
      if (gWorld[ x, y] in gMissionTargets) or
         (gWorld[ x, y] = cBkgExit) then
        gAutoMap[ x, y] := gWorld[ x, y] and cBkgFlagMask;
  c := gCharacters;
  while c <> nil do
  begin
    if c^.isTarget then
    begin
      x := c^.x div cwWorldMap;
      y := (c^.y + 10) div chWorldMap;
      gAutoMap[ x, y] := cBkgChaosBox and cBkgFlagMask;
    end;
    c := c^.next;
  end;
end;


procedure SetupCampaign( var params : WorldParams );
begin
  RandSeed := gCampaign;
  with params do
  begin
    architectureStyle := Random( cArchitectureStyleMax + 1);
    wallCount := Random( 500) + 200;
    wallLength := Random( 5)*2 + 4;
    roomCount := Random( 40) + 20;
    detailDensity := Random( 40) + 20;
  end;
end;


procedure SetupMission( params : WorldParams; mission : Integer;
                        var movingTargets : Integer );
var targets, objects : Integer;
    percentage : Integer;
    architecture : Integer;
begin
  gBadGuyCount := 5 + 4*mission;
  if gPlayerData[0].playing and gPlayerData[1].playing then
    Inc( gBadGuyCount, gBadGuyCount div 2);
  if gBadGuyCount > 40 then
    gBadGuyCount := 40;
  gMissionTargets := [cBkgChaosBox];
  RandSeed := gCampaign + 10*mission;

  repeat
    architecture := Random( cArchitectureMax + 1);
  until cArchitectures[ architecture].style = params.architectureStyle;
  BuildBkgPics( cArchitectures[ architecture], gPalette);

  gObjectsToCollect := 0;
  gTargetsLeft := 0;
  if (mission > 1) and (Random( 10) < 3) then
    gMinimumKills := 30 + 10*mission
  else
    gMinimumKills := 0;
  targets := Random( 1 + mission div 3);
  movingTargets := 0;
  objects := 6 + 2*mission;
  if gPlayerData[0].playing and gPlayerData[1].playing then
  begin
    Inc( targets, targets div 2);
    objects := 2*objects;
  end;
  if gMinimumKills > 0 then
  begin
    if Random( 10) < 5 then
      objects := 0
    else begin
      objects := objects div 2;
      gMinimumKills := gMinimumKills div 2;
    end;
  end;
  BuildWorld( params, mission, targets, objects);

  FillChar( gBaddieProbs, SizeOf( gBaddieProbs), 0);
  percentage := 10*mission;
  if percentage > 100 then
    percentage := 100;
  gBaddieProbs[ cBaddieGoon] := 100 - percentage;
  case Random( 7 + mission) of
    0: gBaddieProbs[ cBaddieMeanGoon] := percentage;
    1: begin
         gBaddieProbs[ cBaddieMeanGoon] := percentage div 2;
         gBaddieProbs[ cBaddieKiller] := percentage div 2;
       end;
    2: begin
         gBaddieProbs[ cBaddieMeanGoon] := percentage div 2;
         gBaddieProbs[ cBaddieRobot] := percentage div 2;
       end;
    3: begin
         gBaddieProbs[ cBaddieRobot] := percentage div 2;
         gBaddieProbs[ cBaddieKiller] := percentage div 2;
       end;
    4: begin
         gBaddieProbs[ cBaddieMeanGoon] := percentage div 3;
         gBaddieProbs[ cBaddieRobot] := percentage div 3;
         gBaddieProbs[ cBaddieKiller] := percentage div 3;
       end;
    5: gBaddieProbs[ cBaddieRobot] := percentage;
    6: gBaddieProbs[ cBaddieKiller] := percentage;
    7: begin
         gBaddieProbs[ cBaddieRobot] := percentage div 2;
         gBaddieProbs[ cBaddieLittleBad] := percentage div 2;
       end;
    8: begin
         gBaddieProbs[ cBaddieMeanGoon] := percentage div 3;
         gBaddieProbs[ cBaddieRobot] := percentage div 3;
         gBaddieProbs[ cBaddieKiller] := percentage div 3;
       end;
    9, 10, 11, 12: begin
         gBaddieProbs[ cBaddieMeanGoon] := percentage div 5;
         gBaddieProbs[ cBaddieRobot] := percentage div 5;
         gBaddieProbs[ cBaddieKiller] := percentage div 5;
         gBaddieProbs[ cBaddieLittleBad] := percentage div 5;
         gBaddieProbs[ cBaddieBigBad] := percentage div 5;
       end;
   12: gBaddieProbs[ cBaddieLittleBad] := percentage;
   13: begin
         gBaddieProbs[ cBaddieMeanGoon] := percentage div 3;
         gBaddieProbs[ cBaddieKiller] := percentage div 3;
         gBaddieProbs[ cBaddieLittleBad] := percentage div 3;
       end;
   14: begin
         gBaddieProbs[ cBaddieBigBad] := percentage div 3;
         gBaddieProbs[ cBaddieRobot] := (2*percentage) div 3;
       end;
   15: begin
         gBaddieProbs[ cBaddieLittleBad] := percentage div 3;
         gBaddieProbs[ cBaddieBigBad] := percentage div 3;
         gBaddieProbs[ cBaddieKiller] := percentage div 3;
       end;
   16: begin
         gBaddieProbs[ cBaddieRobot] := percentage div 3;
         gBaddieProbs[ cBaddieLittleBad] := percentage div 3;
         gBaddieProbs[ cBaddieBigBad] := percentage div 3;
       end;
    else
      gBaddieProbs[ cBaddieKiller] := percentage;
  end;

  Randomize;
  {
  SetPageActive( 1);
  PutLetter( 10, 50, cWhite, 'SetupMission done.');

  FadeOut( 63, gPalette);
  }
end;


procedure SetupGame;
begin
  ClearAllPosFlags;
end;


procedure SetupBadGuys( bigBads : Integer );
var i : Integer;
begin
  i := 100*bigBads;
  while (bigBads > 0) and (i > 0) do
  begin
    if MakeBadGuy( cBaddieBigBad, True) then
    begin
      Inc( gTargetsLeft);
      Dec( bigBads);
    end;
    Dec( i);
  end;
  for i := 1 to gBadGuyCount do
    MakeAnyBadGuy;
end;


procedure RetrieveIniSettings;

  procedure VerifyStick( i : Integer );
  begin
    if StickLeft( i) or StickRight( i) or StickUp( i) or StickDown( i) then
    begin
      WriteLn( 'Stick ', i, ' may require recalibration...stick disabled');
      Write( 'Neutral: ', gStickLeft[i], ' < x < ', gStickRight[i]);
      WriteLn( ', ', gStickUp[i], ' < y < ', gStickDown[i]);
      WriteLn( 'Currently: x = ', gSticks[i].x, ', y = ', gSticks[i].y);
      if hero1Keys.stick = i then
        hero1Keys.stick := 0;
      if hero2Keys.stick = i then
        hero2Keys.stick := 0;
      Write( 'Press Enter...'); ReadLn;
    end
    else
      WriteLn( 'Stick ', i, ' is in neutral position');
  end;

var i : Integer;
    v : PValue;
    song : PLevelSong;
begin
  WriteLn( 'Loading INI...');
  gIniSettings := nil;
  LoadIniFile( 'DOGS', gIniSettings);

  with hero1Keys do
  begin
    up := FindIniNumber( gIniSettings, 'Player1', 'Up', up);
    down := FindIniNumber( gIniSettings, 'Player1', 'Down', down);
    left := FindIniNumber( gIniSettings, 'Player1', 'Left', left);
    right := FindIniNumber( gIniSettings, 'Player1', 'Right', right);
    shoot := FindIniNumber( gIniSettings, 'Player1', 'Shoot', shoot);
    switch := FindIniNumber( gIniSettings, 'Player1', 'Switch', switch);
    stick := FindIniNumber( gIniSettings, 'Player1', 'Stick', stick);
  end;
  gStickLeft[1] := FindIniNumber( gIniSettings, 'Player1', 'StickLeft', gStickLeft[1]);
  gStickRight[1] := FindIniNumber( gIniSettings, 'Player1', 'StickRight', gStickRight[1]);
  gStickUp[1] := FindIniNumber( gIniSettings, 'Player1', 'StickUp', gStickUp[1]);
  gStickDown[1] := FindIniNumber( gIniSettings, 'Player1', 'StickDown', gStickDown[1]);
  with hero2Keys do
  begin
    up := FindIniNumber( gIniSettings, 'Player2', 'Up', up);
    down := FindIniNumber( gIniSettings, 'Player2', 'Down', down);
    left := FindIniNumber( gIniSettings, 'Player2', 'Left', left);
    right := FindIniNumber( gIniSettings, 'Player2', 'Right', right);
    shoot := FindIniNumber( gIniSettings, 'Player2', 'Shoot', shoot);
    switch := FindIniNumber( gIniSettings, 'Player2', 'Switch', switch);
    stick := FindIniNumber( gIniSettings, 'Player2', 'Stick', stick);
  end;
  gStickLeft[2] := FindIniNumber( gIniSettings, 'Player2', 'StickLeft', gStickLeft[2]);
  gStickRight[2] := FindIniNumber( gIniSettings, 'Player2', 'StickRight', gStickRight[2]);
  gStickUp[2] := FindIniNumber( gIniSettings, 'Player2', 'StickUp', gStickUp[2]);
  gStickDown[2] := FindIniNumber( gIniSettings, 'Player2', 'StickDown', gStickDown[2]);

  PollSticks;
  VerifyStick( 1);
  VerifyStick( 2);

  for i := 1 to cSoundMax do
    gSoundFiles[i] := FindIniString( gIniSettings, 'Sound', gSoundFiles[i], '');

  gMenuSong := FindIniString( gIniSettings, 'Music', 'Menu', gMenuSong);
  gCreditsSong := FindIniString( gIniSettings, 'Music', 'Credits', gMenuSong);
  gFailureSong := FindIniString( gIniSettings, 'Music', 'Failure', gMenuSong);
  gSuccessSong := FindIniString( gIniSettings, 'Music', 'Success', gMenuSong);
  gHallOfFameSong := FindIniString( gIniSettings, 'Music', 'Famous', gMenuSong);

  v := GetIniValues( gIniSettings, 'Music');
  while v <> nil do
  begin
    if Equal( v^.key, 'Level') then
    begin
      New( song);
      song^.song := v^.value;
      song^.next := gLevelSongs;
      gLevelSongs := song;
    end;
    v := v^.next;
  end;
  WriteLn( 'OK');
end;


procedure Initialize;
var palette : RGBList;
    i : Integer;
begin
  InitSticks;
  RetrieveIniSettings;
  Randomize;
  InitializeSound(
      FindIniNumber( gIniSettings, 'Sound', 'Irq', -1),
      FindIniNumber( gIniSettings, 'Sound', 'DMA', -1),
      FindIniBoolean( gIniSettings, 'Sound', 'Quality', False),
      FindIniBoolean( gIniSettings, 'Sound', '486', False),
      FindIniBoolean( gIniSettings, 'Sound', 'Off', False));
  OpenMode( 2);
  FillChar( palette, SizeOf( palette), 0);
  fSetColors( palette);
  InstallKbdHandler;
  SetClipRange( 0, 0, 319, 199);
  for i := 0 to cBkgPicMax do
    GetMem( gBkgPics[i], BuffSize( 32, 24));
  New( gCharacterMap);
  New( gStructureMap);
  New( gNoWalk);
end;


procedure SetIniSettings;
begin
  WriteLn( 'Updating settings...');
  with hero1Keys do
  begin
    SetIniNumber( gIniSettings, 'Player1', 'Up', up);
    SetIniNumber( gIniSettings, 'Player1', 'Down', down);
    SetIniNumber( gIniSettings, 'Player1', 'Left', left);
    SetIniNumber( gIniSettings, 'Player1', 'Right', right);
    SetIniNumber( gIniSettings, 'Player1', 'Shoot', shoot);
    SetIniNumber( gIniSettings, 'Player1', 'Switch', switch);
    SetIniNumber( gIniSettings, 'Player1', 'Stick', stick);
  end;
  SetIniNumber( gIniSettings, 'Player1', 'StickLeft', gStickLeft[1]);
  SetIniNumber( gIniSettings, 'Player1', 'StickRight', gStickRight[1]);
  SetIniNumber( gIniSettings, 'Player1', 'StickUp', gStickUp[1]);
  SetIniNumber( gIniSettings, 'Player1', 'StickDown', gStickDown[1]);
  with hero2Keys do
  begin
    SetIniNumber( gIniSettings, 'Player2', 'Up', up);
    SetIniNumber( gIniSettings, 'Player2', 'Down', down);
    SetIniNumber( gIniSettings, 'Player2', 'Left', left);
    SetIniNumber( gIniSettings, 'Player2', 'Right', right);
    SetIniNumber( gIniSettings, 'Player2', 'Shoot', shoot);
    SetIniNumber( gIniSettings, 'Player2', 'Switch', switch);
    SetIniNumber( gIniSettings, 'Player2', 'Stick', stick);
  end;
  SetIniNumber( gIniSettings, 'Player2', 'StickLeft', gStickLeft[2]);
  SetIniNumber( gIniSettings, 'Player2', 'StickRight', gStickRight[2]);
  SetIniNumber( gIniSettings, 'Player2', 'StickUp', gStickUp[2]);
  SetIniNumber( gIniSettings, 'Player2', 'StickDown', gStickDown[2]);
  WriteLn( 'Saving DOGS.INI...');
  WriteIniFile( 'DOGS', gIniSettings);
  WriteLn( 'Cleaning up...');
  DisposeSettings( gIniSettings);
end;


procedure CleanUp;
var i : Integer;
begin
  RemoveKbdHandler;
  CloseMode;
  WriteLn( 'Closing down sound...');
  CloseDownSound;
  WriteLn( 'Freeing memory...');
  for i := 0 to cBkgPicMax do
    FreeMem( gBkgPics[i], BuffSize( 32, 24));
  Dispose( gCharacterMap);
  Dispose( gStructureMap);
  Dispose( gNoWalk);
  SetIniSettings;
  WriteLn( 'All done!');
end;


procedure GameCycles;
var i, count : Integer;
begin
  Inc( gMissionTime);
  gCyclesPerFrame := 1;
  while gVBlankCounter > 4 do
  begin
    Inc( gCyclesPerFrame);
    UpdateCharacters( False, False);
    MoveAllCharacters;
    MoveBullets( False);
    Dec( gVBlankCounter, 4);
    Inc( gMissionTime);
  end;
  {gVBlankCounter := 0;}
end;


{$F+}
procedure VBlankCounter; interrupt;
begin
  Inc( gVBlankCounter);
end;
{$F-}

procedure MainLoop;
var fastPhaseMask,
    slowPhaseMask : Word;
    fastPhase, slowPhase : Boolean;
    done : Boolean;
    mission : Integer;
    params : WorldParams;
    bigBaddies : Integer;
begin
  {fastPhaseMask := 3;
  slowPhaseMask := 7;}

  mission := 0;
  SetupCampaign( params);
  done := False;
  repeat
    gGameOver := False;

    SetupMission( params, mission, bigBaddies);
    MissionIntro( mission);

    SetupPlayers;
    SetupGame;

    SetupBadGuys( 0);
    SetUpAutoMap;

    Intro;
    PlayMusic( GetNextLevelSong);
    gMissionTime := 0;
    gFrameCounter := 0;
    gVBlankCounter := 0;
    while not (gGameOver or done) do
    begin
      if gCyclesPerFrame = 1 then
        fastPhaseMask := 3
      else if gCyclesPerFrame < 4 then
        fastPhaseMask := 1
      else
        fastPhaseMask := 0;
      if gCyclesPerFrame = 1 then
        slowPhaseMask := 7
      else if gCyclesPerFrame < 4 then
        slowPhaseMask := 3
      else if gCyclesPerFrame < 8 then
        slowPhaseMask := 1
      else
        slowPhaseMask := 0;
      fastPhase := gFrameCounter and fastPhaseMask = 0;
      slowPhase := gFrameCounter and slowPhaseMask = 0;

      UpdateCharacters( fastPhase, slowPhase);
      GetPlayerCommands( slowPhase);
      MoveBadGuys( slowPhase);
      MoveBullets( fastPhase);
      UpdateExplosions( fastPhase);
      GameCycles;
      Frame;
      DoSoundEffects;
      if gFrameCounter and 63 = 0 then
        RelocateBadGuys;

      if KeyDown( keyEsc) then
      begin
        while KeyDown( keyEsc) do;
        SetPageActive( 1);
        DrawLetter( 60, 100, cWhite, cBlack, 'Press Esc again to quit, any other key to continue');
        while not AnyKeyDown do;
        if KeyDown( keyEsc) then
        begin
          ClearPlayerData( gPlayerData[ cIdHero1]);
          ClearPlayerData( gPlayerData[ cIdHero2]);
          done := True;
        end;
        gVBlankCounter := 0;
      end;
    end;

    FadeOut( 1, gPalette);
    if gGameOver then
      MissionSummary( mission);
    RemoveAllElements;
  until done or not (gPlayerData[ cIdHero1].completed or gPlayerData[ cIdHero2].completed);
  if not done then
    DisplayHallOfFame;
  PlayMusic( gMenuSong);
end;


procedure TitleScreen;
begin
  FillScreen( cSteelPlate);
  BigText(  70, 20, 'CYBERDOGS');
  BigText( 120, 45, 'v1.0');
  DrawLetter( 110, 100, cWhite, cBlack, '(C) 1994 Ronny Wester');
  DrawLetter( 110, 110, cYellow, cBlack, 'This game is freeware!');
  DrawLetter( 125, 120, cOrange, cBlack, 'Press any key');
  FadeIn( 20, gPalette);
  while not AnyKeyDown do;
  while AnyKeyDown do;
  FadeOut( 20, gPalette);
end;


procedure ParseParameters;
var i : Integer;
    s : String;
    err : Integer;
begin
  for i := 1 to ParamCount do
  begin
    s := ParamStr(i);
    if (Length( s) >= 2) and (s[1] in [ '/', '-']) then
      case s[2] of
        's': gVSync := False;
        'c': begin
               Delete( s, 1, 2);
               if s <> '' then
                 Val( s, gCampaign, err)
               else begin
                 Randomize;
                 gCampaign := Random( 1024);
               end;
             end;
      end;
  end;
end;


var oldMode : Word;

begin
  oldMode := LastMode;
  if Hi( WindMax) > 25 then
    oldMode := oldMode or Font8x8;

  if test8086 < 2 then
  begin
    WriteLn( 'This game requires 386+. Sorry.');
    Exit;
  end;
  ParseParameters;

  Initialize;

  LoadPics( cDogsPics, gPics, cMaxPics, gPalette);
  with gPalette[0] do
  begin
    red := 0;
    green := 0;
    blue := 0;
  end;

  TitleScreen;

  InitializeGame;

  tsAddRoutine( @VBlankCounter, 1193180 div 240);
  PlayMusic( gMenuSong);
  if MainScreen then
    repeat
      ClearPlayerData( gPlayerData[0]);
      ClearPlayerData( gPlayerData[1]);
      MainLoop;
    until not MainScreen;

  KillPics;
  CleanUp;

  TextMode( oldMode);
end.

