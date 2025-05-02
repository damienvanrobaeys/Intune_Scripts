# Invoke_LocateDevice.ps1
This allows you to:
- Locate an Intune device
- Display last location
- Display location in a MAP in your browser
- Display real location address

**Things to notice**
- Getting location of a device can take a while
- Displaying real  address may display an error if you use it multiple times, just try later in this case

**How to use it ?**
</br>
The script contains the below parameters:
- DeviceName: type the device name to locate
- UseLastLocation: switch used to display the last location
- MAP: switch to display location in a Map in your browser
- Address: switch to display exact address in PowerShell

**Display basic location**
</br>
This will get location of a device and display basic info in PowerShell.
</br>
See the command to use: Invoke_LocateDevice.ps1 -DeviceName "TEST"

**Display location in a MAP**
</br>
This will get location of a device and display it in a MAP in your browser.
</br>
See the command to use: Invoke_LocateDevice.ps1 -DeviceName "TEST"

**Get last location**
</br>
This will get the last location of a device and display it in a MAP in your browser.
</br>
See the command to use: Invoke_LocateDevice.ps1 -Device_Name "TEST" -UseLastLocation -MAP

**Display address**
</br>
This will get the last location of a device and display it in a MAP in your browser.
</br>
See the command to use: Invoke_LocateDevice.ps1 -DeviceName "TEST" -Address
