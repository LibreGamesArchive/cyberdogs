unit Globals;


interface

  uses SPX_VGA,
       Keyboard, Sounds, Ini;


const

  cxMin = 10;
  cxMax = 70;
  cyMin = 10;
  cyMax = 70;

  cBlack     = 1;
  cYellow    = 17;
  cOrange    = 19;
  cBrightRed = 21;
  cRed       = 23;
  cDarkRed   = 25;
  cWhite     = 255;
  cGray      = 37;

  cCommandUp     =   2;
  cCommandDown   =   1;
  cCommandLeft   =   4;
  cCommandRight  =   8;
  cCommandShoot  =  16;
  cCommandSwitch =  32;
  cCommandFreeze =  64;
  cCommandNoTurn = 128;
  cCommandMoving =  15;
  cCommandFiring =  48;
  cCommandNoMove =  96; { 112 to disallow movement whilst firing }

  cDirectionUp        = 0;
  cDirectionUpRight   = 1;
  cDirectionRight     = 2;
  cDirectionDownRight = 3;
  cDirectionDown      = 4;
  cDirectionDownLeft  = 5;
  cDirectionLeft      = 6;
  cDirectionUpLeft    = 7;

  cDirectionFromCmd : array [0..15] of Byte =
    ( 0, cDirectionDown, cDirectionUp, 0,
      cDirectionLeft, cDirectionDownLeft, cDirectionUpLeft, 0,
      cDirectionRight, cDirectionDownRight, cDirectionUpRight, 0,
      0, 0, 0, 0 );

  cCmdFromDirection : array [0..7] of Byte =
    ( cCommandUp,
      cCommandUp + cCommandRight,
      cCommandRight,
      cCommandDown + cCommandRight,
      cCommandDown,
      cCommandDown + cCommandLeft,
      cCommandLeft,
      cCommandUp + cCommandLeft );

  cMaxHorizontalDistance = 250;
  cMaxVerticalDistance   = 150;

  cProximityDistance  = 100;
  cRelocationDistance = 400;
  cLargeDistance      = 2500;

  cCharacterHeight = 20;
  cCharacterWidth  = 15;

  cMaxWeaponry = 5;
  cFireBallsPerExplosion = 5;


type

  WeaponryData =
    array [0..cMaxWeaponry] of
      record
        kind : Byte;
        ammo : Integer;
      end;

  ScoreData =
    record
      score,
      kills,
      targets,
      objects,
      closeCombat,
      demolition,
      shotsFired,
      hits,
      hitsTaken,
      time : LongInt;
    end;

  PlayerData =
    record
      mission,
      total       : ScoreData;
      cash        : LongInt;
      missions,
      armor       : Integer;
      lives       : Integer;
      closeCombat : Integer;
      weapons     : WeaponryData;
      playing     : Boolean;
      hero        : Byte;
      button2Down,
      button2Movement : Boolean;
      completed   : Boolean;
    end;

  HeroInfo =
    record
      name    : String[15];
      body    : Byte;
      face    : Byte;
    end;

  KeyControls =
    record
      up,
      down,
      left,
      right,
      shoot,
      switch : Byte;
      {freeze,
      noTurn : Byte;}
      rotate : Boolean;
      stick  : Byte;
    end;

  GunRec =
    record
      name        : String[20];
      pic         : Word;
      range       : Integer;
      rate        : Byte;
      power       : Byte;
      speed       : Integer;
      radius      : Integer;
      bulletStyle : Byte;
      animated    : Byte;
      sound       : Byte;
      areaEffect  : Integer;
    end;


const

  hero1Keys : KeyControls =
    ( up:     keyArrowUp;
      down:   keyArrowDown;
      left:   keyArrowLeft;
      right:  keyArrowRight;
      shoot:  keyLeftCtrl;
      switch: keyEnter;
      rotate: False;
      stick:  0 );

  hero2Keys : KeyControls =
    ( up:     keyKeypad8;
      down:   keyKeypad2;
      left:   keyKeypad4;
      right:  keyKeypad6;
      shoot:  keyRightCtrl;
      switch: keySpace;
      rotate: False;
      stick:  0 );

  cAnimationNone     = 0;
  cAnimationRandom   = 1;
  cAnimationSequence = 2;

  cGunStyles : array [1..10] of GunRec =
    ( ( name: 'PowerGun';
        pic:       134;
        range:      70;
        rate:       40;
        power:      60;
        speed:      10;
        radius:      5;
        bulletStyle: 7;
        animated:    cAnimationNone;
        sound:       cBigGunSound ),
      ( name: 'Blaster';
        pic:       135;
        range:      50;
        rate:       12;
        power:      10;
        speed:       8;
        radius:      4;
        bulletStyle: 0;
        animated:    cAnimationNone;
        sound:       cSmallGunSound ),
      ( name: 'MiniGun';
        pic:       136;
        range:      30;
        rate:        7;
        power:       6;
        speed:      12;
        radius:      3;
        bulletStyle: 2;
        animated:    cAnimationNone;
        sound:       cMinigunSound ),
      ( name: 'Flamer';
        pic:       137;
        range:      25;
        rate:        7;
        power:      10;
        speed:       3;
        radius:     10;
        bulletStyle: 3;
        animated:    cAnimationRandom;
        sound:       cFlamerSound ),
      ( name: 'Launcher';
        pic:       138;
        range:      50;
        rate:       30;
        power:      40;
        speed:       4;
        radius:      1;
        bulletStyle: 4;
        animated:    cAnimationSequence;
        sound:       cLaunchSound ),
      ( name: 'DumbGun';
        pic:       134;
        range:     110;
        rate:       40;
        power:       5;
        speed:       4;
        radius:      0;
        bulletStyle: 1;
        animated:    cAnimationNone;
        sound:       cSmallGunSound ),
      ( name: 'Gun';
        pic:       134;
        range:     110;
        rate:       30;
        power:       3;
        speed:       8;
        radius:      0;
        bulletStyle: 6;
        animated:    cAnimationNone;
        sound:       cSmallGunSound ),
      ( name: 'Lazer';
        pic:       134;
        range:     100;
        rate:       65;
        power:      10;
        speed:      10;
        radius:      0;
        bulletStyle: 5;
        animated:    cAnimationNone;
        sound:       cLaserSound ),
      ( name: 'TurboLazer';
        pic:       134;
        range:     100;
        rate:       35;
        power:       8;
        speed:      10;
        radius:      0;
        bulletStyle: 5;
        animated:    cAnimationNone;
        sound:       cLaserSound ),
      ( name: 'Zapper';
        pic:       351;
        range:      30;
        rate:        7;
        power:      10;
        speed:      12;
        radius:      6;
        bulletStyle: 8;
        animated:    cAnimationSequence;
        sound:       cLaserSound )
    );

  cPowerGun  = 1;
  cBlaster   = 2;
  cSprayer   = 3;
  cFlamer    = 4;
  cGrenade   = 5;
  cGoonGun   = 6;
  cGoonGun2  = 7;
  cGoonGun3  = 8;
  cGoonGun4  = 9;
  cMegaGun   = 10;

  cBlueBody   = 0;
  cBrownBody  = 1;
  cGreyBody   = 2;
  cRedBody    = 3;
  cBlackBody  = 4;
  cMaxBody    = 4;

  cFaceJones      = 0;
  cFaceIce        = 1;
  cFaceWarBaby    = 2;
  cFaceGrunt      = 3;
  cFaceMechGrunt  = 4;
  cFaceGrunt2     = 5;
  cFaceBlondGrunt = 6;
  cFaceBigBadGuy  = 7;
  cMaxFace        = 7;

  cGunDogs     = 0;
  cGunMax      = 0;

  cHeroJones   = 0;
  cHeroIce     = 1;
  cHeroWarBaby = 2;
  cMaxHeros    = 2;

  cHeroInfo : array [0..cMaxHeros] of HeroInfo =
    ( ( name: 'Jones';
        body: cBlueBody;
        face: cFaceJones
      ),
      ( name: 'Ice';
        body: cBlueBody;
        face: cFaceIce
      ),
      ( name: 'WarBaby';
        body: cBlueBody;
        face: cFaceWarBaby
      )
    );

  gCampaign : Word = 0;

  cBaddieGoon      = 0;
  cBaddieMeanGoon  = 1;
  cBaddieKiller    = 2;
  cBaddieRobot     = 3;
  cBaddieLittleBad = 4;
  cBaddieBigBad    = 5;

  cPoolLives = 1;
  cPoolCash  = 2;

  gFreeMovement : Boolean = False;
  g2PlayerPool  : Integer = cPoolLives or cPoolCash;
  gMapKey       : Byte    = keyF1;


var

  gPalette : RGBList;

  gPlayerData : array [0..1] of PlayerData;

  gGameOver : Boolean;
  gTargetsLeft, gObjectsToCollect, gMinimumKills : Integer;
  gMissionTime : LongInt;
  gAlert1,
  gAlert2 : Boolean;
  gFrameCounter : LongInt;
  gMissionTargets : Set of Byte;
  gVBlankCounter : LongInt;
  gBadGuyCount : Integer;
  gBaddieProbs : array [cBaddieGoon..cBaddieBigBad] of Byte;

  gAutoMap : array [ cxMin..cxMax, cyMin..cyMax] of Byte;

  gIniSettings : PSection;
  gCyclesPerFrame : Integer;



implementation


end.
