# Mes --- Maxwell Equations of Software
# Copyright © 2017 Jan Nieuwenhuizen <janneke@gnu.org>
#
# This file is part of Mes.
#
# Mes is free software; you can redistribute it and/or modify it
# under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or (at
# your option) any later version.
#
# Mes is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Mes.  If not, see <http://www.gnu.org/licenses/>.

set -ex

# hex2-0
../mes/guile/mescc.scm -c -E -I ../mes/include -o hex2.E ../mescc-tools/hex2_linker.c
../mes/guile/mescc.scm -c -o hex2.M1 hex2.E
../mescc-tools/bin/M1\
    --LittleEndian\
    --Architecture=1\
    -f ../mes/stage0/x86.M1\
    -f ../mes/lib/libc-mes+tcc.M1\
    -f hex2.M1\
    -o hex2.hex2
../mescc-tools/bin/hex2\
    --LittleEndian\
    --Architecture=1\
    --BaseAddress=0x1000000\
    -f ../mes/stage0/elf32-header.hex2\
    -f ../mes/lib/crt1.hex2\
    -f ../mes/lib/libc-mes+tcc.hex2\
    -f hex2.hex2\
    -f ../mes/stage0/elf32-footer-single-main.hex2\
    --exec_enable\
    -o hex2-0
rm hex2.E

# hex2
./hex2-0\
   \
    --LittleEndian\
    --Architecture=1\
    --BaseAddress=0x1000000\
    -f ../mes/stage0/elf32-header.hex2\
    -f ../mes/lib/crt1.hex2\
    -f ../mes/lib/libc-mes+tcc.hex2\
    -f hex2.hex2\
    -f ../mes/stage0/elf32-footer-single-main.hex2\
    --exec_enable\
    -o hex2-1
mv hex2-1 hex2
cmp hex2-0 hex2 || diff -y hex2-0 hex2
rm hex2-0
rm hex2.hex2

# M1-0
../mes/guile/mescc.scm -c -E -I ../mes/include -o M1.E ../mescc-tools/M1-macro.c
../mes/guile/mescc.scm -c -o M1.M1 M1.E
../mescc-tools/bin/M1\
    --LittleEndian\
    --Architecture=1\
    -f ../mes/stage0/x86.M1\
    -f M1.M1\
    -o M1.hex2
./hex2\
    --LittleEndian\
    --Architecture=1\
    --BaseAddress=0x1000000\
    -f ../mes/stage0/elf32-header.hex2\
    -f ../mes/lib/crt1.hex2\
    -f ../mes/lib/libc-mes+tcc.hex2\
    -f M1.hex2\
    -f ../mes/stage0/elf32-footer-single-main.hex2\
    --exec_enable\
    -o M1-0
rm M1.E

# M1
mv M1.hex2 M1.hex2-0
./M1-0\
    --LittleEndian\
    --Architecture=1\
    -f ../mes/stage0/x86.M1\
    -f M1.M1\
    -o M1.hex2
cmp M1.hex2-0 M1.hex2 || { diff -y M1.hex2-0 M1.hex2 | head -1000; }
./hex2\
    --LittleEndian\
    --Architecture=1\
    --BaseAddress=0x1000000\
    -f ../mes/stage0/elf32-header.hex2\
    -f ../mes/lib/crt1.hex2\
    -f ../mes/lib/libc-mes+tcc.hex2\
    -f M1.hex2\
    -f ../mes/stage0/elf32-footer-single-main.hex2\
    --exec_enable\
    -o M1-1

rm M1.hex2
cmp M1-0 M1-1 || { diff -y M1-0 M1-1; }
mv M1-1 M1
rm M1-0
rm M1.hex2-0

# blood-elf
../mes/guile/mescc.scm -c -E -I ../mes/include -o blood-elf.E ../mescc-tools/blood-elf.c
../mes/guile/mescc.scm -c -o blood-elf.M1 blood-elf.E
./M1\
    --LittleEndian\
    --Architecture=1\
    -f ../mes/stage0/x86.M1\
    -f blood-elf.M1\
    -o blood-elf.hex2
./hex2\
    --LittleEndian\
    --Architecture=1\
    --BaseAddress=0x1000000\
    -f ../mes/stage0/elf32-header.hex2\
    -f ../mes/lib/crt1.hex2\
    -f ../mes/lib/libc-mes+tcc.hex2\
    -f blood-elf.hex2\
    -f ../mes/stage0/elf32-footer-single-main.hex2\
    --exec_enable\
    -o blood-elf
rm blood-elf.E
rm blood-elf.hex2
