;====================== BEGIN GPL LICENSE BLOCK ======================
;
;  This program is free software; you can redistribute it and/or
;  modify it under the terms of the GNU General Public License
;  as published by the Free Software Foundation; either version 2
;  of the License, or (at your option) any later version.
;
;  This program is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  GNU General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with this program; if not, write to the Free Software Foundation,
;  Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
;
;======================= END GPL LICENSE BLOCK ========================

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mouse Axis Lock
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Author: Jeff Boller
; Wiki URL: https://github.com/sundriftproductions/blenderaddons-mouse-axis-lock/wiki
; Tracker URL: https://github.com/sundriftproductions/blenderaddons-mouse-axis-lock
;
; This AutoIt script locks your mouse in a vertical or horizontal direction.
; This helps keep things the mouse fairly steady when combing hair particles in Blender.
; This can also be used in any application where you need to keep the mouse moving almost exactly up/down or left/right.
; (It's not perfect -- AutoIt can't latch onto Windows perfectly, so there's a bit of mouse wiggle. That said, it's pretty good for most applications.)
; This AutoIt script is intended to be called by AutoHotKey (https://www.autohotkey.com ) or by a Blender add-on.
;
; To run this via a keyboard hotkey when using Blender, put the following code in your AutoHotKey script.
; Obviously, change the file paths to reflect the real location of this script:
;
;     #IfWinActive ahk_class GHOST_WindowClass ; Blender
;     {
;          !^u:: 				; Mouse Axis Lock - up/down
;          Run "C:\Program Files (x86)\AutoIt3\AutoIt3.exe" "C:\Programs\blender\2.93\scripts\addons\mouse_axis_lock.au3" "U"
;          return
;
;          !^l:: 				; Mouse Axis Lock - left/right
;          Run "C:\Program Files (x86)\AutoIt3\AutoIt3.exe" "C:\Programs\blender\2.93\scripts\addons\mouse_axis_lock.au3" ; If we don't send a parameter, it locks left/right
;          return
;     }
;     #IfWinActive
;

; Version History:
; 1.0.0 - 2022-08-07: First publicly-released version.

$appName = "MouseAxisLock"

; Make sure we don't launch this script twice.
If WinExists($appName) Then Exit

AutoItWinSetTitle($appName)

$Restrict = "Left/Right"; # Set this to "Up/Down" or "Left/Right".
If $CmdLine[0] = 1 Then
   If $CmdLine[1] = "U" Then ; We passed in "U" as the command line parameter.
	  $Restrict = "Up/Down"
   EndIf
EndIf

HotKeySet ( "{ESC}", "StopRestrict" )

$Height = @DesktopHeight; Sets the resolution (height) to a variable - used in the _MouseTrap loop so you don't have to hardcode the desktop resolution
$Width = @DesktopWidth; Sets the resolution (width) to a variable - used in the _MouseTrap loop so you don't have to hardcode the desktop resolution

Local $aPos = MouseGetPos()
$restrictX = $aPos[0]
$restrictY = $aPos[1]
$tooltipY = 0
If $restrictY < 0 Then $tooltipY = -$Height
ToolTip("Locked " & $Restrict & @CRLF & "(Press ESC to unlock.)", 0, $tooltipY, "Mouse Axis Lock", 1)

While 1
    Sleep ( 100 )
    If $Restrict = "Up/Down" Then
        CustomMouseTrap ( $restrictX, -$Height, $restrictX, $Height) ; Works for dual monitors arranged up and down of the same resolution.
    ElseIf $Restrict = "Left/Right" Then
        CustomMouseTrap (-$Width, $restrictY, $Width, $restrictY) ; Should work for dual monitors with the same resolution arranged side by side but not tested.
    EndIf
WEnd

Func StopRestrict()
   If $Restrict = "Up/Down" Or $Restrict = "Left/Right" Then
	  Global $Restrict = ""
	  CustomMouseTrap()
	  Exit
   EndIf
EndFunc

 Func CustomMouseTrap($i_left=0, $i_top=0, $i_right=0, $i_bottom = 0)
     Local $av_ret
    If @NumParams == 0 Then
        $av_ret = DllCall("user32.dll", "int", "ClipCursor", "int", 0)
    Else
        If @NumParams == 2 Then
            $i_right = $i_left + 1
            $i_bottom = $i_top + 1
        EndIf
        Local $Rect = DllStructCreate("int;int;int;int")
        If @error Then Return 0
        DllStructSetData($Rect, 1, $i_left)
        DllStructSetData($Rect, 2, $i_top)
        DllStructSetData($Rect, 3, $i_right)
        DllStructSetData($Rect, 4, $i_bottom)
        $av_ret = DllCall("user32.dll", "int", "ClipCursor", "ptr", DllStructGetPtr($Rect))
        ;       DllStructDelete($Rect)
    EndIf
    Return $av_ret[0]
 EndFunc
