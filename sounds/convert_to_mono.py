import os
import subprocess
import argparse
from pathlib import Path

# thx to chatgpt my bro

def is_excluded(path, exclude_list):
    """Check if a path should be excluded based on folder/file names."""
    for pattern in exclude_list:
        if pattern in str(path):
            return True
    return False

def convert_to_mono(root_dir, exclude_list):
    root_dir = Path(root_dir)
    for ogg_path in root_dir.rglob("*.ogg"):
        if is_excluded(ogg_path, exclude_list):
            print(f"Skipping (excluded): {ogg_path}")
            continue

        tmp_path = ogg_path.with_suffix(".tmp.ogg")

        cmd = [
            "ffmpeg",
            "-v", "error",
            "-i", str(ogg_path),
            "-ac", "1",  # force mono
            "-y", str(tmp_path)
        ]

        print(f"Converting: {ogg_path}")
        result = subprocess.run(cmd)

        if result.returncode == 0:
            tmp_path.replace(ogg_path)
        else:
            print(f"❌ Failed to convert: {ogg_path}")
            if tmp_path.exists():
                tmp_path.unlink()

if __name__ == "__main__":
    # parser = argparse.ArgumentParser(description="Recursively convert .ogg files to mono using FFmpeg.")
    # parser.add_argument("folder", help="Root folder to start from.")
    # parser.add_argument(
    #     "--exclude",
    #     nargs="*",
    #     default=[],
    #     help="List of folder or file name patterns to exclude (e.g. 'music' 'ambience' 'test.ogg')."
    # )
    # args = parser.parse_args()
    #
    # convert_to_mono(args.folder, args.exclude)

    exclude = [
        "music",
        "ui",
        "sfx/actor/player/sfx_player_death.ogg"
        "sfx/actor/player/sfx_player_leave_game.ogg"
        "sfx/actor/player/sfx_player_leave_game_easter_egg.ogg"
        "sfx/actor/cocoon/sfx_actor_cocoon_break_01.ogg", 
        "sfx/actor/cocoon/sfx_actor_cocoon_break_02.ogg",
        "sfx/ambience",
        "sfx/enemy/mrdung/activate/sfx_boss_mrdung_boss_activate_01.ogg",
        "sfx/enemy/mrdung/activate/sfx_boss_mrdung_boss_activate_02.ogg",
        "sfx/enemy/mrdung/activate/sfx_boss_mrdung_boss_activate_03.ogg",
        "sfx/enemy/mrdung/activate/sfx_boss_mrdung_boss_activate_04.ogg",
        "sfx/enemy/mrdung/activate/sfx_boss_mrdung_boss_activate_05.ogg",
        "sfx/enemy/mrdung/activate/sfx_boss_mrdung_boss_activate_06.ogg",
        "sfx/enemy/mrdung/activate/sfx_boss_mrdung_boss_activate_07.ogg",
        "sfx/enemy/mrdung/activate/sfx_boss_mrdung_boss_activate_08.ogg",
        "sfx/enemy/mrdung/death/sfx_boss_mrdung_death_01.ogg",
        "sfx/enemy/mrdung/death/sfx_boss_mrdung_death_02.ogg",
        "sfx/enemy/mrdung/death/sfx_boss_mrdung_death_03.ogg",
        "sfx/enemy/mrdung/sfx_boss_intro_mrdung.ogg",
        "sfx/upgrades",
    ]
    convert_to_mono(".", exclude)