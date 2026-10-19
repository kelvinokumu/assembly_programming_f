# Division Findings

**DIV leaves all six arithmetic flags undefined.** `U` means no guaranteed
value, not necessarily cleared or unchanged. Results below are immediately
after division.

| File | Calculation | Quotient | Remainder | CF | PF | AF | ZF | SF | OF |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| [div1.asm](div1.asm) | `100 / 7` | `AL = 14` (`0x0E`) | `AH = 2` (`0x02`) | U | U | U | U | U | U |
| [div2.asm](div2.asm) | `50000 / 300` | `AX = 166` (`0x00A6`) | `DX = 200` (`0x00C8`) | U | U | U | U | U | U |
| [div3.asm](div3.asm) | `300000000 / 1000` | `EAX = 300000` (`0x000493E0`) | `EDX = 0` | U | U | U | U | U | U |

## Why

- **[div1.asm](div1.asm):** `100 = 7 * 14 + 2`, giving quotient 14 and
	remainder 2. Together `AH:AL = 0x020E`; the quotient alone is in `AL`.
- **[div2.asm](div2.asm):** The dividend is `DX:AX`, with `DX = 0`.
	`50000 = 300 * 166 + 200`, giving quotient 166 and remainder 200.
- **[div3.asm](div3.asm):** The dividend is `EDX:EAX`, with `EDX = 0`.
	`300000000 = 1000 * 300000`. The remainder is zero, but **ZF is undefined**.

Division by zero or a quotient too large for its register raises **#DE**
(divide error), rather than setting CF or OF. None of these examples faults.

**Inspect before the exit code.** `mov eax, 1` overwrites the quotient.
Then `xor ebx, ebx` produces `CF=0, PF=1, ZF=1, SF=0, OF=0`; AF is undefined.

Instruction reference: [DIV](https://www.felixcloutier.com/x86/div).