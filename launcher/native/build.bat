@echo off
REM CF7:ME miniaudio native DLL build script
REM Output: launcher\bin\Release\miniaudio.dll

setlocal

REM Auto-detect MSVC environment
if not defined VCINSTALLDIR (
    set "VCVARS_BAT="
    for %%v in (
        "C:\Program Files\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
        "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
        "C:\Program Files\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat"
        "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
        "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
        "C:\Program Files (x86)\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"
        "C:\Program Files (x86)\Microsoft Visual Studio\2022\Professional\VC\Auxiliary\Build\vcvars64.bat"
        "C:\Program Files (x86)\Microsoft Visual Studio\2022\Enterprise\VC\Auxiliary\Build\vcvars64.bat"
        "C:\Program Files (x86)\Microsoft Visual Studio\2019\BuildTools\VC\Auxiliary\Build\vcvars64.bat"
    ) do (
        if exist %%v (
            echo [INFO] Found MSVC: %%v
            call %%v
            goto :build
        )
    )
    if exist "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" (
        for /f "usebackq delims=" %%i in (`"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do (
            if exist "%%~i\VC\Auxiliary\Build\vcvars64.bat" (
                set "VCVARS_BAT=%%~i\VC\Auxiliary\Build\vcvars64.bat"
            )
        )
    )
    if defined VCVARS_BAT (
        echo [INFO] Found MSVC via vswhere: %VCVARS_BAT%
        call "%VCVARS_BAT%"
        goto :build
    )
    echo [FAIL] MSVC not found. Install Visual Studio Build Tools 2022.
    exit /b 1
)

:build
where cl >nul 2>&1
if errorlevel 1 (
    echo [FAIL] cl.exe not found in PATH after MSVC setup.
    exit /b 1
)

echo [INFO] Compiling miniaudio_bridge.c ...

REM Output to launcher\bin\Release (relative to this script's directory)
set "OUTDIR=%~dp0..\bin\Release"
if not exist "%OUTDIR%" mkdir "%OUTDIR%"

cl /O2 /LD /W3 /D_CRT_SECURE_NO_WARNINGS "%~dp0miniaudio_bridge.c" /Fe:"%OUTDIR%\miniaudio.dll" /link ole32.lib

if errorlevel 1 (
    echo [FAIL] Compilation failed.
    exit /b 1
)

echo [OK] miniaudio.dll built successfully.
endlocal
