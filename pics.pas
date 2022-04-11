unit Pics;


interface

  uses SPX_VGA,
       Globals, GameArea;


const

  cMaxPics = 351;


var

  gPics : array [0..cMaxPics] of Pointer;
  gBkgPics : array [0..cBkgPicMax] of Pointer;


const

  cBodyPics : array [0..cMaxBody, 0..7, 0..4] of Integer =
    (
      (
        (  10,  14,  13,  12,  11 ),
        (  10,  14,  13,  12,  11 ),
        (  15,  16,  17,  18,  19 ),
        (   0,   4,   3,   2,   1 ),
        (   0,   4,   3,   2,   1 ),
        (   0,   4,   3,   2,   1 ),
        (   5,   9,   8,   7,   6 ),
        (   5,   9,   8,   7,   6 )
      ),
      (
        (  30,  34,  33,  32,  31 ),
        (  30,  34,  33,  32,  31 ),
        (  35,  36,  37,  38,  39 ),
        (  20,  24,  23,  22,  21 ),
        (  20,  24,  23,  22,  21 ),
        (  20,  24,  23,  22,  21 ),
        (  25,  29,  28,  27,  26 ),
        (  25,  29,  28,  27,  26 )
      ),
      (
        ( 246, 250, 249, 248, 247 ),
        ( 246, 250, 249, 248, 247 ),
        ( 251, 252, 253, 254, 255 ),
        ( 236, 240, 239, 238, 237 ),
        ( 236, 240, 239, 238, 237 ),
        ( 236, 240, 239, 238, 237 ),
        ( 241, 245, 244, 243, 242 ),
        ( 241, 245, 244, 243, 242 )
      ),
      (
        ( 266, 270, 269, 268, 267 ),
        ( 266, 270, 269, 268, 267 ),
        ( 271, 272, 273, 274, 275 ),
        ( 256, 260, 259, 258, 257 ),
        ( 256, 260, 259, 258, 257 ),
        ( 256, 260, 259, 258, 257 ),
        ( 261, 265, 264, 263, 262 ),
        ( 261, 265, 264, 263, 262 )
      ),
      (
        ( 334, 338, 337, 336, 335 ),
        ( 334, 338, 337, 336, 335 ),
        ( 339, 340, 341, 342, 343 ),
        ( 324, 328, 327, 326, 325 ),
        ( 324, 328, 327, 326, 325 ),
        ( 324, 328, 327, 326, 325 ),
        ( 329, 333, 332, 331, 330 ),
        ( 329, 333, 332, 331, 330 )
      )
    );

  cFaceNormal = 0;
  cFaceHard   = 1;

  cFacePics : array [0..cMaxFace, 0..7, 0..1] of Integer =
    (
      ( (  64,  64 ), (  63,  63 ), (  62, 197 ), (  61, 196 ), (  60, 195 ), (  59, 194 ), (  58, 193 ), (  65,  65 ) ),
      ( (  72,  72 ), (  71,  71 ), (  70, 202 ), (  69, 201 ), (  68, 200 ), (  67, 199 ), (  66, 198 ), (  73,  73 ) ),
      ( (  80,  80 ), (  79,  79 ), (  78, 207 ), (  77, 206 ), (  76, 205 ), (  75, 204 ), (  74, 203 ), (  81,  81 ) ),
      ( (  88,  88 ), (  87,  87 ), (  86,  86 ), (  85,  85 ), (  84,  84 ), (  83,  83 ), (  82,  82 ), (  89,  89 ) ),
      ( ( 226, 226 ), ( 225, 225 ), ( 224, 224 ), ( 223, 223 ), ( 222, 222 ), ( 221, 221 ), ( 220, 220 ), ( 227, 227 ) ),
      ( ( 234, 234 ), ( 233, 233 ), ( 232, 232 ), ( 231, 231 ), ( 230, 230 ), ( 229, 229 ), ( 228, 228 ), ( 235, 235 ) ),
      ( ( 285, 285 ), ( 284, 284 ), ( 283, 283 ), ( 282, 282 ), ( 281, 281 ), ( 280, 280 ), ( 279, 279 ), ( 286, 286 ) ),
      ( ( 297, 297 ), ( 296, 296 ), ( 295, 295 ), ( 294, 294 ), ( 293, 293 ), ( 292, 292 ), ( 291, 291 ), ( 298, 298 ) )
    );


  cGunIdle   = 0;
  cGunReady  = 1;
  cGunRecoil = 2;
  cMaxGunPosition = 2;

  cGunPics : array [0..cGunMax, 0..7, 0..cMaxGunPosition] of Integer =
    (
      (
        ( 50, 51, 51 ),
        ( 52, 53, 53 ),
        ( 54, 55, 55 ),
        ( 42, 57, 57 ),
        ( 42, 43, 43 ),
        ( 44, 45, 45 ),
        ( 46, 47, 47 ),
        ( 48, 49, 49 )
      )
    );

  cMaxDeath = 9;
  cDeathPics : array [1..cMaxDeath] of Integer =
    ( 184, 185, 186, 187, 188, 189, 190, 191, 192 );

  cMaxFireBalls = 5;
  cExplosionPics : array [0..cMaxFireBalls] of Integer =
    ( 90, 91, 92, 93, 94, 95 );

  cCyanBolts    = 0;
  cRedBolts     = 1;
  cMinigunBolts = 2;
  cFlamerBolts  = 3;
  cGrenades     = 4;
  cGreenBolts   = 5;
  cYellowBolts  = 6;
  cPowerBolts   = 7;
  cZapperBolts  = 8;
  cMaxBolts     = 8;

  cShotConnectPic = 8;

  cShotPics : array [0..cMaxBolts, 0..8] of Integer =
    (
      ( 104, 107, 105, 106, 104, 107, 105, 106, 179 ),
      ( 108, 111, 109, 110, 108, 111, 109, 110, 180 ),
      ( 112, 112, 112, 112, 112, 112, 112, 112, 181 ),
      (  96,  97,  98,  99,  96,  97,  98,  99,  96 ),
      ( 100, 101, 102, 103, 100, 101, 102, 103, 100 ),
      ( 307, 310, 308, 309, 307, 310, 308, 309, 315 ),
      ( 311, 314, 312, 313, 311, 314, 312, 313, 181 ),
      ( 316, 316, 316, 316, 316, 316, 316, 316, 179 ),
      ( 181, 180, 181, 180, 181, 180, 181, 180,  90 )
    );

  cWallPicMax = 0;
  cWallPics : array [0..cWallPicMax, 1..15] of Integer =
    (
      ( 126, 120, 125, 127, 130, 119, 129, 128, 122, 177, 123, 121, 124, 131, 132 )
    );

  cWallPatternMax = 2;
  cWallPatterns : array [0..cWallPatternMax, 0..1] of Integer =
    ( ( 299, 300 ), ( 301, 302 ), ( 303, 304 ) );

  cWallColorMax = 7;
  cWallColors : array [0..cWallColorMax] of RGBType =
    (
      (red: 40; green:  0; blue:  0 ),
      (red: 40; green: 30; blue:  0 ),
      (red: 30; green:  0; blue: 30 ),
      (red: 30; green: 30; blue: 30 ),
      (red: 15; green: 15; blue: 15 ),
      (red: 10; green: 10; blue: 40 ),
      (red:  0; green: 30; blue:  0 ),
      (red: 10; green: 30; blue: 10 )
    );

  cWallColorFirst = 96;
  cMaxWallColors = 7;

  cBkgAnimatedChaosBox  = 0;
  cBkgAnimatedExit      = 1;
  cBkgAnimatedFan       = 2;
  cMaxBkgAnimated = 2;
  cBkgAnimated : array [0..cMaxBkgAnimated, 0..3] of Integer =
    ( ( 276, 277, 276, 278 ),
      ( 287, 288, 289, 290 ),
      ( 318, 318, 319, 319 ) );

  cBkgMax = 3;

  cBkgPics: array [0..cBkgMax, 0..1] of Integer =
    ( ( 113, 114 ),
      ( 115, 116 ),
      ( 117, 118 ),
      ( 212, 213 )
    );

  cBkgColorMax = 5;
  cBkgColors : array [0..cBkgColorMax] of RGBType =
    (
      (red: 13; green: 13; blue:  0 ),
      (red:  0; green: 15; blue:  0 ),
      (red: 25; green:  0; blue:  0 ),
      (red: 11; green: 11; blue: 11 ),
      (red:  9; green:  9; blue:  9 ),
      (red:  7; green:  7; blue: 20 )
    );

  cBkgColorFirst = 106;
  cMaxBkgColors  = 5;

type

  Architecture =
    record
      wallPattern,
      wallColor,
      bkg,
      bkgColor,
      style : Byte;
    end;

const

  cArchitectureMax = 14;
  cArchitectureStyleMax = 2;
  cArchitectures : array [0..cArchitectureMax] of Architecture =
    (
      ( wallPattern:2; wallColor:3; bkg:2; bkgColor:3; style:0 ),
      ( wallPattern:2; wallColor:4; bkg:2; bkgColor:3; style:0 ),
      ( wallPattern:2; wallColor:5; bkg:2; bkgColor:4; style:0 ),
      ( wallPattern:2; wallColor:4; bkg:1; bkgColor:0; style:0 ),
      ( wallPattern:2; wallColor:5; bkg:0; bkgColor:5; style:0 ),
      ( wallPattern:1; wallColor:6; bkg:0; bkgColor:5; style:1 ),
      ( wallPattern:1; wallColor:7; bkg:1; bkgColor:1; style:1 ),
      ( wallPattern:1; wallColor:6; bkg:3; bkgColor:1; style:1 ),
      ( wallPattern:1; wallColor:7; bkg:0; bkgColor:5; style:1 ),
      ( wallPattern:1; wallColor:2; bkg:1; bkgColor:4; style:1 ),
      ( wallPattern:0; wallColor:0; bkg:0; bkgColor:1; style:2 ),
      ( wallPattern:0; wallColor:0; bkg:1; bkgColor:2; style:2 ),
      ( wallPattern:0; wallColor:0; bkg:2; bkgColor:3; style:2 ),
      ( wallPattern:0; wallColor:0; bkg:3; bkgColor:4; style:2 ),
      ( wallPattern:0; wallColor:5; bkg:1; bkgColor:3; style:2 )
    );

  cShadowPic     = 133;
  cSteelPlate    = 178;
  cButton        = 182;
  cHilitedButton = 183;

  cSkullPic      = 208;
  cBloodPic      = 209;
  cCraterPic     = 210;
  cGoldSkullPic  = 211;
  cArmorPic      = 219;
  cArmorAddOnPic = 305;
  cAxePic        = 306;

  cWallPic1      = 214;
  cWallPic2      = 215;
  cWallPic3      = 216;
  cWallPic4      = 217;
  cWallPic5      = 218;

  cExitPic       = 287;

  cChaosBoxBangPic  = 317;
  cBlueBoxPic       = 320;
  cBlueBoxBangPic   = 321;
  cGreyBoxPic       = 322;
  cGreyBoxBangPic   = 323;
  cCratePic         = 344;
  cCrateBangPic     = 345;
  cBoxPic           =  40;
  cBoxBangPic       =  41;

  cDocsPic       = 350;
  cFolderPic     = 346;
  cDiskPic       = 347;
  cCircuitPic    = 348;
  cTeddyPic      = 349;


procedure KillPics;
function  LoadPics( filename : String; var pics; maxPics : Integer; var p : RGBList ) : Boolean;
procedure BuildBkgPics( const a : Architecture; var p : RGBList );
procedure SetClipRange( x, y, x2, y2 : Integer );



implementation

  uses Keyboard;


type

  PicArray = array [0..500] of Pointer;


procedure KillPics;
var i : Integer;
begin
  for i := 0 to cMaxPics do
    if gPics[ i] <> nil then
    begin
      FreeMem( gPics[i], ImageSize( gPics[i]^));
      gPics[i] := nil;
    end;
end;


function LoadPics( filename : String; var pics; maxPics : Integer; var p : RGBList ) : Boolean;
var f    : File;
    i    : Integer;
    size : Word;
begin
  LoadPics := False;
  Assign( f, filename);
  Reset( f, 1);
  if IOResult <> 0 then
    Exit;

  BlockRead( f, p, SizeOf( p));

  i := 0;
  while not Eof( f) and (i <= maxPics) do
  begin
    BlockRead( f, size, SizeOf( size));
    if size <> 0 then
    begin
      GetMem( PicArray( pics)[i], size);
      if gPics[i] <> nil then
        BlockRead( f, PicArray( pics)[i]^, size)
      else
        Seek( f, FilePos( f) + size);
    end;
    Inc( i);
  end;
  Close( f);

  LoadPics := True;
end;


procedure BuildBkgPics( const a : Architecture; var p : RGBList );

  procedure GetPic( i, x, y : Integer );
  begin
    fGet( x, y, x + 31, y + 23, gBkgPics[ i and cBkgFlagMask]^);
  end;

  procedure DecRGB( var rgb : RGBType );

    procedure DecRGBComponent( var x : Byte );
    begin
      if x > 20 then
        Dec( x, 3)
      else if x > 10 then
        Dec( x, 2)
      else if x > 0 then
        Dec( x);
    end;

  begin
    DecRGBComponent( rgb.red);
    DecRGBComponent( rgb.green);
    DecRGBComponent( rgb.blue);
  end;

  procedure OverlayPic( srcLeft, srcTop, dstLeft, dstTop : Integer; color : Byte );
  var x, y : Integer;
  begin
    for x := 0 to 31 do
      for y := 0 to 23 do
        if Point( x + dstLeft, y + dstTop, 2) = color then
          PSet( x + dstLeft, y + dstTop, Point( x + srcLeft, y + srcTop, 2));
  end;

  procedure DoOverlay( pic, pattern : Pointer; color : Byte );
  var x, y, w, h : Integer;
      picPtr, patternPtr : PChar;
  begin
    ImageDims( pic^, w, h);
    if (w <> 32) or (h <> 24) then
      Exit;
    ImageDims( pattern^, w, h);
    if (w <> 32) or (h <> 24) then
      Exit;

    picPtr := pic;
    Inc( picPtr, 4);
    patternPtr := pattern;
    Inc( patternPtr, 4);
    for x := 0 to 31 do
      for y := 0 to 23 do
      begin
        if picPtr^ = Chr( color) then
          picPtr^ := patternPtr^;
        Inc( picPtr);
        Inc( patternPtr);
      end;
  end;

  procedure OverlayPattern( pic, pattern : Integer );
  begin
    DoOverlay( gBkgPics[ pic and cBkgFlagMask],
               gPics[ cWallPatterns[ pattern, 0]], 254);
    DoOverlay( gBkgPics[ pic and cBkgFlagMask],
               gPics[ cWallPatterns[ pattern, 1]], 0);
  end;

var tmp     : Pointer;
    c       : Integer;
    wallPic : Integer;
    rgb     : RGBType;
begin
  wallPic := 0; {cWallPicsIndex[ wall];}

  GetMem( tmp, BuffSize( 32, 24));
  SetPageActive(2);
  Cls(0);

  fPut(   0,   0, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut(  32,   0, gPics[ cBkgPics[ a.bkg, 1]]^, False);
  fPut(  64,   0, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut(  96,   0, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut( 128,   0, gPics[ cBkgPics[ a.bkg, 0]]^, False);

  fPut( 192,   0, gPics[ cWallPics[ wallPic, 13]]^, False);

  {fPut( 224,   0, gPics[ cWallPatterns[ 1, 0]]^, False);
  fPut( 256,   0, gPics[ cWallPatterns[ 1, 1]]^, False);}

  fGet(  32,  0,  63,  11, tmp^);
  fPut(  64,  0, tmp^, False);
  fGet(  32,  0,  47,  11, tmp^);
  fPut(  96,  0, tmp^, False);
  fGet(  32, 12,  47,  23, tmp^);
  fPut( 128, 12, tmp^, False);

  fPut(   0,  24, gPics[ cWallPics[ wallPic,  1]]^, False);
  fPut(  32,  24, gPics[ cWallPics[ wallPic,  2]]^, False);
  fPut(  64,  24, gPics[ cWallPics[ wallPic,  3]]^, False);
  fPut(  96,  24, gPics[ cWallPics[ wallPic,  4]]^, False);
  fPut( 128,  24, gPics[ cWallPics[ wallPic,  5]]^, False);
  fPut( 160,  24, gPics[ cWallPics[ wallPic,  6]]^, False);
  fPut( 192,  24, gPics[ cWallPics[ wallPic,  7]]^, False);
  fPut( 224,  24, gPics[ cWallPics[ wallPic,  8]]^, False);
  fPut(   0,  48, gPics[ cWallPics[ wallPic,  9]]^, False);
  fPut(  32,  48, gPics[ cWallPics[ wallPic, 10]]^, False);
  fPut(  64,  48, gPics[ cWallPics[ wallPic, 11]]^, False);
  fPut(  96,  48, gPics[ cWallPics[ wallPic, 12]]^, False);
  fPut( 128,  48, gPics[ cWallPics[ wallPic, 13]]^, False);
  fPut( 160,  48, gPics[ cWallPics[ wallPic, 14]]^, False);
  fPut( 192,  48, gPics[ cWallPics[ wallPic, 15]]^, False);
  {
  OverlayPic( 224, 0,   0, 24, 254); OverlayPic( 256, 0,   0, 24, 0);
  OverlayPic( 224, 0,  32, 24, 254); OverlayPic( 256, 0,  32, 24, 0);
  OverlayPic( 224, 0,  64, 24, 254); OverlayPic( 256, 0,  64, 24, 0);
  OverlayPic( 224, 0,  96, 24, 254); OverlayPic( 256, 0,  96, 24, 0);
  OverlayPic( 224, 0, 128, 24, 254); OverlayPic( 256, 0, 128, 24, 0);
  OverlayPic( 224, 0, 160, 24, 254); OverlayPic( 256, 0, 160, 24, 0);
  OverlayPic( 224, 0, 192, 24, 254); OverlayPic( 256, 0, 192, 24, 0);
  OverlayPic( 224, 0, 224, 24, 254); OverlayPic( 256, 0, 224, 24, 0);
  OverlayPic( 224, 0,   0, 48, 254); OverlayPic( 256, 0,   0, 48, 0);
  OverlayPic( 224, 0,  32, 48, 254); OverlayPic( 256, 0,  32, 48, 0);
  OverlayPic( 224, 0,  64, 48, 254); OverlayPic( 256, 0,  64, 48, 0);
  OverlayPic( 224, 0,  96, 48, 254); OverlayPic( 256, 0,  96, 48, 0);
  OverlayPic( 224, 0, 128, 48, 254); OverlayPic( 256, 0, 128, 48, 0);
  OverlayPic( 224, 0, 160, 48, 254); OverlayPic( 256, 0, 160, 48, 0);
  OverlayPic( 224, 0, 192, 48, 254); OverlayPic( 256, 0, 192, 48, 0);
  }
  fGet(  48,   0,  63, 23, tmp^);
  fPut(  48,  24, tmp^, False);
  fPut( 176,  24, tmp^, False);
  fPut( 208,  24, tmp^, False);
  fPut(  16,  48, tmp^, False);
  fGet(  16,   0,  31, 11, tmp^);
  fPut(  48,  48, tmp^, False);
  fPut( 112,  48, tmp^, False);
  fGet(  48,  12,  63, 23, tmp^);
  fPut(  48,  60, tmp^, False);
  fPut( 112,  60, tmp^, False);

  fPut(   0,  72, gPics[ cShadowPic]^, False);
  fPut(  32,  72, gPics[ cWallPics[ wallPic,  6]]^, False);
  fPut(  64,  72, gPics[ cWallPics[ wallPic,  7]]^, False);
  fPut(  96,  72, gPics[ cWallPics[ wallPic,  9]]^, False);
  fPut( 128,  72, gPics[ cWallPics[ wallPic, 10]]^, False);
  fPut( 160,  72, gPics[ cWallPics[ wallPic,  2]]^, False);
  fPut( 192,  72, gPics[ cWallPics[ wallPic, 12]]^, False);
  {
  OverlayPic( 224, 0,   0, 72, 254); OverlayPic( 256, 0,   0, 72, 0);
  OverlayPic( 224, 0,  32, 72, 254); OverlayPic( 256, 0,  32, 72, 0);
  OverlayPic( 224, 0,  64, 72, 254); OverlayPic( 256, 0,  64, 72, 0);
  OverlayPic( 224, 0,  96, 72, 254); OverlayPic( 256, 0,  96, 72, 0);
  OverlayPic( 224, 0, 128, 72, 254); OverlayPic( 256, 0, 128, 72, 0);
  OverlayPic( 224, 0, 160, 72, 254); OverlayPic( 256, 0, 160, 72, 0);
  OverlayPic( 224, 0, 192, 72, 254); OverlayPic( 256, 0, 192, 72, 0);
  }
  fGet(  16,  72,  31, 95, tmp^);
  fPut(  48,  72, tmp^, False);
  fPut(  80,  72, tmp^, False);
  fPut( 112,  72, tmp^, False);
  fPut( 144,  72, tmp^, False);
  fPut( 176,  72, tmp^, False);
  fPut( 208,  72, tmp^, False);

  fPut(   0,  96, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut(  32,  96, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut(  64,  96, gPics[ cBkgPics[ a.bkg, 0]]^, False);

  fPut(  96,  96, gPics[ cWallPics[ wallPic, cBkgHorz and cBkgFlagMask]]^, False);
  fPut( 128,  96, gPics[ cWallPics[ wallPic, cBkgHorz and cBkgFlagMask]]^, False);
  fPut( 160,  96, gPics[ cWallPics[ wallPic, cBkgHorz and cBkgFlagMask]]^, False);
  fPut( 192,  96, gPics[ cWallPics[ wallPic, cBkgHorz and cBkgFlagMask]]^, False);
  fPut( 224,  96, gPics[ cWallPics[ wallPic, cBkgHorz and cBkgFlagMask]]^, False);

  fPut(   0, 120, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut(  32, 120, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut(  64, 120, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut(  96, 120, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut( 128, 120, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut( 160, 120, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut( 192, 120, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut( 224, 120, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut( 256, 120, gPics[ cBkgPics[ a.bkg, 0]]^, False);

  fPut(   0, 144, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut(  32, 144, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut(  64, 144, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut(  96, 144, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut( 128, 144, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut( 160, 144, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut( 192, 144, gPics[ cBkgPics[ a.bkg, 0]]^, False);

  fPut(   0, 168, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut(  32, 168, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut(  64, 168, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut(  96, 168, gPics[ cBkgPics[ a.bkg, 0]]^, False);
  fPut( 128, 168, gPics[ cBkgPics[ a.bkg, 0]]^, False);

  fTPut(   0,  96, gPics[ cSkullPic]^, False);
  fTPut(  32,  96, gPics[ cBloodPic]^, False);
  fTPut(  64,  96, gPics[ cCraterPic]^, False);

  fTPut(  96,  96, gPics[ cWallPic1]^, False);
  fTPut( 128,  96, gPics[ cWallPic2]^, False);
  fTPut( 160,  96, gPics[ cWallPic3]^, False);
  fTPut( 192,  96, gPics[ cWallPic4]^, False);
  fTPut( 224,  96, gPics[ cWallPic5]^, False);
  {
  OverlayPic( 224, 0,  96, 96, 254); OverlayPic( 256, 0,  96, 96, 0);
  OverlayPic( 224, 0, 128, 96, 254); OverlayPic( 256, 0, 128, 96, 0);
  OverlayPic( 224, 0, 160, 96, 254); OverlayPic( 256, 0, 160, 96, 0);
  OverlayPic( 224, 0, 192, 96, 254); OverlayPic( 256, 0, 192, 96, 0);
  OverlayPic( 224, 0, 224, 96, 254); OverlayPic( 256, 0, 224, 96, 0);
  }
  fTPut(   0, 120, gPics[ cGunStyles[ cPowerGun].pic]^, False);
  fTPut(  32, 120, gPics[ cGunStyles[ cBlaster].pic]^, False);
  fTPut(  64, 120, gPics[ cGunStyles[ cSprayer].pic]^, False);
  fTPut(  96, 120, gPics[ cGunStyles[ cFlamer].pic]^, False);
  fTPut( 128, 120, gPics[ cGunStyles[ cGrenade].pic]^, False);
  fTPut( 160, 120, gPics[ cArmorPic]^, False);
  fTPut( 192, 120, gPics[ cGoldSkullPic]^, False);
  fTPut( 224, 120, gPics[ cArmorAddOnPic]^, False);
  fTPut( 256, 120, gPics[ cAxePic]^, False);

  fTPut(   0, 144, gPics[ cBlueBoxBangPic]^, False);
  fTPut(  32, 144, gPics[ cGreyBoxBangPic]^, False);
  fTPut(  64, 144, gPics[ cChaosBoxBangPic]^, False);
  fTPut(  96, 144, gPics[ cCratePic]^, False);
  fTPut( 128, 144, gPics[ cCrateBangPic]^, False);
  fTPut( 160, 144, gPics[ cBoxBangPic]^, False);

  fTPut(   0, 168, gPics[ cDocsPic]^, False);
  fTPut(  32, 168, gPics[ cFolderPic]^, False);
  fTPut(  64, 168, gPics[ cDiskPic]^, False);
  fTPut(  96, 168, gPics[ cCircuitPic]^, False);
  fTPut( 128, 168, gPics[ cTeddyPic]^, False);

  FreeMem( tmp, BuffSize( 32, 24));

  rgb := cWallColors[ a.wallColor];
  for c := 0 to cMaxWallColors do
  begin
    p[ cWallColorFirst + c] := rgb;
    DecRGB( rgb);
  end;
  rgb := cBkgColors[ a.bkgColor];
  for c := 0 to cMaxBkgColors do
  begin
    p[ cBkgColorFirst + c] := rgb;
    DecRGB( rgb);
  end;

  GetPic(  0,   0,   0);
  GetPic( 16,  64,   0);
  GetPic( 18,  96,   0);
  GetPic( 17, 128,   0);

  GetPic( 19, 192,   0);

  GetPic(  1,   0,  24);
  GetPic(  2,  32,  24);
  GetPic(  3,  64,  24);
  GetPic(  4,  96,  24);
  GetPic(  5, 128,  24);
  GetPic(  6, 160,  24);
  GetPic(  7, 192,  24);
  GetPic(  8, 224,  24);
  GetPic(  9,   0,  48);
  GetPic( 10,  32,  48);
  GetPic( 11,  64,  48);
  GetPic( 12,  96,  48);
  GetPic( 13, 128,  48);
  GetPic( 14, 160,  48);
  GetPic( 15, 192,  48);

  for c := 1 to 15 do
    OverlayPattern( c, a.wallPattern);

  GetPic( 20,   0,  72);
  GetPic( 22,  32,  72);
  GetPic( 23,  64,  72);
  GetPic( 24,  96,  72);
  GetPic( 25, 128,  72);
  GetPic( 21, 160,  72);
  GetPic( 26, 192,  72);

  for c := 20 to 26 do
    OverlayPattern( c, a.wallPattern);

  GetPic( cBkgFloorSkull,    0,  96);
  GetPic( cBkgFloorBlood,   32,  96);
  GetPic( cBkgFloorCrater,  64,  96);

  GetPic( cBkgHorz1,  96,  96);
  GetPic( cBkgHorz2, 128,  96);
  GetPic( cBkgHorz3, 160,  96);
  GetPic( cBkgHorz4, 192,  96);
  GetPic( cBkgHorz5, 224,  96);

  OverlayPattern( cBkgHorz1, a.wallPattern);
  OverlayPattern( cBkgHorz2, a.wallPattern);
  OverlayPattern( cBkgHorz3, a.wallPattern);
  OverlayPattern( cBkgHorz4, a.wallPattern);
  OverlayPattern( cBkgHorz5, a.wallPattern);

  GetPic( cBkgFloorItem1,        0, 120);
  GetPic( cBkgFloorItem2,       32, 120);
  GetPic( cBkgFloorItem3,       64, 120);
  GetPic( cBkgFloorItem4,       96, 120);
  GetPic( cBkgFloorItem5,      128, 120);
  GetPic( cBkgFloorItem6,      160, 120);
  GetPic( cBkgFloorItem7,      192, 120);
  GetPic( cBkgFloorArmorAddOn, 224, 120);
  GetPic( cBkgFloorAxe,        256, 120);

  GetPic( cBkgBlueBoxRemains,     0, 144);
  GetPic( cBkgGreyBoxRemains,    32, 144);
  GetPic( cBkgChaosBoxRemains,   64, 144);
  GetPic( cBkgCrate and cBkgFlagMask, 96, 144);
  GetPic( cBkgCrateRemains,     128, 144);
  GetPic( cBkgBoxRemains,       160, 144);

  GetPic( cBkgFloorDocs,       0, 168);
  GetPic( cBkgFloorFolder,    32, 168);
  GetPic( cBkgFloorDisk,      64, 168);
  GetPic( cBkgFloorCircuit,   96, 168);
  GetPic( cBkgFloorTeddy,    128, 168);
end;


procedure SetClipRange( x, y, x2, y2 : Integer );
begin
  WinMinX := x;
  WinMaxX := x2;
  WinMinY := y;
  WinMaxY := y2;
end;


end.
