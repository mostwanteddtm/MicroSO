'----- Compiler Instructions

$CPU 80386                      ' compile for 80386
$OPTIMIZE SIZE                  ' make a small code
$COMPILE EXE                    ' compile to an EXE
$DEBUG MAP OFF                  ' turn on map file generation
$DEBUG PBDEBUG OFF              ' don't include pbdebug support
$LIB COM OFF                    ' turn off communications library.
$LIB CGA OFF                    ' turn off CGA graphics library.
$LIB EGA OFF                    ' turn off EGA graphics library.
$LIB VGA OFF                    ' turn off VGA graphics library.
$LIB LPT OFF                    ' turn off printer support library.
$LIB IPRINT OFF                 ' turn off interpreted print library.
$ERROR BOUNDS OFF               ' turn off bounds checking
$ERROR NUMERIC OFF              ' turn off numeric checking
$ERROR OVERFLOW OFF             ' turn off overflow checking
$ERROR STACK OFF                ' turn off stack checking
$COM 0                          ' set communications buffer to nothing
$STRING 4                       ' set largest string size at 1 KB
$STACK 4096                     ' let's use 8 KB stack
$SOUND 1                        ' smallest music buffer possible
$DIM ARRAY                      ' force arrays to be pre-dimensioned before
$DYNAMIC                        ' all arrays will be dynamic by default
$OPTION CNTLBREAK ON            ' allow Ctrl-Break to exit program
OPTION BASE 1                   ' start arrays with element 1

' user defined types

TYPE VBEInfoBlock               ' VBE Information Block
  Signature      AS STRING*4    ' VBE Signature
  Version        AS WORD        ' VBE Version
  OemStrPtr      AS DWORD       ' Pointer to OEM String
  Capabilities   AS DWORD       ' Capabilities graphics environment
  VideoModePtr   AS DWORD       ' Pointer to Video Mode List
  TotalMemory    AS WORD        ' # of 64 KB memory blocks

  ' the next entries are added for VBE 2.0+

  OemSoftRev     AS WORD        ' VBE implementation Software revision
  OemVenName     AS DWORD       ' Pointer to Vendor Name String
  OemProdName    AS DWORD       ' Pointer to Product Name String
  OemProdRev     AS DWORD       ' Pointer to Product Revision String
  Reserved       AS STRING*222  ' Reserved for implementation scratch area
  OemData        AS STRING*256  ' Data Area for OEM Strings
END TYPE
DIM VBE AS VBEInfoBlock         ' define VBE Information Block
VBE.Signature = "VBE2"          ' the default when the function
                                ' is called to indicate VBE 2.0

TYPE ModeInfoBlock              ' Mode Information Block

  ' mandatory information for all VBE revisions

  ModeAttrib     AS WORD        ' mode attributes
  WinAAttrib     AS BYTE        ' window A attributes
  WinBAttrib     AS BYTE        ' window B attributes
  WinGranu       AS WORD        ' window granularity
  WinSize        AS WORD        ' window size
  WinASegment    AS WORD        ' window A start segment
  WinBSegment    AS WORD        ' window B start segment
  WinFuncPtr     AS DWORD       ' pointer to bank switch function
  BPSL           AS WORD        ' bytes per scan line

  ' mandatory information for VBE 1.2 and above

  XResolution    AS WORD        ' horizontal resolution
  YResolution    AS WORD        ' vertical resolution
  XCharSize      AS BYTE        ' character cell width in pixels
  YCharSize      AS BYTE        ' character cell height in pixels
  NumberOfPlanes AS BYTE        ' number of memory planes
  BitsPerPixel   AS BYTE        ' bits per pixel
  NumberOfBanks  AS BYTE        ' number of banks
  MemoryModel    AS BYTE        ' memory model type
  BankSize       AS BYTE        ' bank size in KB
  NOIP           AS BYTE        ' number of image pages
  Reserved1      AS BYTE        ' reserved for page function

  ' Direct Color fields (required for direct and YUV memory models)

  RMaskSize      AS BYTE        ' size color red mask in bits
  RFPosition     AS BYTE        ' lsb bit position of red mask
  GMaskSize      AS BYTE        ' size color green mask in bits
  GFPosition     AS BYTE        ' lsb bit position of green mask
  BMaskSize      AS BYTE        ' size color blue mask in bits
  BFdPosition    AS BYTE        ' lsb bit position of blue mask
  ReMaskSize     AS BYTE        ' size color reserved mask in bits
  ReFPosition    AS BYTE        ' lsb bit position of reserved mask
  DCMI           AS BYTE        ' direct color mode attributes

  ' mandatory information for VBE 2.0 and above

  PhysBasePtr    AS DWORD       ' physical address for flat frame buffer
  OSMO           AS DWORD       ' pointer to start of off screen memory
  OSMS           AS WORD        ' amount of off screen memory in 1KB units
  Reserved2      AS STRING*206  ' remainder of ModeInfoBlock
END TYPE
DIM MIB AS ModeInfoBlock

' word variables

DIM VBEseg AS WORD              ' segment VBE Info Block
DIM VBEoff AS WORD              ' offset VBE Info Block
VBEseg = VARSEG(VBE.Signature)  ' assign pointer to VBE Info block
VBEoff = VARPTR(VBE.Signature)
DIM MIBseg AS WORD              ' segment Mode Info Block
DIM MIBoff AS WORD              ' offset Mode Info Block
MIBseg = VARSEG(MIB.ModeAttrib) ' assign pointer to Mode Info block
MIBoff = VARPTR(MIB.ModeAttrib)
DIM AllSeg AS WORD              ' pointer to all modes array
DIM AllOff AS WORD

' integer  variables

DIM oemlen AS INTEGER           ' length OEM string
DIM NumModes AS INTEGER         ' how much modes are available
DIM Modes256 AS INTEGER         ' number of 256 color modes
DIM i AS INTEGER

' dword variables

DIM VideoMem AS DWORD           ' installed video frame buffer
DIM VideoMultiplier AS DWORD    ' 64 KB in Bytes
VideoMultiplier = 1024*64

' string variables

OEMStr$ = ""                    ' receives OEM string
cont$ = "Please, press any key to continue ..."
fin$ = "Please, press any key to end the application ..."

' mandelbrot

startreal=-2.5                  ' begin x-direction
endreal=1.5                     ' end x-direction
startimag=-1.5                  ' begin y-direction
endimag=1.5                     ' end y-direction
stepreal=0                      ' step in x-direction
stepimag=0                      ' step in y-direction
creal&=0                        ' used long-integers
cimag&=0
zreal&=0
zimag&=0
qreal&=0
qimag&=0
i%=0                            ' counter row loop
j%=0                            ' counter column loop
l%=0                            ' counter for the symmetrical row
k%=0                            ' counter iteration loop
m%=8192                         ' the fudge factor
h?=0                            ' color

$INCLUDE"SVGA.INC"              ' integrate INC file

' Main Program

CLS
' Check the installed processor. We need at least an 80386.

IF pbvCpu? < 3 THEN             ' not an 80386 or better processor
   PRINT
   PRINT"Sorry!"
   PRINT"This application needs an 80386 or better CPU."
   PRINT"Program ends now."
   END                          ' program ends here
END IF

' VESA is available?

IF ISFALSE GetVBE(VBEseg, VBEoff) THEN
   PRINT                        ' no VBE Info Block
   PRINT"Sorry!"
   PRINT"VESA support not available."
   PRINT"Program ends now."
   END                          ' program ends here
END IF

' print installed VESA version

SELECT CASE VBE.Version
  CASE &H100
    PRINT"VESA BIOS 1.0"
  CASE &H101
    PRINT"VESA BIOS 1.1"
  CASE &H102
    PRINT"VESA BIOS 1.2"
  CASE &H200
    PRINT"VESA BIOS 2.0"
  CASE &H300
    PRINT"VESA BIOS 3.0"
END SELECT

' determine length of OEM string

oemlen = GetOEMStr(VBE.OemStrPtr)
IF oemlen <> 0 THEN

   ' copy OEM String and print it out

   OEMStr$ = CopyOEMString(oemlen)
   PRINT OEMStr$

   ELSE

   ' indicate error

   PRINT"OEM string not available."
END IF

' determine the amount of installed Video Memory (Frame Buffer)

VideoMem = VBE.TotalMemory*VideoMultiplier
PRINT"Installed Video Frame Buffer ="; VideoMem;"Bytes =";_
      VideoMem/1024;"KB ="; VideoMem/(1024*1024);"MB"

' Check how much video modes available

NumModes = CountModes(VBE.VideoModePtr)

' build an array for all modes

DIM AllModes(NumModes) AS INTEGER
AllSeg = VARSEG(AllModes(1))
AllOff = VARPTR(AllModes(1))

' copy the VESA modes into the array

CALL CopyModes(AllSeg, AllOff, NumModes, VBE.VideoModePtr)

PRINT
PRINT"VESA Modes available:"
PRINT"---------------------"
PRINT
FOR i = 1 TO NumModes
  PRINT HEX$(AllModes(i)),
NEXT i

PRINT
PRINT
PRINT cont$
CALL Waiting
CLS

' loop over all VESA modes

PRINT"Possible 256 color VESA Modes:"
PRINT"=============================="
PRINT
PRINT"Mode Nr.:" TAB(13) "X resoltion" TAB(28) "Y resolution"_
     TAB(45) "Number"

FOR i = 1 TO NumModes
  temp% = AllModes(i)
  tmp% = GetMIB(temp%, MIBseg, MIBoff)
  IF tmp% = 1 THEN
     t? = MIB.BitsPerPixel
     IF t? = 8 THEN
        PRINT HEX$(temp%); "h" TAB(12) MIB.XResolution TAB(27) _
              MIB.YResolution TAB(44) i
     END IF
  END IF
NEXT i
PRINT
INPUT"Please enter the appropriate number: ",a$
mode% = 0
l% = LEN(a$)
SELECT CASE l%
  CASE 1
    mode% = ASC(a$) - &H30
  CASE 2
    b$ = LEFT$(a$,1)
    c$ = RIGHT$(a$,1)
    mode% = (ASC(b$) - &H30)*10 + (ASC(c$) - &H30)
  CASE ELSE
    PRINT"Impossible Value!"
END SELECT

PRINT cont$
CALL Waiting
CLS

temp% = AllModes(mode%)

IF ISFALSE GetMIB(temp%, MIBseg, MIBoff) THEN
   PRINT                        ' Mode Info Block not available
   PRINT"Sorry!"
   PRINT"VESA Mode not supported."
   PRINT"Program ends now."
   END                          ' program ends here
END IF

res% = SetVESAMode(temp%)

IF res% <> 0 THEN
   PRINT
   SELECT CASE res%
     CASE 1
       PRINT"VESA mode setting failed."
     CASE 2
       PRINT"VESA mode not supported in the current hardware configuration."
     CASE 3
       PRINT"Function call is invalid in current mode."
     CASE 4
       PRINT"Function not supported."
   END SELECT
   PRINT"Please try another mode."
   PRINT"Program ends now."
   END
END IF

time = TIMER

' convert to screen co-ordinates

stepimag = (endimag-startimag)/MIB.YResolution
stepreal = (endreal-startreal)/MIB.XResolution

FOR i% = 0 TO MIB.YResolution/2          ' row loop
  l% = MIB.YResolution - i%              ' calculate symmetrical row
  FOR j% = 0 TO MIB.XResolution-1        ' column loop

    ' calculate start values

    cimag& = CLNG((stepimag*i%+startimag)*m%)
    creal& = CLNG((stepreal*j%+startreal)*m%)

    ' iteration starts with z = c

    zimag& = cimag&
    zreal& = creal&

    ' calculate values for the j-loop

    CALL CalcJ(zreal&, zimag&, qreal&, qimag&)

    ' calculate the values for the k-loop

    CALL CalcK(zreal&, zimag&, creal&, cimag&, qreal&, qimag&, h?)

    ' set pixels

    CALL SetSVGAPixel(j%, i%, h?)
    CALL SetSVGAPixel(j%, l%, h?)


  NEXT j%
NEXT i%
time = TIMER - time

CALL Waiting
CALL Text                       ' set text mode
CLS
LOCATE 1, 1, 0                  ' set cursor
PRINT
PRINT"The VESA Mode number was: "; HEX$(temp%);"h"
PRINT "The resolution was: "; MIB.XResolution; "x";MIB.YResolution; "Pixel"
PRINT
PRINT"Elepsedv Time:"; time; "Seconds"
CALL Waiting


CLS
END                             ' Main Program ends here

' BASIC miscellaneous functions and procedures

' SUB Waiting
' Purpose:         Waits until the user has pressed any key.
' Input:           Nothing
' Output:          waiting for key
SUB Waiting
  WHILE LEN(INKEY$) = 0
  WEND
END SUB

' SUB CalcK                                                                 *
' Purpose:         Calculates the values in the k-loop.                       *
' Input:           p1& = address zreal&                                       *
'                  p2& = address zimag&                                       *
'                  p3& = creal&                                               *
'                  p4& = cimag&                                               *
'                  p5& = address qreal&                                       *
'                  p6& = address qimag&                                       *
'                  p7? = address h? (color)                                   *
' Output:          values calculated                                          *
SUB CalcK(p1&, p2&, byval p3&, byval p4&, p5&, p6&, p7?) PUBLIC
  LOCAL k%
  p7?=0
  ! push        ds
  ! push        di
  ! push        si
  FOR k%=1 TO 100
    ! mov       cl, 13                   ; cl = shift counter
    ! les       di, p2&                  ; es:di -> zimag&
    ! lds       si, p1&                  ; ds:si -> zreal&
    ! db        &H66
    ! mov       ax, ds:[si]              ; eax = zreal&
    ! db        &H66                     ; imul   eax,dword ptr es:[di]
    ! db        &H26                     ; eax = zreal&*zimag&
    ! db        &H0f
    ! db        &Haf
    ! db        &H05
    ! db        &H66
    ! sal       ax, 1                    ; eax = 2*zreal&*zimag&
    ! db        &H66
    ! sar       ax, cl                   ; eax = 2*zreal&*zimag&/m%
    ! db        &H66
    ! add       ax, p4&                  ; eax = 2*zreal&*zimag&/m%+cimag&
    ! db        &H66
    ! mov       word ptr es:[di], ax     ; zimag& = eax
    ! les       di, p1&                  ; es:di -> zreal&
    ! lds       si, p5&                  ; ds:si -> qreal&
    ! db        &H66
    ! mov       ax, ds:[si]              ; eax = qreal&
    ! lds       si, p6&                  ; ds:si -> qimag&
    ! db        &H66
    ! sub       ax, word ptr ds:[si]     ; eax = qreal&-qimag&
    ! db        &H66
    ! add       ax, p3&                  ; eax = qreal&-qimag&+creal&
    ! db        &H66
    ! mov       word ptr es:[di], ax     ; zreal& = eax
    ! les       di, p6&                  ; es:di -> qimag&
    ! lds       si, p2&                  ; ds:si -> zimag&
    ! db        &H66
    ! mov       ax, ds:[si]              ; eax = zimag&
    ! db        &H66                     ; imul   eax,eax
    ! db        &H0f                     ; eax = zimag&*zimag&
    ! db        &Haf
    ! db        &Hc0
    ! db        &H66
    ! shr       ax, cl                   ; eax = zimag&*zimag&/m%
    ! db        &H66
    ! mov       word ptr es:[di], ax     ; qimag& = eax
    ! les       di, p5&                  ; es:di -> qreal&
    ! lds       si, p1&                  ; ds:si -> zreal&
    ! db        &H66
    ! mov       ax, ds:[si]              ; eax = zreal&
    ! db        &H66                     ; imul   eax,eax
    ! db        &H0f                     ; eax = zreal&*zreal&
    ! db        &Haf
    ! db        &Hc0
    ! db        &H66
    ! shr       ax, cl                   ; eax = zreal&*zreal&/m%
    ! mov       word ptr es:[di], ax     ; qreal&:=eax
    ! lds       si, p6&                  ; ds:si -> qimag&
    ! db        &H66
    ! add       ax, word ptr ds:[si]     ; eax = qreal&+qimag&
    ! db        &H66
    ! shr       ax, cl                   ; eax = (qreal&+qimag&)/m%
    ! cmp       ax, 4                    ; ax > 4?
    ! jle       CalcK1                   ; no: jump
    ! les       bx, p7?                  ;yes: es:bx -> h?
    ! mov       ax, k%
    ! and       ax, &H00ff               ; ax = ax MOD 256
    ! mov       word ptr es:[bx], ax     ; h? = ax
    ! mov       k%, 100
    CalcK1:
  NEXT k%
  ! pop         si
  ! pop         di
  ! pop         ds
END SUB

