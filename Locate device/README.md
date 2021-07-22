# Invoke_LocateDevice.ps1
This allows you to:
- Locate an Intune device
- Display last location
- Display location in a MAP in your browser
- Display real location address

</br>
**Note that this uses the module Microsoft.Graph.Intune**

</br>
**How to use it ?**
The script contains the below parameters:
- Device_Name: type the device name to locate
- LastLocation: switch used to display the last location
- MAP: switch to display location in a Map in your browser
- Address: switch to display exact address in PowerShell

</br>
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
