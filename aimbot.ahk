    ; Initialize script
    init:
    ; NoEnv
    ; SingleInstance, Force
    ; Persistent
    ; SendMode Input
    ; InstallKeybdHook
    ; UseHook
    ; KeyHistory, 0
    ; HotKeyInterval 1
    ; MaxHotkeysPerInterval 127
     
    version = 1.0
    authors = HoIIy
    traytip, Sharpshooter %version%, Running in background!, 5, 1
    Menu, tray, NoStandard
    Menu, tray, Tip, Sharpshooter %version% - Made by %authors% - Searching for red
    Menu, tray, Add, Sharpshooter %version%, return
    Menu, tray, Add
    Menu, tray, Add, Help, info
    Menu, tray, Add, Exit, exit
    SetKeyDelay,-1, 1
    SetControlDelay, -1
    SetMouseDelay, -1
    SetWinDelay,-1
    SendMode, InputThenPlay
    SetBatchLines,-1
    ListLines, Off
    CoordMode, Pixel, Screen, RGB
    CoordMode, Mouse, Screen
    PID := DllCall("GetCurrentProcessId")
    Process, Priority, %PID%, High
     
    ; Initial color settings (simplified to one color for testing)
    EMCol := 0xFF0000 ; Initial color (red)
    ColVn := 75
    AntiShakeX := (A_ScreenHeight // 960)
    AntiShakeY := (A_ScreenHeight // 540)
    ZeroX := (A_ScreenWidth // 2)
    ZeroY := (A_ScreenHeight // 2)
    CFovX := (A_ScreenWidth // 25)
    CFovY := (A_ScreenHeight // 25)
    ScanL := ZeroX - CFovX
    ScanT := ZeroY
    ScanR := ZeroX + CFovX
    ScanB := ZeroY + CFovY
    NearAimScanL := ZeroX - AntiShakeX
    NearAimScanT := ZeroY - AntiShakeY
    NearAimScanR := ZeroX + AntiShakeX
    NearAimScanB := ZeroY + AntiShakeY
     
    ; Simplified Kalman filter variables
    KalmanX := 0.1
    KalmanY := 0.1
    KalmanP := 0.0
    KalmanQ := 0.10
    KalmanR := 0.010
    KalmanVx := 0.1
    KalmanVy := 0.1
     
    ; Define initial aiming position
    PrevAimX := 2
    PrevAimY := 2
     
    ; Define the maximum movement distance
    MaxMoveDist := 0.1
     
    Loop
    {
        if (GetKeyState("MButton", "P") or GetKeyState("RButton", "P"))
        {
            PixelSearch, AimPixelX, AimPixelY, NearAimScanL, NearAimScanT, NearAimScanR, NearAimScanB, EMCol, ColVn, Fast RGB
            if (ErrorLevel = 0) ; Proceed only if the PixelSearch is successful
            {
                AimX := AimPixelX - ZeroX
                AimY := AimPixelY - ZeroY
     
                ; Simplified mouse movement
                MoveX := Floor(Sqrt(Abs(AimX))) * (AimX >= 0 ? 1 : -1)
                MoveY := Floor(Sqrt(Abs(AimY))) * (AimY >= 0 ? 1 : -1)
     
                ; Apply Kalman filter
                KalmanX := KalmanX + KalmanVx
                KalmanY := KalmanY + KalmanVy
                KalmanP := KalmanP + KalmanQ
     
                K := KalmanP / (KalmanP + KalmanR)
                KalmanX := KalmanX + K * (MoveX - KalmanX)
                KalmanY := KalmanY + K * (MoveY - KalmanY)
                KalmanVx := KalmanVx + K * (MoveX - KalmanX)
                KalmanVy := KalmanVy + K * (MoveY - KalmanY)
                KalmanP := (1 - K) * KalmanP
     
                ; Exponential Moving Average (EMA) smoothing
                Alpha := 0.5
                SmoothedX := (1 - Alpha) * KalmanX + Alpha * MoveX
                SmoothedY := (1 - Alpha) * KalmanY + Alpha * MoveY
     
                ; Adjusted scaling factor
                DllCall("mouse_event", uint, 1, int, SmoothedX * 1.0, int, SmoothedY * 1.0, uint, 0, int, 1)
     
                PrevAimX := AimX
                PrevAimY := AimY
            }
        }
    }
     
    return:
    goto, init
     
    f2::
    Pause
    Suspend
    return
     
    info:
    msgbox, 0, Sharpshooter %version%,
    return
     
    exit:
    exitapp