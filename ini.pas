unit Ini;


interface


type

  PValue = ^TValue;
  TValue =
    record
      key   : String[20];
      value : String[80];
      next  : PValue;
    end;

  PSection = ^TSection;
  TSection =
    record
      name     : String[20];
      settings : PValue;
      next     : PSection;
    end;


function  Equal( s1, s2 : String ) : Boolean;
function  LoadIniFile( name : String; var settings : PSection ) : Boolean;
function  FindIniString( settings : PSection; section, key, default : String ) : String;
function  FindIniNumber( settings : PSection; section, key : String; default : LongInt ) : LongInt;
function  FindIniBoolean( settings : PSection; section, key : String; default : Boolean ) : Boolean;
procedure SetIniString( var settings : PSection; section, key, value : String );
procedure SetIniNumber( var settings : PSection; section, key : String; value : LongInt );
procedure SetIniBoolean( var settings : PSection; section, key : String; value : Boolean );
function  GetIniValues( settings : PSection; section : String ) : PValue;
procedure WriteIniFile( name : String; settings : PSection );
procedure DisposeSettings( var settings : PSection );


implementation

  uses SPX_Fnc;


function Equal( s1, s2 : String ) : Boolean;
begin
  s1 := Ups( s1);
  s2 := Ups( s2);
  Equal := s1 = s2;
end;


procedure AddSetting( var settings : PSection; section, key, value : String );
var h : ^PSection;
    v : ^PValue;
begin
  h := @settings;
  while (h^ <> nil) and not Equal( h^^.name, section) do
    h := @h^^.next;
  if h^ = nil then
  begin
    New( h^);
    h^^.next := nil;
    h^^.name := section;
    h^^.settings := nil;
  end;
  v := @h^^.settings;
  while v^ <> nil do
    v := @v^^.next;
  New( v^);
  v^^.key := key;
  v^^.value := value;
  v^^.next := nil;
end;


procedure SetSetting( var settings : PSection; section, key, value : String );
var h : ^PSection;
    v : ^PValue;
begin
  h := @settings;
  while (h^ <> nil) and not Equal( h^^.name, section) do
    h := @h^^.next;
  if h^ = nil then
  begin
    New( h^);
    h^^.next := nil;
    h^^.name := section;
    h^^.settings := nil;
  end;
  v := @h^^.settings;
  while (v^ <> nil) and not Equal( v^^.key, key) do
    v := @v^^.next;
  if v^ = nil then
  begin
    New( v^);
    v^^.next := nil;
  end;
  v^^.key := key;
  v^^.value := value;
end;


procedure DisposeSettings( var settings : PSection );
var s : PSection;
    v : PValue;
begin
  while settings <> nil do
  begin
    s := settings;
    settings := s^.next;
    while s^.settings <> nil do
    begin
      v := s^.settings;
      s^.settings := v^.next;
      Dispose( v);
    end;
    Dispose( s);
  end;
end;


function GetIniValues( settings : PSection; section : String ) : PValue;
begin
  while settings <> nil do
  begin
    if Equal( settings^.name, section) then
    begin
      GetIniValues := settings^.settings;
      Exit;
    end;
    settings := settings^.next;
  end;
  GetIniValues := nil;
end;


function FindIniString( settings : PSection; section, key, default : String ) : String;
var v : PValue;
begin
  while settings <> nil do
  begin
    if Equal( settings^.name, section) then
    begin
      v := settings^.settings;
      while v <> nil do
      begin
        if Equal( v^.key, key) then
        begin
          FindIniString := v^.value;
          Exit;
        end;
        v := v^.next;
      end;
    end;
    settings := settings^.next;
  end;
  FindIniString := default;
end;


function FindIniNumber( settings : PSection; section, key : String; default : LongInt ) : LongInt;
var s : String;
    x : LongInt;
    ignore : Integer;
begin
  s := FindIniString( settings, section, key, '');
  if s = '' then
    FindIniNumber := default
  else begin
    Val( s, x, ignore);
    FindIniNumber := x;
    Exit;
  end;
end;


function FindIniBoolean( settings : PSection; section, key : String; default : Boolean ) : Boolean;
var s : String;
begin
  s := FindIniString( settings, section, key, '');
  s := Ups( s);
  if s = 'TRUE' then
    FindIniBoolean := True
  else if s = 'FALSE' then
    FindIniBoolean := False
  else
    FindIniBoolean := default;
end;


procedure SetIniString( var settings : PSection; section, key, value : String );
begin
  SetSetting( settings, section, key, value);
end;


procedure SetIniNumber( var settings : PSection; section, key : String; value : LongInt );
begin
  SetSetting( settings, section, key, St( value));
end;


procedure SetIniBoolean( var settings : PSection; section, key : String; value : Boolean );
begin
  if value then
    SetSetting( settings, section, key, 'True')
  else
    SetSetting( settings, section, key, 'False');
end;


function LoadIniFile( name : String; var settings : PSection ) : Boolean;
var s : String;
    section : String;
    p : Byte;
    f : Text;
begin
  LoadIniFile := False;
  settings := nil;
  Assign( f, name + '.INI');
  Reset( f);
  if IOResult <> 0 then
    Exit;

  section := '';
  while not Eof( f) do
  begin
    ReadLn( f, s);
    if s[1] = '[' then
    begin
      p := Pos( ']', s);
      if p > 0 then
        section := Copy( s, 2, p-2)
      else
        section := Copy( s, 2, Length( s)-1);
    end
    else if (s <> '') and (s[1] <> ';') and (Pos( '=', s) > 0) then
    begin
      while Pos( ' ', s) > 0 do
        Delete( s, Pos( ' ', s), 1);
      p := Pos( '=', s);
      AddSetting( settings, section, Copy( s, 1, p-1), Copy( s, p+1, Length( s)-p));
    end
    else
      AddSetting( settings, section, '', s);
  end;
  Close( f);
  LoadIniFile := settings <> nil;
end;


procedure WriteIniFile( name : String; settings : PSection );
var f : Text;
    v : PValue;
begin
  Assign( f, name + '.INI');
  Rewrite( f);
  if IOResult <> 0 then
    Exit;

  while settings <> nil do
  begin
    if settings^.name <> '' then
      WriteLn( f, '[', settings^.name, ']');
    v := settings^.settings;
    while v <> nil do
    begin
      if v^.key = '' then
        WriteLn( f, v^.value)
      else
        WriteLn( f, v^.key, '=', v^.value);
      v := v^.next;
    end;
    settings := settings^.next;
  end;
  Close( f);
end;


end.
