return {
  
    -- basic settings:
    name = 'bugscraper', -- name of the game for your executable
    developer = 'Yolwoocle', -- dev name used in metadata of the file
    output = '_export', -- output location for your game, defaults to $SAVE_DIRECTORY
    version = '0.6.dev25-02-24', -- 'version' of your game, used to name the folder in output
    love = '12.0', -- version of LÖVE to use, must match github releases
    ignore = {
        ".git",
        ".vscode",
        "_export",
        "_dyn",
        "_tools",
        "_readme",
        -- ".aseprite",
        -- ".lnk",

        "luasteam.dll",
        "steam_api64.dll",
    }, -- folders/files to ignore in your project
    icon = 'icon.png', -- 256x256px PNG icon for game, will be converted for you
    
    -- optional settings:
    use32bit = false, -- set true to build windows 32-bit as well as 64-bit
    identifier = 'com.yolwoocle.bugscraper', -- macos team identifier, defaults to game.developer.name
    libs = { -- files to place in output directly rather than fuse
        windows = {
            "steam_appid.txt",
            "luasteam.dll",
            "steam_api64.dll",
        }, -- can specify per platform or "all"
        all = {
            'resources/license.txt'
        }
    },
    -- hooks = { -- hooks to run commands via os.execute before or after building
    -- },
    platforms = {'windows', 'macos', 'linux'} -- set if you only want to build for a specific platform
    
}