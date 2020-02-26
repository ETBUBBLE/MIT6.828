
obj/user/hello.debug：     文件格式 elf32-i386


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
  80002c:	e8 2d 00 00 00       	call   80005e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
// hello, world
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 14             	sub    $0x14,%esp
	cprintf("hello, world\n");
  800039:	68 e0 22 80 00       	push   $0x8022e0
  80003e:	e8 0e 01 00 00       	call   800151 <cprintf>
	cprintf("i am environment %08x\n", thisenv->env_id);
  800043:	a1 08 40 80 00       	mov    0x804008,%eax
  800048:	8b 40 48             	mov    0x48(%eax),%eax
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	50                   	push   %eax
  80004f:	68 ee 22 80 00       	push   $0x8022ee
  800054:	e8 f8 00 00 00       	call   800151 <cprintf>
}
  800059:	83 c4 10             	add    $0x10,%esp
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	56                   	push   %esi
  800062:	53                   	push   %ebx
  800063:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800066:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800069:	e8 ac 0a 00 00       	call   800b1a <sys_getenvid>
  80006e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800073:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800076:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007b:	a3 08 40 80 00       	mov    %eax,0x804008

    // save the name of the program so that panic() can use it
    if (argc > 0)
  800080:	85 db                	test   %ebx,%ebx
  800082:	7e 07                	jle    80008b <libmain+0x2d>
        binaryname = argv[0];
  800084:	8b 06                	mov    (%esi),%eax
  800086:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  80008b:	83 ec 08             	sub    $0x8,%esp
  80008e:	56                   	push   %esi
  80008f:	53                   	push   %ebx
  800090:	e8 9e ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  800095:	e8 0a 00 00 00       	call   8000a4 <exit>
}
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000a0:	5b                   	pop    %ebx
  8000a1:	5e                   	pop    %esi
  8000a2:	5d                   	pop    %ebp
  8000a3:	c3                   	ret    

008000a4 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000aa:	e8 a4 0e 00 00       	call   800f53 <close_all>
	sys_env_destroy(0);
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 20 0a 00 00       	call   800ad9 <sys_env_destroy>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	53                   	push   %ebx
  8000c2:	83 ec 04             	sub    $0x4,%esp
  8000c5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000c8:	8b 13                	mov    (%ebx),%edx
  8000ca:	8d 42 01             	lea    0x1(%edx),%eax
  8000cd:	89 03                	mov    %eax,(%ebx)
  8000cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000d6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000db:	75 1a                	jne    8000f7 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000dd:	83 ec 08             	sub    $0x8,%esp
  8000e0:	68 ff 00 00 00       	push   $0xff
  8000e5:	8d 43 08             	lea    0x8(%ebx),%eax
  8000e8:	50                   	push   %eax
  8000e9:	e8 ae 09 00 00       	call   800a9c <sys_cputs>
		b->idx = 0;
  8000ee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8000f4:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8000f7:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8000fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000fe:	c9                   	leave  
  8000ff:	c3                   	ret    

00800100 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800100:	55                   	push   %ebp
  800101:	89 e5                	mov    %esp,%ebp
  800103:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800109:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800110:	00 00 00 
	b.cnt = 0;
  800113:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80011a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011d:	ff 75 0c             	pushl  0xc(%ebp)
  800120:	ff 75 08             	pushl  0x8(%ebp)
  800123:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800129:	50                   	push   %eax
  80012a:	68 be 00 80 00       	push   $0x8000be
  80012f:	e8 1a 01 00 00       	call   80024e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800134:	83 c4 08             	add    $0x8,%esp
  800137:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80013d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800143:	50                   	push   %eax
  800144:	e8 53 09 00 00       	call   800a9c <sys_cputs>

	return b.cnt;
}
  800149:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80014f:	c9                   	leave  
  800150:	c3                   	ret    

00800151 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800151:	55                   	push   %ebp
  800152:	89 e5                	mov    %esp,%ebp
  800154:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800157:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80015a:	50                   	push   %eax
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	e8 9d ff ff ff       	call   800100 <vcprintf>
	va_end(ap);

	return cnt;
}
  800163:	c9                   	leave  
  800164:	c3                   	ret    

00800165 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800165:	55                   	push   %ebp
  800166:	89 e5                	mov    %esp,%ebp
  800168:	57                   	push   %edi
  800169:	56                   	push   %esi
  80016a:	53                   	push   %ebx
  80016b:	83 ec 1c             	sub    $0x1c,%esp
  80016e:	89 c7                	mov    %eax,%edi
  800170:	89 d6                	mov    %edx,%esi
  800172:	8b 45 08             	mov    0x8(%ebp),%eax
  800175:	8b 55 0c             	mov    0xc(%ebp),%edx
  800178:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80017b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80017e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800181:	bb 00 00 00 00       	mov    $0x0,%ebx
  800186:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800189:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80018c:	39 d3                	cmp    %edx,%ebx
  80018e:	72 05                	jb     800195 <printnum+0x30>
  800190:	39 45 10             	cmp    %eax,0x10(%ebp)
  800193:	77 45                	ja     8001da <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	ff 75 18             	pushl  0x18(%ebp)
  80019b:	8b 45 14             	mov    0x14(%ebp),%eax
  80019e:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001a1:	53                   	push   %ebx
  8001a2:	ff 75 10             	pushl  0x10(%ebp)
  8001a5:	83 ec 08             	sub    $0x8,%esp
  8001a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8001b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001b4:	e8 97 1e 00 00       	call   802050 <__udivdi3>
  8001b9:	83 c4 18             	add    $0x18,%esp
  8001bc:	52                   	push   %edx
  8001bd:	50                   	push   %eax
  8001be:	89 f2                	mov    %esi,%edx
  8001c0:	89 f8                	mov    %edi,%eax
  8001c2:	e8 9e ff ff ff       	call   800165 <printnum>
  8001c7:	83 c4 20             	add    $0x20,%esp
  8001ca:	eb 18                	jmp    8001e4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001cc:	83 ec 08             	sub    $0x8,%esp
  8001cf:	56                   	push   %esi
  8001d0:	ff 75 18             	pushl  0x18(%ebp)
  8001d3:	ff d7                	call   *%edi
  8001d5:	83 c4 10             	add    $0x10,%esp
  8001d8:	eb 03                	jmp    8001dd <printnum+0x78>
  8001da:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001dd:	83 eb 01             	sub    $0x1,%ebx
  8001e0:	85 db                	test   %ebx,%ebx
  8001e2:	7f e8                	jg     8001cc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8001e4:	83 ec 08             	sub    $0x8,%esp
  8001e7:	56                   	push   %esi
  8001e8:	83 ec 04             	sub    $0x4,%esp
  8001eb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001ee:	ff 75 e0             	pushl  -0x20(%ebp)
  8001f1:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f4:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f7:	e8 84 1f 00 00       	call   802180 <__umoddi3>
  8001fc:	83 c4 14             	add    $0x14,%esp
  8001ff:	0f be 80 0f 23 80 00 	movsbl 0x80230f(%eax),%eax
  800206:	50                   	push   %eax
  800207:	ff d7                	call   *%edi
}
  800209:	83 c4 10             	add    $0x10,%esp
  80020c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80020f:	5b                   	pop    %ebx
  800210:	5e                   	pop    %esi
  800211:	5f                   	pop    %edi
  800212:	5d                   	pop    %ebp
  800213:	c3                   	ret    

00800214 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80021a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80021e:	8b 10                	mov    (%eax),%edx
  800220:	3b 50 04             	cmp    0x4(%eax),%edx
  800223:	73 0a                	jae    80022f <sprintputch+0x1b>
		*b->buf++ = ch;
  800225:	8d 4a 01             	lea    0x1(%edx),%ecx
  800228:	89 08                	mov    %ecx,(%eax)
  80022a:	8b 45 08             	mov    0x8(%ebp),%eax
  80022d:	88 02                	mov    %al,(%edx)
}
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800237:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80023a:	50                   	push   %eax
  80023b:	ff 75 10             	pushl  0x10(%ebp)
  80023e:	ff 75 0c             	pushl  0xc(%ebp)
  800241:	ff 75 08             	pushl  0x8(%ebp)
  800244:	e8 05 00 00 00       	call   80024e <vprintfmt>
	va_end(ap);
}
  800249:	83 c4 10             	add    $0x10,%esp
  80024c:	c9                   	leave  
  80024d:	c3                   	ret    

0080024e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80024e:	55                   	push   %ebp
  80024f:	89 e5                	mov    %esp,%ebp
  800251:	57                   	push   %edi
  800252:	56                   	push   %esi
  800253:	53                   	push   %ebx
  800254:	83 ec 2c             	sub    $0x2c,%esp
  800257:	8b 75 08             	mov    0x8(%ebp),%esi
  80025a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80025d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800260:	eb 12                	jmp    800274 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800262:	85 c0                	test   %eax,%eax
  800264:	0f 84 42 04 00 00    	je     8006ac <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80026a:	83 ec 08             	sub    $0x8,%esp
  80026d:	53                   	push   %ebx
  80026e:	50                   	push   %eax
  80026f:	ff d6                	call   *%esi
  800271:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800274:	83 c7 01             	add    $0x1,%edi
  800277:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80027b:	83 f8 25             	cmp    $0x25,%eax
  80027e:	75 e2                	jne    800262 <vprintfmt+0x14>
  800280:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800284:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80028b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800292:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800299:	b9 00 00 00 00       	mov    $0x0,%ecx
  80029e:	eb 07                	jmp    8002a7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002a3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002a7:	8d 47 01             	lea    0x1(%edi),%eax
  8002aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ad:	0f b6 07             	movzbl (%edi),%eax
  8002b0:	0f b6 d0             	movzbl %al,%edx
  8002b3:	83 e8 23             	sub    $0x23,%eax
  8002b6:	3c 55                	cmp    $0x55,%al
  8002b8:	0f 87 d3 03 00 00    	ja     800691 <vprintfmt+0x443>
  8002be:	0f b6 c0             	movzbl %al,%eax
  8002c1:	ff 24 85 60 24 80 00 	jmp    *0x802460(,%eax,4)
  8002c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002cb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002cf:	eb d6                	jmp    8002a7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8002d9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002dc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8002df:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8002e3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8002e6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8002e9:	83 f9 09             	cmp    $0x9,%ecx
  8002ec:	77 3f                	ja     80032d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8002ee:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8002f1:	eb e9                	jmp    8002dc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8002f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8002f6:	8b 00                	mov    (%eax),%eax
  8002f8:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8002fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8002fe:	8d 40 04             	lea    0x4(%eax),%eax
  800301:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800304:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800307:	eb 2a                	jmp    800333 <vprintfmt+0xe5>
  800309:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80030c:	85 c0                	test   %eax,%eax
  80030e:	ba 00 00 00 00       	mov    $0x0,%edx
  800313:	0f 49 d0             	cmovns %eax,%edx
  800316:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800319:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80031c:	eb 89                	jmp    8002a7 <vprintfmt+0x59>
  80031e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800321:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800328:	e9 7a ff ff ff       	jmp    8002a7 <vprintfmt+0x59>
  80032d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800330:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800333:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800337:	0f 89 6a ff ff ff    	jns    8002a7 <vprintfmt+0x59>
				width = precision, precision = -1;
  80033d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800340:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800343:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80034a:	e9 58 ff ff ff       	jmp    8002a7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80034f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800355:	e9 4d ff ff ff       	jmp    8002a7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80035a:	8b 45 14             	mov    0x14(%ebp),%eax
  80035d:	8d 78 04             	lea    0x4(%eax),%edi
  800360:	83 ec 08             	sub    $0x8,%esp
  800363:	53                   	push   %ebx
  800364:	ff 30                	pushl  (%eax)
  800366:	ff d6                	call   *%esi
			break;
  800368:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80036b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800371:	e9 fe fe ff ff       	jmp    800274 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800376:	8b 45 14             	mov    0x14(%ebp),%eax
  800379:	8d 78 04             	lea    0x4(%eax),%edi
  80037c:	8b 00                	mov    (%eax),%eax
  80037e:	99                   	cltd   
  80037f:	31 d0                	xor    %edx,%eax
  800381:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800383:	83 f8 0f             	cmp    $0xf,%eax
  800386:	7f 0b                	jg     800393 <vprintfmt+0x145>
  800388:	8b 14 85 c0 25 80 00 	mov    0x8025c0(,%eax,4),%edx
  80038f:	85 d2                	test   %edx,%edx
  800391:	75 1b                	jne    8003ae <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800393:	50                   	push   %eax
  800394:	68 27 23 80 00       	push   $0x802327
  800399:	53                   	push   %ebx
  80039a:	56                   	push   %esi
  80039b:	e8 91 fe ff ff       	call   800231 <printfmt>
  8003a0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003a3:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003a9:	e9 c6 fe ff ff       	jmp    800274 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003ae:	52                   	push   %edx
  8003af:	68 f5 26 80 00       	push   $0x8026f5
  8003b4:	53                   	push   %ebx
  8003b5:	56                   	push   %esi
  8003b6:	e8 76 fe ff ff       	call   800231 <printfmt>
  8003bb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003be:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003c4:	e9 ab fe ff ff       	jmp    800274 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003c9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003cc:	83 c0 04             	add    $0x4,%eax
  8003cf:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003d7:	85 ff                	test   %edi,%edi
  8003d9:	b8 20 23 80 00       	mov    $0x802320,%eax
  8003de:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8003e1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003e5:	0f 8e 94 00 00 00    	jle    80047f <vprintfmt+0x231>
  8003eb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8003ef:	0f 84 98 00 00 00    	je     80048d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  8003f5:	83 ec 08             	sub    $0x8,%esp
  8003f8:	ff 75 d0             	pushl  -0x30(%ebp)
  8003fb:	57                   	push   %edi
  8003fc:	e8 33 03 00 00       	call   800734 <strnlen>
  800401:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800404:	29 c1                	sub    %eax,%ecx
  800406:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800409:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80040c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800410:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800413:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800416:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800418:	eb 0f                	jmp    800429 <vprintfmt+0x1db>
					putch(padc, putdat);
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	53                   	push   %ebx
  80041e:	ff 75 e0             	pushl  -0x20(%ebp)
  800421:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800423:	83 ef 01             	sub    $0x1,%edi
  800426:	83 c4 10             	add    $0x10,%esp
  800429:	85 ff                	test   %edi,%edi
  80042b:	7f ed                	jg     80041a <vprintfmt+0x1cc>
  80042d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800430:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800433:	85 c9                	test   %ecx,%ecx
  800435:	b8 00 00 00 00       	mov    $0x0,%eax
  80043a:	0f 49 c1             	cmovns %ecx,%eax
  80043d:	29 c1                	sub    %eax,%ecx
  80043f:	89 75 08             	mov    %esi,0x8(%ebp)
  800442:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800445:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800448:	89 cb                	mov    %ecx,%ebx
  80044a:	eb 4d                	jmp    800499 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80044c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800450:	74 1b                	je     80046d <vprintfmt+0x21f>
  800452:	0f be c0             	movsbl %al,%eax
  800455:	83 e8 20             	sub    $0x20,%eax
  800458:	83 f8 5e             	cmp    $0x5e,%eax
  80045b:	76 10                	jbe    80046d <vprintfmt+0x21f>
					putch('?', putdat);
  80045d:	83 ec 08             	sub    $0x8,%esp
  800460:	ff 75 0c             	pushl  0xc(%ebp)
  800463:	6a 3f                	push   $0x3f
  800465:	ff 55 08             	call   *0x8(%ebp)
  800468:	83 c4 10             	add    $0x10,%esp
  80046b:	eb 0d                	jmp    80047a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	ff 75 0c             	pushl  0xc(%ebp)
  800473:	52                   	push   %edx
  800474:	ff 55 08             	call   *0x8(%ebp)
  800477:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80047a:	83 eb 01             	sub    $0x1,%ebx
  80047d:	eb 1a                	jmp    800499 <vprintfmt+0x24b>
  80047f:	89 75 08             	mov    %esi,0x8(%ebp)
  800482:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800485:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800488:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80048b:	eb 0c                	jmp    800499 <vprintfmt+0x24b>
  80048d:	89 75 08             	mov    %esi,0x8(%ebp)
  800490:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800493:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800496:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800499:	83 c7 01             	add    $0x1,%edi
  80049c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004a0:	0f be d0             	movsbl %al,%edx
  8004a3:	85 d2                	test   %edx,%edx
  8004a5:	74 23                	je     8004ca <vprintfmt+0x27c>
  8004a7:	85 f6                	test   %esi,%esi
  8004a9:	78 a1                	js     80044c <vprintfmt+0x1fe>
  8004ab:	83 ee 01             	sub    $0x1,%esi
  8004ae:	79 9c                	jns    80044c <vprintfmt+0x1fe>
  8004b0:	89 df                	mov    %ebx,%edi
  8004b2:	8b 75 08             	mov    0x8(%ebp),%esi
  8004b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004b8:	eb 18                	jmp    8004d2 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	53                   	push   %ebx
  8004be:	6a 20                	push   $0x20
  8004c0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004c2:	83 ef 01             	sub    $0x1,%edi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	eb 08                	jmp    8004d2 <vprintfmt+0x284>
  8004ca:	89 df                	mov    %ebx,%edi
  8004cc:	8b 75 08             	mov    0x8(%ebp),%esi
  8004cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004d2:	85 ff                	test   %edi,%edi
  8004d4:	7f e4                	jg     8004ba <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004d6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004d9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8004df:	e9 90 fd ff ff       	jmp    800274 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004e4:	83 f9 01             	cmp    $0x1,%ecx
  8004e7:	7e 19                	jle    800502 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  8004e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8004ec:	8b 50 04             	mov    0x4(%eax),%edx
  8004ef:	8b 00                	mov    (%eax),%eax
  8004f1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004f4:	89 55 dc             	mov    %edx,-0x24(%ebp)
  8004f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8004fa:	8d 40 08             	lea    0x8(%eax),%eax
  8004fd:	89 45 14             	mov    %eax,0x14(%ebp)
  800500:	eb 38                	jmp    80053a <vprintfmt+0x2ec>
	else if (lflag)
  800502:	85 c9                	test   %ecx,%ecx
  800504:	74 1b                	je     800521 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800506:	8b 45 14             	mov    0x14(%ebp),%eax
  800509:	8b 00                	mov    (%eax),%eax
  80050b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80050e:	89 c1                	mov    %eax,%ecx
  800510:	c1 f9 1f             	sar    $0x1f,%ecx
  800513:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800516:	8b 45 14             	mov    0x14(%ebp),%eax
  800519:	8d 40 04             	lea    0x4(%eax),%eax
  80051c:	89 45 14             	mov    %eax,0x14(%ebp)
  80051f:	eb 19                	jmp    80053a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8b 00                	mov    (%eax),%eax
  800526:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800529:	89 c1                	mov    %eax,%ecx
  80052b:	c1 f9 1f             	sar    $0x1f,%ecx
  80052e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800531:	8b 45 14             	mov    0x14(%ebp),%eax
  800534:	8d 40 04             	lea    0x4(%eax),%eax
  800537:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80053a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80053d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800540:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800545:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800549:	0f 89 0e 01 00 00    	jns    80065d <vprintfmt+0x40f>
				putch('-', putdat);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	53                   	push   %ebx
  800553:	6a 2d                	push   $0x2d
  800555:	ff d6                	call   *%esi
				num = -(long long) num;
  800557:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80055d:	f7 da                	neg    %edx
  80055f:	83 d1 00             	adc    $0x0,%ecx
  800562:	f7 d9                	neg    %ecx
  800564:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800567:	b8 0a 00 00 00       	mov    $0xa,%eax
  80056c:	e9 ec 00 00 00       	jmp    80065d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800571:	83 f9 01             	cmp    $0x1,%ecx
  800574:	7e 18                	jle    80058e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8b 10                	mov    (%eax),%edx
  80057b:	8b 48 04             	mov    0x4(%eax),%ecx
  80057e:	8d 40 08             	lea    0x8(%eax),%eax
  800581:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800584:	b8 0a 00 00 00       	mov    $0xa,%eax
  800589:	e9 cf 00 00 00       	jmp    80065d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80058e:	85 c9                	test   %ecx,%ecx
  800590:	74 1a                	je     8005ac <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8b 10                	mov    (%eax),%edx
  800597:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059c:	8d 40 04             	lea    0x4(%eax),%eax
  80059f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005a2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005a7:	e9 b1 00 00 00       	jmp    80065d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8b 10                	mov    (%eax),%edx
  8005b1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005b6:	8d 40 04             	lea    0x4(%eax),%eax
  8005b9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c1:	e9 97 00 00 00       	jmp    80065d <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005c6:	83 ec 08             	sub    $0x8,%esp
  8005c9:	53                   	push   %ebx
  8005ca:	6a 58                	push   $0x58
  8005cc:	ff d6                	call   *%esi
			putch('X', putdat);
  8005ce:	83 c4 08             	add    $0x8,%esp
  8005d1:	53                   	push   %ebx
  8005d2:	6a 58                	push   $0x58
  8005d4:	ff d6                	call   *%esi
			putch('X', putdat);
  8005d6:	83 c4 08             	add    $0x8,%esp
  8005d9:	53                   	push   %ebx
  8005da:	6a 58                	push   $0x58
  8005dc:	ff d6                	call   *%esi
			break;
  8005de:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  8005e4:	e9 8b fc ff ff       	jmp    800274 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  8005e9:	83 ec 08             	sub    $0x8,%esp
  8005ec:	53                   	push   %ebx
  8005ed:	6a 30                	push   $0x30
  8005ef:	ff d6                	call   *%esi
			putch('x', putdat);
  8005f1:	83 c4 08             	add    $0x8,%esp
  8005f4:	53                   	push   %ebx
  8005f5:	6a 78                	push   $0x78
  8005f7:	ff d6                	call   *%esi
			num = (unsigned long long)
  8005f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fc:	8b 10                	mov    (%eax),%edx
  8005fe:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800603:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800606:	8d 40 04             	lea    0x4(%eax),%eax
  800609:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80060c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800611:	eb 4a                	jmp    80065d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800613:	83 f9 01             	cmp    $0x1,%ecx
  800616:	7e 15                	jle    80062d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800618:	8b 45 14             	mov    0x14(%ebp),%eax
  80061b:	8b 10                	mov    (%eax),%edx
  80061d:	8b 48 04             	mov    0x4(%eax),%ecx
  800620:	8d 40 08             	lea    0x8(%eax),%eax
  800623:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800626:	b8 10 00 00 00       	mov    $0x10,%eax
  80062b:	eb 30                	jmp    80065d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80062d:	85 c9                	test   %ecx,%ecx
  80062f:	74 17                	je     800648 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800631:	8b 45 14             	mov    0x14(%ebp),%eax
  800634:	8b 10                	mov    (%eax),%edx
  800636:	b9 00 00 00 00       	mov    $0x0,%ecx
  80063b:	8d 40 04             	lea    0x4(%eax),%eax
  80063e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800641:	b8 10 00 00 00       	mov    $0x10,%eax
  800646:	eb 15                	jmp    80065d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800648:	8b 45 14             	mov    0x14(%ebp),%eax
  80064b:	8b 10                	mov    (%eax),%edx
  80064d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800652:	8d 40 04             	lea    0x4(%eax),%eax
  800655:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800658:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80065d:	83 ec 0c             	sub    $0xc,%esp
  800660:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800664:	57                   	push   %edi
  800665:	ff 75 e0             	pushl  -0x20(%ebp)
  800668:	50                   	push   %eax
  800669:	51                   	push   %ecx
  80066a:	52                   	push   %edx
  80066b:	89 da                	mov    %ebx,%edx
  80066d:	89 f0                	mov    %esi,%eax
  80066f:	e8 f1 fa ff ff       	call   800165 <printnum>
			break;
  800674:	83 c4 20             	add    $0x20,%esp
  800677:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067a:	e9 f5 fb ff ff       	jmp    800274 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  80067f:	83 ec 08             	sub    $0x8,%esp
  800682:	53                   	push   %ebx
  800683:	52                   	push   %edx
  800684:	ff d6                	call   *%esi
			break;
  800686:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800689:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80068c:	e9 e3 fb ff ff       	jmp    800274 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800691:	83 ec 08             	sub    $0x8,%esp
  800694:	53                   	push   %ebx
  800695:	6a 25                	push   $0x25
  800697:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800699:	83 c4 10             	add    $0x10,%esp
  80069c:	eb 03                	jmp    8006a1 <vprintfmt+0x453>
  80069e:	83 ef 01             	sub    $0x1,%edi
  8006a1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006a5:	75 f7                	jne    80069e <vprintfmt+0x450>
  8006a7:	e9 c8 fb ff ff       	jmp    800274 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006af:	5b                   	pop    %ebx
  8006b0:	5e                   	pop    %esi
  8006b1:	5f                   	pop    %edi
  8006b2:	5d                   	pop    %ebp
  8006b3:	c3                   	ret    

008006b4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006b4:	55                   	push   %ebp
  8006b5:	89 e5                	mov    %esp,%ebp
  8006b7:	83 ec 18             	sub    $0x18,%esp
  8006ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006c0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006c3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006c7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	74 26                	je     8006fb <vsnprintf+0x47>
  8006d5:	85 d2                	test   %edx,%edx
  8006d7:	7e 22                	jle    8006fb <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006d9:	ff 75 14             	pushl  0x14(%ebp)
  8006dc:	ff 75 10             	pushl  0x10(%ebp)
  8006df:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006e2:	50                   	push   %eax
  8006e3:	68 14 02 80 00       	push   $0x800214
  8006e8:	e8 61 fb ff ff       	call   80024e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006f0:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006f6:	83 c4 10             	add    $0x10,%esp
  8006f9:	eb 05                	jmp    800700 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8006fb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800700:	c9                   	leave  
  800701:	c3                   	ret    

00800702 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800702:	55                   	push   %ebp
  800703:	89 e5                	mov    %esp,%ebp
  800705:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800708:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80070b:	50                   	push   %eax
  80070c:	ff 75 10             	pushl  0x10(%ebp)
  80070f:	ff 75 0c             	pushl  0xc(%ebp)
  800712:	ff 75 08             	pushl  0x8(%ebp)
  800715:	e8 9a ff ff ff       	call   8006b4 <vsnprintf>
	va_end(ap);

	return rc;
}
  80071a:	c9                   	leave  
  80071b:	c3                   	ret    

0080071c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80071c:	55                   	push   %ebp
  80071d:	89 e5                	mov    %esp,%ebp
  80071f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800722:	b8 00 00 00 00       	mov    $0x0,%eax
  800727:	eb 03                	jmp    80072c <strlen+0x10>
		n++;
  800729:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80072c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800730:	75 f7                	jne    800729 <strlen+0xd>
		n++;
	return n;
}
  800732:	5d                   	pop    %ebp
  800733:	c3                   	ret    

00800734 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800734:	55                   	push   %ebp
  800735:	89 e5                	mov    %esp,%ebp
  800737:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80073a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80073d:	ba 00 00 00 00       	mov    $0x0,%edx
  800742:	eb 03                	jmp    800747 <strnlen+0x13>
		n++;
  800744:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800747:	39 c2                	cmp    %eax,%edx
  800749:	74 08                	je     800753 <strnlen+0x1f>
  80074b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  80074f:	75 f3                	jne    800744 <strnlen+0x10>
  800751:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800753:	5d                   	pop    %ebp
  800754:	c3                   	ret    

00800755 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800755:	55                   	push   %ebp
  800756:	89 e5                	mov    %esp,%ebp
  800758:	53                   	push   %ebx
  800759:	8b 45 08             	mov    0x8(%ebp),%eax
  80075c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80075f:	89 c2                	mov    %eax,%edx
  800761:	83 c2 01             	add    $0x1,%edx
  800764:	83 c1 01             	add    $0x1,%ecx
  800767:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80076b:	88 5a ff             	mov    %bl,-0x1(%edx)
  80076e:	84 db                	test   %bl,%bl
  800770:	75 ef                	jne    800761 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800772:	5b                   	pop    %ebx
  800773:	5d                   	pop    %ebp
  800774:	c3                   	ret    

00800775 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	53                   	push   %ebx
  800779:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80077c:	53                   	push   %ebx
  80077d:	e8 9a ff ff ff       	call   80071c <strlen>
  800782:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800785:	ff 75 0c             	pushl  0xc(%ebp)
  800788:	01 d8                	add    %ebx,%eax
  80078a:	50                   	push   %eax
  80078b:	e8 c5 ff ff ff       	call   800755 <strcpy>
	return dst;
}
  800790:	89 d8                	mov    %ebx,%eax
  800792:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800795:	c9                   	leave  
  800796:	c3                   	ret    

00800797 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	56                   	push   %esi
  80079b:	53                   	push   %ebx
  80079c:	8b 75 08             	mov    0x8(%ebp),%esi
  80079f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007a2:	89 f3                	mov    %esi,%ebx
  8007a4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007a7:	89 f2                	mov    %esi,%edx
  8007a9:	eb 0f                	jmp    8007ba <strncpy+0x23>
		*dst++ = *src;
  8007ab:	83 c2 01             	add    $0x1,%edx
  8007ae:	0f b6 01             	movzbl (%ecx),%eax
  8007b1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007b4:	80 39 01             	cmpb   $0x1,(%ecx)
  8007b7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007ba:	39 da                	cmp    %ebx,%edx
  8007bc:	75 ed                	jne    8007ab <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007be:	89 f0                	mov    %esi,%eax
  8007c0:	5b                   	pop    %ebx
  8007c1:	5e                   	pop    %esi
  8007c2:	5d                   	pop    %ebp
  8007c3:	c3                   	ret    

008007c4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007c4:	55                   	push   %ebp
  8007c5:	89 e5                	mov    %esp,%ebp
  8007c7:	56                   	push   %esi
  8007c8:	53                   	push   %ebx
  8007c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8007cc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007cf:	8b 55 10             	mov    0x10(%ebp),%edx
  8007d2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007d4:	85 d2                	test   %edx,%edx
  8007d6:	74 21                	je     8007f9 <strlcpy+0x35>
  8007d8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007dc:	89 f2                	mov    %esi,%edx
  8007de:	eb 09                	jmp    8007e9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  8007e0:	83 c2 01             	add    $0x1,%edx
  8007e3:	83 c1 01             	add    $0x1,%ecx
  8007e6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8007e9:	39 c2                	cmp    %eax,%edx
  8007eb:	74 09                	je     8007f6 <strlcpy+0x32>
  8007ed:	0f b6 19             	movzbl (%ecx),%ebx
  8007f0:	84 db                	test   %bl,%bl
  8007f2:	75 ec                	jne    8007e0 <strlcpy+0x1c>
  8007f4:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  8007f6:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007f9:	29 f0                	sub    %esi,%eax
}
  8007fb:	5b                   	pop    %ebx
  8007fc:	5e                   	pop    %esi
  8007fd:	5d                   	pop    %ebp
  8007fe:	c3                   	ret    

008007ff <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007ff:	55                   	push   %ebp
  800800:	89 e5                	mov    %esp,%ebp
  800802:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800805:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800808:	eb 06                	jmp    800810 <strcmp+0x11>
		p++, q++;
  80080a:	83 c1 01             	add    $0x1,%ecx
  80080d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800810:	0f b6 01             	movzbl (%ecx),%eax
  800813:	84 c0                	test   %al,%al
  800815:	74 04                	je     80081b <strcmp+0x1c>
  800817:	3a 02                	cmp    (%edx),%al
  800819:	74 ef                	je     80080a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80081b:	0f b6 c0             	movzbl %al,%eax
  80081e:	0f b6 12             	movzbl (%edx),%edx
  800821:	29 d0                	sub    %edx,%eax
}
  800823:	5d                   	pop    %ebp
  800824:	c3                   	ret    

00800825 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800825:	55                   	push   %ebp
  800826:	89 e5                	mov    %esp,%ebp
  800828:	53                   	push   %ebx
  800829:	8b 45 08             	mov    0x8(%ebp),%eax
  80082c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082f:	89 c3                	mov    %eax,%ebx
  800831:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800834:	eb 06                	jmp    80083c <strncmp+0x17>
		n--, p++, q++;
  800836:	83 c0 01             	add    $0x1,%eax
  800839:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80083c:	39 d8                	cmp    %ebx,%eax
  80083e:	74 15                	je     800855 <strncmp+0x30>
  800840:	0f b6 08             	movzbl (%eax),%ecx
  800843:	84 c9                	test   %cl,%cl
  800845:	74 04                	je     80084b <strncmp+0x26>
  800847:	3a 0a                	cmp    (%edx),%cl
  800849:	74 eb                	je     800836 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084b:	0f b6 00             	movzbl (%eax),%eax
  80084e:	0f b6 12             	movzbl (%edx),%edx
  800851:	29 d0                	sub    %edx,%eax
  800853:	eb 05                	jmp    80085a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800855:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80085a:	5b                   	pop    %ebx
  80085b:	5d                   	pop    %ebp
  80085c:	c3                   	ret    

0080085d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80085d:	55                   	push   %ebp
  80085e:	89 e5                	mov    %esp,%ebp
  800860:	8b 45 08             	mov    0x8(%ebp),%eax
  800863:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800867:	eb 07                	jmp    800870 <strchr+0x13>
		if (*s == c)
  800869:	38 ca                	cmp    %cl,%dl
  80086b:	74 0f                	je     80087c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80086d:	83 c0 01             	add    $0x1,%eax
  800870:	0f b6 10             	movzbl (%eax),%edx
  800873:	84 d2                	test   %dl,%dl
  800875:	75 f2                	jne    800869 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80087c:	5d                   	pop    %ebp
  80087d:	c3                   	ret    

0080087e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80087e:	55                   	push   %ebp
  80087f:	89 e5                	mov    %esp,%ebp
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800888:	eb 03                	jmp    80088d <strfind+0xf>
  80088a:	83 c0 01             	add    $0x1,%eax
  80088d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800890:	38 ca                	cmp    %cl,%dl
  800892:	74 04                	je     800898 <strfind+0x1a>
  800894:	84 d2                	test   %dl,%dl
  800896:	75 f2                	jne    80088a <strfind+0xc>
			break;
	return (char *) s;
}
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	57                   	push   %edi
  80089e:	56                   	push   %esi
  80089f:	53                   	push   %ebx
  8008a0:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008a3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008a6:	85 c9                	test   %ecx,%ecx
  8008a8:	74 36                	je     8008e0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008aa:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008b0:	75 28                	jne    8008da <memset+0x40>
  8008b2:	f6 c1 03             	test   $0x3,%cl
  8008b5:	75 23                	jne    8008da <memset+0x40>
		c &= 0xFF;
  8008b7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008bb:	89 d3                	mov    %edx,%ebx
  8008bd:	c1 e3 08             	shl    $0x8,%ebx
  8008c0:	89 d6                	mov    %edx,%esi
  8008c2:	c1 e6 18             	shl    $0x18,%esi
  8008c5:	89 d0                	mov    %edx,%eax
  8008c7:	c1 e0 10             	shl    $0x10,%eax
  8008ca:	09 f0                	or     %esi,%eax
  8008cc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008ce:	89 d8                	mov    %ebx,%eax
  8008d0:	09 d0                	or     %edx,%eax
  8008d2:	c1 e9 02             	shr    $0x2,%ecx
  8008d5:	fc                   	cld    
  8008d6:	f3 ab                	rep stos %eax,%es:(%edi)
  8008d8:	eb 06                	jmp    8008e0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008dd:	fc                   	cld    
  8008de:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8008e0:	89 f8                	mov    %edi,%eax
  8008e2:	5b                   	pop    %ebx
  8008e3:	5e                   	pop    %esi
  8008e4:	5f                   	pop    %edi
  8008e5:	5d                   	pop    %ebp
  8008e6:	c3                   	ret    

008008e7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008e7:	55                   	push   %ebp
  8008e8:	89 e5                	mov    %esp,%ebp
  8008ea:	57                   	push   %edi
  8008eb:	56                   	push   %esi
  8008ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ef:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008f2:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008f5:	39 c6                	cmp    %eax,%esi
  8008f7:	73 35                	jae    80092e <memmove+0x47>
  8008f9:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008fc:	39 d0                	cmp    %edx,%eax
  8008fe:	73 2e                	jae    80092e <memmove+0x47>
		s += n;
		d += n;
  800900:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800903:	89 d6                	mov    %edx,%esi
  800905:	09 fe                	or     %edi,%esi
  800907:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80090d:	75 13                	jne    800922 <memmove+0x3b>
  80090f:	f6 c1 03             	test   $0x3,%cl
  800912:	75 0e                	jne    800922 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800914:	83 ef 04             	sub    $0x4,%edi
  800917:	8d 72 fc             	lea    -0x4(%edx),%esi
  80091a:	c1 e9 02             	shr    $0x2,%ecx
  80091d:	fd                   	std    
  80091e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800920:	eb 09                	jmp    80092b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800922:	83 ef 01             	sub    $0x1,%edi
  800925:	8d 72 ff             	lea    -0x1(%edx),%esi
  800928:	fd                   	std    
  800929:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80092b:	fc                   	cld    
  80092c:	eb 1d                	jmp    80094b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80092e:	89 f2                	mov    %esi,%edx
  800930:	09 c2                	or     %eax,%edx
  800932:	f6 c2 03             	test   $0x3,%dl
  800935:	75 0f                	jne    800946 <memmove+0x5f>
  800937:	f6 c1 03             	test   $0x3,%cl
  80093a:	75 0a                	jne    800946 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80093c:	c1 e9 02             	shr    $0x2,%ecx
  80093f:	89 c7                	mov    %eax,%edi
  800941:	fc                   	cld    
  800942:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800944:	eb 05                	jmp    80094b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800946:	89 c7                	mov    %eax,%edi
  800948:	fc                   	cld    
  800949:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80094b:	5e                   	pop    %esi
  80094c:	5f                   	pop    %edi
  80094d:	5d                   	pop    %ebp
  80094e:	c3                   	ret    

0080094f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  80094f:	55                   	push   %ebp
  800950:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800952:	ff 75 10             	pushl  0x10(%ebp)
  800955:	ff 75 0c             	pushl  0xc(%ebp)
  800958:	ff 75 08             	pushl  0x8(%ebp)
  80095b:	e8 87 ff ff ff       	call   8008e7 <memmove>
}
  800960:	c9                   	leave  
  800961:	c3                   	ret    

00800962 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800962:	55                   	push   %ebp
  800963:	89 e5                	mov    %esp,%ebp
  800965:	56                   	push   %esi
  800966:	53                   	push   %ebx
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096d:	89 c6                	mov    %eax,%esi
  80096f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800972:	eb 1a                	jmp    80098e <memcmp+0x2c>
		if (*s1 != *s2)
  800974:	0f b6 08             	movzbl (%eax),%ecx
  800977:	0f b6 1a             	movzbl (%edx),%ebx
  80097a:	38 d9                	cmp    %bl,%cl
  80097c:	74 0a                	je     800988 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80097e:	0f b6 c1             	movzbl %cl,%eax
  800981:	0f b6 db             	movzbl %bl,%ebx
  800984:	29 d8                	sub    %ebx,%eax
  800986:	eb 0f                	jmp    800997 <memcmp+0x35>
		s1++, s2++;
  800988:	83 c0 01             	add    $0x1,%eax
  80098b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80098e:	39 f0                	cmp    %esi,%eax
  800990:	75 e2                	jne    800974 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800992:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800997:	5b                   	pop    %ebx
  800998:	5e                   	pop    %esi
  800999:	5d                   	pop    %ebp
  80099a:	c3                   	ret    

0080099b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80099b:	55                   	push   %ebp
  80099c:	89 e5                	mov    %esp,%ebp
  80099e:	53                   	push   %ebx
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009a2:	89 c1                	mov    %eax,%ecx
  8009a4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009a7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009ab:	eb 0a                	jmp    8009b7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009ad:	0f b6 10             	movzbl (%eax),%edx
  8009b0:	39 da                	cmp    %ebx,%edx
  8009b2:	74 07                	je     8009bb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009b4:	83 c0 01             	add    $0x1,%eax
  8009b7:	39 c8                	cmp    %ecx,%eax
  8009b9:	72 f2                	jb     8009ad <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009bb:	5b                   	pop    %ebx
  8009bc:	5d                   	pop    %ebp
  8009bd:	c3                   	ret    

008009be <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009be:	55                   	push   %ebp
  8009bf:	89 e5                	mov    %esp,%ebp
  8009c1:	57                   	push   %edi
  8009c2:	56                   	push   %esi
  8009c3:	53                   	push   %ebx
  8009c4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ca:	eb 03                	jmp    8009cf <strtol+0x11>
		s++;
  8009cc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009cf:	0f b6 01             	movzbl (%ecx),%eax
  8009d2:	3c 20                	cmp    $0x20,%al
  8009d4:	74 f6                	je     8009cc <strtol+0xe>
  8009d6:	3c 09                	cmp    $0x9,%al
  8009d8:	74 f2                	je     8009cc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009da:	3c 2b                	cmp    $0x2b,%al
  8009dc:	75 0a                	jne    8009e8 <strtol+0x2a>
		s++;
  8009de:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  8009e1:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e6:	eb 11                	jmp    8009f9 <strtol+0x3b>
  8009e8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  8009ed:	3c 2d                	cmp    $0x2d,%al
  8009ef:	75 08                	jne    8009f9 <strtol+0x3b>
		s++, neg = 1;
  8009f1:	83 c1 01             	add    $0x1,%ecx
  8009f4:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009ff:	75 15                	jne    800a16 <strtol+0x58>
  800a01:	80 39 30             	cmpb   $0x30,(%ecx)
  800a04:	75 10                	jne    800a16 <strtol+0x58>
  800a06:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a0a:	75 7c                	jne    800a88 <strtol+0xca>
		s += 2, base = 16;
  800a0c:	83 c1 02             	add    $0x2,%ecx
  800a0f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a14:	eb 16                	jmp    800a2c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a16:	85 db                	test   %ebx,%ebx
  800a18:	75 12                	jne    800a2c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a1a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a1f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a22:	75 08                	jne    800a2c <strtol+0x6e>
		s++, base = 8;
  800a24:	83 c1 01             	add    $0x1,%ecx
  800a27:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a31:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a34:	0f b6 11             	movzbl (%ecx),%edx
  800a37:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a3a:	89 f3                	mov    %esi,%ebx
  800a3c:	80 fb 09             	cmp    $0x9,%bl
  800a3f:	77 08                	ja     800a49 <strtol+0x8b>
			dig = *s - '0';
  800a41:	0f be d2             	movsbl %dl,%edx
  800a44:	83 ea 30             	sub    $0x30,%edx
  800a47:	eb 22                	jmp    800a6b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a49:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a4c:	89 f3                	mov    %esi,%ebx
  800a4e:	80 fb 19             	cmp    $0x19,%bl
  800a51:	77 08                	ja     800a5b <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a53:	0f be d2             	movsbl %dl,%edx
  800a56:	83 ea 57             	sub    $0x57,%edx
  800a59:	eb 10                	jmp    800a6b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a5b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a5e:	89 f3                	mov    %esi,%ebx
  800a60:	80 fb 19             	cmp    $0x19,%bl
  800a63:	77 16                	ja     800a7b <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a65:	0f be d2             	movsbl %dl,%edx
  800a68:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a6b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a6e:	7d 0b                	jge    800a7b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a70:	83 c1 01             	add    $0x1,%ecx
  800a73:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a77:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a79:	eb b9                	jmp    800a34 <strtol+0x76>

	if (endptr)
  800a7b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a7f:	74 0d                	je     800a8e <strtol+0xd0>
		*endptr = (char *) s;
  800a81:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a84:	89 0e                	mov    %ecx,(%esi)
  800a86:	eb 06                	jmp    800a8e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a88:	85 db                	test   %ebx,%ebx
  800a8a:	74 98                	je     800a24 <strtol+0x66>
  800a8c:	eb 9e                	jmp    800a2c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800a8e:	89 c2                	mov    %eax,%edx
  800a90:	f7 da                	neg    %edx
  800a92:	85 ff                	test   %edi,%edi
  800a94:	0f 45 c2             	cmovne %edx,%eax
}
  800a97:	5b                   	pop    %ebx
  800a98:	5e                   	pop    %esi
  800a99:	5f                   	pop    %edi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	57                   	push   %edi
  800aa0:	56                   	push   %esi
  800aa1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aa2:	b8 00 00 00 00       	mov    $0x0,%eax
  800aa7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800aaa:	8b 55 08             	mov    0x8(%ebp),%edx
  800aad:	89 c3                	mov    %eax,%ebx
  800aaf:	89 c7                	mov    %eax,%edi
  800ab1:	89 c6                	mov    %eax,%esi
  800ab3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ab5:	5b                   	pop    %ebx
  800ab6:	5e                   	pop    %esi
  800ab7:	5f                   	pop    %edi
  800ab8:	5d                   	pop    %ebp
  800ab9:	c3                   	ret    

00800aba <sys_cgetc>:

int
sys_cgetc(void)
{
  800aba:	55                   	push   %ebp
  800abb:	89 e5                	mov    %esp,%ebp
  800abd:	57                   	push   %edi
  800abe:	56                   	push   %esi
  800abf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac0:	ba 00 00 00 00       	mov    $0x0,%edx
  800ac5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aca:	89 d1                	mov    %edx,%ecx
  800acc:	89 d3                	mov    %edx,%ebx
  800ace:	89 d7                	mov    %edx,%edi
  800ad0:	89 d6                	mov    %edx,%esi
  800ad2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ad4:	5b                   	pop    %ebx
  800ad5:	5e                   	pop    %esi
  800ad6:	5f                   	pop    %edi
  800ad7:	5d                   	pop    %ebp
  800ad8:	c3                   	ret    

00800ad9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800ad9:	55                   	push   %ebp
  800ada:	89 e5                	mov    %esp,%ebp
  800adc:	57                   	push   %edi
  800add:	56                   	push   %esi
  800ade:	53                   	push   %ebx
  800adf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ae7:	b8 03 00 00 00       	mov    $0x3,%eax
  800aec:	8b 55 08             	mov    0x8(%ebp),%edx
  800aef:	89 cb                	mov    %ecx,%ebx
  800af1:	89 cf                	mov    %ecx,%edi
  800af3:	89 ce                	mov    %ecx,%esi
  800af5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800af7:	85 c0                	test   %eax,%eax
  800af9:	7e 17                	jle    800b12 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800afb:	83 ec 0c             	sub    $0xc,%esp
  800afe:	50                   	push   %eax
  800aff:	6a 03                	push   $0x3
  800b01:	68 1f 26 80 00       	push   $0x80261f
  800b06:	6a 23                	push   $0x23
  800b08:	68 3c 26 80 00       	push   $0x80263c
  800b0d:	e8 c7 13 00 00       	call   801ed9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b12:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b1a:	55                   	push   %ebp
  800b1b:	89 e5                	mov    %esp,%ebp
  800b1d:	57                   	push   %edi
  800b1e:	56                   	push   %esi
  800b1f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b20:	ba 00 00 00 00       	mov    $0x0,%edx
  800b25:	b8 02 00 00 00       	mov    $0x2,%eax
  800b2a:	89 d1                	mov    %edx,%ecx
  800b2c:	89 d3                	mov    %edx,%ebx
  800b2e:	89 d7                	mov    %edx,%edi
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_yield>:

void
sys_yield(void)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b3f:	ba 00 00 00 00       	mov    $0x0,%edx
  800b44:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b49:	89 d1                	mov    %edx,%ecx
  800b4b:	89 d3                	mov    %edx,%ebx
  800b4d:	89 d7                	mov    %edx,%edi
  800b4f:	89 d6                	mov    %edx,%esi
  800b51:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b53:	5b                   	pop    %ebx
  800b54:	5e                   	pop    %esi
  800b55:	5f                   	pop    %edi
  800b56:	5d                   	pop    %ebp
  800b57:	c3                   	ret    

00800b58 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	57                   	push   %edi
  800b5c:	56                   	push   %esi
  800b5d:	53                   	push   %ebx
  800b5e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	be 00 00 00 00       	mov    $0x0,%esi
  800b66:	b8 04 00 00 00       	mov    $0x4,%eax
  800b6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b71:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b74:	89 f7                	mov    %esi,%edi
  800b76:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b78:	85 c0                	test   %eax,%eax
  800b7a:	7e 17                	jle    800b93 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b7c:	83 ec 0c             	sub    $0xc,%esp
  800b7f:	50                   	push   %eax
  800b80:	6a 04                	push   $0x4
  800b82:	68 1f 26 80 00       	push   $0x80261f
  800b87:	6a 23                	push   $0x23
  800b89:	68 3c 26 80 00       	push   $0x80263c
  800b8e:	e8 46 13 00 00       	call   801ed9 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800b93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
  800ba1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba4:	b8 05 00 00 00       	mov    $0x5,%eax
  800ba9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bac:	8b 55 08             	mov    0x8(%ebp),%edx
  800baf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bb2:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bb5:	8b 75 18             	mov    0x18(%ebp),%esi
  800bb8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bba:	85 c0                	test   %eax,%eax
  800bbc:	7e 17                	jle    800bd5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bbe:	83 ec 0c             	sub    $0xc,%esp
  800bc1:	50                   	push   %eax
  800bc2:	6a 05                	push   $0x5
  800bc4:	68 1f 26 80 00       	push   $0x80261f
  800bc9:	6a 23                	push   $0x23
  800bcb:	68 3c 26 80 00       	push   $0x80263c
  800bd0:	e8 04 13 00 00       	call   801ed9 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bd5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bd8:	5b                   	pop    %ebx
  800bd9:	5e                   	pop    %esi
  800bda:	5f                   	pop    %edi
  800bdb:	5d                   	pop    %ebp
  800bdc:	c3                   	ret    

00800bdd <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800be6:	bb 00 00 00 00       	mov    $0x0,%ebx
  800beb:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bf3:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf6:	89 df                	mov    %ebx,%edi
  800bf8:	89 de                	mov    %ebx,%esi
  800bfa:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bfc:	85 c0                	test   %eax,%eax
  800bfe:	7e 17                	jle    800c17 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c00:	83 ec 0c             	sub    $0xc,%esp
  800c03:	50                   	push   %eax
  800c04:	6a 06                	push   $0x6
  800c06:	68 1f 26 80 00       	push   $0x80261f
  800c0b:	6a 23                	push   $0x23
  800c0d:	68 3c 26 80 00       	push   $0x80263c
  800c12:	e8 c2 12 00 00       	call   801ed9 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c1a:	5b                   	pop    %ebx
  800c1b:	5e                   	pop    %esi
  800c1c:	5f                   	pop    %edi
  800c1d:	5d                   	pop    %ebp
  800c1e:	c3                   	ret    

00800c1f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	57                   	push   %edi
  800c23:	56                   	push   %esi
  800c24:	53                   	push   %ebx
  800c25:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c28:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c2d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c35:	8b 55 08             	mov    0x8(%ebp),%edx
  800c38:	89 df                	mov    %ebx,%edi
  800c3a:	89 de                	mov    %ebx,%esi
  800c3c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c3e:	85 c0                	test   %eax,%eax
  800c40:	7e 17                	jle    800c59 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c42:	83 ec 0c             	sub    $0xc,%esp
  800c45:	50                   	push   %eax
  800c46:	6a 08                	push   $0x8
  800c48:	68 1f 26 80 00       	push   $0x80261f
  800c4d:	6a 23                	push   $0x23
  800c4f:	68 3c 26 80 00       	push   $0x80263c
  800c54:	e8 80 12 00 00       	call   801ed9 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c59:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c5c:	5b                   	pop    %ebx
  800c5d:	5e                   	pop    %esi
  800c5e:	5f                   	pop    %edi
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	57                   	push   %edi
  800c65:	56                   	push   %esi
  800c66:	53                   	push   %ebx
  800c67:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c6f:	b8 09 00 00 00       	mov    $0x9,%eax
  800c74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c77:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7a:	89 df                	mov    %ebx,%edi
  800c7c:	89 de                	mov    %ebx,%esi
  800c7e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c80:	85 c0                	test   %eax,%eax
  800c82:	7e 17                	jle    800c9b <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c84:	83 ec 0c             	sub    $0xc,%esp
  800c87:	50                   	push   %eax
  800c88:	6a 09                	push   $0x9
  800c8a:	68 1f 26 80 00       	push   $0x80261f
  800c8f:	6a 23                	push   $0x23
  800c91:	68 3c 26 80 00       	push   $0x80263c
  800c96:	e8 3e 12 00 00       	call   801ed9 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800c9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c9e:	5b                   	pop    %ebx
  800c9f:	5e                   	pop    %esi
  800ca0:	5f                   	pop    %edi
  800ca1:	5d                   	pop    %ebp
  800ca2:	c3                   	ret    

00800ca3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	57                   	push   %edi
  800ca7:	56                   	push   %esi
  800ca8:	53                   	push   %ebx
  800ca9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cac:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cb1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cb6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb9:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbc:	89 df                	mov    %ebx,%edi
  800cbe:	89 de                	mov    %ebx,%esi
  800cc0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cc2:	85 c0                	test   %eax,%eax
  800cc4:	7e 17                	jle    800cdd <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc6:	83 ec 0c             	sub    $0xc,%esp
  800cc9:	50                   	push   %eax
  800cca:	6a 0a                	push   $0xa
  800ccc:	68 1f 26 80 00       	push   $0x80261f
  800cd1:	6a 23                	push   $0x23
  800cd3:	68 3c 26 80 00       	push   $0x80263c
  800cd8:	e8 fc 11 00 00       	call   801ed9 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cdd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce0:	5b                   	pop    %ebx
  800ce1:	5e                   	pop    %esi
  800ce2:	5f                   	pop    %edi
  800ce3:	5d                   	pop    %ebp
  800ce4:	c3                   	ret    

00800ce5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ce5:	55                   	push   %ebp
  800ce6:	89 e5                	mov    %esp,%ebp
  800ce8:	57                   	push   %edi
  800ce9:	56                   	push   %esi
  800cea:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ceb:	be 00 00 00 00       	mov    $0x0,%esi
  800cf0:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cf5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cfe:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d01:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d03:	5b                   	pop    %ebx
  800d04:	5e                   	pop    %esi
  800d05:	5f                   	pop    %edi
  800d06:	5d                   	pop    %ebp
  800d07:	c3                   	ret    

00800d08 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d08:	55                   	push   %ebp
  800d09:	89 e5                	mov    %esp,%ebp
  800d0b:	57                   	push   %edi
  800d0c:	56                   	push   %esi
  800d0d:	53                   	push   %ebx
  800d0e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d11:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d16:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d1b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1e:	89 cb                	mov    %ecx,%ebx
  800d20:	89 cf                	mov    %ecx,%edi
  800d22:	89 ce                	mov    %ecx,%esi
  800d24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d26:	85 c0                	test   %eax,%eax
  800d28:	7e 17                	jle    800d41 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2a:	83 ec 0c             	sub    $0xc,%esp
  800d2d:	50                   	push   %eax
  800d2e:	6a 0d                	push   $0xd
  800d30:	68 1f 26 80 00       	push   $0x80261f
  800d35:	6a 23                	push   $0x23
  800d37:	68 3c 26 80 00       	push   $0x80263c
  800d3c:	e8 98 11 00 00       	call   801ed9 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d44:	5b                   	pop    %ebx
  800d45:	5e                   	pop    %esi
  800d46:	5f                   	pop    %edi
  800d47:	5d                   	pop    %ebp
  800d48:	c3                   	ret    

00800d49 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d49:	55                   	push   %ebp
  800d4a:	89 e5                	mov    %esp,%ebp
  800d4c:	57                   	push   %edi
  800d4d:	56                   	push   %esi
  800d4e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4f:	ba 00 00 00 00       	mov    $0x0,%edx
  800d54:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d59:	89 d1                	mov    %edx,%ecx
  800d5b:	89 d3                	mov    %edx,%ebx
  800d5d:	89 d7                	mov    %edx,%edi
  800d5f:	89 d6                	mov    %edx,%esi
  800d61:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d73:	b8 10 00 00 00       	mov    $0x10,%eax
  800d78:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7b:	89 cb                	mov    %ecx,%ebx
  800d7d:	89 cf                	mov    %ecx,%edi
  800d7f:	89 ce                	mov    %ecx,%esi
  800d81:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800d83:	5b                   	pop    %ebx
  800d84:	5e                   	pop    %esi
  800d85:	5f                   	pop    %edi
  800d86:	5d                   	pop    %ebp
  800d87:	c3                   	ret    

00800d88 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d88:	55                   	push   %ebp
  800d89:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8e:	05 00 00 00 30       	add    $0x30000000,%eax
  800d93:	c1 e8 0c             	shr    $0xc,%eax
}
  800d96:	5d                   	pop    %ebp
  800d97:	c3                   	ret    

00800d98 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9e:	05 00 00 00 30       	add    $0x30000000,%eax
  800da3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800da8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800dad:	5d                   	pop    %ebp
  800dae:	c3                   	ret    

00800daf <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dba:	89 c2                	mov    %eax,%edx
  800dbc:	c1 ea 16             	shr    $0x16,%edx
  800dbf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dc6:	f6 c2 01             	test   $0x1,%dl
  800dc9:	74 11                	je     800ddc <fd_alloc+0x2d>
  800dcb:	89 c2                	mov    %eax,%edx
  800dcd:	c1 ea 0c             	shr    $0xc,%edx
  800dd0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd7:	f6 c2 01             	test   $0x1,%dl
  800dda:	75 09                	jne    800de5 <fd_alloc+0x36>
			*fd_store = fd;
  800ddc:	89 01                	mov    %eax,(%ecx)
			return 0;
  800dde:	b8 00 00 00 00       	mov    $0x0,%eax
  800de3:	eb 17                	jmp    800dfc <fd_alloc+0x4d>
  800de5:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dea:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800def:	75 c9                	jne    800dba <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800df1:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800df7:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dfc:	5d                   	pop    %ebp
  800dfd:	c3                   	ret    

00800dfe <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800dfe:	55                   	push   %ebp
  800dff:	89 e5                	mov    %esp,%ebp
  800e01:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e04:	83 f8 1f             	cmp    $0x1f,%eax
  800e07:	77 36                	ja     800e3f <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e09:	c1 e0 0c             	shl    $0xc,%eax
  800e0c:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e11:	89 c2                	mov    %eax,%edx
  800e13:	c1 ea 16             	shr    $0x16,%edx
  800e16:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e1d:	f6 c2 01             	test   $0x1,%dl
  800e20:	74 24                	je     800e46 <fd_lookup+0x48>
  800e22:	89 c2                	mov    %eax,%edx
  800e24:	c1 ea 0c             	shr    $0xc,%edx
  800e27:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e2e:	f6 c2 01             	test   $0x1,%dl
  800e31:	74 1a                	je     800e4d <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e33:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e36:	89 02                	mov    %eax,(%edx)
	return 0;
  800e38:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3d:	eb 13                	jmp    800e52 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e3f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e44:	eb 0c                	jmp    800e52 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e46:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e4b:	eb 05                	jmp    800e52 <fd_lookup+0x54>
  800e4d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	83 ec 08             	sub    $0x8,%esp
  800e5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5d:	ba c8 26 80 00       	mov    $0x8026c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e62:	eb 13                	jmp    800e77 <dev_lookup+0x23>
  800e64:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e67:	39 08                	cmp    %ecx,(%eax)
  800e69:	75 0c                	jne    800e77 <dev_lookup+0x23>
			*dev = devtab[i];
  800e6b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e6e:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e70:	b8 00 00 00 00       	mov    $0x0,%eax
  800e75:	eb 2e                	jmp    800ea5 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e77:	8b 02                	mov    (%edx),%eax
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	75 e7                	jne    800e64 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e7d:	a1 08 40 80 00       	mov    0x804008,%eax
  800e82:	8b 40 48             	mov    0x48(%eax),%eax
  800e85:	83 ec 04             	sub    $0x4,%esp
  800e88:	51                   	push   %ecx
  800e89:	50                   	push   %eax
  800e8a:	68 4c 26 80 00       	push   $0x80264c
  800e8f:	e8 bd f2 ff ff       	call   800151 <cprintf>
	*dev = 0;
  800e94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e97:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e9d:	83 c4 10             	add    $0x10,%esp
  800ea0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ea5:	c9                   	leave  
  800ea6:	c3                   	ret    

00800ea7 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	56                   	push   %esi
  800eab:	53                   	push   %ebx
  800eac:	83 ec 10             	sub    $0x10,%esp
  800eaf:	8b 75 08             	mov    0x8(%ebp),%esi
  800eb2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eb5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb8:	50                   	push   %eax
  800eb9:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ebf:	c1 e8 0c             	shr    $0xc,%eax
  800ec2:	50                   	push   %eax
  800ec3:	e8 36 ff ff ff       	call   800dfe <fd_lookup>
  800ec8:	83 c4 08             	add    $0x8,%esp
  800ecb:	85 c0                	test   %eax,%eax
  800ecd:	78 05                	js     800ed4 <fd_close+0x2d>
	    || fd != fd2)
  800ecf:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ed2:	74 0c                	je     800ee0 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ed4:	84 db                	test   %bl,%bl
  800ed6:	ba 00 00 00 00       	mov    $0x0,%edx
  800edb:	0f 44 c2             	cmove  %edx,%eax
  800ede:	eb 41                	jmp    800f21 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ee0:	83 ec 08             	sub    $0x8,%esp
  800ee3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ee6:	50                   	push   %eax
  800ee7:	ff 36                	pushl  (%esi)
  800ee9:	e8 66 ff ff ff       	call   800e54 <dev_lookup>
  800eee:	89 c3                	mov    %eax,%ebx
  800ef0:	83 c4 10             	add    $0x10,%esp
  800ef3:	85 c0                	test   %eax,%eax
  800ef5:	78 1a                	js     800f11 <fd_close+0x6a>
		if (dev->dev_close)
  800ef7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800efa:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800efd:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f02:	85 c0                	test   %eax,%eax
  800f04:	74 0b                	je     800f11 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f06:	83 ec 0c             	sub    $0xc,%esp
  800f09:	56                   	push   %esi
  800f0a:	ff d0                	call   *%eax
  800f0c:	89 c3                	mov    %eax,%ebx
  800f0e:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f11:	83 ec 08             	sub    $0x8,%esp
  800f14:	56                   	push   %esi
  800f15:	6a 00                	push   $0x0
  800f17:	e8 c1 fc ff ff       	call   800bdd <sys_page_unmap>
	return r;
  800f1c:	83 c4 10             	add    $0x10,%esp
  800f1f:	89 d8                	mov    %ebx,%eax
}
  800f21:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f24:	5b                   	pop    %ebx
  800f25:	5e                   	pop    %esi
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    

00800f28 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f31:	50                   	push   %eax
  800f32:	ff 75 08             	pushl  0x8(%ebp)
  800f35:	e8 c4 fe ff ff       	call   800dfe <fd_lookup>
  800f3a:	83 c4 08             	add    $0x8,%esp
  800f3d:	85 c0                	test   %eax,%eax
  800f3f:	78 10                	js     800f51 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f41:	83 ec 08             	sub    $0x8,%esp
  800f44:	6a 01                	push   $0x1
  800f46:	ff 75 f4             	pushl  -0xc(%ebp)
  800f49:	e8 59 ff ff ff       	call   800ea7 <fd_close>
  800f4e:	83 c4 10             	add    $0x10,%esp
}
  800f51:	c9                   	leave  
  800f52:	c3                   	ret    

00800f53 <close_all>:

void
close_all(void)
{
  800f53:	55                   	push   %ebp
  800f54:	89 e5                	mov    %esp,%ebp
  800f56:	53                   	push   %ebx
  800f57:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f5a:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f5f:	83 ec 0c             	sub    $0xc,%esp
  800f62:	53                   	push   %ebx
  800f63:	e8 c0 ff ff ff       	call   800f28 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f68:	83 c3 01             	add    $0x1,%ebx
  800f6b:	83 c4 10             	add    $0x10,%esp
  800f6e:	83 fb 20             	cmp    $0x20,%ebx
  800f71:	75 ec                	jne    800f5f <close_all+0xc>
		close(i);
}
  800f73:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f76:	c9                   	leave  
  800f77:	c3                   	ret    

00800f78 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f78:	55                   	push   %ebp
  800f79:	89 e5                	mov    %esp,%ebp
  800f7b:	57                   	push   %edi
  800f7c:	56                   	push   %esi
  800f7d:	53                   	push   %ebx
  800f7e:	83 ec 2c             	sub    $0x2c,%esp
  800f81:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f84:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f87:	50                   	push   %eax
  800f88:	ff 75 08             	pushl  0x8(%ebp)
  800f8b:	e8 6e fe ff ff       	call   800dfe <fd_lookup>
  800f90:	83 c4 08             	add    $0x8,%esp
  800f93:	85 c0                	test   %eax,%eax
  800f95:	0f 88 c1 00 00 00    	js     80105c <dup+0xe4>
		return r;
	close(newfdnum);
  800f9b:	83 ec 0c             	sub    $0xc,%esp
  800f9e:	56                   	push   %esi
  800f9f:	e8 84 ff ff ff       	call   800f28 <close>

	newfd = INDEX2FD(newfdnum);
  800fa4:	89 f3                	mov    %esi,%ebx
  800fa6:	c1 e3 0c             	shl    $0xc,%ebx
  800fa9:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800faf:	83 c4 04             	add    $0x4,%esp
  800fb2:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb5:	e8 de fd ff ff       	call   800d98 <fd2data>
  800fba:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fbc:	89 1c 24             	mov    %ebx,(%esp)
  800fbf:	e8 d4 fd ff ff       	call   800d98 <fd2data>
  800fc4:	83 c4 10             	add    $0x10,%esp
  800fc7:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fca:	89 f8                	mov    %edi,%eax
  800fcc:	c1 e8 16             	shr    $0x16,%eax
  800fcf:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd6:	a8 01                	test   $0x1,%al
  800fd8:	74 37                	je     801011 <dup+0x99>
  800fda:	89 f8                	mov    %edi,%eax
  800fdc:	c1 e8 0c             	shr    $0xc,%eax
  800fdf:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe6:	f6 c2 01             	test   $0x1,%dl
  800fe9:	74 26                	je     801011 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800feb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff2:	83 ec 0c             	sub    $0xc,%esp
  800ff5:	25 07 0e 00 00       	and    $0xe07,%eax
  800ffa:	50                   	push   %eax
  800ffb:	ff 75 d4             	pushl  -0x2c(%ebp)
  800ffe:	6a 00                	push   $0x0
  801000:	57                   	push   %edi
  801001:	6a 00                	push   $0x0
  801003:	e8 93 fb ff ff       	call   800b9b <sys_page_map>
  801008:	89 c7                	mov    %eax,%edi
  80100a:	83 c4 20             	add    $0x20,%esp
  80100d:	85 c0                	test   %eax,%eax
  80100f:	78 2e                	js     80103f <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801011:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801014:	89 d0                	mov    %edx,%eax
  801016:	c1 e8 0c             	shr    $0xc,%eax
  801019:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801020:	83 ec 0c             	sub    $0xc,%esp
  801023:	25 07 0e 00 00       	and    $0xe07,%eax
  801028:	50                   	push   %eax
  801029:	53                   	push   %ebx
  80102a:	6a 00                	push   $0x0
  80102c:	52                   	push   %edx
  80102d:	6a 00                	push   $0x0
  80102f:	e8 67 fb ff ff       	call   800b9b <sys_page_map>
  801034:	89 c7                	mov    %eax,%edi
  801036:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801039:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80103b:	85 ff                	test   %edi,%edi
  80103d:	79 1d                	jns    80105c <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80103f:	83 ec 08             	sub    $0x8,%esp
  801042:	53                   	push   %ebx
  801043:	6a 00                	push   $0x0
  801045:	e8 93 fb ff ff       	call   800bdd <sys_page_unmap>
	sys_page_unmap(0, nva);
  80104a:	83 c4 08             	add    $0x8,%esp
  80104d:	ff 75 d4             	pushl  -0x2c(%ebp)
  801050:	6a 00                	push   $0x0
  801052:	e8 86 fb ff ff       	call   800bdd <sys_page_unmap>
	return r;
  801057:	83 c4 10             	add    $0x10,%esp
  80105a:	89 f8                	mov    %edi,%eax
}
  80105c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80105f:	5b                   	pop    %ebx
  801060:	5e                   	pop    %esi
  801061:	5f                   	pop    %edi
  801062:	5d                   	pop    %ebp
  801063:	c3                   	ret    

00801064 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	53                   	push   %ebx
  801068:	83 ec 14             	sub    $0x14,%esp
  80106b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80106e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801071:	50                   	push   %eax
  801072:	53                   	push   %ebx
  801073:	e8 86 fd ff ff       	call   800dfe <fd_lookup>
  801078:	83 c4 08             	add    $0x8,%esp
  80107b:	89 c2                	mov    %eax,%edx
  80107d:	85 c0                	test   %eax,%eax
  80107f:	78 6d                	js     8010ee <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801081:	83 ec 08             	sub    $0x8,%esp
  801084:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801087:	50                   	push   %eax
  801088:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80108b:	ff 30                	pushl  (%eax)
  80108d:	e8 c2 fd ff ff       	call   800e54 <dev_lookup>
  801092:	83 c4 10             	add    $0x10,%esp
  801095:	85 c0                	test   %eax,%eax
  801097:	78 4c                	js     8010e5 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801099:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80109c:	8b 42 08             	mov    0x8(%edx),%eax
  80109f:	83 e0 03             	and    $0x3,%eax
  8010a2:	83 f8 01             	cmp    $0x1,%eax
  8010a5:	75 21                	jne    8010c8 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010a7:	a1 08 40 80 00       	mov    0x804008,%eax
  8010ac:	8b 40 48             	mov    0x48(%eax),%eax
  8010af:	83 ec 04             	sub    $0x4,%esp
  8010b2:	53                   	push   %ebx
  8010b3:	50                   	push   %eax
  8010b4:	68 8d 26 80 00       	push   $0x80268d
  8010b9:	e8 93 f0 ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  8010be:	83 c4 10             	add    $0x10,%esp
  8010c1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010c6:	eb 26                	jmp    8010ee <read+0x8a>
	}
	if (!dev->dev_read)
  8010c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010cb:	8b 40 08             	mov    0x8(%eax),%eax
  8010ce:	85 c0                	test   %eax,%eax
  8010d0:	74 17                	je     8010e9 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010d2:	83 ec 04             	sub    $0x4,%esp
  8010d5:	ff 75 10             	pushl  0x10(%ebp)
  8010d8:	ff 75 0c             	pushl  0xc(%ebp)
  8010db:	52                   	push   %edx
  8010dc:	ff d0                	call   *%eax
  8010de:	89 c2                	mov    %eax,%edx
  8010e0:	83 c4 10             	add    $0x10,%esp
  8010e3:	eb 09                	jmp    8010ee <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e5:	89 c2                	mov    %eax,%edx
  8010e7:	eb 05                	jmp    8010ee <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010e9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010ee:	89 d0                	mov    %edx,%eax
  8010f0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f3:	c9                   	leave  
  8010f4:	c3                   	ret    

008010f5 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010f5:	55                   	push   %ebp
  8010f6:	89 e5                	mov    %esp,%ebp
  8010f8:	57                   	push   %edi
  8010f9:	56                   	push   %esi
  8010fa:	53                   	push   %ebx
  8010fb:	83 ec 0c             	sub    $0xc,%esp
  8010fe:	8b 7d 08             	mov    0x8(%ebp),%edi
  801101:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801104:	bb 00 00 00 00       	mov    $0x0,%ebx
  801109:	eb 21                	jmp    80112c <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80110b:	83 ec 04             	sub    $0x4,%esp
  80110e:	89 f0                	mov    %esi,%eax
  801110:	29 d8                	sub    %ebx,%eax
  801112:	50                   	push   %eax
  801113:	89 d8                	mov    %ebx,%eax
  801115:	03 45 0c             	add    0xc(%ebp),%eax
  801118:	50                   	push   %eax
  801119:	57                   	push   %edi
  80111a:	e8 45 ff ff ff       	call   801064 <read>
		if (m < 0)
  80111f:	83 c4 10             	add    $0x10,%esp
  801122:	85 c0                	test   %eax,%eax
  801124:	78 10                	js     801136 <readn+0x41>
			return m;
		if (m == 0)
  801126:	85 c0                	test   %eax,%eax
  801128:	74 0a                	je     801134 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80112a:	01 c3                	add    %eax,%ebx
  80112c:	39 f3                	cmp    %esi,%ebx
  80112e:	72 db                	jb     80110b <readn+0x16>
  801130:	89 d8                	mov    %ebx,%eax
  801132:	eb 02                	jmp    801136 <readn+0x41>
  801134:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801136:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801139:	5b                   	pop    %ebx
  80113a:	5e                   	pop    %esi
  80113b:	5f                   	pop    %edi
  80113c:	5d                   	pop    %ebp
  80113d:	c3                   	ret    

0080113e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80113e:	55                   	push   %ebp
  80113f:	89 e5                	mov    %esp,%ebp
  801141:	53                   	push   %ebx
  801142:	83 ec 14             	sub    $0x14,%esp
  801145:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801148:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80114b:	50                   	push   %eax
  80114c:	53                   	push   %ebx
  80114d:	e8 ac fc ff ff       	call   800dfe <fd_lookup>
  801152:	83 c4 08             	add    $0x8,%esp
  801155:	89 c2                	mov    %eax,%edx
  801157:	85 c0                	test   %eax,%eax
  801159:	78 68                	js     8011c3 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115b:	83 ec 08             	sub    $0x8,%esp
  80115e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801161:	50                   	push   %eax
  801162:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801165:	ff 30                	pushl  (%eax)
  801167:	e8 e8 fc ff ff       	call   800e54 <dev_lookup>
  80116c:	83 c4 10             	add    $0x10,%esp
  80116f:	85 c0                	test   %eax,%eax
  801171:	78 47                	js     8011ba <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801173:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801176:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80117a:	75 21                	jne    80119d <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80117c:	a1 08 40 80 00       	mov    0x804008,%eax
  801181:	8b 40 48             	mov    0x48(%eax),%eax
  801184:	83 ec 04             	sub    $0x4,%esp
  801187:	53                   	push   %ebx
  801188:	50                   	push   %eax
  801189:	68 a9 26 80 00       	push   $0x8026a9
  80118e:	e8 be ef ff ff       	call   800151 <cprintf>
		return -E_INVAL;
  801193:	83 c4 10             	add    $0x10,%esp
  801196:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80119b:	eb 26                	jmp    8011c3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80119d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011a0:	8b 52 0c             	mov    0xc(%edx),%edx
  8011a3:	85 d2                	test   %edx,%edx
  8011a5:	74 17                	je     8011be <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011a7:	83 ec 04             	sub    $0x4,%esp
  8011aa:	ff 75 10             	pushl  0x10(%ebp)
  8011ad:	ff 75 0c             	pushl  0xc(%ebp)
  8011b0:	50                   	push   %eax
  8011b1:	ff d2                	call   *%edx
  8011b3:	89 c2                	mov    %eax,%edx
  8011b5:	83 c4 10             	add    $0x10,%esp
  8011b8:	eb 09                	jmp    8011c3 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011ba:	89 c2                	mov    %eax,%edx
  8011bc:	eb 05                	jmp    8011c3 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011be:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011c3:	89 d0                	mov    %edx,%eax
  8011c5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011c8:	c9                   	leave  
  8011c9:	c3                   	ret    

008011ca <seek>:

int
seek(int fdnum, off_t offset)
{
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
  8011cd:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011d0:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011d3:	50                   	push   %eax
  8011d4:	ff 75 08             	pushl  0x8(%ebp)
  8011d7:	e8 22 fc ff ff       	call   800dfe <fd_lookup>
  8011dc:	83 c4 08             	add    $0x8,%esp
  8011df:	85 c0                	test   %eax,%eax
  8011e1:	78 0e                	js     8011f1 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011e3:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011e9:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011f1:	c9                   	leave  
  8011f2:	c3                   	ret    

008011f3 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	53                   	push   %ebx
  8011f7:	83 ec 14             	sub    $0x14,%esp
  8011fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801200:	50                   	push   %eax
  801201:	53                   	push   %ebx
  801202:	e8 f7 fb ff ff       	call   800dfe <fd_lookup>
  801207:	83 c4 08             	add    $0x8,%esp
  80120a:	89 c2                	mov    %eax,%edx
  80120c:	85 c0                	test   %eax,%eax
  80120e:	78 65                	js     801275 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801210:	83 ec 08             	sub    $0x8,%esp
  801213:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801216:	50                   	push   %eax
  801217:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121a:	ff 30                	pushl  (%eax)
  80121c:	e8 33 fc ff ff       	call   800e54 <dev_lookup>
  801221:	83 c4 10             	add    $0x10,%esp
  801224:	85 c0                	test   %eax,%eax
  801226:	78 44                	js     80126c <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801228:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80122f:	75 21                	jne    801252 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801231:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801236:	8b 40 48             	mov    0x48(%eax),%eax
  801239:	83 ec 04             	sub    $0x4,%esp
  80123c:	53                   	push   %ebx
  80123d:	50                   	push   %eax
  80123e:	68 6c 26 80 00       	push   $0x80266c
  801243:	e8 09 ef ff ff       	call   800151 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801248:	83 c4 10             	add    $0x10,%esp
  80124b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801250:	eb 23                	jmp    801275 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801252:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801255:	8b 52 18             	mov    0x18(%edx),%edx
  801258:	85 d2                	test   %edx,%edx
  80125a:	74 14                	je     801270 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80125c:	83 ec 08             	sub    $0x8,%esp
  80125f:	ff 75 0c             	pushl  0xc(%ebp)
  801262:	50                   	push   %eax
  801263:	ff d2                	call   *%edx
  801265:	89 c2                	mov    %eax,%edx
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	eb 09                	jmp    801275 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126c:	89 c2                	mov    %eax,%edx
  80126e:	eb 05                	jmp    801275 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801270:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801275:	89 d0                	mov    %edx,%eax
  801277:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127a:	c9                   	leave  
  80127b:	c3                   	ret    

0080127c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80127c:	55                   	push   %ebp
  80127d:	89 e5                	mov    %esp,%ebp
  80127f:	53                   	push   %ebx
  801280:	83 ec 14             	sub    $0x14,%esp
  801283:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801286:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801289:	50                   	push   %eax
  80128a:	ff 75 08             	pushl  0x8(%ebp)
  80128d:	e8 6c fb ff ff       	call   800dfe <fd_lookup>
  801292:	83 c4 08             	add    $0x8,%esp
  801295:	89 c2                	mov    %eax,%edx
  801297:	85 c0                	test   %eax,%eax
  801299:	78 58                	js     8012f3 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80129b:	83 ec 08             	sub    $0x8,%esp
  80129e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a1:	50                   	push   %eax
  8012a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a5:	ff 30                	pushl  (%eax)
  8012a7:	e8 a8 fb ff ff       	call   800e54 <dev_lookup>
  8012ac:	83 c4 10             	add    $0x10,%esp
  8012af:	85 c0                	test   %eax,%eax
  8012b1:	78 37                	js     8012ea <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012ba:	74 32                	je     8012ee <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012bc:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012bf:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012c6:	00 00 00 
	stat->st_isdir = 0;
  8012c9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012d0:	00 00 00 
	stat->st_dev = dev;
  8012d3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012d9:	83 ec 08             	sub    $0x8,%esp
  8012dc:	53                   	push   %ebx
  8012dd:	ff 75 f0             	pushl  -0x10(%ebp)
  8012e0:	ff 50 14             	call   *0x14(%eax)
  8012e3:	89 c2                	mov    %eax,%edx
  8012e5:	83 c4 10             	add    $0x10,%esp
  8012e8:	eb 09                	jmp    8012f3 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ea:	89 c2                	mov    %eax,%edx
  8012ec:	eb 05                	jmp    8012f3 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012ee:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012f3:	89 d0                	mov    %edx,%eax
  8012f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012f8:	c9                   	leave  
  8012f9:	c3                   	ret    

008012fa <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012fa:	55                   	push   %ebp
  8012fb:	89 e5                	mov    %esp,%ebp
  8012fd:	56                   	push   %esi
  8012fe:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8012ff:	83 ec 08             	sub    $0x8,%esp
  801302:	6a 00                	push   $0x0
  801304:	ff 75 08             	pushl  0x8(%ebp)
  801307:	e8 e3 01 00 00       	call   8014ef <open>
  80130c:	89 c3                	mov    %eax,%ebx
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	85 c0                	test   %eax,%eax
  801313:	78 1b                	js     801330 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801315:	83 ec 08             	sub    $0x8,%esp
  801318:	ff 75 0c             	pushl  0xc(%ebp)
  80131b:	50                   	push   %eax
  80131c:	e8 5b ff ff ff       	call   80127c <fstat>
  801321:	89 c6                	mov    %eax,%esi
	close(fd);
  801323:	89 1c 24             	mov    %ebx,(%esp)
  801326:	e8 fd fb ff ff       	call   800f28 <close>
	return r;
  80132b:	83 c4 10             	add    $0x10,%esp
  80132e:	89 f0                	mov    %esi,%eax
}
  801330:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801333:	5b                   	pop    %ebx
  801334:	5e                   	pop    %esi
  801335:	5d                   	pop    %ebp
  801336:	c3                   	ret    

00801337 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801337:	55                   	push   %ebp
  801338:	89 e5                	mov    %esp,%ebp
  80133a:	56                   	push   %esi
  80133b:	53                   	push   %ebx
  80133c:	89 c6                	mov    %eax,%esi
  80133e:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801340:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801347:	75 12                	jne    80135b <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801349:	83 ec 0c             	sub    $0xc,%esp
  80134c:	6a 01                	push   $0x1
  80134e:	e8 89 0c 00 00       	call   801fdc <ipc_find_env>
  801353:	a3 00 40 80 00       	mov    %eax,0x804000
  801358:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80135b:	6a 07                	push   $0x7
  80135d:	68 00 50 80 00       	push   $0x805000
  801362:	56                   	push   %esi
  801363:	ff 35 00 40 80 00    	pushl  0x804000
  801369:	e8 1a 0c 00 00       	call   801f88 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80136e:	83 c4 0c             	add    $0xc,%esp
  801371:	6a 00                	push   $0x0
  801373:	53                   	push   %ebx
  801374:	6a 00                	push   $0x0
  801376:	e8 a4 0b 00 00       	call   801f1f <ipc_recv>
}
  80137b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80137e:	5b                   	pop    %ebx
  80137f:	5e                   	pop    %esi
  801380:	5d                   	pop    %ebp
  801381:	c3                   	ret    

00801382 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801382:	55                   	push   %ebp
  801383:	89 e5                	mov    %esp,%ebp
  801385:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801388:	8b 45 08             	mov    0x8(%ebp),%eax
  80138b:	8b 40 0c             	mov    0xc(%eax),%eax
  80138e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801393:	8b 45 0c             	mov    0xc(%ebp),%eax
  801396:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80139b:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a0:	b8 02 00 00 00       	mov    $0x2,%eax
  8013a5:	e8 8d ff ff ff       	call   801337 <fsipc>
}
  8013aa:	c9                   	leave  
  8013ab:	c3                   	ret    

008013ac <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013b2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b5:	8b 40 0c             	mov    0xc(%eax),%eax
  8013b8:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c2:	b8 06 00 00 00       	mov    $0x6,%eax
  8013c7:	e8 6b ff ff ff       	call   801337 <fsipc>
}
  8013cc:	c9                   	leave  
  8013cd:	c3                   	ret    

008013ce <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013ce:	55                   	push   %ebp
  8013cf:	89 e5                	mov    %esp,%ebp
  8013d1:	53                   	push   %ebx
  8013d2:	83 ec 04             	sub    $0x4,%esp
  8013d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8013db:	8b 40 0c             	mov    0xc(%eax),%eax
  8013de:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8013e8:	b8 05 00 00 00       	mov    $0x5,%eax
  8013ed:	e8 45 ff ff ff       	call   801337 <fsipc>
  8013f2:	85 c0                	test   %eax,%eax
  8013f4:	78 2c                	js     801422 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013f6:	83 ec 08             	sub    $0x8,%esp
  8013f9:	68 00 50 80 00       	push   $0x805000
  8013fe:	53                   	push   %ebx
  8013ff:	e8 51 f3 ff ff       	call   800755 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801404:	a1 80 50 80 00       	mov    0x805080,%eax
  801409:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80140f:	a1 84 50 80 00       	mov    0x805084,%eax
  801414:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801422:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801425:	c9                   	leave  
  801426:	c3                   	ret    

00801427 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801427:	55                   	push   %ebp
  801428:	89 e5                	mov    %esp,%ebp
  80142a:	83 ec 0c             	sub    $0xc,%esp
  80142d:	8b 45 10             	mov    0x10(%ebp),%eax
  801430:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801435:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80143a:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80143d:	8b 55 08             	mov    0x8(%ebp),%edx
  801440:	8b 52 0c             	mov    0xc(%edx),%edx
  801443:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801449:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  80144e:	50                   	push   %eax
  80144f:	ff 75 0c             	pushl  0xc(%ebp)
  801452:	68 08 50 80 00       	push   $0x805008
  801457:	e8 8b f4 ff ff       	call   8008e7 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80145c:	ba 00 00 00 00       	mov    $0x0,%edx
  801461:	b8 04 00 00 00       	mov    $0x4,%eax
  801466:	e8 cc fe ff ff       	call   801337 <fsipc>
	//panic("devfile_write not implemented");
}
  80146b:	c9                   	leave  
  80146c:	c3                   	ret    

0080146d <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80146d:	55                   	push   %ebp
  80146e:	89 e5                	mov    %esp,%ebp
  801470:	56                   	push   %esi
  801471:	53                   	push   %ebx
  801472:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801475:	8b 45 08             	mov    0x8(%ebp),%eax
  801478:	8b 40 0c             	mov    0xc(%eax),%eax
  80147b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801480:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801486:	ba 00 00 00 00       	mov    $0x0,%edx
  80148b:	b8 03 00 00 00       	mov    $0x3,%eax
  801490:	e8 a2 fe ff ff       	call   801337 <fsipc>
  801495:	89 c3                	mov    %eax,%ebx
  801497:	85 c0                	test   %eax,%eax
  801499:	78 4b                	js     8014e6 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80149b:	39 c6                	cmp    %eax,%esi
  80149d:	73 16                	jae    8014b5 <devfile_read+0x48>
  80149f:	68 dc 26 80 00       	push   $0x8026dc
  8014a4:	68 e3 26 80 00       	push   $0x8026e3
  8014a9:	6a 7c                	push   $0x7c
  8014ab:	68 f8 26 80 00       	push   $0x8026f8
  8014b0:	e8 24 0a 00 00       	call   801ed9 <_panic>
	assert(r <= PGSIZE);
  8014b5:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014ba:	7e 16                	jle    8014d2 <devfile_read+0x65>
  8014bc:	68 03 27 80 00       	push   $0x802703
  8014c1:	68 e3 26 80 00       	push   $0x8026e3
  8014c6:	6a 7d                	push   $0x7d
  8014c8:	68 f8 26 80 00       	push   $0x8026f8
  8014cd:	e8 07 0a 00 00       	call   801ed9 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014d2:	83 ec 04             	sub    $0x4,%esp
  8014d5:	50                   	push   %eax
  8014d6:	68 00 50 80 00       	push   $0x805000
  8014db:	ff 75 0c             	pushl  0xc(%ebp)
  8014de:	e8 04 f4 ff ff       	call   8008e7 <memmove>
	return r;
  8014e3:	83 c4 10             	add    $0x10,%esp
}
  8014e6:	89 d8                	mov    %ebx,%eax
  8014e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014eb:	5b                   	pop    %ebx
  8014ec:	5e                   	pop    %esi
  8014ed:	5d                   	pop    %ebp
  8014ee:	c3                   	ret    

008014ef <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014ef:	55                   	push   %ebp
  8014f0:	89 e5                	mov    %esp,%ebp
  8014f2:	53                   	push   %ebx
  8014f3:	83 ec 20             	sub    $0x20,%esp
  8014f6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014f9:	53                   	push   %ebx
  8014fa:	e8 1d f2 ff ff       	call   80071c <strlen>
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801507:	7f 67                	jg     801570 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801509:	83 ec 0c             	sub    $0xc,%esp
  80150c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150f:	50                   	push   %eax
  801510:	e8 9a f8 ff ff       	call   800daf <fd_alloc>
  801515:	83 c4 10             	add    $0x10,%esp
		return r;
  801518:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80151a:	85 c0                	test   %eax,%eax
  80151c:	78 57                	js     801575 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  80151e:	83 ec 08             	sub    $0x8,%esp
  801521:	53                   	push   %ebx
  801522:	68 00 50 80 00       	push   $0x805000
  801527:	e8 29 f2 ff ff       	call   800755 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80152c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80152f:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801534:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801537:	b8 01 00 00 00       	mov    $0x1,%eax
  80153c:	e8 f6 fd ff ff       	call   801337 <fsipc>
  801541:	89 c3                	mov    %eax,%ebx
  801543:	83 c4 10             	add    $0x10,%esp
  801546:	85 c0                	test   %eax,%eax
  801548:	79 14                	jns    80155e <open+0x6f>
		fd_close(fd, 0);
  80154a:	83 ec 08             	sub    $0x8,%esp
  80154d:	6a 00                	push   $0x0
  80154f:	ff 75 f4             	pushl  -0xc(%ebp)
  801552:	e8 50 f9 ff ff       	call   800ea7 <fd_close>
		return r;
  801557:	83 c4 10             	add    $0x10,%esp
  80155a:	89 da                	mov    %ebx,%edx
  80155c:	eb 17                	jmp    801575 <open+0x86>
	}

	return fd2num(fd);
  80155e:	83 ec 0c             	sub    $0xc,%esp
  801561:	ff 75 f4             	pushl  -0xc(%ebp)
  801564:	e8 1f f8 ff ff       	call   800d88 <fd2num>
  801569:	89 c2                	mov    %eax,%edx
  80156b:	83 c4 10             	add    $0x10,%esp
  80156e:	eb 05                	jmp    801575 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801570:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801575:	89 d0                	mov    %edx,%eax
  801577:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157a:	c9                   	leave  
  80157b:	c3                   	ret    

0080157c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801582:	ba 00 00 00 00       	mov    $0x0,%edx
  801587:	b8 08 00 00 00       	mov    $0x8,%eax
  80158c:	e8 a6 fd ff ff       	call   801337 <fsipc>
}
  801591:	c9                   	leave  
  801592:	c3                   	ret    

00801593 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801593:	55                   	push   %ebp
  801594:	89 e5                	mov    %esp,%ebp
  801596:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801599:	68 0f 27 80 00       	push   $0x80270f
  80159e:	ff 75 0c             	pushl  0xc(%ebp)
  8015a1:	e8 af f1 ff ff       	call   800755 <strcpy>
	return 0;
}
  8015a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ab:	c9                   	leave  
  8015ac:	c3                   	ret    

008015ad <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	53                   	push   %ebx
  8015b1:	83 ec 10             	sub    $0x10,%esp
  8015b4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8015b7:	53                   	push   %ebx
  8015b8:	e8 58 0a 00 00       	call   802015 <pageref>
  8015bd:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8015c0:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8015c5:	83 f8 01             	cmp    $0x1,%eax
  8015c8:	75 10                	jne    8015da <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8015ca:	83 ec 0c             	sub    $0xc,%esp
  8015cd:	ff 73 0c             	pushl  0xc(%ebx)
  8015d0:	e8 c0 02 00 00       	call   801895 <nsipc_close>
  8015d5:	89 c2                	mov    %eax,%edx
  8015d7:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8015da:	89 d0                	mov    %edx,%eax
  8015dc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015df:	c9                   	leave  
  8015e0:	c3                   	ret    

008015e1 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015e7:	6a 00                	push   $0x0
  8015e9:	ff 75 10             	pushl  0x10(%ebp)
  8015ec:	ff 75 0c             	pushl  0xc(%ebp)
  8015ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f2:	ff 70 0c             	pushl  0xc(%eax)
  8015f5:	e8 78 03 00 00       	call   801972 <nsipc_send>
}
  8015fa:	c9                   	leave  
  8015fb:	c3                   	ret    

008015fc <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8015fc:	55                   	push   %ebp
  8015fd:	89 e5                	mov    %esp,%ebp
  8015ff:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801602:	6a 00                	push   $0x0
  801604:	ff 75 10             	pushl  0x10(%ebp)
  801607:	ff 75 0c             	pushl  0xc(%ebp)
  80160a:	8b 45 08             	mov    0x8(%ebp),%eax
  80160d:	ff 70 0c             	pushl  0xc(%eax)
  801610:	e8 f1 02 00 00       	call   801906 <nsipc_recv>
}
  801615:	c9                   	leave  
  801616:	c3                   	ret    

00801617 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801617:	55                   	push   %ebp
  801618:	89 e5                	mov    %esp,%ebp
  80161a:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80161d:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801620:	52                   	push   %edx
  801621:	50                   	push   %eax
  801622:	e8 d7 f7 ff ff       	call   800dfe <fd_lookup>
  801627:	83 c4 10             	add    $0x10,%esp
  80162a:	85 c0                	test   %eax,%eax
  80162c:	78 17                	js     801645 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  80162e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801631:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801637:	39 08                	cmp    %ecx,(%eax)
  801639:	75 05                	jne    801640 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80163b:	8b 40 0c             	mov    0xc(%eax),%eax
  80163e:	eb 05                	jmp    801645 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801640:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801645:	c9                   	leave  
  801646:	c3                   	ret    

00801647 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	56                   	push   %esi
  80164b:	53                   	push   %ebx
  80164c:	83 ec 1c             	sub    $0x1c,%esp
  80164f:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801651:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801654:	50                   	push   %eax
  801655:	e8 55 f7 ff ff       	call   800daf <fd_alloc>
  80165a:	89 c3                	mov    %eax,%ebx
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	85 c0                	test   %eax,%eax
  801661:	78 1b                	js     80167e <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801663:	83 ec 04             	sub    $0x4,%esp
  801666:	68 07 04 00 00       	push   $0x407
  80166b:	ff 75 f4             	pushl  -0xc(%ebp)
  80166e:	6a 00                	push   $0x0
  801670:	e8 e3 f4 ff ff       	call   800b58 <sys_page_alloc>
  801675:	89 c3                	mov    %eax,%ebx
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	85 c0                	test   %eax,%eax
  80167c:	79 10                	jns    80168e <alloc_sockfd+0x47>
		nsipc_close(sockid);
  80167e:	83 ec 0c             	sub    $0xc,%esp
  801681:	56                   	push   %esi
  801682:	e8 0e 02 00 00       	call   801895 <nsipc_close>
		return r;
  801687:	83 c4 10             	add    $0x10,%esp
  80168a:	89 d8                	mov    %ebx,%eax
  80168c:	eb 24                	jmp    8016b2 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  80168e:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801694:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801697:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801699:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8016a3:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8016a6:	83 ec 0c             	sub    $0xc,%esp
  8016a9:	50                   	push   %eax
  8016aa:	e8 d9 f6 ff ff       	call   800d88 <fd2num>
  8016af:	83 c4 10             	add    $0x10,%esp
}
  8016b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b5:	5b                   	pop    %ebx
  8016b6:	5e                   	pop    %esi
  8016b7:	5d                   	pop    %ebp
  8016b8:	c3                   	ret    

008016b9 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c2:	e8 50 ff ff ff       	call   801617 <fd2sockid>
		return r;
  8016c7:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016c9:	85 c0                	test   %eax,%eax
  8016cb:	78 1f                	js     8016ec <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016cd:	83 ec 04             	sub    $0x4,%esp
  8016d0:	ff 75 10             	pushl  0x10(%ebp)
  8016d3:	ff 75 0c             	pushl  0xc(%ebp)
  8016d6:	50                   	push   %eax
  8016d7:	e8 12 01 00 00       	call   8017ee <nsipc_accept>
  8016dc:	83 c4 10             	add    $0x10,%esp
		return r;
  8016df:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016e1:	85 c0                	test   %eax,%eax
  8016e3:	78 07                	js     8016ec <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8016e5:	e8 5d ff ff ff       	call   801647 <alloc_sockfd>
  8016ea:	89 c1                	mov    %eax,%ecx
}
  8016ec:	89 c8                	mov    %ecx,%eax
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    

008016f0 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016f9:	e8 19 ff ff ff       	call   801617 <fd2sockid>
  8016fe:	85 c0                	test   %eax,%eax
  801700:	78 12                	js     801714 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801702:	83 ec 04             	sub    $0x4,%esp
  801705:	ff 75 10             	pushl  0x10(%ebp)
  801708:	ff 75 0c             	pushl  0xc(%ebp)
  80170b:	50                   	push   %eax
  80170c:	e8 2d 01 00 00       	call   80183e <nsipc_bind>
  801711:	83 c4 10             	add    $0x10,%esp
}
  801714:	c9                   	leave  
  801715:	c3                   	ret    

00801716 <shutdown>:

int
shutdown(int s, int how)
{
  801716:	55                   	push   %ebp
  801717:	89 e5                	mov    %esp,%ebp
  801719:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80171c:	8b 45 08             	mov    0x8(%ebp),%eax
  80171f:	e8 f3 fe ff ff       	call   801617 <fd2sockid>
  801724:	85 c0                	test   %eax,%eax
  801726:	78 0f                	js     801737 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801728:	83 ec 08             	sub    $0x8,%esp
  80172b:	ff 75 0c             	pushl  0xc(%ebp)
  80172e:	50                   	push   %eax
  80172f:	e8 3f 01 00 00       	call   801873 <nsipc_shutdown>
  801734:	83 c4 10             	add    $0x10,%esp
}
  801737:	c9                   	leave  
  801738:	c3                   	ret    

00801739 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801739:	55                   	push   %ebp
  80173a:	89 e5                	mov    %esp,%ebp
  80173c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80173f:	8b 45 08             	mov    0x8(%ebp),%eax
  801742:	e8 d0 fe ff ff       	call   801617 <fd2sockid>
  801747:	85 c0                	test   %eax,%eax
  801749:	78 12                	js     80175d <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80174b:	83 ec 04             	sub    $0x4,%esp
  80174e:	ff 75 10             	pushl  0x10(%ebp)
  801751:	ff 75 0c             	pushl  0xc(%ebp)
  801754:	50                   	push   %eax
  801755:	e8 55 01 00 00       	call   8018af <nsipc_connect>
  80175a:	83 c4 10             	add    $0x10,%esp
}
  80175d:	c9                   	leave  
  80175e:	c3                   	ret    

0080175f <listen>:

int
listen(int s, int backlog)
{
  80175f:	55                   	push   %ebp
  801760:	89 e5                	mov    %esp,%ebp
  801762:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801765:	8b 45 08             	mov    0x8(%ebp),%eax
  801768:	e8 aa fe ff ff       	call   801617 <fd2sockid>
  80176d:	85 c0                	test   %eax,%eax
  80176f:	78 0f                	js     801780 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801771:	83 ec 08             	sub    $0x8,%esp
  801774:	ff 75 0c             	pushl  0xc(%ebp)
  801777:	50                   	push   %eax
  801778:	e8 67 01 00 00       	call   8018e4 <nsipc_listen>
  80177d:	83 c4 10             	add    $0x10,%esp
}
  801780:	c9                   	leave  
  801781:	c3                   	ret    

00801782 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801782:	55                   	push   %ebp
  801783:	89 e5                	mov    %esp,%ebp
  801785:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801788:	ff 75 10             	pushl  0x10(%ebp)
  80178b:	ff 75 0c             	pushl  0xc(%ebp)
  80178e:	ff 75 08             	pushl  0x8(%ebp)
  801791:	e8 3a 02 00 00       	call   8019d0 <nsipc_socket>
  801796:	83 c4 10             	add    $0x10,%esp
  801799:	85 c0                	test   %eax,%eax
  80179b:	78 05                	js     8017a2 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80179d:	e8 a5 fe ff ff       	call   801647 <alloc_sockfd>
}
  8017a2:	c9                   	leave  
  8017a3:	c3                   	ret    

008017a4 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8017a4:	55                   	push   %ebp
  8017a5:	89 e5                	mov    %esp,%ebp
  8017a7:	53                   	push   %ebx
  8017a8:	83 ec 04             	sub    $0x4,%esp
  8017ab:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8017ad:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8017b4:	75 12                	jne    8017c8 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017b6:	83 ec 0c             	sub    $0xc,%esp
  8017b9:	6a 02                	push   $0x2
  8017bb:	e8 1c 08 00 00       	call   801fdc <ipc_find_env>
  8017c0:	a3 04 40 80 00       	mov    %eax,0x804004
  8017c5:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8017c8:	6a 07                	push   $0x7
  8017ca:	68 00 60 80 00       	push   $0x806000
  8017cf:	53                   	push   %ebx
  8017d0:	ff 35 04 40 80 00    	pushl  0x804004
  8017d6:	e8 ad 07 00 00       	call   801f88 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017db:	83 c4 0c             	add    $0xc,%esp
  8017de:	6a 00                	push   $0x0
  8017e0:	6a 00                	push   $0x0
  8017e2:	6a 00                	push   $0x0
  8017e4:	e8 36 07 00 00       	call   801f1f <ipc_recv>
}
  8017e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ec:	c9                   	leave  
  8017ed:	c3                   	ret    

008017ee <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	56                   	push   %esi
  8017f2:	53                   	push   %ebx
  8017f3:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8017f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8017fe:	8b 06                	mov    (%esi),%eax
  801800:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801805:	b8 01 00 00 00       	mov    $0x1,%eax
  80180a:	e8 95 ff ff ff       	call   8017a4 <nsipc>
  80180f:	89 c3                	mov    %eax,%ebx
  801811:	85 c0                	test   %eax,%eax
  801813:	78 20                	js     801835 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801815:	83 ec 04             	sub    $0x4,%esp
  801818:	ff 35 10 60 80 00    	pushl  0x806010
  80181e:	68 00 60 80 00       	push   $0x806000
  801823:	ff 75 0c             	pushl  0xc(%ebp)
  801826:	e8 bc f0 ff ff       	call   8008e7 <memmove>
		*addrlen = ret->ret_addrlen;
  80182b:	a1 10 60 80 00       	mov    0x806010,%eax
  801830:	89 06                	mov    %eax,(%esi)
  801832:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801835:	89 d8                	mov    %ebx,%eax
  801837:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80183a:	5b                   	pop    %ebx
  80183b:	5e                   	pop    %esi
  80183c:	5d                   	pop    %ebp
  80183d:	c3                   	ret    

0080183e <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	53                   	push   %ebx
  801842:	83 ec 08             	sub    $0x8,%esp
  801845:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801848:	8b 45 08             	mov    0x8(%ebp),%eax
  80184b:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801850:	53                   	push   %ebx
  801851:	ff 75 0c             	pushl  0xc(%ebp)
  801854:	68 04 60 80 00       	push   $0x806004
  801859:	e8 89 f0 ff ff       	call   8008e7 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  80185e:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801864:	b8 02 00 00 00       	mov    $0x2,%eax
  801869:	e8 36 ff ff ff       	call   8017a4 <nsipc>
}
  80186e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801871:	c9                   	leave  
  801872:	c3                   	ret    

00801873 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801879:	8b 45 08             	mov    0x8(%ebp),%eax
  80187c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801881:	8b 45 0c             	mov    0xc(%ebp),%eax
  801884:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801889:	b8 03 00 00 00       	mov    $0x3,%eax
  80188e:	e8 11 ff ff ff       	call   8017a4 <nsipc>
}
  801893:	c9                   	leave  
  801894:	c3                   	ret    

00801895 <nsipc_close>:

int
nsipc_close(int s)
{
  801895:	55                   	push   %ebp
  801896:	89 e5                	mov    %esp,%ebp
  801898:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80189b:	8b 45 08             	mov    0x8(%ebp),%eax
  80189e:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8018a3:	b8 04 00 00 00       	mov    $0x4,%eax
  8018a8:	e8 f7 fe ff ff       	call   8017a4 <nsipc>
}
  8018ad:	c9                   	leave  
  8018ae:	c3                   	ret    

008018af <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8018af:	55                   	push   %ebp
  8018b0:	89 e5                	mov    %esp,%ebp
  8018b2:	53                   	push   %ebx
  8018b3:	83 ec 08             	sub    $0x8,%esp
  8018b6:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8018b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018bc:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8018c1:	53                   	push   %ebx
  8018c2:	ff 75 0c             	pushl  0xc(%ebp)
  8018c5:	68 04 60 80 00       	push   $0x806004
  8018ca:	e8 18 f0 ff ff       	call   8008e7 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8018cf:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8018d5:	b8 05 00 00 00       	mov    $0x5,%eax
  8018da:	e8 c5 fe ff ff       	call   8017a4 <nsipc>
}
  8018df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e2:	c9                   	leave  
  8018e3:	c3                   	ret    

008018e4 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ed:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8018f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f5:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8018fa:	b8 06 00 00 00       	mov    $0x6,%eax
  8018ff:	e8 a0 fe ff ff       	call   8017a4 <nsipc>
}
  801904:	c9                   	leave  
  801905:	c3                   	ret    

00801906 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801906:	55                   	push   %ebp
  801907:	89 e5                	mov    %esp,%ebp
  801909:	56                   	push   %esi
  80190a:	53                   	push   %ebx
  80190b:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  80190e:	8b 45 08             	mov    0x8(%ebp),%eax
  801911:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801916:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80191c:	8b 45 14             	mov    0x14(%ebp),%eax
  80191f:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801924:	b8 07 00 00 00       	mov    $0x7,%eax
  801929:	e8 76 fe ff ff       	call   8017a4 <nsipc>
  80192e:	89 c3                	mov    %eax,%ebx
  801930:	85 c0                	test   %eax,%eax
  801932:	78 35                	js     801969 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801934:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801939:	7f 04                	jg     80193f <nsipc_recv+0x39>
  80193b:	39 c6                	cmp    %eax,%esi
  80193d:	7d 16                	jge    801955 <nsipc_recv+0x4f>
  80193f:	68 1b 27 80 00       	push   $0x80271b
  801944:	68 e3 26 80 00       	push   $0x8026e3
  801949:	6a 62                	push   $0x62
  80194b:	68 30 27 80 00       	push   $0x802730
  801950:	e8 84 05 00 00       	call   801ed9 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801955:	83 ec 04             	sub    $0x4,%esp
  801958:	50                   	push   %eax
  801959:	68 00 60 80 00       	push   $0x806000
  80195e:	ff 75 0c             	pushl  0xc(%ebp)
  801961:	e8 81 ef ff ff       	call   8008e7 <memmove>
  801966:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801969:	89 d8                	mov    %ebx,%eax
  80196b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80196e:	5b                   	pop    %ebx
  80196f:	5e                   	pop    %esi
  801970:	5d                   	pop    %ebp
  801971:	c3                   	ret    

00801972 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801972:	55                   	push   %ebp
  801973:	89 e5                	mov    %esp,%ebp
  801975:	53                   	push   %ebx
  801976:	83 ec 04             	sub    $0x4,%esp
  801979:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80197c:	8b 45 08             	mov    0x8(%ebp),%eax
  80197f:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801984:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80198a:	7e 16                	jle    8019a2 <nsipc_send+0x30>
  80198c:	68 3c 27 80 00       	push   $0x80273c
  801991:	68 e3 26 80 00       	push   $0x8026e3
  801996:	6a 6d                	push   $0x6d
  801998:	68 30 27 80 00       	push   $0x802730
  80199d:	e8 37 05 00 00       	call   801ed9 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8019a2:	83 ec 04             	sub    $0x4,%esp
  8019a5:	53                   	push   %ebx
  8019a6:	ff 75 0c             	pushl  0xc(%ebp)
  8019a9:	68 0c 60 80 00       	push   $0x80600c
  8019ae:	e8 34 ef ff ff       	call   8008e7 <memmove>
	nsipcbuf.send.req_size = size;
  8019b3:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8019b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8019bc:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8019c1:	b8 08 00 00 00       	mov    $0x8,%eax
  8019c6:	e8 d9 fd ff ff       	call   8017a4 <nsipc>
}
  8019cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019ce:	c9                   	leave  
  8019cf:	c3                   	ret    

008019d0 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019d0:	55                   	push   %ebp
  8019d1:	89 e5                	mov    %esp,%ebp
  8019d3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d9:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8019de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e1:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8019e6:	8b 45 10             	mov    0x10(%ebp),%eax
  8019e9:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8019ee:	b8 09 00 00 00       	mov    $0x9,%eax
  8019f3:	e8 ac fd ff ff       	call   8017a4 <nsipc>
}
  8019f8:	c9                   	leave  
  8019f9:	c3                   	ret    

008019fa <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019fa:	55                   	push   %ebp
  8019fb:	89 e5                	mov    %esp,%ebp
  8019fd:	56                   	push   %esi
  8019fe:	53                   	push   %ebx
  8019ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a02:	83 ec 0c             	sub    $0xc,%esp
  801a05:	ff 75 08             	pushl  0x8(%ebp)
  801a08:	e8 8b f3 ff ff       	call   800d98 <fd2data>
  801a0d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a0f:	83 c4 08             	add    $0x8,%esp
  801a12:	68 48 27 80 00       	push   $0x802748
  801a17:	53                   	push   %ebx
  801a18:	e8 38 ed ff ff       	call   800755 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a1d:	8b 46 04             	mov    0x4(%esi),%eax
  801a20:	2b 06                	sub    (%esi),%eax
  801a22:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a28:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a2f:	00 00 00 
	stat->st_dev = &devpipe;
  801a32:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a39:	30 80 00 
	return 0;
}
  801a3c:	b8 00 00 00 00       	mov    $0x0,%eax
  801a41:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a44:	5b                   	pop    %ebx
  801a45:	5e                   	pop    %esi
  801a46:	5d                   	pop    %ebp
  801a47:	c3                   	ret    

00801a48 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a48:	55                   	push   %ebp
  801a49:	89 e5                	mov    %esp,%ebp
  801a4b:	53                   	push   %ebx
  801a4c:	83 ec 0c             	sub    $0xc,%esp
  801a4f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a52:	53                   	push   %ebx
  801a53:	6a 00                	push   $0x0
  801a55:	e8 83 f1 ff ff       	call   800bdd <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a5a:	89 1c 24             	mov    %ebx,(%esp)
  801a5d:	e8 36 f3 ff ff       	call   800d98 <fd2data>
  801a62:	83 c4 08             	add    $0x8,%esp
  801a65:	50                   	push   %eax
  801a66:	6a 00                	push   $0x0
  801a68:	e8 70 f1 ff ff       	call   800bdd <sys_page_unmap>
}
  801a6d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a70:	c9                   	leave  
  801a71:	c3                   	ret    

00801a72 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a72:	55                   	push   %ebp
  801a73:	89 e5                	mov    %esp,%ebp
  801a75:	57                   	push   %edi
  801a76:	56                   	push   %esi
  801a77:	53                   	push   %ebx
  801a78:	83 ec 1c             	sub    $0x1c,%esp
  801a7b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a7e:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a80:	a1 08 40 80 00       	mov    0x804008,%eax
  801a85:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a88:	83 ec 0c             	sub    $0xc,%esp
  801a8b:	ff 75 e0             	pushl  -0x20(%ebp)
  801a8e:	e8 82 05 00 00       	call   802015 <pageref>
  801a93:	89 c3                	mov    %eax,%ebx
  801a95:	89 3c 24             	mov    %edi,(%esp)
  801a98:	e8 78 05 00 00       	call   802015 <pageref>
  801a9d:	83 c4 10             	add    $0x10,%esp
  801aa0:	39 c3                	cmp    %eax,%ebx
  801aa2:	0f 94 c1             	sete   %cl
  801aa5:	0f b6 c9             	movzbl %cl,%ecx
  801aa8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801aab:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ab1:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ab4:	39 ce                	cmp    %ecx,%esi
  801ab6:	74 1b                	je     801ad3 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ab8:	39 c3                	cmp    %eax,%ebx
  801aba:	75 c4                	jne    801a80 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801abc:	8b 42 58             	mov    0x58(%edx),%eax
  801abf:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ac2:	50                   	push   %eax
  801ac3:	56                   	push   %esi
  801ac4:	68 4f 27 80 00       	push   $0x80274f
  801ac9:	e8 83 e6 ff ff       	call   800151 <cprintf>
  801ace:	83 c4 10             	add    $0x10,%esp
  801ad1:	eb ad                	jmp    801a80 <_pipeisclosed+0xe>
	}
}
  801ad3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ad6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad9:	5b                   	pop    %ebx
  801ada:	5e                   	pop    %esi
  801adb:	5f                   	pop    %edi
  801adc:	5d                   	pop    %ebp
  801add:	c3                   	ret    

00801ade <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ade:	55                   	push   %ebp
  801adf:	89 e5                	mov    %esp,%ebp
  801ae1:	57                   	push   %edi
  801ae2:	56                   	push   %esi
  801ae3:	53                   	push   %ebx
  801ae4:	83 ec 28             	sub    $0x28,%esp
  801ae7:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801aea:	56                   	push   %esi
  801aeb:	e8 a8 f2 ff ff       	call   800d98 <fd2data>
  801af0:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af2:	83 c4 10             	add    $0x10,%esp
  801af5:	bf 00 00 00 00       	mov    $0x0,%edi
  801afa:	eb 4b                	jmp    801b47 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801afc:	89 da                	mov    %ebx,%edx
  801afe:	89 f0                	mov    %esi,%eax
  801b00:	e8 6d ff ff ff       	call   801a72 <_pipeisclosed>
  801b05:	85 c0                	test   %eax,%eax
  801b07:	75 48                	jne    801b51 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b09:	e8 2b f0 ff ff       	call   800b39 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b0e:	8b 43 04             	mov    0x4(%ebx),%eax
  801b11:	8b 0b                	mov    (%ebx),%ecx
  801b13:	8d 51 20             	lea    0x20(%ecx),%edx
  801b16:	39 d0                	cmp    %edx,%eax
  801b18:	73 e2                	jae    801afc <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b1a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b1d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b21:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b24:	89 c2                	mov    %eax,%edx
  801b26:	c1 fa 1f             	sar    $0x1f,%edx
  801b29:	89 d1                	mov    %edx,%ecx
  801b2b:	c1 e9 1b             	shr    $0x1b,%ecx
  801b2e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b31:	83 e2 1f             	and    $0x1f,%edx
  801b34:	29 ca                	sub    %ecx,%edx
  801b36:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b3a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b3e:	83 c0 01             	add    $0x1,%eax
  801b41:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b44:	83 c7 01             	add    $0x1,%edi
  801b47:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b4a:	75 c2                	jne    801b0e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b4c:	8b 45 10             	mov    0x10(%ebp),%eax
  801b4f:	eb 05                	jmp    801b56 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b51:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5f                   	pop    %edi
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    

00801b5e <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	57                   	push   %edi
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	83 ec 18             	sub    $0x18,%esp
  801b67:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b6a:	57                   	push   %edi
  801b6b:	e8 28 f2 ff ff       	call   800d98 <fd2data>
  801b70:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b72:	83 c4 10             	add    $0x10,%esp
  801b75:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b7a:	eb 3d                	jmp    801bb9 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b7c:	85 db                	test   %ebx,%ebx
  801b7e:	74 04                	je     801b84 <devpipe_read+0x26>
				return i;
  801b80:	89 d8                	mov    %ebx,%eax
  801b82:	eb 44                	jmp    801bc8 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b84:	89 f2                	mov    %esi,%edx
  801b86:	89 f8                	mov    %edi,%eax
  801b88:	e8 e5 fe ff ff       	call   801a72 <_pipeisclosed>
  801b8d:	85 c0                	test   %eax,%eax
  801b8f:	75 32                	jne    801bc3 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b91:	e8 a3 ef ff ff       	call   800b39 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b96:	8b 06                	mov    (%esi),%eax
  801b98:	3b 46 04             	cmp    0x4(%esi),%eax
  801b9b:	74 df                	je     801b7c <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b9d:	99                   	cltd   
  801b9e:	c1 ea 1b             	shr    $0x1b,%edx
  801ba1:	01 d0                	add    %edx,%eax
  801ba3:	83 e0 1f             	and    $0x1f,%eax
  801ba6:	29 d0                	sub    %edx,%eax
  801ba8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb0:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bb3:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb6:	83 c3 01             	add    $0x1,%ebx
  801bb9:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bbc:	75 d8                	jne    801b96 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bbe:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc1:	eb 05                	jmp    801bc8 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bc3:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bc8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcb:	5b                   	pop    %ebx
  801bcc:	5e                   	pop    %esi
  801bcd:	5f                   	pop    %edi
  801bce:	5d                   	pop    %ebp
  801bcf:	c3                   	ret    

00801bd0 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bd0:	55                   	push   %ebp
  801bd1:	89 e5                	mov    %esp,%ebp
  801bd3:	56                   	push   %esi
  801bd4:	53                   	push   %ebx
  801bd5:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdb:	50                   	push   %eax
  801bdc:	e8 ce f1 ff ff       	call   800daf <fd_alloc>
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	89 c2                	mov    %eax,%edx
  801be6:	85 c0                	test   %eax,%eax
  801be8:	0f 88 2c 01 00 00    	js     801d1a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bee:	83 ec 04             	sub    $0x4,%esp
  801bf1:	68 07 04 00 00       	push   $0x407
  801bf6:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf9:	6a 00                	push   $0x0
  801bfb:	e8 58 ef ff ff       	call   800b58 <sys_page_alloc>
  801c00:	83 c4 10             	add    $0x10,%esp
  801c03:	89 c2                	mov    %eax,%edx
  801c05:	85 c0                	test   %eax,%eax
  801c07:	0f 88 0d 01 00 00    	js     801d1a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c0d:	83 ec 0c             	sub    $0xc,%esp
  801c10:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c13:	50                   	push   %eax
  801c14:	e8 96 f1 ff ff       	call   800daf <fd_alloc>
  801c19:	89 c3                	mov    %eax,%ebx
  801c1b:	83 c4 10             	add    $0x10,%esp
  801c1e:	85 c0                	test   %eax,%eax
  801c20:	0f 88 e2 00 00 00    	js     801d08 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c26:	83 ec 04             	sub    $0x4,%esp
  801c29:	68 07 04 00 00       	push   $0x407
  801c2e:	ff 75 f0             	pushl  -0x10(%ebp)
  801c31:	6a 00                	push   $0x0
  801c33:	e8 20 ef ff ff       	call   800b58 <sys_page_alloc>
  801c38:	89 c3                	mov    %eax,%ebx
  801c3a:	83 c4 10             	add    $0x10,%esp
  801c3d:	85 c0                	test   %eax,%eax
  801c3f:	0f 88 c3 00 00 00    	js     801d08 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c45:	83 ec 0c             	sub    $0xc,%esp
  801c48:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4b:	e8 48 f1 ff ff       	call   800d98 <fd2data>
  801c50:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c52:	83 c4 0c             	add    $0xc,%esp
  801c55:	68 07 04 00 00       	push   $0x407
  801c5a:	50                   	push   %eax
  801c5b:	6a 00                	push   $0x0
  801c5d:	e8 f6 ee ff ff       	call   800b58 <sys_page_alloc>
  801c62:	89 c3                	mov    %eax,%ebx
  801c64:	83 c4 10             	add    $0x10,%esp
  801c67:	85 c0                	test   %eax,%eax
  801c69:	0f 88 89 00 00 00    	js     801cf8 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c6f:	83 ec 0c             	sub    $0xc,%esp
  801c72:	ff 75 f0             	pushl  -0x10(%ebp)
  801c75:	e8 1e f1 ff ff       	call   800d98 <fd2data>
  801c7a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c81:	50                   	push   %eax
  801c82:	6a 00                	push   $0x0
  801c84:	56                   	push   %esi
  801c85:	6a 00                	push   $0x0
  801c87:	e8 0f ef ff ff       	call   800b9b <sys_page_map>
  801c8c:	89 c3                	mov    %eax,%ebx
  801c8e:	83 c4 20             	add    $0x20,%esp
  801c91:	85 c0                	test   %eax,%eax
  801c93:	78 55                	js     801cea <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c95:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9e:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ca0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801caa:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cb0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb3:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cb5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb8:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cbf:	83 ec 0c             	sub    $0xc,%esp
  801cc2:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc5:	e8 be f0 ff ff       	call   800d88 <fd2num>
  801cca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ccd:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ccf:	83 c4 04             	add    $0x4,%esp
  801cd2:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd5:	e8 ae f0 ff ff       	call   800d88 <fd2num>
  801cda:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cdd:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ce0:	83 c4 10             	add    $0x10,%esp
  801ce3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce8:	eb 30                	jmp    801d1a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cea:	83 ec 08             	sub    $0x8,%esp
  801ced:	56                   	push   %esi
  801cee:	6a 00                	push   $0x0
  801cf0:	e8 e8 ee ff ff       	call   800bdd <sys_page_unmap>
  801cf5:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cf8:	83 ec 08             	sub    $0x8,%esp
  801cfb:	ff 75 f0             	pushl  -0x10(%ebp)
  801cfe:	6a 00                	push   $0x0
  801d00:	e8 d8 ee ff ff       	call   800bdd <sys_page_unmap>
  801d05:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d08:	83 ec 08             	sub    $0x8,%esp
  801d0b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d0e:	6a 00                	push   $0x0
  801d10:	e8 c8 ee ff ff       	call   800bdd <sys_page_unmap>
  801d15:	83 c4 10             	add    $0x10,%esp
  801d18:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d1a:	89 d0                	mov    %edx,%eax
  801d1c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d1f:	5b                   	pop    %ebx
  801d20:	5e                   	pop    %esi
  801d21:	5d                   	pop    %ebp
  801d22:	c3                   	ret    

00801d23 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d23:	55                   	push   %ebp
  801d24:	89 e5                	mov    %esp,%ebp
  801d26:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d29:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2c:	50                   	push   %eax
  801d2d:	ff 75 08             	pushl  0x8(%ebp)
  801d30:	e8 c9 f0 ff ff       	call   800dfe <fd_lookup>
  801d35:	83 c4 10             	add    $0x10,%esp
  801d38:	85 c0                	test   %eax,%eax
  801d3a:	78 18                	js     801d54 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d3c:	83 ec 0c             	sub    $0xc,%esp
  801d3f:	ff 75 f4             	pushl  -0xc(%ebp)
  801d42:	e8 51 f0 ff ff       	call   800d98 <fd2data>
	return _pipeisclosed(fd, p);
  801d47:	89 c2                	mov    %eax,%edx
  801d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4c:	e8 21 fd ff ff       	call   801a72 <_pipeisclosed>
  801d51:	83 c4 10             	add    $0x10,%esp
}
  801d54:	c9                   	leave  
  801d55:	c3                   	ret    

00801d56 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d56:	55                   	push   %ebp
  801d57:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d59:	b8 00 00 00 00       	mov    $0x0,%eax
  801d5e:	5d                   	pop    %ebp
  801d5f:	c3                   	ret    

00801d60 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d60:	55                   	push   %ebp
  801d61:	89 e5                	mov    %esp,%ebp
  801d63:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d66:	68 67 27 80 00       	push   $0x802767
  801d6b:	ff 75 0c             	pushl  0xc(%ebp)
  801d6e:	e8 e2 e9 ff ff       	call   800755 <strcpy>
	return 0;
}
  801d73:	b8 00 00 00 00       	mov    $0x0,%eax
  801d78:	c9                   	leave  
  801d79:	c3                   	ret    

00801d7a <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d7a:	55                   	push   %ebp
  801d7b:	89 e5                	mov    %esp,%ebp
  801d7d:	57                   	push   %edi
  801d7e:	56                   	push   %esi
  801d7f:	53                   	push   %ebx
  801d80:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d86:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d8b:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d91:	eb 2d                	jmp    801dc0 <devcons_write+0x46>
		m = n - tot;
  801d93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d96:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d98:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d9b:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801da0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801da3:	83 ec 04             	sub    $0x4,%esp
  801da6:	53                   	push   %ebx
  801da7:	03 45 0c             	add    0xc(%ebp),%eax
  801daa:	50                   	push   %eax
  801dab:	57                   	push   %edi
  801dac:	e8 36 eb ff ff       	call   8008e7 <memmove>
		sys_cputs(buf, m);
  801db1:	83 c4 08             	add    $0x8,%esp
  801db4:	53                   	push   %ebx
  801db5:	57                   	push   %edi
  801db6:	e8 e1 ec ff ff       	call   800a9c <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dbb:	01 de                	add    %ebx,%esi
  801dbd:	83 c4 10             	add    $0x10,%esp
  801dc0:	89 f0                	mov    %esi,%eax
  801dc2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dc5:	72 cc                	jb     801d93 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dc7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dca:	5b                   	pop    %ebx
  801dcb:	5e                   	pop    %esi
  801dcc:	5f                   	pop    %edi
  801dcd:	5d                   	pop    %ebp
  801dce:	c3                   	ret    

00801dcf <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dcf:	55                   	push   %ebp
  801dd0:	89 e5                	mov    %esp,%ebp
  801dd2:	83 ec 08             	sub    $0x8,%esp
  801dd5:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801dda:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801dde:	74 2a                	je     801e0a <devcons_read+0x3b>
  801de0:	eb 05                	jmp    801de7 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801de2:	e8 52 ed ff ff       	call   800b39 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801de7:	e8 ce ec ff ff       	call   800aba <sys_cgetc>
  801dec:	85 c0                	test   %eax,%eax
  801dee:	74 f2                	je     801de2 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801df0:	85 c0                	test   %eax,%eax
  801df2:	78 16                	js     801e0a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801df4:	83 f8 04             	cmp    $0x4,%eax
  801df7:	74 0c                	je     801e05 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801df9:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dfc:	88 02                	mov    %al,(%edx)
	return 1;
  801dfe:	b8 01 00 00 00       	mov    $0x1,%eax
  801e03:	eb 05                	jmp    801e0a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e05:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e0a:	c9                   	leave  
  801e0b:	c3                   	ret    

00801e0c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801e0c:	55                   	push   %ebp
  801e0d:	89 e5                	mov    %esp,%ebp
  801e0f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e12:	8b 45 08             	mov    0x8(%ebp),%eax
  801e15:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e18:	6a 01                	push   $0x1
  801e1a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e1d:	50                   	push   %eax
  801e1e:	e8 79 ec ff ff       	call   800a9c <sys_cputs>
}
  801e23:	83 c4 10             	add    $0x10,%esp
  801e26:	c9                   	leave  
  801e27:	c3                   	ret    

00801e28 <getchar>:

int
getchar(void)
{
  801e28:	55                   	push   %ebp
  801e29:	89 e5                	mov    %esp,%ebp
  801e2b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e2e:	6a 01                	push   $0x1
  801e30:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e33:	50                   	push   %eax
  801e34:	6a 00                	push   $0x0
  801e36:	e8 29 f2 ff ff       	call   801064 <read>
	if (r < 0)
  801e3b:	83 c4 10             	add    $0x10,%esp
  801e3e:	85 c0                	test   %eax,%eax
  801e40:	78 0f                	js     801e51 <getchar+0x29>
		return r;
	if (r < 1)
  801e42:	85 c0                	test   %eax,%eax
  801e44:	7e 06                	jle    801e4c <getchar+0x24>
		return -E_EOF;
	return c;
  801e46:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e4a:	eb 05                	jmp    801e51 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e4c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e51:	c9                   	leave  
  801e52:	c3                   	ret    

00801e53 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e53:	55                   	push   %ebp
  801e54:	89 e5                	mov    %esp,%ebp
  801e56:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e59:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5c:	50                   	push   %eax
  801e5d:	ff 75 08             	pushl  0x8(%ebp)
  801e60:	e8 99 ef ff ff       	call   800dfe <fd_lookup>
  801e65:	83 c4 10             	add    $0x10,%esp
  801e68:	85 c0                	test   %eax,%eax
  801e6a:	78 11                	js     801e7d <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e6f:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e75:	39 10                	cmp    %edx,(%eax)
  801e77:	0f 94 c0             	sete   %al
  801e7a:	0f b6 c0             	movzbl %al,%eax
}
  801e7d:	c9                   	leave  
  801e7e:	c3                   	ret    

00801e7f <opencons>:

int
opencons(void)
{
  801e7f:	55                   	push   %ebp
  801e80:	89 e5                	mov    %esp,%ebp
  801e82:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e88:	50                   	push   %eax
  801e89:	e8 21 ef ff ff       	call   800daf <fd_alloc>
  801e8e:	83 c4 10             	add    $0x10,%esp
		return r;
  801e91:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e93:	85 c0                	test   %eax,%eax
  801e95:	78 3e                	js     801ed5 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e97:	83 ec 04             	sub    $0x4,%esp
  801e9a:	68 07 04 00 00       	push   $0x407
  801e9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea2:	6a 00                	push   $0x0
  801ea4:	e8 af ec ff ff       	call   800b58 <sys_page_alloc>
  801ea9:	83 c4 10             	add    $0x10,%esp
		return r;
  801eac:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eae:	85 c0                	test   %eax,%eax
  801eb0:	78 23                	js     801ed5 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eb2:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801eb8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ebd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ec7:	83 ec 0c             	sub    $0xc,%esp
  801eca:	50                   	push   %eax
  801ecb:	e8 b8 ee ff ff       	call   800d88 <fd2num>
  801ed0:	89 c2                	mov    %eax,%edx
  801ed2:	83 c4 10             	add    $0x10,%esp
}
  801ed5:	89 d0                	mov    %edx,%eax
  801ed7:	c9                   	leave  
  801ed8:	c3                   	ret    

00801ed9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801ed9:	55                   	push   %ebp
  801eda:	89 e5                	mov    %esp,%ebp
  801edc:	56                   	push   %esi
  801edd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ede:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ee1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ee7:	e8 2e ec ff ff       	call   800b1a <sys_getenvid>
  801eec:	83 ec 0c             	sub    $0xc,%esp
  801eef:	ff 75 0c             	pushl  0xc(%ebp)
  801ef2:	ff 75 08             	pushl  0x8(%ebp)
  801ef5:	56                   	push   %esi
  801ef6:	50                   	push   %eax
  801ef7:	68 74 27 80 00       	push   $0x802774
  801efc:	e8 50 e2 ff ff       	call   800151 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f01:	83 c4 18             	add    $0x18,%esp
  801f04:	53                   	push   %ebx
  801f05:	ff 75 10             	pushl  0x10(%ebp)
  801f08:	e8 f3 e1 ff ff       	call   800100 <vcprintf>
	cprintf("\n");
  801f0d:	c7 04 24 60 27 80 00 	movl   $0x802760,(%esp)
  801f14:	e8 38 e2 ff ff       	call   800151 <cprintf>
  801f19:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f1c:	cc                   	int3   
  801f1d:	eb fd                	jmp    801f1c <_panic+0x43>

00801f1f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f1f:	55                   	push   %ebp
  801f20:	89 e5                	mov    %esp,%ebp
  801f22:	56                   	push   %esi
  801f23:	53                   	push   %ebx
  801f24:	8b 75 08             	mov    0x8(%ebp),%esi
  801f27:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801f2d:	85 c0                	test   %eax,%eax
  801f2f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f34:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801f37:	83 ec 0c             	sub    $0xc,%esp
  801f3a:	50                   	push   %eax
  801f3b:	e8 c8 ed ff ff       	call   800d08 <sys_ipc_recv>
  801f40:	83 c4 10             	add    $0x10,%esp
  801f43:	85 c0                	test   %eax,%eax
  801f45:	79 16                	jns    801f5d <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801f47:	85 f6                	test   %esi,%esi
  801f49:	74 06                	je     801f51 <ipc_recv+0x32>
            *from_env_store = 0;
  801f4b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801f51:	85 db                	test   %ebx,%ebx
  801f53:	74 2c                	je     801f81 <ipc_recv+0x62>
            *perm_store = 0;
  801f55:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f5b:	eb 24                	jmp    801f81 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801f5d:	85 f6                	test   %esi,%esi
  801f5f:	74 0a                	je     801f6b <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801f61:	a1 08 40 80 00       	mov    0x804008,%eax
  801f66:	8b 40 74             	mov    0x74(%eax),%eax
  801f69:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801f6b:	85 db                	test   %ebx,%ebx
  801f6d:	74 0a                	je     801f79 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801f6f:	a1 08 40 80 00       	mov    0x804008,%eax
  801f74:	8b 40 78             	mov    0x78(%eax),%eax
  801f77:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801f79:	a1 08 40 80 00       	mov    0x804008,%eax
  801f7e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801f81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f84:	5b                   	pop    %ebx
  801f85:	5e                   	pop    %esi
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    

00801f88 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f88:	55                   	push   %ebp
  801f89:	89 e5                	mov    %esp,%ebp
  801f8b:	57                   	push   %edi
  801f8c:	56                   	push   %esi
  801f8d:	53                   	push   %ebx
  801f8e:	83 ec 0c             	sub    $0xc,%esp
  801f91:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f94:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f97:	8b 45 10             	mov    0x10(%ebp),%eax
  801f9a:	85 c0                	test   %eax,%eax
  801f9c:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801fa1:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801fa4:	eb 1c                	jmp    801fc2 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801fa6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fa9:	74 12                	je     801fbd <ipc_send+0x35>
  801fab:	50                   	push   %eax
  801fac:	68 98 27 80 00       	push   $0x802798
  801fb1:	6a 3b                	push   $0x3b
  801fb3:	68 ae 27 80 00       	push   $0x8027ae
  801fb8:	e8 1c ff ff ff       	call   801ed9 <_panic>
		sys_yield();
  801fbd:	e8 77 eb ff ff       	call   800b39 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801fc2:	ff 75 14             	pushl  0x14(%ebp)
  801fc5:	53                   	push   %ebx
  801fc6:	56                   	push   %esi
  801fc7:	57                   	push   %edi
  801fc8:	e8 18 ed ff ff       	call   800ce5 <sys_ipc_try_send>
  801fcd:	83 c4 10             	add    $0x10,%esp
  801fd0:	85 c0                	test   %eax,%eax
  801fd2:	78 d2                	js     801fa6 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801fd4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd7:	5b                   	pop    %ebx
  801fd8:	5e                   	pop    %esi
  801fd9:	5f                   	pop    %edi
  801fda:	5d                   	pop    %ebp
  801fdb:	c3                   	ret    

00801fdc <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fdc:	55                   	push   %ebp
  801fdd:	89 e5                	mov    %esp,%ebp
  801fdf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fe2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fe7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fea:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ff0:	8b 52 50             	mov    0x50(%edx),%edx
  801ff3:	39 ca                	cmp    %ecx,%edx
  801ff5:	75 0d                	jne    802004 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ff7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ffa:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fff:	8b 40 48             	mov    0x48(%eax),%eax
  802002:	eb 0f                	jmp    802013 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802004:	83 c0 01             	add    $0x1,%eax
  802007:	3d 00 04 00 00       	cmp    $0x400,%eax
  80200c:	75 d9                	jne    801fe7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80200e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802013:	5d                   	pop    %ebp
  802014:	c3                   	ret    

00802015 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802015:	55                   	push   %ebp
  802016:	89 e5                	mov    %esp,%ebp
  802018:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80201b:	89 d0                	mov    %edx,%eax
  80201d:	c1 e8 16             	shr    $0x16,%eax
  802020:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802027:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80202c:	f6 c1 01             	test   $0x1,%cl
  80202f:	74 1d                	je     80204e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802031:	c1 ea 0c             	shr    $0xc,%edx
  802034:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80203b:	f6 c2 01             	test   $0x1,%dl
  80203e:	74 0e                	je     80204e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802040:	c1 ea 0c             	shr    $0xc,%edx
  802043:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80204a:	ef 
  80204b:	0f b7 c0             	movzwl %ax,%eax
}
  80204e:	5d                   	pop    %ebp
  80204f:	c3                   	ret    

00802050 <__udivdi3>:
  802050:	55                   	push   %ebp
  802051:	57                   	push   %edi
  802052:	56                   	push   %esi
  802053:	53                   	push   %ebx
  802054:	83 ec 1c             	sub    $0x1c,%esp
  802057:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80205b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80205f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802063:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802067:	85 f6                	test   %esi,%esi
  802069:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80206d:	89 ca                	mov    %ecx,%edx
  80206f:	89 f8                	mov    %edi,%eax
  802071:	75 3d                	jne    8020b0 <__udivdi3+0x60>
  802073:	39 cf                	cmp    %ecx,%edi
  802075:	0f 87 c5 00 00 00    	ja     802140 <__udivdi3+0xf0>
  80207b:	85 ff                	test   %edi,%edi
  80207d:	89 fd                	mov    %edi,%ebp
  80207f:	75 0b                	jne    80208c <__udivdi3+0x3c>
  802081:	b8 01 00 00 00       	mov    $0x1,%eax
  802086:	31 d2                	xor    %edx,%edx
  802088:	f7 f7                	div    %edi
  80208a:	89 c5                	mov    %eax,%ebp
  80208c:	89 c8                	mov    %ecx,%eax
  80208e:	31 d2                	xor    %edx,%edx
  802090:	f7 f5                	div    %ebp
  802092:	89 c1                	mov    %eax,%ecx
  802094:	89 d8                	mov    %ebx,%eax
  802096:	89 cf                	mov    %ecx,%edi
  802098:	f7 f5                	div    %ebp
  80209a:	89 c3                	mov    %eax,%ebx
  80209c:	89 d8                	mov    %ebx,%eax
  80209e:	89 fa                	mov    %edi,%edx
  8020a0:	83 c4 1c             	add    $0x1c,%esp
  8020a3:	5b                   	pop    %ebx
  8020a4:	5e                   	pop    %esi
  8020a5:	5f                   	pop    %edi
  8020a6:	5d                   	pop    %ebp
  8020a7:	c3                   	ret    
  8020a8:	90                   	nop
  8020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020b0:	39 ce                	cmp    %ecx,%esi
  8020b2:	77 74                	ja     802128 <__udivdi3+0xd8>
  8020b4:	0f bd fe             	bsr    %esi,%edi
  8020b7:	83 f7 1f             	xor    $0x1f,%edi
  8020ba:	0f 84 98 00 00 00    	je     802158 <__udivdi3+0x108>
  8020c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020c5:	89 f9                	mov    %edi,%ecx
  8020c7:	89 c5                	mov    %eax,%ebp
  8020c9:	29 fb                	sub    %edi,%ebx
  8020cb:	d3 e6                	shl    %cl,%esi
  8020cd:	89 d9                	mov    %ebx,%ecx
  8020cf:	d3 ed                	shr    %cl,%ebp
  8020d1:	89 f9                	mov    %edi,%ecx
  8020d3:	d3 e0                	shl    %cl,%eax
  8020d5:	09 ee                	or     %ebp,%esi
  8020d7:	89 d9                	mov    %ebx,%ecx
  8020d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020dd:	89 d5                	mov    %edx,%ebp
  8020df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020e3:	d3 ed                	shr    %cl,%ebp
  8020e5:	89 f9                	mov    %edi,%ecx
  8020e7:	d3 e2                	shl    %cl,%edx
  8020e9:	89 d9                	mov    %ebx,%ecx
  8020eb:	d3 e8                	shr    %cl,%eax
  8020ed:	09 c2                	or     %eax,%edx
  8020ef:	89 d0                	mov    %edx,%eax
  8020f1:	89 ea                	mov    %ebp,%edx
  8020f3:	f7 f6                	div    %esi
  8020f5:	89 d5                	mov    %edx,%ebp
  8020f7:	89 c3                	mov    %eax,%ebx
  8020f9:	f7 64 24 0c          	mull   0xc(%esp)
  8020fd:	39 d5                	cmp    %edx,%ebp
  8020ff:	72 10                	jb     802111 <__udivdi3+0xc1>
  802101:	8b 74 24 08          	mov    0x8(%esp),%esi
  802105:	89 f9                	mov    %edi,%ecx
  802107:	d3 e6                	shl    %cl,%esi
  802109:	39 c6                	cmp    %eax,%esi
  80210b:	73 07                	jae    802114 <__udivdi3+0xc4>
  80210d:	39 d5                	cmp    %edx,%ebp
  80210f:	75 03                	jne    802114 <__udivdi3+0xc4>
  802111:	83 eb 01             	sub    $0x1,%ebx
  802114:	31 ff                	xor    %edi,%edi
  802116:	89 d8                	mov    %ebx,%eax
  802118:	89 fa                	mov    %edi,%edx
  80211a:	83 c4 1c             	add    $0x1c,%esp
  80211d:	5b                   	pop    %ebx
  80211e:	5e                   	pop    %esi
  80211f:	5f                   	pop    %edi
  802120:	5d                   	pop    %ebp
  802121:	c3                   	ret    
  802122:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802128:	31 ff                	xor    %edi,%edi
  80212a:	31 db                	xor    %ebx,%ebx
  80212c:	89 d8                	mov    %ebx,%eax
  80212e:	89 fa                	mov    %edi,%edx
  802130:	83 c4 1c             	add    $0x1c,%esp
  802133:	5b                   	pop    %ebx
  802134:	5e                   	pop    %esi
  802135:	5f                   	pop    %edi
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    
  802138:	90                   	nop
  802139:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802140:	89 d8                	mov    %ebx,%eax
  802142:	f7 f7                	div    %edi
  802144:	31 ff                	xor    %edi,%edi
  802146:	89 c3                	mov    %eax,%ebx
  802148:	89 d8                	mov    %ebx,%eax
  80214a:	89 fa                	mov    %edi,%edx
  80214c:	83 c4 1c             	add    $0x1c,%esp
  80214f:	5b                   	pop    %ebx
  802150:	5e                   	pop    %esi
  802151:	5f                   	pop    %edi
  802152:	5d                   	pop    %ebp
  802153:	c3                   	ret    
  802154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802158:	39 ce                	cmp    %ecx,%esi
  80215a:	72 0c                	jb     802168 <__udivdi3+0x118>
  80215c:	31 db                	xor    %ebx,%ebx
  80215e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802162:	0f 87 34 ff ff ff    	ja     80209c <__udivdi3+0x4c>
  802168:	bb 01 00 00 00       	mov    $0x1,%ebx
  80216d:	e9 2a ff ff ff       	jmp    80209c <__udivdi3+0x4c>
  802172:	66 90                	xchg   %ax,%ax
  802174:	66 90                	xchg   %ax,%ax
  802176:	66 90                	xchg   %ax,%ax
  802178:	66 90                	xchg   %ax,%ax
  80217a:	66 90                	xchg   %ax,%ax
  80217c:	66 90                	xchg   %ax,%ax
  80217e:	66 90                	xchg   %ax,%ax

00802180 <__umoddi3>:
  802180:	55                   	push   %ebp
  802181:	57                   	push   %edi
  802182:	56                   	push   %esi
  802183:	53                   	push   %ebx
  802184:	83 ec 1c             	sub    $0x1c,%esp
  802187:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80218b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80218f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802193:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802197:	85 d2                	test   %edx,%edx
  802199:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80219d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021a1:	89 f3                	mov    %esi,%ebx
  8021a3:	89 3c 24             	mov    %edi,(%esp)
  8021a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021aa:	75 1c                	jne    8021c8 <__umoddi3+0x48>
  8021ac:	39 f7                	cmp    %esi,%edi
  8021ae:	76 50                	jbe    802200 <__umoddi3+0x80>
  8021b0:	89 c8                	mov    %ecx,%eax
  8021b2:	89 f2                	mov    %esi,%edx
  8021b4:	f7 f7                	div    %edi
  8021b6:	89 d0                	mov    %edx,%eax
  8021b8:	31 d2                	xor    %edx,%edx
  8021ba:	83 c4 1c             	add    $0x1c,%esp
  8021bd:	5b                   	pop    %ebx
  8021be:	5e                   	pop    %esi
  8021bf:	5f                   	pop    %edi
  8021c0:	5d                   	pop    %ebp
  8021c1:	c3                   	ret    
  8021c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021c8:	39 f2                	cmp    %esi,%edx
  8021ca:	89 d0                	mov    %edx,%eax
  8021cc:	77 52                	ja     802220 <__umoddi3+0xa0>
  8021ce:	0f bd ea             	bsr    %edx,%ebp
  8021d1:	83 f5 1f             	xor    $0x1f,%ebp
  8021d4:	75 5a                	jne    802230 <__umoddi3+0xb0>
  8021d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021da:	0f 82 e0 00 00 00    	jb     8022c0 <__umoddi3+0x140>
  8021e0:	39 0c 24             	cmp    %ecx,(%esp)
  8021e3:	0f 86 d7 00 00 00    	jbe    8022c0 <__umoddi3+0x140>
  8021e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021f1:	83 c4 1c             	add    $0x1c,%esp
  8021f4:	5b                   	pop    %ebx
  8021f5:	5e                   	pop    %esi
  8021f6:	5f                   	pop    %edi
  8021f7:	5d                   	pop    %ebp
  8021f8:	c3                   	ret    
  8021f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802200:	85 ff                	test   %edi,%edi
  802202:	89 fd                	mov    %edi,%ebp
  802204:	75 0b                	jne    802211 <__umoddi3+0x91>
  802206:	b8 01 00 00 00       	mov    $0x1,%eax
  80220b:	31 d2                	xor    %edx,%edx
  80220d:	f7 f7                	div    %edi
  80220f:	89 c5                	mov    %eax,%ebp
  802211:	89 f0                	mov    %esi,%eax
  802213:	31 d2                	xor    %edx,%edx
  802215:	f7 f5                	div    %ebp
  802217:	89 c8                	mov    %ecx,%eax
  802219:	f7 f5                	div    %ebp
  80221b:	89 d0                	mov    %edx,%eax
  80221d:	eb 99                	jmp    8021b8 <__umoddi3+0x38>
  80221f:	90                   	nop
  802220:	89 c8                	mov    %ecx,%eax
  802222:	89 f2                	mov    %esi,%edx
  802224:	83 c4 1c             	add    $0x1c,%esp
  802227:	5b                   	pop    %ebx
  802228:	5e                   	pop    %esi
  802229:	5f                   	pop    %edi
  80222a:	5d                   	pop    %ebp
  80222b:	c3                   	ret    
  80222c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802230:	8b 34 24             	mov    (%esp),%esi
  802233:	bf 20 00 00 00       	mov    $0x20,%edi
  802238:	89 e9                	mov    %ebp,%ecx
  80223a:	29 ef                	sub    %ebp,%edi
  80223c:	d3 e0                	shl    %cl,%eax
  80223e:	89 f9                	mov    %edi,%ecx
  802240:	89 f2                	mov    %esi,%edx
  802242:	d3 ea                	shr    %cl,%edx
  802244:	89 e9                	mov    %ebp,%ecx
  802246:	09 c2                	or     %eax,%edx
  802248:	89 d8                	mov    %ebx,%eax
  80224a:	89 14 24             	mov    %edx,(%esp)
  80224d:	89 f2                	mov    %esi,%edx
  80224f:	d3 e2                	shl    %cl,%edx
  802251:	89 f9                	mov    %edi,%ecx
  802253:	89 54 24 04          	mov    %edx,0x4(%esp)
  802257:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80225b:	d3 e8                	shr    %cl,%eax
  80225d:	89 e9                	mov    %ebp,%ecx
  80225f:	89 c6                	mov    %eax,%esi
  802261:	d3 e3                	shl    %cl,%ebx
  802263:	89 f9                	mov    %edi,%ecx
  802265:	89 d0                	mov    %edx,%eax
  802267:	d3 e8                	shr    %cl,%eax
  802269:	89 e9                	mov    %ebp,%ecx
  80226b:	09 d8                	or     %ebx,%eax
  80226d:	89 d3                	mov    %edx,%ebx
  80226f:	89 f2                	mov    %esi,%edx
  802271:	f7 34 24             	divl   (%esp)
  802274:	89 d6                	mov    %edx,%esi
  802276:	d3 e3                	shl    %cl,%ebx
  802278:	f7 64 24 04          	mull   0x4(%esp)
  80227c:	39 d6                	cmp    %edx,%esi
  80227e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802282:	89 d1                	mov    %edx,%ecx
  802284:	89 c3                	mov    %eax,%ebx
  802286:	72 08                	jb     802290 <__umoddi3+0x110>
  802288:	75 11                	jne    80229b <__umoddi3+0x11b>
  80228a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80228e:	73 0b                	jae    80229b <__umoddi3+0x11b>
  802290:	2b 44 24 04          	sub    0x4(%esp),%eax
  802294:	1b 14 24             	sbb    (%esp),%edx
  802297:	89 d1                	mov    %edx,%ecx
  802299:	89 c3                	mov    %eax,%ebx
  80229b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80229f:	29 da                	sub    %ebx,%edx
  8022a1:	19 ce                	sbb    %ecx,%esi
  8022a3:	89 f9                	mov    %edi,%ecx
  8022a5:	89 f0                	mov    %esi,%eax
  8022a7:	d3 e0                	shl    %cl,%eax
  8022a9:	89 e9                	mov    %ebp,%ecx
  8022ab:	d3 ea                	shr    %cl,%edx
  8022ad:	89 e9                	mov    %ebp,%ecx
  8022af:	d3 ee                	shr    %cl,%esi
  8022b1:	09 d0                	or     %edx,%eax
  8022b3:	89 f2                	mov    %esi,%edx
  8022b5:	83 c4 1c             	add    $0x1c,%esp
  8022b8:	5b                   	pop    %ebx
  8022b9:	5e                   	pop    %esi
  8022ba:	5f                   	pop    %edi
  8022bb:	5d                   	pop    %ebp
  8022bc:	c3                   	ret    
  8022bd:	8d 76 00             	lea    0x0(%esi),%esi
  8022c0:	29 f9                	sub    %edi,%ecx
  8022c2:	19 d6                	sbb    %edx,%esi
  8022c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022cc:	e9 18 ff ff ff       	jmp    8021e9 <__umoddi3+0x69>
