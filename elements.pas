unit Elements;


interface


const

  cIdHero1 = 0;
  cIdHero2 = 1;
  cIdEvil  = 2;


type

  PCharacter = ^TCharacter;
  TCharacter =
    record
      id            : Byte;

      x, y          : Integer;
      xFrac, yFrac  : Integer;
      speed         : Integer;

      direction     : Byte;
      faceDir       : Byte;
      facial        : Byte;
      face          : Byte;
      body          : Byte;
      gunPic        : Byte;
      gunPos        : Byte;
      phase         : Byte;
      command       : Byte;

      armor         : Integer;
      lives         : Integer;
      invincibility : Integer;
      dead          : Boolean;
      deathCount    : Integer;

      gun :
        record
          kind      : Byte;
          lock      : Byte;
          ammo      : Integer;
        end;
      closeCombat   : Byte;

      cmd           : Byte;
      actionDelay,
      delay         : Byte;

      visible,
      sleeping      : Boolean;
      moving,
      shooting,
      launching,
      tracking      : Byte;
      isTarget      : Boolean;
      boobyTrapped  : Boolean;
      detouring     : Boolean;
      tryRight      : Boolean;
      turns         : Integer;
      currentDir    : Word;
      distanceToPlayer : Word;

      prev,
      next          : PCharacter;
    end;

  PBullet = ^TBullet;
  TBullet =
    record
      id            : Byte;
      kind          : Byte;
      x, y          : Integer;
      xFrac,
      yFrac         : Integer;
      dx, dy        : Integer;
      range         : Integer;
      owner         : Byte;
      pic           : Integer;
      prev,
      next          : PBullet;
    end;


  PFireBall = ^TFireBall;
  TFireBall =
    record
      stage         : Integer;
      x, y          : Integer;
      prev,
      next          : PFireBall;
    end;


function  AddCharacter( id : Byte ) : PCharacter;
function  RemoveCharacter( c : PCharacter ) : PCharacter;
function  AddBullet : PBullet;
function  RemoveBullet( b : PBullet ) : PBullet;
function  AddFireBall : PFireBall;
function  RemoveFireBall( f : PFireBall ) : PFireBall;
procedure RemoveAllElements;


const

  gHero1      : PCharacter = nil;
  gHero2      : PCharacter = nil;
  gCharacters : PCharacter = nil;
  gBullets    : PBullet    = nil;
  gFireBalls  : PFireBall  = nil;



implementation



function AddCharacter( id : Byte ) : PCharacter;
var c : PCharacter;
begin
  New( c);
  FillChar( c^, SizeOf( c^), 0);
  c^.id := id;
  c^.prev := nil;
  c^.next := gCharacters;
  if gCharacters <> nil then
    gCharacters^.prev := c;
  gCharacters := c;
  AddCharacter := c;
end;


function RemoveCharacter( c : PCharacter ) : PCharacter;
begin
  if c^.next <> nil then
    c^.next^.prev := c^.prev;
  if c^.prev <> nil then
    c^.prev^.next := c^.next
  else
    gCharacters := c^.next;
  RemoveCharacter := c^.next;
  if c = gHero1 then
    gHero1 := nil;
  if c = gHero2 then
    gHero2 := nil;
  Dispose( c);
end;


function AddBullet : PBullet;
var b : PBullet;
begin
  New( b);
  FillChar( b^, SizeOf( b^), 0);
  b^.prev := nil;
  b^.next := gBullets;
  if gBullets <> nil then
    gBullets^.prev := b;
  gBullets := b;
  AddBullet := b;
end;


function RemoveBullet( b : PBullet ) : PBullet;
begin
  if b^.next <> nil then
    b^.next^.prev := b^.prev;
  if b^.prev <> nil then
    b^.prev^.next := b^.next
  else
    gBullets := b^.next;
  RemoveBullet := b^.next;
  Dispose( b);
end;


function AddFireBall : PFireBall;
var f : PFireBall;
begin
  New( f);
  FillChar( f^, SizeOf( f^), 0);
  f^.prev := nil;
  f^.next := gFireBalls;
  if gFireBalls <> nil then
    gFireBalls^.prev := f;
  gFireBalls := f;
  AddFireBall := f;
end;


function RemoveFireBall( f : PFireBall ) : PFireBall;
begin
  if f^.next <> nil then
    f^.next^.prev := f^.prev;
  if f^.prev <> nil then
    f^.prev^.next := f^.next
  else
    gFireBalls := f^.next;
  RemoveFireBall := f^.next;
  Dispose( f);
end;


procedure RemoveAllElements;
begin
  while gCharacters <> nil do
    RemoveCharacter( gCharacters);
  while gBullets <> nil do
    RemoveBullet( gBullets);
  while gFireBalls <> nil do
    RemoveFireBall( gFireBalls);
end;


end.
