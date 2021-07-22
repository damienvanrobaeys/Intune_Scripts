# Invoke_LocateDevice.ps1
This allows you to:
- Locate an Intune device
- Display last location
- Display location in a MAP in your browser
- Display real location address

**Note that this uses the module Microsoft.Graph.Intune**

**How to use it ?**
The script contains the below parameters:
- Device_Name: type the device name to locate
- LastLocation: switch used to display the last location
- MAP: switch to display location in a Map in your browser
- Address: switch to display exact address in PowerShell

**Display basic location**

This will get location of a device and display basic info in PowerShell.
</br>
See the command to use: Invoke_LocateDevice.ps1 -Device_Name "TEST"

**Display location in a MAP**

This will get location of a device and display it in a MAP in your browser.
See the command to use: Invoke_LocateDevice.ps1 -Device_Name "TEST"

**Get last location**

This will get the last location of a device and display it in a MAP in your browser.
See the command to use: Invoke_LocateDevice.ps1 -Device_Name "TEST" -LastLocation -MAP

**Display address**

This will get the last location of a device and display it in a MAP in your browser.
See the command to use: Invoke_LocateDevice.ps1 -Device_Name "TEST" -Address
