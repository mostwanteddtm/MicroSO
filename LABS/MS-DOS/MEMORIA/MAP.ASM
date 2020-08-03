Added Files:
      Tag: UNSTABLE
	oemboot.asm 
Log Message:
pc/ms DOS compatible boot sector

--- NEW FILE: oemboot.asm ---
;
; File:
;                          oemboot.asm
;                      2004, Kenneth J. Davis
;                Copyright (c) 200?, <add name here>
; Description:
; OEM boot sector for FreeDOS compatible with IBM's (R) PC-DOS,
; and Microsoft's (R) PC-DOS.  It may work with OpenDOS/DR-DOS,
; although the standard FreeDOS boot sector works with later
; releases.  May work with other versions of DOS that use
; IBMBIO.COM/IBMDOS.COM pair.  This boot sector loads only up
; to 58 sectors (29KB) of the kernel (IBMBIO.COM) to 0x70:0 then
; jumps to it.  As best I can tell, PC-DOS (and assuming MS-DOS
; behaves similar) expects on entry for:
; ch = media id byte in the boot sector
; dl = BIOS drive booted from (0x00=A:, 0x80=C:, ...)
; ax:bx = the LBA sector of 1st data sector 0x0000:0021 for FAT12
; ?or? 1st sector of IBMBIO.COM (which is normally 1st data sector)
; it also expects the boot sector (in particular the BPB)
; to still be at 0x0:7C00, the directory entry for IBMBIO.COM
; (generally first entry of first sector of the root directory)
; at 0x50:0 (DOS Data Area).  The original boot sector may update
; the floppy disk parameter table (int 1Eh), but we don't so
; may fail for any systems where the changes (???) are needed.
; If the above conditions are not met, then IBMBIO.COM will
; print the not a bootable disk error message.
;
; This boot sector only supports FAT12/FAT16 as PC-DOS
; does not support FAT32 and newer FAT32 capable DOSes
; probably have different boot requirements; also do NOT
; use it to boot the FreeDOS kernel as it expects to be
; fully loaded by boot sector (> 29KB & usually to 0x60:0).
;
; WARNING: PC-DOS has additional requirements, in particular,
; it may expect that IBMBIO.COM and IBMDOS.COM be the 1st
; two entries in the root directory (even before the label)
; and that they occupy the 1st consecutive data sectors.
; Newer releases may support other positions, but still
; generally should occupy consecutive sectors. These conditions
; can usually be met by running sys on a freshly formatted
; and un-label'd disk.
;
;
; Derived From:
;                            boot.asm
;                           DOS-C boot
;
;                   Copyright (c) 1997, 2000-2004
;               Svante Frey, Jim Hall, Jim Tabor, Bart Oldeman,
;             Tom Ehlert, Eric Auer, Luchezar Georgiev, Jon Gentle
;             and Michal H. Tyc (DR-DOS adaptation, boot26dr.asm)
;                      All Rights Reserved
;
; This file is part of FreeDOS.
;
; DOS-C is free software; you can redistribute it and/or
; modify it under the terms of the GNU General Public License
; as published by the Free Software Foundation; either version
; 2, or (at your option) any later version.
;
; DOS-C is distributed in the hope that it will be useful, but
; WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
; the GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public
; License along with DOS-C; see the file COPYING.  If not,
; write to the Free Software Foundation, 675 Mass Ave,
; Cambridge, MA 02139, USA.
;
;
;	+--------+
;	| CLUSTER|
;	|  LIST  |
;	|--------| 0000:7F00
;   |LBA PKT |
;	|--------| 0000:7E00  (0:BP+200)
;	|BOOT SEC| contains BPB
;	|ORIGIN  | 
;	|--------| 0000:7C00  (0:BP)
;	|STACK   | minimal 256 bytes (1/2 sector)
;	|- - - - |
;	|KERNEL  | kernel loaded here (max 58 sectors, 29KB)
;	|LOADED  | also used as FAT buffer
;	|--------| 0070:0000 (0:0700)
;	|DOS DA/ | DOS Data Area,
;	|ROOT DIR| during boot the 1st sector of root directory
;	|--------| 0000:0500
;	|BDA     | BIOS Data Area
;	+--------+ 0000:0400
;	|IVT     | Interrupt Vector Table
;	+--------+ 0000:0000