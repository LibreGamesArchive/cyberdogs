unit Equip;


interface


procedure GetEquipment( index : Integer; var cash : LongInt );
function  GetMenuCommand : Byte;


implementation

  uses SPX_Fnc, SPX_VGA, SPX_Txt, Pics, Fancy, BigFont,
       Globals, Keyboard, Joystick, Stick, Screen, Sounds;


const

  cArmor = 255;
  cAxe   = 254;
  cLife  = 253;
  cDone  = 252;

  cSelectionMax = 9;


type

  EquipmentRec =
    record
      what : Byte;
      pic : Integer;
      description : String[80];
      price, ammoPrice, ammoBlock : Integer;
    end;


function GetMenuCommand : Byte;
var command : Byte;

  procedure CheckStick( stick : Byte );
  begin
    if stick = 0 then
      Exit;
    if StickLeft( stick) then
      command := command or cCommandLeft;
    if StickRight( stick) then
      command := command or cCommandRight;
    if StickUp( stick) then
      command := command or cCommandUp;
    if StickDown( stick) then
      command := command or cCommandDown;
    if StickButton1( stick) then
      command := command or cCommandShoot;
    if StickButton2( stick) then
      command := command or cCommandSwitch;
  end;

begin
  command := 0;

  VSinc;
  PollSticks;
  CheckStick( hero1Keys.stick);
  CheckStick( hero2Keys.stick);

  if KeyDown( keyArrowLeft) then
    command := command or cCommandLeft;
  if KeyDown( keyArrowRight) then
    command := command or cCommandRight;
  if KeyDown( keyArrowUp) then
    command := command or cCommandUp;
  if KeyDown( keyArrowDown) then
    command := command or cCommandDown;
  if KeyDown( keyEnter) then
    command := command or cCommandShoot;
  if KeyDown( keySpace) then
    command := command or cCommandShoot;
  if KeyDown( keyBackspace) then
    command := command or cCommandSwitch;
  if KeyDown( keyKeypadMinus) then
    command := command or cCommandSwitch;
  if KeyDown( keyEsc) then
    command := command or cCommandFreeze;

  GetMenuCommand := command;
end;

procedure GetEquipment( index : Integer; var cash : LongInt );
var choice    : Integer;
    done      : Boolean;
    selection : array [0..cSelectionMax] of EquipmentRec;
    max       : Integer;

{
  function HasWeapon( kind : Byte; var which : Integer ) : Boolean;
  var i : Integer;
  begin
    HasWeapon := True;
    for i := 0 to cMaxWeaponry do
      if gPlayerData[ index].weapons[i].kind = kind then
      begin
        which := i;
        Exit;
      end;
    HasWeapon := False;
  end;
}

  procedure MakeSelection;

    procedure SetEquipment( var eq : EquipmentRec;
                            what : Byte;
                            pic : Integer;
                            description : String;
                            price,
                            ammoPrice,
                            ammoBlock : Integer );
    begin
      eq.what := what;
      eq.pic := pic;
      eq.description := description;
      eq.price := price;
      eq.ammoPrice := ammoPrice;
      eq.ammoBlock := ammoBlock;
    end;

    procedure SetWeapon( var eq : EquipmentRec;
                         what : Byte;
                         price,
                         ammoPrice,
                         ammoBlock : Integer );
    begin
      SetEquipment( eq, what,
                    cGunStyles[ what].pic, cGunStyles[ what].name,
                    price, ammoPrice, ammoBlock);
    end;


  begin
    SetEquipment( selection[0], cLife, cGoldSkullPic, 'Life', 4000, 0, 0);
    SetEquipment( selection[1], cArmor, cArmorAddOnPic, 'Armor +', 2000, 0, 0);
    SetEquipment( selection[2], cAxe, cAxePic, 'Chainsaw', 2000, 0, 0);
    SetWeapon( selection[3], cBlaster,   1000,  500,  50);
    SetWeapon( selection[4], cPowerGun,  2000,  300,  10);
    SetWeapon( selection[5], cFlamer,    2500,  500, 100);
    SetWeapon( selection[6], cSprayer,   2500,  500, 100);
    SetWeapon( selection[7], cGrenade,   1500, 1000,   5);
    SetWeapon( selection[8], cMegaGun,   5500, 3000, 100);
    SetEquipment( selection[9], cDone, -1, 'Done', 0, 0, 0);
  end;

  procedure DrawEquipScreen;

    procedure DrawEquipment( x, y : Integer; const eq : EquipmentRec );
    begin
      {if eq.pic >= 0 then
        fTPut( x, y, gPics[ eq.pic]^, False);}
      if eq.ammoBlock <= 0 then
        Inc( y, 5);
      if eq.price > 0 then
        DrawLetter( x, y + 4, cWhite, cBlack, eq.description + ', ' + St( eq.price + eq.ammoPrice) + 'Cr')
      else
        DrawLetter( x, y + 4, cWhite, cBlack, eq.description);
      if eq.ammoBlock > 0 then
        DrawLetter( x, y + 12, cGray, cBlack, 'Ammo: ' + St( eq.ammoPrice) + 'Cr/' + St( eq.ammoBlock));
    end;

  var i : Integer;
  begin
    FillScreen( cSteelPlate);
    BigText( 40, 20, 'ARMOURY');

    i := 0;
    while i <= cSelectionMax do
    begin
      DrawEquipment( 105, 40 + (i div 2)*22, selection[i]);
      Inc( i);
      DrawEquipment( 215, 40 + (i div 2)*22, selection[i]);
      Inc( i);
    end;

    DrawLetter( 70, 180, cWhite, cBlack, 'Use up/down to highlight and Enter/button to buy');
    DrawLetter( 70, 190, cWhite, cBlack, 'Use Backspace/button #2 to sell');
    PCopy( 2, 1);
  end;

  procedure DrawPlayer;

    procedure DrawInventory( x, y : Integer );
    var i : Integer;
    begin
      for i := 1 to gPlayerData[ index].lives do
        fTPut( x + 20 + ((i-1) mod 2)*12, y - 10 + ((i-1) div 2)*12, gPics[ cGoldSkullPic]^, False);
      DrawLetter( x + 7, y + 33, cWhite, cBlack, 'Armor:' + St( gPlayerData[ index].armor));
      if gPlayerData[ index].closeCombat > 1 then
        DrawLetter( x + 7, y + 41, cWhite, cBlack, 'Chainsaw: ' + St( gPlayerData[ index].closeCombat div 2))
      else
        DrawLetter( x + 7, y + 41, cWhite, cBlack, 'Barehanded');
      for i := 0 to cMaxWeaponry do
        with gPlayerData[ index].weapons[i] do
          if kind <> 0 then
          begin
            fTPut( x, y + 50 + i*20, gPics[ cGunStyles[ kind].pic]^, False);
            DrawLetter( x + 20, y + 65 + i*20, cWhite, cBlack, St( ammo));
          end;
      if gPlayerData[0].playing and gPlayerData[1].playing and
         (g2PlayerPool and cPoolCash <> 0) then
        DrawLetter( 10, 190, cRed, cBlack, 'Pool: '+St( cash) + 'Cr')
      else
        DrawLetter( 10, 190, cYellow, cBlack, 'Cash: '+St( cash) + 'Cr');
    end;

  var x, y : Integer;
  begin
    for x := 0 to 1 do
      for y := 2 to 9 do
        fPut( x*32, y*20, gPics[ cSteelPlate]^, False);
    DrawInventory( 5, 40);
    with cHeroInfo[ gPlayerData[ index].hero] do
    begin
      DrawCharacter( 10, 40, cDirectionDown, cDirectionDownRight, face, body, cGunDogs, cFaceNormal, 0, cGunIdle);
      DrawLetter( 12, 65, cWhite, cBlack, name);
    end;
    CopyRect( 0, 25, 79, 199, pages[2]^, pages[1]^);
  end;

  procedure DrawSelection;

    procedure DrawButton( x, y, index : Integer );
    begin
      if choice = index then
        fTPut( x, y, gPics[ cHilitedButton]^, False)
      else
        fTPut( x, y, gPics[ cButton]^, False);
    end;

  var i : Integer;
  begin
    i := 0;
    while i <= cSelectionMax do
    begin
      DrawButton(  85, 45 + (i div 2)*22, i);
      Inc( i);
      DrawButton( 195, 45 + (i div 2)*22, i);
      Inc( i);
    end;

    CopyRect( 80, 40, 319, 199, pages[2]^, pages[1]^);
  end;

  function HasWeapon( kind : Byte ) : Boolean;
  var i : Integer;
  begin
    HasWeapon := False;
    for i := 0 to cMaxWeaponry do
      if gPlayerData[ index].weapons[i].kind = kind then
        HasWeapon := True;
  end;

  function WeaponCount : Integer;
  var i, count : Integer;
  begin
    count := 0;
    for i := 0 to cMaxWeaponry do
      if gPlayerData[ index].weapons[i].kind > 0 then
        Inc( count);
    WeaponCount := count;
  end;

  function Cost( var eq : EquipmentRec ) : Integer;
  begin
    if (eq.ammoBlock > 0) and HasWeapon( eq.what) then
      Cost := eq.ammoPrice
    else
      Cost := eq.price + eq.ammoPrice;
  end;

  function CanBuy( var eq : EquipmentRec ) : Boolean;
  var ok : Boolean;
  begin
    ok := True;
    case eq.what of

      cLife:
        ok := gPlayerData[ index].lives < 4;

      cArmor:
        ok := gPlayerData[ index].armor < 50;

      cAxe:
        ok := gPlayerData[ index].closeCombat <= 10;

      cPowerGun, cBlaster, cFlamer, cSprayer, cGrenade, cMegaGun:
        ok := HasWeapon( eq.what) or (WeaponCount < 4);

    end;
    CanBuy := ok and (Cost( eq) <= cash);
  end;

  function AddWeapon( kind : Byte; ammo : Integer ) : Boolean;
  var i : Integer;
  begin
    AddWeapon := True;
    for i := 0 to cMaxWeaponry do
      if gPlayerData[ index].weapons[i].kind = kind then
      begin
        Inc( gPlayerData[ index].weapons[i].ammo, ammo);
        Exit;
      end
      else if gPlayerData[ index].weapons[i].kind <= 0 then
      begin
        gPlayerData[ index].weapons[i].kind := kind;
        gPlayerData[ index].weapons[i].ammo := ammo;
        Exit;
      end;
    AddWeapon := False;
  end;

  procedure EnterPressed( choice : Integer );
  var i : Integer;
  begin
    if CanBuy( selection[ choice]) then
    begin
      Dec( cash, Cost( selection[ choice]));
      PlaySound( cSwitchSound);
      with selection[ choice] do
        if what = cArmor then
          Inc( gPlayerData[ index].armor, 5)
        else if what = cAxe then
          Inc( gPlayerData[ index].closeCombat, 2)
        else if what = cLife then
          Inc( gPlayerData[ index].lives)
        else
          AddWeapon( what, ammoBlock);
    end
    else
      PlaySound( cScreamSound);
  end;

  function CanSell( var eq : EquipmentRec ) : Boolean;
  var ok : Boolean;
  begin
    ok := True;
    case eq.what of

      cLife:
        ok := gPlayerData[ index].lives > 1;

      cArmor:
        ok := gPlayerData[ index].armor > 5;

      cAxe:
        ok := gPlayerData[ index].closeCombat > 2;

      cPowerGun, cBlaster, cFlamer, cSprayer, cGrenade, cMegaGun:
        ok := HasWeapon( eq.what);

    end;
    CanSell := ok;
  end;

  function RemoveWeapon( kind : Byte; ammo, price, ammoPrice : Integer ) : Boolean;
  var i, j : Integer;
  begin
    RemoveWeapon := True;
    for i := 0 to cMaxWeaponry do
      if gPlayerData[ index].weapons[i].kind = kind then
      begin
        if gPlayerData[ index].weapons[i].ammo >= ammo then
        begin
          Dec( gPlayerData[ index].weapons[i].ammo, ammo);
          Inc( cash, ammoPrice);
          Exit;
        end;
        for j := i + 1 to cMaxWeaponry do
          gPlayerData[ index].weapons[j-1] := gPlayerData[ index].weapons[j];
        gPlayerData[ index].weapons[ cMaxWeaponry].kind := 0;
        Inc( cash, price);
      end;
    RemoveWeapon := False;
  end;

  procedure MinusPressed( choice : Integer );
  var i : Integer;
  begin
    if CanSell( selection[ choice]) then
    begin
      PlaySound( cPickupSound);
      with selection[ choice] do
      begin
        if what = cArmor then
          Dec( gPlayerData[ index].armor, 5)
        else if what = cAxe then
          Dec( gPlayerData[ index].closeCombat, 2)
        else if what = cLife then
          Dec( gPlayerData[ index].lives)
        else begin
          RemoveWeapon( what, ammoBlock, price, ammoPrice);
          Exit;
        end;
        Inc( cash, price);
      end;
    end
    else
      PlaySound( cScreamSound);
  end;

var cmd : Byte;
begin
  if not gPlayerData[ index].playing then
    Exit;

  choice := 0;
  done := False;

  SetPageActive( 2);
  MakeSelection;
  DrawEquipScreen;
  DrawPlayer;
  DrawSelection;
  FadeIn( 5, gPalette);

  while not done do
  begin
    if cmd <> GetMenuCommand then
    begin
      cmd := GetMenuCommand;
      case cmd of

        cCommandShoot:
          if selection[ choice].what = cDone then
          begin
            done := True;
            PlaySound( cLaunchSound);
          end
          else begin
            EnterPressed( choice);
            DrawPlayer;
          end;

        cCommandSwitch:
          if selection[ choice].what <> cDone then
          begin
            MinusPressed( choice);
            DrawPlayer;
          end;

        cCommandUp:
          begin
            if choice > 1 then
              Dec( choice, 2)
            else
              choice := cSelectionMax;
            DrawSelection;
          end;

        cCommandDown:
          begin
            if choice < cSelectionMax-1 then
              Inc( choice, 2)
            else
              choice := 0;
            DrawSelection;
          end;

        cCommandLeft:
          begin
            if choice > 0 then
              Dec( choice)
            else
              choice := cSelectionMax;
            DrawSelection;
          end;

        cCommandRight:
          begin
            if choice < cSelectionMax then
              Inc( choice)
            else
              choice := 0;
            DrawSelection;
          end;

      end;
    end;
  end;
  FadeOut( 5, gPalette);
end;


end.
