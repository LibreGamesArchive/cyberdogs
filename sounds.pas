unit Sounds;


interface


const

  cBangSound      = 1;
  cScreamSound    = 2;
  cBigGunSound    = 3;
  cLaunchSound    = 4;
  cPickupSound    = 5;
  cSmallGunSound  = 6;
  cMinigunSound   = 7;
  cSwitchSound    = 8;
  cFlamerSound    = 9;
  cLaserSound     = 10;
  cSmallBangSound = 11;
  cChainsawSound  = 12;
  cSoundMax       = 12;


procedure InitializeSound( irq, dma : Integer; quality, use486, tsOnly : Boolean );
procedure CloseDownSound;
procedure DoSound( sound : Integer );
procedure DoSoundEffects;
procedure PlaySound( sound : Integer );
procedure PlayMusic( song : String );
procedure StopMusic;
function  GetNextLevelSong : String;


type

  PLevelSong = ^LevelSong;
  LevelSong =
    record
      song : String[8];
      next : PLevelSong;
    end;


const

  gMusic          : Boolean = False;
  gSoundFX        : Boolean = False;
  gMenuSong       : String[8] = 'cebit90';
  gCreditsSong    : String[8] = 'cebit90';
  gFailureSong    : String[8] = 'cebit90';
  gSuccessSong    : String[8] = 'cebit90';
  gHallOfFameSong : String[8] = 'cebit90';
  gLevelSongs     : PLevelSong = nil;
  gSoundFiles     : array [1..cSoundMax] of String[8] =
    ( 'BANG', 'KILL', 'POWERGUN', 'LAUNCH', 'PICKUP',
      'BLASTER', 'MINIGUN', 'SWITCH', 'FLAME', 'LASER', 'POOF', 'CHAINSAW' );


implementation

{ DSMI.Inc contains a USES clause with all DSMI units }
{$I DSMI.Inc};

const

  uPriority : Integer = 0;
  uLastSamplePos : LongInt = 0;

const

  uSoundPriorities : array [1..cSoundMax] of Integer =
    ( 10, 9, 5, 6, 8, 4, 7, 6, 6, 5, 8, 3 );
  {uSongFiles : array [1..cSongMax] of String[8] =
    ( 'CEBIT90',
      'COMPATIL', 'KOL_DOL', 'FUTURE', 'TECH-ROC', '003', 'DRAGLAIR',
      'SYMF2010', 'GNUTTEN', 'COMA' );}

  cSampleFreq   = 11000;
  cSampleVolume = 64;

  uSoundOn  : Boolean = False;
  uModule   : PModule = nil;
  uSoundChannel : Integer = 0;


var

  uSoundFlags : array [1..cSoundMax] of Boolean;
  uSoundData  : array [1..cSoundMax] of TSampleInfo;
  isGus : Boolean;


procedure LoadRawSound( name : String; var sample : TSampleInfo );
var f : File;
begin
  sample.sample := nil;
  Assign( f, name + '.RAW');
  Reset( f, 1);
  if IOResult <> 0 then
    Exit;

  sample.sample := Malloc( FileSize( f));
  if sample.sample = nil then
  begin
    Close( f);
    Exit;
  end;
  BlockRead( f, sample.sample^, FileSize( f));
  with sample do
  begin
    length    := FileSize( f);
    loopstart := 0;
    loopend   := 0;   { No looping }
    mode      := 0;
    sampleID  := 0;
  end;
  cdiDownLoadSample( 0, sample.sample, sample.sample, sample.length);
  Close( f);
end;


procedure InitializeSound( irq, dma : Integer;
                           quality, use486, tsOnly : Boolean );
var i  : Integer;
    sc : TSoundCard;
    options : Integer;
begin
  options := 0;
  if quality then
    options := options or MCP_QUALITY;
  if use486 then
    options := options or MCP_486;
  {if initDSMI( 22000, 2048, 0, @sc) <> 0 then}
  if tsOnly or (initDSMI( 22000, 2048, options, irq, dma, @sc) <> 0) then
  begin
    tsInit;
    atExit( @tsClose);
    Exit;
  end;
  if sc.ID <> ID_GUS then
    mcpStartVoice
  else
    gusStartVoice;
  cdiSetupChannels( 0, 2, nil);
  uSoundOn := True;
  {FillChar( uSoundFlags, SizeOf( uSoundFlags), 0);
  FillChar( uSoundData, SizeOf( uSoundData), 0);

  WriteLn( 'Loading SB driver...');
  if LoadDriver( '\SBPRO\DRV\CT-VOICE.DRV') <> LoadDrvSuccess then
    Exit;
  WriteLn( 'Setting interrupt');
  SetInterrupt( 5);
  WriteLn( 'Setting base IO address');
  SetBaseIOAddress( $220);
  WriteLn( 'Initializing driver...');
  if InitSB <> SBInitSuccess then
    Exit;
  uSB := True;
  WriteLn( 'Initializing status word');
  InitStatusWord;
  WriteLn( 'Turning speaker on');
  TurnSpeakerOn;}
  WriteLn( 'Loading sound files...');
  for i := 1 to cSoundMax do
    LoadRawSound( gSoundFiles[ i], uSoundData[ i]);
  gMusic := True;
  gSoundFX := True;
end;


procedure CloseDownSound;
var i : Integer;
begin
  if not uSoundOn then
    Exit;

  StopMusic;
  cdiStopNote( uSoundChannel);
  cdiStopNote( uSoundChannel+1);
  for i := 1 to cSoundMax do
    with uSoundData[ i] do
      if sample <> nil then
        Free( sample);
end;


procedure DoSound( sound : Integer );
begin
  uSoundFlags[ sound] := True;
end;


procedure PlaySound( sound : Integer );
begin
  if uPriority > 0 then
  begin
    cdiStopNote( uSoundChannel);
    cdiStopNote( uSoundChannel+1);
    uPriority := 0;
  end;
  DoSound( sound);
  DoSoundEffects;
end;


procedure DoSoundEffects;

  procedure DoSound;
  var i : Integer;
  begin
    for i := 1 to cSoundMax do
      if uSoundFlags[ i] and
         (uSoundData[ i].sample <> nil) and
         (uSoundPriorities[i] > uPriority) then
      begin
        if uPriority > 0 then
        begin
          cdiStopNote( uSoundChannel);
          cdiStopNote( uSoundChannel+1);
        end;
        uPriority := uSoundPriorities[i];
        cdiSetInstrument( uSoundChannel, @uSoundData[i]);
        cdiSetInstrument( uSoundChannel+1, @uSoundData[i]);
        cdiPlayNote( uSoundChannel, cSampleFreq, cSampleVolume);
        cdiPlayNote( uSoundChannel+1, cSampleFreq, cSampleVolume);
        Exit;
      end;
  end;

var pos : LongInt;
begin
  if not (uSoundOn and gSoundFX) then
    Exit;

  if uPriority > 0 then
  begin
    {if cdiGetChannelStatus( uSoundChannel) and ch_Playing = 0 then
      uPriority := 0;}
    pos := cdiGetPosition( uSoundChannel);
    if pos = uLastSamplePos then
      uPriority := 0
    else
      uLastSamplePos := pos;
  end;

  DoSound;
  FillChar( uSoundFlags, SizeOf( uSoundFlags), 0);
end;


procedure StopMusic;
var i : Integer;
begin
  if uModule <> nil then
  begin
    ampStopModule;
    ampFreeModule( uModule);
    uModule := nil;

    { This is a patch for a bug in ampStopModule in the previous release.
      That version unloads ALL samples thus forcing me to
      reload them again.
      This is supposedly fixed in the current release.
      BUT...the current release slows my game WAY down on
      some machines only...weeiird... }

    for i := 1 to cSoundMax do
      with uSoundData[ i] do
        if sample <> nil then
          cdiDownLoadSample( 0, sample, sample, length);
  end;
end;


function GetNextLevelSong : String;
var h : ^PLevelSong;
    s : PLevelSong;
begin
  if gLevelSongs = nil then
  begin
    GetNextLevelSong := '';
    Exit;
  end;
  h := @gLevelSongs;
  while h^^.next <> nil do
    h := @h^^.next;
  s := h^;
  h^ := nil;
  s^.next := gLevelSongs;
  gLevelSongs := s;
  GetNextLevelSong := s^.song;
end;


procedure PlayMusic( song : String );
begin
  if not gMusic then
    Exit;

  StopMusic;
  uModule := ampLoadAMF( song + '.AMF', 0);
  if uModule = nil then
    Exit;
  cdiSetupChannels( 0, uModule^.channelCount + 2, nil);
  uSoundChannel := uModule^.channelCount;
  cdiSetMasterVolume( 0, 64);
  ampPlayModule( uModule, PM_LOOP);
end;


end.
