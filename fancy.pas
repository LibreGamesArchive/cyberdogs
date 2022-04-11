unit Fancy;


interface

  uses SPX_Fnc,
       {$IFDEF XLIB} XSPX {$ELSE} SPX_VGA {$ENDIF};


procedure FancyPut( x, y : Integer; var pic; center : Boolean; dx, dy : Integer );


implementation


type

  PByte = ^Byte;


procedure FancyPut( x, y : Integer; var pic; center : Boolean; dx, dy : Integer );

{$IFDEF XLIB}

begin
  fTPut_Clip( x, y, pic, center);
end;

{$ELSE}

var w, h : Integer;
    xc,
    x1, y1, x2, y2,
    xOffset,
    lines : Integer;
    src, dst : PByte;
    seg : Word;
begin
  if dx < 0 then
    dx := 0;
  if dy < 0 then
    dy := 0;
  ImageDims( pic, w, h);
  if not center then
  begin
    Inc( x, w div 2);
    Inc( y, h div 2);
  end;
  Dec( x, (w div 2)*(1+dx));
  Dec( y, (h div 2)*(1+dy));

  Dec( h);
  if y < WinMinY then
  begin
    y1 := 1 + (WinMinY - y - 1) div (1+dy);
    y := y + y1*dy;
  end
  else
    y1 := 0;
  if y + h*dy > WinMaxY then
    y2 := 1 + (h*dy - WinMaxY - 1) div (1+dy)
  else
    y2 := h;

  if x < WinMinX then
  begin
    x1 := 1 + (WinMinX - x - 1) div (1+dx);
    x := x + x1*dx;
  end
  else
    x1 := 0;
  if x + (w-1)*dx > WinMaxX then
    x2 := 1 + ((w-1)*dx - WinMaxX - 1) div (1+dx)
  else
    x2 := w;

  xOffset := x1 + (w - x2);
  lines := y2 - y1;
  src := PByte( @pic);
  Inc( LongInt( src), 4 + y1*w + x1);
  dst := Ptr( ScnSeg, Pt( x, y));
  while lines >= 0 do
  begin
    dst := Ptr( ScnSeg, Pt( x, y));
    for xc := x1 to x2-1 do
    begin
      if src^ <> 0 then
        dst^ := src^;
      Inc( src);
      Inc( LongInt( dst), 1+dx);
    end;
    Inc( LongInt( src), xOffset);
    Inc( y, 1+dy);
    Dec( lines);
  end;
end;

{$ENDIF}


end.
