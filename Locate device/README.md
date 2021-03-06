# Invoke_LocateDevice.ps1
This allows you to:
- Locate an Intune device
- Display last location
- Display location in a MAP in your browser
- Display real location address


**Things to notice**
- There are two folers depending of the module you use
- The script uses the module Microsoft.Graph.Intune or MSAL.PS
- Getting location of a device can take a while
- Displaying real  address may display an error if you use it multiple times, just try later in this case


**How to use it ?**
</br>
The script contains the below parameters:
- Device_Name: type the device name to locate
- LastLocation: switch used to display the last location
- MAP: switch to display location in a Map in your browser
- Address: switch to display exact address in PowerShell

**Display basic location**
</br>
This will get location of a device and display basic info in PowerShell.
</br>
See the command to use: Invoke_LocateDevice.ps1 -Device_Name "TEST"

**Display location in a MAP**
</br>
This will get location of a device and display it in a MAP in your browser.
</br>
See the command to use: Invoke_LocateDevice.ps1 -Device_Name "TEST"

**Get last location**
</br>
This will get the last location of a device and display it in a MAP in your browser.
</br>
See the command to use: Invoke_LocateDevice.ps1 -Device_Name "TEST" -LastLocation -MAP

**Display address**
</br>
This will get the last location of a device and display it in a MAP in your browser.
</br>
See the command to use: Invoke_LocateDevice.ps1 -Device_Name "TEST" -Address
