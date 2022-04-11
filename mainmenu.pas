unit MainMenu;


interface


function MainScreen : Boolean;


implementation

  uses Strings, SPX_VGA, SPX_Txt, SPX_Fnc,
       Keyboard, Globals, Pics, Fancy, BigFont, Screen,
       Joystick, Stick, Equip, Buffer, Sounds, Credits;



procedure Options;

const

  max = 5;


var

  choice : Integer;
  cmd    : Byte;
  done   : Boolean;


  procedure ShowOption( y, index : Integer; s : String );
  begin
    if index = choice then
      ftPut( 75, y, gPics[ cHilitedButton]^, True)
    else
      ftPut( 75, y, gPics[ cButton]^, True);
    DrawLetter( 100, y, cWhite, cBlack, s);
  end;

  procedure OptionsFrame;
  begin
    FillScreen( cSteelPlate);
    BigText( 60, 20, 'OPTIONS');
    DrawLetter( 40, 175, cWhite, cBlack, 'Use left/right to highlight, Enter/button toggles');

    ShowOption( 50, 0, 'Return to main menu');

    case gSplitscreenMode of

      cSplitScreenNever:
        ShowOption(  70, 1, 'No splitscreen');

      cSplitScreenAlways:
        ShowOption(  70, 1, 'Splitscreen always');

      cSplitScreenOften:
        ShowOption(  70, 1, 'Splitscreen often');

      cSplitScreenSeldom:
        ShowOption(  70, 1, 'Splitscreen seldom');

    end;

    if gMusic and gSoundFX then
      ShowOption( 90, 2, 'Music and Sound FX')
    else if gMusic then
      ShowOption( 90, 2, 'Music')
    else if gSoundFX then
      ShowOption( 90, 2, 'Sound FX')
    else
      ShowOption( 90, 2, 'No sound');

    if gFreeMovement then
      ShowOption( 110, 3, 'Move while firing always')
    else
      ShowOption( 110, 3, 'Move while firing only if strafing');

    case gCampaign of
      0:  ShowOption( 130, 4, 'Campaign: Zero');
      17: ShowOption( 130, 4, 'Campaign: Seventeen');
      4711: ShowOption( 130, 4, 'Campaign: 4711');
      57: ShowOption( 130, 4, 'Campaign: 57!!');
      else
        ShowOption( 130, 4, 'Campaign: '+St(gCampaign));
    end;

    if g2PlayerPool and (cPoolLives or cPoolCash) = (cPoolLives or cPoolCash) then
      ShowOption( 150, 5, '2 player: Pool lives + cash')
    else if g2PlayerPool and cPoolLives <> 0 then
      ShowOption( 150, 5, '2 player: Pool lives')
    else if g2PlayerPool and cPoolCash <> 0 then
      ShowOption( 150, 5, '2 player: Pool cash')
    else
      ShowOption( 150, 5, '2 player: Every dog for itself');

    PCopy( 2, 1);
  end;

begin
  FadeOut( 5, gPalette);
  SetPageActive( 2);
  OptionsFrame;
  FadeIn( 20, gPalette);

  done := False;
  choice := 0;
  while not done do
  begin
    if cmd <> GetMenuCommand then
    begin
      cmd := GetMenuCommand;
      case cmd of

        cCommandShoot:
          begin
            case choice of
              0: done := True;
              1: gSplitScreenMode := (gSplitScreenMode + 1) mod 4;
              2: begin
                   if gMusic then
                     gMusic := False
                   else if gSoundFX then
                   begin
                     gSoundFX := False;
                     gMusic := True;
                   end
                   else begin
                     gSoundFX := True;
                     gMusic := True;
                   end;
                   StopMusic;
                   PlayMusic( gMenuSong);
                 end;
              3: gFreeMovement := not gFreeMovement;
              4: if gCampaign = 0 then
                   gCampaign := 17
                 else if gCampaign = 17 then
                   gCampaign := 4711
                 else if gCampaign = 4711 then
                   gCampaign := 57
                 else
                   gCampaign := 0;
              5: if g2PlayerPool = cPoolLives or cPoolCash then
                   g2PlayerPool := 0
                 else
                   Inc( g2PlayerPool);
            end;
            PlaySound( cBigGunSound);
          end;

        cCommandUp:
          if choice > 0 then
            Dec( choice)
          else
            choice := max;

        cCommandDown:
          if choice < max then
            Inc( choice)
          else
            choice := 0;

      end;
      OptionsFrame;
    end;
  end;
  FadeOut( 5, gPalette);
end;


procedure SelectHero( var hero : Byte; otherHero : Byte );
var delay : Integer;
    faceDir : array [0..cMaxHeros] of Byte;
    dir     : array [0..cMaxHeros] of Byte;
    gunPos  : array [0..cMaxHeros] of Byte;

  procedure SelectFrame;
  var x, y : Integer;
      h : Byte;
  begin
    if delay <= 0 then
    begin
      for h := 0 to cMaxHeros do
      begin
        dir[ h] := Random( 3) + 3;
        faceDir[ h] := dir[ h] + Random( 3) - 1;
        if Random( 4) < 2 then
          gunPos[ h] := cGunIdle
        else
          gunPos[ h] := cGunReady;
      end;
      delay := 30;
    end;

    for x := 1 to 8 do
      for y := 0 to 4 do
        fPut( x*32, y*24 + 40, gPics[ cBkgPics[ 1, 0]]^, False);
    x := (320 - 40 * (cMaxHeros+1)) div 2;
    for h := 0 to cMaxHeros do
    begin
      if hero = h then
        ftPut( x + h*40 + 10, 60, gPics[ cHilitedButton]^, True)
      else if h <> otherHero then
        ftPut( x + h*40 + 10, 60, gPics[ cButton]^, True);
      with cHeroInfo[ h] do
      begin
        if h <> otherHero then
        begin
          DrawCharacter( x + h*40, 80, dir[ h], faceDir[ h], face, body, cGunDogs, 0, 0, cGunIdle);
          DrawLetter( x + h*40, 110, cWhite, cBlack, name);
        end
        else begin
          DrawCharacter( x + h*40, 80, cDirectionUp, cDirectionUp, face, body, cGunDogs, 0, 0, cGunIdle);
          DrawLetter( x + h*40, 110, cRed, cBlack, name);
        end;
      end;
    end;

    Dec( delay);
    VSinc;
    PCopy( 2, 1);
  end;

var h   : Byte;
    cmd : Byte;
begin
  delay := 0;
  FadeOut( 5, gPalette);
  SetPageActive( 2);
  FillScreen( cSteelPlate);
  BigText( 60, 20, 'HEROES');
  DrawLetter( 40, 175, cWhite, cBlack, 'Use left/right to highlight, Enter/button to select');
  SelectFrame;
  FadeIn( 5, gPalette);

  repeat
    SelectFrame;
    if cmd <> GetMenuCommand then
    begin
      cmd := GetMenuCommand;
      if (cmd and cCommandLeft <> 0) and (hero > 0) and ((otherHero > 0) or (hero > 1)) then
      begin
        Dec( hero);
        if hero = otherHero then
          Dec( hero)
      end;
      if (cmd = cCommandRight) and (hero < cMaxHeros) and ((otherHero <> cMaxHeros) or (hero < cMaxHeros-1)) then
      begin
        Inc( hero);
        if hero = otherHero then
          Inc( hero);
      end;
    end;
  until cmd and cCommandShoot <> 0;
  PlaySound( cSwitchSound);
  FadeOut( 5, gPalette);
end;


procedure DefineKeys( index : Integer; var keys : KeyControls );
var delay   : Integer;
    faceDir : Integer;

  procedure ControlFrame;
  begin
    SetPageActive( 2);
    fPut(  0, 60, gPics[ cSteelPlate]^, False);
    fPut( 32, 60, gPics[ cSteelPlate]^, False);
    fPut(  0, 80, gPics[ cSteelPlate]^, False);
    fPut( 32, 80, gPics[ cSteelPlate]^, False);
    with cHeroInfo[ gPlayerData[ index].hero] do
    begin
      DrawCharacter( 25, 65, cDirectionDownLeft, faceDir, face, body, cGunDogs, cFaceNormal, 0, cGunIdle);
      PutLetter( 20, 88, cWhite, name);
    end;
    VSinc;
    CopyRect( 0, 60, 63, 99, pages[2]^, pages[1]^);
    SetPageActive( 1);
    Dec( delay);
    if delay < 0 then
    begin
      faceDir := Random( 3) + 3;
      delay := 25;
    end;
  end;

  procedure ShowKey( y : Integer; key : Byte; color : Byte );
  begin
    Bar( 170, y, 255, y+9, cBlack);
    if keyNames[ key] <> nil then
      PutLetter( 170, y, color, StrPas( keyNames[ key]))
    else
      PutLetter( 170, y, color, 'Strange?!?');
  end;

  procedure GetKey( y : Integer; var key : Byte );
  begin
    ShowKey( y, key, cYellow);
    repeat
      key := GetKeyDown;
      ControlFrame;
    until not (key in [0, keyEsc]);
    ShowKey( y, key, cRed);
    PlaySound( cBigGunSound);
    while AnyKeyDown do
      ControlFrame;
  end;

  procedure ClearDisplay;
  begin
    Bar( 64, 80, 255, 179, cBlack);
  end;

  procedure ReleaseButton( y : Byte );
  begin
    PutLetter( 70, y, cBrightRed, 'Release the button, please');
    while StickAnyButton( keys.stick) do
    begin
      VSinc;
      PollSticks;
      ControlFrame;
    end;
    Bar( 64, y, 255, y + 9, cBlack);
  end;

  procedure CalibrateStick( var stick : Byte );

    procedure WaitForStick;
    begin
      while not StickAnyButton( stick) do
      begin
        VSinc;
        PollSticks;
        ControlFrame;
      end;
      PlaySound( cBigGunSound);
    end;

  var xCenter, yCenter,
      xMin, yMin,
      xMax, yMax : Integer;
  begin
    Bar( 64, 100, 255, 179, cBlack);

    ReleaseButton( 100);

    PutLetter( 70, 100, cBrightRed, 'Move stick top left and press any button');
    WaitForStick;
    xMin := gSticks[ stick].x;
    yMin := gSticks[ stick].y;
    Bar( 64, 100, 255, 109, cBlack);
    PutLetter( 70, 100, cRed, '[ '+St( xMin)+', '+St( yMin)+']');
    ReleaseButton( 110);

    PutLetter( 70, 110, cBrightRed, 'Move stick bottom right and press any button');
    WaitForStick;
    xMax := gSticks[ stick].x;
    yMax := gSticks[ stick].y;
    Bar( 64, 110, 255, 119, cBlack);
    PutLetter( 70, 110, cRed, '[ '+St( xMax)+', '+St( yMax)+']');
    ReleaseButton( 120);

    PutLetter( 70, 120, cBrightRed, 'Center stick and press any button');
    WaitForStick;
    xCenter := gSticks[ stick].x;
    yCenter := gSticks[ stick].y;
    Bar( 64, 120, 255, 129, cBlack);
    PutLetter( 70, 120, cRed, '[ '+St( xCenter)+', '+St( yCenter)+']');
    ReleaseButton( 130);

    if (xMin < xCenter) and (xCenter < xMax) and
       (yMin < yCenter) and (yCenter < yMax) then
    begin
      gStickLeft[ stick] := (xMin + xCenter) div 2;
      gStickRight[ stick] := (xCenter + xMax) div 2;
      gStickUp[ stick] := (yMin + yCenter) div 2;
      gStickDown[ stick] := (yCenter + yMax) div 2;
      PutLetter( 70, 130, cRed, 'Calibration complete');
    end
    else begin
      PutLetter( 70, 130, cBrightRed, 'Error calibrating stick!');
      PutLetter( 70, 140, cRed, 'Press any key');
      stick := 0;
      while not AnyKeyDown do;
    end;
  end;

begin
  FadeOut( 5, gPalette);
  SetPageActive( 1);
  FillScreen( cSteelPlate);
  ClearDisplay;

  BigText( 20, 25, 'CONTROLS');

  FadeIn( 5, gPalette);
  delay := 25;
  faceDir := 4;

  keys.stick := 0;
  InitSticks;
  if gSticks[1].present or gSticks[2].present then
  begin
    PutLetter( 70, 90, cRed, 'Press button for joystick or hit any key');
    repeat
      ControlFrame;
      VSinc;
      PollSticks;
      if StickAnyButton(1) then
        keys.stick := 1;
      if StickAnyButton(2) then
        keys.stick := 2;
    until AnyKeyDown or (keys.stick > 0);
  end;
  while AnyKeyDown do
    ControlFrame;

  if keys.stick > 0 then
  begin
    PlaySound( cBigGunSound);
    ClearDisplay;
    PutLetter( 70,  90, cRed, 'Joystick ' + St( keys.stick) + ' selected');
    ReleaseButton( 100);
    PutLetter( 70, 100, cRed, 'Press button 2 to calibrate stick');
    PutLetter( 70, 110, cRed, 'Press button 1 to exit');
    repeat
      VSinc;
      PollSticks;
    until StickAnyButton( keys.stick);
    PlaySound( cBigGunSound);
    if StickButton2( keys.stick) then
      CalibrateStick( keys.stick);

    ClearDisplay;
    PutLetter( 70, 160, cRed, 'Esc is reserved');
    PutLetter( 70, 90, cRed, 'Show map');
    GetKey( 90, gMapKey);
  end
  else begin
    keys.rotate := False;

    ClearDisplay;
    PutLetter( 70, 160, cRed, 'Esc is reserved');

    if keys.rotate then
    begin
      PutLetter( 70,  90, cRed, 'CounterClockwise');
      PutLetter( 70, 100, cRed, 'Clockwise');
      PutLetter( 70, 110, cRed, 'Forward');
      PutLetter( 70, 120, cRed, 'Backward');
    end
    else begin
      PutLetter( 70,  90, cRed, 'Left');
      PutLetter( 70, 100, cRed, 'Right');
      PutLetter( 70, 110, cRed, 'Up');
      PutLetter( 70, 120, cRed, 'Down');
    end;
    PutLetter( 70, 130, cRed, 'Fire');
    PutLetter( 70, 140, cRed, 'Change weapon');

    PutLetter( 70, 150, cRed, 'Show map');

    ShowKey(  90, keys.left,   cDarkRed);
    ShowKey( 100, keys.right,  cDarkRed);
    ShowKey( 110, keys.up,     cDarkRed);
    ShowKey( 120, keys.down,   cDarkRed);
    ShowKey( 130, keys.shoot,  cDarkRed);
    ShowKey( 140, keys.switch, cDarkRed);
    ShowKey( 150, gMapKey, cDarkRed);

    GetKey(  90, keys.left);
    GetKey( 100, keys.right);
    GetKey( 110, keys.up);
    GetKey( 120, keys.down);
    GetKey( 130, keys.shoot);
    GetKey( 140, keys.switch);
    GetKey( 150, gMapKey);
  end;


  FadeOut( 5, gPalette);
end;


function MainScreen : Boolean;

const

  cTitle    = 'CYBERDOGS';
  cxPlayer1 = 10;
  cyPlayer1 = 70;
  cxPlayer2 = 295;
  cyPlayer2 = 70;
  cyTitle   = 20;
  cyText    = 50;

var

  xTitle,
  xText       : Integer;
  cmd         : Byte;
  choice,
  faceDir1,
  faceDir2,
  delay       : Integer;
  done        : Boolean;

  procedure MainScreenIntro;
  var i : Integer;
      dx, dy : Integer;
      laps : Integer;
      y : Integer;
  begin
    SetPageActive( 1);
    FillScreen( cSteelPlate);
    SetPageActive( 2);
    FadeIn( 20, gPalette);

    { Have title appear }
    dx := 10;
    dy := 10;
    laps := 10 + Length( cTitle);
    while (laps > 0) and not AnyKeyDown do
    begin
      FillScreen( cSteelPlate);
      FancyBigText( xTitle, cyTitle, cTitle, dx, dy, 1, 1);
      VSinc;
      PCopy( 2, 1);
      Dec( dx);
      Dec( dy);
      Dec( laps);
    end;
  end;

  procedure ShowOption( x, y, index : Integer; s : String );
  begin
    if index = choice then
      ftPut( x, y, gPics[ cHilitedButton]^, True)
    else
      ftPut( x, y, gPics[ cButton]^, True);
    DrawLetter( x + 25, y, cWhite, cBlack, s);
  end;

  procedure MenuFrame;
  begin
    FillScreen( cSteelPlate);
    BigText( xTitle, cyTitle, cTitle);
    if gPlayerData[0].playing then
      with cHeroInfo[ gPlayerData[0].hero] do
        DrawCharacter( cxPlayer1, cyPlayer1,
                       cDirectionDown, faceDir1,
                       face, body, cGunDogs, 0, 0, cGunIdle);
    if gPlayerData[1].playing then
      with cHeroInfo[ gPlayerData[1].hero] do
        DrawCharacter( cxPlayer2, cyPlayer2,
                       cDirectionDown, faceDir2,
                       face, body, cGunDogs, 0, 0, cGunIdle);

    if gPlayerData[0].playing then
      ShowOption( 50, 75, 0, 'Player #1 is '+cHeroInfo[ gPlayerData[0].hero].name)
    else
      ShowOption( 50, 75, 0, 'Player #1 not playing');
    ShowOption( 50, 100, 2, 'Set controls');

    if gPlayerData[1].playing then
      ShowOption( 175, 75, 1, 'Player #2 is '+cHeroInfo[ gPlayerData[1].hero].name)
    else
      ShowOption( 175, 75, 1, 'Player #2 not playing');
    ShowOption( 175, 100, 3, 'Set controls');

    ShowOption(  50, 125, 4, 'Start mission');
    ShowOption( 175, 125, 5, 'Credits');
    ShowOption(  50, 150, 6, 'Options screen');
    ShowOption( 175, 150, 7, 'Quit');

    DrawLetter( 30, 185, cWhite, cBlack, 'Use up/down/left/right to highlight, Enter/button to select');
  end;

  procedure UpdateMenuFrame;
  var textPos : Integer;
  begin
    Inc( delay);
    if delay > 15 then
    begin
      faceDir1 := Random( 3) + 3;
      faceDir2 := Random( 3) + 3;
      delay := 0;
    end;
  end;

  procedure Redraw;
  begin
    SetPageActive( 2);
    MenuFrame;
    PCopy( 2, 1);
    FadeIn( 20, gPalette);
  end;

begin
  xTitle := (320 - Length( cTitle) * CharWidth) div 2;
  MainScreenIntro;

  delay := 0;
  faceDir1 := cDirectionDownRight;
  faceDir2 := cDirectionDownLeft;

  choice := 0;
  done := False;
  repeat
    MenuFrame;
    VSinc;
    VSinc;
    PCopy( 2, 1);
    UpdateMenuFrame;

    if cmd <> GetMenuCommand then
    begin
      cmd := GetMenuCommand;
      case cmd of

        cCommandShoot:
          begin
            PlaySound( cBigGunSound);
            case choice of

              0:
                begin
                  gPlayerData[0].playing := not gPlayerData[0].playing;
                  if gPlayerData[0].playing then
                  begin
                    if gPlayerData[1].playing then
                      SelectHero( gPlayerData[0].hero, gPlayerData[1].hero)
                    else
                      SelectHero( gPlayerData[0].hero, $FF);
                    Redraw;
                  end;
                end;

              1:
                begin
                  gPlayerData[1].playing := not gPlayerData[1].playing;
                  if gPlayerData[1].playing then
                  begin
                    if gPlayerData[0].playing then
                      SelectHero( gPlayerData[1].hero, gPlayerData[0].hero)
                    else
                      SelectHero( gPlayerData[1].hero, $FF);
                    Redraw;
                  end;
                end;

              2:
                begin
                  DefineKeys( 0, hero1Keys);
                  gPlayerData[0].playing := True;
                  Redraw;
                end;

              3:
                begin
                  DefineKeys( 1, hero2Keys);
                  gPlayerData[1].playing := True;
                  Redraw;
                end;

              4: if gPlayerData[0].playing or gPlayerData[1].playing then
                   done := True;

              7: done := True;

              6:
                begin
                  Options;
                  Redraw;
                end;

              5:
                begin
                  DisplayCredits;
                  Redraw;
                end;
            end;
          end;

        cCommandUp:
          if choice > 1 then
            Dec( choice, 2);

        cCommandDown:
          if choice <= 5 then
            Inc( choice, 2);

        cCommandLeft:
          if choice > 0 then
            Dec( choice);

        cCommandRight:
          if choice < 7 then
            Inc( choice);

        cCommandFreeze:
          begin
            choice := 7;
            done := True;
          end;

      end;
    end;
  until done;
  FadeOut( 20, gPalette);
  MainScreen := (choice = 4);
end;


end.
