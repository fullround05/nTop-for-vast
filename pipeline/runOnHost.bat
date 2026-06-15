:: turn off command echo
@echo off

:: Configuration
set IP=%1
set Port=%2

set ntopUname=%3
set ntopPasswd=%4

set Velocity=[0,300,0]
set VelocityUnits=mm/s

set Pressure=101325
set PressureUnits=Pa

set CellSize=15
set CellSizeUnits=mm

:: Change working directory to the folder this script is located in
cd /d "%~dp0"

:: Build the JSON input file
(
echo {
echo     "description": "",
echo     "inputs": [
echo         {
echo             "description": "",
echo             "name": "Inlet Velocity",
echo             "type": "vector",
echo             "value": %Velocity%,
echo             "units": "%VelocityUnits%"
echo         },
echo         {
echo             "description": "",
echo             "name": "Outlet Pressure",
echo             "type": "real",
echo             "value": %Pressure%,
echo             "units": "%PressureUnits%"
echo         },
echo         {
echo             "description": "",
echo             "name": "Cell Size",
echo             "type": "real",
echo             "value": %CellSize%,
echo             "units": "%CellSizeUnits%"
echo         }
echo     ],
echo     "title": "Server Side CFD"
echo }
) > exchange\input.json

:: Import the ssh key so the user is prompted to decrypt the key if needed
pageant.exe key.ppk

:: Copy the inputs, notebook, and simulation models to the server
pscp.exe -P %port% input.json root@%ip%:input.json
pscp.exe -P %port% ServerRunner.ntop root@%ip%:
pscp.exe -P %port% exchange\Fluid.implicit root@%ip%:
pscp.exe -P %port% exchange\Inlet.implicit root@%ip%:
pscp.exe -P %port% exchange\Outlet.implicit root@%ip%:


:: SSH to the server and run the flow analysis
plink.exe -P %Port% root@%IP% "ntopcl --username %ntopUname% --password %ntopPasswd% -v2 -j input.json ServerRunner.ntop"

pscp.exe -P %port% root@%ip%:Result.vti exchange\Result.vti
