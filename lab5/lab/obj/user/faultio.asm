
obj/user/faultio.debug：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 3c 00 00 00       	call   80006d <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/lib.h>
#include <inc/x86.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
  800039:	9c                   	pushf  
  80003a:	58                   	pop    %eax
        int x, r;
	int nsecs = 1;
	int secno = 0;
	int diskno = 1;

	if (read_eflags() & FL_IOPL_3)
  80003b:	f6 c4 30             	test   $0x30,%ah
  80003e:	74 10                	je     800050 <umain+0x1d>
		cprintf("eflags wrong\n");
  800040:	83 ec 0c             	sub    $0xc,%esp
  800043:	68 60 1e 80 00       	push   $0x801e60
  800048:	e8 13 01 00 00       	call   800160 <cprintf>
  80004d:	83 c4 10             	add    $0x10,%esp
}

static inline void
outb(int port, uint8_t data)
{
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800050:	ba f6 01 00 00       	mov    $0x1f6,%edx
  800055:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
  80005a:	ee                   	out    %al,(%dx)

	// this outb to select disk 1 should result in a general protection
	// fault, because user-level code shouldn't be able to use the io space.
	outb(0x1F6, 0xE0 | (1<<4));

        cprintf("%s: made it here --- bug\n");
  80005b:	83 ec 0c             	sub    $0xc,%esp
  80005e:	68 6e 1e 80 00       	push   $0x801e6e
  800063:	e8 f8 00 00 00       	call   800160 <cprintf>
}
  800068:	83 c4 10             	add    $0x10,%esp
  80006b:	c9                   	leave  
  80006c:	c3                   	ret    

0080006d <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80006d:	55                   	push   %ebp
  80006e:	89 e5                	mov    %esp,%ebp
  800070:	56                   	push   %esi
  800071:	53                   	push   %ebx
  800072:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800075:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800078:	e8 ac 0a 00 00       	call   800b29 <sys_getenvid>
  80007d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800082:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800085:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008a:	a3 04 40 80 00       	mov    %eax,0x804004

    // save the name of the program so that panic() can use it
    if (argc > 0)
  80008f:	85 db                	test   %ebx,%ebx
  800091:	7e 07                	jle    80009a <libmain+0x2d>
        binaryname = argv[0];
  800093:	8b 06                	mov    (%esi),%eax
  800095:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  80009a:	83 ec 08             	sub    $0x8,%esp
  80009d:	56                   	push   %esi
  80009e:	53                   	push   %ebx
  80009f:	e8 8f ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  8000a4:	e8 0a 00 00 00       	call   8000b3 <exit>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5d                   	pop    %ebp
  8000b2:	c3                   	ret    

008000b3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b3:	55                   	push   %ebp
  8000b4:	89 e5                	mov    %esp,%ebp
  8000b6:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b9:	e8 65 0e 00 00       	call   800f23 <close_all>
	sys_env_destroy(0);
  8000be:	83 ec 0c             	sub    $0xc,%esp
  8000c1:	6a 00                	push   $0x0
  8000c3:	e8 20 0a 00 00       	call   800ae8 <sys_env_destroy>
}
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	c9                   	leave  
  8000cc:	c3                   	ret    

008000cd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000cd:	55                   	push   %ebp
  8000ce:	89 e5                	mov    %esp,%ebp
  8000d0:	53                   	push   %ebx
  8000d1:	83 ec 04             	sub    $0x4,%esp
  8000d4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000d7:	8b 13                	mov    (%ebx),%edx
  8000d9:	8d 42 01             	lea    0x1(%edx),%eax
  8000dc:	89 03                	mov    %eax,(%ebx)
  8000de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000e5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000ea:	75 1a                	jne    800106 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000ec:	83 ec 08             	sub    $0x8,%esp
  8000ef:	68 ff 00 00 00       	push   $0xff
  8000f4:	8d 43 08             	lea    0x8(%ebx),%eax
  8000f7:	50                   	push   %eax
  8000f8:	e8 ae 09 00 00       	call   800aab <sys_cputs>
		b->idx = 0;
  8000fd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800103:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800106:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80010a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80010d:	c9                   	leave  
  80010e:	c3                   	ret    

0080010f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800118:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011f:	00 00 00 
	b.cnt = 0;
  800122:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800129:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80012c:	ff 75 0c             	pushl  0xc(%ebp)
  80012f:	ff 75 08             	pushl  0x8(%ebp)
  800132:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800138:	50                   	push   %eax
  800139:	68 cd 00 80 00       	push   $0x8000cd
  80013e:	e8 1a 01 00 00       	call   80025d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800143:	83 c4 08             	add    $0x8,%esp
  800146:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80014c:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800152:	50                   	push   %eax
  800153:	e8 53 09 00 00       	call   800aab <sys_cputs>

	return b.cnt;
}
  800158:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800166:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800169:	50                   	push   %eax
  80016a:	ff 75 08             	pushl  0x8(%ebp)
  80016d:	e8 9d ff ff ff       	call   80010f <vcprintf>
	va_end(ap);

	return cnt;
}
  800172:	c9                   	leave  
  800173:	c3                   	ret    

00800174 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	57                   	push   %edi
  800178:	56                   	push   %esi
  800179:	53                   	push   %ebx
  80017a:	83 ec 1c             	sub    $0x1c,%esp
  80017d:	89 c7                	mov    %eax,%edi
  80017f:	89 d6                	mov    %edx,%esi
  800181:	8b 45 08             	mov    0x8(%ebp),%eax
  800184:	8b 55 0c             	mov    0xc(%ebp),%edx
  800187:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80018a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80018d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800190:	bb 00 00 00 00       	mov    $0x0,%ebx
  800195:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800198:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80019b:	39 d3                	cmp    %edx,%ebx
  80019d:	72 05                	jb     8001a4 <printnum+0x30>
  80019f:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001a2:	77 45                	ja     8001e9 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001a4:	83 ec 0c             	sub    $0xc,%esp
  8001a7:	ff 75 18             	pushl  0x18(%ebp)
  8001aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8001ad:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001b0:	53                   	push   %ebx
  8001b1:	ff 75 10             	pushl  0x10(%ebp)
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ba:	ff 75 e0             	pushl  -0x20(%ebp)
  8001bd:	ff 75 dc             	pushl  -0x24(%ebp)
  8001c0:	ff 75 d8             	pushl  -0x28(%ebp)
  8001c3:	e8 f8 19 00 00       	call   801bc0 <__udivdi3>
  8001c8:	83 c4 18             	add    $0x18,%esp
  8001cb:	52                   	push   %edx
  8001cc:	50                   	push   %eax
  8001cd:	89 f2                	mov    %esi,%edx
  8001cf:	89 f8                	mov    %edi,%eax
  8001d1:	e8 9e ff ff ff       	call   800174 <printnum>
  8001d6:	83 c4 20             	add    $0x20,%esp
  8001d9:	eb 18                	jmp    8001f3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001db:	83 ec 08             	sub    $0x8,%esp
  8001de:	56                   	push   %esi
  8001df:	ff 75 18             	pushl  0x18(%ebp)
  8001e2:	ff d7                	call   *%edi
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 03                	jmp    8001ec <printnum+0x78>
  8001e9:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ec:	83 eb 01             	sub    $0x1,%ebx
  8001ef:	85 db                	test   %ebx,%ebx
  8001f1:	7f e8                	jg     8001db <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001f3:	83 ec 08             	sub    $0x8,%esp
  8001f6:	56                   	push   %esi
  8001f7:	83 ec 04             	sub    $0x4,%esp
  8001fa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001fd:	ff 75 e0             	pushl  -0x20(%ebp)
  800200:	ff 75 dc             	pushl  -0x24(%ebp)
  800203:	ff 75 d8             	pushl  -0x28(%ebp)
  800206:	e8 e5 1a 00 00       	call   801cf0 <__umoddi3>
  80020b:	83 c4 14             	add    $0x14,%esp
  80020e:	0f be 80 92 1e 80 00 	movsbl 0x801e92(%eax),%eax
  800215:	50                   	push   %eax
  800216:	ff d7                	call   *%edi
}
  800218:	83 c4 10             	add    $0x10,%esp
  80021b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021e:	5b                   	pop    %ebx
  80021f:	5e                   	pop    %esi
  800220:	5f                   	pop    %edi
  800221:	5d                   	pop    %ebp
  800222:	c3                   	ret    

00800223 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800223:	55                   	push   %ebp
  800224:	89 e5                	mov    %esp,%ebp
  800226:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800229:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80022d:	8b 10                	mov    (%eax),%edx
  80022f:	3b 50 04             	cmp    0x4(%eax),%edx
  800232:	73 0a                	jae    80023e <sprintputch+0x1b>
		*b->buf++ = ch;
  800234:	8d 4a 01             	lea    0x1(%edx),%ecx
  800237:	89 08                	mov    %ecx,(%eax)
  800239:	8b 45 08             	mov    0x8(%ebp),%eax
  80023c:	88 02                	mov    %al,(%edx)
}
  80023e:	5d                   	pop    %ebp
  80023f:	c3                   	ret    

00800240 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800240:	55                   	push   %ebp
  800241:	89 e5                	mov    %esp,%ebp
  800243:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800246:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800249:	50                   	push   %eax
  80024a:	ff 75 10             	pushl  0x10(%ebp)
  80024d:	ff 75 0c             	pushl  0xc(%ebp)
  800250:	ff 75 08             	pushl  0x8(%ebp)
  800253:	e8 05 00 00 00       	call   80025d <vprintfmt>
	va_end(ap);
}
  800258:	83 c4 10             	add    $0x10,%esp
  80025b:	c9                   	leave  
  80025c:	c3                   	ret    

0080025d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80025d:	55                   	push   %ebp
  80025e:	89 e5                	mov    %esp,%ebp
  800260:	57                   	push   %edi
  800261:	56                   	push   %esi
  800262:	53                   	push   %ebx
  800263:	83 ec 2c             	sub    $0x2c,%esp
  800266:	8b 75 08             	mov    0x8(%ebp),%esi
  800269:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80026c:	8b 7d 10             	mov    0x10(%ebp),%edi
  80026f:	eb 12                	jmp    800283 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800271:	85 c0                	test   %eax,%eax
  800273:	0f 84 42 04 00 00    	je     8006bb <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800279:	83 ec 08             	sub    $0x8,%esp
  80027c:	53                   	push   %ebx
  80027d:	50                   	push   %eax
  80027e:	ff d6                	call   *%esi
  800280:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800283:	83 c7 01             	add    $0x1,%edi
  800286:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80028a:	83 f8 25             	cmp    $0x25,%eax
  80028d:	75 e2                	jne    800271 <vprintfmt+0x14>
  80028f:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800293:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80029a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002a1:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ad:	eb 07                	jmp    8002b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002af:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002b2:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002b6:	8d 47 01             	lea    0x1(%edi),%eax
  8002b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002bc:	0f b6 07             	movzbl (%edi),%eax
  8002bf:	0f b6 d0             	movzbl %al,%edx
  8002c2:	83 e8 23             	sub    $0x23,%eax
  8002c5:	3c 55                	cmp    $0x55,%al
  8002c7:	0f 87 d3 03 00 00    	ja     8006a0 <vprintfmt+0x443>
  8002cd:	0f b6 c0             	movzbl %al,%eax
  8002d0:	ff 24 85 e0 1f 80 00 	jmp    *0x801fe0(,%eax,4)
  8002d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002da:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002de:	eb d6                	jmp    8002b6 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8002e8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002eb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002ee:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002f2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002f5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002f8:	83 f9 09             	cmp    $0x9,%ecx
  8002fb:	77 3f                	ja     80033c <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002fd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800300:	eb e9                	jmp    8002eb <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800302:	8b 45 14             	mov    0x14(%ebp),%eax
  800305:	8b 00                	mov    (%eax),%eax
  800307:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80030a:	8b 45 14             	mov    0x14(%ebp),%eax
  80030d:	8d 40 04             	lea    0x4(%eax),%eax
  800310:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800313:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800316:	eb 2a                	jmp    800342 <vprintfmt+0xe5>
  800318:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80031b:	85 c0                	test   %eax,%eax
  80031d:	ba 00 00 00 00       	mov    $0x0,%edx
  800322:	0f 49 d0             	cmovns %eax,%edx
  800325:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80032b:	eb 89                	jmp    8002b6 <vprintfmt+0x59>
  80032d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800330:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800337:	e9 7a ff ff ff       	jmp    8002b6 <vprintfmt+0x59>
  80033c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80033f:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800342:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800346:	0f 89 6a ff ff ff    	jns    8002b6 <vprintfmt+0x59>
				width = precision, precision = -1;
  80034c:	8b 45 d0             	mov    -0x30(%ebp),%eax
  80034f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800352:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800359:	e9 58 ff ff ff       	jmp    8002b6 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80035e:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800364:	e9 4d ff ff ff       	jmp    8002b6 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800369:	8b 45 14             	mov    0x14(%ebp),%eax
  80036c:	8d 78 04             	lea    0x4(%eax),%edi
  80036f:	83 ec 08             	sub    $0x8,%esp
  800372:	53                   	push   %ebx
  800373:	ff 30                	pushl  (%eax)
  800375:	ff d6                	call   *%esi
			break;
  800377:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80037a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800380:	e9 fe fe ff ff       	jmp    800283 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800385:	8b 45 14             	mov    0x14(%ebp),%eax
  800388:	8d 78 04             	lea    0x4(%eax),%edi
  80038b:	8b 00                	mov    (%eax),%eax
  80038d:	99                   	cltd   
  80038e:	31 d0                	xor    %edx,%eax
  800390:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800392:	83 f8 0f             	cmp    $0xf,%eax
  800395:	7f 0b                	jg     8003a2 <vprintfmt+0x145>
  800397:	8b 14 85 40 21 80 00 	mov    0x802140(,%eax,4),%edx
  80039e:	85 d2                	test   %edx,%edx
  8003a0:	75 1b                	jne    8003bd <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003a2:	50                   	push   %eax
  8003a3:	68 aa 1e 80 00       	push   $0x801eaa
  8003a8:	53                   	push   %ebx
  8003a9:	56                   	push   %esi
  8003aa:	e8 91 fe ff ff       	call   800240 <printfmt>
  8003af:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003b2:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003b8:	e9 c6 fe ff ff       	jmp    800283 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003bd:	52                   	push   %edx
  8003be:	68 71 22 80 00       	push   $0x802271
  8003c3:	53                   	push   %ebx
  8003c4:	56                   	push   %esi
  8003c5:	e8 76 fe ff ff       	call   800240 <printfmt>
  8003ca:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003cd:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d3:	e9 ab fe ff ff       	jmp    800283 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8003db:	83 c0 04             	add    $0x4,%eax
  8003de:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e4:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003e6:	85 ff                	test   %edi,%edi
  8003e8:	b8 a3 1e 80 00       	mov    $0x801ea3,%eax
  8003ed:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003f4:	0f 8e 94 00 00 00    	jle    80048e <vprintfmt+0x231>
  8003fa:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003fe:	0f 84 98 00 00 00    	je     80049c <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800404:	83 ec 08             	sub    $0x8,%esp
  800407:	ff 75 d0             	pushl  -0x30(%ebp)
  80040a:	57                   	push   %edi
  80040b:	e8 33 03 00 00       	call   800743 <strnlen>
  800410:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800413:	29 c1                	sub    %eax,%ecx
  800415:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800418:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80041b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80041f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800422:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800425:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800427:	eb 0f                	jmp    800438 <vprintfmt+0x1db>
					putch(padc, putdat);
  800429:	83 ec 08             	sub    $0x8,%esp
  80042c:	53                   	push   %ebx
  80042d:	ff 75 e0             	pushl  -0x20(%ebp)
  800430:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800432:	83 ef 01             	sub    $0x1,%edi
  800435:	83 c4 10             	add    $0x10,%esp
  800438:	85 ff                	test   %edi,%edi
  80043a:	7f ed                	jg     800429 <vprintfmt+0x1cc>
  80043c:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80043f:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800442:	85 c9                	test   %ecx,%ecx
  800444:	b8 00 00 00 00       	mov    $0x0,%eax
  800449:	0f 49 c1             	cmovns %ecx,%eax
  80044c:	29 c1                	sub    %eax,%ecx
  80044e:	89 75 08             	mov    %esi,0x8(%ebp)
  800451:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800454:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800457:	89 cb                	mov    %ecx,%ebx
  800459:	eb 4d                	jmp    8004a8 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80045b:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80045f:	74 1b                	je     80047c <vprintfmt+0x21f>
  800461:	0f be c0             	movsbl %al,%eax
  800464:	83 e8 20             	sub    $0x20,%eax
  800467:	83 f8 5e             	cmp    $0x5e,%eax
  80046a:	76 10                	jbe    80047c <vprintfmt+0x21f>
					putch('?', putdat);
  80046c:	83 ec 08             	sub    $0x8,%esp
  80046f:	ff 75 0c             	pushl  0xc(%ebp)
  800472:	6a 3f                	push   $0x3f
  800474:	ff 55 08             	call   *0x8(%ebp)
  800477:	83 c4 10             	add    $0x10,%esp
  80047a:	eb 0d                	jmp    800489 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80047c:	83 ec 08             	sub    $0x8,%esp
  80047f:	ff 75 0c             	pushl  0xc(%ebp)
  800482:	52                   	push   %edx
  800483:	ff 55 08             	call   *0x8(%ebp)
  800486:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800489:	83 eb 01             	sub    $0x1,%ebx
  80048c:	eb 1a                	jmp    8004a8 <vprintfmt+0x24b>
  80048e:	89 75 08             	mov    %esi,0x8(%ebp)
  800491:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800494:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800497:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80049a:	eb 0c                	jmp    8004a8 <vprintfmt+0x24b>
  80049c:	89 75 08             	mov    %esi,0x8(%ebp)
  80049f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a2:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004a8:	83 c7 01             	add    $0x1,%edi
  8004ab:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004af:	0f be d0             	movsbl %al,%edx
  8004b2:	85 d2                	test   %edx,%edx
  8004b4:	74 23                	je     8004d9 <vprintfmt+0x27c>
  8004b6:	85 f6                	test   %esi,%esi
  8004b8:	78 a1                	js     80045b <vprintfmt+0x1fe>
  8004ba:	83 ee 01             	sub    $0x1,%esi
  8004bd:	79 9c                	jns    80045b <vprintfmt+0x1fe>
  8004bf:	89 df                	mov    %ebx,%edi
  8004c1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004c7:	eb 18                	jmp    8004e1 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004c9:	83 ec 08             	sub    $0x8,%esp
  8004cc:	53                   	push   %ebx
  8004cd:	6a 20                	push   $0x20
  8004cf:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004d1:	83 ef 01             	sub    $0x1,%edi
  8004d4:	83 c4 10             	add    $0x10,%esp
  8004d7:	eb 08                	jmp    8004e1 <vprintfmt+0x284>
  8004d9:	89 df                	mov    %ebx,%edi
  8004db:	8b 75 08             	mov    0x8(%ebp),%esi
  8004de:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004e1:	85 ff                	test   %edi,%edi
  8004e3:	7f e4                	jg     8004c9 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004e8:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004ee:	e9 90 fd ff ff       	jmp    800283 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004f3:	83 f9 01             	cmp    $0x1,%ecx
  8004f6:	7e 19                	jle    800511 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8004f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fb:	8b 50 04             	mov    0x4(%eax),%edx
  8004fe:	8b 00                	mov    (%eax),%eax
  800500:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800503:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8d 40 08             	lea    0x8(%eax),%eax
  80050c:	89 45 14             	mov    %eax,0x14(%ebp)
  80050f:	eb 38                	jmp    800549 <vprintfmt+0x2ec>
	else if (lflag)
  800511:	85 c9                	test   %ecx,%ecx
  800513:	74 1b                	je     800530 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800515:	8b 45 14             	mov    0x14(%ebp),%eax
  800518:	8b 00                	mov    (%eax),%eax
  80051a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80051d:	89 c1                	mov    %eax,%ecx
  80051f:	c1 f9 1f             	sar    $0x1f,%ecx
  800522:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800525:	8b 45 14             	mov    0x14(%ebp),%eax
  800528:	8d 40 04             	lea    0x4(%eax),%eax
  80052b:	89 45 14             	mov    %eax,0x14(%ebp)
  80052e:	eb 19                	jmp    800549 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8b 00                	mov    (%eax),%eax
  800535:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800538:	89 c1                	mov    %eax,%ecx
  80053a:	c1 f9 1f             	sar    $0x1f,%ecx
  80053d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 40 04             	lea    0x4(%eax),%eax
  800546:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800549:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80054c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80054f:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800554:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800558:	0f 89 0e 01 00 00    	jns    80066c <vprintfmt+0x40f>
				putch('-', putdat);
  80055e:	83 ec 08             	sub    $0x8,%esp
  800561:	53                   	push   %ebx
  800562:	6a 2d                	push   $0x2d
  800564:	ff d6                	call   *%esi
				num = -(long long) num;
  800566:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800569:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80056c:	f7 da                	neg    %edx
  80056e:	83 d1 00             	adc    $0x0,%ecx
  800571:	f7 d9                	neg    %ecx
  800573:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800576:	b8 0a 00 00 00       	mov    $0xa,%eax
  80057b:	e9 ec 00 00 00       	jmp    80066c <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800580:	83 f9 01             	cmp    $0x1,%ecx
  800583:	7e 18                	jle    80059d <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800585:	8b 45 14             	mov    0x14(%ebp),%eax
  800588:	8b 10                	mov    (%eax),%edx
  80058a:	8b 48 04             	mov    0x4(%eax),%ecx
  80058d:	8d 40 08             	lea    0x8(%eax),%eax
  800590:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800593:	b8 0a 00 00 00       	mov    $0xa,%eax
  800598:	e9 cf 00 00 00       	jmp    80066c <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80059d:	85 c9                	test   %ecx,%ecx
  80059f:	74 1a                	je     8005bb <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8b 10                	mov    (%eax),%edx
  8005a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ab:	8d 40 04             	lea    0x4(%eax),%eax
  8005ae:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005b1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b6:	e9 b1 00 00 00       	jmp    80066c <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005be:	8b 10                	mov    (%eax),%edx
  8005c0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005c5:	8d 40 04             	lea    0x4(%eax),%eax
  8005c8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d0:	e9 97 00 00 00       	jmp    80066c <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005d5:	83 ec 08             	sub    $0x8,%esp
  8005d8:	53                   	push   %ebx
  8005d9:	6a 58                	push   $0x58
  8005db:	ff d6                	call   *%esi
			putch('X', putdat);
  8005dd:	83 c4 08             	add    $0x8,%esp
  8005e0:	53                   	push   %ebx
  8005e1:	6a 58                	push   $0x58
  8005e3:	ff d6                	call   *%esi
			putch('X', putdat);
  8005e5:	83 c4 08             	add    $0x8,%esp
  8005e8:	53                   	push   %ebx
  8005e9:	6a 58                	push   $0x58
  8005eb:	ff d6                	call   *%esi
			break;
  8005ed:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005f0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005f3:	e9 8b fc ff ff       	jmp    800283 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	53                   	push   %ebx
  8005fc:	6a 30                	push   $0x30
  8005fe:	ff d6                	call   *%esi
			putch('x', putdat);
  800600:	83 c4 08             	add    $0x8,%esp
  800603:	53                   	push   %ebx
  800604:	6a 78                	push   $0x78
  800606:	ff d6                	call   *%esi
			num = (unsigned long long)
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8b 10                	mov    (%eax),%edx
  80060d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800612:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800615:	8d 40 04             	lea    0x4(%eax),%eax
  800618:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80061b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800620:	eb 4a                	jmp    80066c <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800622:	83 f9 01             	cmp    $0x1,%ecx
  800625:	7e 15                	jle    80063c <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8b 10                	mov    (%eax),%edx
  80062c:	8b 48 04             	mov    0x4(%eax),%ecx
  80062f:	8d 40 08             	lea    0x8(%eax),%eax
  800632:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800635:	b8 10 00 00 00       	mov    $0x10,%eax
  80063a:	eb 30                	jmp    80066c <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80063c:	85 c9                	test   %ecx,%ecx
  80063e:	74 17                	je     800657 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800640:	8b 45 14             	mov    0x14(%ebp),%eax
  800643:	8b 10                	mov    (%eax),%edx
  800645:	b9 00 00 00 00       	mov    $0x0,%ecx
  80064a:	8d 40 04             	lea    0x4(%eax),%eax
  80064d:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800650:	b8 10 00 00 00       	mov    $0x10,%eax
  800655:	eb 15                	jmp    80066c <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800657:	8b 45 14             	mov    0x14(%ebp),%eax
  80065a:	8b 10                	mov    (%eax),%edx
  80065c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800661:	8d 40 04             	lea    0x4(%eax),%eax
  800664:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800667:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80066c:	83 ec 0c             	sub    $0xc,%esp
  80066f:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800673:	57                   	push   %edi
  800674:	ff 75 e0             	pushl  -0x20(%ebp)
  800677:	50                   	push   %eax
  800678:	51                   	push   %ecx
  800679:	52                   	push   %edx
  80067a:	89 da                	mov    %ebx,%edx
  80067c:	89 f0                	mov    %esi,%eax
  80067e:	e8 f1 fa ff ff       	call   800174 <printnum>
			break;
  800683:	83 c4 20             	add    $0x20,%esp
  800686:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800689:	e9 f5 fb ff ff       	jmp    800283 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80068e:	83 ec 08             	sub    $0x8,%esp
  800691:	53                   	push   %ebx
  800692:	52                   	push   %edx
  800693:	ff d6                	call   *%esi
			break;
  800695:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800698:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80069b:	e9 e3 fb ff ff       	jmp    800283 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006a0:	83 ec 08             	sub    $0x8,%esp
  8006a3:	53                   	push   %ebx
  8006a4:	6a 25                	push   $0x25
  8006a6:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	eb 03                	jmp    8006b0 <vprintfmt+0x453>
  8006ad:	83 ef 01             	sub    $0x1,%edi
  8006b0:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006b4:	75 f7                	jne    8006ad <vprintfmt+0x450>
  8006b6:	e9 c8 fb ff ff       	jmp    800283 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006be:	5b                   	pop    %ebx
  8006bf:	5e                   	pop    %esi
  8006c0:	5f                   	pop    %edi
  8006c1:	5d                   	pop    %ebp
  8006c2:	c3                   	ret    

008006c3 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c3:	55                   	push   %ebp
  8006c4:	89 e5                	mov    %esp,%ebp
  8006c6:	83 ec 18             	sub    $0x18,%esp
  8006c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006cf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006d2:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006d6:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006d9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e0:	85 c0                	test   %eax,%eax
  8006e2:	74 26                	je     80070a <vsnprintf+0x47>
  8006e4:	85 d2                	test   %edx,%edx
  8006e6:	7e 22                	jle    80070a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006e8:	ff 75 14             	pushl  0x14(%ebp)
  8006eb:	ff 75 10             	pushl  0x10(%ebp)
  8006ee:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f1:	50                   	push   %eax
  8006f2:	68 23 02 80 00       	push   $0x800223
  8006f7:	e8 61 fb ff ff       	call   80025d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006fc:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006ff:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800702:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800705:	83 c4 10             	add    $0x10,%esp
  800708:	eb 05                	jmp    80070f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80070a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80070f:	c9                   	leave  
  800710:	c3                   	ret    

00800711 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800717:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80071a:	50                   	push   %eax
  80071b:	ff 75 10             	pushl  0x10(%ebp)
  80071e:	ff 75 0c             	pushl  0xc(%ebp)
  800721:	ff 75 08             	pushl  0x8(%ebp)
  800724:	e8 9a ff ff ff       	call   8006c3 <vsnprintf>
	va_end(ap);

	return rc;
}
  800729:	c9                   	leave  
  80072a:	c3                   	ret    

0080072b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80072b:	55                   	push   %ebp
  80072c:	89 e5                	mov    %esp,%ebp
  80072e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800731:	b8 00 00 00 00       	mov    $0x0,%eax
  800736:	eb 03                	jmp    80073b <strlen+0x10>
		n++;
  800738:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80073b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80073f:	75 f7                	jne    800738 <strlen+0xd>
		n++;
	return n;
}
  800741:	5d                   	pop    %ebp
  800742:	c3                   	ret    

00800743 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800749:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80074c:	ba 00 00 00 00       	mov    $0x0,%edx
  800751:	eb 03                	jmp    800756 <strnlen+0x13>
		n++;
  800753:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800756:	39 c2                	cmp    %eax,%edx
  800758:	74 08                	je     800762 <strnlen+0x1f>
  80075a:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80075e:	75 f3                	jne    800753 <strnlen+0x10>
  800760:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800762:	5d                   	pop    %ebp
  800763:	c3                   	ret    

00800764 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800764:	55                   	push   %ebp
  800765:	89 e5                	mov    %esp,%ebp
  800767:	53                   	push   %ebx
  800768:	8b 45 08             	mov    0x8(%ebp),%eax
  80076b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80076e:	89 c2                	mov    %eax,%edx
  800770:	83 c2 01             	add    $0x1,%edx
  800773:	83 c1 01             	add    $0x1,%ecx
  800776:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80077a:	88 5a ff             	mov    %bl,-0x1(%edx)
  80077d:	84 db                	test   %bl,%bl
  80077f:	75 ef                	jne    800770 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800781:	5b                   	pop    %ebx
  800782:	5d                   	pop    %ebp
  800783:	c3                   	ret    

00800784 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800784:	55                   	push   %ebp
  800785:	89 e5                	mov    %esp,%ebp
  800787:	53                   	push   %ebx
  800788:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80078b:	53                   	push   %ebx
  80078c:	e8 9a ff ff ff       	call   80072b <strlen>
  800791:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800794:	ff 75 0c             	pushl  0xc(%ebp)
  800797:	01 d8                	add    %ebx,%eax
  800799:	50                   	push   %eax
  80079a:	e8 c5 ff ff ff       	call   800764 <strcpy>
	return dst;
}
  80079f:	89 d8                	mov    %ebx,%eax
  8007a1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007a4:	c9                   	leave  
  8007a5:	c3                   	ret    

008007a6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	56                   	push   %esi
  8007aa:	53                   	push   %ebx
  8007ab:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007b1:	89 f3                	mov    %esi,%ebx
  8007b3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007b6:	89 f2                	mov    %esi,%edx
  8007b8:	eb 0f                	jmp    8007c9 <strncpy+0x23>
		*dst++ = *src;
  8007ba:	83 c2 01             	add    $0x1,%edx
  8007bd:	0f b6 01             	movzbl (%ecx),%eax
  8007c0:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007c3:	80 39 01             	cmpb   $0x1,(%ecx)
  8007c6:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c9:	39 da                	cmp    %ebx,%edx
  8007cb:	75 ed                	jne    8007ba <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007cd:	89 f0                	mov    %esi,%eax
  8007cf:	5b                   	pop    %ebx
  8007d0:	5e                   	pop    %esi
  8007d1:	5d                   	pop    %ebp
  8007d2:	c3                   	ret    

008007d3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007d3:	55                   	push   %ebp
  8007d4:	89 e5                	mov    %esp,%ebp
  8007d6:	56                   	push   %esi
  8007d7:	53                   	push   %ebx
  8007d8:	8b 75 08             	mov    0x8(%ebp),%esi
  8007db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007de:	8b 55 10             	mov    0x10(%ebp),%edx
  8007e1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007e3:	85 d2                	test   %edx,%edx
  8007e5:	74 21                	je     800808 <strlcpy+0x35>
  8007e7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007eb:	89 f2                	mov    %esi,%edx
  8007ed:	eb 09                	jmp    8007f8 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007ef:	83 c2 01             	add    $0x1,%edx
  8007f2:	83 c1 01             	add    $0x1,%ecx
  8007f5:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007f8:	39 c2                	cmp    %eax,%edx
  8007fa:	74 09                	je     800805 <strlcpy+0x32>
  8007fc:	0f b6 19             	movzbl (%ecx),%ebx
  8007ff:	84 db                	test   %bl,%bl
  800801:	75 ec                	jne    8007ef <strlcpy+0x1c>
  800803:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800805:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800808:	29 f0                	sub    %esi,%eax
}
  80080a:	5b                   	pop    %ebx
  80080b:	5e                   	pop    %esi
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800814:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800817:	eb 06                	jmp    80081f <strcmp+0x11>
		p++, q++;
  800819:	83 c1 01             	add    $0x1,%ecx
  80081c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80081f:	0f b6 01             	movzbl (%ecx),%eax
  800822:	84 c0                	test   %al,%al
  800824:	74 04                	je     80082a <strcmp+0x1c>
  800826:	3a 02                	cmp    (%edx),%al
  800828:	74 ef                	je     800819 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80082a:	0f b6 c0             	movzbl %al,%eax
  80082d:	0f b6 12             	movzbl (%edx),%edx
  800830:	29 d0                	sub    %edx,%eax
}
  800832:	5d                   	pop    %ebp
  800833:	c3                   	ret    

00800834 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800834:	55                   	push   %ebp
  800835:	89 e5                	mov    %esp,%ebp
  800837:	53                   	push   %ebx
  800838:	8b 45 08             	mov    0x8(%ebp),%eax
  80083b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083e:	89 c3                	mov    %eax,%ebx
  800840:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800843:	eb 06                	jmp    80084b <strncmp+0x17>
		n--, p++, q++;
  800845:	83 c0 01             	add    $0x1,%eax
  800848:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80084b:	39 d8                	cmp    %ebx,%eax
  80084d:	74 15                	je     800864 <strncmp+0x30>
  80084f:	0f b6 08             	movzbl (%eax),%ecx
  800852:	84 c9                	test   %cl,%cl
  800854:	74 04                	je     80085a <strncmp+0x26>
  800856:	3a 0a                	cmp    (%edx),%cl
  800858:	74 eb                	je     800845 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80085a:	0f b6 00             	movzbl (%eax),%eax
  80085d:	0f b6 12             	movzbl (%edx),%edx
  800860:	29 d0                	sub    %edx,%eax
  800862:	eb 05                	jmp    800869 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800864:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800869:	5b                   	pop    %ebx
  80086a:	5d                   	pop    %ebp
  80086b:	c3                   	ret    

0080086c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80086c:	55                   	push   %ebp
  80086d:	89 e5                	mov    %esp,%ebp
  80086f:	8b 45 08             	mov    0x8(%ebp),%eax
  800872:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800876:	eb 07                	jmp    80087f <strchr+0x13>
		if (*s == c)
  800878:	38 ca                	cmp    %cl,%dl
  80087a:	74 0f                	je     80088b <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80087c:	83 c0 01             	add    $0x1,%eax
  80087f:	0f b6 10             	movzbl (%eax),%edx
  800882:	84 d2                	test   %dl,%dl
  800884:	75 f2                	jne    800878 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800886:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80088d:	55                   	push   %ebp
  80088e:	89 e5                	mov    %esp,%ebp
  800890:	8b 45 08             	mov    0x8(%ebp),%eax
  800893:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800897:	eb 03                	jmp    80089c <strfind+0xf>
  800899:	83 c0 01             	add    $0x1,%eax
  80089c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80089f:	38 ca                	cmp    %cl,%dl
  8008a1:	74 04                	je     8008a7 <strfind+0x1a>
  8008a3:	84 d2                	test   %dl,%dl
  8008a5:	75 f2                	jne    800899 <strfind+0xc>
			break;
	return (char *) s;
}
  8008a7:	5d                   	pop    %ebp
  8008a8:	c3                   	ret    

008008a9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a9:	55                   	push   %ebp
  8008aa:	89 e5                	mov    %esp,%ebp
  8008ac:	57                   	push   %edi
  8008ad:	56                   	push   %esi
  8008ae:	53                   	push   %ebx
  8008af:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008b2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008b5:	85 c9                	test   %ecx,%ecx
  8008b7:	74 36                	je     8008ef <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b9:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008bf:	75 28                	jne    8008e9 <memset+0x40>
  8008c1:	f6 c1 03             	test   $0x3,%cl
  8008c4:	75 23                	jne    8008e9 <memset+0x40>
		c &= 0xFF;
  8008c6:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ca:	89 d3                	mov    %edx,%ebx
  8008cc:	c1 e3 08             	shl    $0x8,%ebx
  8008cf:	89 d6                	mov    %edx,%esi
  8008d1:	c1 e6 18             	shl    $0x18,%esi
  8008d4:	89 d0                	mov    %edx,%eax
  8008d6:	c1 e0 10             	shl    $0x10,%eax
  8008d9:	09 f0                	or     %esi,%eax
  8008db:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008dd:	89 d8                	mov    %ebx,%eax
  8008df:	09 d0                	or     %edx,%eax
  8008e1:	c1 e9 02             	shr    $0x2,%ecx
  8008e4:	fc                   	cld    
  8008e5:	f3 ab                	rep stos %eax,%es:(%edi)
  8008e7:	eb 06                	jmp    8008ef <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ec:	fc                   	cld    
  8008ed:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008ef:	89 f8                	mov    %edi,%eax
  8008f1:	5b                   	pop    %ebx
  8008f2:	5e                   	pop    %esi
  8008f3:	5f                   	pop    %edi
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008f6:	55                   	push   %ebp
  8008f7:	89 e5                	mov    %esp,%ebp
  8008f9:	57                   	push   %edi
  8008fa:	56                   	push   %esi
  8008fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800901:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800904:	39 c6                	cmp    %eax,%esi
  800906:	73 35                	jae    80093d <memmove+0x47>
  800908:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80090b:	39 d0                	cmp    %edx,%eax
  80090d:	73 2e                	jae    80093d <memmove+0x47>
		s += n;
		d += n;
  80090f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800912:	89 d6                	mov    %edx,%esi
  800914:	09 fe                	or     %edi,%esi
  800916:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80091c:	75 13                	jne    800931 <memmove+0x3b>
  80091e:	f6 c1 03             	test   $0x3,%cl
  800921:	75 0e                	jne    800931 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800923:	83 ef 04             	sub    $0x4,%edi
  800926:	8d 72 fc             	lea    -0x4(%edx),%esi
  800929:	c1 e9 02             	shr    $0x2,%ecx
  80092c:	fd                   	std    
  80092d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80092f:	eb 09                	jmp    80093a <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800931:	83 ef 01             	sub    $0x1,%edi
  800934:	8d 72 ff             	lea    -0x1(%edx),%esi
  800937:	fd                   	std    
  800938:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80093a:	fc                   	cld    
  80093b:	eb 1d                	jmp    80095a <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80093d:	89 f2                	mov    %esi,%edx
  80093f:	09 c2                	or     %eax,%edx
  800941:	f6 c2 03             	test   $0x3,%dl
  800944:	75 0f                	jne    800955 <memmove+0x5f>
  800946:	f6 c1 03             	test   $0x3,%cl
  800949:	75 0a                	jne    800955 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80094b:	c1 e9 02             	shr    $0x2,%ecx
  80094e:	89 c7                	mov    %eax,%edi
  800950:	fc                   	cld    
  800951:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800953:	eb 05                	jmp    80095a <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800955:	89 c7                	mov    %eax,%edi
  800957:	fc                   	cld    
  800958:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80095a:	5e                   	pop    %esi
  80095b:	5f                   	pop    %edi
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800961:	ff 75 10             	pushl  0x10(%ebp)
  800964:	ff 75 0c             	pushl  0xc(%ebp)
  800967:	ff 75 08             	pushl  0x8(%ebp)
  80096a:	e8 87 ff ff ff       	call   8008f6 <memmove>
}
  80096f:	c9                   	leave  
  800970:	c3                   	ret    

00800971 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	56                   	push   %esi
  800975:	53                   	push   %ebx
  800976:	8b 45 08             	mov    0x8(%ebp),%eax
  800979:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097c:	89 c6                	mov    %eax,%esi
  80097e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800981:	eb 1a                	jmp    80099d <memcmp+0x2c>
		if (*s1 != *s2)
  800983:	0f b6 08             	movzbl (%eax),%ecx
  800986:	0f b6 1a             	movzbl (%edx),%ebx
  800989:	38 d9                	cmp    %bl,%cl
  80098b:	74 0a                	je     800997 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80098d:	0f b6 c1             	movzbl %cl,%eax
  800990:	0f b6 db             	movzbl %bl,%ebx
  800993:	29 d8                	sub    %ebx,%eax
  800995:	eb 0f                	jmp    8009a6 <memcmp+0x35>
		s1++, s2++;
  800997:	83 c0 01             	add    $0x1,%eax
  80099a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80099d:	39 f0                	cmp    %esi,%eax
  80099f:	75 e2                	jne    800983 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a6:	5b                   	pop    %ebx
  8009a7:	5e                   	pop    %esi
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009aa:	55                   	push   %ebp
  8009ab:	89 e5                	mov    %esp,%ebp
  8009ad:	53                   	push   %ebx
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009b1:	89 c1                	mov    %eax,%ecx
  8009b3:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009b6:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ba:	eb 0a                	jmp    8009c6 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009bc:	0f b6 10             	movzbl (%eax),%edx
  8009bf:	39 da                	cmp    %ebx,%edx
  8009c1:	74 07                	je     8009ca <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009c3:	83 c0 01             	add    $0x1,%eax
  8009c6:	39 c8                	cmp    %ecx,%eax
  8009c8:	72 f2                	jb     8009bc <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ca:	5b                   	pop    %ebx
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009cd:	55                   	push   %ebp
  8009ce:	89 e5                	mov    %esp,%ebp
  8009d0:	57                   	push   %edi
  8009d1:	56                   	push   %esi
  8009d2:	53                   	push   %ebx
  8009d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d9:	eb 03                	jmp    8009de <strtol+0x11>
		s++;
  8009db:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009de:	0f b6 01             	movzbl (%ecx),%eax
  8009e1:	3c 20                	cmp    $0x20,%al
  8009e3:	74 f6                	je     8009db <strtol+0xe>
  8009e5:	3c 09                	cmp    $0x9,%al
  8009e7:	74 f2                	je     8009db <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009e9:	3c 2b                	cmp    $0x2b,%al
  8009eb:	75 0a                	jne    8009f7 <strtol+0x2a>
		s++;
  8009ed:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009f0:	bf 00 00 00 00       	mov    $0x0,%edi
  8009f5:	eb 11                	jmp    800a08 <strtol+0x3b>
  8009f7:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009fc:	3c 2d                	cmp    $0x2d,%al
  8009fe:	75 08                	jne    800a08 <strtol+0x3b>
		s++, neg = 1;
  800a00:	83 c1 01             	add    $0x1,%ecx
  800a03:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a08:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a0e:	75 15                	jne    800a25 <strtol+0x58>
  800a10:	80 39 30             	cmpb   $0x30,(%ecx)
  800a13:	75 10                	jne    800a25 <strtol+0x58>
  800a15:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a19:	75 7c                	jne    800a97 <strtol+0xca>
		s += 2, base = 16;
  800a1b:	83 c1 02             	add    $0x2,%ecx
  800a1e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a23:	eb 16                	jmp    800a3b <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a25:	85 db                	test   %ebx,%ebx
  800a27:	75 12                	jne    800a3b <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a29:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a2e:	80 39 30             	cmpb   $0x30,(%ecx)
  800a31:	75 08                	jne    800a3b <strtol+0x6e>
		s++, base = 8;
  800a33:	83 c1 01             	add    $0x1,%ecx
  800a36:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a3b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a40:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a43:	0f b6 11             	movzbl (%ecx),%edx
  800a46:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a49:	89 f3                	mov    %esi,%ebx
  800a4b:	80 fb 09             	cmp    $0x9,%bl
  800a4e:	77 08                	ja     800a58 <strtol+0x8b>
			dig = *s - '0';
  800a50:	0f be d2             	movsbl %dl,%edx
  800a53:	83 ea 30             	sub    $0x30,%edx
  800a56:	eb 22                	jmp    800a7a <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a58:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a5b:	89 f3                	mov    %esi,%ebx
  800a5d:	80 fb 19             	cmp    $0x19,%bl
  800a60:	77 08                	ja     800a6a <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a62:	0f be d2             	movsbl %dl,%edx
  800a65:	83 ea 57             	sub    $0x57,%edx
  800a68:	eb 10                	jmp    800a7a <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a6a:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a6d:	89 f3                	mov    %esi,%ebx
  800a6f:	80 fb 19             	cmp    $0x19,%bl
  800a72:	77 16                	ja     800a8a <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a74:	0f be d2             	movsbl %dl,%edx
  800a77:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a7a:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a7d:	7d 0b                	jge    800a8a <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a7f:	83 c1 01             	add    $0x1,%ecx
  800a82:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a86:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a88:	eb b9                	jmp    800a43 <strtol+0x76>

	if (endptr)
  800a8a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a8e:	74 0d                	je     800a9d <strtol+0xd0>
		*endptr = (char *) s;
  800a90:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a93:	89 0e                	mov    %ecx,(%esi)
  800a95:	eb 06                	jmp    800a9d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a97:	85 db                	test   %ebx,%ebx
  800a99:	74 98                	je     800a33 <strtol+0x66>
  800a9b:	eb 9e                	jmp    800a3b <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a9d:	89 c2                	mov    %eax,%edx
  800a9f:	f7 da                	neg    %edx
  800aa1:	85 ff                	test   %edi,%edi
  800aa3:	0f 45 c2             	cmovne %edx,%eax
}
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5f                   	pop    %edi
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	57                   	push   %edi
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ab9:	8b 55 08             	mov    0x8(%ebp),%edx
  800abc:	89 c3                	mov    %eax,%ebx
  800abe:	89 c7                	mov    %eax,%edi
  800ac0:	89 c6                	mov    %eax,%esi
  800ac2:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5f                   	pop    %edi
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	57                   	push   %edi
  800acd:	56                   	push   %esi
  800ace:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800acf:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad4:	b8 01 00 00 00       	mov    $0x1,%eax
  800ad9:	89 d1                	mov    %edx,%ecx
  800adb:	89 d3                	mov    %edx,%ebx
  800add:	89 d7                	mov    %edx,%edi
  800adf:	89 d6                	mov    %edx,%esi
  800ae1:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ae3:	5b                   	pop    %ebx
  800ae4:	5e                   	pop    %esi
  800ae5:	5f                   	pop    %edi
  800ae6:	5d                   	pop    %ebp
  800ae7:	c3                   	ret    

00800ae8 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ae8:	55                   	push   %ebp
  800ae9:	89 e5                	mov    %esp,%ebp
  800aeb:	57                   	push   %edi
  800aec:	56                   	push   %esi
  800aed:	53                   	push   %ebx
  800aee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af6:	b8 03 00 00 00       	mov    $0x3,%eax
  800afb:	8b 55 08             	mov    0x8(%ebp),%edx
  800afe:	89 cb                	mov    %ecx,%ebx
  800b00:	89 cf                	mov    %ecx,%edi
  800b02:	89 ce                	mov    %ecx,%esi
  800b04:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b06:	85 c0                	test   %eax,%eax
  800b08:	7e 17                	jle    800b21 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b0a:	83 ec 0c             	sub    $0xc,%esp
  800b0d:	50                   	push   %eax
  800b0e:	6a 03                	push   $0x3
  800b10:	68 9f 21 80 00       	push   $0x80219f
  800b15:	6a 23                	push   $0x23
  800b17:	68 bc 21 80 00       	push   $0x8021bc
  800b1c:	e8 21 0f 00 00       	call   801a42 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
  800b2c:	57                   	push   %edi
  800b2d:	56                   	push   %esi
  800b2e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b34:	b8 02 00 00 00       	mov    $0x2,%eax
  800b39:	89 d1                	mov    %edx,%ecx
  800b3b:	89 d3                	mov    %edx,%ebx
  800b3d:	89 d7                	mov    %edx,%edi
  800b3f:	89 d6                	mov    %edx,%esi
  800b41:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b43:	5b                   	pop    %ebx
  800b44:	5e                   	pop    %esi
  800b45:	5f                   	pop    %edi
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <sys_yield>:

void
sys_yield(void)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b53:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b58:	89 d1                	mov    %edx,%ecx
  800b5a:	89 d3                	mov    %edx,%ebx
  800b5c:	89 d7                	mov    %edx,%edi
  800b5e:	89 d6                	mov    %edx,%esi
  800b60:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b62:	5b                   	pop    %ebx
  800b63:	5e                   	pop    %esi
  800b64:	5f                   	pop    %edi
  800b65:	5d                   	pop    %ebp
  800b66:	c3                   	ret    

00800b67 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b67:	55                   	push   %ebp
  800b68:	89 e5                	mov    %esp,%ebp
  800b6a:	57                   	push   %edi
  800b6b:	56                   	push   %esi
  800b6c:	53                   	push   %ebx
  800b6d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b70:	be 00 00 00 00       	mov    $0x0,%esi
  800b75:	b8 04 00 00 00       	mov    $0x4,%eax
  800b7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b7d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b80:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b83:	89 f7                	mov    %esi,%edi
  800b85:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b87:	85 c0                	test   %eax,%eax
  800b89:	7e 17                	jle    800ba2 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b8b:	83 ec 0c             	sub    $0xc,%esp
  800b8e:	50                   	push   %eax
  800b8f:	6a 04                	push   $0x4
  800b91:	68 9f 21 80 00       	push   $0x80219f
  800b96:	6a 23                	push   $0x23
  800b98:	68 bc 21 80 00       	push   $0x8021bc
  800b9d:	e8 a0 0e 00 00       	call   801a42 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ba2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ba5:	5b                   	pop    %ebx
  800ba6:	5e                   	pop    %esi
  800ba7:	5f                   	pop    %edi
  800ba8:	5d                   	pop    %ebp
  800ba9:	c3                   	ret    

00800baa <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800baa:	55                   	push   %ebp
  800bab:	89 e5                	mov    %esp,%ebp
  800bad:	57                   	push   %edi
  800bae:	56                   	push   %esi
  800baf:	53                   	push   %ebx
  800bb0:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb3:	b8 05 00 00 00       	mov    $0x5,%eax
  800bb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800bbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bc1:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bc4:	8b 75 18             	mov    0x18(%ebp),%esi
  800bc7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bc9:	85 c0                	test   %eax,%eax
  800bcb:	7e 17                	jle    800be4 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcd:	83 ec 0c             	sub    $0xc,%esp
  800bd0:	50                   	push   %eax
  800bd1:	6a 05                	push   $0x5
  800bd3:	68 9f 21 80 00       	push   $0x80219f
  800bd8:	6a 23                	push   $0x23
  800bda:	68 bc 21 80 00       	push   $0x8021bc
  800bdf:	e8 5e 0e 00 00       	call   801a42 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800be4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800be7:	5b                   	pop    %ebx
  800be8:	5e                   	pop    %esi
  800be9:	5f                   	pop    %edi
  800bea:	5d                   	pop    %ebp
  800beb:	c3                   	ret    

00800bec <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	57                   	push   %edi
  800bf0:	56                   	push   %esi
  800bf1:	53                   	push   %ebx
  800bf2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bf5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bfa:	b8 06 00 00 00       	mov    $0x6,%eax
  800bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c02:	8b 55 08             	mov    0x8(%ebp),%edx
  800c05:	89 df                	mov    %ebx,%edi
  800c07:	89 de                	mov    %ebx,%esi
  800c09:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c0b:	85 c0                	test   %eax,%eax
  800c0d:	7e 17                	jle    800c26 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c0f:	83 ec 0c             	sub    $0xc,%esp
  800c12:	50                   	push   %eax
  800c13:	6a 06                	push   $0x6
  800c15:	68 9f 21 80 00       	push   $0x80219f
  800c1a:	6a 23                	push   $0x23
  800c1c:	68 bc 21 80 00       	push   $0x8021bc
  800c21:	e8 1c 0e 00 00       	call   801a42 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c29:	5b                   	pop    %ebx
  800c2a:	5e                   	pop    %esi
  800c2b:	5f                   	pop    %edi
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c37:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3c:	b8 08 00 00 00       	mov    $0x8,%eax
  800c41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	89 df                	mov    %ebx,%edi
  800c49:	89 de                	mov    %ebx,%esi
  800c4b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c4d:	85 c0                	test   %eax,%eax
  800c4f:	7e 17                	jle    800c68 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c51:	83 ec 0c             	sub    $0xc,%esp
  800c54:	50                   	push   %eax
  800c55:	6a 08                	push   $0x8
  800c57:	68 9f 21 80 00       	push   $0x80219f
  800c5c:	6a 23                	push   $0x23
  800c5e:	68 bc 21 80 00       	push   $0x8021bc
  800c63:	e8 da 0d 00 00       	call   801a42 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c68:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c6b:	5b                   	pop    %ebx
  800c6c:	5e                   	pop    %esi
  800c6d:	5f                   	pop    %edi
  800c6e:	5d                   	pop    %ebp
  800c6f:	c3                   	ret    

00800c70 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c70:	55                   	push   %ebp
  800c71:	89 e5                	mov    %esp,%ebp
  800c73:	57                   	push   %edi
  800c74:	56                   	push   %esi
  800c75:	53                   	push   %ebx
  800c76:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c79:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c7e:	b8 09 00 00 00       	mov    $0x9,%eax
  800c83:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c86:	8b 55 08             	mov    0x8(%ebp),%edx
  800c89:	89 df                	mov    %ebx,%edi
  800c8b:	89 de                	mov    %ebx,%esi
  800c8d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	7e 17                	jle    800caa <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c93:	83 ec 0c             	sub    $0xc,%esp
  800c96:	50                   	push   %eax
  800c97:	6a 09                	push   $0x9
  800c99:	68 9f 21 80 00       	push   $0x80219f
  800c9e:	6a 23                	push   $0x23
  800ca0:	68 bc 21 80 00       	push   $0x8021bc
  800ca5:	e8 98 0d 00 00       	call   801a42 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800caa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cad:	5b                   	pop    %ebx
  800cae:	5e                   	pop    %esi
  800caf:	5f                   	pop    %edi
  800cb0:	5d                   	pop    %ebp
  800cb1:	c3                   	ret    

00800cb2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cb2:	55                   	push   %ebp
  800cb3:	89 e5                	mov    %esp,%ebp
  800cb5:	57                   	push   %edi
  800cb6:	56                   	push   %esi
  800cb7:	53                   	push   %ebx
  800cb8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbb:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc0:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cc8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccb:	89 df                	mov    %ebx,%edi
  800ccd:	89 de                	mov    %ebx,%esi
  800ccf:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd1:	85 c0                	test   %eax,%eax
  800cd3:	7e 17                	jle    800cec <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd5:	83 ec 0c             	sub    $0xc,%esp
  800cd8:	50                   	push   %eax
  800cd9:	6a 0a                	push   $0xa
  800cdb:	68 9f 21 80 00       	push   $0x80219f
  800ce0:	6a 23                	push   $0x23
  800ce2:	68 bc 21 80 00       	push   $0x8021bc
  800ce7:	e8 56 0d 00 00       	call   801a42 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cef:	5b                   	pop    %ebx
  800cf0:	5e                   	pop    %esi
  800cf1:	5f                   	pop    %edi
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	57                   	push   %edi
  800cf8:	56                   	push   %esi
  800cf9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cfa:	be 00 00 00 00       	mov    $0x0,%esi
  800cff:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d04:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d07:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d0d:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d10:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d12:	5b                   	pop    %ebx
  800d13:	5e                   	pop    %esi
  800d14:	5f                   	pop    %edi
  800d15:	5d                   	pop    %ebp
  800d16:	c3                   	ret    

00800d17 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d25:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2d:	89 cb                	mov    %ecx,%ebx
  800d2f:	89 cf                	mov    %ecx,%edi
  800d31:	89 ce                	mov    %ecx,%esi
  800d33:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d35:	85 c0                	test   %eax,%eax
  800d37:	7e 17                	jle    800d50 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d39:	83 ec 0c             	sub    $0xc,%esp
  800d3c:	50                   	push   %eax
  800d3d:	6a 0d                	push   $0xd
  800d3f:	68 9f 21 80 00       	push   $0x80219f
  800d44:	6a 23                	push   $0x23
  800d46:	68 bc 21 80 00       	push   $0x8021bc
  800d4b:	e8 f2 0c 00 00       	call   801a42 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d53:	5b                   	pop    %ebx
  800d54:	5e                   	pop    %esi
  800d55:	5f                   	pop    %edi
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    

00800d58 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5e:	05 00 00 00 30       	add    $0x30000000,%eax
  800d63:	c1 e8 0c             	shr    $0xc,%eax
}
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6e:	05 00 00 00 30       	add    $0x30000000,%eax
  800d73:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d78:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d7d:	5d                   	pop    %ebp
  800d7e:	c3                   	ret    

00800d7f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d7f:	55                   	push   %ebp
  800d80:	89 e5                	mov    %esp,%ebp
  800d82:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d85:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d8a:	89 c2                	mov    %eax,%edx
  800d8c:	c1 ea 16             	shr    $0x16,%edx
  800d8f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d96:	f6 c2 01             	test   $0x1,%dl
  800d99:	74 11                	je     800dac <fd_alloc+0x2d>
  800d9b:	89 c2                	mov    %eax,%edx
  800d9d:	c1 ea 0c             	shr    $0xc,%edx
  800da0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800da7:	f6 c2 01             	test   $0x1,%dl
  800daa:	75 09                	jne    800db5 <fd_alloc+0x36>
			*fd_store = fd;
  800dac:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dae:	b8 00 00 00 00       	mov    $0x0,%eax
  800db3:	eb 17                	jmp    800dcc <fd_alloc+0x4d>
  800db5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dba:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dbf:	75 c9                	jne    800d8a <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800dc1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dc7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dd4:	83 f8 1f             	cmp    $0x1f,%eax
  800dd7:	77 36                	ja     800e0f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dd9:	c1 e0 0c             	shl    $0xc,%eax
  800ddc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800de1:	89 c2                	mov    %eax,%edx
  800de3:	c1 ea 16             	shr    $0x16,%edx
  800de6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ded:	f6 c2 01             	test   $0x1,%dl
  800df0:	74 24                	je     800e16 <fd_lookup+0x48>
  800df2:	89 c2                	mov    %eax,%edx
  800df4:	c1 ea 0c             	shr    $0xc,%edx
  800df7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dfe:	f6 c2 01             	test   $0x1,%dl
  800e01:	74 1a                	je     800e1d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e03:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e06:	89 02                	mov    %eax,(%edx)
	return 0;
  800e08:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0d:	eb 13                	jmp    800e22 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e0f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e14:	eb 0c                	jmp    800e22 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e16:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e1b:	eb 05                	jmp    800e22 <fd_lookup+0x54>
  800e1d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e22:	5d                   	pop    %ebp
  800e23:	c3                   	ret    

00800e24 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e24:	55                   	push   %ebp
  800e25:	89 e5                	mov    %esp,%ebp
  800e27:	83 ec 08             	sub    $0x8,%esp
  800e2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2d:	ba 48 22 80 00       	mov    $0x802248,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e32:	eb 13                	jmp    800e47 <dev_lookup+0x23>
  800e34:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e37:	39 08                	cmp    %ecx,(%eax)
  800e39:	75 0c                	jne    800e47 <dev_lookup+0x23>
			*dev = devtab[i];
  800e3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e40:	b8 00 00 00 00       	mov    $0x0,%eax
  800e45:	eb 2e                	jmp    800e75 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e47:	8b 02                	mov    (%edx),%eax
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	75 e7                	jne    800e34 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e4d:	a1 04 40 80 00       	mov    0x804004,%eax
  800e52:	8b 40 48             	mov    0x48(%eax),%eax
  800e55:	83 ec 04             	sub    $0x4,%esp
  800e58:	51                   	push   %ecx
  800e59:	50                   	push   %eax
  800e5a:	68 cc 21 80 00       	push   $0x8021cc
  800e5f:	e8 fc f2 ff ff       	call   800160 <cprintf>
	*dev = 0;
  800e64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e67:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e6d:	83 c4 10             	add    $0x10,%esp
  800e70:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e75:	c9                   	leave  
  800e76:	c3                   	ret    

00800e77 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	56                   	push   %esi
  800e7b:	53                   	push   %ebx
  800e7c:	83 ec 10             	sub    $0x10,%esp
  800e7f:	8b 75 08             	mov    0x8(%ebp),%esi
  800e82:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e88:	50                   	push   %eax
  800e89:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e8f:	c1 e8 0c             	shr    $0xc,%eax
  800e92:	50                   	push   %eax
  800e93:	e8 36 ff ff ff       	call   800dce <fd_lookup>
  800e98:	83 c4 08             	add    $0x8,%esp
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	78 05                	js     800ea4 <fd_close+0x2d>
	    || fd != fd2)
  800e9f:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ea2:	74 0c                	je     800eb0 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ea4:	84 db                	test   %bl,%bl
  800ea6:	ba 00 00 00 00       	mov    $0x0,%edx
  800eab:	0f 44 c2             	cmove  %edx,%eax
  800eae:	eb 41                	jmp    800ef1 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800eb0:	83 ec 08             	sub    $0x8,%esp
  800eb3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800eb6:	50                   	push   %eax
  800eb7:	ff 36                	pushl  (%esi)
  800eb9:	e8 66 ff ff ff       	call   800e24 <dev_lookup>
  800ebe:	89 c3                	mov    %eax,%ebx
  800ec0:	83 c4 10             	add    $0x10,%esp
  800ec3:	85 c0                	test   %eax,%eax
  800ec5:	78 1a                	js     800ee1 <fd_close+0x6a>
		if (dev->dev_close)
  800ec7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eca:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ecd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ed2:	85 c0                	test   %eax,%eax
  800ed4:	74 0b                	je     800ee1 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ed6:	83 ec 0c             	sub    $0xc,%esp
  800ed9:	56                   	push   %esi
  800eda:	ff d0                	call   *%eax
  800edc:	89 c3                	mov    %eax,%ebx
  800ede:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ee1:	83 ec 08             	sub    $0x8,%esp
  800ee4:	56                   	push   %esi
  800ee5:	6a 00                	push   $0x0
  800ee7:	e8 00 fd ff ff       	call   800bec <sys_page_unmap>
	return r;
  800eec:	83 c4 10             	add    $0x10,%esp
  800eef:	89 d8                	mov    %ebx,%eax
}
  800ef1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ef4:	5b                   	pop    %ebx
  800ef5:	5e                   	pop    %esi
  800ef6:	5d                   	pop    %ebp
  800ef7:	c3                   	ret    

00800ef8 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800ef8:	55                   	push   %ebp
  800ef9:	89 e5                	mov    %esp,%ebp
  800efb:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800efe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f01:	50                   	push   %eax
  800f02:	ff 75 08             	pushl  0x8(%ebp)
  800f05:	e8 c4 fe ff ff       	call   800dce <fd_lookup>
  800f0a:	83 c4 08             	add    $0x8,%esp
  800f0d:	85 c0                	test   %eax,%eax
  800f0f:	78 10                	js     800f21 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f11:	83 ec 08             	sub    $0x8,%esp
  800f14:	6a 01                	push   $0x1
  800f16:	ff 75 f4             	pushl  -0xc(%ebp)
  800f19:	e8 59 ff ff ff       	call   800e77 <fd_close>
  800f1e:	83 c4 10             	add    $0x10,%esp
}
  800f21:	c9                   	leave  
  800f22:	c3                   	ret    

00800f23 <close_all>:

void
close_all(void)
{
  800f23:	55                   	push   %ebp
  800f24:	89 e5                	mov    %esp,%ebp
  800f26:	53                   	push   %ebx
  800f27:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f2a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f2f:	83 ec 0c             	sub    $0xc,%esp
  800f32:	53                   	push   %ebx
  800f33:	e8 c0 ff ff ff       	call   800ef8 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f38:	83 c3 01             	add    $0x1,%ebx
  800f3b:	83 c4 10             	add    $0x10,%esp
  800f3e:	83 fb 20             	cmp    $0x20,%ebx
  800f41:	75 ec                	jne    800f2f <close_all+0xc>
		close(i);
}
  800f43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f46:	c9                   	leave  
  800f47:	c3                   	ret    

00800f48 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f48:	55                   	push   %ebp
  800f49:	89 e5                	mov    %esp,%ebp
  800f4b:	57                   	push   %edi
  800f4c:	56                   	push   %esi
  800f4d:	53                   	push   %ebx
  800f4e:	83 ec 2c             	sub    $0x2c,%esp
  800f51:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f54:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f57:	50                   	push   %eax
  800f58:	ff 75 08             	pushl  0x8(%ebp)
  800f5b:	e8 6e fe ff ff       	call   800dce <fd_lookup>
  800f60:	83 c4 08             	add    $0x8,%esp
  800f63:	85 c0                	test   %eax,%eax
  800f65:	0f 88 c1 00 00 00    	js     80102c <dup+0xe4>
		return r;
	close(newfdnum);
  800f6b:	83 ec 0c             	sub    $0xc,%esp
  800f6e:	56                   	push   %esi
  800f6f:	e8 84 ff ff ff       	call   800ef8 <close>

	newfd = INDEX2FD(newfdnum);
  800f74:	89 f3                	mov    %esi,%ebx
  800f76:	c1 e3 0c             	shl    $0xc,%ebx
  800f79:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f7f:	83 c4 04             	add    $0x4,%esp
  800f82:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f85:	e8 de fd ff ff       	call   800d68 <fd2data>
  800f8a:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f8c:	89 1c 24             	mov    %ebx,(%esp)
  800f8f:	e8 d4 fd ff ff       	call   800d68 <fd2data>
  800f94:	83 c4 10             	add    $0x10,%esp
  800f97:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f9a:	89 f8                	mov    %edi,%eax
  800f9c:	c1 e8 16             	shr    $0x16,%eax
  800f9f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fa6:	a8 01                	test   $0x1,%al
  800fa8:	74 37                	je     800fe1 <dup+0x99>
  800faa:	89 f8                	mov    %edi,%eax
  800fac:	c1 e8 0c             	shr    $0xc,%eax
  800faf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fb6:	f6 c2 01             	test   $0x1,%dl
  800fb9:	74 26                	je     800fe1 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fbb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fc2:	83 ec 0c             	sub    $0xc,%esp
  800fc5:	25 07 0e 00 00       	and    $0xe07,%eax
  800fca:	50                   	push   %eax
  800fcb:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fce:	6a 00                	push   $0x0
  800fd0:	57                   	push   %edi
  800fd1:	6a 00                	push   $0x0
  800fd3:	e8 d2 fb ff ff       	call   800baa <sys_page_map>
  800fd8:	89 c7                	mov    %eax,%edi
  800fda:	83 c4 20             	add    $0x20,%esp
  800fdd:	85 c0                	test   %eax,%eax
  800fdf:	78 2e                	js     80100f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fe1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fe4:	89 d0                	mov    %edx,%eax
  800fe6:	c1 e8 0c             	shr    $0xc,%eax
  800fe9:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff0:	83 ec 0c             	sub    $0xc,%esp
  800ff3:	25 07 0e 00 00       	and    $0xe07,%eax
  800ff8:	50                   	push   %eax
  800ff9:	53                   	push   %ebx
  800ffa:	6a 00                	push   $0x0
  800ffc:	52                   	push   %edx
  800ffd:	6a 00                	push   $0x0
  800fff:	e8 a6 fb ff ff       	call   800baa <sys_page_map>
  801004:	89 c7                	mov    %eax,%edi
  801006:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801009:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80100b:	85 ff                	test   %edi,%edi
  80100d:	79 1d                	jns    80102c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80100f:	83 ec 08             	sub    $0x8,%esp
  801012:	53                   	push   %ebx
  801013:	6a 00                	push   $0x0
  801015:	e8 d2 fb ff ff       	call   800bec <sys_page_unmap>
	sys_page_unmap(0, nva);
  80101a:	83 c4 08             	add    $0x8,%esp
  80101d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801020:	6a 00                	push   $0x0
  801022:	e8 c5 fb ff ff       	call   800bec <sys_page_unmap>
	return r;
  801027:	83 c4 10             	add    $0x10,%esp
  80102a:	89 f8                	mov    %edi,%eax
}
  80102c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80102f:	5b                   	pop    %ebx
  801030:	5e                   	pop    %esi
  801031:	5f                   	pop    %edi
  801032:	5d                   	pop    %ebp
  801033:	c3                   	ret    

00801034 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801034:	55                   	push   %ebp
  801035:	89 e5                	mov    %esp,%ebp
  801037:	53                   	push   %ebx
  801038:	83 ec 14             	sub    $0x14,%esp
  80103b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80103e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801041:	50                   	push   %eax
  801042:	53                   	push   %ebx
  801043:	e8 86 fd ff ff       	call   800dce <fd_lookup>
  801048:	83 c4 08             	add    $0x8,%esp
  80104b:	89 c2                	mov    %eax,%edx
  80104d:	85 c0                	test   %eax,%eax
  80104f:	78 6d                	js     8010be <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801051:	83 ec 08             	sub    $0x8,%esp
  801054:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801057:	50                   	push   %eax
  801058:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80105b:	ff 30                	pushl  (%eax)
  80105d:	e8 c2 fd ff ff       	call   800e24 <dev_lookup>
  801062:	83 c4 10             	add    $0x10,%esp
  801065:	85 c0                	test   %eax,%eax
  801067:	78 4c                	js     8010b5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801069:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80106c:	8b 42 08             	mov    0x8(%edx),%eax
  80106f:	83 e0 03             	and    $0x3,%eax
  801072:	83 f8 01             	cmp    $0x1,%eax
  801075:	75 21                	jne    801098 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801077:	a1 04 40 80 00       	mov    0x804004,%eax
  80107c:	8b 40 48             	mov    0x48(%eax),%eax
  80107f:	83 ec 04             	sub    $0x4,%esp
  801082:	53                   	push   %ebx
  801083:	50                   	push   %eax
  801084:	68 0d 22 80 00       	push   $0x80220d
  801089:	e8 d2 f0 ff ff       	call   800160 <cprintf>
		return -E_INVAL;
  80108e:	83 c4 10             	add    $0x10,%esp
  801091:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801096:	eb 26                	jmp    8010be <read+0x8a>
	}
	if (!dev->dev_read)
  801098:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80109b:	8b 40 08             	mov    0x8(%eax),%eax
  80109e:	85 c0                	test   %eax,%eax
  8010a0:	74 17                	je     8010b9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010a2:	83 ec 04             	sub    $0x4,%esp
  8010a5:	ff 75 10             	pushl  0x10(%ebp)
  8010a8:	ff 75 0c             	pushl  0xc(%ebp)
  8010ab:	52                   	push   %edx
  8010ac:	ff d0                	call   *%eax
  8010ae:	89 c2                	mov    %eax,%edx
  8010b0:	83 c4 10             	add    $0x10,%esp
  8010b3:	eb 09                	jmp    8010be <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010b5:	89 c2                	mov    %eax,%edx
  8010b7:	eb 05                	jmp    8010be <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010b9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010be:	89 d0                	mov    %edx,%eax
  8010c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c3:	c9                   	leave  
  8010c4:	c3                   	ret    

008010c5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010c5:	55                   	push   %ebp
  8010c6:	89 e5                	mov    %esp,%ebp
  8010c8:	57                   	push   %edi
  8010c9:	56                   	push   %esi
  8010ca:	53                   	push   %ebx
  8010cb:	83 ec 0c             	sub    $0xc,%esp
  8010ce:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010d1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010d4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010d9:	eb 21                	jmp    8010fc <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010db:	83 ec 04             	sub    $0x4,%esp
  8010de:	89 f0                	mov    %esi,%eax
  8010e0:	29 d8                	sub    %ebx,%eax
  8010e2:	50                   	push   %eax
  8010e3:	89 d8                	mov    %ebx,%eax
  8010e5:	03 45 0c             	add    0xc(%ebp),%eax
  8010e8:	50                   	push   %eax
  8010e9:	57                   	push   %edi
  8010ea:	e8 45 ff ff ff       	call   801034 <read>
		if (m < 0)
  8010ef:	83 c4 10             	add    $0x10,%esp
  8010f2:	85 c0                	test   %eax,%eax
  8010f4:	78 10                	js     801106 <readn+0x41>
			return m;
		if (m == 0)
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	74 0a                	je     801104 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010fa:	01 c3                	add    %eax,%ebx
  8010fc:	39 f3                	cmp    %esi,%ebx
  8010fe:	72 db                	jb     8010db <readn+0x16>
  801100:	89 d8                	mov    %ebx,%eax
  801102:	eb 02                	jmp    801106 <readn+0x41>
  801104:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801106:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801109:	5b                   	pop    %ebx
  80110a:	5e                   	pop    %esi
  80110b:	5f                   	pop    %edi
  80110c:	5d                   	pop    %ebp
  80110d:	c3                   	ret    

0080110e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80110e:	55                   	push   %ebp
  80110f:	89 e5                	mov    %esp,%ebp
  801111:	53                   	push   %ebx
  801112:	83 ec 14             	sub    $0x14,%esp
  801115:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801118:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80111b:	50                   	push   %eax
  80111c:	53                   	push   %ebx
  80111d:	e8 ac fc ff ff       	call   800dce <fd_lookup>
  801122:	83 c4 08             	add    $0x8,%esp
  801125:	89 c2                	mov    %eax,%edx
  801127:	85 c0                	test   %eax,%eax
  801129:	78 68                	js     801193 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80112b:	83 ec 08             	sub    $0x8,%esp
  80112e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801131:	50                   	push   %eax
  801132:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801135:	ff 30                	pushl  (%eax)
  801137:	e8 e8 fc ff ff       	call   800e24 <dev_lookup>
  80113c:	83 c4 10             	add    $0x10,%esp
  80113f:	85 c0                	test   %eax,%eax
  801141:	78 47                	js     80118a <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801143:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801146:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80114a:	75 21                	jne    80116d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80114c:	a1 04 40 80 00       	mov    0x804004,%eax
  801151:	8b 40 48             	mov    0x48(%eax),%eax
  801154:	83 ec 04             	sub    $0x4,%esp
  801157:	53                   	push   %ebx
  801158:	50                   	push   %eax
  801159:	68 29 22 80 00       	push   $0x802229
  80115e:	e8 fd ef ff ff       	call   800160 <cprintf>
		return -E_INVAL;
  801163:	83 c4 10             	add    $0x10,%esp
  801166:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80116b:	eb 26                	jmp    801193 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80116d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801170:	8b 52 0c             	mov    0xc(%edx),%edx
  801173:	85 d2                	test   %edx,%edx
  801175:	74 17                	je     80118e <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801177:	83 ec 04             	sub    $0x4,%esp
  80117a:	ff 75 10             	pushl  0x10(%ebp)
  80117d:	ff 75 0c             	pushl  0xc(%ebp)
  801180:	50                   	push   %eax
  801181:	ff d2                	call   *%edx
  801183:	89 c2                	mov    %eax,%edx
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	eb 09                	jmp    801193 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118a:	89 c2                	mov    %eax,%edx
  80118c:	eb 05                	jmp    801193 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80118e:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801193:	89 d0                	mov    %edx,%eax
  801195:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801198:	c9                   	leave  
  801199:	c3                   	ret    

0080119a <seek>:

int
seek(int fdnum, off_t offset)
{
  80119a:	55                   	push   %ebp
  80119b:	89 e5                	mov    %esp,%ebp
  80119d:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011a0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011a3:	50                   	push   %eax
  8011a4:	ff 75 08             	pushl  0x8(%ebp)
  8011a7:	e8 22 fc ff ff       	call   800dce <fd_lookup>
  8011ac:	83 c4 08             	add    $0x8,%esp
  8011af:	85 c0                	test   %eax,%eax
  8011b1:	78 0e                	js     8011c1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011b3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011b9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011bc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011c1:	c9                   	leave  
  8011c2:	c3                   	ret    

008011c3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011c3:	55                   	push   %ebp
  8011c4:	89 e5                	mov    %esp,%ebp
  8011c6:	53                   	push   %ebx
  8011c7:	83 ec 14             	sub    $0x14,%esp
  8011ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011d0:	50                   	push   %eax
  8011d1:	53                   	push   %ebx
  8011d2:	e8 f7 fb ff ff       	call   800dce <fd_lookup>
  8011d7:	83 c4 08             	add    $0x8,%esp
  8011da:	89 c2                	mov    %eax,%edx
  8011dc:	85 c0                	test   %eax,%eax
  8011de:	78 65                	js     801245 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011e0:	83 ec 08             	sub    $0x8,%esp
  8011e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e6:	50                   	push   %eax
  8011e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ea:	ff 30                	pushl  (%eax)
  8011ec:	e8 33 fc ff ff       	call   800e24 <dev_lookup>
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	78 44                	js     80123c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011fb:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011ff:	75 21                	jne    801222 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801201:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801206:	8b 40 48             	mov    0x48(%eax),%eax
  801209:	83 ec 04             	sub    $0x4,%esp
  80120c:	53                   	push   %ebx
  80120d:	50                   	push   %eax
  80120e:	68 ec 21 80 00       	push   $0x8021ec
  801213:	e8 48 ef ff ff       	call   800160 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801220:	eb 23                	jmp    801245 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801222:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801225:	8b 52 18             	mov    0x18(%edx),%edx
  801228:	85 d2                	test   %edx,%edx
  80122a:	74 14                	je     801240 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80122c:	83 ec 08             	sub    $0x8,%esp
  80122f:	ff 75 0c             	pushl  0xc(%ebp)
  801232:	50                   	push   %eax
  801233:	ff d2                	call   *%edx
  801235:	89 c2                	mov    %eax,%edx
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	eb 09                	jmp    801245 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80123c:	89 c2                	mov    %eax,%edx
  80123e:	eb 05                	jmp    801245 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801240:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801245:	89 d0                	mov    %edx,%eax
  801247:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80124a:	c9                   	leave  
  80124b:	c3                   	ret    

0080124c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	53                   	push   %ebx
  801250:	83 ec 14             	sub    $0x14,%esp
  801253:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801256:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801259:	50                   	push   %eax
  80125a:	ff 75 08             	pushl  0x8(%ebp)
  80125d:	e8 6c fb ff ff       	call   800dce <fd_lookup>
  801262:	83 c4 08             	add    $0x8,%esp
  801265:	89 c2                	mov    %eax,%edx
  801267:	85 c0                	test   %eax,%eax
  801269:	78 58                	js     8012c3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126b:	83 ec 08             	sub    $0x8,%esp
  80126e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801271:	50                   	push   %eax
  801272:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801275:	ff 30                	pushl  (%eax)
  801277:	e8 a8 fb ff ff       	call   800e24 <dev_lookup>
  80127c:	83 c4 10             	add    $0x10,%esp
  80127f:	85 c0                	test   %eax,%eax
  801281:	78 37                	js     8012ba <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801283:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801286:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80128a:	74 32                	je     8012be <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80128c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80128f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801296:	00 00 00 
	stat->st_isdir = 0;
  801299:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012a0:	00 00 00 
	stat->st_dev = dev;
  8012a3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012a9:	83 ec 08             	sub    $0x8,%esp
  8012ac:	53                   	push   %ebx
  8012ad:	ff 75 f0             	pushl  -0x10(%ebp)
  8012b0:	ff 50 14             	call   *0x14(%eax)
  8012b3:	89 c2                	mov    %eax,%edx
  8012b5:	83 c4 10             	add    $0x10,%esp
  8012b8:	eb 09                	jmp    8012c3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ba:	89 c2                	mov    %eax,%edx
  8012bc:	eb 05                	jmp    8012c3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012c3:	89 d0                	mov    %edx,%eax
  8012c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c8:	c9                   	leave  
  8012c9:	c3                   	ret    

008012ca <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012ca:	55                   	push   %ebp
  8012cb:	89 e5                	mov    %esp,%ebp
  8012cd:	56                   	push   %esi
  8012ce:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012cf:	83 ec 08             	sub    $0x8,%esp
  8012d2:	6a 00                	push   $0x0
  8012d4:	ff 75 08             	pushl  0x8(%ebp)
  8012d7:	e8 e3 01 00 00       	call   8014bf <open>
  8012dc:	89 c3                	mov    %eax,%ebx
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	78 1b                	js     801300 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012e5:	83 ec 08             	sub    $0x8,%esp
  8012e8:	ff 75 0c             	pushl  0xc(%ebp)
  8012eb:	50                   	push   %eax
  8012ec:	e8 5b ff ff ff       	call   80124c <fstat>
  8012f1:	89 c6                	mov    %eax,%esi
	close(fd);
  8012f3:	89 1c 24             	mov    %ebx,(%esp)
  8012f6:	e8 fd fb ff ff       	call   800ef8 <close>
	return r;
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	89 f0                	mov    %esi,%eax
}
  801300:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801303:	5b                   	pop    %ebx
  801304:	5e                   	pop    %esi
  801305:	5d                   	pop    %ebp
  801306:	c3                   	ret    

00801307 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	56                   	push   %esi
  80130b:	53                   	push   %ebx
  80130c:	89 c6                	mov    %eax,%esi
  80130e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801310:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801317:	75 12                	jne    80132b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801319:	83 ec 0c             	sub    $0xc,%esp
  80131c:	6a 01                	push   $0x1
  80131e:	e8 22 08 00 00       	call   801b45 <ipc_find_env>
  801323:	a3 00 40 80 00       	mov    %eax,0x804000
  801328:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80132b:	6a 07                	push   $0x7
  80132d:	68 00 50 80 00       	push   $0x805000
  801332:	56                   	push   %esi
  801333:	ff 35 00 40 80 00    	pushl  0x804000
  801339:	e8 b3 07 00 00       	call   801af1 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80133e:	83 c4 0c             	add    $0xc,%esp
  801341:	6a 00                	push   $0x0
  801343:	53                   	push   %ebx
  801344:	6a 00                	push   $0x0
  801346:	e8 3d 07 00 00       	call   801a88 <ipc_recv>
}
  80134b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80134e:	5b                   	pop    %ebx
  80134f:	5e                   	pop    %esi
  801350:	5d                   	pop    %ebp
  801351:	c3                   	ret    

00801352 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801358:	8b 45 08             	mov    0x8(%ebp),%eax
  80135b:	8b 40 0c             	mov    0xc(%eax),%eax
  80135e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801363:	8b 45 0c             	mov    0xc(%ebp),%eax
  801366:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80136b:	ba 00 00 00 00       	mov    $0x0,%edx
  801370:	b8 02 00 00 00       	mov    $0x2,%eax
  801375:	e8 8d ff ff ff       	call   801307 <fsipc>
}
  80137a:	c9                   	leave  
  80137b:	c3                   	ret    

0080137c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80137c:	55                   	push   %ebp
  80137d:	89 e5                	mov    %esp,%ebp
  80137f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801382:	8b 45 08             	mov    0x8(%ebp),%eax
  801385:	8b 40 0c             	mov    0xc(%eax),%eax
  801388:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80138d:	ba 00 00 00 00       	mov    $0x0,%edx
  801392:	b8 06 00 00 00       	mov    $0x6,%eax
  801397:	e8 6b ff ff ff       	call   801307 <fsipc>
}
  80139c:	c9                   	leave  
  80139d:	c3                   	ret    

0080139e <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
  8013a1:	53                   	push   %ebx
  8013a2:	83 ec 04             	sub    $0x4,%esp
  8013a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ae:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b8:	b8 05 00 00 00       	mov    $0x5,%eax
  8013bd:	e8 45 ff ff ff       	call   801307 <fsipc>
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	78 2c                	js     8013f2 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013c6:	83 ec 08             	sub    $0x8,%esp
  8013c9:	68 00 50 80 00       	push   $0x805000
  8013ce:	53                   	push   %ebx
  8013cf:	e8 90 f3 ff ff       	call   800764 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013d4:	a1 80 50 80 00       	mov    0x805080,%eax
  8013d9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013df:	a1 84 50 80 00       	mov    0x805084,%eax
  8013e4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013ea:	83 c4 10             	add    $0x10,%esp
  8013ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013f5:	c9                   	leave  
  8013f6:	c3                   	ret    

008013f7 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013f7:	55                   	push   %ebp
  8013f8:	89 e5                	mov    %esp,%ebp
  8013fa:	83 ec 0c             	sub    $0xc,%esp
  8013fd:	8b 45 10             	mov    0x10(%ebp),%eax
  801400:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801405:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80140a:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80140d:	8b 55 08             	mov    0x8(%ebp),%edx
  801410:	8b 52 0c             	mov    0xc(%edx),%edx
  801413:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801419:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80141e:	50                   	push   %eax
  80141f:	ff 75 0c             	pushl  0xc(%ebp)
  801422:	68 08 50 80 00       	push   $0x805008
  801427:	e8 ca f4 ff ff       	call   8008f6 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80142c:	ba 00 00 00 00       	mov    $0x0,%edx
  801431:	b8 04 00 00 00       	mov    $0x4,%eax
  801436:	e8 cc fe ff ff       	call   801307 <fsipc>
	//panic("devfile_write not implemented");
}
  80143b:	c9                   	leave  
  80143c:	c3                   	ret    

0080143d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80143d:	55                   	push   %ebp
  80143e:	89 e5                	mov    %esp,%ebp
  801440:	56                   	push   %esi
  801441:	53                   	push   %ebx
  801442:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801445:	8b 45 08             	mov    0x8(%ebp),%eax
  801448:	8b 40 0c             	mov    0xc(%eax),%eax
  80144b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801450:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801456:	ba 00 00 00 00       	mov    $0x0,%edx
  80145b:	b8 03 00 00 00       	mov    $0x3,%eax
  801460:	e8 a2 fe ff ff       	call   801307 <fsipc>
  801465:	89 c3                	mov    %eax,%ebx
  801467:	85 c0                	test   %eax,%eax
  801469:	78 4b                	js     8014b6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80146b:	39 c6                	cmp    %eax,%esi
  80146d:	73 16                	jae    801485 <devfile_read+0x48>
  80146f:	68 58 22 80 00       	push   $0x802258
  801474:	68 5f 22 80 00       	push   $0x80225f
  801479:	6a 7c                	push   $0x7c
  80147b:	68 74 22 80 00       	push   $0x802274
  801480:	e8 bd 05 00 00       	call   801a42 <_panic>
	assert(r <= PGSIZE);
  801485:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80148a:	7e 16                	jle    8014a2 <devfile_read+0x65>
  80148c:	68 7f 22 80 00       	push   $0x80227f
  801491:	68 5f 22 80 00       	push   $0x80225f
  801496:	6a 7d                	push   $0x7d
  801498:	68 74 22 80 00       	push   $0x802274
  80149d:	e8 a0 05 00 00       	call   801a42 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014a2:	83 ec 04             	sub    $0x4,%esp
  8014a5:	50                   	push   %eax
  8014a6:	68 00 50 80 00       	push   $0x805000
  8014ab:	ff 75 0c             	pushl  0xc(%ebp)
  8014ae:	e8 43 f4 ff ff       	call   8008f6 <memmove>
	return r;
  8014b3:	83 c4 10             	add    $0x10,%esp
}
  8014b6:	89 d8                	mov    %ebx,%eax
  8014b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014bb:	5b                   	pop    %ebx
  8014bc:	5e                   	pop    %esi
  8014bd:	5d                   	pop    %ebp
  8014be:	c3                   	ret    

008014bf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014bf:	55                   	push   %ebp
  8014c0:	89 e5                	mov    %esp,%ebp
  8014c2:	53                   	push   %ebx
  8014c3:	83 ec 20             	sub    $0x20,%esp
  8014c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014c9:	53                   	push   %ebx
  8014ca:	e8 5c f2 ff ff       	call   80072b <strlen>
  8014cf:	83 c4 10             	add    $0x10,%esp
  8014d2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014d7:	7f 67                	jg     801540 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014d9:	83 ec 0c             	sub    $0xc,%esp
  8014dc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014df:	50                   	push   %eax
  8014e0:	e8 9a f8 ff ff       	call   800d7f <fd_alloc>
  8014e5:	83 c4 10             	add    $0x10,%esp
		return r;
  8014e8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014ea:	85 c0                	test   %eax,%eax
  8014ec:	78 57                	js     801545 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014ee:	83 ec 08             	sub    $0x8,%esp
  8014f1:	53                   	push   %ebx
  8014f2:	68 00 50 80 00       	push   $0x805000
  8014f7:	e8 68 f2 ff ff       	call   800764 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ff:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801504:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801507:	b8 01 00 00 00       	mov    $0x1,%eax
  80150c:	e8 f6 fd ff ff       	call   801307 <fsipc>
  801511:	89 c3                	mov    %eax,%ebx
  801513:	83 c4 10             	add    $0x10,%esp
  801516:	85 c0                	test   %eax,%eax
  801518:	79 14                	jns    80152e <open+0x6f>
		fd_close(fd, 0);
  80151a:	83 ec 08             	sub    $0x8,%esp
  80151d:	6a 00                	push   $0x0
  80151f:	ff 75 f4             	pushl  -0xc(%ebp)
  801522:	e8 50 f9 ff ff       	call   800e77 <fd_close>
		return r;
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	89 da                	mov    %ebx,%edx
  80152c:	eb 17                	jmp    801545 <open+0x86>
	}

	return fd2num(fd);
  80152e:	83 ec 0c             	sub    $0xc,%esp
  801531:	ff 75 f4             	pushl  -0xc(%ebp)
  801534:	e8 1f f8 ff ff       	call   800d58 <fd2num>
  801539:	89 c2                	mov    %eax,%edx
  80153b:	83 c4 10             	add    $0x10,%esp
  80153e:	eb 05                	jmp    801545 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801540:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801545:	89 d0                	mov    %edx,%eax
  801547:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80154a:	c9                   	leave  
  80154b:	c3                   	ret    

0080154c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80154c:	55                   	push   %ebp
  80154d:	89 e5                	mov    %esp,%ebp
  80154f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801552:	ba 00 00 00 00       	mov    $0x0,%edx
  801557:	b8 08 00 00 00       	mov    $0x8,%eax
  80155c:	e8 a6 fd ff ff       	call   801307 <fsipc>
}
  801561:	c9                   	leave  
  801562:	c3                   	ret    

00801563 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801563:	55                   	push   %ebp
  801564:	89 e5                	mov    %esp,%ebp
  801566:	56                   	push   %esi
  801567:	53                   	push   %ebx
  801568:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80156b:	83 ec 0c             	sub    $0xc,%esp
  80156e:	ff 75 08             	pushl  0x8(%ebp)
  801571:	e8 f2 f7 ff ff       	call   800d68 <fd2data>
  801576:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801578:	83 c4 08             	add    $0x8,%esp
  80157b:	68 8b 22 80 00       	push   $0x80228b
  801580:	53                   	push   %ebx
  801581:	e8 de f1 ff ff       	call   800764 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801586:	8b 46 04             	mov    0x4(%esi),%eax
  801589:	2b 06                	sub    (%esi),%eax
  80158b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801591:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801598:	00 00 00 
	stat->st_dev = &devpipe;
  80159b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  8015a2:	30 80 00 
	return 0;
}
  8015a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8015aa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ad:	5b                   	pop    %ebx
  8015ae:	5e                   	pop    %esi
  8015af:	5d                   	pop    %ebp
  8015b0:	c3                   	ret    

008015b1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	53                   	push   %ebx
  8015b5:	83 ec 0c             	sub    $0xc,%esp
  8015b8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015bb:	53                   	push   %ebx
  8015bc:	6a 00                	push   $0x0
  8015be:	e8 29 f6 ff ff       	call   800bec <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015c3:	89 1c 24             	mov    %ebx,(%esp)
  8015c6:	e8 9d f7 ff ff       	call   800d68 <fd2data>
  8015cb:	83 c4 08             	add    $0x8,%esp
  8015ce:	50                   	push   %eax
  8015cf:	6a 00                	push   $0x0
  8015d1:	e8 16 f6 ff ff       	call   800bec <sys_page_unmap>
}
  8015d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015d9:	c9                   	leave  
  8015da:	c3                   	ret    

008015db <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	57                   	push   %edi
  8015df:	56                   	push   %esi
  8015e0:	53                   	push   %ebx
  8015e1:	83 ec 1c             	sub    $0x1c,%esp
  8015e4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015e7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015e9:	a1 04 40 80 00       	mov    0x804004,%eax
  8015ee:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015f1:	83 ec 0c             	sub    $0xc,%esp
  8015f4:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f7:	e8 82 05 00 00       	call   801b7e <pageref>
  8015fc:	89 c3                	mov    %eax,%ebx
  8015fe:	89 3c 24             	mov    %edi,(%esp)
  801601:	e8 78 05 00 00       	call   801b7e <pageref>
  801606:	83 c4 10             	add    $0x10,%esp
  801609:	39 c3                	cmp    %eax,%ebx
  80160b:	0f 94 c1             	sete   %cl
  80160e:	0f b6 c9             	movzbl %cl,%ecx
  801611:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801614:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80161a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  80161d:	39 ce                	cmp    %ecx,%esi
  80161f:	74 1b                	je     80163c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801621:	39 c3                	cmp    %eax,%ebx
  801623:	75 c4                	jne    8015e9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801625:	8b 42 58             	mov    0x58(%edx),%eax
  801628:	ff 75 e4             	pushl  -0x1c(%ebp)
  80162b:	50                   	push   %eax
  80162c:	56                   	push   %esi
  80162d:	68 92 22 80 00       	push   $0x802292
  801632:	e8 29 eb ff ff       	call   800160 <cprintf>
  801637:	83 c4 10             	add    $0x10,%esp
  80163a:	eb ad                	jmp    8015e9 <_pipeisclosed+0xe>
	}
}
  80163c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80163f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801642:	5b                   	pop    %ebx
  801643:	5e                   	pop    %esi
  801644:	5f                   	pop    %edi
  801645:	5d                   	pop    %ebp
  801646:	c3                   	ret    

00801647 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	57                   	push   %edi
  80164b:	56                   	push   %esi
  80164c:	53                   	push   %ebx
  80164d:	83 ec 28             	sub    $0x28,%esp
  801650:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801653:	56                   	push   %esi
  801654:	e8 0f f7 ff ff       	call   800d68 <fd2data>
  801659:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80165b:	83 c4 10             	add    $0x10,%esp
  80165e:	bf 00 00 00 00       	mov    $0x0,%edi
  801663:	eb 4b                	jmp    8016b0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801665:	89 da                	mov    %ebx,%edx
  801667:	89 f0                	mov    %esi,%eax
  801669:	e8 6d ff ff ff       	call   8015db <_pipeisclosed>
  80166e:	85 c0                	test   %eax,%eax
  801670:	75 48                	jne    8016ba <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801672:	e8 d1 f4 ff ff       	call   800b48 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801677:	8b 43 04             	mov    0x4(%ebx),%eax
  80167a:	8b 0b                	mov    (%ebx),%ecx
  80167c:	8d 51 20             	lea    0x20(%ecx),%edx
  80167f:	39 d0                	cmp    %edx,%eax
  801681:	73 e2                	jae    801665 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801683:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801686:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80168a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80168d:	89 c2                	mov    %eax,%edx
  80168f:	c1 fa 1f             	sar    $0x1f,%edx
  801692:	89 d1                	mov    %edx,%ecx
  801694:	c1 e9 1b             	shr    $0x1b,%ecx
  801697:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80169a:	83 e2 1f             	and    $0x1f,%edx
  80169d:	29 ca                	sub    %ecx,%edx
  80169f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  8016a3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  8016a7:	83 c0 01             	add    $0x1,%eax
  8016aa:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016ad:	83 c7 01             	add    $0x1,%edi
  8016b0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016b3:	75 c2                	jne    801677 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8016b8:	eb 05                	jmp    8016bf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016ba:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c2:	5b                   	pop    %ebx
  8016c3:	5e                   	pop    %esi
  8016c4:	5f                   	pop    %edi
  8016c5:	5d                   	pop    %ebp
  8016c6:	c3                   	ret    

008016c7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016c7:	55                   	push   %ebp
  8016c8:	89 e5                	mov    %esp,%ebp
  8016ca:	57                   	push   %edi
  8016cb:	56                   	push   %esi
  8016cc:	53                   	push   %ebx
  8016cd:	83 ec 18             	sub    $0x18,%esp
  8016d0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016d3:	57                   	push   %edi
  8016d4:	e8 8f f6 ff ff       	call   800d68 <fd2data>
  8016d9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016db:	83 c4 10             	add    $0x10,%esp
  8016de:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016e3:	eb 3d                	jmp    801722 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016e5:	85 db                	test   %ebx,%ebx
  8016e7:	74 04                	je     8016ed <devpipe_read+0x26>
				return i;
  8016e9:	89 d8                	mov    %ebx,%eax
  8016eb:	eb 44                	jmp    801731 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016ed:	89 f2                	mov    %esi,%edx
  8016ef:	89 f8                	mov    %edi,%eax
  8016f1:	e8 e5 fe ff ff       	call   8015db <_pipeisclosed>
  8016f6:	85 c0                	test   %eax,%eax
  8016f8:	75 32                	jne    80172c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016fa:	e8 49 f4 ff ff       	call   800b48 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016ff:	8b 06                	mov    (%esi),%eax
  801701:	3b 46 04             	cmp    0x4(%esi),%eax
  801704:	74 df                	je     8016e5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801706:	99                   	cltd   
  801707:	c1 ea 1b             	shr    $0x1b,%edx
  80170a:	01 d0                	add    %edx,%eax
  80170c:	83 e0 1f             	and    $0x1f,%eax
  80170f:	29 d0                	sub    %edx,%eax
  801711:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801716:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801719:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80171c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80171f:	83 c3 01             	add    $0x1,%ebx
  801722:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801725:	75 d8                	jne    8016ff <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801727:	8b 45 10             	mov    0x10(%ebp),%eax
  80172a:	eb 05                	jmp    801731 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80172c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801731:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801734:	5b                   	pop    %ebx
  801735:	5e                   	pop    %esi
  801736:	5f                   	pop    %edi
  801737:	5d                   	pop    %ebp
  801738:	c3                   	ret    

00801739 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	56                   	push   %esi
  80173d:	53                   	push   %ebx
  80173e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801741:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801744:	50                   	push   %eax
  801745:	e8 35 f6 ff ff       	call   800d7f <fd_alloc>
  80174a:	83 c4 10             	add    $0x10,%esp
  80174d:	89 c2                	mov    %eax,%edx
  80174f:	85 c0                	test   %eax,%eax
  801751:	0f 88 2c 01 00 00    	js     801883 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801757:	83 ec 04             	sub    $0x4,%esp
  80175a:	68 07 04 00 00       	push   $0x407
  80175f:	ff 75 f4             	pushl  -0xc(%ebp)
  801762:	6a 00                	push   $0x0
  801764:	e8 fe f3 ff ff       	call   800b67 <sys_page_alloc>
  801769:	83 c4 10             	add    $0x10,%esp
  80176c:	89 c2                	mov    %eax,%edx
  80176e:	85 c0                	test   %eax,%eax
  801770:	0f 88 0d 01 00 00    	js     801883 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801776:	83 ec 0c             	sub    $0xc,%esp
  801779:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80177c:	50                   	push   %eax
  80177d:	e8 fd f5 ff ff       	call   800d7f <fd_alloc>
  801782:	89 c3                	mov    %eax,%ebx
  801784:	83 c4 10             	add    $0x10,%esp
  801787:	85 c0                	test   %eax,%eax
  801789:	0f 88 e2 00 00 00    	js     801871 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80178f:	83 ec 04             	sub    $0x4,%esp
  801792:	68 07 04 00 00       	push   $0x407
  801797:	ff 75 f0             	pushl  -0x10(%ebp)
  80179a:	6a 00                	push   $0x0
  80179c:	e8 c6 f3 ff ff       	call   800b67 <sys_page_alloc>
  8017a1:	89 c3                	mov    %eax,%ebx
  8017a3:	83 c4 10             	add    $0x10,%esp
  8017a6:	85 c0                	test   %eax,%eax
  8017a8:	0f 88 c3 00 00 00    	js     801871 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017ae:	83 ec 0c             	sub    $0xc,%esp
  8017b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8017b4:	e8 af f5 ff ff       	call   800d68 <fd2data>
  8017b9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017bb:	83 c4 0c             	add    $0xc,%esp
  8017be:	68 07 04 00 00       	push   $0x407
  8017c3:	50                   	push   %eax
  8017c4:	6a 00                	push   $0x0
  8017c6:	e8 9c f3 ff ff       	call   800b67 <sys_page_alloc>
  8017cb:	89 c3                	mov    %eax,%ebx
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	0f 88 89 00 00 00    	js     801861 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017d8:	83 ec 0c             	sub    $0xc,%esp
  8017db:	ff 75 f0             	pushl  -0x10(%ebp)
  8017de:	e8 85 f5 ff ff       	call   800d68 <fd2data>
  8017e3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017ea:	50                   	push   %eax
  8017eb:	6a 00                	push   $0x0
  8017ed:	56                   	push   %esi
  8017ee:	6a 00                	push   $0x0
  8017f0:	e8 b5 f3 ff ff       	call   800baa <sys_page_map>
  8017f5:	89 c3                	mov    %eax,%ebx
  8017f7:	83 c4 20             	add    $0x20,%esp
  8017fa:	85 c0                	test   %eax,%eax
  8017fc:	78 55                	js     801853 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017fe:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801804:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801807:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801809:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80180c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801813:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801819:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  80181e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801821:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801828:	83 ec 0c             	sub    $0xc,%esp
  80182b:	ff 75 f4             	pushl  -0xc(%ebp)
  80182e:	e8 25 f5 ff ff       	call   800d58 <fd2num>
  801833:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801836:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801838:	83 c4 04             	add    $0x4,%esp
  80183b:	ff 75 f0             	pushl  -0x10(%ebp)
  80183e:	e8 15 f5 ff ff       	call   800d58 <fd2num>
  801843:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801846:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801849:	83 c4 10             	add    $0x10,%esp
  80184c:	ba 00 00 00 00       	mov    $0x0,%edx
  801851:	eb 30                	jmp    801883 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801853:	83 ec 08             	sub    $0x8,%esp
  801856:	56                   	push   %esi
  801857:	6a 00                	push   $0x0
  801859:	e8 8e f3 ff ff       	call   800bec <sys_page_unmap>
  80185e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801861:	83 ec 08             	sub    $0x8,%esp
  801864:	ff 75 f0             	pushl  -0x10(%ebp)
  801867:	6a 00                	push   $0x0
  801869:	e8 7e f3 ff ff       	call   800bec <sys_page_unmap>
  80186e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801871:	83 ec 08             	sub    $0x8,%esp
  801874:	ff 75 f4             	pushl  -0xc(%ebp)
  801877:	6a 00                	push   $0x0
  801879:	e8 6e f3 ff ff       	call   800bec <sys_page_unmap>
  80187e:	83 c4 10             	add    $0x10,%esp
  801881:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801883:	89 d0                	mov    %edx,%eax
  801885:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801888:	5b                   	pop    %ebx
  801889:	5e                   	pop    %esi
  80188a:	5d                   	pop    %ebp
  80188b:	c3                   	ret    

0080188c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80188c:	55                   	push   %ebp
  80188d:	89 e5                	mov    %esp,%ebp
  80188f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801892:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801895:	50                   	push   %eax
  801896:	ff 75 08             	pushl  0x8(%ebp)
  801899:	e8 30 f5 ff ff       	call   800dce <fd_lookup>
  80189e:	83 c4 10             	add    $0x10,%esp
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	78 18                	js     8018bd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  8018a5:	83 ec 0c             	sub    $0xc,%esp
  8018a8:	ff 75 f4             	pushl  -0xc(%ebp)
  8018ab:	e8 b8 f4 ff ff       	call   800d68 <fd2data>
	return _pipeisclosed(fd, p);
  8018b0:	89 c2                	mov    %eax,%edx
  8018b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018b5:	e8 21 fd ff ff       	call   8015db <_pipeisclosed>
  8018ba:	83 c4 10             	add    $0x10,%esp
}
  8018bd:	c9                   	leave  
  8018be:	c3                   	ret    

008018bf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018bf:	55                   	push   %ebp
  8018c0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8018c7:	5d                   	pop    %ebp
  8018c8:	c3                   	ret    

008018c9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018c9:	55                   	push   %ebp
  8018ca:	89 e5                	mov    %esp,%ebp
  8018cc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018cf:	68 aa 22 80 00       	push   $0x8022aa
  8018d4:	ff 75 0c             	pushl  0xc(%ebp)
  8018d7:	e8 88 ee ff ff       	call   800764 <strcpy>
	return 0;
}
  8018dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8018e1:	c9                   	leave  
  8018e2:	c3                   	ret    

008018e3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	57                   	push   %edi
  8018e7:	56                   	push   %esi
  8018e8:	53                   	push   %ebx
  8018e9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018ef:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018f4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018fa:	eb 2d                	jmp    801929 <devcons_write+0x46>
		m = n - tot;
  8018fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018ff:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801901:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801904:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801909:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80190c:	83 ec 04             	sub    $0x4,%esp
  80190f:	53                   	push   %ebx
  801910:	03 45 0c             	add    0xc(%ebp),%eax
  801913:	50                   	push   %eax
  801914:	57                   	push   %edi
  801915:	e8 dc ef ff ff       	call   8008f6 <memmove>
		sys_cputs(buf, m);
  80191a:	83 c4 08             	add    $0x8,%esp
  80191d:	53                   	push   %ebx
  80191e:	57                   	push   %edi
  80191f:	e8 87 f1 ff ff       	call   800aab <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801924:	01 de                	add    %ebx,%esi
  801926:	83 c4 10             	add    $0x10,%esp
  801929:	89 f0                	mov    %esi,%eax
  80192b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80192e:	72 cc                	jb     8018fc <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801930:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801933:	5b                   	pop    %ebx
  801934:	5e                   	pop    %esi
  801935:	5f                   	pop    %edi
  801936:	5d                   	pop    %ebp
  801937:	c3                   	ret    

00801938 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801938:	55                   	push   %ebp
  801939:	89 e5                	mov    %esp,%ebp
  80193b:	83 ec 08             	sub    $0x8,%esp
  80193e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801943:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801947:	74 2a                	je     801973 <devcons_read+0x3b>
  801949:	eb 05                	jmp    801950 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80194b:	e8 f8 f1 ff ff       	call   800b48 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801950:	e8 74 f1 ff ff       	call   800ac9 <sys_cgetc>
  801955:	85 c0                	test   %eax,%eax
  801957:	74 f2                	je     80194b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801959:	85 c0                	test   %eax,%eax
  80195b:	78 16                	js     801973 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  80195d:	83 f8 04             	cmp    $0x4,%eax
  801960:	74 0c                	je     80196e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801962:	8b 55 0c             	mov    0xc(%ebp),%edx
  801965:	88 02                	mov    %al,(%edx)
	return 1;
  801967:	b8 01 00 00 00       	mov    $0x1,%eax
  80196c:	eb 05                	jmp    801973 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80196e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801973:	c9                   	leave  
  801974:	c3                   	ret    

00801975 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801975:	55                   	push   %ebp
  801976:	89 e5                	mov    %esp,%ebp
  801978:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80197b:	8b 45 08             	mov    0x8(%ebp),%eax
  80197e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801981:	6a 01                	push   $0x1
  801983:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801986:	50                   	push   %eax
  801987:	e8 1f f1 ff ff       	call   800aab <sys_cputs>
}
  80198c:	83 c4 10             	add    $0x10,%esp
  80198f:	c9                   	leave  
  801990:	c3                   	ret    

00801991 <getchar>:

int
getchar(void)
{
  801991:	55                   	push   %ebp
  801992:	89 e5                	mov    %esp,%ebp
  801994:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801997:	6a 01                	push   $0x1
  801999:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80199c:	50                   	push   %eax
  80199d:	6a 00                	push   $0x0
  80199f:	e8 90 f6 ff ff       	call   801034 <read>
	if (r < 0)
  8019a4:	83 c4 10             	add    $0x10,%esp
  8019a7:	85 c0                	test   %eax,%eax
  8019a9:	78 0f                	js     8019ba <getchar+0x29>
		return r;
	if (r < 1)
  8019ab:	85 c0                	test   %eax,%eax
  8019ad:	7e 06                	jle    8019b5 <getchar+0x24>
		return -E_EOF;
	return c;
  8019af:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019b3:	eb 05                	jmp    8019ba <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019b5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019ba:	c9                   	leave  
  8019bb:	c3                   	ret    

008019bc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019c2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019c5:	50                   	push   %eax
  8019c6:	ff 75 08             	pushl  0x8(%ebp)
  8019c9:	e8 00 f4 ff ff       	call   800dce <fd_lookup>
  8019ce:	83 c4 10             	add    $0x10,%esp
  8019d1:	85 c0                	test   %eax,%eax
  8019d3:	78 11                	js     8019e6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019d8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019de:	39 10                	cmp    %edx,(%eax)
  8019e0:	0f 94 c0             	sete   %al
  8019e3:	0f b6 c0             	movzbl %al,%eax
}
  8019e6:	c9                   	leave  
  8019e7:	c3                   	ret    

008019e8 <opencons>:

int
opencons(void)
{
  8019e8:	55                   	push   %ebp
  8019e9:	89 e5                	mov    %esp,%ebp
  8019eb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019f1:	50                   	push   %eax
  8019f2:	e8 88 f3 ff ff       	call   800d7f <fd_alloc>
  8019f7:	83 c4 10             	add    $0x10,%esp
		return r;
  8019fa:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019fc:	85 c0                	test   %eax,%eax
  8019fe:	78 3e                	js     801a3e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a00:	83 ec 04             	sub    $0x4,%esp
  801a03:	68 07 04 00 00       	push   $0x407
  801a08:	ff 75 f4             	pushl  -0xc(%ebp)
  801a0b:	6a 00                	push   $0x0
  801a0d:	e8 55 f1 ff ff       	call   800b67 <sys_page_alloc>
  801a12:	83 c4 10             	add    $0x10,%esp
		return r;
  801a15:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a17:	85 c0                	test   %eax,%eax
  801a19:	78 23                	js     801a3e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a1b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a21:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a24:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a26:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a29:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a30:	83 ec 0c             	sub    $0xc,%esp
  801a33:	50                   	push   %eax
  801a34:	e8 1f f3 ff ff       	call   800d58 <fd2num>
  801a39:	89 c2                	mov    %eax,%edx
  801a3b:	83 c4 10             	add    $0x10,%esp
}
  801a3e:	89 d0                	mov    %edx,%eax
  801a40:	c9                   	leave  
  801a41:	c3                   	ret    

00801a42 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a42:	55                   	push   %ebp
  801a43:	89 e5                	mov    %esp,%ebp
  801a45:	56                   	push   %esi
  801a46:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a47:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a4a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a50:	e8 d4 f0 ff ff       	call   800b29 <sys_getenvid>
  801a55:	83 ec 0c             	sub    $0xc,%esp
  801a58:	ff 75 0c             	pushl  0xc(%ebp)
  801a5b:	ff 75 08             	pushl  0x8(%ebp)
  801a5e:	56                   	push   %esi
  801a5f:	50                   	push   %eax
  801a60:	68 b8 22 80 00       	push   $0x8022b8
  801a65:	e8 f6 e6 ff ff       	call   800160 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a6a:	83 c4 18             	add    $0x18,%esp
  801a6d:	53                   	push   %ebx
  801a6e:	ff 75 10             	pushl  0x10(%ebp)
  801a71:	e8 99 e6 ff ff       	call   80010f <vcprintf>
	cprintf("\n");
  801a76:	c7 04 24 a3 22 80 00 	movl   $0x8022a3,(%esp)
  801a7d:	e8 de e6 ff ff       	call   800160 <cprintf>
  801a82:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a85:	cc                   	int3   
  801a86:	eb fd                	jmp    801a85 <_panic+0x43>

00801a88 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	56                   	push   %esi
  801a8c:	53                   	push   %ebx
  801a8d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a90:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a93:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801a96:	85 c0                	test   %eax,%eax
  801a98:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a9d:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801aa0:	83 ec 0c             	sub    $0xc,%esp
  801aa3:	50                   	push   %eax
  801aa4:	e8 6e f2 ff ff       	call   800d17 <sys_ipc_recv>
  801aa9:	83 c4 10             	add    $0x10,%esp
  801aac:	85 c0                	test   %eax,%eax
  801aae:	79 16                	jns    801ac6 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801ab0:	85 f6                	test   %esi,%esi
  801ab2:	74 06                	je     801aba <ipc_recv+0x32>
            *from_env_store = 0;
  801ab4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801aba:	85 db                	test   %ebx,%ebx
  801abc:	74 2c                	je     801aea <ipc_recv+0x62>
            *perm_store = 0;
  801abe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ac4:	eb 24                	jmp    801aea <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801ac6:	85 f6                	test   %esi,%esi
  801ac8:	74 0a                	je     801ad4 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801aca:	a1 04 40 80 00       	mov    0x804004,%eax
  801acf:	8b 40 74             	mov    0x74(%eax),%eax
  801ad2:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801ad4:	85 db                	test   %ebx,%ebx
  801ad6:	74 0a                	je     801ae2 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801ad8:	a1 04 40 80 00       	mov    0x804004,%eax
  801add:	8b 40 78             	mov    0x78(%eax),%eax
  801ae0:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801ae2:	a1 04 40 80 00       	mov    0x804004,%eax
  801ae7:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801aea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aed:	5b                   	pop    %ebx
  801aee:	5e                   	pop    %esi
  801aef:	5d                   	pop    %ebp
  801af0:	c3                   	ret    

00801af1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	57                   	push   %edi
  801af5:	56                   	push   %esi
  801af6:	53                   	push   %ebx
  801af7:	83 ec 0c             	sub    $0xc,%esp
  801afa:	8b 7d 08             	mov    0x8(%ebp),%edi
  801afd:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b00:	8b 45 10             	mov    0x10(%ebp),%eax
  801b03:	85 c0                	test   %eax,%eax
  801b05:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801b0a:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801b0d:	eb 1c                	jmp    801b2b <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801b0f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b12:	74 12                	je     801b26 <ipc_send+0x35>
  801b14:	50                   	push   %eax
  801b15:	68 dc 22 80 00       	push   $0x8022dc
  801b1a:	6a 3a                	push   $0x3a
  801b1c:	68 f2 22 80 00       	push   $0x8022f2
  801b21:	e8 1c ff ff ff       	call   801a42 <_panic>
		sys_yield();
  801b26:	e8 1d f0 ff ff       	call   800b48 <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801b2b:	ff 75 14             	pushl  0x14(%ebp)
  801b2e:	53                   	push   %ebx
  801b2f:	56                   	push   %esi
  801b30:	57                   	push   %edi
  801b31:	e8 be f1 ff ff       	call   800cf4 <sys_ipc_try_send>
  801b36:	83 c4 10             	add    $0x10,%esp
  801b39:	85 c0                	test   %eax,%eax
  801b3b:	78 d2                	js     801b0f <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801b3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b40:	5b                   	pop    %ebx
  801b41:	5e                   	pop    %esi
  801b42:	5f                   	pop    %edi
  801b43:	5d                   	pop    %ebp
  801b44:	c3                   	ret    

00801b45 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b45:	55                   	push   %ebp
  801b46:	89 e5                	mov    %esp,%ebp
  801b48:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b4b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b50:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b53:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b59:	8b 52 50             	mov    0x50(%edx),%edx
  801b5c:	39 ca                	cmp    %ecx,%edx
  801b5e:	75 0d                	jne    801b6d <ipc_find_env+0x28>
			return envs[i].env_id;
  801b60:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b63:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b68:	8b 40 48             	mov    0x48(%eax),%eax
  801b6b:	eb 0f                	jmp    801b7c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b6d:	83 c0 01             	add    $0x1,%eax
  801b70:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b75:	75 d9                	jne    801b50 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b77:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b7c:	5d                   	pop    %ebp
  801b7d:	c3                   	ret    

00801b7e <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b7e:	55                   	push   %ebp
  801b7f:	89 e5                	mov    %esp,%ebp
  801b81:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b84:	89 d0                	mov    %edx,%eax
  801b86:	c1 e8 16             	shr    $0x16,%eax
  801b89:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b90:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b95:	f6 c1 01             	test   $0x1,%cl
  801b98:	74 1d                	je     801bb7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b9a:	c1 ea 0c             	shr    $0xc,%edx
  801b9d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801ba4:	f6 c2 01             	test   $0x1,%dl
  801ba7:	74 0e                	je     801bb7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801ba9:	c1 ea 0c             	shr    $0xc,%edx
  801bac:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801bb3:	ef 
  801bb4:	0f b7 c0             	movzwl %ax,%eax
}
  801bb7:	5d                   	pop    %ebp
  801bb8:	c3                   	ret    
  801bb9:	66 90                	xchg   %ax,%ax
  801bbb:	66 90                	xchg   %ax,%ax
  801bbd:	66 90                	xchg   %ax,%ax
  801bbf:	90                   	nop

00801bc0 <__udivdi3>:
  801bc0:	55                   	push   %ebp
  801bc1:	57                   	push   %edi
  801bc2:	56                   	push   %esi
  801bc3:	53                   	push   %ebx
  801bc4:	83 ec 1c             	sub    $0x1c,%esp
  801bc7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bcb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bcf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bd3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bd7:	85 f6                	test   %esi,%esi
  801bd9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bdd:	89 ca                	mov    %ecx,%edx
  801bdf:	89 f8                	mov    %edi,%eax
  801be1:	75 3d                	jne    801c20 <__udivdi3+0x60>
  801be3:	39 cf                	cmp    %ecx,%edi
  801be5:	0f 87 c5 00 00 00    	ja     801cb0 <__udivdi3+0xf0>
  801beb:	85 ff                	test   %edi,%edi
  801bed:	89 fd                	mov    %edi,%ebp
  801bef:	75 0b                	jne    801bfc <__udivdi3+0x3c>
  801bf1:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf6:	31 d2                	xor    %edx,%edx
  801bf8:	f7 f7                	div    %edi
  801bfa:	89 c5                	mov    %eax,%ebp
  801bfc:	89 c8                	mov    %ecx,%eax
  801bfe:	31 d2                	xor    %edx,%edx
  801c00:	f7 f5                	div    %ebp
  801c02:	89 c1                	mov    %eax,%ecx
  801c04:	89 d8                	mov    %ebx,%eax
  801c06:	89 cf                	mov    %ecx,%edi
  801c08:	f7 f5                	div    %ebp
  801c0a:	89 c3                	mov    %eax,%ebx
  801c0c:	89 d8                	mov    %ebx,%eax
  801c0e:	89 fa                	mov    %edi,%edx
  801c10:	83 c4 1c             	add    $0x1c,%esp
  801c13:	5b                   	pop    %ebx
  801c14:	5e                   	pop    %esi
  801c15:	5f                   	pop    %edi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    
  801c18:	90                   	nop
  801c19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c20:	39 ce                	cmp    %ecx,%esi
  801c22:	77 74                	ja     801c98 <__udivdi3+0xd8>
  801c24:	0f bd fe             	bsr    %esi,%edi
  801c27:	83 f7 1f             	xor    $0x1f,%edi
  801c2a:	0f 84 98 00 00 00    	je     801cc8 <__udivdi3+0x108>
  801c30:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c35:	89 f9                	mov    %edi,%ecx
  801c37:	89 c5                	mov    %eax,%ebp
  801c39:	29 fb                	sub    %edi,%ebx
  801c3b:	d3 e6                	shl    %cl,%esi
  801c3d:	89 d9                	mov    %ebx,%ecx
  801c3f:	d3 ed                	shr    %cl,%ebp
  801c41:	89 f9                	mov    %edi,%ecx
  801c43:	d3 e0                	shl    %cl,%eax
  801c45:	09 ee                	or     %ebp,%esi
  801c47:	89 d9                	mov    %ebx,%ecx
  801c49:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c4d:	89 d5                	mov    %edx,%ebp
  801c4f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c53:	d3 ed                	shr    %cl,%ebp
  801c55:	89 f9                	mov    %edi,%ecx
  801c57:	d3 e2                	shl    %cl,%edx
  801c59:	89 d9                	mov    %ebx,%ecx
  801c5b:	d3 e8                	shr    %cl,%eax
  801c5d:	09 c2                	or     %eax,%edx
  801c5f:	89 d0                	mov    %edx,%eax
  801c61:	89 ea                	mov    %ebp,%edx
  801c63:	f7 f6                	div    %esi
  801c65:	89 d5                	mov    %edx,%ebp
  801c67:	89 c3                	mov    %eax,%ebx
  801c69:	f7 64 24 0c          	mull   0xc(%esp)
  801c6d:	39 d5                	cmp    %edx,%ebp
  801c6f:	72 10                	jb     801c81 <__udivdi3+0xc1>
  801c71:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c75:	89 f9                	mov    %edi,%ecx
  801c77:	d3 e6                	shl    %cl,%esi
  801c79:	39 c6                	cmp    %eax,%esi
  801c7b:	73 07                	jae    801c84 <__udivdi3+0xc4>
  801c7d:	39 d5                	cmp    %edx,%ebp
  801c7f:	75 03                	jne    801c84 <__udivdi3+0xc4>
  801c81:	83 eb 01             	sub    $0x1,%ebx
  801c84:	31 ff                	xor    %edi,%edi
  801c86:	89 d8                	mov    %ebx,%eax
  801c88:	89 fa                	mov    %edi,%edx
  801c8a:	83 c4 1c             	add    $0x1c,%esp
  801c8d:	5b                   	pop    %ebx
  801c8e:	5e                   	pop    %esi
  801c8f:	5f                   	pop    %edi
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    
  801c92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c98:	31 ff                	xor    %edi,%edi
  801c9a:	31 db                	xor    %ebx,%ebx
  801c9c:	89 d8                	mov    %ebx,%eax
  801c9e:	89 fa                	mov    %edi,%edx
  801ca0:	83 c4 1c             	add    $0x1c,%esp
  801ca3:	5b                   	pop    %ebx
  801ca4:	5e                   	pop    %esi
  801ca5:	5f                   	pop    %edi
  801ca6:	5d                   	pop    %ebp
  801ca7:	c3                   	ret    
  801ca8:	90                   	nop
  801ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cb0:	89 d8                	mov    %ebx,%eax
  801cb2:	f7 f7                	div    %edi
  801cb4:	31 ff                	xor    %edi,%edi
  801cb6:	89 c3                	mov    %eax,%ebx
  801cb8:	89 d8                	mov    %ebx,%eax
  801cba:	89 fa                	mov    %edi,%edx
  801cbc:	83 c4 1c             	add    $0x1c,%esp
  801cbf:	5b                   	pop    %ebx
  801cc0:	5e                   	pop    %esi
  801cc1:	5f                   	pop    %edi
  801cc2:	5d                   	pop    %ebp
  801cc3:	c3                   	ret    
  801cc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cc8:	39 ce                	cmp    %ecx,%esi
  801cca:	72 0c                	jb     801cd8 <__udivdi3+0x118>
  801ccc:	31 db                	xor    %ebx,%ebx
  801cce:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cd2:	0f 87 34 ff ff ff    	ja     801c0c <__udivdi3+0x4c>
  801cd8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801cdd:	e9 2a ff ff ff       	jmp    801c0c <__udivdi3+0x4c>
  801ce2:	66 90                	xchg   %ax,%ax
  801ce4:	66 90                	xchg   %ax,%ax
  801ce6:	66 90                	xchg   %ax,%ax
  801ce8:	66 90                	xchg   %ax,%ax
  801cea:	66 90                	xchg   %ax,%ax
  801cec:	66 90                	xchg   %ax,%ax
  801cee:	66 90                	xchg   %ax,%ax

00801cf0 <__umoddi3>:
  801cf0:	55                   	push   %ebp
  801cf1:	57                   	push   %edi
  801cf2:	56                   	push   %esi
  801cf3:	53                   	push   %ebx
  801cf4:	83 ec 1c             	sub    $0x1c,%esp
  801cf7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801cfb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cff:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d07:	85 d2                	test   %edx,%edx
  801d09:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801d0d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d11:	89 f3                	mov    %esi,%ebx
  801d13:	89 3c 24             	mov    %edi,(%esp)
  801d16:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d1a:	75 1c                	jne    801d38 <__umoddi3+0x48>
  801d1c:	39 f7                	cmp    %esi,%edi
  801d1e:	76 50                	jbe    801d70 <__umoddi3+0x80>
  801d20:	89 c8                	mov    %ecx,%eax
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	f7 f7                	div    %edi
  801d26:	89 d0                	mov    %edx,%eax
  801d28:	31 d2                	xor    %edx,%edx
  801d2a:	83 c4 1c             	add    $0x1c,%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5f                   	pop    %edi
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    
  801d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d38:	39 f2                	cmp    %esi,%edx
  801d3a:	89 d0                	mov    %edx,%eax
  801d3c:	77 52                	ja     801d90 <__umoddi3+0xa0>
  801d3e:	0f bd ea             	bsr    %edx,%ebp
  801d41:	83 f5 1f             	xor    $0x1f,%ebp
  801d44:	75 5a                	jne    801da0 <__umoddi3+0xb0>
  801d46:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d4a:	0f 82 e0 00 00 00    	jb     801e30 <__umoddi3+0x140>
  801d50:	39 0c 24             	cmp    %ecx,(%esp)
  801d53:	0f 86 d7 00 00 00    	jbe    801e30 <__umoddi3+0x140>
  801d59:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d5d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d61:	83 c4 1c             	add    $0x1c,%esp
  801d64:	5b                   	pop    %ebx
  801d65:	5e                   	pop    %esi
  801d66:	5f                   	pop    %edi
  801d67:	5d                   	pop    %ebp
  801d68:	c3                   	ret    
  801d69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d70:	85 ff                	test   %edi,%edi
  801d72:	89 fd                	mov    %edi,%ebp
  801d74:	75 0b                	jne    801d81 <__umoddi3+0x91>
  801d76:	b8 01 00 00 00       	mov    $0x1,%eax
  801d7b:	31 d2                	xor    %edx,%edx
  801d7d:	f7 f7                	div    %edi
  801d7f:	89 c5                	mov    %eax,%ebp
  801d81:	89 f0                	mov    %esi,%eax
  801d83:	31 d2                	xor    %edx,%edx
  801d85:	f7 f5                	div    %ebp
  801d87:	89 c8                	mov    %ecx,%eax
  801d89:	f7 f5                	div    %ebp
  801d8b:	89 d0                	mov    %edx,%eax
  801d8d:	eb 99                	jmp    801d28 <__umoddi3+0x38>
  801d8f:	90                   	nop
  801d90:	89 c8                	mov    %ecx,%eax
  801d92:	89 f2                	mov    %esi,%edx
  801d94:	83 c4 1c             	add    $0x1c,%esp
  801d97:	5b                   	pop    %ebx
  801d98:	5e                   	pop    %esi
  801d99:	5f                   	pop    %edi
  801d9a:	5d                   	pop    %ebp
  801d9b:	c3                   	ret    
  801d9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801da0:	8b 34 24             	mov    (%esp),%esi
  801da3:	bf 20 00 00 00       	mov    $0x20,%edi
  801da8:	89 e9                	mov    %ebp,%ecx
  801daa:	29 ef                	sub    %ebp,%edi
  801dac:	d3 e0                	shl    %cl,%eax
  801dae:	89 f9                	mov    %edi,%ecx
  801db0:	89 f2                	mov    %esi,%edx
  801db2:	d3 ea                	shr    %cl,%edx
  801db4:	89 e9                	mov    %ebp,%ecx
  801db6:	09 c2                	or     %eax,%edx
  801db8:	89 d8                	mov    %ebx,%eax
  801dba:	89 14 24             	mov    %edx,(%esp)
  801dbd:	89 f2                	mov    %esi,%edx
  801dbf:	d3 e2                	shl    %cl,%edx
  801dc1:	89 f9                	mov    %edi,%ecx
  801dc3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801dc7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dcb:	d3 e8                	shr    %cl,%eax
  801dcd:	89 e9                	mov    %ebp,%ecx
  801dcf:	89 c6                	mov    %eax,%esi
  801dd1:	d3 e3                	shl    %cl,%ebx
  801dd3:	89 f9                	mov    %edi,%ecx
  801dd5:	89 d0                	mov    %edx,%eax
  801dd7:	d3 e8                	shr    %cl,%eax
  801dd9:	89 e9                	mov    %ebp,%ecx
  801ddb:	09 d8                	or     %ebx,%eax
  801ddd:	89 d3                	mov    %edx,%ebx
  801ddf:	89 f2                	mov    %esi,%edx
  801de1:	f7 34 24             	divl   (%esp)
  801de4:	89 d6                	mov    %edx,%esi
  801de6:	d3 e3                	shl    %cl,%ebx
  801de8:	f7 64 24 04          	mull   0x4(%esp)
  801dec:	39 d6                	cmp    %edx,%esi
  801dee:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801df2:	89 d1                	mov    %edx,%ecx
  801df4:	89 c3                	mov    %eax,%ebx
  801df6:	72 08                	jb     801e00 <__umoddi3+0x110>
  801df8:	75 11                	jne    801e0b <__umoddi3+0x11b>
  801dfa:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dfe:	73 0b                	jae    801e0b <__umoddi3+0x11b>
  801e00:	2b 44 24 04          	sub    0x4(%esp),%eax
  801e04:	1b 14 24             	sbb    (%esp),%edx
  801e07:	89 d1                	mov    %edx,%ecx
  801e09:	89 c3                	mov    %eax,%ebx
  801e0b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801e0f:	29 da                	sub    %ebx,%edx
  801e11:	19 ce                	sbb    %ecx,%esi
  801e13:	89 f9                	mov    %edi,%ecx
  801e15:	89 f0                	mov    %esi,%eax
  801e17:	d3 e0                	shl    %cl,%eax
  801e19:	89 e9                	mov    %ebp,%ecx
  801e1b:	d3 ea                	shr    %cl,%edx
  801e1d:	89 e9                	mov    %ebp,%ecx
  801e1f:	d3 ee                	shr    %cl,%esi
  801e21:	09 d0                	or     %edx,%eax
  801e23:	89 f2                	mov    %esi,%edx
  801e25:	83 c4 1c             	add    $0x1c,%esp
  801e28:	5b                   	pop    %ebx
  801e29:	5e                   	pop    %esi
  801e2a:	5f                   	pop    %edi
  801e2b:	5d                   	pop    %ebp
  801e2c:	c3                   	ret    
  801e2d:	8d 76 00             	lea    0x0(%esi),%esi
  801e30:	29 f9                	sub    %edi,%ecx
  801e32:	19 d6                	sbb    %edx,%esi
  801e34:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e38:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e3c:	e9 18 ff ff ff       	jmp    801d59 <__umoddi3+0x69>
