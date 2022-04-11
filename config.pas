unit Config;


interface


implementation


procedure GetConfiguration;
var s : PSetting;
begin
  LoadIniFile( 'DOGS', s);

end;



end.