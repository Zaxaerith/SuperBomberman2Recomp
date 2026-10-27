def generate_password_script(password: str, output_path: str, post_wait_frames: int = 240, extra_dumps=None):
    digits = [int(c) for c in password]
    lines = [
        f"# Super Bomberman 2 - Password Entry: {password}",
        "wait 120",
        "press start 5",
        "wait 100",
        "press start 5",
        "wait 100",
        "press start 5",
        "wait 150",
        "wait 140",
        "# Move down to PASSWORD",
        "press down 5",
        "wait 30",
        "press down 5",
        "wait 30",
        "press start 5",
        "wait 180",
        "# At password screen",
    ]
    
    for i, d in enumerate(digits):
        if d <= 5:
            for _ in range(d):
                lines.append("press up 5")
                lines.append("wait 15")
        else:
            for _ in range(10 - d):
                lines.append("press down 5")
                lines.append("wait 15")
        if i < 3:
            lines.append("press right 5")
            lines.append("wait 20")
            
    lines.append("wait 30")
    lines.append("dump 01_pw_entered")
    lines.append("press start 5")
    lines.append(f"wait {post_wait_frames}")
    if extra_dumps:
        for name, wait_after in extra_dumps:
            lines.append(f"dump {name}")
            if wait_after > 0:
                lines.append(f"wait {wait_after}")
    else:
        lines.append("dump 02_world_loaded")
    lines.append("quit\n")
    
    with open(output_path, "w") as f:
        f.write("\n".join(lines))
    print(f"Generated {output_path} for password {password}")

if __name__ == "__main__":
    import sys
    pw = sys.argv[1] if len(sys.argv) > 1 else "5462"
    out = sys.argv[2] if len(sys.argv) > 2 else "tests/test_world2.script"
    extra = [("world_start_banner", 120), ("world_gameplay_map", 0)]
    generate_password_script(pw, out, post_wait_frames=240, extra_dumps=extra)
