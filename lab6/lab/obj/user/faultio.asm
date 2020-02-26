
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
  800043:	68 00 23 80 00       	push   $0x802300
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
  80005e:	68 0e 23 80 00       	push   $0x80230e
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
  80008a:	a3 08 40 80 00       	mov    %eax,0x804008

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
  8000b9:	e8 a4 0e 00 00       	call   800f62 <close_all>
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
  8001c3:	e8 98 1e 00 00       	call   802060 <__udivdi3>
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
  800206:	e8 85 1f 00 00       	call   802190 <__umoddi3>
  80020b:	83 c4 14             	add    $0x14,%esp
  80020e:	0f be 80 32 23 80 00 	movsbl 0x802332(%eax),%eax
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
  8002d0:	ff 24 85 80 24 80 00 	jmp    *0x802480(,%eax,4)
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
  800397:	8b 14 85 e0 25 80 00 	mov    0x8025e0(,%eax,4),%edx
  80039e:	85 d2                	test   %edx,%edx
  8003a0:	75 1b                	jne    8003bd <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003a2:	50                   	push   %eax
  8003a3:	68 4a 23 80 00       	push   $0x80234a
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
  8003be:	68 15 27 80 00       	push   $0x802715
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
  8003e8:	b8 43 23 80 00       	mov    $0x802343,%eax
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
  800b10:	68 3f 26 80 00       	push   $0x80263f
  800b15:	6a 23                	push   $0x23
  800b17:	68 5c 26 80 00       	push   $0x80265c
  800b1c:	e8 c7 13 00 00       	call   801ee8 <_panic>

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
  800b91:	68 3f 26 80 00       	push   $0x80263f
  800b96:	6a 23                	push   $0x23
  800b98:	68 5c 26 80 00       	push   $0x80265c
  800b9d:	e8 46 13 00 00       	call   801ee8 <_panic>

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
  800bd3:	68 3f 26 80 00       	push   $0x80263f
  800bd8:	6a 23                	push   $0x23
  800bda:	68 5c 26 80 00       	push   $0x80265c
  800bdf:	e8 04 13 00 00       	call   801ee8 <_panic>

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
  800c15:	68 3f 26 80 00       	push   $0x80263f
  800c1a:	6a 23                	push   $0x23
  800c1c:	68 5c 26 80 00       	push   $0x80265c
  800c21:	e8 c2 12 00 00       	call   801ee8 <_panic>

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
  800c57:	68 3f 26 80 00       	push   $0x80263f
  800c5c:	6a 23                	push   $0x23
  800c5e:	68 5c 26 80 00       	push   $0x80265c
  800c63:	e8 80 12 00 00       	call   801ee8 <_panic>

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
  800c99:	68 3f 26 80 00       	push   $0x80263f
  800c9e:	6a 23                	push   $0x23
  800ca0:	68 5c 26 80 00       	push   $0x80265c
  800ca5:	e8 3e 12 00 00       	call   801ee8 <_panic>

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
  800cdb:	68 3f 26 80 00       	push   $0x80263f
  800ce0:	6a 23                	push   $0x23
  800ce2:	68 5c 26 80 00       	push   $0x80265c
  800ce7:	e8 fc 11 00 00       	call   801ee8 <_panic>

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
  800d3f:	68 3f 26 80 00       	push   $0x80263f
  800d44:	6a 23                	push   $0x23
  800d46:	68 5c 26 80 00       	push   $0x80265c
  800d4b:	e8 98 11 00 00       	call   801ee8 <_panic>

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

00800d58 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	57                   	push   %edi
  800d5c:	56                   	push   %esi
  800d5d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800d63:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d68:	89 d1                	mov    %edx,%ecx
  800d6a:	89 d3                	mov    %edx,%ebx
  800d6c:	89 d7                	mov    %edx,%edi
  800d6e:	89 d6                	mov    %edx,%esi
  800d70:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d72:	5b                   	pop    %ebx
  800d73:	5e                   	pop    %esi
  800d74:	5f                   	pop    %edi
  800d75:	5d                   	pop    %ebp
  800d76:	c3                   	ret    

00800d77 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800d77:	55                   	push   %ebp
  800d78:	89 e5                	mov    %esp,%ebp
  800d7a:	57                   	push   %edi
  800d7b:	56                   	push   %esi
  800d7c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d82:	b8 10 00 00 00       	mov    $0x10,%eax
  800d87:	8b 55 08             	mov    0x8(%ebp),%edx
  800d8a:	89 cb                	mov    %ecx,%ebx
  800d8c:	89 cf                	mov    %ecx,%edi
  800d8e:	89 ce                	mov    %ecx,%esi
  800d90:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800d92:	5b                   	pop    %ebx
  800d93:	5e                   	pop    %esi
  800d94:	5f                   	pop    %edi
  800d95:	5d                   	pop    %ebp
  800d96:	c3                   	ret    

00800d97 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d97:	55                   	push   %ebp
  800d98:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d9a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9d:	05 00 00 00 30       	add    $0x30000000,%eax
  800da2:	c1 e8 0c             	shr    $0xc,%eax
}
  800da5:	5d                   	pop    %ebp
  800da6:	c3                   	ret    

00800da7 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800daa:	8b 45 08             	mov    0x8(%ebp),%eax
  800dad:	05 00 00 00 30       	add    $0x30000000,%eax
  800db2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800db7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    

00800dbe <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dc4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dc9:	89 c2                	mov    %eax,%edx
  800dcb:	c1 ea 16             	shr    $0x16,%edx
  800dce:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dd5:	f6 c2 01             	test   $0x1,%dl
  800dd8:	74 11                	je     800deb <fd_alloc+0x2d>
  800dda:	89 c2                	mov    %eax,%edx
  800ddc:	c1 ea 0c             	shr    $0xc,%edx
  800ddf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800de6:	f6 c2 01             	test   $0x1,%dl
  800de9:	75 09                	jne    800df4 <fd_alloc+0x36>
			*fd_store = fd;
  800deb:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ded:	b8 00 00 00 00       	mov    $0x0,%eax
  800df2:	eb 17                	jmp    800e0b <fd_alloc+0x4d>
  800df4:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800df9:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800dfe:	75 c9                	jne    800dc9 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e00:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e06:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e0b:	5d                   	pop    %ebp
  800e0c:	c3                   	ret    

00800e0d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e13:	83 f8 1f             	cmp    $0x1f,%eax
  800e16:	77 36                	ja     800e4e <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e18:	c1 e0 0c             	shl    $0xc,%eax
  800e1b:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e20:	89 c2                	mov    %eax,%edx
  800e22:	c1 ea 16             	shr    $0x16,%edx
  800e25:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e2c:	f6 c2 01             	test   $0x1,%dl
  800e2f:	74 24                	je     800e55 <fd_lookup+0x48>
  800e31:	89 c2                	mov    %eax,%edx
  800e33:	c1 ea 0c             	shr    $0xc,%edx
  800e36:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e3d:	f6 c2 01             	test   $0x1,%dl
  800e40:	74 1a                	je     800e5c <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e42:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e45:	89 02                	mov    %eax,(%edx)
	return 0;
  800e47:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4c:	eb 13                	jmp    800e61 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e4e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e53:	eb 0c                	jmp    800e61 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e55:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e5a:	eb 05                	jmp    800e61 <fd_lookup+0x54>
  800e5c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e61:	5d                   	pop    %ebp
  800e62:	c3                   	ret    

00800e63 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e63:	55                   	push   %ebp
  800e64:	89 e5                	mov    %esp,%ebp
  800e66:	83 ec 08             	sub    $0x8,%esp
  800e69:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e6c:	ba e8 26 80 00       	mov    $0x8026e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e71:	eb 13                	jmp    800e86 <dev_lookup+0x23>
  800e73:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e76:	39 08                	cmp    %ecx,(%eax)
  800e78:	75 0c                	jne    800e86 <dev_lookup+0x23>
			*dev = devtab[i];
  800e7a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e84:	eb 2e                	jmp    800eb4 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e86:	8b 02                	mov    (%edx),%eax
  800e88:	85 c0                	test   %eax,%eax
  800e8a:	75 e7                	jne    800e73 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e8c:	a1 08 40 80 00       	mov    0x804008,%eax
  800e91:	8b 40 48             	mov    0x48(%eax),%eax
  800e94:	83 ec 04             	sub    $0x4,%esp
  800e97:	51                   	push   %ecx
  800e98:	50                   	push   %eax
  800e99:	68 6c 26 80 00       	push   $0x80266c
  800e9e:	e8 bd f2 ff ff       	call   800160 <cprintf>
	*dev = 0;
  800ea3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800eac:	83 c4 10             	add    $0x10,%esp
  800eaf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800eb4:	c9                   	leave  
  800eb5:	c3                   	ret    

00800eb6 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	56                   	push   %esi
  800eba:	53                   	push   %ebx
  800ebb:	83 ec 10             	sub    $0x10,%esp
  800ebe:	8b 75 08             	mov    0x8(%ebp),%esi
  800ec1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ec4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ec7:	50                   	push   %eax
  800ec8:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ece:	c1 e8 0c             	shr    $0xc,%eax
  800ed1:	50                   	push   %eax
  800ed2:	e8 36 ff ff ff       	call   800e0d <fd_lookup>
  800ed7:	83 c4 08             	add    $0x8,%esp
  800eda:	85 c0                	test   %eax,%eax
  800edc:	78 05                	js     800ee3 <fd_close+0x2d>
	    || fd != fd2)
  800ede:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ee1:	74 0c                	je     800eef <fd_close+0x39>
		return (must_exist ? r : 0);
  800ee3:	84 db                	test   %bl,%bl
  800ee5:	ba 00 00 00 00       	mov    $0x0,%edx
  800eea:	0f 44 c2             	cmove  %edx,%eax
  800eed:	eb 41                	jmp    800f30 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800eef:	83 ec 08             	sub    $0x8,%esp
  800ef2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ef5:	50                   	push   %eax
  800ef6:	ff 36                	pushl  (%esi)
  800ef8:	e8 66 ff ff ff       	call   800e63 <dev_lookup>
  800efd:	89 c3                	mov    %eax,%ebx
  800eff:	83 c4 10             	add    $0x10,%esp
  800f02:	85 c0                	test   %eax,%eax
  800f04:	78 1a                	js     800f20 <fd_close+0x6a>
		if (dev->dev_close)
  800f06:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f09:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f0c:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f11:	85 c0                	test   %eax,%eax
  800f13:	74 0b                	je     800f20 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f15:	83 ec 0c             	sub    $0xc,%esp
  800f18:	56                   	push   %esi
  800f19:	ff d0                	call   *%eax
  800f1b:	89 c3                	mov    %eax,%ebx
  800f1d:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f20:	83 ec 08             	sub    $0x8,%esp
  800f23:	56                   	push   %esi
  800f24:	6a 00                	push   $0x0
  800f26:	e8 c1 fc ff ff       	call   800bec <sys_page_unmap>
	return r;
  800f2b:	83 c4 10             	add    $0x10,%esp
  800f2e:	89 d8                	mov    %ebx,%eax
}
  800f30:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f33:	5b                   	pop    %ebx
  800f34:	5e                   	pop    %esi
  800f35:	5d                   	pop    %ebp
  800f36:	c3                   	ret    

00800f37 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f37:	55                   	push   %ebp
  800f38:	89 e5                	mov    %esp,%ebp
  800f3a:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f40:	50                   	push   %eax
  800f41:	ff 75 08             	pushl  0x8(%ebp)
  800f44:	e8 c4 fe ff ff       	call   800e0d <fd_lookup>
  800f49:	83 c4 08             	add    $0x8,%esp
  800f4c:	85 c0                	test   %eax,%eax
  800f4e:	78 10                	js     800f60 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f50:	83 ec 08             	sub    $0x8,%esp
  800f53:	6a 01                	push   $0x1
  800f55:	ff 75 f4             	pushl  -0xc(%ebp)
  800f58:	e8 59 ff ff ff       	call   800eb6 <fd_close>
  800f5d:	83 c4 10             	add    $0x10,%esp
}
  800f60:	c9                   	leave  
  800f61:	c3                   	ret    

00800f62 <close_all>:

void
close_all(void)
{
  800f62:	55                   	push   %ebp
  800f63:	89 e5                	mov    %esp,%ebp
  800f65:	53                   	push   %ebx
  800f66:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f69:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f6e:	83 ec 0c             	sub    $0xc,%esp
  800f71:	53                   	push   %ebx
  800f72:	e8 c0 ff ff ff       	call   800f37 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f77:	83 c3 01             	add    $0x1,%ebx
  800f7a:	83 c4 10             	add    $0x10,%esp
  800f7d:	83 fb 20             	cmp    $0x20,%ebx
  800f80:	75 ec                	jne    800f6e <close_all+0xc>
		close(i);
}
  800f82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f85:	c9                   	leave  
  800f86:	c3                   	ret    

00800f87 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f87:	55                   	push   %ebp
  800f88:	89 e5                	mov    %esp,%ebp
  800f8a:	57                   	push   %edi
  800f8b:	56                   	push   %esi
  800f8c:	53                   	push   %ebx
  800f8d:	83 ec 2c             	sub    $0x2c,%esp
  800f90:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f93:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f96:	50                   	push   %eax
  800f97:	ff 75 08             	pushl  0x8(%ebp)
  800f9a:	e8 6e fe ff ff       	call   800e0d <fd_lookup>
  800f9f:	83 c4 08             	add    $0x8,%esp
  800fa2:	85 c0                	test   %eax,%eax
  800fa4:	0f 88 c1 00 00 00    	js     80106b <dup+0xe4>
		return r;
	close(newfdnum);
  800faa:	83 ec 0c             	sub    $0xc,%esp
  800fad:	56                   	push   %esi
  800fae:	e8 84 ff ff ff       	call   800f37 <close>

	newfd = INDEX2FD(newfdnum);
  800fb3:	89 f3                	mov    %esi,%ebx
  800fb5:	c1 e3 0c             	shl    $0xc,%ebx
  800fb8:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fbe:	83 c4 04             	add    $0x4,%esp
  800fc1:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fc4:	e8 de fd ff ff       	call   800da7 <fd2data>
  800fc9:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fcb:	89 1c 24             	mov    %ebx,(%esp)
  800fce:	e8 d4 fd ff ff       	call   800da7 <fd2data>
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fd9:	89 f8                	mov    %edi,%eax
  800fdb:	c1 e8 16             	shr    $0x16,%eax
  800fde:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fe5:	a8 01                	test   $0x1,%al
  800fe7:	74 37                	je     801020 <dup+0x99>
  800fe9:	89 f8                	mov    %edi,%eax
  800feb:	c1 e8 0c             	shr    $0xc,%eax
  800fee:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800ff5:	f6 c2 01             	test   $0x1,%dl
  800ff8:	74 26                	je     801020 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800ffa:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801001:	83 ec 0c             	sub    $0xc,%esp
  801004:	25 07 0e 00 00       	and    $0xe07,%eax
  801009:	50                   	push   %eax
  80100a:	ff 75 d4             	pushl  -0x2c(%ebp)
  80100d:	6a 00                	push   $0x0
  80100f:	57                   	push   %edi
  801010:	6a 00                	push   $0x0
  801012:	e8 93 fb ff ff       	call   800baa <sys_page_map>
  801017:	89 c7                	mov    %eax,%edi
  801019:	83 c4 20             	add    $0x20,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	78 2e                	js     80104e <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801020:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801023:	89 d0                	mov    %edx,%eax
  801025:	c1 e8 0c             	shr    $0xc,%eax
  801028:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80102f:	83 ec 0c             	sub    $0xc,%esp
  801032:	25 07 0e 00 00       	and    $0xe07,%eax
  801037:	50                   	push   %eax
  801038:	53                   	push   %ebx
  801039:	6a 00                	push   $0x0
  80103b:	52                   	push   %edx
  80103c:	6a 00                	push   $0x0
  80103e:	e8 67 fb ff ff       	call   800baa <sys_page_map>
  801043:	89 c7                	mov    %eax,%edi
  801045:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801048:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80104a:	85 ff                	test   %edi,%edi
  80104c:	79 1d                	jns    80106b <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80104e:	83 ec 08             	sub    $0x8,%esp
  801051:	53                   	push   %ebx
  801052:	6a 00                	push   $0x0
  801054:	e8 93 fb ff ff       	call   800bec <sys_page_unmap>
	sys_page_unmap(0, nva);
  801059:	83 c4 08             	add    $0x8,%esp
  80105c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80105f:	6a 00                	push   $0x0
  801061:	e8 86 fb ff ff       	call   800bec <sys_page_unmap>
	return r;
  801066:	83 c4 10             	add    $0x10,%esp
  801069:	89 f8                	mov    %edi,%eax
}
  80106b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80106e:	5b                   	pop    %ebx
  80106f:	5e                   	pop    %esi
  801070:	5f                   	pop    %edi
  801071:	5d                   	pop    %ebp
  801072:	c3                   	ret    

00801073 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	53                   	push   %ebx
  801077:	83 ec 14             	sub    $0x14,%esp
  80107a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80107d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801080:	50                   	push   %eax
  801081:	53                   	push   %ebx
  801082:	e8 86 fd ff ff       	call   800e0d <fd_lookup>
  801087:	83 c4 08             	add    $0x8,%esp
  80108a:	89 c2                	mov    %eax,%edx
  80108c:	85 c0                	test   %eax,%eax
  80108e:	78 6d                	js     8010fd <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801090:	83 ec 08             	sub    $0x8,%esp
  801093:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801096:	50                   	push   %eax
  801097:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80109a:	ff 30                	pushl  (%eax)
  80109c:	e8 c2 fd ff ff       	call   800e63 <dev_lookup>
  8010a1:	83 c4 10             	add    $0x10,%esp
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	78 4c                	js     8010f4 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010ab:	8b 42 08             	mov    0x8(%edx),%eax
  8010ae:	83 e0 03             	and    $0x3,%eax
  8010b1:	83 f8 01             	cmp    $0x1,%eax
  8010b4:	75 21                	jne    8010d7 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010b6:	a1 08 40 80 00       	mov    0x804008,%eax
  8010bb:	8b 40 48             	mov    0x48(%eax),%eax
  8010be:	83 ec 04             	sub    $0x4,%esp
  8010c1:	53                   	push   %ebx
  8010c2:	50                   	push   %eax
  8010c3:	68 ad 26 80 00       	push   $0x8026ad
  8010c8:	e8 93 f0 ff ff       	call   800160 <cprintf>
		return -E_INVAL;
  8010cd:	83 c4 10             	add    $0x10,%esp
  8010d0:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010d5:	eb 26                	jmp    8010fd <read+0x8a>
	}
	if (!dev->dev_read)
  8010d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010da:	8b 40 08             	mov    0x8(%eax),%eax
  8010dd:	85 c0                	test   %eax,%eax
  8010df:	74 17                	je     8010f8 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010e1:	83 ec 04             	sub    $0x4,%esp
  8010e4:	ff 75 10             	pushl  0x10(%ebp)
  8010e7:	ff 75 0c             	pushl  0xc(%ebp)
  8010ea:	52                   	push   %edx
  8010eb:	ff d0                	call   *%eax
  8010ed:	89 c2                	mov    %eax,%edx
  8010ef:	83 c4 10             	add    $0x10,%esp
  8010f2:	eb 09                	jmp    8010fd <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010f4:	89 c2                	mov    %eax,%edx
  8010f6:	eb 05                	jmp    8010fd <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010f8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010fd:	89 d0                	mov    %edx,%eax
  8010ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801102:	c9                   	leave  
  801103:	c3                   	ret    

00801104 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	57                   	push   %edi
  801108:	56                   	push   %esi
  801109:	53                   	push   %ebx
  80110a:	83 ec 0c             	sub    $0xc,%esp
  80110d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801110:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801113:	bb 00 00 00 00       	mov    $0x0,%ebx
  801118:	eb 21                	jmp    80113b <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80111a:	83 ec 04             	sub    $0x4,%esp
  80111d:	89 f0                	mov    %esi,%eax
  80111f:	29 d8                	sub    %ebx,%eax
  801121:	50                   	push   %eax
  801122:	89 d8                	mov    %ebx,%eax
  801124:	03 45 0c             	add    0xc(%ebp),%eax
  801127:	50                   	push   %eax
  801128:	57                   	push   %edi
  801129:	e8 45 ff ff ff       	call   801073 <read>
		if (m < 0)
  80112e:	83 c4 10             	add    $0x10,%esp
  801131:	85 c0                	test   %eax,%eax
  801133:	78 10                	js     801145 <readn+0x41>
			return m;
		if (m == 0)
  801135:	85 c0                	test   %eax,%eax
  801137:	74 0a                	je     801143 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801139:	01 c3                	add    %eax,%ebx
  80113b:	39 f3                	cmp    %esi,%ebx
  80113d:	72 db                	jb     80111a <readn+0x16>
  80113f:	89 d8                	mov    %ebx,%eax
  801141:	eb 02                	jmp    801145 <readn+0x41>
  801143:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801145:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801148:	5b                   	pop    %ebx
  801149:	5e                   	pop    %esi
  80114a:	5f                   	pop    %edi
  80114b:	5d                   	pop    %ebp
  80114c:	c3                   	ret    

0080114d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80114d:	55                   	push   %ebp
  80114e:	89 e5                	mov    %esp,%ebp
  801150:	53                   	push   %ebx
  801151:	83 ec 14             	sub    $0x14,%esp
  801154:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801157:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80115a:	50                   	push   %eax
  80115b:	53                   	push   %ebx
  80115c:	e8 ac fc ff ff       	call   800e0d <fd_lookup>
  801161:	83 c4 08             	add    $0x8,%esp
  801164:	89 c2                	mov    %eax,%edx
  801166:	85 c0                	test   %eax,%eax
  801168:	78 68                	js     8011d2 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80116a:	83 ec 08             	sub    $0x8,%esp
  80116d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801170:	50                   	push   %eax
  801171:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801174:	ff 30                	pushl  (%eax)
  801176:	e8 e8 fc ff ff       	call   800e63 <dev_lookup>
  80117b:	83 c4 10             	add    $0x10,%esp
  80117e:	85 c0                	test   %eax,%eax
  801180:	78 47                	js     8011c9 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801182:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801185:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801189:	75 21                	jne    8011ac <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80118b:	a1 08 40 80 00       	mov    0x804008,%eax
  801190:	8b 40 48             	mov    0x48(%eax),%eax
  801193:	83 ec 04             	sub    $0x4,%esp
  801196:	53                   	push   %ebx
  801197:	50                   	push   %eax
  801198:	68 c9 26 80 00       	push   $0x8026c9
  80119d:	e8 be ef ff ff       	call   800160 <cprintf>
		return -E_INVAL;
  8011a2:	83 c4 10             	add    $0x10,%esp
  8011a5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011aa:	eb 26                	jmp    8011d2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011af:	8b 52 0c             	mov    0xc(%edx),%edx
  8011b2:	85 d2                	test   %edx,%edx
  8011b4:	74 17                	je     8011cd <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011b6:	83 ec 04             	sub    $0x4,%esp
  8011b9:	ff 75 10             	pushl  0x10(%ebp)
  8011bc:	ff 75 0c             	pushl  0xc(%ebp)
  8011bf:	50                   	push   %eax
  8011c0:	ff d2                	call   *%edx
  8011c2:	89 c2                	mov    %eax,%edx
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	eb 09                	jmp    8011d2 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c9:	89 c2                	mov    %eax,%edx
  8011cb:	eb 05                	jmp    8011d2 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011cd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011d2:	89 d0                	mov    %edx,%eax
  8011d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011d7:	c9                   	leave  
  8011d8:	c3                   	ret    

008011d9 <seek>:

int
seek(int fdnum, off_t offset)
{
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011df:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011e2:	50                   	push   %eax
  8011e3:	ff 75 08             	pushl  0x8(%ebp)
  8011e6:	e8 22 fc ff ff       	call   800e0d <fd_lookup>
  8011eb:	83 c4 08             	add    $0x8,%esp
  8011ee:	85 c0                	test   %eax,%eax
  8011f0:	78 0e                	js     801200 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011f2:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011f8:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801200:	c9                   	leave  
  801201:	c3                   	ret    

00801202 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801202:	55                   	push   %ebp
  801203:	89 e5                	mov    %esp,%ebp
  801205:	53                   	push   %ebx
  801206:	83 ec 14             	sub    $0x14,%esp
  801209:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80120c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80120f:	50                   	push   %eax
  801210:	53                   	push   %ebx
  801211:	e8 f7 fb ff ff       	call   800e0d <fd_lookup>
  801216:	83 c4 08             	add    $0x8,%esp
  801219:	89 c2                	mov    %eax,%edx
  80121b:	85 c0                	test   %eax,%eax
  80121d:	78 65                	js     801284 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80121f:	83 ec 08             	sub    $0x8,%esp
  801222:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801225:	50                   	push   %eax
  801226:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801229:	ff 30                	pushl  (%eax)
  80122b:	e8 33 fc ff ff       	call   800e63 <dev_lookup>
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	85 c0                	test   %eax,%eax
  801235:	78 44                	js     80127b <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801237:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80123a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80123e:	75 21                	jne    801261 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801240:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801245:	8b 40 48             	mov    0x48(%eax),%eax
  801248:	83 ec 04             	sub    $0x4,%esp
  80124b:	53                   	push   %ebx
  80124c:	50                   	push   %eax
  80124d:	68 8c 26 80 00       	push   $0x80268c
  801252:	e8 09 ef ff ff       	call   800160 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801257:	83 c4 10             	add    $0x10,%esp
  80125a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80125f:	eb 23                	jmp    801284 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801261:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801264:	8b 52 18             	mov    0x18(%edx),%edx
  801267:	85 d2                	test   %edx,%edx
  801269:	74 14                	je     80127f <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80126b:	83 ec 08             	sub    $0x8,%esp
  80126e:	ff 75 0c             	pushl  0xc(%ebp)
  801271:	50                   	push   %eax
  801272:	ff d2                	call   *%edx
  801274:	89 c2                	mov    %eax,%edx
  801276:	83 c4 10             	add    $0x10,%esp
  801279:	eb 09                	jmp    801284 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127b:	89 c2                	mov    %eax,%edx
  80127d:	eb 05                	jmp    801284 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80127f:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801284:	89 d0                	mov    %edx,%eax
  801286:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801289:	c9                   	leave  
  80128a:	c3                   	ret    

0080128b <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	53                   	push   %ebx
  80128f:	83 ec 14             	sub    $0x14,%esp
  801292:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801295:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801298:	50                   	push   %eax
  801299:	ff 75 08             	pushl  0x8(%ebp)
  80129c:	e8 6c fb ff ff       	call   800e0d <fd_lookup>
  8012a1:	83 c4 08             	add    $0x8,%esp
  8012a4:	89 c2                	mov    %eax,%edx
  8012a6:	85 c0                	test   %eax,%eax
  8012a8:	78 58                	js     801302 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012aa:	83 ec 08             	sub    $0x8,%esp
  8012ad:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012b0:	50                   	push   %eax
  8012b1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012b4:	ff 30                	pushl  (%eax)
  8012b6:	e8 a8 fb ff ff       	call   800e63 <dev_lookup>
  8012bb:	83 c4 10             	add    $0x10,%esp
  8012be:	85 c0                	test   %eax,%eax
  8012c0:	78 37                	js     8012f9 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012c5:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012c9:	74 32                	je     8012fd <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012cb:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012ce:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012d5:	00 00 00 
	stat->st_isdir = 0;
  8012d8:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012df:	00 00 00 
	stat->st_dev = dev;
  8012e2:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012e8:	83 ec 08             	sub    $0x8,%esp
  8012eb:	53                   	push   %ebx
  8012ec:	ff 75 f0             	pushl  -0x10(%ebp)
  8012ef:	ff 50 14             	call   *0x14(%eax)
  8012f2:	89 c2                	mov    %eax,%edx
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	eb 09                	jmp    801302 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f9:	89 c2                	mov    %eax,%edx
  8012fb:	eb 05                	jmp    801302 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012fd:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801302:	89 d0                	mov    %edx,%eax
  801304:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801307:	c9                   	leave  
  801308:	c3                   	ret    

00801309 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801309:	55                   	push   %ebp
  80130a:	89 e5                	mov    %esp,%ebp
  80130c:	56                   	push   %esi
  80130d:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80130e:	83 ec 08             	sub    $0x8,%esp
  801311:	6a 00                	push   $0x0
  801313:	ff 75 08             	pushl  0x8(%ebp)
  801316:	e8 e3 01 00 00       	call   8014fe <open>
  80131b:	89 c3                	mov    %eax,%ebx
  80131d:	83 c4 10             	add    $0x10,%esp
  801320:	85 c0                	test   %eax,%eax
  801322:	78 1b                	js     80133f <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801324:	83 ec 08             	sub    $0x8,%esp
  801327:	ff 75 0c             	pushl  0xc(%ebp)
  80132a:	50                   	push   %eax
  80132b:	e8 5b ff ff ff       	call   80128b <fstat>
  801330:	89 c6                	mov    %eax,%esi
	close(fd);
  801332:	89 1c 24             	mov    %ebx,(%esp)
  801335:	e8 fd fb ff ff       	call   800f37 <close>
	return r;
  80133a:	83 c4 10             	add    $0x10,%esp
  80133d:	89 f0                	mov    %esi,%eax
}
  80133f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801342:	5b                   	pop    %ebx
  801343:	5e                   	pop    %esi
  801344:	5d                   	pop    %ebp
  801345:	c3                   	ret    

00801346 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801346:	55                   	push   %ebp
  801347:	89 e5                	mov    %esp,%ebp
  801349:	56                   	push   %esi
  80134a:	53                   	push   %ebx
  80134b:	89 c6                	mov    %eax,%esi
  80134d:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80134f:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801356:	75 12                	jne    80136a <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801358:	83 ec 0c             	sub    $0xc,%esp
  80135b:	6a 01                	push   $0x1
  80135d:	e8 89 0c 00 00       	call   801feb <ipc_find_env>
  801362:	a3 00 40 80 00       	mov    %eax,0x804000
  801367:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80136a:	6a 07                	push   $0x7
  80136c:	68 00 50 80 00       	push   $0x805000
  801371:	56                   	push   %esi
  801372:	ff 35 00 40 80 00    	pushl  0x804000
  801378:	e8 1a 0c 00 00       	call   801f97 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80137d:	83 c4 0c             	add    $0xc,%esp
  801380:	6a 00                	push   $0x0
  801382:	53                   	push   %ebx
  801383:	6a 00                	push   $0x0
  801385:	e8 a4 0b 00 00       	call   801f2e <ipc_recv>
}
  80138a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80138d:	5b                   	pop    %ebx
  80138e:	5e                   	pop    %esi
  80138f:	5d                   	pop    %ebp
  801390:	c3                   	ret    

00801391 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801397:	8b 45 08             	mov    0x8(%ebp),%eax
  80139a:	8b 40 0c             	mov    0xc(%eax),%eax
  80139d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8013af:	b8 02 00 00 00       	mov    $0x2,%eax
  8013b4:	e8 8d ff ff ff       	call   801346 <fsipc>
}
  8013b9:	c9                   	leave  
  8013ba:	c3                   	ret    

008013bb <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013bb:	55                   	push   %ebp
  8013bc:	89 e5                	mov    %esp,%ebp
  8013be:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013c4:	8b 40 0c             	mov    0xc(%eax),%eax
  8013c7:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d1:	b8 06 00 00 00       	mov    $0x6,%eax
  8013d6:	e8 6b ff ff ff       	call   801346 <fsipc>
}
  8013db:	c9                   	leave  
  8013dc:	c3                   	ret    

008013dd <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	53                   	push   %ebx
  8013e1:	83 ec 04             	sub    $0x4,%esp
  8013e4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ed:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f7:	b8 05 00 00 00       	mov    $0x5,%eax
  8013fc:	e8 45 ff ff ff       	call   801346 <fsipc>
  801401:	85 c0                	test   %eax,%eax
  801403:	78 2c                	js     801431 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801405:	83 ec 08             	sub    $0x8,%esp
  801408:	68 00 50 80 00       	push   $0x805000
  80140d:	53                   	push   %ebx
  80140e:	e8 51 f3 ff ff       	call   800764 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801413:	a1 80 50 80 00       	mov    0x805080,%eax
  801418:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80141e:	a1 84 50 80 00       	mov    0x805084,%eax
  801423:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801429:	83 c4 10             	add    $0x10,%esp
  80142c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801431:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801434:	c9                   	leave  
  801435:	c3                   	ret    

00801436 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801436:	55                   	push   %ebp
  801437:	89 e5                	mov    %esp,%ebp
  801439:	83 ec 0c             	sub    $0xc,%esp
  80143c:	8b 45 10             	mov    0x10(%ebp),%eax
  80143f:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801444:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801449:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80144c:	8b 55 08             	mov    0x8(%ebp),%edx
  80144f:	8b 52 0c             	mov    0xc(%edx),%edx
  801452:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801458:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80145d:	50                   	push   %eax
  80145e:	ff 75 0c             	pushl  0xc(%ebp)
  801461:	68 08 50 80 00       	push   $0x805008
  801466:	e8 8b f4 ff ff       	call   8008f6 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80146b:	ba 00 00 00 00       	mov    $0x0,%edx
  801470:	b8 04 00 00 00       	mov    $0x4,%eax
  801475:	e8 cc fe ff ff       	call   801346 <fsipc>
	//panic("devfile_write not implemented");
}
  80147a:	c9                   	leave  
  80147b:	c3                   	ret    

0080147c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80147c:	55                   	push   %ebp
  80147d:	89 e5                	mov    %esp,%ebp
  80147f:	56                   	push   %esi
  801480:	53                   	push   %ebx
  801481:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801484:	8b 45 08             	mov    0x8(%ebp),%eax
  801487:	8b 40 0c             	mov    0xc(%eax),%eax
  80148a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80148f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801495:	ba 00 00 00 00       	mov    $0x0,%edx
  80149a:	b8 03 00 00 00       	mov    $0x3,%eax
  80149f:	e8 a2 fe ff ff       	call   801346 <fsipc>
  8014a4:	89 c3                	mov    %eax,%ebx
  8014a6:	85 c0                	test   %eax,%eax
  8014a8:	78 4b                	js     8014f5 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014aa:	39 c6                	cmp    %eax,%esi
  8014ac:	73 16                	jae    8014c4 <devfile_read+0x48>
  8014ae:	68 fc 26 80 00       	push   $0x8026fc
  8014b3:	68 03 27 80 00       	push   $0x802703
  8014b8:	6a 7c                	push   $0x7c
  8014ba:	68 18 27 80 00       	push   $0x802718
  8014bf:	e8 24 0a 00 00       	call   801ee8 <_panic>
	assert(r <= PGSIZE);
  8014c4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014c9:	7e 16                	jle    8014e1 <devfile_read+0x65>
  8014cb:	68 23 27 80 00       	push   $0x802723
  8014d0:	68 03 27 80 00       	push   $0x802703
  8014d5:	6a 7d                	push   $0x7d
  8014d7:	68 18 27 80 00       	push   $0x802718
  8014dc:	e8 07 0a 00 00       	call   801ee8 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014e1:	83 ec 04             	sub    $0x4,%esp
  8014e4:	50                   	push   %eax
  8014e5:	68 00 50 80 00       	push   $0x805000
  8014ea:	ff 75 0c             	pushl  0xc(%ebp)
  8014ed:	e8 04 f4 ff ff       	call   8008f6 <memmove>
	return r;
  8014f2:	83 c4 10             	add    $0x10,%esp
}
  8014f5:	89 d8                	mov    %ebx,%eax
  8014f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014fa:	5b                   	pop    %ebx
  8014fb:	5e                   	pop    %esi
  8014fc:	5d                   	pop    %ebp
  8014fd:	c3                   	ret    

008014fe <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014fe:	55                   	push   %ebp
  8014ff:	89 e5                	mov    %esp,%ebp
  801501:	53                   	push   %ebx
  801502:	83 ec 20             	sub    $0x20,%esp
  801505:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801508:	53                   	push   %ebx
  801509:	e8 1d f2 ff ff       	call   80072b <strlen>
  80150e:	83 c4 10             	add    $0x10,%esp
  801511:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801516:	7f 67                	jg     80157f <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801518:	83 ec 0c             	sub    $0xc,%esp
  80151b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151e:	50                   	push   %eax
  80151f:	e8 9a f8 ff ff       	call   800dbe <fd_alloc>
  801524:	83 c4 10             	add    $0x10,%esp
		return r;
  801527:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801529:	85 c0                	test   %eax,%eax
  80152b:	78 57                	js     801584 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80152d:	83 ec 08             	sub    $0x8,%esp
  801530:	53                   	push   %ebx
  801531:	68 00 50 80 00       	push   $0x805000
  801536:	e8 29 f2 ff ff       	call   800764 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80153b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80153e:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801543:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801546:	b8 01 00 00 00       	mov    $0x1,%eax
  80154b:	e8 f6 fd ff ff       	call   801346 <fsipc>
  801550:	89 c3                	mov    %eax,%ebx
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	85 c0                	test   %eax,%eax
  801557:	79 14                	jns    80156d <open+0x6f>
		fd_close(fd, 0);
  801559:	83 ec 08             	sub    $0x8,%esp
  80155c:	6a 00                	push   $0x0
  80155e:	ff 75 f4             	pushl  -0xc(%ebp)
  801561:	e8 50 f9 ff ff       	call   800eb6 <fd_close>
		return r;
  801566:	83 c4 10             	add    $0x10,%esp
  801569:	89 da                	mov    %ebx,%edx
  80156b:	eb 17                	jmp    801584 <open+0x86>
	}

	return fd2num(fd);
  80156d:	83 ec 0c             	sub    $0xc,%esp
  801570:	ff 75 f4             	pushl  -0xc(%ebp)
  801573:	e8 1f f8 ff ff       	call   800d97 <fd2num>
  801578:	89 c2                	mov    %eax,%edx
  80157a:	83 c4 10             	add    $0x10,%esp
  80157d:	eb 05                	jmp    801584 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  80157f:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801584:	89 d0                	mov    %edx,%eax
  801586:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801589:	c9                   	leave  
  80158a:	c3                   	ret    

0080158b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801591:	ba 00 00 00 00       	mov    $0x0,%edx
  801596:	b8 08 00 00 00       	mov    $0x8,%eax
  80159b:	e8 a6 fd ff ff       	call   801346 <fsipc>
}
  8015a0:	c9                   	leave  
  8015a1:	c3                   	ret    

008015a2 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  8015a2:	55                   	push   %ebp
  8015a3:	89 e5                	mov    %esp,%ebp
  8015a5:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  8015a8:	68 2f 27 80 00       	push   $0x80272f
  8015ad:	ff 75 0c             	pushl  0xc(%ebp)
  8015b0:	e8 af f1 ff ff       	call   800764 <strcpy>
	return 0;
}
  8015b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ba:	c9                   	leave  
  8015bb:	c3                   	ret    

008015bc <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	53                   	push   %ebx
  8015c0:	83 ec 10             	sub    $0x10,%esp
  8015c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8015c6:	53                   	push   %ebx
  8015c7:	e8 58 0a 00 00       	call   802024 <pageref>
  8015cc:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8015cf:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8015d4:	83 f8 01             	cmp    $0x1,%eax
  8015d7:	75 10                	jne    8015e9 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8015d9:	83 ec 0c             	sub    $0xc,%esp
  8015dc:	ff 73 0c             	pushl  0xc(%ebx)
  8015df:	e8 c0 02 00 00       	call   8018a4 <nsipc_close>
  8015e4:	89 c2                	mov    %eax,%edx
  8015e6:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8015e9:	89 d0                	mov    %edx,%eax
  8015eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ee:	c9                   	leave  
  8015ef:	c3                   	ret    

008015f0 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015f6:	6a 00                	push   $0x0
  8015f8:	ff 75 10             	pushl  0x10(%ebp)
  8015fb:	ff 75 0c             	pushl  0xc(%ebp)
  8015fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801601:	ff 70 0c             	pushl  0xc(%eax)
  801604:	e8 78 03 00 00       	call   801981 <nsipc_send>
}
  801609:	c9                   	leave  
  80160a:	c3                   	ret    

0080160b <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  80160b:	55                   	push   %ebp
  80160c:	89 e5                	mov    %esp,%ebp
  80160e:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801611:	6a 00                	push   $0x0
  801613:	ff 75 10             	pushl  0x10(%ebp)
  801616:	ff 75 0c             	pushl  0xc(%ebp)
  801619:	8b 45 08             	mov    0x8(%ebp),%eax
  80161c:	ff 70 0c             	pushl  0xc(%eax)
  80161f:	e8 f1 02 00 00       	call   801915 <nsipc_recv>
}
  801624:	c9                   	leave  
  801625:	c3                   	ret    

00801626 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801626:	55                   	push   %ebp
  801627:	89 e5                	mov    %esp,%ebp
  801629:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80162c:	8d 55 f4             	lea    -0xc(%ebp),%edx
  80162f:	52                   	push   %edx
  801630:	50                   	push   %eax
  801631:	e8 d7 f7 ff ff       	call   800e0d <fd_lookup>
  801636:	83 c4 10             	add    $0x10,%esp
  801639:	85 c0                	test   %eax,%eax
  80163b:	78 17                	js     801654 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80163d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801640:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801646:	39 08                	cmp    %ecx,(%eax)
  801648:	75 05                	jne    80164f <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80164a:	8b 40 0c             	mov    0xc(%eax),%eax
  80164d:	eb 05                	jmp    801654 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  80164f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801654:	c9                   	leave  
  801655:	c3                   	ret    

00801656 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	56                   	push   %esi
  80165a:	53                   	push   %ebx
  80165b:	83 ec 1c             	sub    $0x1c,%esp
  80165e:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801660:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801663:	50                   	push   %eax
  801664:	e8 55 f7 ff ff       	call   800dbe <fd_alloc>
  801669:	89 c3                	mov    %eax,%ebx
  80166b:	83 c4 10             	add    $0x10,%esp
  80166e:	85 c0                	test   %eax,%eax
  801670:	78 1b                	js     80168d <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801672:	83 ec 04             	sub    $0x4,%esp
  801675:	68 07 04 00 00       	push   $0x407
  80167a:	ff 75 f4             	pushl  -0xc(%ebp)
  80167d:	6a 00                	push   $0x0
  80167f:	e8 e3 f4 ff ff       	call   800b67 <sys_page_alloc>
  801684:	89 c3                	mov    %eax,%ebx
  801686:	83 c4 10             	add    $0x10,%esp
  801689:	85 c0                	test   %eax,%eax
  80168b:	79 10                	jns    80169d <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80168d:	83 ec 0c             	sub    $0xc,%esp
  801690:	56                   	push   %esi
  801691:	e8 0e 02 00 00       	call   8018a4 <nsipc_close>
		return r;
  801696:	83 c4 10             	add    $0x10,%esp
  801699:	89 d8                	mov    %ebx,%eax
  80169b:	eb 24                	jmp    8016c1 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80169d:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8016a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a6:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  8016a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8016b2:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8016b5:	83 ec 0c             	sub    $0xc,%esp
  8016b8:	50                   	push   %eax
  8016b9:	e8 d9 f6 ff ff       	call   800d97 <fd2num>
  8016be:	83 c4 10             	add    $0x10,%esp
}
  8016c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016c4:	5b                   	pop    %ebx
  8016c5:	5e                   	pop    %esi
  8016c6:	5d                   	pop    %ebp
  8016c7:	c3                   	ret    

008016c8 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8016c8:	55                   	push   %ebp
  8016c9:	89 e5                	mov    %esp,%ebp
  8016cb:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d1:	e8 50 ff ff ff       	call   801626 <fd2sockid>
		return r;
  8016d6:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016d8:	85 c0                	test   %eax,%eax
  8016da:	78 1f                	js     8016fb <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016dc:	83 ec 04             	sub    $0x4,%esp
  8016df:	ff 75 10             	pushl  0x10(%ebp)
  8016e2:	ff 75 0c             	pushl  0xc(%ebp)
  8016e5:	50                   	push   %eax
  8016e6:	e8 12 01 00 00       	call   8017fd <nsipc_accept>
  8016eb:	83 c4 10             	add    $0x10,%esp
		return r;
  8016ee:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016f0:	85 c0                	test   %eax,%eax
  8016f2:	78 07                	js     8016fb <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8016f4:	e8 5d ff ff ff       	call   801656 <alloc_sockfd>
  8016f9:	89 c1                	mov    %eax,%ecx
}
  8016fb:	89 c8                	mov    %ecx,%eax
  8016fd:	c9                   	leave  
  8016fe:	c3                   	ret    

008016ff <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801705:	8b 45 08             	mov    0x8(%ebp),%eax
  801708:	e8 19 ff ff ff       	call   801626 <fd2sockid>
  80170d:	85 c0                	test   %eax,%eax
  80170f:	78 12                	js     801723 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801711:	83 ec 04             	sub    $0x4,%esp
  801714:	ff 75 10             	pushl  0x10(%ebp)
  801717:	ff 75 0c             	pushl  0xc(%ebp)
  80171a:	50                   	push   %eax
  80171b:	e8 2d 01 00 00       	call   80184d <nsipc_bind>
  801720:	83 c4 10             	add    $0x10,%esp
}
  801723:	c9                   	leave  
  801724:	c3                   	ret    

00801725 <shutdown>:

int
shutdown(int s, int how)
{
  801725:	55                   	push   %ebp
  801726:	89 e5                	mov    %esp,%ebp
  801728:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80172b:	8b 45 08             	mov    0x8(%ebp),%eax
  80172e:	e8 f3 fe ff ff       	call   801626 <fd2sockid>
  801733:	85 c0                	test   %eax,%eax
  801735:	78 0f                	js     801746 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801737:	83 ec 08             	sub    $0x8,%esp
  80173a:	ff 75 0c             	pushl  0xc(%ebp)
  80173d:	50                   	push   %eax
  80173e:	e8 3f 01 00 00       	call   801882 <nsipc_shutdown>
  801743:	83 c4 10             	add    $0x10,%esp
}
  801746:	c9                   	leave  
  801747:	c3                   	ret    

00801748 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801748:	55                   	push   %ebp
  801749:	89 e5                	mov    %esp,%ebp
  80174b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80174e:	8b 45 08             	mov    0x8(%ebp),%eax
  801751:	e8 d0 fe ff ff       	call   801626 <fd2sockid>
  801756:	85 c0                	test   %eax,%eax
  801758:	78 12                	js     80176c <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80175a:	83 ec 04             	sub    $0x4,%esp
  80175d:	ff 75 10             	pushl  0x10(%ebp)
  801760:	ff 75 0c             	pushl  0xc(%ebp)
  801763:	50                   	push   %eax
  801764:	e8 55 01 00 00       	call   8018be <nsipc_connect>
  801769:	83 c4 10             	add    $0x10,%esp
}
  80176c:	c9                   	leave  
  80176d:	c3                   	ret    

0080176e <listen>:

int
listen(int s, int backlog)
{
  80176e:	55                   	push   %ebp
  80176f:	89 e5                	mov    %esp,%ebp
  801771:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801774:	8b 45 08             	mov    0x8(%ebp),%eax
  801777:	e8 aa fe ff ff       	call   801626 <fd2sockid>
  80177c:	85 c0                	test   %eax,%eax
  80177e:	78 0f                	js     80178f <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801780:	83 ec 08             	sub    $0x8,%esp
  801783:	ff 75 0c             	pushl  0xc(%ebp)
  801786:	50                   	push   %eax
  801787:	e8 67 01 00 00       	call   8018f3 <nsipc_listen>
  80178c:	83 c4 10             	add    $0x10,%esp
}
  80178f:	c9                   	leave  
  801790:	c3                   	ret    

00801791 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801791:	55                   	push   %ebp
  801792:	89 e5                	mov    %esp,%ebp
  801794:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801797:	ff 75 10             	pushl  0x10(%ebp)
  80179a:	ff 75 0c             	pushl  0xc(%ebp)
  80179d:	ff 75 08             	pushl  0x8(%ebp)
  8017a0:	e8 3a 02 00 00       	call   8019df <nsipc_socket>
  8017a5:	83 c4 10             	add    $0x10,%esp
  8017a8:	85 c0                	test   %eax,%eax
  8017aa:	78 05                	js     8017b1 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  8017ac:	e8 a5 fe ff ff       	call   801656 <alloc_sockfd>
}
  8017b1:	c9                   	leave  
  8017b2:	c3                   	ret    

008017b3 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8017b3:	55                   	push   %ebp
  8017b4:	89 e5                	mov    %esp,%ebp
  8017b6:	53                   	push   %ebx
  8017b7:	83 ec 04             	sub    $0x4,%esp
  8017ba:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8017bc:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8017c3:	75 12                	jne    8017d7 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017c5:	83 ec 0c             	sub    $0xc,%esp
  8017c8:	6a 02                	push   $0x2
  8017ca:	e8 1c 08 00 00       	call   801feb <ipc_find_env>
  8017cf:	a3 04 40 80 00       	mov    %eax,0x804004
  8017d4:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8017d7:	6a 07                	push   $0x7
  8017d9:	68 00 60 80 00       	push   $0x806000
  8017de:	53                   	push   %ebx
  8017df:	ff 35 04 40 80 00    	pushl  0x804004
  8017e5:	e8 ad 07 00 00       	call   801f97 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017ea:	83 c4 0c             	add    $0xc,%esp
  8017ed:	6a 00                	push   $0x0
  8017ef:	6a 00                	push   $0x0
  8017f1:	6a 00                	push   $0x0
  8017f3:	e8 36 07 00 00       	call   801f2e <ipc_recv>
}
  8017f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017fb:	c9                   	leave  
  8017fc:	c3                   	ret    

008017fd <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017fd:	55                   	push   %ebp
  8017fe:	89 e5                	mov    %esp,%ebp
  801800:	56                   	push   %esi
  801801:	53                   	push   %ebx
  801802:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801805:	8b 45 08             	mov    0x8(%ebp),%eax
  801808:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  80180d:	8b 06                	mov    (%esi),%eax
  80180f:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801814:	b8 01 00 00 00       	mov    $0x1,%eax
  801819:	e8 95 ff ff ff       	call   8017b3 <nsipc>
  80181e:	89 c3                	mov    %eax,%ebx
  801820:	85 c0                	test   %eax,%eax
  801822:	78 20                	js     801844 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801824:	83 ec 04             	sub    $0x4,%esp
  801827:	ff 35 10 60 80 00    	pushl  0x806010
  80182d:	68 00 60 80 00       	push   $0x806000
  801832:	ff 75 0c             	pushl  0xc(%ebp)
  801835:	e8 bc f0 ff ff       	call   8008f6 <memmove>
		*addrlen = ret->ret_addrlen;
  80183a:	a1 10 60 80 00       	mov    0x806010,%eax
  80183f:	89 06                	mov    %eax,(%esi)
  801841:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801844:	89 d8                	mov    %ebx,%eax
  801846:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801849:	5b                   	pop    %ebx
  80184a:	5e                   	pop    %esi
  80184b:	5d                   	pop    %ebp
  80184c:	c3                   	ret    

0080184d <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	53                   	push   %ebx
  801851:	83 ec 08             	sub    $0x8,%esp
  801854:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801857:	8b 45 08             	mov    0x8(%ebp),%eax
  80185a:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  80185f:	53                   	push   %ebx
  801860:	ff 75 0c             	pushl  0xc(%ebp)
  801863:	68 04 60 80 00       	push   $0x806004
  801868:	e8 89 f0 ff ff       	call   8008f6 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80186d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801873:	b8 02 00 00 00       	mov    $0x2,%eax
  801878:	e8 36 ff ff ff       	call   8017b3 <nsipc>
}
  80187d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801880:	c9                   	leave  
  801881:	c3                   	ret    

00801882 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801888:	8b 45 08             	mov    0x8(%ebp),%eax
  80188b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801890:	8b 45 0c             	mov    0xc(%ebp),%eax
  801893:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801898:	b8 03 00 00 00       	mov    $0x3,%eax
  80189d:	e8 11 ff ff ff       	call   8017b3 <nsipc>
}
  8018a2:	c9                   	leave  
  8018a3:	c3                   	ret    

008018a4 <nsipc_close>:

int
nsipc_close(int s)
{
  8018a4:	55                   	push   %ebp
  8018a5:	89 e5                	mov    %esp,%ebp
  8018a7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  8018aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ad:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8018b2:	b8 04 00 00 00       	mov    $0x4,%eax
  8018b7:	e8 f7 fe ff ff       	call   8017b3 <nsipc>
}
  8018bc:	c9                   	leave  
  8018bd:	c3                   	ret    

008018be <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8018be:	55                   	push   %ebp
  8018bf:	89 e5                	mov    %esp,%ebp
  8018c1:	53                   	push   %ebx
  8018c2:	83 ec 08             	sub    $0x8,%esp
  8018c5:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8018c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cb:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8018d0:	53                   	push   %ebx
  8018d1:	ff 75 0c             	pushl  0xc(%ebp)
  8018d4:	68 04 60 80 00       	push   $0x806004
  8018d9:	e8 18 f0 ff ff       	call   8008f6 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8018de:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8018e4:	b8 05 00 00 00       	mov    $0x5,%eax
  8018e9:	e8 c5 fe ff ff       	call   8017b3 <nsipc>
}
  8018ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018f1:	c9                   	leave  
  8018f2:	c3                   	ret    

008018f3 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fc:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801901:	8b 45 0c             	mov    0xc(%ebp),%eax
  801904:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801909:	b8 06 00 00 00       	mov    $0x6,%eax
  80190e:	e8 a0 fe ff ff       	call   8017b3 <nsipc>
}
  801913:	c9                   	leave  
  801914:	c3                   	ret    

00801915 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801915:	55                   	push   %ebp
  801916:	89 e5                	mov    %esp,%ebp
  801918:	56                   	push   %esi
  801919:	53                   	push   %ebx
  80191a:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80191d:	8b 45 08             	mov    0x8(%ebp),%eax
  801920:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801925:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80192b:	8b 45 14             	mov    0x14(%ebp),%eax
  80192e:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801933:	b8 07 00 00 00       	mov    $0x7,%eax
  801938:	e8 76 fe ff ff       	call   8017b3 <nsipc>
  80193d:	89 c3                	mov    %eax,%ebx
  80193f:	85 c0                	test   %eax,%eax
  801941:	78 35                	js     801978 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801943:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801948:	7f 04                	jg     80194e <nsipc_recv+0x39>
  80194a:	39 c6                	cmp    %eax,%esi
  80194c:	7d 16                	jge    801964 <nsipc_recv+0x4f>
  80194e:	68 3b 27 80 00       	push   $0x80273b
  801953:	68 03 27 80 00       	push   $0x802703
  801958:	6a 62                	push   $0x62
  80195a:	68 50 27 80 00       	push   $0x802750
  80195f:	e8 84 05 00 00       	call   801ee8 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801964:	83 ec 04             	sub    $0x4,%esp
  801967:	50                   	push   %eax
  801968:	68 00 60 80 00       	push   $0x806000
  80196d:	ff 75 0c             	pushl  0xc(%ebp)
  801970:	e8 81 ef ff ff       	call   8008f6 <memmove>
  801975:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801978:	89 d8                	mov    %ebx,%eax
  80197a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80197d:	5b                   	pop    %ebx
  80197e:	5e                   	pop    %esi
  80197f:	5d                   	pop    %ebp
  801980:	c3                   	ret    

00801981 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	53                   	push   %ebx
  801985:	83 ec 04             	sub    $0x4,%esp
  801988:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80198b:	8b 45 08             	mov    0x8(%ebp),%eax
  80198e:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801993:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801999:	7e 16                	jle    8019b1 <nsipc_send+0x30>
  80199b:	68 5c 27 80 00       	push   $0x80275c
  8019a0:	68 03 27 80 00       	push   $0x802703
  8019a5:	6a 6d                	push   $0x6d
  8019a7:	68 50 27 80 00       	push   $0x802750
  8019ac:	e8 37 05 00 00       	call   801ee8 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8019b1:	83 ec 04             	sub    $0x4,%esp
  8019b4:	53                   	push   %ebx
  8019b5:	ff 75 0c             	pushl  0xc(%ebp)
  8019b8:	68 0c 60 80 00       	push   $0x80600c
  8019bd:	e8 34 ef ff ff       	call   8008f6 <memmove>
	nsipcbuf.send.req_size = size;
  8019c2:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8019c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8019cb:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8019d0:	b8 08 00 00 00       	mov    $0x8,%eax
  8019d5:	e8 d9 fd ff ff       	call   8017b3 <nsipc>
}
  8019da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019dd:	c9                   	leave  
  8019de:	c3                   	ret    

008019df <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019df:	55                   	push   %ebp
  8019e0:	89 e5                	mov    %esp,%ebp
  8019e2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8019ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019f0:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8019f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8019f8:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8019fd:	b8 09 00 00 00       	mov    $0x9,%eax
  801a02:	e8 ac fd ff ff       	call   8017b3 <nsipc>
}
  801a07:	c9                   	leave  
  801a08:	c3                   	ret    

00801a09 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	56                   	push   %esi
  801a0d:	53                   	push   %ebx
  801a0e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a11:	83 ec 0c             	sub    $0xc,%esp
  801a14:	ff 75 08             	pushl  0x8(%ebp)
  801a17:	e8 8b f3 ff ff       	call   800da7 <fd2data>
  801a1c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a1e:	83 c4 08             	add    $0x8,%esp
  801a21:	68 68 27 80 00       	push   $0x802768
  801a26:	53                   	push   %ebx
  801a27:	e8 38 ed ff ff       	call   800764 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a2c:	8b 46 04             	mov    0x4(%esi),%eax
  801a2f:	2b 06                	sub    (%esi),%eax
  801a31:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a37:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a3e:	00 00 00 
	stat->st_dev = &devpipe;
  801a41:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a48:	30 80 00 
	return 0;
}
  801a4b:	b8 00 00 00 00       	mov    $0x0,%eax
  801a50:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a53:	5b                   	pop    %ebx
  801a54:	5e                   	pop    %esi
  801a55:	5d                   	pop    %ebp
  801a56:	c3                   	ret    

00801a57 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a57:	55                   	push   %ebp
  801a58:	89 e5                	mov    %esp,%ebp
  801a5a:	53                   	push   %ebx
  801a5b:	83 ec 0c             	sub    $0xc,%esp
  801a5e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a61:	53                   	push   %ebx
  801a62:	6a 00                	push   $0x0
  801a64:	e8 83 f1 ff ff       	call   800bec <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a69:	89 1c 24             	mov    %ebx,(%esp)
  801a6c:	e8 36 f3 ff ff       	call   800da7 <fd2data>
  801a71:	83 c4 08             	add    $0x8,%esp
  801a74:	50                   	push   %eax
  801a75:	6a 00                	push   $0x0
  801a77:	e8 70 f1 ff ff       	call   800bec <sys_page_unmap>
}
  801a7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a7f:	c9                   	leave  
  801a80:	c3                   	ret    

00801a81 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a81:	55                   	push   %ebp
  801a82:	89 e5                	mov    %esp,%ebp
  801a84:	57                   	push   %edi
  801a85:	56                   	push   %esi
  801a86:	53                   	push   %ebx
  801a87:	83 ec 1c             	sub    $0x1c,%esp
  801a8a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a8d:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a8f:	a1 08 40 80 00       	mov    0x804008,%eax
  801a94:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a97:	83 ec 0c             	sub    $0xc,%esp
  801a9a:	ff 75 e0             	pushl  -0x20(%ebp)
  801a9d:	e8 82 05 00 00       	call   802024 <pageref>
  801aa2:	89 c3                	mov    %eax,%ebx
  801aa4:	89 3c 24             	mov    %edi,(%esp)
  801aa7:	e8 78 05 00 00       	call   802024 <pageref>
  801aac:	83 c4 10             	add    $0x10,%esp
  801aaf:	39 c3                	cmp    %eax,%ebx
  801ab1:	0f 94 c1             	sete   %cl
  801ab4:	0f b6 c9             	movzbl %cl,%ecx
  801ab7:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801aba:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ac0:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ac3:	39 ce                	cmp    %ecx,%esi
  801ac5:	74 1b                	je     801ae2 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ac7:	39 c3                	cmp    %eax,%ebx
  801ac9:	75 c4                	jne    801a8f <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801acb:	8b 42 58             	mov    0x58(%edx),%eax
  801ace:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ad1:	50                   	push   %eax
  801ad2:	56                   	push   %esi
  801ad3:	68 6f 27 80 00       	push   $0x80276f
  801ad8:	e8 83 e6 ff ff       	call   800160 <cprintf>
  801add:	83 c4 10             	add    $0x10,%esp
  801ae0:	eb ad                	jmp    801a8f <_pipeisclosed+0xe>
	}
}
  801ae2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ae5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae8:	5b                   	pop    %ebx
  801ae9:	5e                   	pop    %esi
  801aea:	5f                   	pop    %edi
  801aeb:	5d                   	pop    %ebp
  801aec:	c3                   	ret    

00801aed <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	57                   	push   %edi
  801af1:	56                   	push   %esi
  801af2:	53                   	push   %ebx
  801af3:	83 ec 28             	sub    $0x28,%esp
  801af6:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801af9:	56                   	push   %esi
  801afa:	e8 a8 f2 ff ff       	call   800da7 <fd2data>
  801aff:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b01:	83 c4 10             	add    $0x10,%esp
  801b04:	bf 00 00 00 00       	mov    $0x0,%edi
  801b09:	eb 4b                	jmp    801b56 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b0b:	89 da                	mov    %ebx,%edx
  801b0d:	89 f0                	mov    %esi,%eax
  801b0f:	e8 6d ff ff ff       	call   801a81 <_pipeisclosed>
  801b14:	85 c0                	test   %eax,%eax
  801b16:	75 48                	jne    801b60 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b18:	e8 2b f0 ff ff       	call   800b48 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b1d:	8b 43 04             	mov    0x4(%ebx),%eax
  801b20:	8b 0b                	mov    (%ebx),%ecx
  801b22:	8d 51 20             	lea    0x20(%ecx),%edx
  801b25:	39 d0                	cmp    %edx,%eax
  801b27:	73 e2                	jae    801b0b <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b2c:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b30:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b33:	89 c2                	mov    %eax,%edx
  801b35:	c1 fa 1f             	sar    $0x1f,%edx
  801b38:	89 d1                	mov    %edx,%ecx
  801b3a:	c1 e9 1b             	shr    $0x1b,%ecx
  801b3d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b40:	83 e2 1f             	and    $0x1f,%edx
  801b43:	29 ca                	sub    %ecx,%edx
  801b45:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b49:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b4d:	83 c0 01             	add    $0x1,%eax
  801b50:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b53:	83 c7 01             	add    $0x1,%edi
  801b56:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b59:	75 c2                	jne    801b1d <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b5b:	8b 45 10             	mov    0x10(%ebp),%eax
  801b5e:	eb 05                	jmp    801b65 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b60:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b65:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b68:	5b                   	pop    %ebx
  801b69:	5e                   	pop    %esi
  801b6a:	5f                   	pop    %edi
  801b6b:	5d                   	pop    %ebp
  801b6c:	c3                   	ret    

00801b6d <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b6d:	55                   	push   %ebp
  801b6e:	89 e5                	mov    %esp,%ebp
  801b70:	57                   	push   %edi
  801b71:	56                   	push   %esi
  801b72:	53                   	push   %ebx
  801b73:	83 ec 18             	sub    $0x18,%esp
  801b76:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b79:	57                   	push   %edi
  801b7a:	e8 28 f2 ff ff       	call   800da7 <fd2data>
  801b7f:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b81:	83 c4 10             	add    $0x10,%esp
  801b84:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b89:	eb 3d                	jmp    801bc8 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b8b:	85 db                	test   %ebx,%ebx
  801b8d:	74 04                	je     801b93 <devpipe_read+0x26>
				return i;
  801b8f:	89 d8                	mov    %ebx,%eax
  801b91:	eb 44                	jmp    801bd7 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b93:	89 f2                	mov    %esi,%edx
  801b95:	89 f8                	mov    %edi,%eax
  801b97:	e8 e5 fe ff ff       	call   801a81 <_pipeisclosed>
  801b9c:	85 c0                	test   %eax,%eax
  801b9e:	75 32                	jne    801bd2 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801ba0:	e8 a3 ef ff ff       	call   800b48 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801ba5:	8b 06                	mov    (%esi),%eax
  801ba7:	3b 46 04             	cmp    0x4(%esi),%eax
  801baa:	74 df                	je     801b8b <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801bac:	99                   	cltd   
  801bad:	c1 ea 1b             	shr    $0x1b,%edx
  801bb0:	01 d0                	add    %edx,%eax
  801bb2:	83 e0 1f             	and    $0x1f,%eax
  801bb5:	29 d0                	sub    %edx,%eax
  801bb7:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bbc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bbf:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bc2:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bc5:	83 c3 01             	add    $0x1,%ebx
  801bc8:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bcb:	75 d8                	jne    801ba5 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bcd:	8b 45 10             	mov    0x10(%ebp),%eax
  801bd0:	eb 05                	jmp    801bd7 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bd2:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bda:	5b                   	pop    %ebx
  801bdb:	5e                   	pop    %esi
  801bdc:	5f                   	pop    %edi
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	56                   	push   %esi
  801be3:	53                   	push   %ebx
  801be4:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801be7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bea:	50                   	push   %eax
  801beb:	e8 ce f1 ff ff       	call   800dbe <fd_alloc>
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	89 c2                	mov    %eax,%edx
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	0f 88 2c 01 00 00    	js     801d29 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bfd:	83 ec 04             	sub    $0x4,%esp
  801c00:	68 07 04 00 00       	push   $0x407
  801c05:	ff 75 f4             	pushl  -0xc(%ebp)
  801c08:	6a 00                	push   $0x0
  801c0a:	e8 58 ef ff ff       	call   800b67 <sys_page_alloc>
  801c0f:	83 c4 10             	add    $0x10,%esp
  801c12:	89 c2                	mov    %eax,%edx
  801c14:	85 c0                	test   %eax,%eax
  801c16:	0f 88 0d 01 00 00    	js     801d29 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c1c:	83 ec 0c             	sub    $0xc,%esp
  801c1f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c22:	50                   	push   %eax
  801c23:	e8 96 f1 ff ff       	call   800dbe <fd_alloc>
  801c28:	89 c3                	mov    %eax,%ebx
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	0f 88 e2 00 00 00    	js     801d17 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c35:	83 ec 04             	sub    $0x4,%esp
  801c38:	68 07 04 00 00       	push   $0x407
  801c3d:	ff 75 f0             	pushl  -0x10(%ebp)
  801c40:	6a 00                	push   $0x0
  801c42:	e8 20 ef ff ff       	call   800b67 <sys_page_alloc>
  801c47:	89 c3                	mov    %eax,%ebx
  801c49:	83 c4 10             	add    $0x10,%esp
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	0f 88 c3 00 00 00    	js     801d17 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c54:	83 ec 0c             	sub    $0xc,%esp
  801c57:	ff 75 f4             	pushl  -0xc(%ebp)
  801c5a:	e8 48 f1 ff ff       	call   800da7 <fd2data>
  801c5f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c61:	83 c4 0c             	add    $0xc,%esp
  801c64:	68 07 04 00 00       	push   $0x407
  801c69:	50                   	push   %eax
  801c6a:	6a 00                	push   $0x0
  801c6c:	e8 f6 ee ff ff       	call   800b67 <sys_page_alloc>
  801c71:	89 c3                	mov    %eax,%ebx
  801c73:	83 c4 10             	add    $0x10,%esp
  801c76:	85 c0                	test   %eax,%eax
  801c78:	0f 88 89 00 00 00    	js     801d07 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c7e:	83 ec 0c             	sub    $0xc,%esp
  801c81:	ff 75 f0             	pushl  -0x10(%ebp)
  801c84:	e8 1e f1 ff ff       	call   800da7 <fd2data>
  801c89:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c90:	50                   	push   %eax
  801c91:	6a 00                	push   $0x0
  801c93:	56                   	push   %esi
  801c94:	6a 00                	push   $0x0
  801c96:	e8 0f ef ff ff       	call   800baa <sys_page_map>
  801c9b:	89 c3                	mov    %eax,%ebx
  801c9d:	83 c4 20             	add    $0x20,%esp
  801ca0:	85 c0                	test   %eax,%eax
  801ca2:	78 55                	js     801cf9 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ca4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801caa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cad:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801caf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cb2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cb9:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cbf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cc2:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cc4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cc7:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cce:	83 ec 0c             	sub    $0xc,%esp
  801cd1:	ff 75 f4             	pushl  -0xc(%ebp)
  801cd4:	e8 be f0 ff ff       	call   800d97 <fd2num>
  801cd9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cdc:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cde:	83 c4 04             	add    $0x4,%esp
  801ce1:	ff 75 f0             	pushl  -0x10(%ebp)
  801ce4:	e8 ae f0 ff ff       	call   800d97 <fd2num>
  801ce9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cec:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cef:	83 c4 10             	add    $0x10,%esp
  801cf2:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf7:	eb 30                	jmp    801d29 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cf9:	83 ec 08             	sub    $0x8,%esp
  801cfc:	56                   	push   %esi
  801cfd:	6a 00                	push   $0x0
  801cff:	e8 e8 ee ff ff       	call   800bec <sys_page_unmap>
  801d04:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d07:	83 ec 08             	sub    $0x8,%esp
  801d0a:	ff 75 f0             	pushl  -0x10(%ebp)
  801d0d:	6a 00                	push   $0x0
  801d0f:	e8 d8 ee ff ff       	call   800bec <sys_page_unmap>
  801d14:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d17:	83 ec 08             	sub    $0x8,%esp
  801d1a:	ff 75 f4             	pushl  -0xc(%ebp)
  801d1d:	6a 00                	push   $0x0
  801d1f:	e8 c8 ee ff ff       	call   800bec <sys_page_unmap>
  801d24:	83 c4 10             	add    $0x10,%esp
  801d27:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d29:	89 d0                	mov    %edx,%eax
  801d2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d2e:	5b                   	pop    %ebx
  801d2f:	5e                   	pop    %esi
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    

00801d32 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d32:	55                   	push   %ebp
  801d33:	89 e5                	mov    %esp,%ebp
  801d35:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d38:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d3b:	50                   	push   %eax
  801d3c:	ff 75 08             	pushl  0x8(%ebp)
  801d3f:	e8 c9 f0 ff ff       	call   800e0d <fd_lookup>
  801d44:	83 c4 10             	add    $0x10,%esp
  801d47:	85 c0                	test   %eax,%eax
  801d49:	78 18                	js     801d63 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d4b:	83 ec 0c             	sub    $0xc,%esp
  801d4e:	ff 75 f4             	pushl  -0xc(%ebp)
  801d51:	e8 51 f0 ff ff       	call   800da7 <fd2data>
	return _pipeisclosed(fd, p);
  801d56:	89 c2                	mov    %eax,%edx
  801d58:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d5b:	e8 21 fd ff ff       	call   801a81 <_pipeisclosed>
  801d60:	83 c4 10             	add    $0x10,%esp
}
  801d63:	c9                   	leave  
  801d64:	c3                   	ret    

00801d65 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d65:	55                   	push   %ebp
  801d66:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d68:	b8 00 00 00 00       	mov    $0x0,%eax
  801d6d:	5d                   	pop    %ebp
  801d6e:	c3                   	ret    

00801d6f <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d6f:	55                   	push   %ebp
  801d70:	89 e5                	mov    %esp,%ebp
  801d72:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d75:	68 87 27 80 00       	push   $0x802787
  801d7a:	ff 75 0c             	pushl  0xc(%ebp)
  801d7d:	e8 e2 e9 ff ff       	call   800764 <strcpy>
	return 0;
}
  801d82:	b8 00 00 00 00       	mov    $0x0,%eax
  801d87:	c9                   	leave  
  801d88:	c3                   	ret    

00801d89 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d89:	55                   	push   %ebp
  801d8a:	89 e5                	mov    %esp,%ebp
  801d8c:	57                   	push   %edi
  801d8d:	56                   	push   %esi
  801d8e:	53                   	push   %ebx
  801d8f:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d95:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d9a:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801da0:	eb 2d                	jmp    801dcf <devcons_write+0x46>
		m = n - tot;
  801da2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801da5:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801da7:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801daa:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801daf:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801db2:	83 ec 04             	sub    $0x4,%esp
  801db5:	53                   	push   %ebx
  801db6:	03 45 0c             	add    0xc(%ebp),%eax
  801db9:	50                   	push   %eax
  801dba:	57                   	push   %edi
  801dbb:	e8 36 eb ff ff       	call   8008f6 <memmove>
		sys_cputs(buf, m);
  801dc0:	83 c4 08             	add    $0x8,%esp
  801dc3:	53                   	push   %ebx
  801dc4:	57                   	push   %edi
  801dc5:	e8 e1 ec ff ff       	call   800aab <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dca:	01 de                	add    %ebx,%esi
  801dcc:	83 c4 10             	add    $0x10,%esp
  801dcf:	89 f0                	mov    %esi,%eax
  801dd1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dd4:	72 cc                	jb     801da2 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd9:	5b                   	pop    %ebx
  801dda:	5e                   	pop    %esi
  801ddb:	5f                   	pop    %edi
  801ddc:	5d                   	pop    %ebp
  801ddd:	c3                   	ret    

00801dde <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dde:	55                   	push   %ebp
  801ddf:	89 e5                	mov    %esp,%ebp
  801de1:	83 ec 08             	sub    $0x8,%esp
  801de4:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801de9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ded:	74 2a                	je     801e19 <devcons_read+0x3b>
  801def:	eb 05                	jmp    801df6 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801df1:	e8 52 ed ff ff       	call   800b48 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801df6:	e8 ce ec ff ff       	call   800ac9 <sys_cgetc>
  801dfb:	85 c0                	test   %eax,%eax
  801dfd:	74 f2                	je     801df1 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801dff:	85 c0                	test   %eax,%eax
  801e01:	78 16                	js     801e19 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e03:	83 f8 04             	cmp    $0x4,%eax
  801e06:	74 0c                	je     801e14 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801e08:	8b 55 0c             	mov    0xc(%ebp),%edx
  801e0b:	88 02                	mov    %al,(%edx)
	return 1;
  801e0d:	b8 01 00 00 00       	mov    $0x1,%eax
  801e12:	eb 05                	jmp    801e19 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e14:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e19:	c9                   	leave  
  801e1a:	c3                   	ret    

00801e1b <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801e1b:	55                   	push   %ebp
  801e1c:	89 e5                	mov    %esp,%ebp
  801e1e:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e21:	8b 45 08             	mov    0x8(%ebp),%eax
  801e24:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e27:	6a 01                	push   $0x1
  801e29:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e2c:	50                   	push   %eax
  801e2d:	e8 79 ec ff ff       	call   800aab <sys_cputs>
}
  801e32:	83 c4 10             	add    $0x10,%esp
  801e35:	c9                   	leave  
  801e36:	c3                   	ret    

00801e37 <getchar>:

int
getchar(void)
{
  801e37:	55                   	push   %ebp
  801e38:	89 e5                	mov    %esp,%ebp
  801e3a:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e3d:	6a 01                	push   $0x1
  801e3f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e42:	50                   	push   %eax
  801e43:	6a 00                	push   $0x0
  801e45:	e8 29 f2 ff ff       	call   801073 <read>
	if (r < 0)
  801e4a:	83 c4 10             	add    $0x10,%esp
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	78 0f                	js     801e60 <getchar+0x29>
		return r;
	if (r < 1)
  801e51:	85 c0                	test   %eax,%eax
  801e53:	7e 06                	jle    801e5b <getchar+0x24>
		return -E_EOF;
	return c;
  801e55:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e59:	eb 05                	jmp    801e60 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e5b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e60:	c9                   	leave  
  801e61:	c3                   	ret    

00801e62 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e62:	55                   	push   %ebp
  801e63:	89 e5                	mov    %esp,%ebp
  801e65:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e68:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e6b:	50                   	push   %eax
  801e6c:	ff 75 08             	pushl  0x8(%ebp)
  801e6f:	e8 99 ef ff ff       	call   800e0d <fd_lookup>
  801e74:	83 c4 10             	add    $0x10,%esp
  801e77:	85 c0                	test   %eax,%eax
  801e79:	78 11                	js     801e8c <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e7e:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e84:	39 10                	cmp    %edx,(%eax)
  801e86:	0f 94 c0             	sete   %al
  801e89:	0f b6 c0             	movzbl %al,%eax
}
  801e8c:	c9                   	leave  
  801e8d:	c3                   	ret    

00801e8e <opencons>:

int
opencons(void)
{
  801e8e:	55                   	push   %ebp
  801e8f:	89 e5                	mov    %esp,%ebp
  801e91:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e94:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e97:	50                   	push   %eax
  801e98:	e8 21 ef ff ff       	call   800dbe <fd_alloc>
  801e9d:	83 c4 10             	add    $0x10,%esp
		return r;
  801ea0:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ea2:	85 c0                	test   %eax,%eax
  801ea4:	78 3e                	js     801ee4 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ea6:	83 ec 04             	sub    $0x4,%esp
  801ea9:	68 07 04 00 00       	push   $0x407
  801eae:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb1:	6a 00                	push   $0x0
  801eb3:	e8 af ec ff ff       	call   800b67 <sys_page_alloc>
  801eb8:	83 c4 10             	add    $0x10,%esp
		return r;
  801ebb:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ebd:	85 c0                	test   %eax,%eax
  801ebf:	78 23                	js     801ee4 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ec1:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801ec7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eca:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ecc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ecf:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ed6:	83 ec 0c             	sub    $0xc,%esp
  801ed9:	50                   	push   %eax
  801eda:	e8 b8 ee ff ff       	call   800d97 <fd2num>
  801edf:	89 c2                	mov    %eax,%edx
  801ee1:	83 c4 10             	add    $0x10,%esp
}
  801ee4:	89 d0                	mov    %edx,%eax
  801ee6:	c9                   	leave  
  801ee7:	c3                   	ret    

00801ee8 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ee8:	55                   	push   %ebp
  801ee9:	89 e5                	mov    %esp,%ebp
  801eeb:	56                   	push   %esi
  801eec:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801eed:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ef0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ef6:	e8 2e ec ff ff       	call   800b29 <sys_getenvid>
  801efb:	83 ec 0c             	sub    $0xc,%esp
  801efe:	ff 75 0c             	pushl  0xc(%ebp)
  801f01:	ff 75 08             	pushl  0x8(%ebp)
  801f04:	56                   	push   %esi
  801f05:	50                   	push   %eax
  801f06:	68 94 27 80 00       	push   $0x802794
  801f0b:	e8 50 e2 ff ff       	call   800160 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f10:	83 c4 18             	add    $0x18,%esp
  801f13:	53                   	push   %ebx
  801f14:	ff 75 10             	pushl  0x10(%ebp)
  801f17:	e8 f3 e1 ff ff       	call   80010f <vcprintf>
	cprintf("\n");
  801f1c:	c7 04 24 80 27 80 00 	movl   $0x802780,(%esp)
  801f23:	e8 38 e2 ff ff       	call   800160 <cprintf>
  801f28:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f2b:	cc                   	int3   
  801f2c:	eb fd                	jmp    801f2b <_panic+0x43>

00801f2e <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f2e:	55                   	push   %ebp
  801f2f:	89 e5                	mov    %esp,%ebp
  801f31:	56                   	push   %esi
  801f32:	53                   	push   %ebx
  801f33:	8b 75 08             	mov    0x8(%ebp),%esi
  801f36:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f39:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f43:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801f46:	83 ec 0c             	sub    $0xc,%esp
  801f49:	50                   	push   %eax
  801f4a:	e8 c8 ed ff ff       	call   800d17 <sys_ipc_recv>
  801f4f:	83 c4 10             	add    $0x10,%esp
  801f52:	85 c0                	test   %eax,%eax
  801f54:	79 16                	jns    801f6c <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801f56:	85 f6                	test   %esi,%esi
  801f58:	74 06                	je     801f60 <ipc_recv+0x32>
            *from_env_store = 0;
  801f5a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801f60:	85 db                	test   %ebx,%ebx
  801f62:	74 2c                	je     801f90 <ipc_recv+0x62>
            *perm_store = 0;
  801f64:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f6a:	eb 24                	jmp    801f90 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801f6c:	85 f6                	test   %esi,%esi
  801f6e:	74 0a                	je     801f7a <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801f70:	a1 08 40 80 00       	mov    0x804008,%eax
  801f75:	8b 40 74             	mov    0x74(%eax),%eax
  801f78:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801f7a:	85 db                	test   %ebx,%ebx
  801f7c:	74 0a                	je     801f88 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801f7e:	a1 08 40 80 00       	mov    0x804008,%eax
  801f83:	8b 40 78             	mov    0x78(%eax),%eax
  801f86:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801f88:	a1 08 40 80 00       	mov    0x804008,%eax
  801f8d:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801f90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f93:	5b                   	pop    %ebx
  801f94:	5e                   	pop    %esi
  801f95:	5d                   	pop    %ebp
  801f96:	c3                   	ret    

00801f97 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f97:	55                   	push   %ebp
  801f98:	89 e5                	mov    %esp,%ebp
  801f9a:	57                   	push   %edi
  801f9b:	56                   	push   %esi
  801f9c:	53                   	push   %ebx
  801f9d:	83 ec 0c             	sub    $0xc,%esp
  801fa0:	8b 7d 08             	mov    0x8(%ebp),%edi
  801fa3:	8b 75 0c             	mov    0xc(%ebp),%esi
  801fa6:	8b 45 10             	mov    0x10(%ebp),%eax
  801fa9:	85 c0                	test   %eax,%eax
  801fab:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801fb0:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801fb3:	eb 1c                	jmp    801fd1 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801fb5:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fb8:	74 12                	je     801fcc <ipc_send+0x35>
  801fba:	50                   	push   %eax
  801fbb:	68 b8 27 80 00       	push   $0x8027b8
  801fc0:	6a 3b                	push   $0x3b
  801fc2:	68 ce 27 80 00       	push   $0x8027ce
  801fc7:	e8 1c ff ff ff       	call   801ee8 <_panic>
		sys_yield();
  801fcc:	e8 77 eb ff ff       	call   800b48 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801fd1:	ff 75 14             	pushl  0x14(%ebp)
  801fd4:	53                   	push   %ebx
  801fd5:	56                   	push   %esi
  801fd6:	57                   	push   %edi
  801fd7:	e8 18 ed ff ff       	call   800cf4 <sys_ipc_try_send>
  801fdc:	83 c4 10             	add    $0x10,%esp
  801fdf:	85 c0                	test   %eax,%eax
  801fe1:	78 d2                	js     801fb5 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801fe3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fe6:	5b                   	pop    %ebx
  801fe7:	5e                   	pop    %esi
  801fe8:	5f                   	pop    %edi
  801fe9:	5d                   	pop    %ebp
  801fea:	c3                   	ret    

00801feb <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801feb:	55                   	push   %ebp
  801fec:	89 e5                	mov    %esp,%ebp
  801fee:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ff1:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ff6:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ff9:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fff:	8b 52 50             	mov    0x50(%edx),%edx
  802002:	39 ca                	cmp    %ecx,%edx
  802004:	75 0d                	jne    802013 <ipc_find_env+0x28>
			return envs[i].env_id;
  802006:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802009:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80200e:	8b 40 48             	mov    0x48(%eax),%eax
  802011:	eb 0f                	jmp    802022 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802013:	83 c0 01             	add    $0x1,%eax
  802016:	3d 00 04 00 00       	cmp    $0x400,%eax
  80201b:	75 d9                	jne    801ff6 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80201d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802022:	5d                   	pop    %ebp
  802023:	c3                   	ret    

00802024 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802024:	55                   	push   %ebp
  802025:	89 e5                	mov    %esp,%ebp
  802027:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80202a:	89 d0                	mov    %edx,%eax
  80202c:	c1 e8 16             	shr    $0x16,%eax
  80202f:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802036:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80203b:	f6 c1 01             	test   $0x1,%cl
  80203e:	74 1d                	je     80205d <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802040:	c1 ea 0c             	shr    $0xc,%edx
  802043:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80204a:	f6 c2 01             	test   $0x1,%dl
  80204d:	74 0e                	je     80205d <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80204f:	c1 ea 0c             	shr    $0xc,%edx
  802052:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802059:	ef 
  80205a:	0f b7 c0             	movzwl %ax,%eax
}
  80205d:	5d                   	pop    %ebp
  80205e:	c3                   	ret    
  80205f:	90                   	nop

00802060 <__udivdi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	83 ec 1c             	sub    $0x1c,%esp
  802067:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80206b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80206f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802077:	85 f6                	test   %esi,%esi
  802079:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80207d:	89 ca                	mov    %ecx,%edx
  80207f:	89 f8                	mov    %edi,%eax
  802081:	75 3d                	jne    8020c0 <__udivdi3+0x60>
  802083:	39 cf                	cmp    %ecx,%edi
  802085:	0f 87 c5 00 00 00    	ja     802150 <__udivdi3+0xf0>
  80208b:	85 ff                	test   %edi,%edi
  80208d:	89 fd                	mov    %edi,%ebp
  80208f:	75 0b                	jne    80209c <__udivdi3+0x3c>
  802091:	b8 01 00 00 00       	mov    $0x1,%eax
  802096:	31 d2                	xor    %edx,%edx
  802098:	f7 f7                	div    %edi
  80209a:	89 c5                	mov    %eax,%ebp
  80209c:	89 c8                	mov    %ecx,%eax
  80209e:	31 d2                	xor    %edx,%edx
  8020a0:	f7 f5                	div    %ebp
  8020a2:	89 c1                	mov    %eax,%ecx
  8020a4:	89 d8                	mov    %ebx,%eax
  8020a6:	89 cf                	mov    %ecx,%edi
  8020a8:	f7 f5                	div    %ebp
  8020aa:	89 c3                	mov    %eax,%ebx
  8020ac:	89 d8                	mov    %ebx,%eax
  8020ae:	89 fa                	mov    %edi,%edx
  8020b0:	83 c4 1c             	add    $0x1c,%esp
  8020b3:	5b                   	pop    %ebx
  8020b4:	5e                   	pop    %esi
  8020b5:	5f                   	pop    %edi
  8020b6:	5d                   	pop    %ebp
  8020b7:	c3                   	ret    
  8020b8:	90                   	nop
  8020b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020c0:	39 ce                	cmp    %ecx,%esi
  8020c2:	77 74                	ja     802138 <__udivdi3+0xd8>
  8020c4:	0f bd fe             	bsr    %esi,%edi
  8020c7:	83 f7 1f             	xor    $0x1f,%edi
  8020ca:	0f 84 98 00 00 00    	je     802168 <__udivdi3+0x108>
  8020d0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	89 c5                	mov    %eax,%ebp
  8020d9:	29 fb                	sub    %edi,%ebx
  8020db:	d3 e6                	shl    %cl,%esi
  8020dd:	89 d9                	mov    %ebx,%ecx
  8020df:	d3 ed                	shr    %cl,%ebp
  8020e1:	89 f9                	mov    %edi,%ecx
  8020e3:	d3 e0                	shl    %cl,%eax
  8020e5:	09 ee                	or     %ebp,%esi
  8020e7:	89 d9                	mov    %ebx,%ecx
  8020e9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020ed:	89 d5                	mov    %edx,%ebp
  8020ef:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020f3:	d3 ed                	shr    %cl,%ebp
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	d3 e2                	shl    %cl,%edx
  8020f9:	89 d9                	mov    %ebx,%ecx
  8020fb:	d3 e8                	shr    %cl,%eax
  8020fd:	09 c2                	or     %eax,%edx
  8020ff:	89 d0                	mov    %edx,%eax
  802101:	89 ea                	mov    %ebp,%edx
  802103:	f7 f6                	div    %esi
  802105:	89 d5                	mov    %edx,%ebp
  802107:	89 c3                	mov    %eax,%ebx
  802109:	f7 64 24 0c          	mull   0xc(%esp)
  80210d:	39 d5                	cmp    %edx,%ebp
  80210f:	72 10                	jb     802121 <__udivdi3+0xc1>
  802111:	8b 74 24 08          	mov    0x8(%esp),%esi
  802115:	89 f9                	mov    %edi,%ecx
  802117:	d3 e6                	shl    %cl,%esi
  802119:	39 c6                	cmp    %eax,%esi
  80211b:	73 07                	jae    802124 <__udivdi3+0xc4>
  80211d:	39 d5                	cmp    %edx,%ebp
  80211f:	75 03                	jne    802124 <__udivdi3+0xc4>
  802121:	83 eb 01             	sub    $0x1,%ebx
  802124:	31 ff                	xor    %edi,%edi
  802126:	89 d8                	mov    %ebx,%eax
  802128:	89 fa                	mov    %edi,%edx
  80212a:	83 c4 1c             	add    $0x1c,%esp
  80212d:	5b                   	pop    %ebx
  80212e:	5e                   	pop    %esi
  80212f:	5f                   	pop    %edi
  802130:	5d                   	pop    %ebp
  802131:	c3                   	ret    
  802132:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802138:	31 ff                	xor    %edi,%edi
  80213a:	31 db                	xor    %ebx,%ebx
  80213c:	89 d8                	mov    %ebx,%eax
  80213e:	89 fa                	mov    %edi,%edx
  802140:	83 c4 1c             	add    $0x1c,%esp
  802143:	5b                   	pop    %ebx
  802144:	5e                   	pop    %esi
  802145:	5f                   	pop    %edi
  802146:	5d                   	pop    %ebp
  802147:	c3                   	ret    
  802148:	90                   	nop
  802149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802150:	89 d8                	mov    %ebx,%eax
  802152:	f7 f7                	div    %edi
  802154:	31 ff                	xor    %edi,%edi
  802156:	89 c3                	mov    %eax,%ebx
  802158:	89 d8                	mov    %ebx,%eax
  80215a:	89 fa                	mov    %edi,%edx
  80215c:	83 c4 1c             	add    $0x1c,%esp
  80215f:	5b                   	pop    %ebx
  802160:	5e                   	pop    %esi
  802161:	5f                   	pop    %edi
  802162:	5d                   	pop    %ebp
  802163:	c3                   	ret    
  802164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802168:	39 ce                	cmp    %ecx,%esi
  80216a:	72 0c                	jb     802178 <__udivdi3+0x118>
  80216c:	31 db                	xor    %ebx,%ebx
  80216e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802172:	0f 87 34 ff ff ff    	ja     8020ac <__udivdi3+0x4c>
  802178:	bb 01 00 00 00       	mov    $0x1,%ebx
  80217d:	e9 2a ff ff ff       	jmp    8020ac <__udivdi3+0x4c>
  802182:	66 90                	xchg   %ax,%ax
  802184:	66 90                	xchg   %ax,%ax
  802186:	66 90                	xchg   %ax,%ax
  802188:	66 90                	xchg   %ax,%ax
  80218a:	66 90                	xchg   %ax,%ax
  80218c:	66 90                	xchg   %ax,%ax
  80218e:	66 90                	xchg   %ax,%ax

00802190 <__umoddi3>:
  802190:	55                   	push   %ebp
  802191:	57                   	push   %edi
  802192:	56                   	push   %esi
  802193:	53                   	push   %ebx
  802194:	83 ec 1c             	sub    $0x1c,%esp
  802197:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80219b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80219f:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021a3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8021a7:	85 d2                	test   %edx,%edx
  8021a9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8021ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021b1:	89 f3                	mov    %esi,%ebx
  8021b3:	89 3c 24             	mov    %edi,(%esp)
  8021b6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021ba:	75 1c                	jne    8021d8 <__umoddi3+0x48>
  8021bc:	39 f7                	cmp    %esi,%edi
  8021be:	76 50                	jbe    802210 <__umoddi3+0x80>
  8021c0:	89 c8                	mov    %ecx,%eax
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	f7 f7                	div    %edi
  8021c6:	89 d0                	mov    %edx,%eax
  8021c8:	31 d2                	xor    %edx,%edx
  8021ca:	83 c4 1c             	add    $0x1c,%esp
  8021cd:	5b                   	pop    %ebx
  8021ce:	5e                   	pop    %esi
  8021cf:	5f                   	pop    %edi
  8021d0:	5d                   	pop    %ebp
  8021d1:	c3                   	ret    
  8021d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021d8:	39 f2                	cmp    %esi,%edx
  8021da:	89 d0                	mov    %edx,%eax
  8021dc:	77 52                	ja     802230 <__umoddi3+0xa0>
  8021de:	0f bd ea             	bsr    %edx,%ebp
  8021e1:	83 f5 1f             	xor    $0x1f,%ebp
  8021e4:	75 5a                	jne    802240 <__umoddi3+0xb0>
  8021e6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ea:	0f 82 e0 00 00 00    	jb     8022d0 <__umoddi3+0x140>
  8021f0:	39 0c 24             	cmp    %ecx,(%esp)
  8021f3:	0f 86 d7 00 00 00    	jbe    8022d0 <__umoddi3+0x140>
  8021f9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021fd:	8b 54 24 04          	mov    0x4(%esp),%edx
  802201:	83 c4 1c             	add    $0x1c,%esp
  802204:	5b                   	pop    %ebx
  802205:	5e                   	pop    %esi
  802206:	5f                   	pop    %edi
  802207:	5d                   	pop    %ebp
  802208:	c3                   	ret    
  802209:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802210:	85 ff                	test   %edi,%edi
  802212:	89 fd                	mov    %edi,%ebp
  802214:	75 0b                	jne    802221 <__umoddi3+0x91>
  802216:	b8 01 00 00 00       	mov    $0x1,%eax
  80221b:	31 d2                	xor    %edx,%edx
  80221d:	f7 f7                	div    %edi
  80221f:	89 c5                	mov    %eax,%ebp
  802221:	89 f0                	mov    %esi,%eax
  802223:	31 d2                	xor    %edx,%edx
  802225:	f7 f5                	div    %ebp
  802227:	89 c8                	mov    %ecx,%eax
  802229:	f7 f5                	div    %ebp
  80222b:	89 d0                	mov    %edx,%eax
  80222d:	eb 99                	jmp    8021c8 <__umoddi3+0x38>
  80222f:	90                   	nop
  802230:	89 c8                	mov    %ecx,%eax
  802232:	89 f2                	mov    %esi,%edx
  802234:	83 c4 1c             	add    $0x1c,%esp
  802237:	5b                   	pop    %ebx
  802238:	5e                   	pop    %esi
  802239:	5f                   	pop    %edi
  80223a:	5d                   	pop    %ebp
  80223b:	c3                   	ret    
  80223c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802240:	8b 34 24             	mov    (%esp),%esi
  802243:	bf 20 00 00 00       	mov    $0x20,%edi
  802248:	89 e9                	mov    %ebp,%ecx
  80224a:	29 ef                	sub    %ebp,%edi
  80224c:	d3 e0                	shl    %cl,%eax
  80224e:	89 f9                	mov    %edi,%ecx
  802250:	89 f2                	mov    %esi,%edx
  802252:	d3 ea                	shr    %cl,%edx
  802254:	89 e9                	mov    %ebp,%ecx
  802256:	09 c2                	or     %eax,%edx
  802258:	89 d8                	mov    %ebx,%eax
  80225a:	89 14 24             	mov    %edx,(%esp)
  80225d:	89 f2                	mov    %esi,%edx
  80225f:	d3 e2                	shl    %cl,%edx
  802261:	89 f9                	mov    %edi,%ecx
  802263:	89 54 24 04          	mov    %edx,0x4(%esp)
  802267:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80226b:	d3 e8                	shr    %cl,%eax
  80226d:	89 e9                	mov    %ebp,%ecx
  80226f:	89 c6                	mov    %eax,%esi
  802271:	d3 e3                	shl    %cl,%ebx
  802273:	89 f9                	mov    %edi,%ecx
  802275:	89 d0                	mov    %edx,%eax
  802277:	d3 e8                	shr    %cl,%eax
  802279:	89 e9                	mov    %ebp,%ecx
  80227b:	09 d8                	or     %ebx,%eax
  80227d:	89 d3                	mov    %edx,%ebx
  80227f:	89 f2                	mov    %esi,%edx
  802281:	f7 34 24             	divl   (%esp)
  802284:	89 d6                	mov    %edx,%esi
  802286:	d3 e3                	shl    %cl,%ebx
  802288:	f7 64 24 04          	mull   0x4(%esp)
  80228c:	39 d6                	cmp    %edx,%esi
  80228e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802292:	89 d1                	mov    %edx,%ecx
  802294:	89 c3                	mov    %eax,%ebx
  802296:	72 08                	jb     8022a0 <__umoddi3+0x110>
  802298:	75 11                	jne    8022ab <__umoddi3+0x11b>
  80229a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80229e:	73 0b                	jae    8022ab <__umoddi3+0x11b>
  8022a0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8022a4:	1b 14 24             	sbb    (%esp),%edx
  8022a7:	89 d1                	mov    %edx,%ecx
  8022a9:	89 c3                	mov    %eax,%ebx
  8022ab:	8b 54 24 08          	mov    0x8(%esp),%edx
  8022af:	29 da                	sub    %ebx,%edx
  8022b1:	19 ce                	sbb    %ecx,%esi
  8022b3:	89 f9                	mov    %edi,%ecx
  8022b5:	89 f0                	mov    %esi,%eax
  8022b7:	d3 e0                	shl    %cl,%eax
  8022b9:	89 e9                	mov    %ebp,%ecx
  8022bb:	d3 ea                	shr    %cl,%edx
  8022bd:	89 e9                	mov    %ebp,%ecx
  8022bf:	d3 ee                	shr    %cl,%esi
  8022c1:	09 d0                	or     %edx,%eax
  8022c3:	89 f2                	mov    %esi,%edx
  8022c5:	83 c4 1c             	add    $0x1c,%esp
  8022c8:	5b                   	pop    %ebx
  8022c9:	5e                   	pop    %esi
  8022ca:	5f                   	pop    %edi
  8022cb:	5d                   	pop    %ebp
  8022cc:	c3                   	ret    
  8022cd:	8d 76 00             	lea    0x0(%esi),%esi
  8022d0:	29 f9                	sub    %edi,%ecx
  8022d2:	19 d6                	sbb    %edx,%esi
  8022d4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022d8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022dc:	e9 18 ff ff ff       	jmp    8021f9 <__umoddi3+0x69>
