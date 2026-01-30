export const device = #{
    linux: SYSTEM.platform == "Linux",
    windows: SYSTEM.platform == "Windows",
    macos: SYSTEM.platform == "Darwin",
};

// Handle directories
fn dir_exists(p) {
    io::path_exists(p) && io::path_is_dir(p)
}

// Constants
let LOCAL_APPDATA = io::env("LOCALAPPDATA", "");
// let PS_HOME = io::env("PSHOME", ""); // this dir does not exist
let ROAMING_APPDATA = io::env("APPDATA", "");
let USER_PROFILE = io::env("USERPROFILE", "");

export const eggs = #{
    assets: #{
        targets: if device.linux {
            "~/.config/share/"
        } else if device.windows {
            LOCAL_APPDATA + "\\share"
        } else {
            ""
        },
        templates: [], // raw files copied as-is (no templating)
        enabled: true,
    },
    browser: #{
        // targets: "",
        templates: ["bookmarks.html"],
        enabled: false
    },
    nvim: #{
        targets: if device.linux {
            "~\\.config\\nvim"
        } else if device.windows {
            LOCAL_APPDATA + "\\nvim"
        } else {
            ""
        },
        templates: ["*.lua"],
        enabled: (device.linux || device.windows),
    },
    fastfetch: #{
        targets: if device.linux {
            "~\\.config\\fastfetch"
        } else if device.macos {
            io::env("USERPROFILE", "") + "\\.config\\fastfetch"
        } else {
            ""
        },
        templates: [],
        enabled: (device.linux || device.windows),
    },
    powershell: #{
        targets: if device.linux {
            "~\\.config\\powershell"
        } else if device.windows {
            if dir_exists(USER_PROFILE + "\\Documents\\PowerShell") {
                USER_PROFILE + "\\Documents\\PowerShell"
            } else if dir_exists(USER_PROFILE + "\\Documents\\PowerShell") {
                "C:\\Windows\\System32\\WindowsPowerShell\\v1.0"
            }
        } else {
            ""
        },
        templates: ["profile.ps1"], // ["profile.ps1", "profile.psm1"],
        enabled: device.windows,
    },
    terminal: #{
        targets: if device.windows {
            LOCAL_APPDATA + "\\Packages\\Microsoft.WindowsTerminal_8wekyb3d8bbwe\\LocalState"
        } else {
            ""
        },
        templates: ["settings.json"],
        enabled: device.windows,
    },
};
