# SPDX-License-Identifier: CC0-1.0
# SPDX-FileCopyrightText: 2024–2025 Jason Yundt <jason@jasonyundt.email>
/**
  Print all boot messages to a serial console and start getty on that
  serial console.

  This module is mainly useful for virtual machines. Serial terminals
  allow you to easily copy and paste text between the host and the guest
  system even before the guest system has loaded any kind of graphical
  user interface.
*/
{
  boot.kernelParams = [ "console=ttyS0" ];
}
