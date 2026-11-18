{ ... }:

# Blockstream Jade over USB.
#
# Unlike a Trezor, Jade is not a HID device: it enumerates as a USB serial
# port (`/dev/ttyACM*` on Jade Plus/Core, `/dev/ttyUSB*` on Jade 1.0/1.1).
# Without udev rules that node is root-only, and every companion app reports
# "no hardware device detected".  The rules below are HWI's
# `hwilib/udev/55-usb-jade.rules` and cover all Jade revisions:
#
#   10c4:ea60  CP210x bridge  (early / DIY units)
#   1a86:55d4  CH340 bridge   (Jade 1.0 / 1.1)
#   303a:4001  ESP32-S3 USB   (Jade Plus / Core)
#
# `plugdev` and `dialout` are already declared in
# modules/system/shared/configuration.nix, and alice is a member of both.
{
  services.udev.extraRules = ''
    # Blockstream Jade: read/write tty node for plugdev, plus jade0/jade1/...
    # symlinks so a tool can be pointed at one specific unit.
    KERNEL=="ttyUSB*", SUBSYSTEMS=="usb", ATTRS{idVendor}=="10c4", ATTRS{idProduct}=="ea60", MODE="0660", GROUP="plugdev", TAG+="uaccess", SYMLINK+="jade%n"
    KERNEL=="ttyACM*", SUBSYSTEMS=="usb", ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="55d4", MODE="0660", GROUP="plugdev", TAG+="uaccess", SYMLINK+="jade%n"
    KERNEL=="ttyACM*", SUBSYSTEMS=="usb", ATTRS{idVendor}=="303a", ATTRS{idProduct}=="4001", MODE="0660", GROUP="plugdev", TAG+="uaccess", SYMLINK+="jade%n"

    # Jade disappears from /dev after a few idle seconds when the kernel
    # autosuspends it (the documented "Jade disconnected" bug on Linux).
    # Keep power/control at "on" for all three USB identities.
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="10c4", ATTR{idProduct}=="ea60", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="1a86", ATTR{idProduct}=="55d4", TEST=="power/control", ATTR{power/control}="on"
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="303a", ATTR{idProduct}=="4001", TEST=="power/control", ATTR{power/control}="on"
  '';
}
