
obj/user/divzero.debug：     文件格式 elf32-i386


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
  80002c:	e8 2f 00 00 00       	call   800060 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	zero = 0;
  800039:	c7 05 04 40 80 00 00 	movl   $0x0,0x804004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 40 1e 80 00       	push   $0x801e40
  800056:	e8 f8 00 00 00       	call   800153 <cprintf>
}
  80005b:	83 c4 10             	add    $0x10,%esp
  80005e:	c9                   	leave  
  80005f:	c3                   	ret    

00800060 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800060:	55                   	push   %ebp
  800061:	89 e5                	mov    %esp,%ebp
  800063:	56                   	push   %esi
  800064:	53                   	push   %ebx
  800065:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800068:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  80006b:	e8 ac 0a 00 00       	call   800b1c <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 08 40 80 00       	mov    %eax,0x804008

    // save the name of the program so that panic() can use it
    if (argc > 0)
  800082:	85 db                	test   %ebx,%ebx
  800084:	7e 07                	jle    80008d <libmain+0x2d>
        binaryname = argv[0];
  800086:	8b 06                	mov    (%esi),%eax
  800088:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  80008d:	83 ec 08             	sub    $0x8,%esp
  800090:	56                   	push   %esi
  800091:	53                   	push   %ebx
  800092:	e8 9c ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  800097:	e8 0a 00 00 00       	call   8000a6 <exit>
}
  80009c:	83 c4 10             	add    $0x10,%esp
  80009f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a2:	5b                   	pop    %ebx
  8000a3:	5e                   	pop    %esi
  8000a4:	5d                   	pop    %ebp
  8000a5:	c3                   	ret    

008000a6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000ac:	e8 65 0e 00 00       	call   800f16 <close_all>
	sys_env_destroy(0);
  8000b1:	83 ec 0c             	sub    $0xc,%esp
  8000b4:	6a 00                	push   $0x0
  8000b6:	e8 20 0a 00 00       	call   800adb <sys_env_destroy>
}
  8000bb:	83 c4 10             	add    $0x10,%esp
  8000be:	c9                   	leave  
  8000bf:	c3                   	ret    

008000c0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 04             	sub    $0x4,%esp
  8000c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ca:	8b 13                	mov    (%ebx),%edx
  8000cc:	8d 42 01             	lea    0x1(%edx),%eax
  8000cf:	89 03                	mov    %eax,(%ebx)
  8000d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000dd:	75 1a                	jne    8000f9 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000df:	83 ec 08             	sub    $0x8,%esp
  8000e2:	68 ff 00 00 00       	push   $0xff
  8000e7:	8d 43 08             	lea    0x8(%ebx),%eax
  8000ea:	50                   	push   %eax
  8000eb:	e8 ae 09 00 00       	call   800a9e <sys_cputs>
		b->idx = 0;
  8000f0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f6:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f9:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800100:	c9                   	leave  
  800101:	c3                   	ret    

00800102 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80010b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800112:	00 00 00 
	b.cnt = 0;
  800115:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011f:	ff 75 0c             	pushl  0xc(%ebp)
  800122:	ff 75 08             	pushl  0x8(%ebp)
  800125:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80012b:	50                   	push   %eax
  80012c:	68 c0 00 80 00       	push   $0x8000c0
  800131:	e8 1a 01 00 00       	call   800250 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800136:	83 c4 08             	add    $0x8,%esp
  800139:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800145:	50                   	push   %eax
  800146:	e8 53 09 00 00       	call   800a9e <sys_cputs>

	return b.cnt;
}
  80014b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800153:	55                   	push   %ebp
  800154:	89 e5                	mov    %esp,%ebp
  800156:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800159:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015c:	50                   	push   %eax
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	e8 9d ff ff ff       	call   800102 <vcprintf>
	va_end(ap);

	return cnt;
}
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800167:	55                   	push   %ebp
  800168:	89 e5                	mov    %esp,%ebp
  80016a:	57                   	push   %edi
  80016b:	56                   	push   %esi
  80016c:	53                   	push   %ebx
  80016d:	83 ec 1c             	sub    $0x1c,%esp
  800170:	89 c7                	mov    %eax,%edi
  800172:	89 d6                	mov    %edx,%esi
  800174:	8b 45 08             	mov    0x8(%ebp),%eax
  800177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800180:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800183:	bb 00 00 00 00       	mov    $0x0,%ebx
  800188:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80018b:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80018e:	39 d3                	cmp    %edx,%ebx
  800190:	72 05                	jb     800197 <printnum+0x30>
  800192:	39 45 10             	cmp    %eax,0x10(%ebp)
  800195:	77 45                	ja     8001dc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800197:	83 ec 0c             	sub    $0xc,%esp
  80019a:	ff 75 18             	pushl  0x18(%ebp)
  80019d:	8b 45 14             	mov    0x14(%ebp),%eax
  8001a0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a3:	53                   	push   %ebx
  8001a4:	ff 75 10             	pushl  0x10(%ebp)
  8001a7:	83 ec 08             	sub    $0x8,%esp
  8001aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8001b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b6:	e8 f5 19 00 00       	call   801bb0 <__udivdi3>
  8001bb:	83 c4 18             	add    $0x18,%esp
  8001be:	52                   	push   %edx
  8001bf:	50                   	push   %eax
  8001c0:	89 f2                	mov    %esi,%edx
  8001c2:	89 f8                	mov    %edi,%eax
  8001c4:	e8 9e ff ff ff       	call   800167 <printnum>
  8001c9:	83 c4 20             	add    $0x20,%esp
  8001cc:	eb 18                	jmp    8001e6 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ce:	83 ec 08             	sub    $0x8,%esp
  8001d1:	56                   	push   %esi
  8001d2:	ff 75 18             	pushl  0x18(%ebp)
  8001d5:	ff d7                	call   *%edi
  8001d7:	83 c4 10             	add    $0x10,%esp
  8001da:	eb 03                	jmp    8001df <printnum+0x78>
  8001dc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001df:	83 eb 01             	sub    $0x1,%ebx
  8001e2:	85 db                	test   %ebx,%ebx
  8001e4:	7f e8                	jg     8001ce <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e6:	83 ec 08             	sub    $0x8,%esp
  8001e9:	56                   	push   %esi
  8001ea:	83 ec 04             	sub    $0x4,%esp
  8001ed:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001f0:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f3:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f6:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f9:	e8 e2 1a 00 00       	call   801ce0 <__umoddi3>
  8001fe:	83 c4 14             	add    $0x14,%esp
  800201:	0f be 80 58 1e 80 00 	movsbl 0x801e58(%eax),%eax
  800208:	50                   	push   %eax
  800209:	ff d7                	call   *%edi
}
  80020b:	83 c4 10             	add    $0x10,%esp
  80020e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800211:	5b                   	pop    %ebx
  800212:	5e                   	pop    %esi
  800213:	5f                   	pop    %edi
  800214:	5d                   	pop    %ebp
  800215:	c3                   	ret    

00800216 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
  800219:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80021c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800220:	8b 10                	mov    (%eax),%edx
  800222:	3b 50 04             	cmp    0x4(%eax),%edx
  800225:	73 0a                	jae    800231 <sprintputch+0x1b>
		*b->buf++ = ch;
  800227:	8d 4a 01             	lea    0x1(%edx),%ecx
  80022a:	89 08                	mov    %ecx,(%eax)
  80022c:	8b 45 08             	mov    0x8(%ebp),%eax
  80022f:	88 02                	mov    %al,(%edx)
}
  800231:	5d                   	pop    %ebp
  800232:	c3                   	ret    

00800233 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800233:	55                   	push   %ebp
  800234:	89 e5                	mov    %esp,%ebp
  800236:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800239:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80023c:	50                   	push   %eax
  80023d:	ff 75 10             	pushl  0x10(%ebp)
  800240:	ff 75 0c             	pushl  0xc(%ebp)
  800243:	ff 75 08             	pushl  0x8(%ebp)
  800246:	e8 05 00 00 00       	call   800250 <vprintfmt>
	va_end(ap);
}
  80024b:	83 c4 10             	add    $0x10,%esp
  80024e:	c9                   	leave  
  80024f:	c3                   	ret    

00800250 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800250:	55                   	push   %ebp
  800251:	89 e5                	mov    %esp,%ebp
  800253:	57                   	push   %edi
  800254:	56                   	push   %esi
  800255:	53                   	push   %ebx
  800256:	83 ec 2c             	sub    $0x2c,%esp
  800259:	8b 75 08             	mov    0x8(%ebp),%esi
  80025c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80025f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800262:	eb 12                	jmp    800276 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800264:	85 c0                	test   %eax,%eax
  800266:	0f 84 42 04 00 00    	je     8006ae <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80026c:	83 ec 08             	sub    $0x8,%esp
  80026f:	53                   	push   %ebx
  800270:	50                   	push   %eax
  800271:	ff d6                	call   *%esi
  800273:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800276:	83 c7 01             	add    $0x1,%edi
  800279:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80027d:	83 f8 25             	cmp    $0x25,%eax
  800280:	75 e2                	jne    800264 <vprintfmt+0x14>
  800282:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800286:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80028d:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800294:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80029b:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002a0:	eb 07                	jmp    8002a9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002a2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002a5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002a9:	8d 47 01             	lea    0x1(%edi),%eax
  8002ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002af:	0f b6 07             	movzbl (%edi),%eax
  8002b2:	0f b6 d0             	movzbl %al,%edx
  8002b5:	83 e8 23             	sub    $0x23,%eax
  8002b8:	3c 55                	cmp    $0x55,%al
  8002ba:	0f 87 d3 03 00 00    	ja     800693 <vprintfmt+0x443>
  8002c0:	0f b6 c0             	movzbl %al,%eax
  8002c3:	ff 24 85 a0 1f 80 00 	jmp    *0x801fa0(,%eax,4)
  8002ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002cd:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002d1:	eb d6                	jmp    8002a9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8002db:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002de:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002e1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002e5:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002e8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002eb:	83 f9 09             	cmp    $0x9,%ecx
  8002ee:	77 3f                	ja     80032f <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002f0:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8002f3:	eb e9                	jmp    8002de <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f8:	8b 00                	mov    (%eax),%eax
  8002fa:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002fd:	8b 45 14             	mov    0x14(%ebp),%eax
  800300:	8d 40 04             	lea    0x4(%eax),%eax
  800303:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800306:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800309:	eb 2a                	jmp    800335 <vprintfmt+0xe5>
  80030b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80030e:	85 c0                	test   %eax,%eax
  800310:	ba 00 00 00 00       	mov    $0x0,%edx
  800315:	0f 49 d0             	cmovns %eax,%edx
  800318:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80031b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80031e:	eb 89                	jmp    8002a9 <vprintfmt+0x59>
  800320:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800323:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80032a:	e9 7a ff ff ff       	jmp    8002a9 <vprintfmt+0x59>
  80032f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800332:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800335:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800339:	0f 89 6a ff ff ff    	jns    8002a9 <vprintfmt+0x59>
				width = precision, precision = -1;
  80033f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800342:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800345:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80034c:	e9 58 ff ff ff       	jmp    8002a9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800351:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800354:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800357:	e9 4d ff ff ff       	jmp    8002a9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80035c:	8b 45 14             	mov    0x14(%ebp),%eax
  80035f:	8d 78 04             	lea    0x4(%eax),%edi
  800362:	83 ec 08             	sub    $0x8,%esp
  800365:	53                   	push   %ebx
  800366:	ff 30                	pushl  (%eax)
  800368:	ff d6                	call   *%esi
			break;
  80036a:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80036d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800373:	e9 fe fe ff ff       	jmp    800276 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800378:	8b 45 14             	mov    0x14(%ebp),%eax
  80037b:	8d 78 04             	lea    0x4(%eax),%edi
  80037e:	8b 00                	mov    (%eax),%eax
  800380:	99                   	cltd   
  800381:	31 d0                	xor    %edx,%eax
  800383:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800385:	83 f8 0f             	cmp    $0xf,%eax
  800388:	7f 0b                	jg     800395 <vprintfmt+0x145>
  80038a:	8b 14 85 00 21 80 00 	mov    0x802100(,%eax,4),%edx
  800391:	85 d2                	test   %edx,%edx
  800393:	75 1b                	jne    8003b0 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800395:	50                   	push   %eax
  800396:	68 70 1e 80 00       	push   $0x801e70
  80039b:	53                   	push   %ebx
  80039c:	56                   	push   %esi
  80039d:	e8 91 fe ff ff       	call   800233 <printfmt>
  8003a2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a5:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003ab:	e9 c6 fe ff ff       	jmp    800276 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003b0:	52                   	push   %edx
  8003b1:	68 31 22 80 00       	push   $0x802231
  8003b6:	53                   	push   %ebx
  8003b7:	56                   	push   %esi
  8003b8:	e8 76 fe ff ff       	call   800233 <printfmt>
  8003bd:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c0:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c6:	e9 ab fe ff ff       	jmp    800276 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ce:	83 c0 04             	add    $0x4,%eax
  8003d1:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003d9:	85 ff                	test   %edi,%edi
  8003db:	b8 69 1e 80 00       	mov    $0x801e69,%eax
  8003e0:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003e3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e7:	0f 8e 94 00 00 00    	jle    800481 <vprintfmt+0x231>
  8003ed:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003f1:	0f 84 98 00 00 00    	je     80048f <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f7:	83 ec 08             	sub    $0x8,%esp
  8003fa:	ff 75 d0             	pushl  -0x30(%ebp)
  8003fd:	57                   	push   %edi
  8003fe:	e8 33 03 00 00       	call   800736 <strnlen>
  800403:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800406:	29 c1                	sub    %eax,%ecx
  800408:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80040b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80040e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800412:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800415:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800418:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80041a:	eb 0f                	jmp    80042b <vprintfmt+0x1db>
					putch(padc, putdat);
  80041c:	83 ec 08             	sub    $0x8,%esp
  80041f:	53                   	push   %ebx
  800420:	ff 75 e0             	pushl  -0x20(%ebp)
  800423:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800425:	83 ef 01             	sub    $0x1,%edi
  800428:	83 c4 10             	add    $0x10,%esp
  80042b:	85 ff                	test   %edi,%edi
  80042d:	7f ed                	jg     80041c <vprintfmt+0x1cc>
  80042f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800432:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800435:	85 c9                	test   %ecx,%ecx
  800437:	b8 00 00 00 00       	mov    $0x0,%eax
  80043c:	0f 49 c1             	cmovns %ecx,%eax
  80043f:	29 c1                	sub    %eax,%ecx
  800441:	89 75 08             	mov    %esi,0x8(%ebp)
  800444:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800447:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80044a:	89 cb                	mov    %ecx,%ebx
  80044c:	eb 4d                	jmp    80049b <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80044e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800452:	74 1b                	je     80046f <vprintfmt+0x21f>
  800454:	0f be c0             	movsbl %al,%eax
  800457:	83 e8 20             	sub    $0x20,%eax
  80045a:	83 f8 5e             	cmp    $0x5e,%eax
  80045d:	76 10                	jbe    80046f <vprintfmt+0x21f>
					putch('?', putdat);
  80045f:	83 ec 08             	sub    $0x8,%esp
  800462:	ff 75 0c             	pushl  0xc(%ebp)
  800465:	6a 3f                	push   $0x3f
  800467:	ff 55 08             	call   *0x8(%ebp)
  80046a:	83 c4 10             	add    $0x10,%esp
  80046d:	eb 0d                	jmp    80047c <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80046f:	83 ec 08             	sub    $0x8,%esp
  800472:	ff 75 0c             	pushl  0xc(%ebp)
  800475:	52                   	push   %edx
  800476:	ff 55 08             	call   *0x8(%ebp)
  800479:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80047c:	83 eb 01             	sub    $0x1,%ebx
  80047f:	eb 1a                	jmp    80049b <vprintfmt+0x24b>
  800481:	89 75 08             	mov    %esi,0x8(%ebp)
  800484:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800487:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80048a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80048d:	eb 0c                	jmp    80049b <vprintfmt+0x24b>
  80048f:	89 75 08             	mov    %esi,0x8(%ebp)
  800492:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800495:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800498:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80049b:	83 c7 01             	add    $0x1,%edi
  80049e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004a2:	0f be d0             	movsbl %al,%edx
  8004a5:	85 d2                	test   %edx,%edx
  8004a7:	74 23                	je     8004cc <vprintfmt+0x27c>
  8004a9:	85 f6                	test   %esi,%esi
  8004ab:	78 a1                	js     80044e <vprintfmt+0x1fe>
  8004ad:	83 ee 01             	sub    $0x1,%esi
  8004b0:	79 9c                	jns    80044e <vprintfmt+0x1fe>
  8004b2:	89 df                	mov    %ebx,%edi
  8004b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004ba:	eb 18                	jmp    8004d4 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004bc:	83 ec 08             	sub    $0x8,%esp
  8004bf:	53                   	push   %ebx
  8004c0:	6a 20                	push   $0x20
  8004c2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004c4:	83 ef 01             	sub    $0x1,%edi
  8004c7:	83 c4 10             	add    $0x10,%esp
  8004ca:	eb 08                	jmp    8004d4 <vprintfmt+0x284>
  8004cc:	89 df                	mov    %ebx,%edi
  8004ce:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d4:	85 ff                	test   %edi,%edi
  8004d6:	7f e4                	jg     8004bc <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004db:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004e1:	e9 90 fd ff ff       	jmp    800276 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004e6:	83 f9 01             	cmp    $0x1,%ecx
  8004e9:	7e 19                	jle    800504 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8004eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ee:	8b 50 04             	mov    0x4(%eax),%edx
  8004f1:	8b 00                	mov    (%eax),%eax
  8004f3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f6:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fc:	8d 40 08             	lea    0x8(%eax),%eax
  8004ff:	89 45 14             	mov    %eax,0x14(%ebp)
  800502:	eb 38                	jmp    80053c <vprintfmt+0x2ec>
	else if (lflag)
  800504:	85 c9                	test   %ecx,%ecx
  800506:	74 1b                	je     800523 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800508:	8b 45 14             	mov    0x14(%ebp),%eax
  80050b:	8b 00                	mov    (%eax),%eax
  80050d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800510:	89 c1                	mov    %eax,%ecx
  800512:	c1 f9 1f             	sar    $0x1f,%ecx
  800515:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800518:	8b 45 14             	mov    0x14(%ebp),%eax
  80051b:	8d 40 04             	lea    0x4(%eax),%eax
  80051e:	89 45 14             	mov    %eax,0x14(%ebp)
  800521:	eb 19                	jmp    80053c <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800523:	8b 45 14             	mov    0x14(%ebp),%eax
  800526:	8b 00                	mov    (%eax),%eax
  800528:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80052b:	89 c1                	mov    %eax,%ecx
  80052d:	c1 f9 1f             	sar    $0x1f,%ecx
  800530:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800533:	8b 45 14             	mov    0x14(%ebp),%eax
  800536:	8d 40 04             	lea    0x4(%eax),%eax
  800539:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80053c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800542:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800547:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80054b:	0f 89 0e 01 00 00    	jns    80065f <vprintfmt+0x40f>
				putch('-', putdat);
  800551:	83 ec 08             	sub    $0x8,%esp
  800554:	53                   	push   %ebx
  800555:	6a 2d                	push   $0x2d
  800557:	ff d6                	call   *%esi
				num = -(long long) num;
  800559:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80055f:	f7 da                	neg    %edx
  800561:	83 d1 00             	adc    $0x0,%ecx
  800564:	f7 d9                	neg    %ecx
  800566:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800569:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056e:	e9 ec 00 00 00       	jmp    80065f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800573:	83 f9 01             	cmp    $0x1,%ecx
  800576:	7e 18                	jle    800590 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 10                	mov    (%eax),%edx
  80057d:	8b 48 04             	mov    0x4(%eax),%ecx
  800580:	8d 40 08             	lea    0x8(%eax),%eax
  800583:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800586:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058b:	e9 cf 00 00 00       	jmp    80065f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800590:	85 c9                	test   %ecx,%ecx
  800592:	74 1a                	je     8005ae <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8b 10                	mov    (%eax),%edx
  800599:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059e:	8d 40 04             	lea    0x4(%eax),%eax
  8005a1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005a4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a9:	e9 b1 00 00 00       	jmp    80065f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005ae:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b1:	8b 10                	mov    (%eax),%edx
  8005b3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b8:	8d 40 04             	lea    0x4(%eax),%eax
  8005bb:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c3:	e9 97 00 00 00       	jmp    80065f <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005c8:	83 ec 08             	sub    $0x8,%esp
  8005cb:	53                   	push   %ebx
  8005cc:	6a 58                	push   $0x58
  8005ce:	ff d6                	call   *%esi
			putch('X', putdat);
  8005d0:	83 c4 08             	add    $0x8,%esp
  8005d3:	53                   	push   %ebx
  8005d4:	6a 58                	push   $0x58
  8005d6:	ff d6                	call   *%esi
			putch('X', putdat);
  8005d8:	83 c4 08             	add    $0x8,%esp
  8005db:	53                   	push   %ebx
  8005dc:	6a 58                	push   $0x58
  8005de:	ff d6                	call   *%esi
			break;
  8005e0:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005e6:	e9 8b fc ff ff       	jmp    800276 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8005eb:	83 ec 08             	sub    $0x8,%esp
  8005ee:	53                   	push   %ebx
  8005ef:	6a 30                	push   $0x30
  8005f1:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f3:	83 c4 08             	add    $0x8,%esp
  8005f6:	53                   	push   %ebx
  8005f7:	6a 78                	push   $0x78
  8005f9:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fe:	8b 10                	mov    (%eax),%edx
  800600:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800605:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800608:	8d 40 04             	lea    0x4(%eax),%eax
  80060b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80060e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800613:	eb 4a                	jmp    80065f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800615:	83 f9 01             	cmp    $0x1,%ecx
  800618:	7e 15                	jle    80062f <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8b 10                	mov    (%eax),%edx
  80061f:	8b 48 04             	mov    0x4(%eax),%ecx
  800622:	8d 40 08             	lea    0x8(%eax),%eax
  800625:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800628:	b8 10 00 00 00       	mov    $0x10,%eax
  80062d:	eb 30                	jmp    80065f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80062f:	85 c9                	test   %ecx,%ecx
  800631:	74 17                	je     80064a <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8b 10                	mov    (%eax),%edx
  800638:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063d:	8d 40 04             	lea    0x4(%eax),%eax
  800640:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800643:	b8 10 00 00 00       	mov    $0x10,%eax
  800648:	eb 15                	jmp    80065f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80064a:	8b 45 14             	mov    0x14(%ebp),%eax
  80064d:	8b 10                	mov    (%eax),%edx
  80064f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800654:	8d 40 04             	lea    0x4(%eax),%eax
  800657:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80065a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80065f:	83 ec 0c             	sub    $0xc,%esp
  800662:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800666:	57                   	push   %edi
  800667:	ff 75 e0             	pushl  -0x20(%ebp)
  80066a:	50                   	push   %eax
  80066b:	51                   	push   %ecx
  80066c:	52                   	push   %edx
  80066d:	89 da                	mov    %ebx,%edx
  80066f:	89 f0                	mov    %esi,%eax
  800671:	e8 f1 fa ff ff       	call   800167 <printnum>
			break;
  800676:	83 c4 20             	add    $0x20,%esp
  800679:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067c:	e9 f5 fb ff ff       	jmp    800276 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	53                   	push   %ebx
  800685:	52                   	push   %edx
  800686:	ff d6                	call   *%esi
			break;
  800688:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80068e:	e9 e3 fb ff ff       	jmp    800276 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800693:	83 ec 08             	sub    $0x8,%esp
  800696:	53                   	push   %ebx
  800697:	6a 25                	push   $0x25
  800699:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80069b:	83 c4 10             	add    $0x10,%esp
  80069e:	eb 03                	jmp    8006a3 <vprintfmt+0x453>
  8006a0:	83 ef 01             	sub    $0x1,%edi
  8006a3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006a7:	75 f7                	jne    8006a0 <vprintfmt+0x450>
  8006a9:	e9 c8 fb ff ff       	jmp    800276 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006b1:	5b                   	pop    %ebx
  8006b2:	5e                   	pop    %esi
  8006b3:	5f                   	pop    %edi
  8006b4:	5d                   	pop    %ebp
  8006b5:	c3                   	ret    

008006b6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b6:	55                   	push   %ebp
  8006b7:	89 e5                	mov    %esp,%ebp
  8006b9:	83 ec 18             	sub    $0x18,%esp
  8006bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006cc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d3:	85 c0                	test   %eax,%eax
  8006d5:	74 26                	je     8006fd <vsnprintf+0x47>
  8006d7:	85 d2                	test   %edx,%edx
  8006d9:	7e 22                	jle    8006fd <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006db:	ff 75 14             	pushl  0x14(%ebp)
  8006de:	ff 75 10             	pushl  0x10(%ebp)
  8006e1:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e4:	50                   	push   %eax
  8006e5:	68 16 02 80 00       	push   $0x800216
  8006ea:	e8 61 fb ff ff       	call   800250 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f8:	83 c4 10             	add    $0x10,%esp
  8006fb:	eb 05                	jmp    800702 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800702:	c9                   	leave  
  800703:	c3                   	ret    

00800704 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800704:	55                   	push   %ebp
  800705:	89 e5                	mov    %esp,%ebp
  800707:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80070a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070d:	50                   	push   %eax
  80070e:	ff 75 10             	pushl  0x10(%ebp)
  800711:	ff 75 0c             	pushl  0xc(%ebp)
  800714:	ff 75 08             	pushl  0x8(%ebp)
  800717:	e8 9a ff ff ff       	call   8006b6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80071c:	c9                   	leave  
  80071d:	c3                   	ret    

0080071e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800724:	b8 00 00 00 00       	mov    $0x0,%eax
  800729:	eb 03                	jmp    80072e <strlen+0x10>
		n++;
  80072b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80072e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800732:	75 f7                	jne    80072b <strlen+0xd>
		n++;
	return n;
}
  800734:	5d                   	pop    %ebp
  800735:	c3                   	ret    

00800736 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800736:	55                   	push   %ebp
  800737:	89 e5                	mov    %esp,%ebp
  800739:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073f:	ba 00 00 00 00       	mov    $0x0,%edx
  800744:	eb 03                	jmp    800749 <strnlen+0x13>
		n++;
  800746:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800749:	39 c2                	cmp    %eax,%edx
  80074b:	74 08                	je     800755 <strnlen+0x1f>
  80074d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800751:	75 f3                	jne    800746 <strnlen+0x10>
  800753:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800755:	5d                   	pop    %ebp
  800756:	c3                   	ret    

00800757 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	53                   	push   %ebx
  80075b:	8b 45 08             	mov    0x8(%ebp),%eax
  80075e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800761:	89 c2                	mov    %eax,%edx
  800763:	83 c2 01             	add    $0x1,%edx
  800766:	83 c1 01             	add    $0x1,%ecx
  800769:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80076d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800770:	84 db                	test   %bl,%bl
  800772:	75 ef                	jne    800763 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800774:	5b                   	pop    %ebx
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	53                   	push   %ebx
  80077b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80077e:	53                   	push   %ebx
  80077f:	e8 9a ff ff ff       	call   80071e <strlen>
  800784:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800787:	ff 75 0c             	pushl  0xc(%ebp)
  80078a:	01 d8                	add    %ebx,%eax
  80078c:	50                   	push   %eax
  80078d:	e8 c5 ff ff ff       	call   800757 <strcpy>
	return dst;
}
  800792:	89 d8                	mov    %ebx,%eax
  800794:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800797:	c9                   	leave  
  800798:	c3                   	ret    

00800799 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800799:	55                   	push   %ebp
  80079a:	89 e5                	mov    %esp,%ebp
  80079c:	56                   	push   %esi
  80079d:	53                   	push   %ebx
  80079e:	8b 75 08             	mov    0x8(%ebp),%esi
  8007a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a4:	89 f3                	mov    %esi,%ebx
  8007a6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a9:	89 f2                	mov    %esi,%edx
  8007ab:	eb 0f                	jmp    8007bc <strncpy+0x23>
		*dst++ = *src;
  8007ad:	83 c2 01             	add    $0x1,%edx
  8007b0:	0f b6 01             	movzbl (%ecx),%eax
  8007b3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b6:	80 39 01             	cmpb   $0x1,(%ecx)
  8007b9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007bc:	39 da                	cmp    %ebx,%edx
  8007be:	75 ed                	jne    8007ad <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007c0:	89 f0                	mov    %esi,%eax
  8007c2:	5b                   	pop    %ebx
  8007c3:	5e                   	pop    %esi
  8007c4:	5d                   	pop    %ebp
  8007c5:	c3                   	ret    

008007c6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	56                   	push   %esi
  8007ca:	53                   	push   %ebx
  8007cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007d1:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d6:	85 d2                	test   %edx,%edx
  8007d8:	74 21                	je     8007fb <strlcpy+0x35>
  8007da:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007de:	89 f2                	mov    %esi,%edx
  8007e0:	eb 09                	jmp    8007eb <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e2:	83 c2 01             	add    $0x1,%edx
  8007e5:	83 c1 01             	add    $0x1,%ecx
  8007e8:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007eb:	39 c2                	cmp    %eax,%edx
  8007ed:	74 09                	je     8007f8 <strlcpy+0x32>
  8007ef:	0f b6 19             	movzbl (%ecx),%ebx
  8007f2:	84 db                	test   %bl,%bl
  8007f4:	75 ec                	jne    8007e2 <strlcpy+0x1c>
  8007f6:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007f8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007fb:	29 f0                	sub    %esi,%eax
}
  8007fd:	5b                   	pop    %ebx
  8007fe:	5e                   	pop    %esi
  8007ff:	5d                   	pop    %ebp
  800800:	c3                   	ret    

00800801 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800801:	55                   	push   %ebp
  800802:	89 e5                	mov    %esp,%ebp
  800804:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800807:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80080a:	eb 06                	jmp    800812 <strcmp+0x11>
		p++, q++;
  80080c:	83 c1 01             	add    $0x1,%ecx
  80080f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800812:	0f b6 01             	movzbl (%ecx),%eax
  800815:	84 c0                	test   %al,%al
  800817:	74 04                	je     80081d <strcmp+0x1c>
  800819:	3a 02                	cmp    (%edx),%al
  80081b:	74 ef                	je     80080c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081d:	0f b6 c0             	movzbl %al,%eax
  800820:	0f b6 12             	movzbl (%edx),%edx
  800823:	29 d0                	sub    %edx,%eax
}
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	53                   	push   %ebx
  80082b:	8b 45 08             	mov    0x8(%ebp),%eax
  80082e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800831:	89 c3                	mov    %eax,%ebx
  800833:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800836:	eb 06                	jmp    80083e <strncmp+0x17>
		n--, p++, q++;
  800838:	83 c0 01             	add    $0x1,%eax
  80083b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80083e:	39 d8                	cmp    %ebx,%eax
  800840:	74 15                	je     800857 <strncmp+0x30>
  800842:	0f b6 08             	movzbl (%eax),%ecx
  800845:	84 c9                	test   %cl,%cl
  800847:	74 04                	je     80084d <strncmp+0x26>
  800849:	3a 0a                	cmp    (%edx),%cl
  80084b:	74 eb                	je     800838 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084d:	0f b6 00             	movzbl (%eax),%eax
  800850:	0f b6 12             	movzbl (%edx),%edx
  800853:	29 d0                	sub    %edx,%eax
  800855:	eb 05                	jmp    80085c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800857:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80085c:	5b                   	pop    %ebx
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	8b 45 08             	mov    0x8(%ebp),%eax
  800865:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800869:	eb 07                	jmp    800872 <strchr+0x13>
		if (*s == c)
  80086b:	38 ca                	cmp    %cl,%dl
  80086d:	74 0f                	je     80087e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80086f:	83 c0 01             	add    $0x1,%eax
  800872:	0f b6 10             	movzbl (%eax),%edx
  800875:	84 d2                	test   %dl,%dl
  800877:	75 f2                	jne    80086b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800879:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80087e:	5d                   	pop    %ebp
  80087f:	c3                   	ret    

00800880 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800880:	55                   	push   %ebp
  800881:	89 e5                	mov    %esp,%ebp
  800883:	8b 45 08             	mov    0x8(%ebp),%eax
  800886:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088a:	eb 03                	jmp    80088f <strfind+0xf>
  80088c:	83 c0 01             	add    $0x1,%eax
  80088f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800892:	38 ca                	cmp    %cl,%dl
  800894:	74 04                	je     80089a <strfind+0x1a>
  800896:	84 d2                	test   %dl,%dl
  800898:	75 f2                	jne    80088c <strfind+0xc>
			break;
	return (char *) s;
}
  80089a:	5d                   	pop    %ebp
  80089b:	c3                   	ret    

0080089c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	57                   	push   %edi
  8008a0:	56                   	push   %esi
  8008a1:	53                   	push   %ebx
  8008a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a8:	85 c9                	test   %ecx,%ecx
  8008aa:	74 36                	je     8008e2 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008ac:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b2:	75 28                	jne    8008dc <memset+0x40>
  8008b4:	f6 c1 03             	test   $0x3,%cl
  8008b7:	75 23                	jne    8008dc <memset+0x40>
		c &= 0xFF;
  8008b9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008bd:	89 d3                	mov    %edx,%ebx
  8008bf:	c1 e3 08             	shl    $0x8,%ebx
  8008c2:	89 d6                	mov    %edx,%esi
  8008c4:	c1 e6 18             	shl    $0x18,%esi
  8008c7:	89 d0                	mov    %edx,%eax
  8008c9:	c1 e0 10             	shl    $0x10,%eax
  8008cc:	09 f0                	or     %esi,%eax
  8008ce:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008d0:	89 d8                	mov    %ebx,%eax
  8008d2:	09 d0                	or     %edx,%eax
  8008d4:	c1 e9 02             	shr    $0x2,%ecx
  8008d7:	fc                   	cld    
  8008d8:	f3 ab                	rep stos %eax,%es:(%edi)
  8008da:	eb 06                	jmp    8008e2 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008df:	fc                   	cld    
  8008e0:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e2:	89 f8                	mov    %edi,%eax
  8008e4:	5b                   	pop    %ebx
  8008e5:	5e                   	pop    %esi
  8008e6:	5f                   	pop    %edi
  8008e7:	5d                   	pop    %ebp
  8008e8:	c3                   	ret    

008008e9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e9:	55                   	push   %ebp
  8008ea:	89 e5                	mov    %esp,%ebp
  8008ec:	57                   	push   %edi
  8008ed:	56                   	push   %esi
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f7:	39 c6                	cmp    %eax,%esi
  8008f9:	73 35                	jae    800930 <memmove+0x47>
  8008fb:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008fe:	39 d0                	cmp    %edx,%eax
  800900:	73 2e                	jae    800930 <memmove+0x47>
		s += n;
		d += n;
  800902:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800905:	89 d6                	mov    %edx,%esi
  800907:	09 fe                	or     %edi,%esi
  800909:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80090f:	75 13                	jne    800924 <memmove+0x3b>
  800911:	f6 c1 03             	test   $0x3,%cl
  800914:	75 0e                	jne    800924 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800916:	83 ef 04             	sub    $0x4,%edi
  800919:	8d 72 fc             	lea    -0x4(%edx),%esi
  80091c:	c1 e9 02             	shr    $0x2,%ecx
  80091f:	fd                   	std    
  800920:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800922:	eb 09                	jmp    80092d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800924:	83 ef 01             	sub    $0x1,%edi
  800927:	8d 72 ff             	lea    -0x1(%edx),%esi
  80092a:	fd                   	std    
  80092b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80092d:	fc                   	cld    
  80092e:	eb 1d                	jmp    80094d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800930:	89 f2                	mov    %esi,%edx
  800932:	09 c2                	or     %eax,%edx
  800934:	f6 c2 03             	test   $0x3,%dl
  800937:	75 0f                	jne    800948 <memmove+0x5f>
  800939:	f6 c1 03             	test   $0x3,%cl
  80093c:	75 0a                	jne    800948 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80093e:	c1 e9 02             	shr    $0x2,%ecx
  800941:	89 c7                	mov    %eax,%edi
  800943:	fc                   	cld    
  800944:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800946:	eb 05                	jmp    80094d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800948:	89 c7                	mov    %eax,%edi
  80094a:	fc                   	cld    
  80094b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094d:	5e                   	pop    %esi
  80094e:	5f                   	pop    %edi
  80094f:	5d                   	pop    %ebp
  800950:	c3                   	ret    

00800951 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800954:	ff 75 10             	pushl  0x10(%ebp)
  800957:	ff 75 0c             	pushl  0xc(%ebp)
  80095a:	ff 75 08             	pushl  0x8(%ebp)
  80095d:	e8 87 ff ff ff       	call   8008e9 <memmove>
}
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	8b 45 08             	mov    0x8(%ebp),%eax
  80096c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096f:	89 c6                	mov    %eax,%esi
  800971:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800974:	eb 1a                	jmp    800990 <memcmp+0x2c>
		if (*s1 != *s2)
  800976:	0f b6 08             	movzbl (%eax),%ecx
  800979:	0f b6 1a             	movzbl (%edx),%ebx
  80097c:	38 d9                	cmp    %bl,%cl
  80097e:	74 0a                	je     80098a <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800980:	0f b6 c1             	movzbl %cl,%eax
  800983:	0f b6 db             	movzbl %bl,%ebx
  800986:	29 d8                	sub    %ebx,%eax
  800988:	eb 0f                	jmp    800999 <memcmp+0x35>
		s1++, s2++;
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800990:	39 f0                	cmp    %esi,%eax
  800992:	75 e2                	jne    800976 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800994:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800999:	5b                   	pop    %ebx
  80099a:	5e                   	pop    %esi
  80099b:	5d                   	pop    %ebp
  80099c:	c3                   	ret    

0080099d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099d:	55                   	push   %ebp
  80099e:	89 e5                	mov    %esp,%ebp
  8009a0:	53                   	push   %ebx
  8009a1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a4:	89 c1                	mov    %eax,%ecx
  8009a6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ad:	eb 0a                	jmp    8009b9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009af:	0f b6 10             	movzbl (%eax),%edx
  8009b2:	39 da                	cmp    %ebx,%edx
  8009b4:	74 07                	je     8009bd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b6:	83 c0 01             	add    $0x1,%eax
  8009b9:	39 c8                	cmp    %ecx,%eax
  8009bb:	72 f2                	jb     8009af <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009bd:	5b                   	pop    %ebx
  8009be:	5d                   	pop    %ebp
  8009bf:	c3                   	ret    

008009c0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009c0:	55                   	push   %ebp
  8009c1:	89 e5                	mov    %esp,%ebp
  8009c3:	57                   	push   %edi
  8009c4:	56                   	push   %esi
  8009c5:	53                   	push   %ebx
  8009c6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cc:	eb 03                	jmp    8009d1 <strtol+0x11>
		s++;
  8009ce:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009d1:	0f b6 01             	movzbl (%ecx),%eax
  8009d4:	3c 20                	cmp    $0x20,%al
  8009d6:	74 f6                	je     8009ce <strtol+0xe>
  8009d8:	3c 09                	cmp    $0x9,%al
  8009da:	74 f2                	je     8009ce <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009dc:	3c 2b                	cmp    $0x2b,%al
  8009de:	75 0a                	jne    8009ea <strtol+0x2a>
		s++;
  8009e0:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e3:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e8:	eb 11                	jmp    8009fb <strtol+0x3b>
  8009ea:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ef:	3c 2d                	cmp    $0x2d,%al
  8009f1:	75 08                	jne    8009fb <strtol+0x3b>
		s++, neg = 1;
  8009f3:	83 c1 01             	add    $0x1,%ecx
  8009f6:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a01:	75 15                	jne    800a18 <strtol+0x58>
  800a03:	80 39 30             	cmpb   $0x30,(%ecx)
  800a06:	75 10                	jne    800a18 <strtol+0x58>
  800a08:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a0c:	75 7c                	jne    800a8a <strtol+0xca>
		s += 2, base = 16;
  800a0e:	83 c1 02             	add    $0x2,%ecx
  800a11:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a16:	eb 16                	jmp    800a2e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a18:	85 db                	test   %ebx,%ebx
  800a1a:	75 12                	jne    800a2e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a1c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a21:	80 39 30             	cmpb   $0x30,(%ecx)
  800a24:	75 08                	jne    800a2e <strtol+0x6e>
		s++, base = 8;
  800a26:	83 c1 01             	add    $0x1,%ecx
  800a29:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a2e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a33:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a36:	0f b6 11             	movzbl (%ecx),%edx
  800a39:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a3c:	89 f3                	mov    %esi,%ebx
  800a3e:	80 fb 09             	cmp    $0x9,%bl
  800a41:	77 08                	ja     800a4b <strtol+0x8b>
			dig = *s - '0';
  800a43:	0f be d2             	movsbl %dl,%edx
  800a46:	83 ea 30             	sub    $0x30,%edx
  800a49:	eb 22                	jmp    800a6d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a4b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a4e:	89 f3                	mov    %esi,%ebx
  800a50:	80 fb 19             	cmp    $0x19,%bl
  800a53:	77 08                	ja     800a5d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a55:	0f be d2             	movsbl %dl,%edx
  800a58:	83 ea 57             	sub    $0x57,%edx
  800a5b:	eb 10                	jmp    800a6d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a5d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a60:	89 f3                	mov    %esi,%ebx
  800a62:	80 fb 19             	cmp    $0x19,%bl
  800a65:	77 16                	ja     800a7d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a67:	0f be d2             	movsbl %dl,%edx
  800a6a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a6d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a70:	7d 0b                	jge    800a7d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a72:	83 c1 01             	add    $0x1,%ecx
  800a75:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a79:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a7b:	eb b9                	jmp    800a36 <strtol+0x76>

	if (endptr)
  800a7d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a81:	74 0d                	je     800a90 <strtol+0xd0>
		*endptr = (char *) s;
  800a83:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a86:	89 0e                	mov    %ecx,(%esi)
  800a88:	eb 06                	jmp    800a90 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a8a:	85 db                	test   %ebx,%ebx
  800a8c:	74 98                	je     800a26 <strtol+0x66>
  800a8e:	eb 9e                	jmp    800a2e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a90:	89 c2                	mov    %eax,%edx
  800a92:	f7 da                	neg    %edx
  800a94:	85 ff                	test   %edi,%edi
  800a96:	0f 45 c2             	cmovne %edx,%eax
}
  800a99:	5b                   	pop    %ebx
  800a9a:	5e                   	pop    %esi
  800a9b:	5f                   	pop    %edi
  800a9c:	5d                   	pop    %ebp
  800a9d:	c3                   	ret    

00800a9e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a9e:	55                   	push   %ebp
  800a9f:	89 e5                	mov    %esp,%ebp
  800aa1:	57                   	push   %edi
  800aa2:	56                   	push   %esi
  800aa3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa4:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aac:	8b 55 08             	mov    0x8(%ebp),%edx
  800aaf:	89 c3                	mov    %eax,%ebx
  800ab1:	89 c7                	mov    %eax,%edi
  800ab3:	89 c6                	mov    %eax,%esi
  800ab5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5f                   	pop    %edi
  800aba:	5d                   	pop    %ebp
  800abb:	c3                   	ret    

00800abc <sys_cgetc>:

int
sys_cgetc(void)
{
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	57                   	push   %edi
  800ac0:	56                   	push   %esi
  800ac1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac7:	b8 01 00 00 00       	mov    $0x1,%eax
  800acc:	89 d1                	mov    %edx,%ecx
  800ace:	89 d3                	mov    %edx,%ebx
  800ad0:	89 d7                	mov    %edx,%edi
  800ad2:	89 d6                	mov    %edx,%esi
  800ad4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad6:	5b                   	pop    %ebx
  800ad7:	5e                   	pop    %esi
  800ad8:	5f                   	pop    %edi
  800ad9:	5d                   	pop    %ebp
  800ada:	c3                   	ret    

00800adb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800adb:	55                   	push   %ebp
  800adc:	89 e5                	mov    %esp,%ebp
  800ade:	57                   	push   %edi
  800adf:	56                   	push   %esi
  800ae0:	53                   	push   %ebx
  800ae1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae9:	b8 03 00 00 00       	mov    $0x3,%eax
  800aee:	8b 55 08             	mov    0x8(%ebp),%edx
  800af1:	89 cb                	mov    %ecx,%ebx
  800af3:	89 cf                	mov    %ecx,%edi
  800af5:	89 ce                	mov    %ecx,%esi
  800af7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800af9:	85 c0                	test   %eax,%eax
  800afb:	7e 17                	jle    800b14 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afd:	83 ec 0c             	sub    $0xc,%esp
  800b00:	50                   	push   %eax
  800b01:	6a 03                	push   $0x3
  800b03:	68 5f 21 80 00       	push   $0x80215f
  800b08:	6a 23                	push   $0x23
  800b0a:	68 7c 21 80 00       	push   $0x80217c
  800b0f:	e8 21 0f 00 00       	call   801a35 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b14:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b17:	5b                   	pop    %ebx
  800b18:	5e                   	pop    %esi
  800b19:	5f                   	pop    %edi
  800b1a:	5d                   	pop    %ebp
  800b1b:	c3                   	ret    

00800b1c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	57                   	push   %edi
  800b20:	56                   	push   %esi
  800b21:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b22:	ba 00 00 00 00       	mov    $0x0,%edx
  800b27:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2c:	89 d1                	mov    %edx,%ecx
  800b2e:	89 d3                	mov    %edx,%ebx
  800b30:	89 d7                	mov    %edx,%edi
  800b32:	89 d6                	mov    %edx,%esi
  800b34:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <sys_yield>:

void
sys_yield(void)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b41:	ba 00 00 00 00       	mov    $0x0,%edx
  800b46:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b4b:	89 d1                	mov    %edx,%ecx
  800b4d:	89 d3                	mov    %edx,%ebx
  800b4f:	89 d7                	mov    %edx,%edi
  800b51:	89 d6                	mov    %edx,%esi
  800b53:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b55:	5b                   	pop    %ebx
  800b56:	5e                   	pop    %esi
  800b57:	5f                   	pop    %edi
  800b58:	5d                   	pop    %ebp
  800b59:	c3                   	ret    

00800b5a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	57                   	push   %edi
  800b5e:	56                   	push   %esi
  800b5f:	53                   	push   %ebx
  800b60:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b63:	be 00 00 00 00       	mov    $0x0,%esi
  800b68:	b8 04 00 00 00       	mov    $0x4,%eax
  800b6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b70:	8b 55 08             	mov    0x8(%ebp),%edx
  800b73:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b76:	89 f7                	mov    %esi,%edi
  800b78:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b7a:	85 c0                	test   %eax,%eax
  800b7c:	7e 17                	jle    800b95 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7e:	83 ec 0c             	sub    $0xc,%esp
  800b81:	50                   	push   %eax
  800b82:	6a 04                	push   $0x4
  800b84:	68 5f 21 80 00       	push   $0x80215f
  800b89:	6a 23                	push   $0x23
  800b8b:	68 7c 21 80 00       	push   $0x80217c
  800b90:	e8 a0 0e 00 00       	call   801a35 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b98:	5b                   	pop    %ebx
  800b99:	5e                   	pop    %esi
  800b9a:	5f                   	pop    %edi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bae:	8b 55 08             	mov    0x8(%ebp),%edx
  800bb1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bbc:	85 c0                	test   %eax,%eax
  800bbe:	7e 17                	jle    800bd7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bc0:	83 ec 0c             	sub    $0xc,%esp
  800bc3:	50                   	push   %eax
  800bc4:	6a 05                	push   $0x5
  800bc6:	68 5f 21 80 00       	push   $0x80215f
  800bcb:	6a 23                	push   $0x23
  800bcd:	68 7c 21 80 00       	push   $0x80217c
  800bd2:	e8 5e 0e 00 00       	call   801a35 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bda:	5b                   	pop    %ebx
  800bdb:	5e                   	pop    %esi
  800bdc:	5f                   	pop    %edi
  800bdd:	5d                   	pop    %ebp
  800bde:	c3                   	ret    

00800bdf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bdf:	55                   	push   %ebp
  800be0:	89 e5                	mov    %esp,%ebp
  800be2:	57                   	push   %edi
  800be3:	56                   	push   %esi
  800be4:	53                   	push   %ebx
  800be5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be8:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bed:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf8:	89 df                	mov    %ebx,%edi
  800bfa:	89 de                	mov    %ebx,%esi
  800bfc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfe:	85 c0                	test   %eax,%eax
  800c00:	7e 17                	jle    800c19 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c02:	83 ec 0c             	sub    $0xc,%esp
  800c05:	50                   	push   %eax
  800c06:	6a 06                	push   $0x6
  800c08:	68 5f 21 80 00       	push   $0x80215f
  800c0d:	6a 23                	push   $0x23
  800c0f:	68 7c 21 80 00       	push   $0x80217c
  800c14:	e8 1c 0e 00 00       	call   801a35 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1c:	5b                   	pop    %ebx
  800c1d:	5e                   	pop    %esi
  800c1e:	5f                   	pop    %edi
  800c1f:	5d                   	pop    %ebp
  800c20:	c3                   	ret    

00800c21 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c21:	55                   	push   %ebp
  800c22:	89 e5                	mov    %esp,%ebp
  800c24:	57                   	push   %edi
  800c25:	56                   	push   %esi
  800c26:	53                   	push   %ebx
  800c27:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c2a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c34:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c37:	8b 55 08             	mov    0x8(%ebp),%edx
  800c3a:	89 df                	mov    %ebx,%edi
  800c3c:	89 de                	mov    %ebx,%esi
  800c3e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c40:	85 c0                	test   %eax,%eax
  800c42:	7e 17                	jle    800c5b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c44:	83 ec 0c             	sub    $0xc,%esp
  800c47:	50                   	push   %eax
  800c48:	6a 08                	push   $0x8
  800c4a:	68 5f 21 80 00       	push   $0x80215f
  800c4f:	6a 23                	push   $0x23
  800c51:	68 7c 21 80 00       	push   $0x80217c
  800c56:	e8 da 0d 00 00       	call   801a35 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5e:	5b                   	pop    %ebx
  800c5f:	5e                   	pop    %esi
  800c60:	5f                   	pop    %edi
  800c61:	5d                   	pop    %ebp
  800c62:	c3                   	ret    

00800c63 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	57                   	push   %edi
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c71:	b8 09 00 00 00       	mov    $0x9,%eax
  800c76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c79:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7c:	89 df                	mov    %ebx,%edi
  800c7e:	89 de                	mov    %ebx,%esi
  800c80:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c82:	85 c0                	test   %eax,%eax
  800c84:	7e 17                	jle    800c9d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c86:	83 ec 0c             	sub    $0xc,%esp
  800c89:	50                   	push   %eax
  800c8a:	6a 09                	push   $0x9
  800c8c:	68 5f 21 80 00       	push   $0x80215f
  800c91:	6a 23                	push   $0x23
  800c93:	68 7c 21 80 00       	push   $0x80217c
  800c98:	e8 98 0d 00 00       	call   801a35 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5f                   	pop    %edi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	57                   	push   %edi
  800ca9:	56                   	push   %esi
  800caa:	53                   	push   %ebx
  800cab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cae:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cbb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbe:	89 df                	mov    %ebx,%edi
  800cc0:	89 de                	mov    %ebx,%esi
  800cc2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc4:	85 c0                	test   %eax,%eax
  800cc6:	7e 17                	jle    800cdf <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc8:	83 ec 0c             	sub    $0xc,%esp
  800ccb:	50                   	push   %eax
  800ccc:	6a 0a                	push   $0xa
  800cce:	68 5f 21 80 00       	push   $0x80215f
  800cd3:	6a 23                	push   $0x23
  800cd5:	68 7c 21 80 00       	push   $0x80217c
  800cda:	e8 56 0d 00 00       	call   801a35 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cdf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce2:	5b                   	pop    %ebx
  800ce3:	5e                   	pop    %esi
  800ce4:	5f                   	pop    %edi
  800ce5:	5d                   	pop    %ebp
  800ce6:	c3                   	ret    

00800ce7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce7:	55                   	push   %ebp
  800ce8:	89 e5                	mov    %esp,%ebp
  800cea:	57                   	push   %edi
  800ceb:	56                   	push   %esi
  800cec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ced:	be 00 00 00 00       	mov    $0x0,%esi
  800cf2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfa:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d00:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d03:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d05:	5b                   	pop    %ebx
  800d06:	5e                   	pop    %esi
  800d07:	5f                   	pop    %edi
  800d08:	5d                   	pop    %ebp
  800d09:	c3                   	ret    

00800d0a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d0a:	55                   	push   %ebp
  800d0b:	89 e5                	mov    %esp,%ebp
  800d0d:	57                   	push   %edi
  800d0e:	56                   	push   %esi
  800d0f:	53                   	push   %ebx
  800d10:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d13:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d18:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d1d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d20:	89 cb                	mov    %ecx,%ebx
  800d22:	89 cf                	mov    %ecx,%edi
  800d24:	89 ce                	mov    %ecx,%esi
  800d26:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d28:	85 c0                	test   %eax,%eax
  800d2a:	7e 17                	jle    800d43 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2c:	83 ec 0c             	sub    $0xc,%esp
  800d2f:	50                   	push   %eax
  800d30:	6a 0d                	push   $0xd
  800d32:	68 5f 21 80 00       	push   $0x80215f
  800d37:	6a 23                	push   $0x23
  800d39:	68 7c 21 80 00       	push   $0x80217c
  800d3e:	e8 f2 0c 00 00       	call   801a35 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d46:	5b                   	pop    %ebx
  800d47:	5e                   	pop    %esi
  800d48:	5f                   	pop    %edi
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d51:	05 00 00 00 30       	add    $0x30000000,%eax
  800d56:	c1 e8 0c             	shr    $0xc,%eax
}
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d61:	05 00 00 00 30       	add    $0x30000000,%eax
  800d66:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d6b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d70:	5d                   	pop    %ebp
  800d71:	c3                   	ret    

00800d72 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d72:	55                   	push   %ebp
  800d73:	89 e5                	mov    %esp,%ebp
  800d75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d78:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800d7d:	89 c2                	mov    %eax,%edx
  800d7f:	c1 ea 16             	shr    $0x16,%edx
  800d82:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d89:	f6 c2 01             	test   $0x1,%dl
  800d8c:	74 11                	je     800d9f <fd_alloc+0x2d>
  800d8e:	89 c2                	mov    %eax,%edx
  800d90:	c1 ea 0c             	shr    $0xc,%edx
  800d93:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d9a:	f6 c2 01             	test   $0x1,%dl
  800d9d:	75 09                	jne    800da8 <fd_alloc+0x36>
			*fd_store = fd;
  800d9f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800da1:	b8 00 00 00 00       	mov    $0x0,%eax
  800da6:	eb 17                	jmp    800dbf <fd_alloc+0x4d>
  800da8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dad:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800db2:	75 c9                	jne    800d7d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800db4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800dba:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dbf:	5d                   	pop    %ebp
  800dc0:	c3                   	ret    

00800dc1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dc1:	55                   	push   %ebp
  800dc2:	89 e5                	mov    %esp,%ebp
  800dc4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800dc7:	83 f8 1f             	cmp    $0x1f,%eax
  800dca:	77 36                	ja     800e02 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800dcc:	c1 e0 0c             	shl    $0xc,%eax
  800dcf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800dd4:	89 c2                	mov    %eax,%edx
  800dd6:	c1 ea 16             	shr    $0x16,%edx
  800dd9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800de0:	f6 c2 01             	test   $0x1,%dl
  800de3:	74 24                	je     800e09 <fd_lookup+0x48>
  800de5:	89 c2                	mov    %eax,%edx
  800de7:	c1 ea 0c             	shr    $0xc,%edx
  800dea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800df1:	f6 c2 01             	test   $0x1,%dl
  800df4:	74 1a                	je     800e10 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800df6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800df9:	89 02                	mov    %eax,(%edx)
	return 0;
  800dfb:	b8 00 00 00 00       	mov    $0x0,%eax
  800e00:	eb 13                	jmp    800e15 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e02:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e07:	eb 0c                	jmp    800e15 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e09:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e0e:	eb 05                	jmp    800e15 <fd_lookup+0x54>
  800e10:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e15:	5d                   	pop    %ebp
  800e16:	c3                   	ret    

00800e17 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e17:	55                   	push   %ebp
  800e18:	89 e5                	mov    %esp,%ebp
  800e1a:	83 ec 08             	sub    $0x8,%esp
  800e1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e20:	ba 08 22 80 00       	mov    $0x802208,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e25:	eb 13                	jmp    800e3a <dev_lookup+0x23>
  800e27:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e2a:	39 08                	cmp    %ecx,(%eax)
  800e2c:	75 0c                	jne    800e3a <dev_lookup+0x23>
			*dev = devtab[i];
  800e2e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e31:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e33:	b8 00 00 00 00       	mov    $0x0,%eax
  800e38:	eb 2e                	jmp    800e68 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e3a:	8b 02                	mov    (%edx),%eax
  800e3c:	85 c0                	test   %eax,%eax
  800e3e:	75 e7                	jne    800e27 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e40:	a1 08 40 80 00       	mov    0x804008,%eax
  800e45:	8b 40 48             	mov    0x48(%eax),%eax
  800e48:	83 ec 04             	sub    $0x4,%esp
  800e4b:	51                   	push   %ecx
  800e4c:	50                   	push   %eax
  800e4d:	68 8c 21 80 00       	push   $0x80218c
  800e52:	e8 fc f2 ff ff       	call   800153 <cprintf>
	*dev = 0;
  800e57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e60:	83 c4 10             	add    $0x10,%esp
  800e63:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e68:	c9                   	leave  
  800e69:	c3                   	ret    

00800e6a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e6a:	55                   	push   %ebp
  800e6b:	89 e5                	mov    %esp,%ebp
  800e6d:	56                   	push   %esi
  800e6e:	53                   	push   %ebx
  800e6f:	83 ec 10             	sub    $0x10,%esp
  800e72:	8b 75 08             	mov    0x8(%ebp),%esi
  800e75:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e78:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e7b:	50                   	push   %eax
  800e7c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800e82:	c1 e8 0c             	shr    $0xc,%eax
  800e85:	50                   	push   %eax
  800e86:	e8 36 ff ff ff       	call   800dc1 <fd_lookup>
  800e8b:	83 c4 08             	add    $0x8,%esp
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	78 05                	js     800e97 <fd_close+0x2d>
	    || fd != fd2)
  800e92:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800e95:	74 0c                	je     800ea3 <fd_close+0x39>
		return (must_exist ? r : 0);
  800e97:	84 db                	test   %bl,%bl
  800e99:	ba 00 00 00 00       	mov    $0x0,%edx
  800e9e:	0f 44 c2             	cmove  %edx,%eax
  800ea1:	eb 41                	jmp    800ee4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ea3:	83 ec 08             	sub    $0x8,%esp
  800ea6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ea9:	50                   	push   %eax
  800eaa:	ff 36                	pushl  (%esi)
  800eac:	e8 66 ff ff ff       	call   800e17 <dev_lookup>
  800eb1:	89 c3                	mov    %eax,%ebx
  800eb3:	83 c4 10             	add    $0x10,%esp
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	78 1a                	js     800ed4 <fd_close+0x6a>
		if (dev->dev_close)
  800eba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ebd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800ec0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ec5:	85 c0                	test   %eax,%eax
  800ec7:	74 0b                	je     800ed4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ec9:	83 ec 0c             	sub    $0xc,%esp
  800ecc:	56                   	push   %esi
  800ecd:	ff d0                	call   *%eax
  800ecf:	89 c3                	mov    %eax,%ebx
  800ed1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800ed4:	83 ec 08             	sub    $0x8,%esp
  800ed7:	56                   	push   %esi
  800ed8:	6a 00                	push   $0x0
  800eda:	e8 00 fd ff ff       	call   800bdf <sys_page_unmap>
	return r;
  800edf:	83 c4 10             	add    $0x10,%esp
  800ee2:	89 d8                	mov    %ebx,%eax
}
  800ee4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ee7:	5b                   	pop    %ebx
  800ee8:	5e                   	pop    %esi
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ef1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ef4:	50                   	push   %eax
  800ef5:	ff 75 08             	pushl  0x8(%ebp)
  800ef8:	e8 c4 fe ff ff       	call   800dc1 <fd_lookup>
  800efd:	83 c4 08             	add    $0x8,%esp
  800f00:	85 c0                	test   %eax,%eax
  800f02:	78 10                	js     800f14 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f04:	83 ec 08             	sub    $0x8,%esp
  800f07:	6a 01                	push   $0x1
  800f09:	ff 75 f4             	pushl  -0xc(%ebp)
  800f0c:	e8 59 ff ff ff       	call   800e6a <fd_close>
  800f11:	83 c4 10             	add    $0x10,%esp
}
  800f14:	c9                   	leave  
  800f15:	c3                   	ret    

00800f16 <close_all>:

void
close_all(void)
{
  800f16:	55                   	push   %ebp
  800f17:	89 e5                	mov    %esp,%ebp
  800f19:	53                   	push   %ebx
  800f1a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f1d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f22:	83 ec 0c             	sub    $0xc,%esp
  800f25:	53                   	push   %ebx
  800f26:	e8 c0 ff ff ff       	call   800eeb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f2b:	83 c3 01             	add    $0x1,%ebx
  800f2e:	83 c4 10             	add    $0x10,%esp
  800f31:	83 fb 20             	cmp    $0x20,%ebx
  800f34:	75 ec                	jne    800f22 <close_all+0xc>
		close(i);
}
  800f36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f39:	c9                   	leave  
  800f3a:	c3                   	ret    

00800f3b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f3b:	55                   	push   %ebp
  800f3c:	89 e5                	mov    %esp,%ebp
  800f3e:	57                   	push   %edi
  800f3f:	56                   	push   %esi
  800f40:	53                   	push   %ebx
  800f41:	83 ec 2c             	sub    $0x2c,%esp
  800f44:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f47:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f4a:	50                   	push   %eax
  800f4b:	ff 75 08             	pushl  0x8(%ebp)
  800f4e:	e8 6e fe ff ff       	call   800dc1 <fd_lookup>
  800f53:	83 c4 08             	add    $0x8,%esp
  800f56:	85 c0                	test   %eax,%eax
  800f58:	0f 88 c1 00 00 00    	js     80101f <dup+0xe4>
		return r;
	close(newfdnum);
  800f5e:	83 ec 0c             	sub    $0xc,%esp
  800f61:	56                   	push   %esi
  800f62:	e8 84 ff ff ff       	call   800eeb <close>

	newfd = INDEX2FD(newfdnum);
  800f67:	89 f3                	mov    %esi,%ebx
  800f69:	c1 e3 0c             	shl    $0xc,%ebx
  800f6c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f72:	83 c4 04             	add    $0x4,%esp
  800f75:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f78:	e8 de fd ff ff       	call   800d5b <fd2data>
  800f7d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800f7f:	89 1c 24             	mov    %ebx,(%esp)
  800f82:	e8 d4 fd ff ff       	call   800d5b <fd2data>
  800f87:	83 c4 10             	add    $0x10,%esp
  800f8a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f8d:	89 f8                	mov    %edi,%eax
  800f8f:	c1 e8 16             	shr    $0x16,%eax
  800f92:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f99:	a8 01                	test   $0x1,%al
  800f9b:	74 37                	je     800fd4 <dup+0x99>
  800f9d:	89 f8                	mov    %edi,%eax
  800f9f:	c1 e8 0c             	shr    $0xc,%eax
  800fa2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fa9:	f6 c2 01             	test   $0x1,%dl
  800fac:	74 26                	je     800fd4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fb5:	83 ec 0c             	sub    $0xc,%esp
  800fb8:	25 07 0e 00 00       	and    $0xe07,%eax
  800fbd:	50                   	push   %eax
  800fbe:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fc1:	6a 00                	push   $0x0
  800fc3:	57                   	push   %edi
  800fc4:	6a 00                	push   $0x0
  800fc6:	e8 d2 fb ff ff       	call   800b9d <sys_page_map>
  800fcb:	89 c7                	mov    %eax,%edi
  800fcd:	83 c4 20             	add    $0x20,%esp
  800fd0:	85 c0                	test   %eax,%eax
  800fd2:	78 2e                	js     801002 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800fd4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800fd7:	89 d0                	mov    %edx,%eax
  800fd9:	c1 e8 0c             	shr    $0xc,%eax
  800fdc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe3:	83 ec 0c             	sub    $0xc,%esp
  800fe6:	25 07 0e 00 00       	and    $0xe07,%eax
  800feb:	50                   	push   %eax
  800fec:	53                   	push   %ebx
  800fed:	6a 00                	push   $0x0
  800fef:	52                   	push   %edx
  800ff0:	6a 00                	push   $0x0
  800ff2:	e8 a6 fb ff ff       	call   800b9d <sys_page_map>
  800ff7:	89 c7                	mov    %eax,%edi
  800ff9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800ffc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800ffe:	85 ff                	test   %edi,%edi
  801000:	79 1d                	jns    80101f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801002:	83 ec 08             	sub    $0x8,%esp
  801005:	53                   	push   %ebx
  801006:	6a 00                	push   $0x0
  801008:	e8 d2 fb ff ff       	call   800bdf <sys_page_unmap>
	sys_page_unmap(0, nva);
  80100d:	83 c4 08             	add    $0x8,%esp
  801010:	ff 75 d4             	pushl  -0x2c(%ebp)
  801013:	6a 00                	push   $0x0
  801015:	e8 c5 fb ff ff       	call   800bdf <sys_page_unmap>
	return r;
  80101a:	83 c4 10             	add    $0x10,%esp
  80101d:	89 f8                	mov    %edi,%eax
}
  80101f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801022:	5b                   	pop    %ebx
  801023:	5e                   	pop    %esi
  801024:	5f                   	pop    %edi
  801025:	5d                   	pop    %ebp
  801026:	c3                   	ret    

00801027 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801027:	55                   	push   %ebp
  801028:	89 e5                	mov    %esp,%ebp
  80102a:	53                   	push   %ebx
  80102b:	83 ec 14             	sub    $0x14,%esp
  80102e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801031:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801034:	50                   	push   %eax
  801035:	53                   	push   %ebx
  801036:	e8 86 fd ff ff       	call   800dc1 <fd_lookup>
  80103b:	83 c4 08             	add    $0x8,%esp
  80103e:	89 c2                	mov    %eax,%edx
  801040:	85 c0                	test   %eax,%eax
  801042:	78 6d                	js     8010b1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801044:	83 ec 08             	sub    $0x8,%esp
  801047:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80104a:	50                   	push   %eax
  80104b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80104e:	ff 30                	pushl  (%eax)
  801050:	e8 c2 fd ff ff       	call   800e17 <dev_lookup>
  801055:	83 c4 10             	add    $0x10,%esp
  801058:	85 c0                	test   %eax,%eax
  80105a:	78 4c                	js     8010a8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80105c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80105f:	8b 42 08             	mov    0x8(%edx),%eax
  801062:	83 e0 03             	and    $0x3,%eax
  801065:	83 f8 01             	cmp    $0x1,%eax
  801068:	75 21                	jne    80108b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80106a:	a1 08 40 80 00       	mov    0x804008,%eax
  80106f:	8b 40 48             	mov    0x48(%eax),%eax
  801072:	83 ec 04             	sub    $0x4,%esp
  801075:	53                   	push   %ebx
  801076:	50                   	push   %eax
  801077:	68 cd 21 80 00       	push   $0x8021cd
  80107c:	e8 d2 f0 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  801081:	83 c4 10             	add    $0x10,%esp
  801084:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801089:	eb 26                	jmp    8010b1 <read+0x8a>
	}
	if (!dev->dev_read)
  80108b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80108e:	8b 40 08             	mov    0x8(%eax),%eax
  801091:	85 c0                	test   %eax,%eax
  801093:	74 17                	je     8010ac <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801095:	83 ec 04             	sub    $0x4,%esp
  801098:	ff 75 10             	pushl  0x10(%ebp)
  80109b:	ff 75 0c             	pushl  0xc(%ebp)
  80109e:	52                   	push   %edx
  80109f:	ff d0                	call   *%eax
  8010a1:	89 c2                	mov    %eax,%edx
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	eb 09                	jmp    8010b1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010a8:	89 c2                	mov    %eax,%edx
  8010aa:	eb 05                	jmp    8010b1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010b1:	89 d0                	mov    %edx,%eax
  8010b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b6:	c9                   	leave  
  8010b7:	c3                   	ret    

008010b8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	57                   	push   %edi
  8010bc:	56                   	push   %esi
  8010bd:	53                   	push   %ebx
  8010be:	83 ec 0c             	sub    $0xc,%esp
  8010c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010c4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010cc:	eb 21                	jmp    8010ef <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010ce:	83 ec 04             	sub    $0x4,%esp
  8010d1:	89 f0                	mov    %esi,%eax
  8010d3:	29 d8                	sub    %ebx,%eax
  8010d5:	50                   	push   %eax
  8010d6:	89 d8                	mov    %ebx,%eax
  8010d8:	03 45 0c             	add    0xc(%ebp),%eax
  8010db:	50                   	push   %eax
  8010dc:	57                   	push   %edi
  8010dd:	e8 45 ff ff ff       	call   801027 <read>
		if (m < 0)
  8010e2:	83 c4 10             	add    $0x10,%esp
  8010e5:	85 c0                	test   %eax,%eax
  8010e7:	78 10                	js     8010f9 <readn+0x41>
			return m;
		if (m == 0)
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	74 0a                	je     8010f7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010ed:	01 c3                	add    %eax,%ebx
  8010ef:	39 f3                	cmp    %esi,%ebx
  8010f1:	72 db                	jb     8010ce <readn+0x16>
  8010f3:	89 d8                	mov    %ebx,%eax
  8010f5:	eb 02                	jmp    8010f9 <readn+0x41>
  8010f7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8010f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fc:	5b                   	pop    %ebx
  8010fd:	5e                   	pop    %esi
  8010fe:	5f                   	pop    %edi
  8010ff:	5d                   	pop    %ebp
  801100:	c3                   	ret    

00801101 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801101:	55                   	push   %ebp
  801102:	89 e5                	mov    %esp,%ebp
  801104:	53                   	push   %ebx
  801105:	83 ec 14             	sub    $0x14,%esp
  801108:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80110b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80110e:	50                   	push   %eax
  80110f:	53                   	push   %ebx
  801110:	e8 ac fc ff ff       	call   800dc1 <fd_lookup>
  801115:	83 c4 08             	add    $0x8,%esp
  801118:	89 c2                	mov    %eax,%edx
  80111a:	85 c0                	test   %eax,%eax
  80111c:	78 68                	js     801186 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80111e:	83 ec 08             	sub    $0x8,%esp
  801121:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801124:	50                   	push   %eax
  801125:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801128:	ff 30                	pushl  (%eax)
  80112a:	e8 e8 fc ff ff       	call   800e17 <dev_lookup>
  80112f:	83 c4 10             	add    $0x10,%esp
  801132:	85 c0                	test   %eax,%eax
  801134:	78 47                	js     80117d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801136:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801139:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80113d:	75 21                	jne    801160 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80113f:	a1 08 40 80 00       	mov    0x804008,%eax
  801144:	8b 40 48             	mov    0x48(%eax),%eax
  801147:	83 ec 04             	sub    $0x4,%esp
  80114a:	53                   	push   %ebx
  80114b:	50                   	push   %eax
  80114c:	68 e9 21 80 00       	push   $0x8021e9
  801151:	e8 fd ef ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  801156:	83 c4 10             	add    $0x10,%esp
  801159:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80115e:	eb 26                	jmp    801186 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801160:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801163:	8b 52 0c             	mov    0xc(%edx),%edx
  801166:	85 d2                	test   %edx,%edx
  801168:	74 17                	je     801181 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80116a:	83 ec 04             	sub    $0x4,%esp
  80116d:	ff 75 10             	pushl  0x10(%ebp)
  801170:	ff 75 0c             	pushl  0xc(%ebp)
  801173:	50                   	push   %eax
  801174:	ff d2                	call   *%edx
  801176:	89 c2                	mov    %eax,%edx
  801178:	83 c4 10             	add    $0x10,%esp
  80117b:	eb 09                	jmp    801186 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80117d:	89 c2                	mov    %eax,%edx
  80117f:	eb 05                	jmp    801186 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801181:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801186:	89 d0                	mov    %edx,%eax
  801188:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80118b:	c9                   	leave  
  80118c:	c3                   	ret    

0080118d <seek>:

int
seek(int fdnum, off_t offset)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
  801190:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801193:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801196:	50                   	push   %eax
  801197:	ff 75 08             	pushl  0x8(%ebp)
  80119a:	e8 22 fc ff ff       	call   800dc1 <fd_lookup>
  80119f:	83 c4 08             	add    $0x8,%esp
  8011a2:	85 c0                	test   %eax,%eax
  8011a4:	78 0e                	js     8011b4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011ac:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011b4:	c9                   	leave  
  8011b5:	c3                   	ret    

008011b6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011b6:	55                   	push   %ebp
  8011b7:	89 e5                	mov    %esp,%ebp
  8011b9:	53                   	push   %ebx
  8011ba:	83 ec 14             	sub    $0x14,%esp
  8011bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011c3:	50                   	push   %eax
  8011c4:	53                   	push   %ebx
  8011c5:	e8 f7 fb ff ff       	call   800dc1 <fd_lookup>
  8011ca:	83 c4 08             	add    $0x8,%esp
  8011cd:	89 c2                	mov    %eax,%edx
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	78 65                	js     801238 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d3:	83 ec 08             	sub    $0x8,%esp
  8011d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011d9:	50                   	push   %eax
  8011da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011dd:	ff 30                	pushl  (%eax)
  8011df:	e8 33 fc ff ff       	call   800e17 <dev_lookup>
  8011e4:	83 c4 10             	add    $0x10,%esp
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	78 44                	js     80122f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011ee:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f2:	75 21                	jne    801215 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8011f4:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011f9:	8b 40 48             	mov    0x48(%eax),%eax
  8011fc:	83 ec 04             	sub    $0x4,%esp
  8011ff:	53                   	push   %ebx
  801200:	50                   	push   %eax
  801201:	68 ac 21 80 00       	push   $0x8021ac
  801206:	e8 48 ef ff ff       	call   800153 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80120b:	83 c4 10             	add    $0x10,%esp
  80120e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801213:	eb 23                	jmp    801238 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801215:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801218:	8b 52 18             	mov    0x18(%edx),%edx
  80121b:	85 d2                	test   %edx,%edx
  80121d:	74 14                	je     801233 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80121f:	83 ec 08             	sub    $0x8,%esp
  801222:	ff 75 0c             	pushl  0xc(%ebp)
  801225:	50                   	push   %eax
  801226:	ff d2                	call   *%edx
  801228:	89 c2                	mov    %eax,%edx
  80122a:	83 c4 10             	add    $0x10,%esp
  80122d:	eb 09                	jmp    801238 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80122f:	89 c2                	mov    %eax,%edx
  801231:	eb 05                	jmp    801238 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801233:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801238:	89 d0                	mov    %edx,%eax
  80123a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80123d:	c9                   	leave  
  80123e:	c3                   	ret    

0080123f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80123f:	55                   	push   %ebp
  801240:	89 e5                	mov    %esp,%ebp
  801242:	53                   	push   %ebx
  801243:	83 ec 14             	sub    $0x14,%esp
  801246:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801249:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80124c:	50                   	push   %eax
  80124d:	ff 75 08             	pushl  0x8(%ebp)
  801250:	e8 6c fb ff ff       	call   800dc1 <fd_lookup>
  801255:	83 c4 08             	add    $0x8,%esp
  801258:	89 c2                	mov    %eax,%edx
  80125a:	85 c0                	test   %eax,%eax
  80125c:	78 58                	js     8012b6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125e:	83 ec 08             	sub    $0x8,%esp
  801261:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801264:	50                   	push   %eax
  801265:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801268:	ff 30                	pushl  (%eax)
  80126a:	e8 a8 fb ff ff       	call   800e17 <dev_lookup>
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	78 37                	js     8012ad <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801276:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801279:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80127d:	74 32                	je     8012b1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80127f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801282:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801289:	00 00 00 
	stat->st_isdir = 0;
  80128c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801293:	00 00 00 
	stat->st_dev = dev;
  801296:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80129c:	83 ec 08             	sub    $0x8,%esp
  80129f:	53                   	push   %ebx
  8012a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8012a3:	ff 50 14             	call   *0x14(%eax)
  8012a6:	89 c2                	mov    %eax,%edx
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	eb 09                	jmp    8012b6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ad:	89 c2                	mov    %eax,%edx
  8012af:	eb 05                	jmp    8012b6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012b6:	89 d0                	mov    %edx,%eax
  8012b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012bb:	c9                   	leave  
  8012bc:	c3                   	ret    

008012bd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	56                   	push   %esi
  8012c1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012c2:	83 ec 08             	sub    $0x8,%esp
  8012c5:	6a 00                	push   $0x0
  8012c7:	ff 75 08             	pushl  0x8(%ebp)
  8012ca:	e8 e3 01 00 00       	call   8014b2 <open>
  8012cf:	89 c3                	mov    %eax,%ebx
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	85 c0                	test   %eax,%eax
  8012d6:	78 1b                	js     8012f3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8012d8:	83 ec 08             	sub    $0x8,%esp
  8012db:	ff 75 0c             	pushl  0xc(%ebp)
  8012de:	50                   	push   %eax
  8012df:	e8 5b ff ff ff       	call   80123f <fstat>
  8012e4:	89 c6                	mov    %eax,%esi
	close(fd);
  8012e6:	89 1c 24             	mov    %ebx,(%esp)
  8012e9:	e8 fd fb ff ff       	call   800eeb <close>
	return r;
  8012ee:	83 c4 10             	add    $0x10,%esp
  8012f1:	89 f0                	mov    %esi,%eax
}
  8012f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012f6:	5b                   	pop    %ebx
  8012f7:	5e                   	pop    %esi
  8012f8:	5d                   	pop    %ebp
  8012f9:	c3                   	ret    

008012fa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	56                   	push   %esi
  8012fe:	53                   	push   %ebx
  8012ff:	89 c6                	mov    %eax,%esi
  801301:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801303:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80130a:	75 12                	jne    80131e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80130c:	83 ec 0c             	sub    $0xc,%esp
  80130f:	6a 01                	push   $0x1
  801311:	e8 22 08 00 00       	call   801b38 <ipc_find_env>
  801316:	a3 00 40 80 00       	mov    %eax,0x804000
  80131b:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80131e:	6a 07                	push   $0x7
  801320:	68 00 50 80 00       	push   $0x805000
  801325:	56                   	push   %esi
  801326:	ff 35 00 40 80 00    	pushl  0x804000
  80132c:	e8 b3 07 00 00       	call   801ae4 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801331:	83 c4 0c             	add    $0xc,%esp
  801334:	6a 00                	push   $0x0
  801336:	53                   	push   %ebx
  801337:	6a 00                	push   $0x0
  801339:	e8 3d 07 00 00       	call   801a7b <ipc_recv>
}
  80133e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801341:	5b                   	pop    %ebx
  801342:	5e                   	pop    %esi
  801343:	5d                   	pop    %ebp
  801344:	c3                   	ret    

00801345 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801345:	55                   	push   %ebp
  801346:	89 e5                	mov    %esp,%ebp
  801348:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80134b:	8b 45 08             	mov    0x8(%ebp),%eax
  80134e:	8b 40 0c             	mov    0xc(%eax),%eax
  801351:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801356:	8b 45 0c             	mov    0xc(%ebp),%eax
  801359:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80135e:	ba 00 00 00 00       	mov    $0x0,%edx
  801363:	b8 02 00 00 00       	mov    $0x2,%eax
  801368:	e8 8d ff ff ff       	call   8012fa <fsipc>
}
  80136d:	c9                   	leave  
  80136e:	c3                   	ret    

0080136f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80136f:	55                   	push   %ebp
  801370:	89 e5                	mov    %esp,%ebp
  801372:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801375:	8b 45 08             	mov    0x8(%ebp),%eax
  801378:	8b 40 0c             	mov    0xc(%eax),%eax
  80137b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801380:	ba 00 00 00 00       	mov    $0x0,%edx
  801385:	b8 06 00 00 00       	mov    $0x6,%eax
  80138a:	e8 6b ff ff ff       	call   8012fa <fsipc>
}
  80138f:	c9                   	leave  
  801390:	c3                   	ret    

00801391 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801391:	55                   	push   %ebp
  801392:	89 e5                	mov    %esp,%ebp
  801394:	53                   	push   %ebx
  801395:	83 ec 04             	sub    $0x4,%esp
  801398:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80139b:	8b 45 08             	mov    0x8(%ebp),%eax
  80139e:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ab:	b8 05 00 00 00       	mov    $0x5,%eax
  8013b0:	e8 45 ff ff ff       	call   8012fa <fsipc>
  8013b5:	85 c0                	test   %eax,%eax
  8013b7:	78 2c                	js     8013e5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013b9:	83 ec 08             	sub    $0x8,%esp
  8013bc:	68 00 50 80 00       	push   $0x805000
  8013c1:	53                   	push   %ebx
  8013c2:	e8 90 f3 ff ff       	call   800757 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013c7:	a1 80 50 80 00       	mov    0x805080,%eax
  8013cc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013d2:	a1 84 50 80 00       	mov    0x805084,%eax
  8013d7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e8:	c9                   	leave  
  8013e9:	c3                   	ret    

008013ea <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	83 ec 0c             	sub    $0xc,%esp
  8013f0:	8b 45 10             	mov    0x10(%ebp),%eax
  8013f3:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013f8:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013fd:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801400:	8b 55 08             	mov    0x8(%ebp),%edx
  801403:	8b 52 0c             	mov    0xc(%edx),%edx
  801406:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80140c:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801411:	50                   	push   %eax
  801412:	ff 75 0c             	pushl  0xc(%ebp)
  801415:	68 08 50 80 00       	push   $0x805008
  80141a:	e8 ca f4 ff ff       	call   8008e9 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80141f:	ba 00 00 00 00       	mov    $0x0,%edx
  801424:	b8 04 00 00 00       	mov    $0x4,%eax
  801429:	e8 cc fe ff ff       	call   8012fa <fsipc>
	//panic("devfile_write not implemented");
}
  80142e:	c9                   	leave  
  80142f:	c3                   	ret    

00801430 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	56                   	push   %esi
  801434:	53                   	push   %ebx
  801435:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801438:	8b 45 08             	mov    0x8(%ebp),%eax
  80143b:	8b 40 0c             	mov    0xc(%eax),%eax
  80143e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801443:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801449:	ba 00 00 00 00       	mov    $0x0,%edx
  80144e:	b8 03 00 00 00       	mov    $0x3,%eax
  801453:	e8 a2 fe ff ff       	call   8012fa <fsipc>
  801458:	89 c3                	mov    %eax,%ebx
  80145a:	85 c0                	test   %eax,%eax
  80145c:	78 4b                	js     8014a9 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80145e:	39 c6                	cmp    %eax,%esi
  801460:	73 16                	jae    801478 <devfile_read+0x48>
  801462:	68 18 22 80 00       	push   $0x802218
  801467:	68 1f 22 80 00       	push   $0x80221f
  80146c:	6a 7c                	push   $0x7c
  80146e:	68 34 22 80 00       	push   $0x802234
  801473:	e8 bd 05 00 00       	call   801a35 <_panic>
	assert(r <= PGSIZE);
  801478:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80147d:	7e 16                	jle    801495 <devfile_read+0x65>
  80147f:	68 3f 22 80 00       	push   $0x80223f
  801484:	68 1f 22 80 00       	push   $0x80221f
  801489:	6a 7d                	push   $0x7d
  80148b:	68 34 22 80 00       	push   $0x802234
  801490:	e8 a0 05 00 00       	call   801a35 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801495:	83 ec 04             	sub    $0x4,%esp
  801498:	50                   	push   %eax
  801499:	68 00 50 80 00       	push   $0x805000
  80149e:	ff 75 0c             	pushl  0xc(%ebp)
  8014a1:	e8 43 f4 ff ff       	call   8008e9 <memmove>
	return r;
  8014a6:	83 c4 10             	add    $0x10,%esp
}
  8014a9:	89 d8                	mov    %ebx,%eax
  8014ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ae:	5b                   	pop    %ebx
  8014af:	5e                   	pop    %esi
  8014b0:	5d                   	pop    %ebp
  8014b1:	c3                   	ret    

008014b2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014b2:	55                   	push   %ebp
  8014b3:	89 e5                	mov    %esp,%ebp
  8014b5:	53                   	push   %ebx
  8014b6:	83 ec 20             	sub    $0x20,%esp
  8014b9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014bc:	53                   	push   %ebx
  8014bd:	e8 5c f2 ff ff       	call   80071e <strlen>
  8014c2:	83 c4 10             	add    $0x10,%esp
  8014c5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014ca:	7f 67                	jg     801533 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014cc:	83 ec 0c             	sub    $0xc,%esp
  8014cf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014d2:	50                   	push   %eax
  8014d3:	e8 9a f8 ff ff       	call   800d72 <fd_alloc>
  8014d8:	83 c4 10             	add    $0x10,%esp
		return r;
  8014db:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014dd:	85 c0                	test   %eax,%eax
  8014df:	78 57                	js     801538 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8014e1:	83 ec 08             	sub    $0x8,%esp
  8014e4:	53                   	push   %ebx
  8014e5:	68 00 50 80 00       	push   $0x805000
  8014ea:	e8 68 f2 ff ff       	call   800757 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014f2:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014f7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014fa:	b8 01 00 00 00       	mov    $0x1,%eax
  8014ff:	e8 f6 fd ff ff       	call   8012fa <fsipc>
  801504:	89 c3                	mov    %eax,%ebx
  801506:	83 c4 10             	add    $0x10,%esp
  801509:	85 c0                	test   %eax,%eax
  80150b:	79 14                	jns    801521 <open+0x6f>
		fd_close(fd, 0);
  80150d:	83 ec 08             	sub    $0x8,%esp
  801510:	6a 00                	push   $0x0
  801512:	ff 75 f4             	pushl  -0xc(%ebp)
  801515:	e8 50 f9 ff ff       	call   800e6a <fd_close>
		return r;
  80151a:	83 c4 10             	add    $0x10,%esp
  80151d:	89 da                	mov    %ebx,%edx
  80151f:	eb 17                	jmp    801538 <open+0x86>
	}

	return fd2num(fd);
  801521:	83 ec 0c             	sub    $0xc,%esp
  801524:	ff 75 f4             	pushl  -0xc(%ebp)
  801527:	e8 1f f8 ff ff       	call   800d4b <fd2num>
  80152c:	89 c2                	mov    %eax,%edx
  80152e:	83 c4 10             	add    $0x10,%esp
  801531:	eb 05                	jmp    801538 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801533:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801538:	89 d0                	mov    %edx,%eax
  80153a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80153d:	c9                   	leave  
  80153e:	c3                   	ret    

0080153f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80153f:	55                   	push   %ebp
  801540:	89 e5                	mov    %esp,%ebp
  801542:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801545:	ba 00 00 00 00       	mov    $0x0,%edx
  80154a:	b8 08 00 00 00       	mov    $0x8,%eax
  80154f:	e8 a6 fd ff ff       	call   8012fa <fsipc>
}
  801554:	c9                   	leave  
  801555:	c3                   	ret    

00801556 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	56                   	push   %esi
  80155a:	53                   	push   %ebx
  80155b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80155e:	83 ec 0c             	sub    $0xc,%esp
  801561:	ff 75 08             	pushl  0x8(%ebp)
  801564:	e8 f2 f7 ff ff       	call   800d5b <fd2data>
  801569:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80156b:	83 c4 08             	add    $0x8,%esp
  80156e:	68 4b 22 80 00       	push   $0x80224b
  801573:	53                   	push   %ebx
  801574:	e8 de f1 ff ff       	call   800757 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801579:	8b 46 04             	mov    0x4(%esi),%eax
  80157c:	2b 06                	sub    (%esi),%eax
  80157e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801584:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80158b:	00 00 00 
	stat->st_dev = &devpipe;
  80158e:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801595:	30 80 00 
	return 0;
}
  801598:	b8 00 00 00 00       	mov    $0x0,%eax
  80159d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015a0:	5b                   	pop    %ebx
  8015a1:	5e                   	pop    %esi
  8015a2:	5d                   	pop    %ebp
  8015a3:	c3                   	ret    

008015a4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8015a4:	55                   	push   %ebp
  8015a5:	89 e5                	mov    %esp,%ebp
  8015a7:	53                   	push   %ebx
  8015a8:	83 ec 0c             	sub    $0xc,%esp
  8015ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8015ae:	53                   	push   %ebx
  8015af:	6a 00                	push   $0x0
  8015b1:	e8 29 f6 ff ff       	call   800bdf <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8015b6:	89 1c 24             	mov    %ebx,(%esp)
  8015b9:	e8 9d f7 ff ff       	call   800d5b <fd2data>
  8015be:	83 c4 08             	add    $0x8,%esp
  8015c1:	50                   	push   %eax
  8015c2:	6a 00                	push   $0x0
  8015c4:	e8 16 f6 ff ff       	call   800bdf <sys_page_unmap>
}
  8015c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cc:	c9                   	leave  
  8015cd:	c3                   	ret    

008015ce <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8015ce:	55                   	push   %ebp
  8015cf:	89 e5                	mov    %esp,%ebp
  8015d1:	57                   	push   %edi
  8015d2:	56                   	push   %esi
  8015d3:	53                   	push   %ebx
  8015d4:	83 ec 1c             	sub    $0x1c,%esp
  8015d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8015da:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8015dc:	a1 08 40 80 00       	mov    0x804008,%eax
  8015e1:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8015e4:	83 ec 0c             	sub    $0xc,%esp
  8015e7:	ff 75 e0             	pushl  -0x20(%ebp)
  8015ea:	e8 82 05 00 00       	call   801b71 <pageref>
  8015ef:	89 c3                	mov    %eax,%ebx
  8015f1:	89 3c 24             	mov    %edi,(%esp)
  8015f4:	e8 78 05 00 00       	call   801b71 <pageref>
  8015f9:	83 c4 10             	add    $0x10,%esp
  8015fc:	39 c3                	cmp    %eax,%ebx
  8015fe:	0f 94 c1             	sete   %cl
  801601:	0f b6 c9             	movzbl %cl,%ecx
  801604:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801607:	8b 15 08 40 80 00    	mov    0x804008,%edx
  80160d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801610:	39 ce                	cmp    %ecx,%esi
  801612:	74 1b                	je     80162f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801614:	39 c3                	cmp    %eax,%ebx
  801616:	75 c4                	jne    8015dc <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801618:	8b 42 58             	mov    0x58(%edx),%eax
  80161b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80161e:	50                   	push   %eax
  80161f:	56                   	push   %esi
  801620:	68 52 22 80 00       	push   $0x802252
  801625:	e8 29 eb ff ff       	call   800153 <cprintf>
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	eb ad                	jmp    8015dc <_pipeisclosed+0xe>
	}
}
  80162f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801632:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801635:	5b                   	pop    %ebx
  801636:	5e                   	pop    %esi
  801637:	5f                   	pop    %edi
  801638:	5d                   	pop    %ebp
  801639:	c3                   	ret    

0080163a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80163a:	55                   	push   %ebp
  80163b:	89 e5                	mov    %esp,%ebp
  80163d:	57                   	push   %edi
  80163e:	56                   	push   %esi
  80163f:	53                   	push   %ebx
  801640:	83 ec 28             	sub    $0x28,%esp
  801643:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801646:	56                   	push   %esi
  801647:	e8 0f f7 ff ff       	call   800d5b <fd2data>
  80164c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	bf 00 00 00 00       	mov    $0x0,%edi
  801656:	eb 4b                	jmp    8016a3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801658:	89 da                	mov    %ebx,%edx
  80165a:	89 f0                	mov    %esi,%eax
  80165c:	e8 6d ff ff ff       	call   8015ce <_pipeisclosed>
  801661:	85 c0                	test   %eax,%eax
  801663:	75 48                	jne    8016ad <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801665:	e8 d1 f4 ff ff       	call   800b3b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80166a:	8b 43 04             	mov    0x4(%ebx),%eax
  80166d:	8b 0b                	mov    (%ebx),%ecx
  80166f:	8d 51 20             	lea    0x20(%ecx),%edx
  801672:	39 d0                	cmp    %edx,%eax
  801674:	73 e2                	jae    801658 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801676:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801679:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80167d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801680:	89 c2                	mov    %eax,%edx
  801682:	c1 fa 1f             	sar    $0x1f,%edx
  801685:	89 d1                	mov    %edx,%ecx
  801687:	c1 e9 1b             	shr    $0x1b,%ecx
  80168a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80168d:	83 e2 1f             	and    $0x1f,%edx
  801690:	29 ca                	sub    %ecx,%edx
  801692:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801696:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80169a:	83 c0 01             	add    $0x1,%eax
  80169d:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016a0:	83 c7 01             	add    $0x1,%edi
  8016a3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8016a6:	75 c2                	jne    80166a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  8016a8:	8b 45 10             	mov    0x10(%ebp),%eax
  8016ab:	eb 05                	jmp    8016b2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8016ad:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8016b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016b5:	5b                   	pop    %ebx
  8016b6:	5e                   	pop    %esi
  8016b7:	5f                   	pop    %edi
  8016b8:	5d                   	pop    %ebp
  8016b9:	c3                   	ret    

008016ba <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	57                   	push   %edi
  8016be:	56                   	push   %esi
  8016bf:	53                   	push   %ebx
  8016c0:	83 ec 18             	sub    $0x18,%esp
  8016c3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8016c6:	57                   	push   %edi
  8016c7:	e8 8f f6 ff ff       	call   800d5b <fd2data>
  8016cc:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016ce:	83 c4 10             	add    $0x10,%esp
  8016d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016d6:	eb 3d                	jmp    801715 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8016d8:	85 db                	test   %ebx,%ebx
  8016da:	74 04                	je     8016e0 <devpipe_read+0x26>
				return i;
  8016dc:	89 d8                	mov    %ebx,%eax
  8016de:	eb 44                	jmp    801724 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8016e0:	89 f2                	mov    %esi,%edx
  8016e2:	89 f8                	mov    %edi,%eax
  8016e4:	e8 e5 fe ff ff       	call   8015ce <_pipeisclosed>
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	75 32                	jne    80171f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8016ed:	e8 49 f4 ff ff       	call   800b3b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8016f2:	8b 06                	mov    (%esi),%eax
  8016f4:	3b 46 04             	cmp    0x4(%esi),%eax
  8016f7:	74 df                	je     8016d8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016f9:	99                   	cltd   
  8016fa:	c1 ea 1b             	shr    $0x1b,%edx
  8016fd:	01 d0                	add    %edx,%eax
  8016ff:	83 e0 1f             	and    $0x1f,%eax
  801702:	29 d0                	sub    %edx,%eax
  801704:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801709:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80170c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  80170f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801712:	83 c3 01             	add    $0x1,%ebx
  801715:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801718:	75 d8                	jne    8016f2 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  80171a:	8b 45 10             	mov    0x10(%ebp),%eax
  80171d:	eb 05                	jmp    801724 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80171f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801724:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801727:	5b                   	pop    %ebx
  801728:	5e                   	pop    %esi
  801729:	5f                   	pop    %edi
  80172a:	5d                   	pop    %ebp
  80172b:	c3                   	ret    

0080172c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	56                   	push   %esi
  801730:	53                   	push   %ebx
  801731:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801734:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801737:	50                   	push   %eax
  801738:	e8 35 f6 ff ff       	call   800d72 <fd_alloc>
  80173d:	83 c4 10             	add    $0x10,%esp
  801740:	89 c2                	mov    %eax,%edx
  801742:	85 c0                	test   %eax,%eax
  801744:	0f 88 2c 01 00 00    	js     801876 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80174a:	83 ec 04             	sub    $0x4,%esp
  80174d:	68 07 04 00 00       	push   $0x407
  801752:	ff 75 f4             	pushl  -0xc(%ebp)
  801755:	6a 00                	push   $0x0
  801757:	e8 fe f3 ff ff       	call   800b5a <sys_page_alloc>
  80175c:	83 c4 10             	add    $0x10,%esp
  80175f:	89 c2                	mov    %eax,%edx
  801761:	85 c0                	test   %eax,%eax
  801763:	0f 88 0d 01 00 00    	js     801876 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801769:	83 ec 0c             	sub    $0xc,%esp
  80176c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80176f:	50                   	push   %eax
  801770:	e8 fd f5 ff ff       	call   800d72 <fd_alloc>
  801775:	89 c3                	mov    %eax,%ebx
  801777:	83 c4 10             	add    $0x10,%esp
  80177a:	85 c0                	test   %eax,%eax
  80177c:	0f 88 e2 00 00 00    	js     801864 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801782:	83 ec 04             	sub    $0x4,%esp
  801785:	68 07 04 00 00       	push   $0x407
  80178a:	ff 75 f0             	pushl  -0x10(%ebp)
  80178d:	6a 00                	push   $0x0
  80178f:	e8 c6 f3 ff ff       	call   800b5a <sys_page_alloc>
  801794:	89 c3                	mov    %eax,%ebx
  801796:	83 c4 10             	add    $0x10,%esp
  801799:	85 c0                	test   %eax,%eax
  80179b:	0f 88 c3 00 00 00    	js     801864 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  8017a1:	83 ec 0c             	sub    $0xc,%esp
  8017a4:	ff 75 f4             	pushl  -0xc(%ebp)
  8017a7:	e8 af f5 ff ff       	call   800d5b <fd2data>
  8017ac:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017ae:	83 c4 0c             	add    $0xc,%esp
  8017b1:	68 07 04 00 00       	push   $0x407
  8017b6:	50                   	push   %eax
  8017b7:	6a 00                	push   $0x0
  8017b9:	e8 9c f3 ff ff       	call   800b5a <sys_page_alloc>
  8017be:	89 c3                	mov    %eax,%ebx
  8017c0:	83 c4 10             	add    $0x10,%esp
  8017c3:	85 c0                	test   %eax,%eax
  8017c5:	0f 88 89 00 00 00    	js     801854 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017cb:	83 ec 0c             	sub    $0xc,%esp
  8017ce:	ff 75 f0             	pushl  -0x10(%ebp)
  8017d1:	e8 85 f5 ff ff       	call   800d5b <fd2data>
  8017d6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017dd:	50                   	push   %eax
  8017de:	6a 00                	push   $0x0
  8017e0:	56                   	push   %esi
  8017e1:	6a 00                	push   $0x0
  8017e3:	e8 b5 f3 ff ff       	call   800b9d <sys_page_map>
  8017e8:	89 c3                	mov    %eax,%ebx
  8017ea:	83 c4 20             	add    $0x20,%esp
  8017ed:	85 c0                	test   %eax,%eax
  8017ef:	78 55                	js     801846 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8017f1:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8017f7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017fa:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8017fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ff:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801806:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80180c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801811:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801814:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  80181b:	83 ec 0c             	sub    $0xc,%esp
  80181e:	ff 75 f4             	pushl  -0xc(%ebp)
  801821:	e8 25 f5 ff ff       	call   800d4b <fd2num>
  801826:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801829:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80182b:	83 c4 04             	add    $0x4,%esp
  80182e:	ff 75 f0             	pushl  -0x10(%ebp)
  801831:	e8 15 f5 ff ff       	call   800d4b <fd2num>
  801836:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801839:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80183c:	83 c4 10             	add    $0x10,%esp
  80183f:	ba 00 00 00 00       	mov    $0x0,%edx
  801844:	eb 30                	jmp    801876 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801846:	83 ec 08             	sub    $0x8,%esp
  801849:	56                   	push   %esi
  80184a:	6a 00                	push   $0x0
  80184c:	e8 8e f3 ff ff       	call   800bdf <sys_page_unmap>
  801851:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801854:	83 ec 08             	sub    $0x8,%esp
  801857:	ff 75 f0             	pushl  -0x10(%ebp)
  80185a:	6a 00                	push   $0x0
  80185c:	e8 7e f3 ff ff       	call   800bdf <sys_page_unmap>
  801861:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801864:	83 ec 08             	sub    $0x8,%esp
  801867:	ff 75 f4             	pushl  -0xc(%ebp)
  80186a:	6a 00                	push   $0x0
  80186c:	e8 6e f3 ff ff       	call   800bdf <sys_page_unmap>
  801871:	83 c4 10             	add    $0x10,%esp
  801874:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801876:	89 d0                	mov    %edx,%eax
  801878:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187b:	5b                   	pop    %ebx
  80187c:	5e                   	pop    %esi
  80187d:	5d                   	pop    %ebp
  80187e:	c3                   	ret    

0080187f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801885:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801888:	50                   	push   %eax
  801889:	ff 75 08             	pushl  0x8(%ebp)
  80188c:	e8 30 f5 ff ff       	call   800dc1 <fd_lookup>
  801891:	83 c4 10             	add    $0x10,%esp
  801894:	85 c0                	test   %eax,%eax
  801896:	78 18                	js     8018b0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801898:	83 ec 0c             	sub    $0xc,%esp
  80189b:	ff 75 f4             	pushl  -0xc(%ebp)
  80189e:	e8 b8 f4 ff ff       	call   800d5b <fd2data>
	return _pipeisclosed(fd, p);
  8018a3:	89 c2                	mov    %eax,%edx
  8018a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a8:	e8 21 fd ff ff       	call   8015ce <_pipeisclosed>
  8018ad:	83 c4 10             	add    $0x10,%esp
}
  8018b0:	c9                   	leave  
  8018b1:	c3                   	ret    

008018b2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8018b2:	55                   	push   %ebp
  8018b3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  8018b5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ba:	5d                   	pop    %ebp
  8018bb:	c3                   	ret    

008018bc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8018bc:	55                   	push   %ebp
  8018bd:	89 e5                	mov    %esp,%ebp
  8018bf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8018c2:	68 6a 22 80 00       	push   $0x80226a
  8018c7:	ff 75 0c             	pushl  0xc(%ebp)
  8018ca:	e8 88 ee ff ff       	call   800757 <strcpy>
	return 0;
}
  8018cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8018d4:	c9                   	leave  
  8018d5:	c3                   	ret    

008018d6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8018d6:	55                   	push   %ebp
  8018d7:	89 e5                	mov    %esp,%ebp
  8018d9:	57                   	push   %edi
  8018da:	56                   	push   %esi
  8018db:	53                   	push   %ebx
  8018dc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018e2:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018e7:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8018ed:	eb 2d                	jmp    80191c <devcons_write+0x46>
		m = n - tot;
  8018ef:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018f2:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8018f4:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8018f7:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8018fc:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8018ff:	83 ec 04             	sub    $0x4,%esp
  801902:	53                   	push   %ebx
  801903:	03 45 0c             	add    0xc(%ebp),%eax
  801906:	50                   	push   %eax
  801907:	57                   	push   %edi
  801908:	e8 dc ef ff ff       	call   8008e9 <memmove>
		sys_cputs(buf, m);
  80190d:	83 c4 08             	add    $0x8,%esp
  801910:	53                   	push   %ebx
  801911:	57                   	push   %edi
  801912:	e8 87 f1 ff ff       	call   800a9e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801917:	01 de                	add    %ebx,%esi
  801919:	83 c4 10             	add    $0x10,%esp
  80191c:	89 f0                	mov    %esi,%eax
  80191e:	3b 75 10             	cmp    0x10(%ebp),%esi
  801921:	72 cc                	jb     8018ef <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801923:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801926:	5b                   	pop    %ebx
  801927:	5e                   	pop    %esi
  801928:	5f                   	pop    %edi
  801929:	5d                   	pop    %ebp
  80192a:	c3                   	ret    

0080192b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	83 ec 08             	sub    $0x8,%esp
  801931:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801936:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80193a:	74 2a                	je     801966 <devcons_read+0x3b>
  80193c:	eb 05                	jmp    801943 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  80193e:	e8 f8 f1 ff ff       	call   800b3b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801943:	e8 74 f1 ff ff       	call   800abc <sys_cgetc>
  801948:	85 c0                	test   %eax,%eax
  80194a:	74 f2                	je     80193e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80194c:	85 c0                	test   %eax,%eax
  80194e:	78 16                	js     801966 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801950:	83 f8 04             	cmp    $0x4,%eax
  801953:	74 0c                	je     801961 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801955:	8b 55 0c             	mov    0xc(%ebp),%edx
  801958:	88 02                	mov    %al,(%edx)
	return 1;
  80195a:	b8 01 00 00 00       	mov    $0x1,%eax
  80195f:	eb 05                	jmp    801966 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801961:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801966:	c9                   	leave  
  801967:	c3                   	ret    

00801968 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801968:	55                   	push   %ebp
  801969:	89 e5                	mov    %esp,%ebp
  80196b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80196e:	8b 45 08             	mov    0x8(%ebp),%eax
  801971:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801974:	6a 01                	push   $0x1
  801976:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801979:	50                   	push   %eax
  80197a:	e8 1f f1 ff ff       	call   800a9e <sys_cputs>
}
  80197f:	83 c4 10             	add    $0x10,%esp
  801982:	c9                   	leave  
  801983:	c3                   	ret    

00801984 <getchar>:

int
getchar(void)
{
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80198a:	6a 01                	push   $0x1
  80198c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80198f:	50                   	push   %eax
  801990:	6a 00                	push   $0x0
  801992:	e8 90 f6 ff ff       	call   801027 <read>
	if (r < 0)
  801997:	83 c4 10             	add    $0x10,%esp
  80199a:	85 c0                	test   %eax,%eax
  80199c:	78 0f                	js     8019ad <getchar+0x29>
		return r;
	if (r < 1)
  80199e:	85 c0                	test   %eax,%eax
  8019a0:	7e 06                	jle    8019a8 <getchar+0x24>
		return -E_EOF;
	return c;
  8019a2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  8019a6:	eb 05                	jmp    8019ad <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  8019a8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  8019ad:	c9                   	leave  
  8019ae:	c3                   	ret    

008019af <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8019b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019b8:	50                   	push   %eax
  8019b9:	ff 75 08             	pushl  0x8(%ebp)
  8019bc:	e8 00 f4 ff ff       	call   800dc1 <fd_lookup>
  8019c1:	83 c4 10             	add    $0x10,%esp
  8019c4:	85 c0                	test   %eax,%eax
  8019c6:	78 11                	js     8019d9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8019c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019cb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019d1:	39 10                	cmp    %edx,(%eax)
  8019d3:	0f 94 c0             	sete   %al
  8019d6:	0f b6 c0             	movzbl %al,%eax
}
  8019d9:	c9                   	leave  
  8019da:	c3                   	ret    

008019db <opencons>:

int
opencons(void)
{
  8019db:	55                   	push   %ebp
  8019dc:	89 e5                	mov    %esp,%ebp
  8019de:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019e1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019e4:	50                   	push   %eax
  8019e5:	e8 88 f3 ff ff       	call   800d72 <fd_alloc>
  8019ea:	83 c4 10             	add    $0x10,%esp
		return r;
  8019ed:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8019ef:	85 c0                	test   %eax,%eax
  8019f1:	78 3e                	js     801a31 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019f3:	83 ec 04             	sub    $0x4,%esp
  8019f6:	68 07 04 00 00       	push   $0x407
  8019fb:	ff 75 f4             	pushl  -0xc(%ebp)
  8019fe:	6a 00                	push   $0x0
  801a00:	e8 55 f1 ff ff       	call   800b5a <sys_page_alloc>
  801a05:	83 c4 10             	add    $0x10,%esp
		return r;
  801a08:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a0a:	85 c0                	test   %eax,%eax
  801a0c:	78 23                	js     801a31 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801a0e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a17:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801a19:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a1c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801a23:	83 ec 0c             	sub    $0xc,%esp
  801a26:	50                   	push   %eax
  801a27:	e8 1f f3 ff ff       	call   800d4b <fd2num>
  801a2c:	89 c2                	mov    %eax,%edx
  801a2e:	83 c4 10             	add    $0x10,%esp
}
  801a31:	89 d0                	mov    %edx,%eax
  801a33:	c9                   	leave  
  801a34:	c3                   	ret    

00801a35 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a35:	55                   	push   %ebp
  801a36:	89 e5                	mov    %esp,%ebp
  801a38:	56                   	push   %esi
  801a39:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a3a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a3d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a43:	e8 d4 f0 ff ff       	call   800b1c <sys_getenvid>
  801a48:	83 ec 0c             	sub    $0xc,%esp
  801a4b:	ff 75 0c             	pushl  0xc(%ebp)
  801a4e:	ff 75 08             	pushl  0x8(%ebp)
  801a51:	56                   	push   %esi
  801a52:	50                   	push   %eax
  801a53:	68 78 22 80 00       	push   $0x802278
  801a58:	e8 f6 e6 ff ff       	call   800153 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a5d:	83 c4 18             	add    $0x18,%esp
  801a60:	53                   	push   %ebx
  801a61:	ff 75 10             	pushl  0x10(%ebp)
  801a64:	e8 99 e6 ff ff       	call   800102 <vcprintf>
	cprintf("\n");
  801a69:	c7 04 24 4c 1e 80 00 	movl   $0x801e4c,(%esp)
  801a70:	e8 de e6 ff ff       	call   800153 <cprintf>
  801a75:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a78:	cc                   	int3   
  801a79:	eb fd                	jmp    801a78 <_panic+0x43>

00801a7b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a7b:	55                   	push   %ebp
  801a7c:	89 e5                	mov    %esp,%ebp
  801a7e:	56                   	push   %esi
  801a7f:	53                   	push   %ebx
  801a80:	8b 75 08             	mov    0x8(%ebp),%esi
  801a83:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a86:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801a89:	85 c0                	test   %eax,%eax
  801a8b:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a90:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801a93:	83 ec 0c             	sub    $0xc,%esp
  801a96:	50                   	push   %eax
  801a97:	e8 6e f2 ff ff       	call   800d0a <sys_ipc_recv>
  801a9c:	83 c4 10             	add    $0x10,%esp
  801a9f:	85 c0                	test   %eax,%eax
  801aa1:	79 16                	jns    801ab9 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801aa3:	85 f6                	test   %esi,%esi
  801aa5:	74 06                	je     801aad <ipc_recv+0x32>
            *from_env_store = 0;
  801aa7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801aad:	85 db                	test   %ebx,%ebx
  801aaf:	74 2c                	je     801add <ipc_recv+0x62>
            *perm_store = 0;
  801ab1:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801ab7:	eb 24                	jmp    801add <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801ab9:	85 f6                	test   %esi,%esi
  801abb:	74 0a                	je     801ac7 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801abd:	a1 08 40 80 00       	mov    0x804008,%eax
  801ac2:	8b 40 74             	mov    0x74(%eax),%eax
  801ac5:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801ac7:	85 db                	test   %ebx,%ebx
  801ac9:	74 0a                	je     801ad5 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801acb:	a1 08 40 80 00       	mov    0x804008,%eax
  801ad0:	8b 40 78             	mov    0x78(%eax),%eax
  801ad3:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801ad5:	a1 08 40 80 00       	mov    0x804008,%eax
  801ada:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801add:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ae0:	5b                   	pop    %ebx
  801ae1:	5e                   	pop    %esi
  801ae2:	5d                   	pop    %ebp
  801ae3:	c3                   	ret    

00801ae4 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	57                   	push   %edi
  801ae8:	56                   	push   %esi
  801ae9:	53                   	push   %ebx
  801aea:	83 ec 0c             	sub    $0xc,%esp
  801aed:	8b 7d 08             	mov    0x8(%ebp),%edi
  801af0:	8b 75 0c             	mov    0xc(%ebp),%esi
  801af3:	8b 45 10             	mov    0x10(%ebp),%eax
  801af6:	85 c0                	test   %eax,%eax
  801af8:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801afd:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801b00:	eb 1c                	jmp    801b1e <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801b02:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801b05:	74 12                	je     801b19 <ipc_send+0x35>
  801b07:	50                   	push   %eax
  801b08:	68 9c 22 80 00       	push   $0x80229c
  801b0d:	6a 3a                	push   $0x3a
  801b0f:	68 b2 22 80 00       	push   $0x8022b2
  801b14:	e8 1c ff ff ff       	call   801a35 <_panic>
		sys_yield();
  801b19:	e8 1d f0 ff ff       	call   800b3b <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801b1e:	ff 75 14             	pushl  0x14(%ebp)
  801b21:	53                   	push   %ebx
  801b22:	56                   	push   %esi
  801b23:	57                   	push   %edi
  801b24:	e8 be f1 ff ff       	call   800ce7 <sys_ipc_try_send>
  801b29:	83 c4 10             	add    $0x10,%esp
  801b2c:	85 c0                	test   %eax,%eax
  801b2e:	78 d2                	js     801b02 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801b30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b33:	5b                   	pop    %ebx
  801b34:	5e                   	pop    %esi
  801b35:	5f                   	pop    %edi
  801b36:	5d                   	pop    %ebp
  801b37:	c3                   	ret    

00801b38 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b38:	55                   	push   %ebp
  801b39:	89 e5                	mov    %esp,%ebp
  801b3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b3e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b43:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b46:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b4c:	8b 52 50             	mov    0x50(%edx),%edx
  801b4f:	39 ca                	cmp    %ecx,%edx
  801b51:	75 0d                	jne    801b60 <ipc_find_env+0x28>
			return envs[i].env_id;
  801b53:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b56:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b5b:	8b 40 48             	mov    0x48(%eax),%eax
  801b5e:	eb 0f                	jmp    801b6f <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b60:	83 c0 01             	add    $0x1,%eax
  801b63:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b68:	75 d9                	jne    801b43 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b6a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b6f:	5d                   	pop    %ebp
  801b70:	c3                   	ret    

00801b71 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b71:	55                   	push   %ebp
  801b72:	89 e5                	mov    %esp,%ebp
  801b74:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b77:	89 d0                	mov    %edx,%eax
  801b79:	c1 e8 16             	shr    $0x16,%eax
  801b7c:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b83:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b88:	f6 c1 01             	test   $0x1,%cl
  801b8b:	74 1d                	je     801baa <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b8d:	c1 ea 0c             	shr    $0xc,%edx
  801b90:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b97:	f6 c2 01             	test   $0x1,%dl
  801b9a:	74 0e                	je     801baa <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b9c:	c1 ea 0c             	shr    $0xc,%edx
  801b9f:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801ba6:	ef 
  801ba7:	0f b7 c0             	movzwl %ax,%eax
}
  801baa:	5d                   	pop    %ebp
  801bab:	c3                   	ret    
  801bac:	66 90                	xchg   %ax,%ax
  801bae:	66 90                	xchg   %ax,%ax

00801bb0 <__udivdi3>:
  801bb0:	55                   	push   %ebp
  801bb1:	57                   	push   %edi
  801bb2:	56                   	push   %esi
  801bb3:	53                   	push   %ebx
  801bb4:	83 ec 1c             	sub    $0x1c,%esp
  801bb7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801bbb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801bbf:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801bc3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801bc7:	85 f6                	test   %esi,%esi
  801bc9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801bcd:	89 ca                	mov    %ecx,%edx
  801bcf:	89 f8                	mov    %edi,%eax
  801bd1:	75 3d                	jne    801c10 <__udivdi3+0x60>
  801bd3:	39 cf                	cmp    %ecx,%edi
  801bd5:	0f 87 c5 00 00 00    	ja     801ca0 <__udivdi3+0xf0>
  801bdb:	85 ff                	test   %edi,%edi
  801bdd:	89 fd                	mov    %edi,%ebp
  801bdf:	75 0b                	jne    801bec <__udivdi3+0x3c>
  801be1:	b8 01 00 00 00       	mov    $0x1,%eax
  801be6:	31 d2                	xor    %edx,%edx
  801be8:	f7 f7                	div    %edi
  801bea:	89 c5                	mov    %eax,%ebp
  801bec:	89 c8                	mov    %ecx,%eax
  801bee:	31 d2                	xor    %edx,%edx
  801bf0:	f7 f5                	div    %ebp
  801bf2:	89 c1                	mov    %eax,%ecx
  801bf4:	89 d8                	mov    %ebx,%eax
  801bf6:	89 cf                	mov    %ecx,%edi
  801bf8:	f7 f5                	div    %ebp
  801bfa:	89 c3                	mov    %eax,%ebx
  801bfc:	89 d8                	mov    %ebx,%eax
  801bfe:	89 fa                	mov    %edi,%edx
  801c00:	83 c4 1c             	add    $0x1c,%esp
  801c03:	5b                   	pop    %ebx
  801c04:	5e                   	pop    %esi
  801c05:	5f                   	pop    %edi
  801c06:	5d                   	pop    %ebp
  801c07:	c3                   	ret    
  801c08:	90                   	nop
  801c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c10:	39 ce                	cmp    %ecx,%esi
  801c12:	77 74                	ja     801c88 <__udivdi3+0xd8>
  801c14:	0f bd fe             	bsr    %esi,%edi
  801c17:	83 f7 1f             	xor    $0x1f,%edi
  801c1a:	0f 84 98 00 00 00    	je     801cb8 <__udivdi3+0x108>
  801c20:	bb 20 00 00 00       	mov    $0x20,%ebx
  801c25:	89 f9                	mov    %edi,%ecx
  801c27:	89 c5                	mov    %eax,%ebp
  801c29:	29 fb                	sub    %edi,%ebx
  801c2b:	d3 e6                	shl    %cl,%esi
  801c2d:	89 d9                	mov    %ebx,%ecx
  801c2f:	d3 ed                	shr    %cl,%ebp
  801c31:	89 f9                	mov    %edi,%ecx
  801c33:	d3 e0                	shl    %cl,%eax
  801c35:	09 ee                	or     %ebp,%esi
  801c37:	89 d9                	mov    %ebx,%ecx
  801c39:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801c3d:	89 d5                	mov    %edx,%ebp
  801c3f:	8b 44 24 08          	mov    0x8(%esp),%eax
  801c43:	d3 ed                	shr    %cl,%ebp
  801c45:	89 f9                	mov    %edi,%ecx
  801c47:	d3 e2                	shl    %cl,%edx
  801c49:	89 d9                	mov    %ebx,%ecx
  801c4b:	d3 e8                	shr    %cl,%eax
  801c4d:	09 c2                	or     %eax,%edx
  801c4f:	89 d0                	mov    %edx,%eax
  801c51:	89 ea                	mov    %ebp,%edx
  801c53:	f7 f6                	div    %esi
  801c55:	89 d5                	mov    %edx,%ebp
  801c57:	89 c3                	mov    %eax,%ebx
  801c59:	f7 64 24 0c          	mull   0xc(%esp)
  801c5d:	39 d5                	cmp    %edx,%ebp
  801c5f:	72 10                	jb     801c71 <__udivdi3+0xc1>
  801c61:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c65:	89 f9                	mov    %edi,%ecx
  801c67:	d3 e6                	shl    %cl,%esi
  801c69:	39 c6                	cmp    %eax,%esi
  801c6b:	73 07                	jae    801c74 <__udivdi3+0xc4>
  801c6d:	39 d5                	cmp    %edx,%ebp
  801c6f:	75 03                	jne    801c74 <__udivdi3+0xc4>
  801c71:	83 eb 01             	sub    $0x1,%ebx
  801c74:	31 ff                	xor    %edi,%edi
  801c76:	89 d8                	mov    %ebx,%eax
  801c78:	89 fa                	mov    %edi,%edx
  801c7a:	83 c4 1c             	add    $0x1c,%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    
  801c82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c88:	31 ff                	xor    %edi,%edi
  801c8a:	31 db                	xor    %ebx,%ebx
  801c8c:	89 d8                	mov    %ebx,%eax
  801c8e:	89 fa                	mov    %edi,%edx
  801c90:	83 c4 1c             	add    $0x1c,%esp
  801c93:	5b                   	pop    %ebx
  801c94:	5e                   	pop    %esi
  801c95:	5f                   	pop    %edi
  801c96:	5d                   	pop    %ebp
  801c97:	c3                   	ret    
  801c98:	90                   	nop
  801c99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ca0:	89 d8                	mov    %ebx,%eax
  801ca2:	f7 f7                	div    %edi
  801ca4:	31 ff                	xor    %edi,%edi
  801ca6:	89 c3                	mov    %eax,%ebx
  801ca8:	89 d8                	mov    %ebx,%eax
  801caa:	89 fa                	mov    %edi,%edx
  801cac:	83 c4 1c             	add    $0x1c,%esp
  801caf:	5b                   	pop    %ebx
  801cb0:	5e                   	pop    %esi
  801cb1:	5f                   	pop    %edi
  801cb2:	5d                   	pop    %ebp
  801cb3:	c3                   	ret    
  801cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801cb8:	39 ce                	cmp    %ecx,%esi
  801cba:	72 0c                	jb     801cc8 <__udivdi3+0x118>
  801cbc:	31 db                	xor    %ebx,%ebx
  801cbe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801cc2:	0f 87 34 ff ff ff    	ja     801bfc <__udivdi3+0x4c>
  801cc8:	bb 01 00 00 00       	mov    $0x1,%ebx
  801ccd:	e9 2a ff ff ff       	jmp    801bfc <__udivdi3+0x4c>
  801cd2:	66 90                	xchg   %ax,%ax
  801cd4:	66 90                	xchg   %ax,%ax
  801cd6:	66 90                	xchg   %ax,%ax
  801cd8:	66 90                	xchg   %ax,%ax
  801cda:	66 90                	xchg   %ax,%ax
  801cdc:	66 90                	xchg   %ax,%ax
  801cde:	66 90                	xchg   %ax,%ax

00801ce0 <__umoddi3>:
  801ce0:	55                   	push   %ebp
  801ce1:	57                   	push   %edi
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 1c             	sub    $0x1c,%esp
  801ce7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801ceb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801cef:	8b 74 24 34          	mov    0x34(%esp),%esi
  801cf3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cf7:	85 d2                	test   %edx,%edx
  801cf9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cfd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d01:	89 f3                	mov    %esi,%ebx
  801d03:	89 3c 24             	mov    %edi,(%esp)
  801d06:	89 74 24 04          	mov    %esi,0x4(%esp)
  801d0a:	75 1c                	jne    801d28 <__umoddi3+0x48>
  801d0c:	39 f7                	cmp    %esi,%edi
  801d0e:	76 50                	jbe    801d60 <__umoddi3+0x80>
  801d10:	89 c8                	mov    %ecx,%eax
  801d12:	89 f2                	mov    %esi,%edx
  801d14:	f7 f7                	div    %edi
  801d16:	89 d0                	mov    %edx,%eax
  801d18:	31 d2                	xor    %edx,%edx
  801d1a:	83 c4 1c             	add    $0x1c,%esp
  801d1d:	5b                   	pop    %ebx
  801d1e:	5e                   	pop    %esi
  801d1f:	5f                   	pop    %edi
  801d20:	5d                   	pop    %ebp
  801d21:	c3                   	ret    
  801d22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d28:	39 f2                	cmp    %esi,%edx
  801d2a:	89 d0                	mov    %edx,%eax
  801d2c:	77 52                	ja     801d80 <__umoddi3+0xa0>
  801d2e:	0f bd ea             	bsr    %edx,%ebp
  801d31:	83 f5 1f             	xor    $0x1f,%ebp
  801d34:	75 5a                	jne    801d90 <__umoddi3+0xb0>
  801d36:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801d3a:	0f 82 e0 00 00 00    	jb     801e20 <__umoddi3+0x140>
  801d40:	39 0c 24             	cmp    %ecx,(%esp)
  801d43:	0f 86 d7 00 00 00    	jbe    801e20 <__umoddi3+0x140>
  801d49:	8b 44 24 08          	mov    0x8(%esp),%eax
  801d4d:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d51:	83 c4 1c             	add    $0x1c,%esp
  801d54:	5b                   	pop    %ebx
  801d55:	5e                   	pop    %esi
  801d56:	5f                   	pop    %edi
  801d57:	5d                   	pop    %ebp
  801d58:	c3                   	ret    
  801d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d60:	85 ff                	test   %edi,%edi
  801d62:	89 fd                	mov    %edi,%ebp
  801d64:	75 0b                	jne    801d71 <__umoddi3+0x91>
  801d66:	b8 01 00 00 00       	mov    $0x1,%eax
  801d6b:	31 d2                	xor    %edx,%edx
  801d6d:	f7 f7                	div    %edi
  801d6f:	89 c5                	mov    %eax,%ebp
  801d71:	89 f0                	mov    %esi,%eax
  801d73:	31 d2                	xor    %edx,%edx
  801d75:	f7 f5                	div    %ebp
  801d77:	89 c8                	mov    %ecx,%eax
  801d79:	f7 f5                	div    %ebp
  801d7b:	89 d0                	mov    %edx,%eax
  801d7d:	eb 99                	jmp    801d18 <__umoddi3+0x38>
  801d7f:	90                   	nop
  801d80:	89 c8                	mov    %ecx,%eax
  801d82:	89 f2                	mov    %esi,%edx
  801d84:	83 c4 1c             	add    $0x1c,%esp
  801d87:	5b                   	pop    %ebx
  801d88:	5e                   	pop    %esi
  801d89:	5f                   	pop    %edi
  801d8a:	5d                   	pop    %ebp
  801d8b:	c3                   	ret    
  801d8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d90:	8b 34 24             	mov    (%esp),%esi
  801d93:	bf 20 00 00 00       	mov    $0x20,%edi
  801d98:	89 e9                	mov    %ebp,%ecx
  801d9a:	29 ef                	sub    %ebp,%edi
  801d9c:	d3 e0                	shl    %cl,%eax
  801d9e:	89 f9                	mov    %edi,%ecx
  801da0:	89 f2                	mov    %esi,%edx
  801da2:	d3 ea                	shr    %cl,%edx
  801da4:	89 e9                	mov    %ebp,%ecx
  801da6:	09 c2                	or     %eax,%edx
  801da8:	89 d8                	mov    %ebx,%eax
  801daa:	89 14 24             	mov    %edx,(%esp)
  801dad:	89 f2                	mov    %esi,%edx
  801daf:	d3 e2                	shl    %cl,%edx
  801db1:	89 f9                	mov    %edi,%ecx
  801db3:	89 54 24 04          	mov    %edx,0x4(%esp)
  801db7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801dbb:	d3 e8                	shr    %cl,%eax
  801dbd:	89 e9                	mov    %ebp,%ecx
  801dbf:	89 c6                	mov    %eax,%esi
  801dc1:	d3 e3                	shl    %cl,%ebx
  801dc3:	89 f9                	mov    %edi,%ecx
  801dc5:	89 d0                	mov    %edx,%eax
  801dc7:	d3 e8                	shr    %cl,%eax
  801dc9:	89 e9                	mov    %ebp,%ecx
  801dcb:	09 d8                	or     %ebx,%eax
  801dcd:	89 d3                	mov    %edx,%ebx
  801dcf:	89 f2                	mov    %esi,%edx
  801dd1:	f7 34 24             	divl   (%esp)
  801dd4:	89 d6                	mov    %edx,%esi
  801dd6:	d3 e3                	shl    %cl,%ebx
  801dd8:	f7 64 24 04          	mull   0x4(%esp)
  801ddc:	39 d6                	cmp    %edx,%esi
  801dde:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801de2:	89 d1                	mov    %edx,%ecx
  801de4:	89 c3                	mov    %eax,%ebx
  801de6:	72 08                	jb     801df0 <__umoddi3+0x110>
  801de8:	75 11                	jne    801dfb <__umoddi3+0x11b>
  801dea:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801dee:	73 0b                	jae    801dfb <__umoddi3+0x11b>
  801df0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801df4:	1b 14 24             	sbb    (%esp),%edx
  801df7:	89 d1                	mov    %edx,%ecx
  801df9:	89 c3                	mov    %eax,%ebx
  801dfb:	8b 54 24 08          	mov    0x8(%esp),%edx
  801dff:	29 da                	sub    %ebx,%edx
  801e01:	19 ce                	sbb    %ecx,%esi
  801e03:	89 f9                	mov    %edi,%ecx
  801e05:	89 f0                	mov    %esi,%eax
  801e07:	d3 e0                	shl    %cl,%eax
  801e09:	89 e9                	mov    %ebp,%ecx
  801e0b:	d3 ea                	shr    %cl,%edx
  801e0d:	89 e9                	mov    %ebp,%ecx
  801e0f:	d3 ee                	shr    %cl,%esi
  801e11:	09 d0                	or     %edx,%eax
  801e13:	89 f2                	mov    %esi,%edx
  801e15:	83 c4 1c             	add    $0x1c,%esp
  801e18:	5b                   	pop    %ebx
  801e19:	5e                   	pop    %esi
  801e1a:	5f                   	pop    %edi
  801e1b:	5d                   	pop    %ebp
  801e1c:	c3                   	ret    
  801e1d:	8d 76 00             	lea    0x0(%esi),%esi
  801e20:	29 f9                	sub    %edi,%ecx
  801e22:	19 d6                	sbb    %edx,%esi
  801e24:	89 74 24 04          	mov    %esi,0x4(%esp)
  801e28:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e2c:	e9 18 ff ff ff       	jmp    801d49 <__umoddi3+0x69>
