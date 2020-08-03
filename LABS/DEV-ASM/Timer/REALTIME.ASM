; =============================================================================
;
;                               Litos - Time
;
; =============================================================================
; PC Real-time clock - interrupted every 1 ms:
;	Hardware clock generator: 1193182 Hz
; 	Timer divisor: 1193
;       Interrupt frequency: 1000.1525566 Hz (0.9998474667 ms)
;	Increment in 100-nanosecs: 9998.474666899
;	Low DWORD increment (decimal part): 2038678808 (7983C518h)
;	High DWORD increment: 9998
;	Clock ticks per day: 86413180.89
; =============================================================================
; TODO: Synchronize time-stamp counter on all CPUs (or use add-on correction)
; TODO: Adjust time precission correcting time delta in run-time.
; TODO: Synchronize CMOS access with NMI interrupt (it cannot be disabled).

; ------------- Clock constants

TIME_DIVISOR	EQU	1193		; real-time clock divisor (1000.153 Hz)
TIME_DELTA_DEC	EQU	2038678808	; time delta in 100-ns, decimal part
TIME_DELTA_INT	EQU	9998		; time delta in 100-ns, integer part
TIME_1MS	EQU	10000		; time 1 ms in 100-ns
TIME_1MS_REAL	EQU	9998		; real precision of time 1 ms in 100-ns

		CODE_SECTION	32

; ------------- Macro - read byte from CMOS (INPUT: %1=index, OUTPUT: AL=value)
; (It takes very roughly 5 microseconds)

%macro		GET_CMOS 1
		mov	al,%1+B7	; AL <- index of the byte+NMI disabled
		call	GetCMOS		; read byte from CMOS
%endmacro

; ------------- Macro - write byte into CMOS (INPUT: %1=index, %2=value)
; (It takes very roughly 5 microseconds)

%macro		SET_CMOS 2
		mov	al,%1+B7	; AL <- index of the byte+NMI disabled
		out	70h,al		; set index of the byte
		SHORT_DELAY		; short delay
		mov	al,%2		; byte to write into CMOS
		out	71h,al		; write byte into CMOS
%endmacro

; ------------- Macro - pack binary byte (in AL) to BCD (destroys AH)

%macro		BINBCD	0
		aam	10		; unpack digits modulo 10
		aad	16		; pack digits modulo 16
%endmacro

; ------------- Macro - unpack BCD byte (in AL) to binary (destroys AH)

%macro		BCDBIN	0
		aam	16		; unpack digits modulo 16
		aad	10		; pack digits modulo 10
%endmacro

; -----------------------------------------------------------------------------
;                          Lock/unlock current time
; -----------------------------------------------------------------------------
; NOTES:	Use macro TIMELOCK to lock, TIMEUNLOCK to unlock.
; -----------------------------------------------------------------------------

; ------------- Time lock function

%ifdef	SMP
		LOCK_LockFnc CurTimeLock,CurrentTimeLock ; declare time lock
%endif

; ------------- Macro - call time lock function

%macro		TIMELOCK 0
%ifdef	SMP
		call	CurTimeLock	; call time lock function
%endif
%endmacro

; ------------- Macro - time unlock

%macro		TIMEUNLOCK 0
%ifdef	SMP
		LOCK_Unlock CurrentTimeLock ; unlock current time
%endif
%endmacro

; -----------------------------------------------------------------------------
;                          Lock/unlock CMOS time
; -----------------------------------------------------------------------------
; NOTES:	Use macro CMOSLOCK to lock, CMOSUNLOCK to unlock.
; -----------------------------------------------------------------------------

; ------------- CMOS lock function

%ifdef	SMP
		LOCK_LockFnc CMOSLock,CMOSTimeLock ; declare CMOS lock function
%endif

; ------------- Macro - call CMOS lock function

%macro		CMOSLOCK 0
%ifdef	SMP
		call	CMOSLock	; call CMOS lock function
%endif
%endmacro

; ------------- Macro - CMOS unlock

%macro		CMOSUNLOCK 0
%ifdef	SMP
		LOCK_Unlock CMOSTimeLock ; unlock CMOS time
%endif
%endmacro

; -----------------------------------------------------------------------------
;                          Short delay
; -----------------------------------------------------------------------------
; INPUT:	EAX = wait time in microseconds (roughly)
; -----------------------------------------------------------------------------

; ------------- Push registers

UDelay:		push	eax		; push EAX
		push	ecx		; push ECX		

; ------------- Recalc to number of loops (i.e. N/1.5 =~ N*0.625)

		mov	ecx,eax		; ECX <- required time
		shr	eax,2		; EAX <- time / 4
		sub	ecx,eax		; N - N/4
		shr	eax,1		; ECX <- time / 8
		sub	ecx,eax		; N - N/4 - N/8

; ------------- Wait for a givven time

		jecxz	UDelay8		; no time
UDelay2:	SHORT_DELAY		; short delay (1.5 us aprox.)
		loop	UDelay2		; next loop

; ------------- Pop registers

UDelay8:	pop	ecx		; pop ECX
		pop	eax		; pop EAX
		ret

; -----------------------------------------------------------------------------
;                          Short delay (byte)
; -----------------------------------------------------------------------------
; INPUT:	AL = wait time in microseconds (roughly)
; -----------------------------------------------------------------------------

UDelayByte:	push	eax		; push EAX
		movzx	eax,al		; EAX <- required wait time
		call	UDelay		; short delay
		pop	eax		; pop EAX
		ret

; -----------------------------------------------------------------------------
;                        Read byte from CMOS
; -----------------------------------------------------------------------------
; INPUT:	AL = index of the byte (B7 = disable NMI)
; OUTPUT:	AL = byte read from the CMOS
; -----------------------------------------------------------------------------

GetCMOS:	out	70h,al		; set index of the byte
		SHORT_DELAY		; short delay
		in	al,71h		; read byte from the CMOS
		ret

; -----------------------------------------------------------------------------
;                              Disable NMI
; -----------------------------------------------------------------------------
; LOCKS:	CMOSTimeLock
; -----------------------------------------------------------------------------

; ------------- Quick check if NMI is already disabled

NMIDisable:	test	byte [CMOSNMIFlag],B7 ; is NMI already disabled?
		jnz	NMIDisable2	; NMI is already disabled

; ------------- Push registers

		push	eax		; push EAX
		pushf			; push flags
		cli			; disable interrupts

; ------------- Lock CMOS time

		CMOSLOCK		; lock CMOS time

; ------------- Disable NMI (using register 13, which is read/only)
; Store variable before setting port to avoid reenabling with comming NMI.

		mov	al,B7+13	; NMI disabled + register 13
		mov	[CMOSNMIFlag],al; store new state of NMI
		out	70h,al		; disable NMI

; ------------- Unlock CMOS time

		CMOSUNLOCK		; unlock CMOS time

; ------------- Pop registers

		popf			; pop flags (and enable interrupts)
		pop	eax		; pop EAX
NMIDisable2:	ret

; -----------------------------------------------------------------------------
;                                Enable NMI
; -----------------------------------------------------------------------------
; LOCKS:	CMOSTimeLock
; -----------------------------------------------------------------------------

; ------------- Quick check if NMI is already enabled

NMIEnable:	test	byte [CMOSNMIFlag],B7 ; is NMI already enabled?
		jz	NMIEnable2	; NMI is already enabled

; ------------- Push registers

		push	eax		; push EAX
		pushf			; push flags
		cli			; disable interrupts

; ------------- Lock CMOS time

		CMOSLOCK		; lock CMOS time

; ------------- Enable NMI (using register 13, which is read/only)
; Store variable before setting port to avoid redisabling with comming NMI.

		mov	al,13		; NMI enabled + register 13
		mov	[CMOSNMIFlag],al; store new state of NMI
		out	70h,al		; enable NMI

; ------------- Unlock CMOS time

		CMOSUNLOCK		; unlock CMOS time

; ------------- Pop registers

		popf			; pop flags (and enable interrupts)
		pop	eax		; pop EAX
NMIEnable2:	ret

; -----------------------------------------------------------------------------
;                               Read CMOS time
; -----------------------------------------------------------------------------
; OUTPUT:	EDX:EAX = CMOS time in 100-nanosec Julian format
; LOCKS:	CMOSTimeLock
; NOTES:	Function takes normaly 40-60 microseconds,up to 2 milliseconds.
;		CMOS must use BCD mode, 24-hour cycle.
; -----------------------------------------------------------------------------

; ------------- Push registers

GetCMOSTime:	push	ebx		; push EBX
		push	ecx		; push ECX
		pushf			; push flags
		cli			; disable interrupts

; ------------- Lock CMOS time

		CMOSLOCK		; lock CMOS time

; ------------- Disable NMI (for several time if NMI occurs right now)

		mov	al,B7+13	; NMI disabled + register 13
		out	70h,al		; disable NMI
		out	70h,al		; disable NMI
		out	70h,al		; disable NMI

; ------------- Wait if time update cycle is in progress (with timeout 5 ms)

		mov	cl,4		; CL <- total number of attempts
GetCMOSTime2:	mov	dx,800		; DX <- number of tests
GetCMOSTime3:	GET_CMOS 10		; get status register A (5 microsec)
		test	al,B7		; is time update cycle in progress?
		jz	GetCMOSTime4	; time is not updating

; ------------- Temporary enable interrupts and unlock CMOS time

		CMOSUNLOCK		; unlock CMOS time
		popf			; enable interrupts for timer interrupt
		SHORT_DELAY		; short delay (1.5 microsec)
		pushf			; push flags
		cli			; disable interrupts again
		CMOSLOCK		; lock CMOS time
		dec	dx		; loop counter
		jnz	GetCMOSTime3	; wait for end of update cycle

; ------------- Read CMOS clock (2-times, it takes about 2*25 microseconds)

GetCMOSTime4:	mov	ebx,CMOSTimeBuff ; EBX <- CMOS time buffer
GetCMOSTime5:	xor	eax,eax		; EAX <- 0
		mov	[ebx+SYSTIME_100NSec],eax ; clear 100-nanoseconds
		GET_CMOS 4		; read hour
		shl	eax,16		; hour to 3rd byte
		GET_CMOS 2		; read minute
		mov	ah,al		; AH <- minute
		GET_CMOS 0		; read second
		xchg	eax,edx		; EDX <- second-minute-hour
		xor	eax,eax		; EAX <- 0
		GET_CMOS 9		; read year
		shl	eax,16		; year to 3rd byte
		GET_CMOS 8		; read month
		mov	ah,al		; AH <- month
		GET_CMOS 7		; read day
		cmp	edx,[ebx+SYSTIME_Sec] ; change?
		mov	[ebx+SYSTIME_Sec],edx ; store second-minute-hour-dayw
		jne	GetCMOSTime6	; change
		cmp	eax,[ebx+SYSTIME_Day] ; change?
GetCMOSTime6:	mov	[ebx+SYSTIME_Day],eax ; store day-month-year
		jne	GetCMOSTime5	; change, read again

; ------------- Check again if time update cycle is in progress

		dec	cl		; counter of total attempts
		jz	GetCMOSTime7	; no other attempt
		GET_CMOS 10		; get status register A
		test	al,B7		; is time update cycle in progress?
		jnz	GetCMOSTime2	; time is updating, repeat reading

; ------------- Convert values from BCD to binary format

GetCMOSTime7:	xor	edx,edx		; EDX <- 0
		mov	dl,SYSTIME_Year	; EDX <- offset of last entry
GetCMOSTime8:	mov	al,[ebx+edx]	; read value
		BCDBIN			; convert from BCD to binary
		mov	[ebx+edx],al	; write value
		dec	edx		; decrease offset of entry
		cmp	dl,SYSTIME_Sec	; is it first entry?
		jae	GetCMOSTime8	; convert next value

; ------------- Year correction

		movzx	eax,byte [ebx+SYSTIME_Year] ; EAX <- year
		cmp	al,80		; year 1980 or more
		jae	GetCMOSTime9	; it is year 1980 or more
		add	al,100		; century correction
GetCMOSTime9:	add	ax,1900		; add century
		mov	[ebx+SYSTIME_Year],ax ; store year

; ------------- Set default NMI

		mov	al,[CMOSNMIFlag]; AL <- old value of NMI
		out	70h,al		; enable NMI

; ------------- Convert system time to Julian time
		
		call	SystemToJulian	; convert system time to Julian

; ------------- Unlock CMOS time

		CMOSUNLOCK		; unlock CMOS time

; ------------- Pop registers

		popf			; pop flags (and enable interrupts)
		pop	ecx		; pop ECX
		pop	ebx		; pop EBX
		ret

; -----------------------------------------------------------------------------
;                        Initialize system timer
; -----------------------------------------------------------------------------
; NOTES:	This function must be called with interrupt disabled.
; -----------------------------------------------------------------------------

; ------------- Initialize system timer

TimerInit:	mov	al,B5+B4+B2	; select timer 0, LSB+MSB, mode 2
		out	43h,al		; set Timer 0 mode
		mov	al,TIME_DIVISOR & 0ffh ; AL <- time divisor LOW
		out	40h,al		; set divisor LOW
		SHORT_DELAY		; short delay
		mov	al,TIME_DIVISOR >> 8 ; AL <- time divisor HIGH
		out	40h,al		; set divisor HIGH
		ret

; -----------------------------------------------------------------------------
;                  Recalculate performance coefficients
; -----------------------------------------------------------------------------

; ------------- Prepare coefficient to recalc performance timer to nanoseconds

PerfCoefRecalc:	mov	ecx,[CPUInfo+CPU_Frequency] ; ECX <- CPU frequency
		xor	edx,edx		; EDX <- 0
		mov	eax,1000000000	; EAX <- nanoseconds per second
		div	ecx		; get integer part
		mov	[PerfCoeffNS+4],eax ; store integer part
		xor	eax,eax		; EAX <- 0
		div	ecx		; get decimal part
		mov	[PerfCoeffNS],eax ; store decimal part

; ------------- Prepare coefficient to recalc performance timer to 100-nanosecs

		xor	edx,edx		; EDX <- 0
		mov	eax,10000000	; EAX <- 100-nanoseconds per second
		div	ecx		; get integer part
		mov	[PerfCoeff100N+4],eax ; store integer part
		xor	eax,eax		; EAX <- 0
		div	ecx		; get decimal part
		mov	[PerfCoeff100N],eax ; store decimal part

; ------------- Prepare coefficient to recalc performance timer to microseconds

		mov	edx,1000000	; EDX <- microseconds per second
		xor	eax,eax		; EAX <- 0
		div	ecx		; get coefficient
		mov	[PerfCoeffUS],eax ; store coefficient

; ------------- Prepare coefficient to recalc performance timer to milliseconds

		mov	edx,1000 << 10	; EDX <- milliseconds per second * 1024
		xor	eax,eax		; EAX <- 0
		div	ecx		; get coefficient
		mov	[PerfCoeffMS],eax ; store coefficient

; ------------- Prepare coefficient to recalc performance timer to seconds

		mov	edx,1 << 20	; EDX <- 1 second * 1024 * 1024
		xor	eax,eax		; EAX <- 0
		div	ecx		; get coefficient
		mov	[PerfCoeffS],eax ; store coefficient
		ret

; -----------------------------------------------------------------------------
;                    Timer interrupt (called every 1 ms)
; -----------------------------------------------------------------------------
; LOCKS:	CurrentTimeLock
; -----------------------------------------------------------------------------

; ------------- Push registers

TimerInt:	push	eax		; push EAX
		push	ebx		; push EBX
		push	ds		; push DS
		push	es		; push ES

; ------------- Initialize registers

		mov	eax,SYSTEM_DS	; EAX <- system data segment
		mov	ds,eax		; DS <- system data segment
		mov	es,eax		; ES <- system data segment
		cld			; direction up

; ------------- Acknowledge interrupt

		IRQLOCK			; lock 8259A interrupt controller
		in	al,21h		; release interrupt controller 1
		mov	al,60h+TIMER_IRQ ; AL <- timer IRQ
		out	20h,al		; acknowledge interrupt
		IRQUNLOCK		; unlock 8259A interrupt controller

; ------------- Get current task (-> EBX)

		CURRENT	ebx		; EBX <- get current task

; ------------- Increase current time (only for CPU 0)
%ifdef	SMP
		cmp	byte [ebx+TASK_CPU],0 ; is it CPU 0 ?
		jne	TimerInt4	; it is not CPU 0
%endif
		TIMELOCK		; lock current time
		add	dword [CurrentTimeDec],TIME_DELTA_DEC
		adc	dword [CurrentTime],TIME_DELTA_INT
		adc	dword [CurrentTime+4],byte 0
		TIMEUNLOCK		; unlock current time

; ------------- Next alarm (only CPU 0)

		sub	dword [AlarmListNext],TIME_1MS_REAL ; next service
		jg	TimerInt4	; no service
		call	AlarmTime	; alarm service

; ------------- Next scheduler

TimerInt4:	mov	ebx,[ebx+TASK_RunQueue] ; EBX <- current run-queue
		add	dword [ebx+RUNQ_Elapsed],TIME_1MS_REAL ; elapsed time
		sub	dword [ebx+RUNQ_NextSched],TIME_1MS_REAL; next schedule
		jg	TimerInt9	; no next scheduling yet

; ------------- Call scheduler

		sti			; enable interrupts
		call	Schedule	; scheduler

; ------------- Pop registers

TimerInt9:	pop	es		; pop ES
		pop	ds		; pop DS
		pop	ebx		; pop EBX
		pop	eax		; pop EAX
		iret

; -----------------------------------------------------------------------------
;                     Set current time (without setting CMOS)
; -----------------------------------------------------------------------------
; INPUT:	EDX:EAX = current time in 100-nanosec from 1/1/4713 BCE 12:00
; LOCKS:	CurrentTimeLock
; -----------------------------------------------------------------------------

; ------------- Push registers

SetCurrentTime:	push	eax		; push EAX
		push	edx		; push EDX

; ------------- Disable interrupts

		pushf			; push flags
		cli			; disable interrupts

; ------------- Lock current time

		TIMELOCK		; lock current time

; ------------- Set current time

		sub	eax,[CurrentTime] ; EAX <- offset LOW
		sbb	edx,[CurrentTime+4] ; EDX <- offset HIGH
		add	[CurrentTime],eax ; set current time LOW
		adc	[CurrentTime+4],edx ; set current time HIGH
		add	[StartTime],eax	; set start time LOW
		adc	[StartTime+4],edx ; set start time HIGH

; ------------- Unlock current time

		TIMEUNLOCK		; unlock current time

; ------------- Enable interrupts

		popf			; pop flags

; ------------- Pop registers

		pop	edx		; pop EDX
		pop	eax		; pop EAX
		ret

; -----------------------------------------------------------------------------
;                              Get current time
; -----------------------------------------------------------------------------
; OUTPUT:	EDX:EAX = current time in 100-nanosec from 1/1/4713 BCE 12:00
; LOCKS:	CurrentTimeLock
; NOTES:	Takes 50 ns on 1.6 GHz CPU.
; -----------------------------------------------------------------------------

; ------------- Disable interrupts (timer interrupt locks current time)

GetCurrentTime:	pushf			; push flags
		cli			; disable interrupts

; ------------- Lock current time

		TIMELOCK		; lock current time

; ------------- Read current time

		mov	eax,[CurrentTime] ; get current time LOW
		mov	edx,[CurrentTime+4] ; get current time HIGH

; ------------- Unlock current time

		TIMEUNLOCK		; unlock current time

; ------------- Enable interrupts

		popf			; pop flags
		ret

; -----------------------------------------------------------------------------
;                       Get system start-up time
; -----------------------------------------------------------------------------
; OUTPUT:	EDX:EAX = system start-up time in 100-nanosecs
; -----------------------------------------------------------------------------

; ------------- Disable interrupts

GetStartTime:	pushf			; push flags
		cli			; disable interrupts

; ------------- Lock current time

		TIMELOCK		; lock current time

; ------------- Get start time

		mov	eax,[StartTime]	; EAX <- start time LOW
		mov	edx,[StartTime+4]; EDX <- start time HIGH

; ------------- Unlock current time

		TIMEUNLOCK		; unlock current time

; ------------- Enable interrupts

		popf			; pop flags
		ret

; -----------------------------------------------------------------------------
;                   Get system time (relative to start of system)
; -----------------------------------------------------------------------------
; OUTPUT:	EDX:EAX = system time in 100-nanosec
; LOCKS:	CurrentTimeLock
; NOTES:	Takes 50 ns on 1.6 GHz CPU.
; -----------------------------------------------------------------------------

; ------------- Disable interrupts (timer interrupt locks current time)

GetSystemTime:	pushf			; push flags
		cli			; disable interrupts

; ------------- Lock current time

		TIMELOCK		; lock current time

; ------------- Read current time

		mov	eax,[CurrentTime] ; get current time LOW
		mov	edx,[CurrentTime+4] ; get current time HIGH
		sub	eax,[StartTime]	; subtract start time LOW
		sbb	edx,[StartTime+4] ; subtract start time HIGH

; ------------- Unlock current time

		TIMEUNLOCK		; unlock current time

; ------------- Enable interrupts

		popf			; pop flags
		ret

; -----------------------------------------------------------------------------
;                 Get system time LOW (relative to start of system)
; -----------------------------------------------------------------------------
; OUTPUT:	EAX = system time LOW in 100-nanosec
; -----------------------------------------------------------------------------

GetSysTimeLOW:	mov	eax,[CurrentTime] ; get current time LOW
		sub	eax,[StartTime]	; subtract start time LOW
		ret

; -----------------------------------------------------------------------------
;                     Get mode of performance timer
; -----------------------------------------------------------------------------
; OUTPUT:	EAX = mode of performance timer (0=time-stamp counter, 1=time)
; -----------------------------------------------------------------------------

PerfGetMode:	xor	eax,eax		; mode 0: time-stamp counter
		TSC_OK			; is time-stamp counter supported?
		jnz	PerfGetMode2	; time-stamp counter is supported
		inc	eax		; mode 1: system time
PerfGetMode2:	ret

; -----------------------------------------------------------------------------
;                    Get native frequency of performance timer
; -----------------------------------------------------------------------------
; OUTPUT:	EAX = native frequency od performance timer in Hz
; -----------------------------------------------------------------------------

; ------------- Get frequency of time-stamp counter

PerfGetFreq:	TSC_OK			; is time-stamp counter supported?
		jz	PerfGetFreq2	; time-stamp counter is not supported
		mov	eax,[CPUInfo+CPU_Frequency] ; EAX <- CPU frequency
		ret

; ------------- Get frequency of system time (100-nanoseconds per second)

PerfGetFreq2:   mov	eax,10000000	; EAX <- frequency of system timer
		ret

; -----------------------------------------------------------------------------
;                         Get native performance timer
; -----------------------------------------------------------------------------
; OUTPUT:	EDX:EAX = performance timer for current CPU (in clocks)
; -----------------------------------------------------------------------------

; ------------- Read performance timer from time-stamp counter

PerfGet:	TSC_OK			; is time-stamp counter supported?
		jz	PerfGet2	; time-stamp counter is not supported
		rdtsc			; read time-stamp counter (-> EDX:EAX)
		ret

; ------------- Read performance timer from system time

PerfGet2:	call	GetSystemTime	; get system time
		ret

; -----------------------------------------------------------------------------
;                     Get performance timer in nanoseconds
; -----------------------------------------------------------------------------
; OUTPUT:	EDX:EAX = performance timer for current CPU (in nanoseconds)
; -----------------------------------------------------------------------------

; ------------- Push registers

PerfGetNS:	push	ebx		; push EBX
		push	ecx		; push ECX

; ------------- Read performance timer from time-stamp counter

		TSC_OK			; is time-stamp counter supported?
		jz	PerfGetNS2	; time-stamp counter is not supported
		rdtsc			; read time-stamp counter (-> EDX:EAX)

; ------------- Recalc performance timer to nanoseconds

		push	edx		; push counter HIGH
		push	eax		; push counter LOW
		mul	dword [PerfCoeffNS] ; counter LOW * coef LOW
		mov	ecx,edx		; ECX <- result 2 (waste result 1)
		pop	eax		; pop counter LOW
		mul	dword [PerfCoeffNS+4] ; counter LOW * coef HIGH
		add	ecx,eax		; ECX <- add result 2
		mov	ebx,edx		; EBX <- result 3
		pop	eax		; pop counter HIGH
		mul	dword [PerfCoeffNS] ; counter HIGH * coef LOW
		add	eax,ecx		; EAX <- add result 2
		adc	edx,ebx		; add result 3 (waste result 4)

; ------------- Pop registers

		pop	ecx		; pop ECX
		pop	ebx		; pop EBX
		ret

; ------------- Read performance timer from system time

PerfGetNS2:	call	GetSystemTime	; get system time

; ------------- Recalc performance timer to nanoseconds

		xchg	eax,ecx		; ECX <- push timer LOW
		xchg	eax,edx		; EAX <- timer HIGH
		xor	ebx,ebx		; EBX <- 0
		mov	bl,100		; number of nanoseconds per 100-nanosec
		mul	ebx		; timer HIGH * 100
		xchg	eax,ecx		; EAX <- timer LOW, ECX <- result HIGH
		mul	ebx		; timer LOW * 100
		add	edx,ecx		; add result HIGH

; ------------- Pop registers

		pop	ecx		; pop ECX
		pop	ebx		; pop EBX
		ret

; -----------------------------------------------------------------------------
;                   Get performance timer in 100-nanoseconds
; -----------------------------------------------------------------------------
; OUTPUT:	EDX:EAX = performance timer for current CPU (in 100-nanosecs)
; LOCKS:	CurrentTimeLock
; -----------------------------------------------------------------------------

; ------------- Read performance timer from time-stamp counter

PerfGet100N:	TSC_OK			; is time-stamp counter supported?
		jz	PerfGet100N2	; time-stamp counter is not supported
		rdtsc			; read time-stamp counter (-> EDX:EAX)

; ------------- Push registers

		push	ebx		; push EBX
		push	ecx		; push ECX

; ------------- Recalc performance timer to 100-nanoseconds

		push	edx		; push counter HIGH
		push	eax		; push counter LOW
		mul	dword [PerfCoeff100N] ; counter LOW * coef LOW
		mov	ecx,edx		; ECX <- result 2 (waste result 1)
		pop	eax		; pop counter LOW
		mul	dword [PerfCoeff100N+4] ; counter LOW * coef HIGH
		add	ecx,eax		; ECX <- add result 2
		mov	ebx,edx		; EBX <- result 3
		pop	eax		; pop counter HIGH
		mul	dword [PerfCoeff100N] ; counter HIGH * coef LOW
		add	eax,ecx		; EAX <- add result 2
		adc	edx,ebx		; add result 3 (waste result 4)

; ------------- Pop registers

		pop	ecx		; pop ECX
		pop	ebx		; pop EBX
		ret

; ------------- Read performance timer from system time

PerfGet100N2:	call	GetSystemTime	; get system time
		ret

; -----------------------------------------------------------------------------
;                    Get performance timer in microseconds
; -----------------------------------------------------------------------------
; OUTPUT:	EDX:EAX = performance timer for current CPU (in microseconds)
; LOCKS:	CurrentTimeLock
; -----------------------------------------------------------------------------

; ------------- Push registers

PerfGetUS:	push	ecx		; push ECX

; ------------- Read performance timer from time-stamp counter

		TSC_OK			; is time-stamp counter supported?
		jz	PerfGetUS2	; time-stamp counter is not supported
		rdtsc			; read time-stamp counter (-> EDX:EAX)

; ------------- Recalc performance timer to microseconds

		push	edx		; push counter HIGH
		mul	dword [PerfCoeffUS] ; counter LOW * coef
		mov	ecx,edx		; ECX <- result 2 (waste result 1)
		pop	eax		; pop counter HIGH
		mul	dword [PerfCoeffUS] ; counter HIGH * coef
		add	eax,ecx		; EAX <- add result 2
		adc	edx,byte 0	; carry

; ------------- Pop registers

		pop	ecx		; pop ECX
		ret

; ------------- Read performance timer from system time

PerfGetUS2:	push	ebx		; push EBX
		call	GetSystemTime	; get system time

; ------------- Recalc performance timer to microseconds

		xor	ebx,ebx		; EBX <- 0
		mov	bl,10		; number of 100-nanosec per microsecond
		xchg	eax,ecx		; ECX <- push time LOW
		xor	eax,eax		; EAX <- 0
		xchg	eax,edx		; EAX <- timer HIGH, EDX <- 0
		div	ebx		; EAX <- get result HIGH
		xchg	eax,ecx		; EAX <- time LOW, ECX <- result HIGH
		div	ebx		; EAX <- get result LOW
		mov	edx,ecx		; EDX <- result HIGH

; ------------- Pop registers

		pop	ebx		; pop EBX
		pop	ecx		; pop ECX
		ret

; -----------------------------------------------------------------------------
;                    Get performance timer in milliseconds
; -----------------------------------------------------------------------------
; OUTPUT:	EDX:EAX = performance timer for current CPU (in milliseconds)
; LOCKS:	CurrentTimeLock
; -----------------------------------------------------------------------------

; ------------- Push registers

PerfGetMS:	push	ecx		; push ECX

; ------------- Read performance timer from time-stamp counter

		TSC_OK			; is time-stamp counter supported?
		jz	PerfGetMS2	; time-stamp counter is not supported
		rdtsc			; read time-stamp counter (-> EDX:EAX)

; ------------- Recalc performance timer to milliseconds

		push	edx		; push counter HIGH
		mul	dword [PerfCoeffMS] ; counter LOW * coef
		mov	ecx,edx		; ECX <- result 2 (waste result 1)
		pop	eax		; pop counter HIGH
		mul	dword [PerfCoeffMS] ; counter HIGH * coef
		add	eax,ecx		; EAX <- add result 2
		adc	edx,byte 0	; carry
		shrd	eax,edx,10	; shift result >> 10
		shr	edx,10		; shift result HIGH >> 10

; ------------- Pop registers

		pop	ecx		; pop ECX
		ret

; ------------- Read performance timer from system time

PerfGetMS2:	push	ebx		; push EBX
		call	GetSystemTime	; get system time

; ------------- Recalc performance timer to milliseconds

		mov	ebx,10000	; number of 100-nanosec per millisecond
		xchg	eax,ecx		; ECX <- push time LOW
		xor	eax,eax		; EAX <- 0
		xchg	eax,edx		; EAX <- timer HIGH, EDX <- 0
		div	ebx		; EAX <- get result HIGH
		xchg	eax,ecx		; EAX <- time LOW, ECX <- result HIGH
		div	ebx		; EAX <- get result LOW
		mov	edx,ecx		; EDX <- result HIGH

; ------------- Pop registers

		pop	ebx		; pop EBX
		pop	ecx		; pop ECX
		ret

; -----------------------------------------------------------------------------
;                      Get performance timer in seconds
; -----------------------------------------------------------------------------
; OUTPUT:	EAX = performance timer for current CPU (in seconds)
; LOCKS:	CurrentTimeLock
; -----------------------------------------------------------------------------

; ------------- Push registers

PerfGetS:	push	ecx		; push ECX
		push	edx		; push EDX

; ------------- Read performance timer from time-stamp counter

		TSC_OK			; is time-stamp counter supported?
		jz	PerfGetS2	; time-stamp counter is not supported
		rdtsc			; read time-stamp counter (-> EDX:EAX)

; ------------- Recalc performance timer to seconds

		push	edx		; push counter HIGH
		mul	dword [PerfCoeffS] ; counter LOW * coef
		mov	ecx,edx		; ECX <- result 2 (waste result 1)
		pop	eax		; pop counter HIGH
		mul	dword [PerfCoeffS] ; counter HIGH * coef
		add	eax,ecx		; EAX <- add result 2
		adc	edx,byte 0	; carry
		shrd	eax,edx,20	; shift result >> 20

; ------------- Pop registers

		pop	edx		; pop EDX
		pop	ecx		; pop ECX
		ret

; ------------- Read performance timer from system time

PerfGetS2:	call	GetSystemTime	; get system time

; ------------- Recalc performance timer to seconds

		mov	ecx,10000000	; number of 100-nanosec per second
		div	ecx		; recalc

; ------------- Pop registers

		pop	edx		; pop EDX
		pop	ecx		; pop ECX
		ret

; -----------------------------------------------------------------------------
;                                   Data
; -----------------------------------------------------------------------------

		DATA_SECTION

; ------------- Current time lock

%ifdef SMP
		align	4, db 0
CurrentTimeLock:SPINLOCK		; current time lock
%endif

; ------------- CMOS time lock
%ifdef SMP
		align	4, db 0
CMOSTimeLock:	SPINLOCK		; CMOS time lock
%endif

; ------------- CMOS current NMI flag (bit 7: 1=NMI is disabled, 0=NMI enabled)

		align	4, db 0
CMOSNMIFlag:	db	13		; NMI is enabled, use R/O register 13

; ------------- IRQ handler for system timer

		align	8, db 0
TimeIRQHandler:	LISTHEAD		; link to next IRQ handler
		dd	0		; pointer to IRQ descriptor
		dw	IRQ_PRIVATE|IRQ_ACTIVE ; IRQ flags
		db	0		; current IRQ number
		db	0		; recomended best IRQ number
		dd	B0		; mask of usable IRQs (1=enabled)
		dd	0		; user data (NULL=disabled)
		dd	0		; counter for slow interrupts
		dd	TimerInt	; fast handler (NULL=none)
		dd	0		; slow handler (NULL=none)
		dd	0		; callback (NULL=none)

; ------------- IRQ handler for CMOS timer

		align	8, db 0
CMOSIRQHandler:	LISTHEAD		; link to next IRQ handler
		dd	0		; pointer to IRQ descriptor
		dw	IRQ_PRIVATE|IRQ_ACTIVE ; IRQ flags
		db	8		; current IRQ number
		db	8		; recomended best IRQ number
		dd	B8		; mask of usable IRQs (1=enabled)
		dd	0		; user data (NULL=disabled)
		dd	0		; counter for slow interrupts
		dd	0		; fast handler (NULL=none)
		dd	0		; slow handler (NULL=none)
		dd	0		; callback (NULL=none)

; -----------------------------------------------------------------------------
;                            Uninitialized data
; -----------------------------------------------------------------------------

		BSS_SECTION

; ------------- Time of start of the system

		align	8, resb 1
StartTime:	resd	2

; ------------- Current time

		align	8, resb 1
		resd	1
CurrentTimeDec:	resd	1		; current time - decimal part
CurrentTime:	resd	2		; current time - integer part

; ------------- Performance coefficients

		align	8, resb 1
PerfCoeffNS:	resd	2		; coefficient to recalc to nanoseconds
PerfCoeff100N:	resd	2		; coefficient to recalc to 100-nanosecs
PerfCoeffUS:	resd	1		; coefficient to recalc to microseconds
PerfCoeffMS:	resd	1		; coefficient to recalc to miliseconds
PerfCoeffS:	resd	1		; coefficient to recalc to seconds

; ------------- CMOS time buffer

CMOSTimeBuff:	resb	SYSTIME_size	; CMOS time buffer

		align	8, resb 1
CMOSTimeOff:	resd	2		; CMOS time offset (daylight savings)