E:

cd E:\FlightGear 2024.1\

SET FG_ROOT=E:\FlightGear 2024.1\\data

START .\bin\fgfs.exe --fdm=null --native-fdm=socket,in,30,localhost,5502,udp --aircraft=Kirov --fog-fastest --disable-clouds --timeofday=noon  --airport=X51 --runway=36 --altitude=2 --heading=0 --offset-distance=0 --offset-azimuth=0 --config=custom_tower.xml