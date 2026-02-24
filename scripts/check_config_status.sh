#!/data/data/com.termux/files/usr/bin/bash
/data/data/com.termux/files/usr/bin/proot-distro login debian -- openclaw doctor > /sdcard/claw_doctor.txt 2>&1
chmod 600 /sdcard/claw_doctor.txt
