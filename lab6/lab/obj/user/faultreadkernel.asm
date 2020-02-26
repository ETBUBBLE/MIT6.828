
obj/user/faultreadkernel.debug：     文件格式 elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	ff 35 00 00 10 f0    	pushl  0xf0100000
  80003f:	68 e0 22 80 00       	push   $0x8022e0
  800044:	e8 f8 00 00 00       	call   800141 <cprintf>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 ac 0a 00 00       	call   800b0a <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 40 80 00       	mov    %eax,0x804008

    // save the name of the program so that panic() can use it
    if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
        binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 a4 0e 00 00       	call   800f43 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 20 0a 00 00       	call   800ac9 <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	53                   	push   %ebx
  8000b2:	83 ec 04             	sub    $0x4,%esp
  8000b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000b8:	8b 13                	mov    (%ebx),%edx
  8000ba:	8d 42 01             	lea    0x1(%edx),%eax
  8000bd:	89 03                	mov    %eax,(%ebx)
  8000bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000c6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000cb:	75 1a                	jne    8000e7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000cd:	83 ec 08             	sub    $0x8,%esp
  8000d0:	68 ff 00 00 00       	push   $0xff
  8000d5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000d8:	50                   	push   %eax
  8000d9:	e8 ae 09 00 00       	call   800a8c <sys_cputs>
		b->idx = 0;
  8000de:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000e4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000e7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000ee:	c9                   	leave  
  8000ef:	c3                   	ret    

008000f0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8000f9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800100:	00 00 00 
	b.cnt = 0;
  800103:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80010a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80010d:	ff 75 0c             	pushl  0xc(%ebp)
  800110:	ff 75 08             	pushl  0x8(%ebp)
  800113:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800119:	50                   	push   %eax
  80011a:	68 ae 00 80 00       	push   $0x8000ae
  80011f:	e8 1a 01 00 00       	call   80023e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800124:	83 c4 08             	add    $0x8,%esp
  800127:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80012d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800133:	50                   	push   %eax
  800134:	e8 53 09 00 00       	call   800a8c <sys_cputs>

	return b.cnt;
}
  800139:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800141:	55                   	push   %ebp
  800142:	89 e5                	mov    %esp,%ebp
  800144:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800147:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80014a:	50                   	push   %eax
  80014b:	ff 75 08             	pushl  0x8(%ebp)
  80014e:	e8 9d ff ff ff       	call   8000f0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	57                   	push   %edi
  800159:	56                   	push   %esi
  80015a:	53                   	push   %ebx
  80015b:	83 ec 1c             	sub    $0x1c,%esp
  80015e:	89 c7                	mov    %eax,%edi
  800160:	89 d6                	mov    %edx,%esi
  800162:	8b 45 08             	mov    0x8(%ebp),%eax
  800165:	8b 55 0c             	mov    0xc(%ebp),%edx
  800168:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80016b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80016e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800171:	bb 00 00 00 00       	mov    $0x0,%ebx
  800176:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800179:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80017c:	39 d3                	cmp    %edx,%ebx
  80017e:	72 05                	jb     800185 <printnum+0x30>
  800180:	39 45 10             	cmp    %eax,0x10(%ebp)
  800183:	77 45                	ja     8001ca <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800185:	83 ec 0c             	sub    $0xc,%esp
  800188:	ff 75 18             	pushl  0x18(%ebp)
  80018b:	8b 45 14             	mov    0x14(%ebp),%eax
  80018e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800191:	53                   	push   %ebx
  800192:	ff 75 10             	pushl  0x10(%ebp)
  800195:	83 ec 08             	sub    $0x8,%esp
  800198:	ff 75 e4             	pushl  -0x1c(%ebp)
  80019b:	ff 75 e0             	pushl  -0x20(%ebp)
  80019e:	ff 75 dc             	pushl  -0x24(%ebp)
  8001a1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001a4:	e8 97 1e 00 00       	call   802040 <__udivdi3>
  8001a9:	83 c4 18             	add    $0x18,%esp
  8001ac:	52                   	push   %edx
  8001ad:	50                   	push   %eax
  8001ae:	89 f2                	mov    %esi,%edx
  8001b0:	89 f8                	mov    %edi,%eax
  8001b2:	e8 9e ff ff ff       	call   800155 <printnum>
  8001b7:	83 c4 20             	add    $0x20,%esp
  8001ba:	eb 18                	jmp    8001d4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001bc:	83 ec 08             	sub    $0x8,%esp
  8001bf:	56                   	push   %esi
  8001c0:	ff 75 18             	pushl  0x18(%ebp)
  8001c3:	ff d7                	call   *%edi
  8001c5:	83 c4 10             	add    $0x10,%esp
  8001c8:	eb 03                	jmp    8001cd <printnum+0x78>
  8001ca:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001cd:	83 eb 01             	sub    $0x1,%ebx
  8001d0:	85 db                	test   %ebx,%ebx
  8001d2:	7f e8                	jg     8001bc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001d4:	83 ec 08             	sub    $0x8,%esp
  8001d7:	56                   	push   %esi
  8001d8:	83 ec 04             	sub    $0x4,%esp
  8001db:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001de:	ff 75 e0             	pushl  -0x20(%ebp)
  8001e1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001e4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001e7:	e8 84 1f 00 00       	call   802170 <__umoddi3>
  8001ec:	83 c4 14             	add    $0x14,%esp
  8001ef:	0f be 80 11 23 80 00 	movsbl 0x802311(%eax),%eax
  8001f6:	50                   	push   %eax
  8001f7:	ff d7                	call   *%edi
}
  8001f9:	83 c4 10             	add    $0x10,%esp
  8001fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ff:	5b                   	pop    %ebx
  800200:	5e                   	pop    %esi
  800201:	5f                   	pop    %edi
  800202:	5d                   	pop    %ebp
  800203:	c3                   	ret    

00800204 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80020a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80020e:	8b 10                	mov    (%eax),%edx
  800210:	3b 50 04             	cmp    0x4(%eax),%edx
  800213:	73 0a                	jae    80021f <sprintputch+0x1b>
		*b->buf++ = ch;
  800215:	8d 4a 01             	lea    0x1(%edx),%ecx
  800218:	89 08                	mov    %ecx,(%eax)
  80021a:	8b 45 08             	mov    0x8(%ebp),%eax
  80021d:	88 02                	mov    %al,(%edx)
}
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800227:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80022a:	50                   	push   %eax
  80022b:	ff 75 10             	pushl  0x10(%ebp)
  80022e:	ff 75 0c             	pushl  0xc(%ebp)
  800231:	ff 75 08             	pushl  0x8(%ebp)
  800234:	e8 05 00 00 00       	call   80023e <vprintfmt>
	va_end(ap);
}
  800239:	83 c4 10             	add    $0x10,%esp
  80023c:	c9                   	leave  
  80023d:	c3                   	ret    

0080023e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	57                   	push   %edi
  800242:	56                   	push   %esi
  800243:	53                   	push   %ebx
  800244:	83 ec 2c             	sub    $0x2c,%esp
  800247:	8b 75 08             	mov    0x8(%ebp),%esi
  80024a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80024d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800250:	eb 12                	jmp    800264 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800252:	85 c0                	test   %eax,%eax
  800254:	0f 84 42 04 00 00    	je     80069c <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80025a:	83 ec 08             	sub    $0x8,%esp
  80025d:	53                   	push   %ebx
  80025e:	50                   	push   %eax
  80025f:	ff d6                	call   *%esi
  800261:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800264:	83 c7 01             	add    $0x1,%edi
  800267:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80026b:	83 f8 25             	cmp    $0x25,%eax
  80026e:	75 e2                	jne    800252 <vprintfmt+0x14>
  800270:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800274:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80027b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800282:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800289:	b9 00 00 00 00       	mov    $0x0,%ecx
  80028e:	eb 07                	jmp    800297 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800290:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800293:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800297:	8d 47 01             	lea    0x1(%edi),%eax
  80029a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80029d:	0f b6 07             	movzbl (%edi),%eax
  8002a0:	0f b6 d0             	movzbl %al,%edx
  8002a3:	83 e8 23             	sub    $0x23,%eax
  8002a6:	3c 55                	cmp    $0x55,%al
  8002a8:	0f 87 d3 03 00 00    	ja     800681 <vprintfmt+0x443>
  8002ae:	0f b6 c0             	movzbl %al,%eax
  8002b1:	ff 24 85 60 24 80 00 	jmp    *0x802460(,%eax,4)
  8002b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002bb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002bf:	eb d6                	jmp    800297 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002c9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002cf:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002d3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002d6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002d9:	83 f9 09             	cmp    $0x9,%ecx
  8002dc:	77 3f                	ja     80031d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002de:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8002e1:	eb e9                	jmp    8002cc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002e6:	8b 00                	mov    (%eax),%eax
  8002e8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002ee:	8d 40 04             	lea    0x4(%eax),%eax
  8002f1:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8002f7:	eb 2a                	jmp    800323 <vprintfmt+0xe5>
  8002f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8002fc:	85 c0                	test   %eax,%eax
  8002fe:	ba 00 00 00 00       	mov    $0x0,%edx
  800303:	0f 49 d0             	cmovns %eax,%edx
  800306:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800309:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80030c:	eb 89                	jmp    800297 <vprintfmt+0x59>
  80030e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800311:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800318:	e9 7a ff ff ff       	jmp    800297 <vprintfmt+0x59>
  80031d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800320:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800323:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800327:	0f 89 6a ff ff ff    	jns    800297 <vprintfmt+0x59>
				width = precision, precision = -1;
  80032d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800330:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800333:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80033a:	e9 58 ff ff ff       	jmp    800297 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80033f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800342:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800345:	e9 4d ff ff ff       	jmp    800297 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80034a:	8b 45 14             	mov    0x14(%ebp),%eax
  80034d:	8d 78 04             	lea    0x4(%eax),%edi
  800350:	83 ec 08             	sub    $0x8,%esp
  800353:	53                   	push   %ebx
  800354:	ff 30                	pushl  (%eax)
  800356:	ff d6                	call   *%esi
			break;
  800358:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80035b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800361:	e9 fe fe ff ff       	jmp    800264 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800366:	8b 45 14             	mov    0x14(%ebp),%eax
  800369:	8d 78 04             	lea    0x4(%eax),%edi
  80036c:	8b 00                	mov    (%eax),%eax
  80036e:	99                   	cltd   
  80036f:	31 d0                	xor    %edx,%eax
  800371:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800373:	83 f8 0f             	cmp    $0xf,%eax
  800376:	7f 0b                	jg     800383 <vprintfmt+0x145>
  800378:	8b 14 85 c0 25 80 00 	mov    0x8025c0(,%eax,4),%edx
  80037f:	85 d2                	test   %edx,%edx
  800381:	75 1b                	jne    80039e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800383:	50                   	push   %eax
  800384:	68 29 23 80 00       	push   $0x802329
  800389:	53                   	push   %ebx
  80038a:	56                   	push   %esi
  80038b:	e8 91 fe ff ff       	call   800221 <printfmt>
  800390:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800393:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800396:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800399:	e9 c6 fe ff ff       	jmp    800264 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80039e:	52                   	push   %edx
  80039f:	68 f5 26 80 00       	push   $0x8026f5
  8003a4:	53                   	push   %ebx
  8003a5:	56                   	push   %esi
  8003a6:	e8 76 fe ff ff       	call   800221 <printfmt>
  8003ab:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ae:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003b4:	e9 ab fe ff ff       	jmp    800264 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bc:	83 c0 04             	add    $0x4,%eax
  8003bf:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003c7:	85 ff                	test   %edi,%edi
  8003c9:	b8 22 23 80 00       	mov    $0x802322,%eax
  8003ce:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003d1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d5:	0f 8e 94 00 00 00    	jle    80046f <vprintfmt+0x231>
  8003db:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003df:	0f 84 98 00 00 00    	je     80047d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003e5:	83 ec 08             	sub    $0x8,%esp
  8003e8:	ff 75 d0             	pushl  -0x30(%ebp)
  8003eb:	57                   	push   %edi
  8003ec:	e8 33 03 00 00       	call   800724 <strnlen>
  8003f1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003f4:	29 c1                	sub    %eax,%ecx
  8003f6:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8003f9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8003fc:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800400:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800403:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800406:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800408:	eb 0f                	jmp    800419 <vprintfmt+0x1db>
					putch(padc, putdat);
  80040a:	83 ec 08             	sub    $0x8,%esp
  80040d:	53                   	push   %ebx
  80040e:	ff 75 e0             	pushl  -0x20(%ebp)
  800411:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800413:	83 ef 01             	sub    $0x1,%edi
  800416:	83 c4 10             	add    $0x10,%esp
  800419:	85 ff                	test   %edi,%edi
  80041b:	7f ed                	jg     80040a <vprintfmt+0x1cc>
  80041d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800420:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800423:	85 c9                	test   %ecx,%ecx
  800425:	b8 00 00 00 00       	mov    $0x0,%eax
  80042a:	0f 49 c1             	cmovns %ecx,%eax
  80042d:	29 c1                	sub    %eax,%ecx
  80042f:	89 75 08             	mov    %esi,0x8(%ebp)
  800432:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800435:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800438:	89 cb                	mov    %ecx,%ebx
  80043a:	eb 4d                	jmp    800489 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80043c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800440:	74 1b                	je     80045d <vprintfmt+0x21f>
  800442:	0f be c0             	movsbl %al,%eax
  800445:	83 e8 20             	sub    $0x20,%eax
  800448:	83 f8 5e             	cmp    $0x5e,%eax
  80044b:	76 10                	jbe    80045d <vprintfmt+0x21f>
					putch('?', putdat);
  80044d:	83 ec 08             	sub    $0x8,%esp
  800450:	ff 75 0c             	pushl  0xc(%ebp)
  800453:	6a 3f                	push   $0x3f
  800455:	ff 55 08             	call   *0x8(%ebp)
  800458:	83 c4 10             	add    $0x10,%esp
  80045b:	eb 0d                	jmp    80046a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	ff 75 0c             	pushl  0xc(%ebp)
  800463:	52                   	push   %edx
  800464:	ff 55 08             	call   *0x8(%ebp)
  800467:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80046a:	83 eb 01             	sub    $0x1,%ebx
  80046d:	eb 1a                	jmp    800489 <vprintfmt+0x24b>
  80046f:	89 75 08             	mov    %esi,0x8(%ebp)
  800472:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800475:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800478:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80047b:	eb 0c                	jmp    800489 <vprintfmt+0x24b>
  80047d:	89 75 08             	mov    %esi,0x8(%ebp)
  800480:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800483:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800486:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800489:	83 c7 01             	add    $0x1,%edi
  80048c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800490:	0f be d0             	movsbl %al,%edx
  800493:	85 d2                	test   %edx,%edx
  800495:	74 23                	je     8004ba <vprintfmt+0x27c>
  800497:	85 f6                	test   %esi,%esi
  800499:	78 a1                	js     80043c <vprintfmt+0x1fe>
  80049b:	83 ee 01             	sub    $0x1,%esi
  80049e:	79 9c                	jns    80043c <vprintfmt+0x1fe>
  8004a0:	89 df                	mov    %ebx,%edi
  8004a2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004a8:	eb 18                	jmp    8004c2 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004aa:	83 ec 08             	sub    $0x8,%esp
  8004ad:	53                   	push   %ebx
  8004ae:	6a 20                	push   $0x20
  8004b0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004b2:	83 ef 01             	sub    $0x1,%edi
  8004b5:	83 c4 10             	add    $0x10,%esp
  8004b8:	eb 08                	jmp    8004c2 <vprintfmt+0x284>
  8004ba:	89 df                	mov    %ebx,%edi
  8004bc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004c2:	85 ff                	test   %edi,%edi
  8004c4:	7f e4                	jg     8004aa <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004c9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004cc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004cf:	e9 90 fd ff ff       	jmp    800264 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004d4:	83 f9 01             	cmp    $0x1,%ecx
  8004d7:	7e 19                	jle    8004f2 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8004d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dc:	8b 50 04             	mov    0x4(%eax),%edx
  8004df:	8b 00                	mov    (%eax),%eax
  8004e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004e4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ea:	8d 40 08             	lea    0x8(%eax),%eax
  8004ed:	89 45 14             	mov    %eax,0x14(%ebp)
  8004f0:	eb 38                	jmp    80052a <vprintfmt+0x2ec>
	else if (lflag)
  8004f2:	85 c9                	test   %ecx,%ecx
  8004f4:	74 1b                	je     800511 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8004f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f9:	8b 00                	mov    (%eax),%eax
  8004fb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004fe:	89 c1                	mov    %eax,%ecx
  800500:	c1 f9 1f             	sar    $0x1f,%ecx
  800503:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8d 40 04             	lea    0x4(%eax),%eax
  80050c:	89 45 14             	mov    %eax,0x14(%ebp)
  80050f:	eb 19                	jmp    80052a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800511:	8b 45 14             	mov    0x14(%ebp),%eax
  800514:	8b 00                	mov    (%eax),%eax
  800516:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800519:	89 c1                	mov    %eax,%ecx
  80051b:	c1 f9 1f             	sar    $0x1f,%ecx
  80051e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 40 04             	lea    0x4(%eax),%eax
  800527:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80052a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80052d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800530:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800535:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800539:	0f 89 0e 01 00 00    	jns    80064d <vprintfmt+0x40f>
				putch('-', putdat);
  80053f:	83 ec 08             	sub    $0x8,%esp
  800542:	53                   	push   %ebx
  800543:	6a 2d                	push   $0x2d
  800545:	ff d6                	call   *%esi
				num = -(long long) num;
  800547:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80054a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80054d:	f7 da                	neg    %edx
  80054f:	83 d1 00             	adc    $0x0,%ecx
  800552:	f7 d9                	neg    %ecx
  800554:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800557:	b8 0a 00 00 00       	mov    $0xa,%eax
  80055c:	e9 ec 00 00 00       	jmp    80064d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800561:	83 f9 01             	cmp    $0x1,%ecx
  800564:	7e 18                	jle    80057e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8b 10                	mov    (%eax),%edx
  80056b:	8b 48 04             	mov    0x4(%eax),%ecx
  80056e:	8d 40 08             	lea    0x8(%eax),%eax
  800571:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800574:	b8 0a 00 00 00       	mov    $0xa,%eax
  800579:	e9 cf 00 00 00       	jmp    80064d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80057e:	85 c9                	test   %ecx,%ecx
  800580:	74 1a                	je     80059c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	8b 10                	mov    (%eax),%edx
  800587:	b9 00 00 00 00       	mov    $0x0,%ecx
  80058c:	8d 40 04             	lea    0x4(%eax),%eax
  80058f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800592:	b8 0a 00 00 00       	mov    $0xa,%eax
  800597:	e9 b1 00 00 00       	jmp    80064d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80059c:	8b 45 14             	mov    0x14(%ebp),%eax
  80059f:	8b 10                	mov    (%eax),%edx
  8005a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005a6:	8d 40 04             	lea    0x4(%eax),%eax
  8005a9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005ac:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005b1:	e9 97 00 00 00       	jmp    80064d <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005b6:	83 ec 08             	sub    $0x8,%esp
  8005b9:	53                   	push   %ebx
  8005ba:	6a 58                	push   $0x58
  8005bc:	ff d6                	call   *%esi
			putch('X', putdat);
  8005be:	83 c4 08             	add    $0x8,%esp
  8005c1:	53                   	push   %ebx
  8005c2:	6a 58                	push   $0x58
  8005c4:	ff d6                	call   *%esi
			putch('X', putdat);
  8005c6:	83 c4 08             	add    $0x8,%esp
  8005c9:	53                   	push   %ebx
  8005ca:	6a 58                	push   $0x58
  8005cc:	ff d6                	call   *%esi
			break;
  8005ce:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005d4:	e9 8b fc ff ff       	jmp    800264 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8005d9:	83 ec 08             	sub    $0x8,%esp
  8005dc:	53                   	push   %ebx
  8005dd:	6a 30                	push   $0x30
  8005df:	ff d6                	call   *%esi
			putch('x', putdat);
  8005e1:	83 c4 08             	add    $0x8,%esp
  8005e4:	53                   	push   %ebx
  8005e5:	6a 78                	push   $0x78
  8005e7:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8b 10                	mov    (%eax),%edx
  8005ee:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8005f3:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8005f6:	8d 40 04             	lea    0x4(%eax),%eax
  8005f9:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8005fc:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800601:	eb 4a                	jmp    80064d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800603:	83 f9 01             	cmp    $0x1,%ecx
  800606:	7e 15                	jle    80061d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800608:	8b 45 14             	mov    0x14(%ebp),%eax
  80060b:	8b 10                	mov    (%eax),%edx
  80060d:	8b 48 04             	mov    0x4(%eax),%ecx
  800610:	8d 40 08             	lea    0x8(%eax),%eax
  800613:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800616:	b8 10 00 00 00       	mov    $0x10,%eax
  80061b:	eb 30                	jmp    80064d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80061d:	85 c9                	test   %ecx,%ecx
  80061f:	74 17                	je     800638 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800621:	8b 45 14             	mov    0x14(%ebp),%eax
  800624:	8b 10                	mov    (%eax),%edx
  800626:	b9 00 00 00 00       	mov    $0x0,%ecx
  80062b:	8d 40 04             	lea    0x4(%eax),%eax
  80062e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800631:	b8 10 00 00 00       	mov    $0x10,%eax
  800636:	eb 15                	jmp    80064d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800638:	8b 45 14             	mov    0x14(%ebp),%eax
  80063b:	8b 10                	mov    (%eax),%edx
  80063d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800642:	8d 40 04             	lea    0x4(%eax),%eax
  800645:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800648:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80064d:	83 ec 0c             	sub    $0xc,%esp
  800650:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800654:	57                   	push   %edi
  800655:	ff 75 e0             	pushl  -0x20(%ebp)
  800658:	50                   	push   %eax
  800659:	51                   	push   %ecx
  80065a:	52                   	push   %edx
  80065b:	89 da                	mov    %ebx,%edx
  80065d:	89 f0                	mov    %esi,%eax
  80065f:	e8 f1 fa ff ff       	call   800155 <printnum>
			break;
  800664:	83 c4 20             	add    $0x20,%esp
  800667:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80066a:	e9 f5 fb ff ff       	jmp    800264 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80066f:	83 ec 08             	sub    $0x8,%esp
  800672:	53                   	push   %ebx
  800673:	52                   	push   %edx
  800674:	ff d6                	call   *%esi
			break;
  800676:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800679:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80067c:	e9 e3 fb ff ff       	jmp    800264 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800681:	83 ec 08             	sub    $0x8,%esp
  800684:	53                   	push   %ebx
  800685:	6a 25                	push   $0x25
  800687:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800689:	83 c4 10             	add    $0x10,%esp
  80068c:	eb 03                	jmp    800691 <vprintfmt+0x453>
  80068e:	83 ef 01             	sub    $0x1,%edi
  800691:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800695:	75 f7                	jne    80068e <vprintfmt+0x450>
  800697:	e9 c8 fb ff ff       	jmp    800264 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80069c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80069f:	5b                   	pop    %ebx
  8006a0:	5e                   	pop    %esi
  8006a1:	5f                   	pop    %edi
  8006a2:	5d                   	pop    %ebp
  8006a3:	c3                   	ret    

008006a4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006a4:	55                   	push   %ebp
  8006a5:	89 e5                	mov    %esp,%ebp
  8006a7:	83 ec 18             	sub    $0x18,%esp
  8006aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006b3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006b7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ba:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006c1:	85 c0                	test   %eax,%eax
  8006c3:	74 26                	je     8006eb <vsnprintf+0x47>
  8006c5:	85 d2                	test   %edx,%edx
  8006c7:	7e 22                	jle    8006eb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006c9:	ff 75 14             	pushl  0x14(%ebp)
  8006cc:	ff 75 10             	pushl  0x10(%ebp)
  8006cf:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006d2:	50                   	push   %eax
  8006d3:	68 04 02 80 00       	push   $0x800204
  8006d8:	e8 61 fb ff ff       	call   80023e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006e0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	eb 05                	jmp    8006f0 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006eb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8006f0:	c9                   	leave  
  8006f1:	c3                   	ret    

008006f2 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006f2:	55                   	push   %ebp
  8006f3:	89 e5                	mov    %esp,%ebp
  8006f5:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006f8:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006fb:	50                   	push   %eax
  8006fc:	ff 75 10             	pushl  0x10(%ebp)
  8006ff:	ff 75 0c             	pushl  0xc(%ebp)
  800702:	ff 75 08             	pushl  0x8(%ebp)
  800705:	e8 9a ff ff ff       	call   8006a4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80070a:	c9                   	leave  
  80070b:	c3                   	ret    

0080070c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800712:	b8 00 00 00 00       	mov    $0x0,%eax
  800717:	eb 03                	jmp    80071c <strlen+0x10>
		n++;
  800719:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80071c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800720:	75 f7                	jne    800719 <strlen+0xd>
		n++;
	return n;
}
  800722:	5d                   	pop    %ebp
  800723:	c3                   	ret    

00800724 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80072a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80072d:	ba 00 00 00 00       	mov    $0x0,%edx
  800732:	eb 03                	jmp    800737 <strnlen+0x13>
		n++;
  800734:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800737:	39 c2                	cmp    %eax,%edx
  800739:	74 08                	je     800743 <strnlen+0x1f>
  80073b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80073f:	75 f3                	jne    800734 <strnlen+0x10>
  800741:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800743:	5d                   	pop    %ebp
  800744:	c3                   	ret    

00800745 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800745:	55                   	push   %ebp
  800746:	89 e5                	mov    %esp,%ebp
  800748:	53                   	push   %ebx
  800749:	8b 45 08             	mov    0x8(%ebp),%eax
  80074c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80074f:	89 c2                	mov    %eax,%edx
  800751:	83 c2 01             	add    $0x1,%edx
  800754:	83 c1 01             	add    $0x1,%ecx
  800757:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80075b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80075e:	84 db                	test   %bl,%bl
  800760:	75 ef                	jne    800751 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800762:	5b                   	pop    %ebx
  800763:	5d                   	pop    %ebp
  800764:	c3                   	ret    

00800765 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	53                   	push   %ebx
  800769:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80076c:	53                   	push   %ebx
  80076d:	e8 9a ff ff ff       	call   80070c <strlen>
  800772:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800775:	ff 75 0c             	pushl  0xc(%ebp)
  800778:	01 d8                	add    %ebx,%eax
  80077a:	50                   	push   %eax
  80077b:	e8 c5 ff ff ff       	call   800745 <strcpy>
	return dst;
}
  800780:	89 d8                	mov    %ebx,%eax
  800782:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800785:	c9                   	leave  
  800786:	c3                   	ret    

00800787 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800787:	55                   	push   %ebp
  800788:	89 e5                	mov    %esp,%ebp
  80078a:	56                   	push   %esi
  80078b:	53                   	push   %ebx
  80078c:	8b 75 08             	mov    0x8(%ebp),%esi
  80078f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800792:	89 f3                	mov    %esi,%ebx
  800794:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800797:	89 f2                	mov    %esi,%edx
  800799:	eb 0f                	jmp    8007aa <strncpy+0x23>
		*dst++ = *src;
  80079b:	83 c2 01             	add    $0x1,%edx
  80079e:	0f b6 01             	movzbl (%ecx),%eax
  8007a1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a4:	80 39 01             	cmpb   $0x1,(%ecx)
  8007a7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007aa:	39 da                	cmp    %ebx,%edx
  8007ac:	75 ed                	jne    80079b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007ae:	89 f0                	mov    %esi,%eax
  8007b0:	5b                   	pop    %ebx
  8007b1:	5e                   	pop    %esi
  8007b2:	5d                   	pop    %ebp
  8007b3:	c3                   	ret    

008007b4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	56                   	push   %esi
  8007b8:	53                   	push   %ebx
  8007b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007bf:	8b 55 10             	mov    0x10(%ebp),%edx
  8007c2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007c4:	85 d2                	test   %edx,%edx
  8007c6:	74 21                	je     8007e9 <strlcpy+0x35>
  8007c8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007cc:	89 f2                	mov    %esi,%edx
  8007ce:	eb 09                	jmp    8007d9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007d0:	83 c2 01             	add    $0x1,%edx
  8007d3:	83 c1 01             	add    $0x1,%ecx
  8007d6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007d9:	39 c2                	cmp    %eax,%edx
  8007db:	74 09                	je     8007e6 <strlcpy+0x32>
  8007dd:	0f b6 19             	movzbl (%ecx),%ebx
  8007e0:	84 db                	test   %bl,%bl
  8007e2:	75 ec                	jne    8007d0 <strlcpy+0x1c>
  8007e4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007e6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007e9:	29 f0                	sub    %esi,%eax
}
  8007eb:	5b                   	pop    %ebx
  8007ec:	5e                   	pop    %esi
  8007ed:	5d                   	pop    %ebp
  8007ee:	c3                   	ret    

008007ef <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ef:	55                   	push   %ebp
  8007f0:	89 e5                	mov    %esp,%ebp
  8007f2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007f5:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007f8:	eb 06                	jmp    800800 <strcmp+0x11>
		p++, q++;
  8007fa:	83 c1 01             	add    $0x1,%ecx
  8007fd:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800800:	0f b6 01             	movzbl (%ecx),%eax
  800803:	84 c0                	test   %al,%al
  800805:	74 04                	je     80080b <strcmp+0x1c>
  800807:	3a 02                	cmp    (%edx),%al
  800809:	74 ef                	je     8007fa <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80080b:	0f b6 c0             	movzbl %al,%eax
  80080e:	0f b6 12             	movzbl (%edx),%edx
  800811:	29 d0                	sub    %edx,%eax
}
  800813:	5d                   	pop    %ebp
  800814:	c3                   	ret    

00800815 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800815:	55                   	push   %ebp
  800816:	89 e5                	mov    %esp,%ebp
  800818:	53                   	push   %ebx
  800819:	8b 45 08             	mov    0x8(%ebp),%eax
  80081c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80081f:	89 c3                	mov    %eax,%ebx
  800821:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800824:	eb 06                	jmp    80082c <strncmp+0x17>
		n--, p++, q++;
  800826:	83 c0 01             	add    $0x1,%eax
  800829:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80082c:	39 d8                	cmp    %ebx,%eax
  80082e:	74 15                	je     800845 <strncmp+0x30>
  800830:	0f b6 08             	movzbl (%eax),%ecx
  800833:	84 c9                	test   %cl,%cl
  800835:	74 04                	je     80083b <strncmp+0x26>
  800837:	3a 0a                	cmp    (%edx),%cl
  800839:	74 eb                	je     800826 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80083b:	0f b6 00             	movzbl (%eax),%eax
  80083e:	0f b6 12             	movzbl (%edx),%edx
  800841:	29 d0                	sub    %edx,%eax
  800843:	eb 05                	jmp    80084a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800845:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80084a:	5b                   	pop    %ebx
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80084d:	55                   	push   %ebp
  80084e:	89 e5                	mov    %esp,%ebp
  800850:	8b 45 08             	mov    0x8(%ebp),%eax
  800853:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800857:	eb 07                	jmp    800860 <strchr+0x13>
		if (*s == c)
  800859:	38 ca                	cmp    %cl,%dl
  80085b:	74 0f                	je     80086c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80085d:	83 c0 01             	add    $0x1,%eax
  800860:	0f b6 10             	movzbl (%eax),%edx
  800863:	84 d2                	test   %dl,%dl
  800865:	75 f2                	jne    800859 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800867:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80086c:	5d                   	pop    %ebp
  80086d:	c3                   	ret    

0080086e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	8b 45 08             	mov    0x8(%ebp),%eax
  800874:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800878:	eb 03                	jmp    80087d <strfind+0xf>
  80087a:	83 c0 01             	add    $0x1,%eax
  80087d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800880:	38 ca                	cmp    %cl,%dl
  800882:	74 04                	je     800888 <strfind+0x1a>
  800884:	84 d2                	test   %dl,%dl
  800886:	75 f2                	jne    80087a <strfind+0xc>
			break;
	return (char *) s;
}
  800888:	5d                   	pop    %ebp
  800889:	c3                   	ret    

0080088a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80088a:	55                   	push   %ebp
  80088b:	89 e5                	mov    %esp,%ebp
  80088d:	57                   	push   %edi
  80088e:	56                   	push   %esi
  80088f:	53                   	push   %ebx
  800890:	8b 7d 08             	mov    0x8(%ebp),%edi
  800893:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800896:	85 c9                	test   %ecx,%ecx
  800898:	74 36                	je     8008d0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80089a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008a0:	75 28                	jne    8008ca <memset+0x40>
  8008a2:	f6 c1 03             	test   $0x3,%cl
  8008a5:	75 23                	jne    8008ca <memset+0x40>
		c &= 0xFF;
  8008a7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008ab:	89 d3                	mov    %edx,%ebx
  8008ad:	c1 e3 08             	shl    $0x8,%ebx
  8008b0:	89 d6                	mov    %edx,%esi
  8008b2:	c1 e6 18             	shl    $0x18,%esi
  8008b5:	89 d0                	mov    %edx,%eax
  8008b7:	c1 e0 10             	shl    $0x10,%eax
  8008ba:	09 f0                	or     %esi,%eax
  8008bc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008be:	89 d8                	mov    %ebx,%eax
  8008c0:	09 d0                	or     %edx,%eax
  8008c2:	c1 e9 02             	shr    $0x2,%ecx
  8008c5:	fc                   	cld    
  8008c6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008c8:	eb 06                	jmp    8008d0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cd:	fc                   	cld    
  8008ce:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008d0:	89 f8                	mov    %edi,%eax
  8008d2:	5b                   	pop    %ebx
  8008d3:	5e                   	pop    %esi
  8008d4:	5f                   	pop    %edi
  8008d5:	5d                   	pop    %ebp
  8008d6:	c3                   	ret    

008008d7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008d7:	55                   	push   %ebp
  8008d8:	89 e5                	mov    %esp,%ebp
  8008da:	57                   	push   %edi
  8008db:	56                   	push   %esi
  8008dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8008df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008e2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008e5:	39 c6                	cmp    %eax,%esi
  8008e7:	73 35                	jae    80091e <memmove+0x47>
  8008e9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008ec:	39 d0                	cmp    %edx,%eax
  8008ee:	73 2e                	jae    80091e <memmove+0x47>
		s += n;
		d += n;
  8008f0:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f3:	89 d6                	mov    %edx,%esi
  8008f5:	09 fe                	or     %edi,%esi
  8008f7:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008fd:	75 13                	jne    800912 <memmove+0x3b>
  8008ff:	f6 c1 03             	test   $0x3,%cl
  800902:	75 0e                	jne    800912 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800904:	83 ef 04             	sub    $0x4,%edi
  800907:	8d 72 fc             	lea    -0x4(%edx),%esi
  80090a:	c1 e9 02             	shr    $0x2,%ecx
  80090d:	fd                   	std    
  80090e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800910:	eb 09                	jmp    80091b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800912:	83 ef 01             	sub    $0x1,%edi
  800915:	8d 72 ff             	lea    -0x1(%edx),%esi
  800918:	fd                   	std    
  800919:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80091b:	fc                   	cld    
  80091c:	eb 1d                	jmp    80093b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80091e:	89 f2                	mov    %esi,%edx
  800920:	09 c2                	or     %eax,%edx
  800922:	f6 c2 03             	test   $0x3,%dl
  800925:	75 0f                	jne    800936 <memmove+0x5f>
  800927:	f6 c1 03             	test   $0x3,%cl
  80092a:	75 0a                	jne    800936 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80092c:	c1 e9 02             	shr    $0x2,%ecx
  80092f:	89 c7                	mov    %eax,%edi
  800931:	fc                   	cld    
  800932:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800934:	eb 05                	jmp    80093b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800936:	89 c7                	mov    %eax,%edi
  800938:	fc                   	cld    
  800939:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80093b:	5e                   	pop    %esi
  80093c:	5f                   	pop    %edi
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80093f:	55                   	push   %ebp
  800940:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800942:	ff 75 10             	pushl  0x10(%ebp)
  800945:	ff 75 0c             	pushl  0xc(%ebp)
  800948:	ff 75 08             	pushl  0x8(%ebp)
  80094b:	e8 87 ff ff ff       	call   8008d7 <memmove>
}
  800950:	c9                   	leave  
  800951:	c3                   	ret    

00800952 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800952:	55                   	push   %ebp
  800953:	89 e5                	mov    %esp,%ebp
  800955:	56                   	push   %esi
  800956:	53                   	push   %ebx
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095d:	89 c6                	mov    %eax,%esi
  80095f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800962:	eb 1a                	jmp    80097e <memcmp+0x2c>
		if (*s1 != *s2)
  800964:	0f b6 08             	movzbl (%eax),%ecx
  800967:	0f b6 1a             	movzbl (%edx),%ebx
  80096a:	38 d9                	cmp    %bl,%cl
  80096c:	74 0a                	je     800978 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80096e:	0f b6 c1             	movzbl %cl,%eax
  800971:	0f b6 db             	movzbl %bl,%ebx
  800974:	29 d8                	sub    %ebx,%eax
  800976:	eb 0f                	jmp    800987 <memcmp+0x35>
		s1++, s2++;
  800978:	83 c0 01             	add    $0x1,%eax
  80097b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80097e:	39 f0                	cmp    %esi,%eax
  800980:	75 e2                	jne    800964 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800982:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800987:	5b                   	pop    %ebx
  800988:	5e                   	pop    %esi
  800989:	5d                   	pop    %ebp
  80098a:	c3                   	ret    

0080098b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	53                   	push   %ebx
  80098f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800992:	89 c1                	mov    %eax,%ecx
  800994:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800997:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80099b:	eb 0a                	jmp    8009a7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80099d:	0f b6 10             	movzbl (%eax),%edx
  8009a0:	39 da                	cmp    %ebx,%edx
  8009a2:	74 07                	je     8009ab <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009a4:	83 c0 01             	add    $0x1,%eax
  8009a7:	39 c8                	cmp    %ecx,%eax
  8009a9:	72 f2                	jb     80099d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009ab:	5b                   	pop    %ebx
  8009ac:	5d                   	pop    %ebp
  8009ad:	c3                   	ret    

008009ae <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	57                   	push   %edi
  8009b2:	56                   	push   %esi
  8009b3:	53                   	push   %ebx
  8009b4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009b7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ba:	eb 03                	jmp    8009bf <strtol+0x11>
		s++;
  8009bc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009bf:	0f b6 01             	movzbl (%ecx),%eax
  8009c2:	3c 20                	cmp    $0x20,%al
  8009c4:	74 f6                	je     8009bc <strtol+0xe>
  8009c6:	3c 09                	cmp    $0x9,%al
  8009c8:	74 f2                	je     8009bc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009ca:	3c 2b                	cmp    $0x2b,%al
  8009cc:	75 0a                	jne    8009d8 <strtol+0x2a>
		s++;
  8009ce:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009d1:	bf 00 00 00 00       	mov    $0x0,%edi
  8009d6:	eb 11                	jmp    8009e9 <strtol+0x3b>
  8009d8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009dd:	3c 2d                	cmp    $0x2d,%al
  8009df:	75 08                	jne    8009e9 <strtol+0x3b>
		s++, neg = 1;
  8009e1:	83 c1 01             	add    $0x1,%ecx
  8009e4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009e9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009ef:	75 15                	jne    800a06 <strtol+0x58>
  8009f1:	80 39 30             	cmpb   $0x30,(%ecx)
  8009f4:	75 10                	jne    800a06 <strtol+0x58>
  8009f6:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009fa:	75 7c                	jne    800a78 <strtol+0xca>
		s += 2, base = 16;
  8009fc:	83 c1 02             	add    $0x2,%ecx
  8009ff:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a04:	eb 16                	jmp    800a1c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a06:	85 db                	test   %ebx,%ebx
  800a08:	75 12                	jne    800a1c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a0a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a0f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a12:	75 08                	jne    800a1c <strtol+0x6e>
		s++, base = 8;
  800a14:	83 c1 01             	add    $0x1,%ecx
  800a17:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a1c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a21:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a24:	0f b6 11             	movzbl (%ecx),%edx
  800a27:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a2a:	89 f3                	mov    %esi,%ebx
  800a2c:	80 fb 09             	cmp    $0x9,%bl
  800a2f:	77 08                	ja     800a39 <strtol+0x8b>
			dig = *s - '0';
  800a31:	0f be d2             	movsbl %dl,%edx
  800a34:	83 ea 30             	sub    $0x30,%edx
  800a37:	eb 22                	jmp    800a5b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a39:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a3c:	89 f3                	mov    %esi,%ebx
  800a3e:	80 fb 19             	cmp    $0x19,%bl
  800a41:	77 08                	ja     800a4b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a43:	0f be d2             	movsbl %dl,%edx
  800a46:	83 ea 57             	sub    $0x57,%edx
  800a49:	eb 10                	jmp    800a5b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a4b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a4e:	89 f3                	mov    %esi,%ebx
  800a50:	80 fb 19             	cmp    $0x19,%bl
  800a53:	77 16                	ja     800a6b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a55:	0f be d2             	movsbl %dl,%edx
  800a58:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a5b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a5e:	7d 0b                	jge    800a6b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a60:	83 c1 01             	add    $0x1,%ecx
  800a63:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a67:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a69:	eb b9                	jmp    800a24 <strtol+0x76>

	if (endptr)
  800a6b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a6f:	74 0d                	je     800a7e <strtol+0xd0>
		*endptr = (char *) s;
  800a71:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a74:	89 0e                	mov    %ecx,(%esi)
  800a76:	eb 06                	jmp    800a7e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a78:	85 db                	test   %ebx,%ebx
  800a7a:	74 98                	je     800a14 <strtol+0x66>
  800a7c:	eb 9e                	jmp    800a1c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a7e:	89 c2                	mov    %eax,%edx
  800a80:	f7 da                	neg    %edx
  800a82:	85 ff                	test   %edi,%edi
  800a84:	0f 45 c2             	cmovne %edx,%eax
}
  800a87:	5b                   	pop    %ebx
  800a88:	5e                   	pop    %esi
  800a89:	5f                   	pop    %edi
  800a8a:	5d                   	pop    %ebp
  800a8b:	c3                   	ret    

00800a8c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	57                   	push   %edi
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a92:	b8 00 00 00 00       	mov    $0x0,%eax
  800a97:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a9d:	89 c3                	mov    %eax,%ebx
  800a9f:	89 c7                	mov    %eax,%edi
  800aa1:	89 c6                	mov    %eax,%esi
  800aa3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800aa5:	5b                   	pop    %ebx
  800aa6:	5e                   	pop    %esi
  800aa7:	5f                   	pop    %edi
  800aa8:	5d                   	pop    %ebp
  800aa9:	c3                   	ret    

00800aaa <sys_cgetc>:

int
sys_cgetc(void)
{
  800aaa:	55                   	push   %ebp
  800aab:	89 e5                	mov    %esp,%ebp
  800aad:	57                   	push   %edi
  800aae:	56                   	push   %esi
  800aaf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ab0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ab5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aba:	89 d1                	mov    %edx,%ecx
  800abc:	89 d3                	mov    %edx,%ebx
  800abe:	89 d7                	mov    %edx,%edi
  800ac0:	89 d6                	mov    %edx,%esi
  800ac2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ac4:	5b                   	pop    %ebx
  800ac5:	5e                   	pop    %esi
  800ac6:	5f                   	pop    %edi
  800ac7:	5d                   	pop    %ebp
  800ac8:	c3                   	ret    

00800ac9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ac9:	55                   	push   %ebp
  800aca:	89 e5                	mov    %esp,%ebp
  800acc:	57                   	push   %edi
  800acd:	56                   	push   %esi
  800ace:	53                   	push   %ebx
  800acf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ad2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ad7:	b8 03 00 00 00       	mov    $0x3,%eax
  800adc:	8b 55 08             	mov    0x8(%ebp),%edx
  800adf:	89 cb                	mov    %ecx,%ebx
  800ae1:	89 cf                	mov    %ecx,%edi
  800ae3:	89 ce                	mov    %ecx,%esi
  800ae5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ae7:	85 c0                	test   %eax,%eax
  800ae9:	7e 17                	jle    800b02 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800aeb:	83 ec 0c             	sub    $0xc,%esp
  800aee:	50                   	push   %eax
  800aef:	6a 03                	push   $0x3
  800af1:	68 1f 26 80 00       	push   $0x80261f
  800af6:	6a 23                	push   $0x23
  800af8:	68 3c 26 80 00       	push   $0x80263c
  800afd:	e8 c7 13 00 00       	call   801ec9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b02:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b05:	5b                   	pop    %ebx
  800b06:	5e                   	pop    %esi
  800b07:	5f                   	pop    %edi
  800b08:	5d                   	pop    %ebp
  800b09:	c3                   	ret    

00800b0a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b0a:	55                   	push   %ebp
  800b0b:	89 e5                	mov    %esp,%ebp
  800b0d:	57                   	push   %edi
  800b0e:	56                   	push   %esi
  800b0f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b10:	ba 00 00 00 00       	mov    $0x0,%edx
  800b15:	b8 02 00 00 00       	mov    $0x2,%eax
  800b1a:	89 d1                	mov    %edx,%ecx
  800b1c:	89 d3                	mov    %edx,%ebx
  800b1e:	89 d7                	mov    %edx,%edi
  800b20:	89 d6                	mov    %edx,%esi
  800b22:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b24:	5b                   	pop    %ebx
  800b25:	5e                   	pop    %esi
  800b26:	5f                   	pop    %edi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    

00800b29 <sys_yield>:

void
sys_yield(void)
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
  800b34:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b39:	89 d1                	mov    %edx,%ecx
  800b3b:	89 d3                	mov    %edx,%ebx
  800b3d:	89 d7                	mov    %edx,%edi
  800b3f:	89 d6                	mov    %edx,%esi
  800b41:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b43:	5b                   	pop    %ebx
  800b44:	5e                   	pop    %esi
  800b45:	5f                   	pop    %edi
  800b46:	5d                   	pop    %ebp
  800b47:	c3                   	ret    

00800b48 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	57                   	push   %edi
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b51:	be 00 00 00 00       	mov    $0x0,%esi
  800b56:	b8 04 00 00 00       	mov    $0x4,%eax
  800b5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b61:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b64:	89 f7                	mov    %esi,%edi
  800b66:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b68:	85 c0                	test   %eax,%eax
  800b6a:	7e 17                	jle    800b83 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b6c:	83 ec 0c             	sub    $0xc,%esp
  800b6f:	50                   	push   %eax
  800b70:	6a 04                	push   $0x4
  800b72:	68 1f 26 80 00       	push   $0x80261f
  800b77:	6a 23                	push   $0x23
  800b79:	68 3c 26 80 00       	push   $0x80263c
  800b7e:	e8 46 13 00 00       	call   801ec9 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b83:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b86:	5b                   	pop    %ebx
  800b87:	5e                   	pop    %esi
  800b88:	5f                   	pop    %edi
  800b89:	5d                   	pop    %ebp
  800b8a:	c3                   	ret    

00800b8b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	57                   	push   %edi
  800b8f:	56                   	push   %esi
  800b90:	53                   	push   %ebx
  800b91:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b94:	b8 05 00 00 00       	mov    $0x5,%eax
  800b99:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b9c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b9f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ba2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ba5:	8b 75 18             	mov    0x18(%ebp),%esi
  800ba8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800baa:	85 c0                	test   %eax,%eax
  800bac:	7e 17                	jle    800bc5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bae:	83 ec 0c             	sub    $0xc,%esp
  800bb1:	50                   	push   %eax
  800bb2:	6a 05                	push   $0x5
  800bb4:	68 1f 26 80 00       	push   $0x80261f
  800bb9:	6a 23                	push   $0x23
  800bbb:	68 3c 26 80 00       	push   $0x80263c
  800bc0:	e8 04 13 00 00       	call   801ec9 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bc5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc8:	5b                   	pop    %ebx
  800bc9:	5e                   	pop    %esi
  800bca:	5f                   	pop    %edi
  800bcb:	5d                   	pop    %ebp
  800bcc:	c3                   	ret    

00800bcd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bd6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800bdb:	b8 06 00 00 00       	mov    $0x6,%eax
  800be0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800be3:	8b 55 08             	mov    0x8(%ebp),%edx
  800be6:	89 df                	mov    %ebx,%edi
  800be8:	89 de                	mov    %ebx,%esi
  800bea:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bec:	85 c0                	test   %eax,%eax
  800bee:	7e 17                	jle    800c07 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bf0:	83 ec 0c             	sub    $0xc,%esp
  800bf3:	50                   	push   %eax
  800bf4:	6a 06                	push   $0x6
  800bf6:	68 1f 26 80 00       	push   $0x80261f
  800bfb:	6a 23                	push   $0x23
  800bfd:	68 3c 26 80 00       	push   $0x80263c
  800c02:	e8 c2 12 00 00       	call   801ec9 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c07:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c0a:	5b                   	pop    %ebx
  800c0b:	5e                   	pop    %esi
  800c0c:	5f                   	pop    %edi
  800c0d:	5d                   	pop    %ebp
  800c0e:	c3                   	ret    

00800c0f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c0f:	55                   	push   %ebp
  800c10:	89 e5                	mov    %esp,%ebp
  800c12:	57                   	push   %edi
  800c13:	56                   	push   %esi
  800c14:	53                   	push   %ebx
  800c15:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c18:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c1d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c22:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c25:	8b 55 08             	mov    0x8(%ebp),%edx
  800c28:	89 df                	mov    %ebx,%edi
  800c2a:	89 de                	mov    %ebx,%esi
  800c2c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c2e:	85 c0                	test   %eax,%eax
  800c30:	7e 17                	jle    800c49 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c32:	83 ec 0c             	sub    $0xc,%esp
  800c35:	50                   	push   %eax
  800c36:	6a 08                	push   $0x8
  800c38:	68 1f 26 80 00       	push   $0x80261f
  800c3d:	6a 23                	push   $0x23
  800c3f:	68 3c 26 80 00       	push   $0x80263c
  800c44:	e8 80 12 00 00       	call   801ec9 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c49:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c4c:	5b                   	pop    %ebx
  800c4d:	5e                   	pop    %esi
  800c4e:	5f                   	pop    %edi
  800c4f:	5d                   	pop    %ebp
  800c50:	c3                   	ret    

00800c51 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	57                   	push   %edi
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c5f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c67:	8b 55 08             	mov    0x8(%ebp),%edx
  800c6a:	89 df                	mov    %ebx,%edi
  800c6c:	89 de                	mov    %ebx,%esi
  800c6e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c70:	85 c0                	test   %eax,%eax
  800c72:	7e 17                	jle    800c8b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c74:	83 ec 0c             	sub    $0xc,%esp
  800c77:	50                   	push   %eax
  800c78:	6a 09                	push   $0x9
  800c7a:	68 1f 26 80 00       	push   $0x80261f
  800c7f:	6a 23                	push   $0x23
  800c81:	68 3c 26 80 00       	push   $0x80263c
  800c86:	e8 3e 12 00 00       	call   801ec9 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c93:	55                   	push   %ebp
  800c94:	89 e5                	mov    %esp,%ebp
  800c96:	57                   	push   %edi
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c9c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ca1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ca6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cac:	89 df                	mov    %ebx,%edi
  800cae:	89 de                	mov    %ebx,%esi
  800cb0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cb2:	85 c0                	test   %eax,%eax
  800cb4:	7e 17                	jle    800ccd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cb6:	83 ec 0c             	sub    $0xc,%esp
  800cb9:	50                   	push   %eax
  800cba:	6a 0a                	push   $0xa
  800cbc:	68 1f 26 80 00       	push   $0x80261f
  800cc1:	6a 23                	push   $0x23
  800cc3:	68 3c 26 80 00       	push   $0x80263c
  800cc8:	e8 fc 11 00 00       	call   801ec9 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800ccd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd0:	5b                   	pop    %ebx
  800cd1:	5e                   	pop    %esi
  800cd2:	5f                   	pop    %edi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	57                   	push   %edi
  800cd9:	56                   	push   %esi
  800cda:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdb:	be 00 00 00 00       	mov    $0x0,%esi
  800ce0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ce5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cee:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cf1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cf3:	5b                   	pop    %ebx
  800cf4:	5e                   	pop    %esi
  800cf5:	5f                   	pop    %edi
  800cf6:	5d                   	pop    %ebp
  800cf7:	c3                   	ret    

00800cf8 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cf8:	55                   	push   %ebp
  800cf9:	89 e5                	mov    %esp,%ebp
  800cfb:	57                   	push   %edi
  800cfc:	56                   	push   %esi
  800cfd:	53                   	push   %ebx
  800cfe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d01:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d06:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d0b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0e:	89 cb                	mov    %ecx,%ebx
  800d10:	89 cf                	mov    %ecx,%edi
  800d12:	89 ce                	mov    %ecx,%esi
  800d14:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d16:	85 c0                	test   %eax,%eax
  800d18:	7e 17                	jle    800d31 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1a:	83 ec 0c             	sub    $0xc,%esp
  800d1d:	50                   	push   %eax
  800d1e:	6a 0d                	push   $0xd
  800d20:	68 1f 26 80 00       	push   $0x80261f
  800d25:	6a 23                	push   $0x23
  800d27:	68 3c 26 80 00       	push   $0x80263c
  800d2c:	e8 98 11 00 00       	call   801ec9 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d31:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d34:	5b                   	pop    %ebx
  800d35:	5e                   	pop    %esi
  800d36:	5f                   	pop    %edi
  800d37:	5d                   	pop    %ebp
  800d38:	c3                   	ret    

00800d39 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
  800d3c:	57                   	push   %edi
  800d3d:	56                   	push   %esi
  800d3e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d44:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d49:	89 d1                	mov    %edx,%ecx
  800d4b:	89 d3                	mov    %edx,%ebx
  800d4d:	89 d7                	mov    %edx,%edi
  800d4f:	89 d6                	mov    %edx,%esi
  800d51:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d53:	5b                   	pop    %ebx
  800d54:	5e                   	pop    %esi
  800d55:	5f                   	pop    %edi
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    

00800d58 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
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
  800d5e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d63:	b8 10 00 00 00       	mov    $0x10,%eax
  800d68:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6b:	89 cb                	mov    %ecx,%ebx
  800d6d:	89 cf                	mov    %ecx,%edi
  800d6f:	89 ce                	mov    %ecx,%esi
  800d71:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800d73:	5b                   	pop    %ebx
  800d74:	5e                   	pop    %esi
  800d75:	5f                   	pop    %edi
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d7b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d7e:	05 00 00 00 30       	add    $0x30000000,%eax
  800d83:	c1 e8 0c             	shr    $0xc,%eax
}
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8e:	05 00 00 00 30       	add    $0x30000000,%eax
  800d93:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800d98:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800d9d:	5d                   	pop    %ebp
  800d9e:	c3                   	ret    

00800d9f <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800d9f:	55                   	push   %ebp
  800da0:	89 e5                	mov    %esp,%ebp
  800da2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800daa:	89 c2                	mov    %eax,%edx
  800dac:	c1 ea 16             	shr    $0x16,%edx
  800daf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800db6:	f6 c2 01             	test   $0x1,%dl
  800db9:	74 11                	je     800dcc <fd_alloc+0x2d>
  800dbb:	89 c2                	mov    %eax,%edx
  800dbd:	c1 ea 0c             	shr    $0xc,%edx
  800dc0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dc7:	f6 c2 01             	test   $0x1,%dl
  800dca:	75 09                	jne    800dd5 <fd_alloc+0x36>
			*fd_store = fd;
  800dcc:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dce:	b8 00 00 00 00       	mov    $0x0,%eax
  800dd3:	eb 17                	jmp    800dec <fd_alloc+0x4d>
  800dd5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dda:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800ddf:	75 c9                	jne    800daa <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800de1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800de7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800df4:	83 f8 1f             	cmp    $0x1f,%eax
  800df7:	77 36                	ja     800e2f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800df9:	c1 e0 0c             	shl    $0xc,%eax
  800dfc:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e01:	89 c2                	mov    %eax,%edx
  800e03:	c1 ea 16             	shr    $0x16,%edx
  800e06:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e0d:	f6 c2 01             	test   $0x1,%dl
  800e10:	74 24                	je     800e36 <fd_lookup+0x48>
  800e12:	89 c2                	mov    %eax,%edx
  800e14:	c1 ea 0c             	shr    $0xc,%edx
  800e17:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e1e:	f6 c2 01             	test   $0x1,%dl
  800e21:	74 1a                	je     800e3d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e23:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e26:	89 02                	mov    %eax,(%edx)
	return 0;
  800e28:	b8 00 00 00 00       	mov    $0x0,%eax
  800e2d:	eb 13                	jmp    800e42 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e2f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e34:	eb 0c                	jmp    800e42 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e36:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e3b:	eb 05                	jmp    800e42 <fd_lookup+0x54>
  800e3d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e42:	5d                   	pop    %ebp
  800e43:	c3                   	ret    

00800e44 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	83 ec 08             	sub    $0x8,%esp
  800e4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4d:	ba c8 26 80 00       	mov    $0x8026c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e52:	eb 13                	jmp    800e67 <dev_lookup+0x23>
  800e54:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e57:	39 08                	cmp    %ecx,(%eax)
  800e59:	75 0c                	jne    800e67 <dev_lookup+0x23>
			*dev = devtab[i];
  800e5b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e5e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e60:	b8 00 00 00 00       	mov    $0x0,%eax
  800e65:	eb 2e                	jmp    800e95 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e67:	8b 02                	mov    (%edx),%eax
  800e69:	85 c0                	test   %eax,%eax
  800e6b:	75 e7                	jne    800e54 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e6d:	a1 08 40 80 00       	mov    0x804008,%eax
  800e72:	8b 40 48             	mov    0x48(%eax),%eax
  800e75:	83 ec 04             	sub    $0x4,%esp
  800e78:	51                   	push   %ecx
  800e79:	50                   	push   %eax
  800e7a:	68 4c 26 80 00       	push   $0x80264c
  800e7f:	e8 bd f2 ff ff       	call   800141 <cprintf>
	*dev = 0;
  800e84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e87:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e8d:	83 c4 10             	add    $0x10,%esp
  800e90:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800e95:	c9                   	leave  
  800e96:	c3                   	ret    

00800e97 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800e97:	55                   	push   %ebp
  800e98:	89 e5                	mov    %esp,%ebp
  800e9a:	56                   	push   %esi
  800e9b:	53                   	push   %ebx
  800e9c:	83 ec 10             	sub    $0x10,%esp
  800e9f:	8b 75 08             	mov    0x8(%ebp),%esi
  800ea2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800ea5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea8:	50                   	push   %eax
  800ea9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800eaf:	c1 e8 0c             	shr    $0xc,%eax
  800eb2:	50                   	push   %eax
  800eb3:	e8 36 ff ff ff       	call   800dee <fd_lookup>
  800eb8:	83 c4 08             	add    $0x8,%esp
  800ebb:	85 c0                	test   %eax,%eax
  800ebd:	78 05                	js     800ec4 <fd_close+0x2d>
	    || fd != fd2)
  800ebf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ec2:	74 0c                	je     800ed0 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ec4:	84 db                	test   %bl,%bl
  800ec6:	ba 00 00 00 00       	mov    $0x0,%edx
  800ecb:	0f 44 c2             	cmove  %edx,%eax
  800ece:	eb 41                	jmp    800f11 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ed0:	83 ec 08             	sub    $0x8,%esp
  800ed3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ed6:	50                   	push   %eax
  800ed7:	ff 36                	pushl  (%esi)
  800ed9:	e8 66 ff ff ff       	call   800e44 <dev_lookup>
  800ede:	89 c3                	mov    %eax,%ebx
  800ee0:	83 c4 10             	add    $0x10,%esp
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	78 1a                	js     800f01 <fd_close+0x6a>
		if (dev->dev_close)
  800ee7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eea:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800eed:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	74 0b                	je     800f01 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800ef6:	83 ec 0c             	sub    $0xc,%esp
  800ef9:	56                   	push   %esi
  800efa:	ff d0                	call   *%eax
  800efc:	89 c3                	mov    %eax,%ebx
  800efe:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f01:	83 ec 08             	sub    $0x8,%esp
  800f04:	56                   	push   %esi
  800f05:	6a 00                	push   $0x0
  800f07:	e8 c1 fc ff ff       	call   800bcd <sys_page_unmap>
	return r;
  800f0c:	83 c4 10             	add    $0x10,%esp
  800f0f:	89 d8                	mov    %ebx,%eax
}
  800f11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f14:	5b                   	pop    %ebx
  800f15:	5e                   	pop    %esi
  800f16:	5d                   	pop    %ebp
  800f17:	c3                   	ret    

00800f18 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f18:	55                   	push   %ebp
  800f19:	89 e5                	mov    %esp,%ebp
  800f1b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f1e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f21:	50                   	push   %eax
  800f22:	ff 75 08             	pushl  0x8(%ebp)
  800f25:	e8 c4 fe ff ff       	call   800dee <fd_lookup>
  800f2a:	83 c4 08             	add    $0x8,%esp
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	78 10                	js     800f41 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f31:	83 ec 08             	sub    $0x8,%esp
  800f34:	6a 01                	push   $0x1
  800f36:	ff 75 f4             	pushl  -0xc(%ebp)
  800f39:	e8 59 ff ff ff       	call   800e97 <fd_close>
  800f3e:	83 c4 10             	add    $0x10,%esp
}
  800f41:	c9                   	leave  
  800f42:	c3                   	ret    

00800f43 <close_all>:

void
close_all(void)
{
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	53                   	push   %ebx
  800f47:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f4a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f4f:	83 ec 0c             	sub    $0xc,%esp
  800f52:	53                   	push   %ebx
  800f53:	e8 c0 ff ff ff       	call   800f18 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f58:	83 c3 01             	add    $0x1,%ebx
  800f5b:	83 c4 10             	add    $0x10,%esp
  800f5e:	83 fb 20             	cmp    $0x20,%ebx
  800f61:	75 ec                	jne    800f4f <close_all+0xc>
		close(i);
}
  800f63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f66:	c9                   	leave  
  800f67:	c3                   	ret    

00800f68 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	57                   	push   %edi
  800f6c:	56                   	push   %esi
  800f6d:	53                   	push   %ebx
  800f6e:	83 ec 2c             	sub    $0x2c,%esp
  800f71:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f74:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f77:	50                   	push   %eax
  800f78:	ff 75 08             	pushl  0x8(%ebp)
  800f7b:	e8 6e fe ff ff       	call   800dee <fd_lookup>
  800f80:	83 c4 08             	add    $0x8,%esp
  800f83:	85 c0                	test   %eax,%eax
  800f85:	0f 88 c1 00 00 00    	js     80104c <dup+0xe4>
		return r;
	close(newfdnum);
  800f8b:	83 ec 0c             	sub    $0xc,%esp
  800f8e:	56                   	push   %esi
  800f8f:	e8 84 ff ff ff       	call   800f18 <close>

	newfd = INDEX2FD(newfdnum);
  800f94:	89 f3                	mov    %esi,%ebx
  800f96:	c1 e3 0c             	shl    $0xc,%ebx
  800f99:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800f9f:	83 c4 04             	add    $0x4,%esp
  800fa2:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fa5:	e8 de fd ff ff       	call   800d88 <fd2data>
  800faa:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fac:	89 1c 24             	mov    %ebx,(%esp)
  800faf:	e8 d4 fd ff ff       	call   800d88 <fd2data>
  800fb4:	83 c4 10             	add    $0x10,%esp
  800fb7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fba:	89 f8                	mov    %edi,%eax
  800fbc:	c1 e8 16             	shr    $0x16,%eax
  800fbf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fc6:	a8 01                	test   $0x1,%al
  800fc8:	74 37                	je     801001 <dup+0x99>
  800fca:	89 f8                	mov    %edi,%eax
  800fcc:	c1 e8 0c             	shr    $0xc,%eax
  800fcf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fd6:	f6 c2 01             	test   $0x1,%dl
  800fd9:	74 26                	je     801001 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fdb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800fe2:	83 ec 0c             	sub    $0xc,%esp
  800fe5:	25 07 0e 00 00       	and    $0xe07,%eax
  800fea:	50                   	push   %eax
  800feb:	ff 75 d4             	pushl  -0x2c(%ebp)
  800fee:	6a 00                	push   $0x0
  800ff0:	57                   	push   %edi
  800ff1:	6a 00                	push   $0x0
  800ff3:	e8 93 fb ff ff       	call   800b8b <sys_page_map>
  800ff8:	89 c7                	mov    %eax,%edi
  800ffa:	83 c4 20             	add    $0x20,%esp
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	78 2e                	js     80102f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801001:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801004:	89 d0                	mov    %edx,%eax
  801006:	c1 e8 0c             	shr    $0xc,%eax
  801009:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801010:	83 ec 0c             	sub    $0xc,%esp
  801013:	25 07 0e 00 00       	and    $0xe07,%eax
  801018:	50                   	push   %eax
  801019:	53                   	push   %ebx
  80101a:	6a 00                	push   $0x0
  80101c:	52                   	push   %edx
  80101d:	6a 00                	push   $0x0
  80101f:	e8 67 fb ff ff       	call   800b8b <sys_page_map>
  801024:	89 c7                	mov    %eax,%edi
  801026:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801029:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80102b:	85 ff                	test   %edi,%edi
  80102d:	79 1d                	jns    80104c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80102f:	83 ec 08             	sub    $0x8,%esp
  801032:	53                   	push   %ebx
  801033:	6a 00                	push   $0x0
  801035:	e8 93 fb ff ff       	call   800bcd <sys_page_unmap>
	sys_page_unmap(0, nva);
  80103a:	83 c4 08             	add    $0x8,%esp
  80103d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801040:	6a 00                	push   $0x0
  801042:	e8 86 fb ff ff       	call   800bcd <sys_page_unmap>
	return r;
  801047:	83 c4 10             	add    $0x10,%esp
  80104a:	89 f8                	mov    %edi,%eax
}
  80104c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80104f:	5b                   	pop    %ebx
  801050:	5e                   	pop    %esi
  801051:	5f                   	pop    %edi
  801052:	5d                   	pop    %ebp
  801053:	c3                   	ret    

00801054 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801054:	55                   	push   %ebp
  801055:	89 e5                	mov    %esp,%ebp
  801057:	53                   	push   %ebx
  801058:	83 ec 14             	sub    $0x14,%esp
  80105b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80105e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801061:	50                   	push   %eax
  801062:	53                   	push   %ebx
  801063:	e8 86 fd ff ff       	call   800dee <fd_lookup>
  801068:	83 c4 08             	add    $0x8,%esp
  80106b:	89 c2                	mov    %eax,%edx
  80106d:	85 c0                	test   %eax,%eax
  80106f:	78 6d                	js     8010de <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801071:	83 ec 08             	sub    $0x8,%esp
  801074:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801077:	50                   	push   %eax
  801078:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80107b:	ff 30                	pushl  (%eax)
  80107d:	e8 c2 fd ff ff       	call   800e44 <dev_lookup>
  801082:	83 c4 10             	add    $0x10,%esp
  801085:	85 c0                	test   %eax,%eax
  801087:	78 4c                	js     8010d5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801089:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80108c:	8b 42 08             	mov    0x8(%edx),%eax
  80108f:	83 e0 03             	and    $0x3,%eax
  801092:	83 f8 01             	cmp    $0x1,%eax
  801095:	75 21                	jne    8010b8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801097:	a1 08 40 80 00       	mov    0x804008,%eax
  80109c:	8b 40 48             	mov    0x48(%eax),%eax
  80109f:	83 ec 04             	sub    $0x4,%esp
  8010a2:	53                   	push   %ebx
  8010a3:	50                   	push   %eax
  8010a4:	68 8d 26 80 00       	push   $0x80268d
  8010a9:	e8 93 f0 ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  8010ae:	83 c4 10             	add    $0x10,%esp
  8010b1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010b6:	eb 26                	jmp    8010de <read+0x8a>
	}
	if (!dev->dev_read)
  8010b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010bb:	8b 40 08             	mov    0x8(%eax),%eax
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	74 17                	je     8010d9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010c2:	83 ec 04             	sub    $0x4,%esp
  8010c5:	ff 75 10             	pushl  0x10(%ebp)
  8010c8:	ff 75 0c             	pushl  0xc(%ebp)
  8010cb:	52                   	push   %edx
  8010cc:	ff d0                	call   *%eax
  8010ce:	89 c2                	mov    %eax,%edx
  8010d0:	83 c4 10             	add    $0x10,%esp
  8010d3:	eb 09                	jmp    8010de <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010d5:	89 c2                	mov    %eax,%edx
  8010d7:	eb 05                	jmp    8010de <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010d9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010de:	89 d0                	mov    %edx,%eax
  8010e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e3:	c9                   	leave  
  8010e4:	c3                   	ret    

008010e5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	57                   	push   %edi
  8010e9:	56                   	push   %esi
  8010ea:	53                   	push   %ebx
  8010eb:	83 ec 0c             	sub    $0xc,%esp
  8010ee:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010f1:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8010f4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8010f9:	eb 21                	jmp    80111c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8010fb:	83 ec 04             	sub    $0x4,%esp
  8010fe:	89 f0                	mov    %esi,%eax
  801100:	29 d8                	sub    %ebx,%eax
  801102:	50                   	push   %eax
  801103:	89 d8                	mov    %ebx,%eax
  801105:	03 45 0c             	add    0xc(%ebp),%eax
  801108:	50                   	push   %eax
  801109:	57                   	push   %edi
  80110a:	e8 45 ff ff ff       	call   801054 <read>
		if (m < 0)
  80110f:	83 c4 10             	add    $0x10,%esp
  801112:	85 c0                	test   %eax,%eax
  801114:	78 10                	js     801126 <readn+0x41>
			return m;
		if (m == 0)
  801116:	85 c0                	test   %eax,%eax
  801118:	74 0a                	je     801124 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80111a:	01 c3                	add    %eax,%ebx
  80111c:	39 f3                	cmp    %esi,%ebx
  80111e:	72 db                	jb     8010fb <readn+0x16>
  801120:	89 d8                	mov    %ebx,%eax
  801122:	eb 02                	jmp    801126 <readn+0x41>
  801124:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801126:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801129:	5b                   	pop    %ebx
  80112a:	5e                   	pop    %esi
  80112b:	5f                   	pop    %edi
  80112c:	5d                   	pop    %ebp
  80112d:	c3                   	ret    

0080112e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	53                   	push   %ebx
  801132:	83 ec 14             	sub    $0x14,%esp
  801135:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801138:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80113b:	50                   	push   %eax
  80113c:	53                   	push   %ebx
  80113d:	e8 ac fc ff ff       	call   800dee <fd_lookup>
  801142:	83 c4 08             	add    $0x8,%esp
  801145:	89 c2                	mov    %eax,%edx
  801147:	85 c0                	test   %eax,%eax
  801149:	78 68                	js     8011b3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114b:	83 ec 08             	sub    $0x8,%esp
  80114e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801151:	50                   	push   %eax
  801152:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801155:	ff 30                	pushl  (%eax)
  801157:	e8 e8 fc ff ff       	call   800e44 <dev_lookup>
  80115c:	83 c4 10             	add    $0x10,%esp
  80115f:	85 c0                	test   %eax,%eax
  801161:	78 47                	js     8011aa <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801163:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801166:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80116a:	75 21                	jne    80118d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80116c:	a1 08 40 80 00       	mov    0x804008,%eax
  801171:	8b 40 48             	mov    0x48(%eax),%eax
  801174:	83 ec 04             	sub    $0x4,%esp
  801177:	53                   	push   %ebx
  801178:	50                   	push   %eax
  801179:	68 a9 26 80 00       	push   $0x8026a9
  80117e:	e8 be ef ff ff       	call   800141 <cprintf>
		return -E_INVAL;
  801183:	83 c4 10             	add    $0x10,%esp
  801186:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80118b:	eb 26                	jmp    8011b3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80118d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801190:	8b 52 0c             	mov    0xc(%edx),%edx
  801193:	85 d2                	test   %edx,%edx
  801195:	74 17                	je     8011ae <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801197:	83 ec 04             	sub    $0x4,%esp
  80119a:	ff 75 10             	pushl  0x10(%ebp)
  80119d:	ff 75 0c             	pushl  0xc(%ebp)
  8011a0:	50                   	push   %eax
  8011a1:	ff d2                	call   *%edx
  8011a3:	89 c2                	mov    %eax,%edx
  8011a5:	83 c4 10             	add    $0x10,%esp
  8011a8:	eb 09                	jmp    8011b3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011aa:	89 c2                	mov    %eax,%edx
  8011ac:	eb 05                	jmp    8011b3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011ae:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011b3:	89 d0                	mov    %edx,%eax
  8011b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011b8:	c9                   	leave  
  8011b9:	c3                   	ret    

008011ba <seek>:

int
seek(int fdnum, off_t offset)
{
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011c0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011c3:	50                   	push   %eax
  8011c4:	ff 75 08             	pushl  0x8(%ebp)
  8011c7:	e8 22 fc ff ff       	call   800dee <fd_lookup>
  8011cc:	83 c4 08             	add    $0x8,%esp
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	78 0e                	js     8011e1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011d3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011d9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011e1:	c9                   	leave  
  8011e2:	c3                   	ret    

008011e3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011e3:	55                   	push   %ebp
  8011e4:	89 e5                	mov    %esp,%ebp
  8011e6:	53                   	push   %ebx
  8011e7:	83 ec 14             	sub    $0x14,%esp
  8011ea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ed:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f0:	50                   	push   %eax
  8011f1:	53                   	push   %ebx
  8011f2:	e8 f7 fb ff ff       	call   800dee <fd_lookup>
  8011f7:	83 c4 08             	add    $0x8,%esp
  8011fa:	89 c2                	mov    %eax,%edx
  8011fc:	85 c0                	test   %eax,%eax
  8011fe:	78 65                	js     801265 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801200:	83 ec 08             	sub    $0x8,%esp
  801203:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801206:	50                   	push   %eax
  801207:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120a:	ff 30                	pushl  (%eax)
  80120c:	e8 33 fc ff ff       	call   800e44 <dev_lookup>
  801211:	83 c4 10             	add    $0x10,%esp
  801214:	85 c0                	test   %eax,%eax
  801216:	78 44                	js     80125c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801218:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80121f:	75 21                	jne    801242 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801221:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801226:	8b 40 48             	mov    0x48(%eax),%eax
  801229:	83 ec 04             	sub    $0x4,%esp
  80122c:	53                   	push   %ebx
  80122d:	50                   	push   %eax
  80122e:	68 6c 26 80 00       	push   $0x80266c
  801233:	e8 09 ef ff ff       	call   800141 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801240:	eb 23                	jmp    801265 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801242:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801245:	8b 52 18             	mov    0x18(%edx),%edx
  801248:	85 d2                	test   %edx,%edx
  80124a:	74 14                	je     801260 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80124c:	83 ec 08             	sub    $0x8,%esp
  80124f:	ff 75 0c             	pushl  0xc(%ebp)
  801252:	50                   	push   %eax
  801253:	ff d2                	call   *%edx
  801255:	89 c2                	mov    %eax,%edx
  801257:	83 c4 10             	add    $0x10,%esp
  80125a:	eb 09                	jmp    801265 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80125c:	89 c2                	mov    %eax,%edx
  80125e:	eb 05                	jmp    801265 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801260:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801265:	89 d0                	mov    %edx,%eax
  801267:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80126a:	c9                   	leave  
  80126b:	c3                   	ret    

0080126c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80126c:	55                   	push   %ebp
  80126d:	89 e5                	mov    %esp,%ebp
  80126f:	53                   	push   %ebx
  801270:	83 ec 14             	sub    $0x14,%esp
  801273:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801276:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801279:	50                   	push   %eax
  80127a:	ff 75 08             	pushl  0x8(%ebp)
  80127d:	e8 6c fb ff ff       	call   800dee <fd_lookup>
  801282:	83 c4 08             	add    $0x8,%esp
  801285:	89 c2                	mov    %eax,%edx
  801287:	85 c0                	test   %eax,%eax
  801289:	78 58                	js     8012e3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128b:	83 ec 08             	sub    $0x8,%esp
  80128e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801291:	50                   	push   %eax
  801292:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801295:	ff 30                	pushl  (%eax)
  801297:	e8 a8 fb ff ff       	call   800e44 <dev_lookup>
  80129c:	83 c4 10             	add    $0x10,%esp
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	78 37                	js     8012da <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012aa:	74 32                	je     8012de <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012ac:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012af:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012b6:	00 00 00 
	stat->st_isdir = 0;
  8012b9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012c0:	00 00 00 
	stat->st_dev = dev;
  8012c3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012c9:	83 ec 08             	sub    $0x8,%esp
  8012cc:	53                   	push   %ebx
  8012cd:	ff 75 f0             	pushl  -0x10(%ebp)
  8012d0:	ff 50 14             	call   *0x14(%eax)
  8012d3:	89 c2                	mov    %eax,%edx
  8012d5:	83 c4 10             	add    $0x10,%esp
  8012d8:	eb 09                	jmp    8012e3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012da:	89 c2                	mov    %eax,%edx
  8012dc:	eb 05                	jmp    8012e3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012e3:	89 d0                	mov    %edx,%eax
  8012e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e8:	c9                   	leave  
  8012e9:	c3                   	ret    

008012ea <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012ea:	55                   	push   %ebp
  8012eb:	89 e5                	mov    %esp,%ebp
  8012ed:	56                   	push   %esi
  8012ee:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012ef:	83 ec 08             	sub    $0x8,%esp
  8012f2:	6a 00                	push   $0x0
  8012f4:	ff 75 08             	pushl  0x8(%ebp)
  8012f7:	e8 e3 01 00 00       	call   8014df <open>
  8012fc:	89 c3                	mov    %eax,%ebx
  8012fe:	83 c4 10             	add    $0x10,%esp
  801301:	85 c0                	test   %eax,%eax
  801303:	78 1b                	js     801320 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801305:	83 ec 08             	sub    $0x8,%esp
  801308:	ff 75 0c             	pushl  0xc(%ebp)
  80130b:	50                   	push   %eax
  80130c:	e8 5b ff ff ff       	call   80126c <fstat>
  801311:	89 c6                	mov    %eax,%esi
	close(fd);
  801313:	89 1c 24             	mov    %ebx,(%esp)
  801316:	e8 fd fb ff ff       	call   800f18 <close>
	return r;
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	89 f0                	mov    %esi,%eax
}
  801320:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801323:	5b                   	pop    %ebx
  801324:	5e                   	pop    %esi
  801325:	5d                   	pop    %ebp
  801326:	c3                   	ret    

00801327 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801327:	55                   	push   %ebp
  801328:	89 e5                	mov    %esp,%ebp
  80132a:	56                   	push   %esi
  80132b:	53                   	push   %ebx
  80132c:	89 c6                	mov    %eax,%esi
  80132e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801330:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801337:	75 12                	jne    80134b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801339:	83 ec 0c             	sub    $0xc,%esp
  80133c:	6a 01                	push   $0x1
  80133e:	e8 89 0c 00 00       	call   801fcc <ipc_find_env>
  801343:	a3 00 40 80 00       	mov    %eax,0x804000
  801348:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80134b:	6a 07                	push   $0x7
  80134d:	68 00 50 80 00       	push   $0x805000
  801352:	56                   	push   %esi
  801353:	ff 35 00 40 80 00    	pushl  0x804000
  801359:	e8 1a 0c 00 00       	call   801f78 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80135e:	83 c4 0c             	add    $0xc,%esp
  801361:	6a 00                	push   $0x0
  801363:	53                   	push   %ebx
  801364:	6a 00                	push   $0x0
  801366:	e8 a4 0b 00 00       	call   801f0f <ipc_recv>
}
  80136b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80136e:	5b                   	pop    %ebx
  80136f:	5e                   	pop    %esi
  801370:	5d                   	pop    %ebp
  801371:	c3                   	ret    

00801372 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801372:	55                   	push   %ebp
  801373:	89 e5                	mov    %esp,%ebp
  801375:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801378:	8b 45 08             	mov    0x8(%ebp),%eax
  80137b:	8b 40 0c             	mov    0xc(%eax),%eax
  80137e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801383:	8b 45 0c             	mov    0xc(%ebp),%eax
  801386:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80138b:	ba 00 00 00 00       	mov    $0x0,%edx
  801390:	b8 02 00 00 00       	mov    $0x2,%eax
  801395:	e8 8d ff ff ff       	call   801327 <fsipc>
}
  80139a:	c9                   	leave  
  80139b:	c3                   	ret    

0080139c <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80139c:	55                   	push   %ebp
  80139d:	89 e5                	mov    %esp,%ebp
  80139f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a5:	8b 40 0c             	mov    0xc(%eax),%eax
  8013a8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8013b2:	b8 06 00 00 00       	mov    $0x6,%eax
  8013b7:	e8 6b ff ff ff       	call   801327 <fsipc>
}
  8013bc:	c9                   	leave  
  8013bd:	c3                   	ret    

008013be <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013be:	55                   	push   %ebp
  8013bf:	89 e5                	mov    %esp,%ebp
  8013c1:	53                   	push   %ebx
  8013c2:	83 ec 04             	sub    $0x4,%esp
  8013c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013c8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013cb:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ce:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013d3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d8:	b8 05 00 00 00       	mov    $0x5,%eax
  8013dd:	e8 45 ff ff ff       	call   801327 <fsipc>
  8013e2:	85 c0                	test   %eax,%eax
  8013e4:	78 2c                	js     801412 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013e6:	83 ec 08             	sub    $0x8,%esp
  8013e9:	68 00 50 80 00       	push   $0x805000
  8013ee:	53                   	push   %ebx
  8013ef:	e8 51 f3 ff ff       	call   800745 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8013f4:	a1 80 50 80 00       	mov    0x805080,%eax
  8013f9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8013ff:	a1 84 50 80 00       	mov    0x805084,%eax
  801404:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801412:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801415:	c9                   	leave  
  801416:	c3                   	ret    

00801417 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	83 ec 0c             	sub    $0xc,%esp
  80141d:	8b 45 10             	mov    0x10(%ebp),%eax
  801420:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801425:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80142a:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80142d:	8b 55 08             	mov    0x8(%ebp),%edx
  801430:	8b 52 0c             	mov    0xc(%edx),%edx
  801433:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801439:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80143e:	50                   	push   %eax
  80143f:	ff 75 0c             	pushl  0xc(%ebp)
  801442:	68 08 50 80 00       	push   $0x805008
  801447:	e8 8b f4 ff ff       	call   8008d7 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80144c:	ba 00 00 00 00       	mov    $0x0,%edx
  801451:	b8 04 00 00 00       	mov    $0x4,%eax
  801456:	e8 cc fe ff ff       	call   801327 <fsipc>
	//panic("devfile_write not implemented");
}
  80145b:	c9                   	leave  
  80145c:	c3                   	ret    

0080145d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80145d:	55                   	push   %ebp
  80145e:	89 e5                	mov    %esp,%ebp
  801460:	56                   	push   %esi
  801461:	53                   	push   %ebx
  801462:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801465:	8b 45 08             	mov    0x8(%ebp),%eax
  801468:	8b 40 0c             	mov    0xc(%eax),%eax
  80146b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801470:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801476:	ba 00 00 00 00       	mov    $0x0,%edx
  80147b:	b8 03 00 00 00       	mov    $0x3,%eax
  801480:	e8 a2 fe ff ff       	call   801327 <fsipc>
  801485:	89 c3                	mov    %eax,%ebx
  801487:	85 c0                	test   %eax,%eax
  801489:	78 4b                	js     8014d6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80148b:	39 c6                	cmp    %eax,%esi
  80148d:	73 16                	jae    8014a5 <devfile_read+0x48>
  80148f:	68 dc 26 80 00       	push   $0x8026dc
  801494:	68 e3 26 80 00       	push   $0x8026e3
  801499:	6a 7c                	push   $0x7c
  80149b:	68 f8 26 80 00       	push   $0x8026f8
  8014a0:	e8 24 0a 00 00       	call   801ec9 <_panic>
	assert(r <= PGSIZE);
  8014a5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014aa:	7e 16                	jle    8014c2 <devfile_read+0x65>
  8014ac:	68 03 27 80 00       	push   $0x802703
  8014b1:	68 e3 26 80 00       	push   $0x8026e3
  8014b6:	6a 7d                	push   $0x7d
  8014b8:	68 f8 26 80 00       	push   $0x8026f8
  8014bd:	e8 07 0a 00 00       	call   801ec9 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014c2:	83 ec 04             	sub    $0x4,%esp
  8014c5:	50                   	push   %eax
  8014c6:	68 00 50 80 00       	push   $0x805000
  8014cb:	ff 75 0c             	pushl  0xc(%ebp)
  8014ce:	e8 04 f4 ff ff       	call   8008d7 <memmove>
	return r;
  8014d3:	83 c4 10             	add    $0x10,%esp
}
  8014d6:	89 d8                	mov    %ebx,%eax
  8014d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014db:	5b                   	pop    %ebx
  8014dc:	5e                   	pop    %esi
  8014dd:	5d                   	pop    %ebp
  8014de:	c3                   	ret    

008014df <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	53                   	push   %ebx
  8014e3:	83 ec 20             	sub    $0x20,%esp
  8014e6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014e9:	53                   	push   %ebx
  8014ea:	e8 1d f2 ff ff       	call   80070c <strlen>
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8014f7:	7f 67                	jg     801560 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8014f9:	83 ec 0c             	sub    $0xc,%esp
  8014fc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ff:	50                   	push   %eax
  801500:	e8 9a f8 ff ff       	call   800d9f <fd_alloc>
  801505:	83 c4 10             	add    $0x10,%esp
		return r;
  801508:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80150a:	85 c0                	test   %eax,%eax
  80150c:	78 57                	js     801565 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80150e:	83 ec 08             	sub    $0x8,%esp
  801511:	53                   	push   %ebx
  801512:	68 00 50 80 00       	push   $0x805000
  801517:	e8 29 f2 ff ff       	call   800745 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80151c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80151f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801524:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801527:	b8 01 00 00 00       	mov    $0x1,%eax
  80152c:	e8 f6 fd ff ff       	call   801327 <fsipc>
  801531:	89 c3                	mov    %eax,%ebx
  801533:	83 c4 10             	add    $0x10,%esp
  801536:	85 c0                	test   %eax,%eax
  801538:	79 14                	jns    80154e <open+0x6f>
		fd_close(fd, 0);
  80153a:	83 ec 08             	sub    $0x8,%esp
  80153d:	6a 00                	push   $0x0
  80153f:	ff 75 f4             	pushl  -0xc(%ebp)
  801542:	e8 50 f9 ff ff       	call   800e97 <fd_close>
		return r;
  801547:	83 c4 10             	add    $0x10,%esp
  80154a:	89 da                	mov    %ebx,%edx
  80154c:	eb 17                	jmp    801565 <open+0x86>
	}

	return fd2num(fd);
  80154e:	83 ec 0c             	sub    $0xc,%esp
  801551:	ff 75 f4             	pushl  -0xc(%ebp)
  801554:	e8 1f f8 ff ff       	call   800d78 <fd2num>
  801559:	89 c2                	mov    %eax,%edx
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	eb 05                	jmp    801565 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801560:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801565:	89 d0                	mov    %edx,%eax
  801567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156a:	c9                   	leave  
  80156b:	c3                   	ret    

0080156c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801572:	ba 00 00 00 00       	mov    $0x0,%edx
  801577:	b8 08 00 00 00       	mov    $0x8,%eax
  80157c:	e8 a6 fd ff ff       	call   801327 <fsipc>
}
  801581:	c9                   	leave  
  801582:	c3                   	ret    

00801583 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801583:	55                   	push   %ebp
  801584:	89 e5                	mov    %esp,%ebp
  801586:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801589:	68 0f 27 80 00       	push   $0x80270f
  80158e:	ff 75 0c             	pushl  0xc(%ebp)
  801591:	e8 af f1 ff ff       	call   800745 <strcpy>
	return 0;
}
  801596:	b8 00 00 00 00       	mov    $0x0,%eax
  80159b:	c9                   	leave  
  80159c:	c3                   	ret    

0080159d <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  80159d:	55                   	push   %ebp
  80159e:	89 e5                	mov    %esp,%ebp
  8015a0:	53                   	push   %ebx
  8015a1:	83 ec 10             	sub    $0x10,%esp
  8015a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8015a7:	53                   	push   %ebx
  8015a8:	e8 58 0a 00 00       	call   802005 <pageref>
  8015ad:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8015b0:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8015b5:	83 f8 01             	cmp    $0x1,%eax
  8015b8:	75 10                	jne    8015ca <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8015ba:	83 ec 0c             	sub    $0xc,%esp
  8015bd:	ff 73 0c             	pushl  0xc(%ebx)
  8015c0:	e8 c0 02 00 00       	call   801885 <nsipc_close>
  8015c5:	89 c2                	mov    %eax,%edx
  8015c7:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8015ca:	89 d0                	mov    %edx,%eax
  8015cc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015cf:	c9                   	leave  
  8015d0:	c3                   	ret    

008015d1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015d7:	6a 00                	push   $0x0
  8015d9:	ff 75 10             	pushl  0x10(%ebp)
  8015dc:	ff 75 0c             	pushl  0xc(%ebp)
  8015df:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e2:	ff 70 0c             	pushl  0xc(%eax)
  8015e5:	e8 78 03 00 00       	call   801962 <nsipc_send>
}
  8015ea:	c9                   	leave  
  8015eb:	c3                   	ret    

008015ec <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8015ec:	55                   	push   %ebp
  8015ed:	89 e5                	mov    %esp,%ebp
  8015ef:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8015f2:	6a 00                	push   $0x0
  8015f4:	ff 75 10             	pushl  0x10(%ebp)
  8015f7:	ff 75 0c             	pushl  0xc(%ebp)
  8015fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fd:	ff 70 0c             	pushl  0xc(%eax)
  801600:	e8 f1 02 00 00       	call   8018f6 <nsipc_recv>
}
  801605:	c9                   	leave  
  801606:	c3                   	ret    

00801607 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801607:	55                   	push   %ebp
  801608:	89 e5                	mov    %esp,%ebp
  80160a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80160d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801610:	52                   	push   %edx
  801611:	50                   	push   %eax
  801612:	e8 d7 f7 ff ff       	call   800dee <fd_lookup>
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	85 c0                	test   %eax,%eax
  80161c:	78 17                	js     801635 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80161e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801621:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801627:	39 08                	cmp    %ecx,(%eax)
  801629:	75 05                	jne    801630 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80162b:	8b 40 0c             	mov    0xc(%eax),%eax
  80162e:	eb 05                	jmp    801635 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801630:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801635:	c9                   	leave  
  801636:	c3                   	ret    

00801637 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801637:	55                   	push   %ebp
  801638:	89 e5                	mov    %esp,%ebp
  80163a:	56                   	push   %esi
  80163b:	53                   	push   %ebx
  80163c:	83 ec 1c             	sub    $0x1c,%esp
  80163f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801641:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801644:	50                   	push   %eax
  801645:	e8 55 f7 ff ff       	call   800d9f <fd_alloc>
  80164a:	89 c3                	mov    %eax,%ebx
  80164c:	83 c4 10             	add    $0x10,%esp
  80164f:	85 c0                	test   %eax,%eax
  801651:	78 1b                	js     80166e <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801653:	83 ec 04             	sub    $0x4,%esp
  801656:	68 07 04 00 00       	push   $0x407
  80165b:	ff 75 f4             	pushl  -0xc(%ebp)
  80165e:	6a 00                	push   $0x0
  801660:	e8 e3 f4 ff ff       	call   800b48 <sys_page_alloc>
  801665:	89 c3                	mov    %eax,%ebx
  801667:	83 c4 10             	add    $0x10,%esp
  80166a:	85 c0                	test   %eax,%eax
  80166c:	79 10                	jns    80167e <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80166e:	83 ec 0c             	sub    $0xc,%esp
  801671:	56                   	push   %esi
  801672:	e8 0e 02 00 00       	call   801885 <nsipc_close>
		return r;
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	89 d8                	mov    %ebx,%eax
  80167c:	eb 24                	jmp    8016a2 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80167e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801684:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801687:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801689:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80168c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801693:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801696:	83 ec 0c             	sub    $0xc,%esp
  801699:	50                   	push   %eax
  80169a:	e8 d9 f6 ff ff       	call   800d78 <fd2num>
  80169f:	83 c4 10             	add    $0x10,%esp
}
  8016a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016a5:	5b                   	pop    %ebx
  8016a6:	5e                   	pop    %esi
  8016a7:	5d                   	pop    %ebp
  8016a8:	c3                   	ret    

008016a9 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8016a9:	55                   	push   %ebp
  8016aa:	89 e5                	mov    %esp,%ebp
  8016ac:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016af:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b2:	e8 50 ff ff ff       	call   801607 <fd2sockid>
		return r;
  8016b7:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	78 1f                	js     8016dc <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016bd:	83 ec 04             	sub    $0x4,%esp
  8016c0:	ff 75 10             	pushl  0x10(%ebp)
  8016c3:	ff 75 0c             	pushl  0xc(%ebp)
  8016c6:	50                   	push   %eax
  8016c7:	e8 12 01 00 00       	call   8017de <nsipc_accept>
  8016cc:	83 c4 10             	add    $0x10,%esp
		return r;
  8016cf:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016d1:	85 c0                	test   %eax,%eax
  8016d3:	78 07                	js     8016dc <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8016d5:	e8 5d ff ff ff       	call   801637 <alloc_sockfd>
  8016da:	89 c1                	mov    %eax,%ecx
}
  8016dc:	89 c8                	mov    %ecx,%eax
  8016de:	c9                   	leave  
  8016df:	c3                   	ret    

008016e0 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8016e0:	55                   	push   %ebp
  8016e1:	89 e5                	mov    %esp,%ebp
  8016e3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e9:	e8 19 ff ff ff       	call   801607 <fd2sockid>
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	78 12                	js     801704 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8016f2:	83 ec 04             	sub    $0x4,%esp
  8016f5:	ff 75 10             	pushl  0x10(%ebp)
  8016f8:	ff 75 0c             	pushl  0xc(%ebp)
  8016fb:	50                   	push   %eax
  8016fc:	e8 2d 01 00 00       	call   80182e <nsipc_bind>
  801701:	83 c4 10             	add    $0x10,%esp
}
  801704:	c9                   	leave  
  801705:	c3                   	ret    

00801706 <shutdown>:

int
shutdown(int s, int how)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80170c:	8b 45 08             	mov    0x8(%ebp),%eax
  80170f:	e8 f3 fe ff ff       	call   801607 <fd2sockid>
  801714:	85 c0                	test   %eax,%eax
  801716:	78 0f                	js     801727 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801718:	83 ec 08             	sub    $0x8,%esp
  80171b:	ff 75 0c             	pushl  0xc(%ebp)
  80171e:	50                   	push   %eax
  80171f:	e8 3f 01 00 00       	call   801863 <nsipc_shutdown>
  801724:	83 c4 10             	add    $0x10,%esp
}
  801727:	c9                   	leave  
  801728:	c3                   	ret    

00801729 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801729:	55                   	push   %ebp
  80172a:	89 e5                	mov    %esp,%ebp
  80172c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80172f:	8b 45 08             	mov    0x8(%ebp),%eax
  801732:	e8 d0 fe ff ff       	call   801607 <fd2sockid>
  801737:	85 c0                	test   %eax,%eax
  801739:	78 12                	js     80174d <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80173b:	83 ec 04             	sub    $0x4,%esp
  80173e:	ff 75 10             	pushl  0x10(%ebp)
  801741:	ff 75 0c             	pushl  0xc(%ebp)
  801744:	50                   	push   %eax
  801745:	e8 55 01 00 00       	call   80189f <nsipc_connect>
  80174a:	83 c4 10             	add    $0x10,%esp
}
  80174d:	c9                   	leave  
  80174e:	c3                   	ret    

0080174f <listen>:

int
listen(int s, int backlog)
{
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801755:	8b 45 08             	mov    0x8(%ebp),%eax
  801758:	e8 aa fe ff ff       	call   801607 <fd2sockid>
  80175d:	85 c0                	test   %eax,%eax
  80175f:	78 0f                	js     801770 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801761:	83 ec 08             	sub    $0x8,%esp
  801764:	ff 75 0c             	pushl  0xc(%ebp)
  801767:	50                   	push   %eax
  801768:	e8 67 01 00 00       	call   8018d4 <nsipc_listen>
  80176d:	83 c4 10             	add    $0x10,%esp
}
  801770:	c9                   	leave  
  801771:	c3                   	ret    

00801772 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801772:	55                   	push   %ebp
  801773:	89 e5                	mov    %esp,%ebp
  801775:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801778:	ff 75 10             	pushl  0x10(%ebp)
  80177b:	ff 75 0c             	pushl  0xc(%ebp)
  80177e:	ff 75 08             	pushl  0x8(%ebp)
  801781:	e8 3a 02 00 00       	call   8019c0 <nsipc_socket>
  801786:	83 c4 10             	add    $0x10,%esp
  801789:	85 c0                	test   %eax,%eax
  80178b:	78 05                	js     801792 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80178d:	e8 a5 fe ff ff       	call   801637 <alloc_sockfd>
}
  801792:	c9                   	leave  
  801793:	c3                   	ret    

00801794 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	53                   	push   %ebx
  801798:	83 ec 04             	sub    $0x4,%esp
  80179b:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  80179d:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8017a4:	75 12                	jne    8017b8 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017a6:	83 ec 0c             	sub    $0xc,%esp
  8017a9:	6a 02                	push   $0x2
  8017ab:	e8 1c 08 00 00       	call   801fcc <ipc_find_env>
  8017b0:	a3 04 40 80 00       	mov    %eax,0x804004
  8017b5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8017b8:	6a 07                	push   $0x7
  8017ba:	68 00 60 80 00       	push   $0x806000
  8017bf:	53                   	push   %ebx
  8017c0:	ff 35 04 40 80 00    	pushl  0x804004
  8017c6:	e8 ad 07 00 00       	call   801f78 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017cb:	83 c4 0c             	add    $0xc,%esp
  8017ce:	6a 00                	push   $0x0
  8017d0:	6a 00                	push   $0x0
  8017d2:	6a 00                	push   $0x0
  8017d4:	e8 36 07 00 00       	call   801f0f <ipc_recv>
}
  8017d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017dc:	c9                   	leave  
  8017dd:	c3                   	ret    

008017de <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	56                   	push   %esi
  8017e2:	53                   	push   %ebx
  8017e3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8017e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8017ee:	8b 06                	mov    (%esi),%eax
  8017f0:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8017f5:	b8 01 00 00 00       	mov    $0x1,%eax
  8017fa:	e8 95 ff ff ff       	call   801794 <nsipc>
  8017ff:	89 c3                	mov    %eax,%ebx
  801801:	85 c0                	test   %eax,%eax
  801803:	78 20                	js     801825 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801805:	83 ec 04             	sub    $0x4,%esp
  801808:	ff 35 10 60 80 00    	pushl  0x806010
  80180e:	68 00 60 80 00       	push   $0x806000
  801813:	ff 75 0c             	pushl  0xc(%ebp)
  801816:	e8 bc f0 ff ff       	call   8008d7 <memmove>
		*addrlen = ret->ret_addrlen;
  80181b:	a1 10 60 80 00       	mov    0x806010,%eax
  801820:	89 06                	mov    %eax,(%esi)
  801822:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801825:	89 d8                	mov    %ebx,%eax
  801827:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182a:	5b                   	pop    %ebx
  80182b:	5e                   	pop    %esi
  80182c:	5d                   	pop    %ebp
  80182d:	c3                   	ret    

0080182e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	53                   	push   %ebx
  801832:	83 ec 08             	sub    $0x8,%esp
  801835:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801838:	8b 45 08             	mov    0x8(%ebp),%eax
  80183b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801840:	53                   	push   %ebx
  801841:	ff 75 0c             	pushl  0xc(%ebp)
  801844:	68 04 60 80 00       	push   $0x806004
  801849:	e8 89 f0 ff ff       	call   8008d7 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80184e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801854:	b8 02 00 00 00       	mov    $0x2,%eax
  801859:	e8 36 ff ff ff       	call   801794 <nsipc>
}
  80185e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801861:	c9                   	leave  
  801862:	c3                   	ret    

00801863 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801863:	55                   	push   %ebp
  801864:	89 e5                	mov    %esp,%ebp
  801866:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801869:	8b 45 08             	mov    0x8(%ebp),%eax
  80186c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801871:	8b 45 0c             	mov    0xc(%ebp),%eax
  801874:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801879:	b8 03 00 00 00       	mov    $0x3,%eax
  80187e:	e8 11 ff ff ff       	call   801794 <nsipc>
}
  801883:	c9                   	leave  
  801884:	c3                   	ret    

00801885 <nsipc_close>:

int
nsipc_close(int s)
{
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80188b:	8b 45 08             	mov    0x8(%ebp),%eax
  80188e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801893:	b8 04 00 00 00       	mov    $0x4,%eax
  801898:	e8 f7 fe ff ff       	call   801794 <nsipc>
}
  80189d:	c9                   	leave  
  80189e:	c3                   	ret    

0080189f <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80189f:	55                   	push   %ebp
  8018a0:	89 e5                	mov    %esp,%ebp
  8018a2:	53                   	push   %ebx
  8018a3:	83 ec 08             	sub    $0x8,%esp
  8018a6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8018a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ac:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8018b1:	53                   	push   %ebx
  8018b2:	ff 75 0c             	pushl  0xc(%ebp)
  8018b5:	68 04 60 80 00       	push   $0x806004
  8018ba:	e8 18 f0 ff ff       	call   8008d7 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8018bf:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8018c5:	b8 05 00 00 00       	mov    $0x5,%eax
  8018ca:	e8 c5 fe ff ff       	call   801794 <nsipc>
}
  8018cf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d2:	c9                   	leave  
  8018d3:	c3                   	ret    

008018d4 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
  8018d7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018da:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dd:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8018e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8018ea:	b8 06 00 00 00       	mov    $0x6,%eax
  8018ef:	e8 a0 fe ff ff       	call   801794 <nsipc>
}
  8018f4:	c9                   	leave  
  8018f5:	c3                   	ret    

008018f6 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8018f6:	55                   	push   %ebp
  8018f7:	89 e5                	mov    %esp,%ebp
  8018f9:	56                   	push   %esi
  8018fa:	53                   	push   %ebx
  8018fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8018fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801901:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801906:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80190c:	8b 45 14             	mov    0x14(%ebp),%eax
  80190f:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801914:	b8 07 00 00 00       	mov    $0x7,%eax
  801919:	e8 76 fe ff ff       	call   801794 <nsipc>
  80191e:	89 c3                	mov    %eax,%ebx
  801920:	85 c0                	test   %eax,%eax
  801922:	78 35                	js     801959 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801924:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801929:	7f 04                	jg     80192f <nsipc_recv+0x39>
  80192b:	39 c6                	cmp    %eax,%esi
  80192d:	7d 16                	jge    801945 <nsipc_recv+0x4f>
  80192f:	68 1b 27 80 00       	push   $0x80271b
  801934:	68 e3 26 80 00       	push   $0x8026e3
  801939:	6a 62                	push   $0x62
  80193b:	68 30 27 80 00       	push   $0x802730
  801940:	e8 84 05 00 00       	call   801ec9 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801945:	83 ec 04             	sub    $0x4,%esp
  801948:	50                   	push   %eax
  801949:	68 00 60 80 00       	push   $0x806000
  80194e:	ff 75 0c             	pushl  0xc(%ebp)
  801951:	e8 81 ef ff ff       	call   8008d7 <memmove>
  801956:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801959:	89 d8                	mov    %ebx,%eax
  80195b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80195e:	5b                   	pop    %ebx
  80195f:	5e                   	pop    %esi
  801960:	5d                   	pop    %ebp
  801961:	c3                   	ret    

00801962 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801962:	55                   	push   %ebp
  801963:	89 e5                	mov    %esp,%ebp
  801965:	53                   	push   %ebx
  801966:	83 ec 04             	sub    $0x4,%esp
  801969:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80196c:	8b 45 08             	mov    0x8(%ebp),%eax
  80196f:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801974:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80197a:	7e 16                	jle    801992 <nsipc_send+0x30>
  80197c:	68 3c 27 80 00       	push   $0x80273c
  801981:	68 e3 26 80 00       	push   $0x8026e3
  801986:	6a 6d                	push   $0x6d
  801988:	68 30 27 80 00       	push   $0x802730
  80198d:	e8 37 05 00 00       	call   801ec9 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801992:	83 ec 04             	sub    $0x4,%esp
  801995:	53                   	push   %ebx
  801996:	ff 75 0c             	pushl  0xc(%ebp)
  801999:	68 0c 60 80 00       	push   $0x80600c
  80199e:	e8 34 ef ff ff       	call   8008d7 <memmove>
	nsipcbuf.send.req_size = size;
  8019a3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8019a9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019ac:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8019b1:	b8 08 00 00 00       	mov    $0x8,%eax
  8019b6:	e8 d9 fd ff ff       	call   801794 <nsipc>
}
  8019bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019be:	c9                   	leave  
  8019bf:	c3                   	ret    

008019c0 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019c0:	55                   	push   %ebp
  8019c1:	89 e5                	mov    %esp,%ebp
  8019c3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019c9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8019ce:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019d1:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8019d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8019d9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8019de:	b8 09 00 00 00       	mov    $0x9,%eax
  8019e3:	e8 ac fd ff ff       	call   801794 <nsipc>
}
  8019e8:	c9                   	leave  
  8019e9:	c3                   	ret    

008019ea <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019ea:	55                   	push   %ebp
  8019eb:	89 e5                	mov    %esp,%ebp
  8019ed:	56                   	push   %esi
  8019ee:	53                   	push   %ebx
  8019ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8019f2:	83 ec 0c             	sub    $0xc,%esp
  8019f5:	ff 75 08             	pushl  0x8(%ebp)
  8019f8:	e8 8b f3 ff ff       	call   800d88 <fd2data>
  8019fd:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8019ff:	83 c4 08             	add    $0x8,%esp
  801a02:	68 48 27 80 00       	push   $0x802748
  801a07:	53                   	push   %ebx
  801a08:	e8 38 ed ff ff       	call   800745 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a0d:	8b 46 04             	mov    0x4(%esi),%eax
  801a10:	2b 06                	sub    (%esi),%eax
  801a12:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a18:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a1f:	00 00 00 
	stat->st_dev = &devpipe;
  801a22:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a29:	30 80 00 
	return 0;
}
  801a2c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a31:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a34:	5b                   	pop    %ebx
  801a35:	5e                   	pop    %esi
  801a36:	5d                   	pop    %ebp
  801a37:	c3                   	ret    

00801a38 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	53                   	push   %ebx
  801a3c:	83 ec 0c             	sub    $0xc,%esp
  801a3f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a42:	53                   	push   %ebx
  801a43:	6a 00                	push   $0x0
  801a45:	e8 83 f1 ff ff       	call   800bcd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a4a:	89 1c 24             	mov    %ebx,(%esp)
  801a4d:	e8 36 f3 ff ff       	call   800d88 <fd2data>
  801a52:	83 c4 08             	add    $0x8,%esp
  801a55:	50                   	push   %eax
  801a56:	6a 00                	push   $0x0
  801a58:	e8 70 f1 ff ff       	call   800bcd <sys_page_unmap>
}
  801a5d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a60:	c9                   	leave  
  801a61:	c3                   	ret    

00801a62 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a62:	55                   	push   %ebp
  801a63:	89 e5                	mov    %esp,%ebp
  801a65:	57                   	push   %edi
  801a66:	56                   	push   %esi
  801a67:	53                   	push   %ebx
  801a68:	83 ec 1c             	sub    $0x1c,%esp
  801a6b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a6e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a70:	a1 08 40 80 00       	mov    0x804008,%eax
  801a75:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a78:	83 ec 0c             	sub    $0xc,%esp
  801a7b:	ff 75 e0             	pushl  -0x20(%ebp)
  801a7e:	e8 82 05 00 00       	call   802005 <pageref>
  801a83:	89 c3                	mov    %eax,%ebx
  801a85:	89 3c 24             	mov    %edi,(%esp)
  801a88:	e8 78 05 00 00       	call   802005 <pageref>
  801a8d:	83 c4 10             	add    $0x10,%esp
  801a90:	39 c3                	cmp    %eax,%ebx
  801a92:	0f 94 c1             	sete   %cl
  801a95:	0f b6 c9             	movzbl %cl,%ecx
  801a98:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801a9b:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801aa1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801aa4:	39 ce                	cmp    %ecx,%esi
  801aa6:	74 1b                	je     801ac3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801aa8:	39 c3                	cmp    %eax,%ebx
  801aaa:	75 c4                	jne    801a70 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801aac:	8b 42 58             	mov    0x58(%edx),%eax
  801aaf:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ab2:	50                   	push   %eax
  801ab3:	56                   	push   %esi
  801ab4:	68 4f 27 80 00       	push   $0x80274f
  801ab9:	e8 83 e6 ff ff       	call   800141 <cprintf>
  801abe:	83 c4 10             	add    $0x10,%esp
  801ac1:	eb ad                	jmp    801a70 <_pipeisclosed+0xe>
	}
}
  801ac3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ac6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac9:	5b                   	pop    %ebx
  801aca:	5e                   	pop    %esi
  801acb:	5f                   	pop    %edi
  801acc:	5d                   	pop    %ebp
  801acd:	c3                   	ret    

00801ace <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	57                   	push   %edi
  801ad2:	56                   	push   %esi
  801ad3:	53                   	push   %ebx
  801ad4:	83 ec 28             	sub    $0x28,%esp
  801ad7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801ada:	56                   	push   %esi
  801adb:	e8 a8 f2 ff ff       	call   800d88 <fd2data>
  801ae0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	bf 00 00 00 00       	mov    $0x0,%edi
  801aea:	eb 4b                	jmp    801b37 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801aec:	89 da                	mov    %ebx,%edx
  801aee:	89 f0                	mov    %esi,%eax
  801af0:	e8 6d ff ff ff       	call   801a62 <_pipeisclosed>
  801af5:	85 c0                	test   %eax,%eax
  801af7:	75 48                	jne    801b41 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801af9:	e8 2b f0 ff ff       	call   800b29 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801afe:	8b 43 04             	mov    0x4(%ebx),%eax
  801b01:	8b 0b                	mov    (%ebx),%ecx
  801b03:	8d 51 20             	lea    0x20(%ecx),%edx
  801b06:	39 d0                	cmp    %edx,%eax
  801b08:	73 e2                	jae    801aec <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b0d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b11:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b14:	89 c2                	mov    %eax,%edx
  801b16:	c1 fa 1f             	sar    $0x1f,%edx
  801b19:	89 d1                	mov    %edx,%ecx
  801b1b:	c1 e9 1b             	shr    $0x1b,%ecx
  801b1e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b21:	83 e2 1f             	and    $0x1f,%edx
  801b24:	29 ca                	sub    %ecx,%edx
  801b26:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b2a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b2e:	83 c0 01             	add    $0x1,%eax
  801b31:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b34:	83 c7 01             	add    $0x1,%edi
  801b37:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b3a:	75 c2                	jne    801afe <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b3c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b3f:	eb 05                	jmp    801b46 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b41:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b49:	5b                   	pop    %ebx
  801b4a:	5e                   	pop    %esi
  801b4b:	5f                   	pop    %edi
  801b4c:	5d                   	pop    %ebp
  801b4d:	c3                   	ret    

00801b4e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b4e:	55                   	push   %ebp
  801b4f:	89 e5                	mov    %esp,%ebp
  801b51:	57                   	push   %edi
  801b52:	56                   	push   %esi
  801b53:	53                   	push   %ebx
  801b54:	83 ec 18             	sub    $0x18,%esp
  801b57:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b5a:	57                   	push   %edi
  801b5b:	e8 28 f2 ff ff       	call   800d88 <fd2data>
  801b60:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b62:	83 c4 10             	add    $0x10,%esp
  801b65:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b6a:	eb 3d                	jmp    801ba9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b6c:	85 db                	test   %ebx,%ebx
  801b6e:	74 04                	je     801b74 <devpipe_read+0x26>
				return i;
  801b70:	89 d8                	mov    %ebx,%eax
  801b72:	eb 44                	jmp    801bb8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b74:	89 f2                	mov    %esi,%edx
  801b76:	89 f8                	mov    %edi,%eax
  801b78:	e8 e5 fe ff ff       	call   801a62 <_pipeisclosed>
  801b7d:	85 c0                	test   %eax,%eax
  801b7f:	75 32                	jne    801bb3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b81:	e8 a3 ef ff ff       	call   800b29 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b86:	8b 06                	mov    (%esi),%eax
  801b88:	3b 46 04             	cmp    0x4(%esi),%eax
  801b8b:	74 df                	je     801b6c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b8d:	99                   	cltd   
  801b8e:	c1 ea 1b             	shr    $0x1b,%edx
  801b91:	01 d0                	add    %edx,%eax
  801b93:	83 e0 1f             	and    $0x1f,%eax
  801b96:	29 d0                	sub    %edx,%eax
  801b98:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801b9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ba0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ba3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ba6:	83 c3 01             	add    $0x1,%ebx
  801ba9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bac:	75 d8                	jne    801b86 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bae:	8b 45 10             	mov    0x10(%ebp),%eax
  801bb1:	eb 05                	jmp    801bb8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bb3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bb8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bbb:	5b                   	pop    %ebx
  801bbc:	5e                   	pop    %esi
  801bbd:	5f                   	pop    %edi
  801bbe:	5d                   	pop    %ebp
  801bbf:	c3                   	ret    

00801bc0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	56                   	push   %esi
  801bc4:	53                   	push   %ebx
  801bc5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bcb:	50                   	push   %eax
  801bcc:	e8 ce f1 ff ff       	call   800d9f <fd_alloc>
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	89 c2                	mov    %eax,%edx
  801bd6:	85 c0                	test   %eax,%eax
  801bd8:	0f 88 2c 01 00 00    	js     801d0a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bde:	83 ec 04             	sub    $0x4,%esp
  801be1:	68 07 04 00 00       	push   $0x407
  801be6:	ff 75 f4             	pushl  -0xc(%ebp)
  801be9:	6a 00                	push   $0x0
  801beb:	e8 58 ef ff ff       	call   800b48 <sys_page_alloc>
  801bf0:	83 c4 10             	add    $0x10,%esp
  801bf3:	89 c2                	mov    %eax,%edx
  801bf5:	85 c0                	test   %eax,%eax
  801bf7:	0f 88 0d 01 00 00    	js     801d0a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801bfd:	83 ec 0c             	sub    $0xc,%esp
  801c00:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c03:	50                   	push   %eax
  801c04:	e8 96 f1 ff ff       	call   800d9f <fd_alloc>
  801c09:	89 c3                	mov    %eax,%ebx
  801c0b:	83 c4 10             	add    $0x10,%esp
  801c0e:	85 c0                	test   %eax,%eax
  801c10:	0f 88 e2 00 00 00    	js     801cf8 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c16:	83 ec 04             	sub    $0x4,%esp
  801c19:	68 07 04 00 00       	push   $0x407
  801c1e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c21:	6a 00                	push   $0x0
  801c23:	e8 20 ef ff ff       	call   800b48 <sys_page_alloc>
  801c28:	89 c3                	mov    %eax,%ebx
  801c2a:	83 c4 10             	add    $0x10,%esp
  801c2d:	85 c0                	test   %eax,%eax
  801c2f:	0f 88 c3 00 00 00    	js     801cf8 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c35:	83 ec 0c             	sub    $0xc,%esp
  801c38:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3b:	e8 48 f1 ff ff       	call   800d88 <fd2data>
  801c40:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c42:	83 c4 0c             	add    $0xc,%esp
  801c45:	68 07 04 00 00       	push   $0x407
  801c4a:	50                   	push   %eax
  801c4b:	6a 00                	push   $0x0
  801c4d:	e8 f6 ee ff ff       	call   800b48 <sys_page_alloc>
  801c52:	89 c3                	mov    %eax,%ebx
  801c54:	83 c4 10             	add    $0x10,%esp
  801c57:	85 c0                	test   %eax,%eax
  801c59:	0f 88 89 00 00 00    	js     801ce8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c5f:	83 ec 0c             	sub    $0xc,%esp
  801c62:	ff 75 f0             	pushl  -0x10(%ebp)
  801c65:	e8 1e f1 ff ff       	call   800d88 <fd2data>
  801c6a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c71:	50                   	push   %eax
  801c72:	6a 00                	push   $0x0
  801c74:	56                   	push   %esi
  801c75:	6a 00                	push   $0x0
  801c77:	e8 0f ef ff ff       	call   800b8b <sys_page_map>
  801c7c:	89 c3                	mov    %eax,%ebx
  801c7e:	83 c4 20             	add    $0x20,%esp
  801c81:	85 c0                	test   %eax,%eax
  801c83:	78 55                	js     801cda <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c85:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c8e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801c90:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c93:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801c9a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ca0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801ca5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ca8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801caf:	83 ec 0c             	sub    $0xc,%esp
  801cb2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb5:	e8 be f0 ff ff       	call   800d78 <fd2num>
  801cba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cbd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cbf:	83 c4 04             	add    $0x4,%esp
  801cc2:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc5:	e8 ae f0 ff ff       	call   800d78 <fd2num>
  801cca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ccd:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801cd0:	83 c4 10             	add    $0x10,%esp
  801cd3:	ba 00 00 00 00       	mov    $0x0,%edx
  801cd8:	eb 30                	jmp    801d0a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cda:	83 ec 08             	sub    $0x8,%esp
  801cdd:	56                   	push   %esi
  801cde:	6a 00                	push   $0x0
  801ce0:	e8 e8 ee ff ff       	call   800bcd <sys_page_unmap>
  801ce5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801ce8:	83 ec 08             	sub    $0x8,%esp
  801ceb:	ff 75 f0             	pushl  -0x10(%ebp)
  801cee:	6a 00                	push   $0x0
  801cf0:	e8 d8 ee ff ff       	call   800bcd <sys_page_unmap>
  801cf5:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801cf8:	83 ec 08             	sub    $0x8,%esp
  801cfb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cfe:	6a 00                	push   $0x0
  801d00:	e8 c8 ee ff ff       	call   800bcd <sys_page_unmap>
  801d05:	83 c4 10             	add    $0x10,%esp
  801d08:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d0a:	89 d0                	mov    %edx,%eax
  801d0c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d0f:	5b                   	pop    %ebx
  801d10:	5e                   	pop    %esi
  801d11:	5d                   	pop    %ebp
  801d12:	c3                   	ret    

00801d13 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d13:	55                   	push   %ebp
  801d14:	89 e5                	mov    %esp,%ebp
  801d16:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d1c:	50                   	push   %eax
  801d1d:	ff 75 08             	pushl  0x8(%ebp)
  801d20:	e8 c9 f0 ff ff       	call   800dee <fd_lookup>
  801d25:	83 c4 10             	add    $0x10,%esp
  801d28:	85 c0                	test   %eax,%eax
  801d2a:	78 18                	js     801d44 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d2c:	83 ec 0c             	sub    $0xc,%esp
  801d2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d32:	e8 51 f0 ff ff       	call   800d88 <fd2data>
	return _pipeisclosed(fd, p);
  801d37:	89 c2                	mov    %eax,%edx
  801d39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d3c:	e8 21 fd ff ff       	call   801a62 <_pipeisclosed>
  801d41:	83 c4 10             	add    $0x10,%esp
}
  801d44:	c9                   	leave  
  801d45:	c3                   	ret    

00801d46 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d46:	55                   	push   %ebp
  801d47:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d49:	b8 00 00 00 00       	mov    $0x0,%eax
  801d4e:	5d                   	pop    %ebp
  801d4f:	c3                   	ret    

00801d50 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d50:	55                   	push   %ebp
  801d51:	89 e5                	mov    %esp,%ebp
  801d53:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d56:	68 67 27 80 00       	push   $0x802767
  801d5b:	ff 75 0c             	pushl  0xc(%ebp)
  801d5e:	e8 e2 e9 ff ff       	call   800745 <strcpy>
	return 0;
}
  801d63:	b8 00 00 00 00       	mov    $0x0,%eax
  801d68:	c9                   	leave  
  801d69:	c3                   	ret    

00801d6a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d6a:	55                   	push   %ebp
  801d6b:	89 e5                	mov    %esp,%ebp
  801d6d:	57                   	push   %edi
  801d6e:	56                   	push   %esi
  801d6f:	53                   	push   %ebx
  801d70:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d76:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d7b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d81:	eb 2d                	jmp    801db0 <devcons_write+0x46>
		m = n - tot;
  801d83:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d86:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d88:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d8b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801d90:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d93:	83 ec 04             	sub    $0x4,%esp
  801d96:	53                   	push   %ebx
  801d97:	03 45 0c             	add    0xc(%ebp),%eax
  801d9a:	50                   	push   %eax
  801d9b:	57                   	push   %edi
  801d9c:	e8 36 eb ff ff       	call   8008d7 <memmove>
		sys_cputs(buf, m);
  801da1:	83 c4 08             	add    $0x8,%esp
  801da4:	53                   	push   %ebx
  801da5:	57                   	push   %edi
  801da6:	e8 e1 ec ff ff       	call   800a8c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dab:	01 de                	add    %ebx,%esi
  801dad:	83 c4 10             	add    $0x10,%esp
  801db0:	89 f0                	mov    %esi,%eax
  801db2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801db5:	72 cc                	jb     801d83 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801db7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dba:	5b                   	pop    %ebx
  801dbb:	5e                   	pop    %esi
  801dbc:	5f                   	pop    %edi
  801dbd:	5d                   	pop    %ebp
  801dbe:	c3                   	ret    

00801dbf <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	83 ec 08             	sub    $0x8,%esp
  801dc5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dce:	74 2a                	je     801dfa <devcons_read+0x3b>
  801dd0:	eb 05                	jmp    801dd7 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801dd2:	e8 52 ed ff ff       	call   800b29 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801dd7:	e8 ce ec ff ff       	call   800aaa <sys_cgetc>
  801ddc:	85 c0                	test   %eax,%eax
  801dde:	74 f2                	je     801dd2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801de0:	85 c0                	test   %eax,%eax
  801de2:	78 16                	js     801dfa <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801de4:	83 f8 04             	cmp    $0x4,%eax
  801de7:	74 0c                	je     801df5 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801de9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dec:	88 02                	mov    %al,(%edx)
	return 1;
  801dee:	b8 01 00 00 00       	mov    $0x1,%eax
  801df3:	eb 05                	jmp    801dfa <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801df5:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801dfa:	c9                   	leave  
  801dfb:	c3                   	ret    

00801dfc <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
  801dff:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e02:	8b 45 08             	mov    0x8(%ebp),%eax
  801e05:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e08:	6a 01                	push   $0x1
  801e0a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e0d:	50                   	push   %eax
  801e0e:	e8 79 ec ff ff       	call   800a8c <sys_cputs>
}
  801e13:	83 c4 10             	add    $0x10,%esp
  801e16:	c9                   	leave  
  801e17:	c3                   	ret    

00801e18 <getchar>:

int
getchar(void)
{
  801e18:	55                   	push   %ebp
  801e19:	89 e5                	mov    %esp,%ebp
  801e1b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e1e:	6a 01                	push   $0x1
  801e20:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e23:	50                   	push   %eax
  801e24:	6a 00                	push   $0x0
  801e26:	e8 29 f2 ff ff       	call   801054 <read>
	if (r < 0)
  801e2b:	83 c4 10             	add    $0x10,%esp
  801e2e:	85 c0                	test   %eax,%eax
  801e30:	78 0f                	js     801e41 <getchar+0x29>
		return r;
	if (r < 1)
  801e32:	85 c0                	test   %eax,%eax
  801e34:	7e 06                	jle    801e3c <getchar+0x24>
		return -E_EOF;
	return c;
  801e36:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e3a:	eb 05                	jmp    801e41 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e3c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e41:	c9                   	leave  
  801e42:	c3                   	ret    

00801e43 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e43:	55                   	push   %ebp
  801e44:	89 e5                	mov    %esp,%ebp
  801e46:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e4c:	50                   	push   %eax
  801e4d:	ff 75 08             	pushl  0x8(%ebp)
  801e50:	e8 99 ef ff ff       	call   800dee <fd_lookup>
  801e55:	83 c4 10             	add    $0x10,%esp
  801e58:	85 c0                	test   %eax,%eax
  801e5a:	78 11                	js     801e6d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e5f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e65:	39 10                	cmp    %edx,(%eax)
  801e67:	0f 94 c0             	sete   %al
  801e6a:	0f b6 c0             	movzbl %al,%eax
}
  801e6d:	c9                   	leave  
  801e6e:	c3                   	ret    

00801e6f <opencons>:

int
opencons(void)
{
  801e6f:	55                   	push   %ebp
  801e70:	89 e5                	mov    %esp,%ebp
  801e72:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e75:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e78:	50                   	push   %eax
  801e79:	e8 21 ef ff ff       	call   800d9f <fd_alloc>
  801e7e:	83 c4 10             	add    $0x10,%esp
		return r;
  801e81:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e83:	85 c0                	test   %eax,%eax
  801e85:	78 3e                	js     801ec5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e87:	83 ec 04             	sub    $0x4,%esp
  801e8a:	68 07 04 00 00       	push   $0x407
  801e8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801e92:	6a 00                	push   $0x0
  801e94:	e8 af ec ff ff       	call   800b48 <sys_page_alloc>
  801e99:	83 c4 10             	add    $0x10,%esp
		return r;
  801e9c:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	78 23                	js     801ec5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ea2:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801ea8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eab:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ead:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801eb0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801eb7:	83 ec 0c             	sub    $0xc,%esp
  801eba:	50                   	push   %eax
  801ebb:	e8 b8 ee ff ff       	call   800d78 <fd2num>
  801ec0:	89 c2                	mov    %eax,%edx
  801ec2:	83 c4 10             	add    $0x10,%esp
}
  801ec5:	89 d0                	mov    %edx,%eax
  801ec7:	c9                   	leave  
  801ec8:	c3                   	ret    

00801ec9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ec9:	55                   	push   %ebp
  801eca:	89 e5                	mov    %esp,%ebp
  801ecc:	56                   	push   %esi
  801ecd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ece:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ed1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ed7:	e8 2e ec ff ff       	call   800b0a <sys_getenvid>
  801edc:	83 ec 0c             	sub    $0xc,%esp
  801edf:	ff 75 0c             	pushl  0xc(%ebp)
  801ee2:	ff 75 08             	pushl  0x8(%ebp)
  801ee5:	56                   	push   %esi
  801ee6:	50                   	push   %eax
  801ee7:	68 74 27 80 00       	push   $0x802774
  801eec:	e8 50 e2 ff ff       	call   800141 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801ef1:	83 c4 18             	add    $0x18,%esp
  801ef4:	53                   	push   %ebx
  801ef5:	ff 75 10             	pushl  0x10(%ebp)
  801ef8:	e8 f3 e1 ff ff       	call   8000f0 <vcprintf>
	cprintf("\n");
  801efd:	c7 04 24 60 27 80 00 	movl   $0x802760,(%esp)
  801f04:	e8 38 e2 ff ff       	call   800141 <cprintf>
  801f09:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f0c:	cc                   	int3   
  801f0d:	eb fd                	jmp    801f0c <_panic+0x43>

00801f0f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f0f:	55                   	push   %ebp
  801f10:	89 e5                	mov    %esp,%ebp
  801f12:	56                   	push   %esi
  801f13:	53                   	push   %ebx
  801f14:	8b 75 08             	mov    0x8(%ebp),%esi
  801f17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801f1d:	85 c0                	test   %eax,%eax
  801f1f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f24:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801f27:	83 ec 0c             	sub    $0xc,%esp
  801f2a:	50                   	push   %eax
  801f2b:	e8 c8 ed ff ff       	call   800cf8 <sys_ipc_recv>
  801f30:	83 c4 10             	add    $0x10,%esp
  801f33:	85 c0                	test   %eax,%eax
  801f35:	79 16                	jns    801f4d <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801f37:	85 f6                	test   %esi,%esi
  801f39:	74 06                	je     801f41 <ipc_recv+0x32>
            *from_env_store = 0;
  801f3b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801f41:	85 db                	test   %ebx,%ebx
  801f43:	74 2c                	je     801f71 <ipc_recv+0x62>
            *perm_store = 0;
  801f45:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f4b:	eb 24                	jmp    801f71 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801f4d:	85 f6                	test   %esi,%esi
  801f4f:	74 0a                	je     801f5b <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801f51:	a1 08 40 80 00       	mov    0x804008,%eax
  801f56:	8b 40 74             	mov    0x74(%eax),%eax
  801f59:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801f5b:	85 db                	test   %ebx,%ebx
  801f5d:	74 0a                	je     801f69 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801f5f:	a1 08 40 80 00       	mov    0x804008,%eax
  801f64:	8b 40 78             	mov    0x78(%eax),%eax
  801f67:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801f69:	a1 08 40 80 00       	mov    0x804008,%eax
  801f6e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801f71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f74:	5b                   	pop    %ebx
  801f75:	5e                   	pop    %esi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    

00801f78 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	57                   	push   %edi
  801f7c:	56                   	push   %esi
  801f7d:	53                   	push   %ebx
  801f7e:	83 ec 0c             	sub    $0xc,%esp
  801f81:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f84:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f87:	8b 45 10             	mov    0x10(%ebp),%eax
  801f8a:	85 c0                	test   %eax,%eax
  801f8c:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801f91:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801f94:	eb 1c                	jmp    801fb2 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801f96:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f99:	74 12                	je     801fad <ipc_send+0x35>
  801f9b:	50                   	push   %eax
  801f9c:	68 98 27 80 00       	push   $0x802798
  801fa1:	6a 3b                	push   $0x3b
  801fa3:	68 ae 27 80 00       	push   $0x8027ae
  801fa8:	e8 1c ff ff ff       	call   801ec9 <_panic>
		sys_yield();
  801fad:	e8 77 eb ff ff       	call   800b29 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801fb2:	ff 75 14             	pushl  0x14(%ebp)
  801fb5:	53                   	push   %ebx
  801fb6:	56                   	push   %esi
  801fb7:	57                   	push   %edi
  801fb8:	e8 18 ed ff ff       	call   800cd5 <sys_ipc_try_send>
  801fbd:	83 c4 10             	add    $0x10,%esp
  801fc0:	85 c0                	test   %eax,%eax
  801fc2:	78 d2                	js     801f96 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801fc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc7:	5b                   	pop    %ebx
  801fc8:	5e                   	pop    %esi
  801fc9:	5f                   	pop    %edi
  801fca:	5d                   	pop    %ebp
  801fcb:	c3                   	ret    

00801fcc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fcc:	55                   	push   %ebp
  801fcd:	89 e5                	mov    %esp,%ebp
  801fcf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fd2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fd7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fda:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fe0:	8b 52 50             	mov    0x50(%edx),%edx
  801fe3:	39 ca                	cmp    %ecx,%edx
  801fe5:	75 0d                	jne    801ff4 <ipc_find_env+0x28>
			return envs[i].env_id;
  801fe7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fea:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fef:	8b 40 48             	mov    0x48(%eax),%eax
  801ff2:	eb 0f                	jmp    802003 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ff4:	83 c0 01             	add    $0x1,%eax
  801ff7:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ffc:	75 d9                	jne    801fd7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ffe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802003:	5d                   	pop    %ebp
  802004:	c3                   	ret    

00802005 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802005:	55                   	push   %ebp
  802006:	89 e5                	mov    %esp,%ebp
  802008:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80200b:	89 d0                	mov    %edx,%eax
  80200d:	c1 e8 16             	shr    $0x16,%eax
  802010:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802017:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80201c:	f6 c1 01             	test   $0x1,%cl
  80201f:	74 1d                	je     80203e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802021:	c1 ea 0c             	shr    $0xc,%edx
  802024:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80202b:	f6 c2 01             	test   $0x1,%dl
  80202e:	74 0e                	je     80203e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802030:	c1 ea 0c             	shr    $0xc,%edx
  802033:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80203a:	ef 
  80203b:	0f b7 c0             	movzwl %ax,%eax
}
  80203e:	5d                   	pop    %ebp
  80203f:	c3                   	ret    

00802040 <__udivdi3>:
  802040:	55                   	push   %ebp
  802041:	57                   	push   %edi
  802042:	56                   	push   %esi
  802043:	53                   	push   %ebx
  802044:	83 ec 1c             	sub    $0x1c,%esp
  802047:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80204b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80204f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802053:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802057:	85 f6                	test   %esi,%esi
  802059:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80205d:	89 ca                	mov    %ecx,%edx
  80205f:	89 f8                	mov    %edi,%eax
  802061:	75 3d                	jne    8020a0 <__udivdi3+0x60>
  802063:	39 cf                	cmp    %ecx,%edi
  802065:	0f 87 c5 00 00 00    	ja     802130 <__udivdi3+0xf0>
  80206b:	85 ff                	test   %edi,%edi
  80206d:	89 fd                	mov    %edi,%ebp
  80206f:	75 0b                	jne    80207c <__udivdi3+0x3c>
  802071:	b8 01 00 00 00       	mov    $0x1,%eax
  802076:	31 d2                	xor    %edx,%edx
  802078:	f7 f7                	div    %edi
  80207a:	89 c5                	mov    %eax,%ebp
  80207c:	89 c8                	mov    %ecx,%eax
  80207e:	31 d2                	xor    %edx,%edx
  802080:	f7 f5                	div    %ebp
  802082:	89 c1                	mov    %eax,%ecx
  802084:	89 d8                	mov    %ebx,%eax
  802086:	89 cf                	mov    %ecx,%edi
  802088:	f7 f5                	div    %ebp
  80208a:	89 c3                	mov    %eax,%ebx
  80208c:	89 d8                	mov    %ebx,%eax
  80208e:	89 fa                	mov    %edi,%edx
  802090:	83 c4 1c             	add    $0x1c,%esp
  802093:	5b                   	pop    %ebx
  802094:	5e                   	pop    %esi
  802095:	5f                   	pop    %edi
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    
  802098:	90                   	nop
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	39 ce                	cmp    %ecx,%esi
  8020a2:	77 74                	ja     802118 <__udivdi3+0xd8>
  8020a4:	0f bd fe             	bsr    %esi,%edi
  8020a7:	83 f7 1f             	xor    $0x1f,%edi
  8020aa:	0f 84 98 00 00 00    	je     802148 <__udivdi3+0x108>
  8020b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	89 c5                	mov    %eax,%ebp
  8020b9:	29 fb                	sub    %edi,%ebx
  8020bb:	d3 e6                	shl    %cl,%esi
  8020bd:	89 d9                	mov    %ebx,%ecx
  8020bf:	d3 ed                	shr    %cl,%ebp
  8020c1:	89 f9                	mov    %edi,%ecx
  8020c3:	d3 e0                	shl    %cl,%eax
  8020c5:	09 ee                	or     %ebp,%esi
  8020c7:	89 d9                	mov    %ebx,%ecx
  8020c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020cd:	89 d5                	mov    %edx,%ebp
  8020cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020d3:	d3 ed                	shr    %cl,%ebp
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	d3 e2                	shl    %cl,%edx
  8020d9:	89 d9                	mov    %ebx,%ecx
  8020db:	d3 e8                	shr    %cl,%eax
  8020dd:	09 c2                	or     %eax,%edx
  8020df:	89 d0                	mov    %edx,%eax
  8020e1:	89 ea                	mov    %ebp,%edx
  8020e3:	f7 f6                	div    %esi
  8020e5:	89 d5                	mov    %edx,%ebp
  8020e7:	89 c3                	mov    %eax,%ebx
  8020e9:	f7 64 24 0c          	mull   0xc(%esp)
  8020ed:	39 d5                	cmp    %edx,%ebp
  8020ef:	72 10                	jb     802101 <__udivdi3+0xc1>
  8020f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	d3 e6                	shl    %cl,%esi
  8020f9:	39 c6                	cmp    %eax,%esi
  8020fb:	73 07                	jae    802104 <__udivdi3+0xc4>
  8020fd:	39 d5                	cmp    %edx,%ebp
  8020ff:	75 03                	jne    802104 <__udivdi3+0xc4>
  802101:	83 eb 01             	sub    $0x1,%ebx
  802104:	31 ff                	xor    %edi,%edi
  802106:	89 d8                	mov    %ebx,%eax
  802108:	89 fa                	mov    %edi,%edx
  80210a:	83 c4 1c             	add    $0x1c,%esp
  80210d:	5b                   	pop    %ebx
  80210e:	5e                   	pop    %esi
  80210f:	5f                   	pop    %edi
  802110:	5d                   	pop    %ebp
  802111:	c3                   	ret    
  802112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802118:	31 ff                	xor    %edi,%edi
  80211a:	31 db                	xor    %ebx,%ebx
  80211c:	89 d8                	mov    %ebx,%eax
  80211e:	89 fa                	mov    %edi,%edx
  802120:	83 c4 1c             	add    $0x1c,%esp
  802123:	5b                   	pop    %ebx
  802124:	5e                   	pop    %esi
  802125:	5f                   	pop    %edi
  802126:	5d                   	pop    %ebp
  802127:	c3                   	ret    
  802128:	90                   	nop
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	89 d8                	mov    %ebx,%eax
  802132:	f7 f7                	div    %edi
  802134:	31 ff                	xor    %edi,%edi
  802136:	89 c3                	mov    %eax,%ebx
  802138:	89 d8                	mov    %ebx,%eax
  80213a:	89 fa                	mov    %edi,%edx
  80213c:	83 c4 1c             	add    $0x1c,%esp
  80213f:	5b                   	pop    %ebx
  802140:	5e                   	pop    %esi
  802141:	5f                   	pop    %edi
  802142:	5d                   	pop    %ebp
  802143:	c3                   	ret    
  802144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802148:	39 ce                	cmp    %ecx,%esi
  80214a:	72 0c                	jb     802158 <__udivdi3+0x118>
  80214c:	31 db                	xor    %ebx,%ebx
  80214e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802152:	0f 87 34 ff ff ff    	ja     80208c <__udivdi3+0x4c>
  802158:	bb 01 00 00 00       	mov    $0x1,%ebx
  80215d:	e9 2a ff ff ff       	jmp    80208c <__udivdi3+0x4c>
  802162:	66 90                	xchg   %ax,%ax
  802164:	66 90                	xchg   %ax,%ax
  802166:	66 90                	xchg   %ax,%ax
  802168:	66 90                	xchg   %ax,%ax
  80216a:	66 90                	xchg   %ax,%ax
  80216c:	66 90                	xchg   %ax,%ax
  80216e:	66 90                	xchg   %ax,%ax

00802170 <__umoddi3>:
  802170:	55                   	push   %ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	53                   	push   %ebx
  802174:	83 ec 1c             	sub    $0x1c,%esp
  802177:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80217b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80217f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802183:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802187:	85 d2                	test   %edx,%edx
  802189:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80218d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802191:	89 f3                	mov    %esi,%ebx
  802193:	89 3c 24             	mov    %edi,(%esp)
  802196:	89 74 24 04          	mov    %esi,0x4(%esp)
  80219a:	75 1c                	jne    8021b8 <__umoddi3+0x48>
  80219c:	39 f7                	cmp    %esi,%edi
  80219e:	76 50                	jbe    8021f0 <__umoddi3+0x80>
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	f7 f7                	div    %edi
  8021a6:	89 d0                	mov    %edx,%eax
  8021a8:	31 d2                	xor    %edx,%edx
  8021aa:	83 c4 1c             	add    $0x1c,%esp
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5f                   	pop    %edi
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    
  8021b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b8:	39 f2                	cmp    %esi,%edx
  8021ba:	89 d0                	mov    %edx,%eax
  8021bc:	77 52                	ja     802210 <__umoddi3+0xa0>
  8021be:	0f bd ea             	bsr    %edx,%ebp
  8021c1:	83 f5 1f             	xor    $0x1f,%ebp
  8021c4:	75 5a                	jne    802220 <__umoddi3+0xb0>
  8021c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ca:	0f 82 e0 00 00 00    	jb     8022b0 <__umoddi3+0x140>
  8021d0:	39 0c 24             	cmp    %ecx,(%esp)
  8021d3:	0f 86 d7 00 00 00    	jbe    8022b0 <__umoddi3+0x140>
  8021d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021e1:	83 c4 1c             	add    $0x1c,%esp
  8021e4:	5b                   	pop    %ebx
  8021e5:	5e                   	pop    %esi
  8021e6:	5f                   	pop    %edi
  8021e7:	5d                   	pop    %ebp
  8021e8:	c3                   	ret    
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	85 ff                	test   %edi,%edi
  8021f2:	89 fd                	mov    %edi,%ebp
  8021f4:	75 0b                	jne    802201 <__umoddi3+0x91>
  8021f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021fb:	31 d2                	xor    %edx,%edx
  8021fd:	f7 f7                	div    %edi
  8021ff:	89 c5                	mov    %eax,%ebp
  802201:	89 f0                	mov    %esi,%eax
  802203:	31 d2                	xor    %edx,%edx
  802205:	f7 f5                	div    %ebp
  802207:	89 c8                	mov    %ecx,%eax
  802209:	f7 f5                	div    %ebp
  80220b:	89 d0                	mov    %edx,%eax
  80220d:	eb 99                	jmp    8021a8 <__umoddi3+0x38>
  80220f:	90                   	nop
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	83 c4 1c             	add    $0x1c,%esp
  802217:	5b                   	pop    %ebx
  802218:	5e                   	pop    %esi
  802219:	5f                   	pop    %edi
  80221a:	5d                   	pop    %ebp
  80221b:	c3                   	ret    
  80221c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802220:	8b 34 24             	mov    (%esp),%esi
  802223:	bf 20 00 00 00       	mov    $0x20,%edi
  802228:	89 e9                	mov    %ebp,%ecx
  80222a:	29 ef                	sub    %ebp,%edi
  80222c:	d3 e0                	shl    %cl,%eax
  80222e:	89 f9                	mov    %edi,%ecx
  802230:	89 f2                	mov    %esi,%edx
  802232:	d3 ea                	shr    %cl,%edx
  802234:	89 e9                	mov    %ebp,%ecx
  802236:	09 c2                	or     %eax,%edx
  802238:	89 d8                	mov    %ebx,%eax
  80223a:	89 14 24             	mov    %edx,(%esp)
  80223d:	89 f2                	mov    %esi,%edx
  80223f:	d3 e2                	shl    %cl,%edx
  802241:	89 f9                	mov    %edi,%ecx
  802243:	89 54 24 04          	mov    %edx,0x4(%esp)
  802247:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80224b:	d3 e8                	shr    %cl,%eax
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	89 c6                	mov    %eax,%esi
  802251:	d3 e3                	shl    %cl,%ebx
  802253:	89 f9                	mov    %edi,%ecx
  802255:	89 d0                	mov    %edx,%eax
  802257:	d3 e8                	shr    %cl,%eax
  802259:	89 e9                	mov    %ebp,%ecx
  80225b:	09 d8                	or     %ebx,%eax
  80225d:	89 d3                	mov    %edx,%ebx
  80225f:	89 f2                	mov    %esi,%edx
  802261:	f7 34 24             	divl   (%esp)
  802264:	89 d6                	mov    %edx,%esi
  802266:	d3 e3                	shl    %cl,%ebx
  802268:	f7 64 24 04          	mull   0x4(%esp)
  80226c:	39 d6                	cmp    %edx,%esi
  80226e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802272:	89 d1                	mov    %edx,%ecx
  802274:	89 c3                	mov    %eax,%ebx
  802276:	72 08                	jb     802280 <__umoddi3+0x110>
  802278:	75 11                	jne    80228b <__umoddi3+0x11b>
  80227a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80227e:	73 0b                	jae    80228b <__umoddi3+0x11b>
  802280:	2b 44 24 04          	sub    0x4(%esp),%eax
  802284:	1b 14 24             	sbb    (%esp),%edx
  802287:	89 d1                	mov    %edx,%ecx
  802289:	89 c3                	mov    %eax,%ebx
  80228b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80228f:	29 da                	sub    %ebx,%edx
  802291:	19 ce                	sbb    %ecx,%esi
  802293:	89 f9                	mov    %edi,%ecx
  802295:	89 f0                	mov    %esi,%eax
  802297:	d3 e0                	shl    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	d3 ea                	shr    %cl,%edx
  80229d:	89 e9                	mov    %ebp,%ecx
  80229f:	d3 ee                	shr    %cl,%esi
  8022a1:	09 d0                	or     %edx,%eax
  8022a3:	89 f2                	mov    %esi,%edx
  8022a5:	83 c4 1c             	add    $0x1c,%esp
  8022a8:	5b                   	pop    %ebx
  8022a9:	5e                   	pop    %esi
  8022aa:	5f                   	pop    %edi
  8022ab:	5d                   	pop    %ebp
  8022ac:	c3                   	ret    
  8022ad:	8d 76 00             	lea    0x0(%esi),%esi
  8022b0:	29 f9                	sub    %edi,%ecx
  8022b2:	19 d6                	sbb    %edx,%esi
  8022b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022bc:	e9 18 ff ff ff       	jmp    8021d9 <__umoddi3+0x69>
