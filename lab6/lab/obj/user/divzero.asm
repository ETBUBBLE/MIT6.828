
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
  800039:	c7 05 08 40 80 00 00 	movl   $0x0,0x804008
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	b8 01 00 00 00       	mov    $0x1,%eax
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	99                   	cltd   
  80004e:	f7 f9                	idiv   %ecx
  800050:	50                   	push   %eax
  800051:	68 00 23 80 00       	push   $0x802300
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
  80007d:	a3 0c 40 80 00       	mov    %eax,0x80400c

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
  8000ac:	e8 a4 0e 00 00       	call   800f55 <close_all>
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
  8001b6:	e8 a5 1e 00 00       	call   802060 <__udivdi3>
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
  8001f9:	e8 92 1f 00 00       	call   802190 <__umoddi3>
  8001fe:	83 c4 14             	add    $0x14,%esp
  800201:	0f be 80 18 23 80 00 	movsbl 0x802318(%eax),%eax
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
  8002c3:	ff 24 85 60 24 80 00 	jmp    *0x802460(,%eax,4)
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
  80038a:	8b 14 85 c0 25 80 00 	mov    0x8025c0(,%eax,4),%edx
  800391:	85 d2                	test   %edx,%edx
  800393:	75 1b                	jne    8003b0 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800395:	50                   	push   %eax
  800396:	68 30 23 80 00       	push   $0x802330
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
  8003b1:	68 f5 26 80 00       	push   $0x8026f5
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
  8003db:	b8 29 23 80 00       	mov    $0x802329,%eax
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
  800b03:	68 1f 26 80 00       	push   $0x80261f
  800b08:	6a 23                	push   $0x23
  800b0a:	68 3c 26 80 00       	push   $0x80263c
  800b0f:	e8 c7 13 00 00       	call   801edb <_panic>

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
  800b84:	68 1f 26 80 00       	push   $0x80261f
  800b89:	6a 23                	push   $0x23
  800b8b:	68 3c 26 80 00       	push   $0x80263c
  800b90:	e8 46 13 00 00       	call   801edb <_panic>

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
  800bc6:	68 1f 26 80 00       	push   $0x80261f
  800bcb:	6a 23                	push   $0x23
  800bcd:	68 3c 26 80 00       	push   $0x80263c
  800bd2:	e8 04 13 00 00       	call   801edb <_panic>

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
  800c08:	68 1f 26 80 00       	push   $0x80261f
  800c0d:	6a 23                	push   $0x23
  800c0f:	68 3c 26 80 00       	push   $0x80263c
  800c14:	e8 c2 12 00 00       	call   801edb <_panic>

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
  800c4a:	68 1f 26 80 00       	push   $0x80261f
  800c4f:	6a 23                	push   $0x23
  800c51:	68 3c 26 80 00       	push   $0x80263c
  800c56:	e8 80 12 00 00       	call   801edb <_panic>

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
  800c8c:	68 1f 26 80 00       	push   $0x80261f
  800c91:	6a 23                	push   $0x23
  800c93:	68 3c 26 80 00       	push   $0x80263c
  800c98:	e8 3e 12 00 00       	call   801edb <_panic>

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
  800cce:	68 1f 26 80 00       	push   $0x80261f
  800cd3:	6a 23                	push   $0x23
  800cd5:	68 3c 26 80 00       	push   $0x80263c
  800cda:	e8 fc 11 00 00       	call   801edb <_panic>

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
  800d32:	68 1f 26 80 00       	push   $0x80261f
  800d37:	6a 23                	push   $0x23
  800d39:	68 3c 26 80 00       	push   $0x80263c
  800d3e:	e8 98 11 00 00       	call   801edb <_panic>

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

00800d4b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	57                   	push   %edi
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d51:	ba 00 00 00 00       	mov    $0x0,%edx
  800d56:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d5b:	89 d1                	mov    %edx,%ecx
  800d5d:	89 d3                	mov    %edx,%ebx
  800d5f:	89 d7                	mov    %edx,%edi
  800d61:	89 d6                	mov    %edx,%esi
  800d63:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d65:	5b                   	pop    %ebx
  800d66:	5e                   	pop    %esi
  800d67:	5f                   	pop    %edi
  800d68:	5d                   	pop    %ebp
  800d69:	c3                   	ret    

00800d6a <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	57                   	push   %edi
  800d6e:	56                   	push   %esi
  800d6f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d70:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d75:	b8 10 00 00 00       	mov    $0x10,%eax
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	89 cb                	mov    %ecx,%ebx
  800d7f:	89 cf                	mov    %ecx,%edi
  800d81:	89 ce                	mov    %ecx,%esi
  800d83:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800d8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d90:	05 00 00 00 30       	add    $0x30000000,%eax
  800d95:	c1 e8 0c             	shr    $0xc,%eax
}
  800d98:	5d                   	pop    %ebp
  800d99:	c3                   	ret    

00800d9a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800d9a:	55                   	push   %ebp
  800d9b:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800d9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800da0:	05 00 00 00 30       	add    $0x30000000,%eax
  800da5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800daa:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800dbc:	89 c2                	mov    %eax,%edx
  800dbe:	c1 ea 16             	shr    $0x16,%edx
  800dc1:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800dc8:	f6 c2 01             	test   $0x1,%dl
  800dcb:	74 11                	je     800dde <fd_alloc+0x2d>
  800dcd:	89 c2                	mov    %eax,%edx
  800dcf:	c1 ea 0c             	shr    $0xc,%edx
  800dd2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800dd9:	f6 c2 01             	test   $0x1,%dl
  800ddc:	75 09                	jne    800de7 <fd_alloc+0x36>
			*fd_store = fd;
  800dde:	89 01                	mov    %eax,(%ecx)
			return 0;
  800de0:	b8 00 00 00 00       	mov    $0x0,%eax
  800de5:	eb 17                	jmp    800dfe <fd_alloc+0x4d>
  800de7:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800dec:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800df1:	75 c9                	jne    800dbc <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800df3:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800df9:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800dfe:	5d                   	pop    %ebp
  800dff:	c3                   	ret    

00800e00 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e00:	55                   	push   %ebp
  800e01:	89 e5                	mov    %esp,%ebp
  800e03:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e06:	83 f8 1f             	cmp    $0x1f,%eax
  800e09:	77 36                	ja     800e41 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e0b:	c1 e0 0c             	shl    $0xc,%eax
  800e0e:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e13:	89 c2                	mov    %eax,%edx
  800e15:	c1 ea 16             	shr    $0x16,%edx
  800e18:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e1f:	f6 c2 01             	test   $0x1,%dl
  800e22:	74 24                	je     800e48 <fd_lookup+0x48>
  800e24:	89 c2                	mov    %eax,%edx
  800e26:	c1 ea 0c             	shr    $0xc,%edx
  800e29:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e30:	f6 c2 01             	test   $0x1,%dl
  800e33:	74 1a                	je     800e4f <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e35:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e38:	89 02                	mov    %eax,(%edx)
	return 0;
  800e3a:	b8 00 00 00 00       	mov    $0x0,%eax
  800e3f:	eb 13                	jmp    800e54 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e41:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e46:	eb 0c                	jmp    800e54 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800e48:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e4d:	eb 05                	jmp    800e54 <fd_lookup+0x54>
  800e4f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800e54:	5d                   	pop    %ebp
  800e55:	c3                   	ret    

00800e56 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e56:	55                   	push   %ebp
  800e57:	89 e5                	mov    %esp,%ebp
  800e59:	83 ec 08             	sub    $0x8,%esp
  800e5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5f:	ba c8 26 80 00       	mov    $0x8026c8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800e64:	eb 13                	jmp    800e79 <dev_lookup+0x23>
  800e66:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800e69:	39 08                	cmp    %ecx,(%eax)
  800e6b:	75 0c                	jne    800e79 <dev_lookup+0x23>
			*dev = devtab[i];
  800e6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e70:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e72:	b8 00 00 00 00       	mov    $0x0,%eax
  800e77:	eb 2e                	jmp    800ea7 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800e79:	8b 02                	mov    (%edx),%eax
  800e7b:	85 c0                	test   %eax,%eax
  800e7d:	75 e7                	jne    800e66 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800e7f:	a1 0c 40 80 00       	mov    0x80400c,%eax
  800e84:	8b 40 48             	mov    0x48(%eax),%eax
  800e87:	83 ec 04             	sub    $0x4,%esp
  800e8a:	51                   	push   %ecx
  800e8b:	50                   	push   %eax
  800e8c:	68 4c 26 80 00       	push   $0x80264c
  800e91:	e8 bd f2 ff ff       	call   800153 <cprintf>
	*dev = 0;
  800e96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e99:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800e9f:	83 c4 10             	add    $0x10,%esp
  800ea2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ea7:	c9                   	leave  
  800ea8:	c3                   	ret    

00800ea9 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	56                   	push   %esi
  800ead:	53                   	push   %ebx
  800eae:	83 ec 10             	sub    $0x10,%esp
  800eb1:	8b 75 08             	mov    0x8(%ebp),%esi
  800eb4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800eb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eba:	50                   	push   %eax
  800ebb:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800ec1:	c1 e8 0c             	shr    $0xc,%eax
  800ec4:	50                   	push   %eax
  800ec5:	e8 36 ff ff ff       	call   800e00 <fd_lookup>
  800eca:	83 c4 08             	add    $0x8,%esp
  800ecd:	85 c0                	test   %eax,%eax
  800ecf:	78 05                	js     800ed6 <fd_close+0x2d>
	    || fd != fd2)
  800ed1:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800ed4:	74 0c                	je     800ee2 <fd_close+0x39>
		return (must_exist ? r : 0);
  800ed6:	84 db                	test   %bl,%bl
  800ed8:	ba 00 00 00 00       	mov    $0x0,%edx
  800edd:	0f 44 c2             	cmove  %edx,%eax
  800ee0:	eb 41                	jmp    800f23 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800ee2:	83 ec 08             	sub    $0x8,%esp
  800ee5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800ee8:	50                   	push   %eax
  800ee9:	ff 36                	pushl  (%esi)
  800eeb:	e8 66 ff ff ff       	call   800e56 <dev_lookup>
  800ef0:	89 c3                	mov    %eax,%ebx
  800ef2:	83 c4 10             	add    $0x10,%esp
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	78 1a                	js     800f13 <fd_close+0x6a>
		if (dev->dev_close)
  800ef9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800efc:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800eff:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f04:	85 c0                	test   %eax,%eax
  800f06:	74 0b                	je     800f13 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f08:	83 ec 0c             	sub    $0xc,%esp
  800f0b:	56                   	push   %esi
  800f0c:	ff d0                	call   *%eax
  800f0e:	89 c3                	mov    %eax,%ebx
  800f10:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f13:	83 ec 08             	sub    $0x8,%esp
  800f16:	56                   	push   %esi
  800f17:	6a 00                	push   $0x0
  800f19:	e8 c1 fc ff ff       	call   800bdf <sys_page_unmap>
	return r;
  800f1e:	83 c4 10             	add    $0x10,%esp
  800f21:	89 d8                	mov    %ebx,%eax
}
  800f23:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f26:	5b                   	pop    %ebx
  800f27:	5e                   	pop    %esi
  800f28:	5d                   	pop    %ebp
  800f29:	c3                   	ret    

00800f2a <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f2a:	55                   	push   %ebp
  800f2b:	89 e5                	mov    %esp,%ebp
  800f2d:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f33:	50                   	push   %eax
  800f34:	ff 75 08             	pushl  0x8(%ebp)
  800f37:	e8 c4 fe ff ff       	call   800e00 <fd_lookup>
  800f3c:	83 c4 08             	add    $0x8,%esp
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	78 10                	js     800f53 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800f43:	83 ec 08             	sub    $0x8,%esp
  800f46:	6a 01                	push   $0x1
  800f48:	ff 75 f4             	pushl  -0xc(%ebp)
  800f4b:	e8 59 ff ff ff       	call   800ea9 <fd_close>
  800f50:	83 c4 10             	add    $0x10,%esp
}
  800f53:	c9                   	leave  
  800f54:	c3                   	ret    

00800f55 <close_all>:

void
close_all(void)
{
  800f55:	55                   	push   %ebp
  800f56:	89 e5                	mov    %esp,%ebp
  800f58:	53                   	push   %ebx
  800f59:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800f5c:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800f61:	83 ec 0c             	sub    $0xc,%esp
  800f64:	53                   	push   %ebx
  800f65:	e8 c0 ff ff ff       	call   800f2a <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800f6a:	83 c3 01             	add    $0x1,%ebx
  800f6d:	83 c4 10             	add    $0x10,%esp
  800f70:	83 fb 20             	cmp    $0x20,%ebx
  800f73:	75 ec                	jne    800f61 <close_all+0xc>
		close(i);
}
  800f75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f78:	c9                   	leave  
  800f79:	c3                   	ret    

00800f7a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800f7a:	55                   	push   %ebp
  800f7b:	89 e5                	mov    %esp,%ebp
  800f7d:	57                   	push   %edi
  800f7e:	56                   	push   %esi
  800f7f:	53                   	push   %ebx
  800f80:	83 ec 2c             	sub    $0x2c,%esp
  800f83:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800f86:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800f89:	50                   	push   %eax
  800f8a:	ff 75 08             	pushl  0x8(%ebp)
  800f8d:	e8 6e fe ff ff       	call   800e00 <fd_lookup>
  800f92:	83 c4 08             	add    $0x8,%esp
  800f95:	85 c0                	test   %eax,%eax
  800f97:	0f 88 c1 00 00 00    	js     80105e <dup+0xe4>
		return r;
	close(newfdnum);
  800f9d:	83 ec 0c             	sub    $0xc,%esp
  800fa0:	56                   	push   %esi
  800fa1:	e8 84 ff ff ff       	call   800f2a <close>

	newfd = INDEX2FD(newfdnum);
  800fa6:	89 f3                	mov    %esi,%ebx
  800fa8:	c1 e3 0c             	shl    $0xc,%ebx
  800fab:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800fb1:	83 c4 04             	add    $0x4,%esp
  800fb4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800fb7:	e8 de fd ff ff       	call   800d9a <fd2data>
  800fbc:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800fbe:	89 1c 24             	mov    %ebx,(%esp)
  800fc1:	e8 d4 fd ff ff       	call   800d9a <fd2data>
  800fc6:	83 c4 10             	add    $0x10,%esp
  800fc9:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800fcc:	89 f8                	mov    %edi,%eax
  800fce:	c1 e8 16             	shr    $0x16,%eax
  800fd1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800fd8:	a8 01                	test   $0x1,%al
  800fda:	74 37                	je     801013 <dup+0x99>
  800fdc:	89 f8                	mov    %edi,%eax
  800fde:	c1 e8 0c             	shr    $0xc,%eax
  800fe1:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800fe8:	f6 c2 01             	test   $0x1,%dl
  800feb:	74 26                	je     801013 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800fed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800ff4:	83 ec 0c             	sub    $0xc,%esp
  800ff7:	25 07 0e 00 00       	and    $0xe07,%eax
  800ffc:	50                   	push   %eax
  800ffd:	ff 75 d4             	pushl  -0x2c(%ebp)
  801000:	6a 00                	push   $0x0
  801002:	57                   	push   %edi
  801003:	6a 00                	push   $0x0
  801005:	e8 93 fb ff ff       	call   800b9d <sys_page_map>
  80100a:	89 c7                	mov    %eax,%edi
  80100c:	83 c4 20             	add    $0x20,%esp
  80100f:	85 c0                	test   %eax,%eax
  801011:	78 2e                	js     801041 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801013:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801016:	89 d0                	mov    %edx,%eax
  801018:	c1 e8 0c             	shr    $0xc,%eax
  80101b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801022:	83 ec 0c             	sub    $0xc,%esp
  801025:	25 07 0e 00 00       	and    $0xe07,%eax
  80102a:	50                   	push   %eax
  80102b:	53                   	push   %ebx
  80102c:	6a 00                	push   $0x0
  80102e:	52                   	push   %edx
  80102f:	6a 00                	push   $0x0
  801031:	e8 67 fb ff ff       	call   800b9d <sys_page_map>
  801036:	89 c7                	mov    %eax,%edi
  801038:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80103b:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80103d:	85 ff                	test   %edi,%edi
  80103f:	79 1d                	jns    80105e <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801041:	83 ec 08             	sub    $0x8,%esp
  801044:	53                   	push   %ebx
  801045:	6a 00                	push   $0x0
  801047:	e8 93 fb ff ff       	call   800bdf <sys_page_unmap>
	sys_page_unmap(0, nva);
  80104c:	83 c4 08             	add    $0x8,%esp
  80104f:	ff 75 d4             	pushl  -0x2c(%ebp)
  801052:	6a 00                	push   $0x0
  801054:	e8 86 fb ff ff       	call   800bdf <sys_page_unmap>
	return r;
  801059:	83 c4 10             	add    $0x10,%esp
  80105c:	89 f8                	mov    %edi,%eax
}
  80105e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801061:	5b                   	pop    %ebx
  801062:	5e                   	pop    %esi
  801063:	5f                   	pop    %edi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	53                   	push   %ebx
  80106a:	83 ec 14             	sub    $0x14,%esp
  80106d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801070:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801073:	50                   	push   %eax
  801074:	53                   	push   %ebx
  801075:	e8 86 fd ff ff       	call   800e00 <fd_lookup>
  80107a:	83 c4 08             	add    $0x8,%esp
  80107d:	89 c2                	mov    %eax,%edx
  80107f:	85 c0                	test   %eax,%eax
  801081:	78 6d                	js     8010f0 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801083:	83 ec 08             	sub    $0x8,%esp
  801086:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801089:	50                   	push   %eax
  80108a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80108d:	ff 30                	pushl  (%eax)
  80108f:	e8 c2 fd ff ff       	call   800e56 <dev_lookup>
  801094:	83 c4 10             	add    $0x10,%esp
  801097:	85 c0                	test   %eax,%eax
  801099:	78 4c                	js     8010e7 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80109b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80109e:	8b 42 08             	mov    0x8(%edx),%eax
  8010a1:	83 e0 03             	and    $0x3,%eax
  8010a4:	83 f8 01             	cmp    $0x1,%eax
  8010a7:	75 21                	jne    8010ca <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8010a9:	a1 0c 40 80 00       	mov    0x80400c,%eax
  8010ae:	8b 40 48             	mov    0x48(%eax),%eax
  8010b1:	83 ec 04             	sub    $0x4,%esp
  8010b4:	53                   	push   %ebx
  8010b5:	50                   	push   %eax
  8010b6:	68 8d 26 80 00       	push   $0x80268d
  8010bb:	e8 93 f0 ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  8010c0:	83 c4 10             	add    $0x10,%esp
  8010c3:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8010c8:	eb 26                	jmp    8010f0 <read+0x8a>
	}
	if (!dev->dev_read)
  8010ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8010cd:	8b 40 08             	mov    0x8(%eax),%eax
  8010d0:	85 c0                	test   %eax,%eax
  8010d2:	74 17                	je     8010eb <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8010d4:	83 ec 04             	sub    $0x4,%esp
  8010d7:	ff 75 10             	pushl  0x10(%ebp)
  8010da:	ff 75 0c             	pushl  0xc(%ebp)
  8010dd:	52                   	push   %edx
  8010de:	ff d0                	call   *%eax
  8010e0:	89 c2                	mov    %eax,%edx
  8010e2:	83 c4 10             	add    $0x10,%esp
  8010e5:	eb 09                	jmp    8010f0 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e7:	89 c2                	mov    %eax,%edx
  8010e9:	eb 05                	jmp    8010f0 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8010eb:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8010f0:	89 d0                	mov    %edx,%eax
  8010f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010f5:	c9                   	leave  
  8010f6:	c3                   	ret    

008010f7 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8010f7:	55                   	push   %ebp
  8010f8:	89 e5                	mov    %esp,%ebp
  8010fa:	57                   	push   %edi
  8010fb:	56                   	push   %esi
  8010fc:	53                   	push   %ebx
  8010fd:	83 ec 0c             	sub    $0xc,%esp
  801100:	8b 7d 08             	mov    0x8(%ebp),%edi
  801103:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801106:	bb 00 00 00 00       	mov    $0x0,%ebx
  80110b:	eb 21                	jmp    80112e <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80110d:	83 ec 04             	sub    $0x4,%esp
  801110:	89 f0                	mov    %esi,%eax
  801112:	29 d8                	sub    %ebx,%eax
  801114:	50                   	push   %eax
  801115:	89 d8                	mov    %ebx,%eax
  801117:	03 45 0c             	add    0xc(%ebp),%eax
  80111a:	50                   	push   %eax
  80111b:	57                   	push   %edi
  80111c:	e8 45 ff ff ff       	call   801066 <read>
		if (m < 0)
  801121:	83 c4 10             	add    $0x10,%esp
  801124:	85 c0                	test   %eax,%eax
  801126:	78 10                	js     801138 <readn+0x41>
			return m;
		if (m == 0)
  801128:	85 c0                	test   %eax,%eax
  80112a:	74 0a                	je     801136 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80112c:	01 c3                	add    %eax,%ebx
  80112e:	39 f3                	cmp    %esi,%ebx
  801130:	72 db                	jb     80110d <readn+0x16>
  801132:	89 d8                	mov    %ebx,%eax
  801134:	eb 02                	jmp    801138 <readn+0x41>
  801136:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801138:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113b:	5b                   	pop    %ebx
  80113c:	5e                   	pop    %esi
  80113d:	5f                   	pop    %edi
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    

00801140 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	53                   	push   %ebx
  801144:	83 ec 14             	sub    $0x14,%esp
  801147:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80114a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80114d:	50                   	push   %eax
  80114e:	53                   	push   %ebx
  80114f:	e8 ac fc ff ff       	call   800e00 <fd_lookup>
  801154:	83 c4 08             	add    $0x8,%esp
  801157:	89 c2                	mov    %eax,%edx
  801159:	85 c0                	test   %eax,%eax
  80115b:	78 68                	js     8011c5 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80115d:	83 ec 08             	sub    $0x8,%esp
  801160:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801163:	50                   	push   %eax
  801164:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801167:	ff 30                	pushl  (%eax)
  801169:	e8 e8 fc ff ff       	call   800e56 <dev_lookup>
  80116e:	83 c4 10             	add    $0x10,%esp
  801171:	85 c0                	test   %eax,%eax
  801173:	78 47                	js     8011bc <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801175:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801178:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80117c:	75 21                	jne    80119f <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80117e:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801183:	8b 40 48             	mov    0x48(%eax),%eax
  801186:	83 ec 04             	sub    $0x4,%esp
  801189:	53                   	push   %ebx
  80118a:	50                   	push   %eax
  80118b:	68 a9 26 80 00       	push   $0x8026a9
  801190:	e8 be ef ff ff       	call   800153 <cprintf>
		return -E_INVAL;
  801195:	83 c4 10             	add    $0x10,%esp
  801198:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80119d:	eb 26                	jmp    8011c5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80119f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011a2:	8b 52 0c             	mov    0xc(%edx),%edx
  8011a5:	85 d2                	test   %edx,%edx
  8011a7:	74 17                	je     8011c0 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011a9:	83 ec 04             	sub    $0x4,%esp
  8011ac:	ff 75 10             	pushl  0x10(%ebp)
  8011af:	ff 75 0c             	pushl  0xc(%ebp)
  8011b2:	50                   	push   %eax
  8011b3:	ff d2                	call   *%edx
  8011b5:	89 c2                	mov    %eax,%edx
  8011b7:	83 c4 10             	add    $0x10,%esp
  8011ba:	eb 09                	jmp    8011c5 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011bc:	89 c2                	mov    %eax,%edx
  8011be:	eb 05                	jmp    8011c5 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8011c0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8011c5:	89 d0                	mov    %edx,%eax
  8011c7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ca:	c9                   	leave  
  8011cb:	c3                   	ret    

008011cc <seek>:

int
seek(int fdnum, off_t offset)
{
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011d2:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8011d5:	50                   	push   %eax
  8011d6:	ff 75 08             	pushl  0x8(%ebp)
  8011d9:	e8 22 fc ff ff       	call   800e00 <fd_lookup>
  8011de:	83 c4 08             	add    $0x8,%esp
  8011e1:	85 c0                	test   %eax,%eax
  8011e3:	78 0e                	js     8011f3 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8011e5:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8011e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8011eb:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8011ee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8011f3:	c9                   	leave  
  8011f4:	c3                   	ret    

008011f5 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8011f5:	55                   	push   %ebp
  8011f6:	89 e5                	mov    %esp,%ebp
  8011f8:	53                   	push   %ebx
  8011f9:	83 ec 14             	sub    $0x14,%esp
  8011fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801202:	50                   	push   %eax
  801203:	53                   	push   %ebx
  801204:	e8 f7 fb ff ff       	call   800e00 <fd_lookup>
  801209:	83 c4 08             	add    $0x8,%esp
  80120c:	89 c2                	mov    %eax,%edx
  80120e:	85 c0                	test   %eax,%eax
  801210:	78 65                	js     801277 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801212:	83 ec 08             	sub    $0x8,%esp
  801215:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801218:	50                   	push   %eax
  801219:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121c:	ff 30                	pushl  (%eax)
  80121e:	e8 33 fc ff ff       	call   800e56 <dev_lookup>
  801223:	83 c4 10             	add    $0x10,%esp
  801226:	85 c0                	test   %eax,%eax
  801228:	78 44                	js     80126e <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80122a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80122d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801231:	75 21                	jne    801254 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801233:	a1 0c 40 80 00       	mov    0x80400c,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801238:	8b 40 48             	mov    0x48(%eax),%eax
  80123b:	83 ec 04             	sub    $0x4,%esp
  80123e:	53                   	push   %ebx
  80123f:	50                   	push   %eax
  801240:	68 6c 26 80 00       	push   $0x80266c
  801245:	e8 09 ef ff ff       	call   800153 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80124a:	83 c4 10             	add    $0x10,%esp
  80124d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801252:	eb 23                	jmp    801277 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801254:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801257:	8b 52 18             	mov    0x18(%edx),%edx
  80125a:	85 d2                	test   %edx,%edx
  80125c:	74 14                	je     801272 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80125e:	83 ec 08             	sub    $0x8,%esp
  801261:	ff 75 0c             	pushl  0xc(%ebp)
  801264:	50                   	push   %eax
  801265:	ff d2                	call   *%edx
  801267:	89 c2                	mov    %eax,%edx
  801269:	83 c4 10             	add    $0x10,%esp
  80126c:	eb 09                	jmp    801277 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126e:	89 c2                	mov    %eax,%edx
  801270:	eb 05                	jmp    801277 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801272:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  801277:	89 d0                	mov    %edx,%eax
  801279:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80127c:	c9                   	leave  
  80127d:	c3                   	ret    

0080127e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	53                   	push   %ebx
  801282:	83 ec 14             	sub    $0x14,%esp
  801285:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801288:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80128b:	50                   	push   %eax
  80128c:	ff 75 08             	pushl  0x8(%ebp)
  80128f:	e8 6c fb ff ff       	call   800e00 <fd_lookup>
  801294:	83 c4 08             	add    $0x8,%esp
  801297:	89 c2                	mov    %eax,%edx
  801299:	85 c0                	test   %eax,%eax
  80129b:	78 58                	js     8012f5 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80129d:	83 ec 08             	sub    $0x8,%esp
  8012a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012a3:	50                   	push   %eax
  8012a4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a7:	ff 30                	pushl  (%eax)
  8012a9:	e8 a8 fb ff ff       	call   800e56 <dev_lookup>
  8012ae:	83 c4 10             	add    $0x10,%esp
  8012b1:	85 c0                	test   %eax,%eax
  8012b3:	78 37                	js     8012ec <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8012b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b8:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8012bc:	74 32                	je     8012f0 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8012be:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8012c1:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8012c8:	00 00 00 
	stat->st_isdir = 0;
  8012cb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8012d2:	00 00 00 
	stat->st_dev = dev;
  8012d5:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8012db:	83 ec 08             	sub    $0x8,%esp
  8012de:	53                   	push   %ebx
  8012df:	ff 75 f0             	pushl  -0x10(%ebp)
  8012e2:	ff 50 14             	call   *0x14(%eax)
  8012e5:	89 c2                	mov    %eax,%edx
  8012e7:	83 c4 10             	add    $0x10,%esp
  8012ea:	eb 09                	jmp    8012f5 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012ec:	89 c2                	mov    %eax,%edx
  8012ee:	eb 05                	jmp    8012f5 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8012f0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8012f5:	89 d0                	mov    %edx,%eax
  8012f7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012fa:	c9                   	leave  
  8012fb:	c3                   	ret    

008012fc <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8012fc:	55                   	push   %ebp
  8012fd:	89 e5                	mov    %esp,%ebp
  8012ff:	56                   	push   %esi
  801300:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801301:	83 ec 08             	sub    $0x8,%esp
  801304:	6a 00                	push   $0x0
  801306:	ff 75 08             	pushl  0x8(%ebp)
  801309:	e8 e3 01 00 00       	call   8014f1 <open>
  80130e:	89 c3                	mov    %eax,%ebx
  801310:	83 c4 10             	add    $0x10,%esp
  801313:	85 c0                	test   %eax,%eax
  801315:	78 1b                	js     801332 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801317:	83 ec 08             	sub    $0x8,%esp
  80131a:	ff 75 0c             	pushl  0xc(%ebp)
  80131d:	50                   	push   %eax
  80131e:	e8 5b ff ff ff       	call   80127e <fstat>
  801323:	89 c6                	mov    %eax,%esi
	close(fd);
  801325:	89 1c 24             	mov    %ebx,(%esp)
  801328:	e8 fd fb ff ff       	call   800f2a <close>
	return r;
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	89 f0                	mov    %esi,%eax
}
  801332:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801335:	5b                   	pop    %ebx
  801336:	5e                   	pop    %esi
  801337:	5d                   	pop    %ebp
  801338:	c3                   	ret    

00801339 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801339:	55                   	push   %ebp
  80133a:	89 e5                	mov    %esp,%ebp
  80133c:	56                   	push   %esi
  80133d:	53                   	push   %ebx
  80133e:	89 c6                	mov    %eax,%esi
  801340:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801342:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801349:	75 12                	jne    80135d <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80134b:	83 ec 0c             	sub    $0xc,%esp
  80134e:	6a 01                	push   $0x1
  801350:	e8 89 0c 00 00       	call   801fde <ipc_find_env>
  801355:	a3 00 40 80 00       	mov    %eax,0x804000
  80135a:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80135d:	6a 07                	push   $0x7
  80135f:	68 00 50 80 00       	push   $0x805000
  801364:	56                   	push   %esi
  801365:	ff 35 00 40 80 00    	pushl  0x804000
  80136b:	e8 1a 0c 00 00       	call   801f8a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801370:	83 c4 0c             	add    $0xc,%esp
  801373:	6a 00                	push   $0x0
  801375:	53                   	push   %ebx
  801376:	6a 00                	push   $0x0
  801378:	e8 a4 0b 00 00       	call   801f21 <ipc_recv>
}
  80137d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801380:	5b                   	pop    %ebx
  801381:	5e                   	pop    %esi
  801382:	5d                   	pop    %ebp
  801383:	c3                   	ret    

00801384 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801384:	55                   	push   %ebp
  801385:	89 e5                	mov    %esp,%ebp
  801387:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80138a:	8b 45 08             	mov    0x8(%ebp),%eax
  80138d:	8b 40 0c             	mov    0xc(%eax),%eax
  801390:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801395:	8b 45 0c             	mov    0xc(%ebp),%eax
  801398:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80139d:	ba 00 00 00 00       	mov    $0x0,%edx
  8013a2:	b8 02 00 00 00       	mov    $0x2,%eax
  8013a7:	e8 8d ff ff ff       	call   801339 <fsipc>
}
  8013ac:	c9                   	leave  
  8013ad:	c3                   	ret    

008013ae <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8013ae:	55                   	push   %ebp
  8013af:	89 e5                	mov    %esp,%ebp
  8013b1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8013b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013b7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ba:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8013bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8013c4:	b8 06 00 00 00       	mov    $0x6,%eax
  8013c9:	e8 6b ff ff ff       	call   801339 <fsipc>
}
  8013ce:	c9                   	leave  
  8013cf:	c3                   	ret    

008013d0 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8013d0:	55                   	push   %ebp
  8013d1:	89 e5                	mov    %esp,%ebp
  8013d3:	53                   	push   %ebx
  8013d4:	83 ec 04             	sub    $0x4,%esp
  8013d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8013da:	8b 45 08             	mov    0x8(%ebp),%eax
  8013dd:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e0:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8013e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013ea:	b8 05 00 00 00       	mov    $0x5,%eax
  8013ef:	e8 45 ff ff ff       	call   801339 <fsipc>
  8013f4:	85 c0                	test   %eax,%eax
  8013f6:	78 2c                	js     801424 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8013f8:	83 ec 08             	sub    $0x8,%esp
  8013fb:	68 00 50 80 00       	push   $0x805000
  801400:	53                   	push   %ebx
  801401:	e8 51 f3 ff ff       	call   800757 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801406:	a1 80 50 80 00       	mov    0x805080,%eax
  80140b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801411:	a1 84 50 80 00       	mov    0x805084,%eax
  801416:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80141c:	83 c4 10             	add    $0x10,%esp
  80141f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801424:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801427:	c9                   	leave  
  801428:	c3                   	ret    

00801429 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	83 ec 0c             	sub    $0xc,%esp
  80142f:	8b 45 10             	mov    0x10(%ebp),%eax
  801432:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801437:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80143c:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80143f:	8b 55 08             	mov    0x8(%ebp),%edx
  801442:	8b 52 0c             	mov    0xc(%edx),%edx
  801445:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80144b:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801450:	50                   	push   %eax
  801451:	ff 75 0c             	pushl  0xc(%ebp)
  801454:	68 08 50 80 00       	push   $0x805008
  801459:	e8 8b f4 ff ff       	call   8008e9 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80145e:	ba 00 00 00 00       	mov    $0x0,%edx
  801463:	b8 04 00 00 00       	mov    $0x4,%eax
  801468:	e8 cc fe ff ff       	call   801339 <fsipc>
	//panic("devfile_write not implemented");
}
  80146d:	c9                   	leave  
  80146e:	c3                   	ret    

0080146f <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  80146f:	55                   	push   %ebp
  801470:	89 e5                	mov    %esp,%ebp
  801472:	56                   	push   %esi
  801473:	53                   	push   %ebx
  801474:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801477:	8b 45 08             	mov    0x8(%ebp),%eax
  80147a:	8b 40 0c             	mov    0xc(%eax),%eax
  80147d:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801482:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801488:	ba 00 00 00 00       	mov    $0x0,%edx
  80148d:	b8 03 00 00 00       	mov    $0x3,%eax
  801492:	e8 a2 fe ff ff       	call   801339 <fsipc>
  801497:	89 c3                	mov    %eax,%ebx
  801499:	85 c0                	test   %eax,%eax
  80149b:	78 4b                	js     8014e8 <devfile_read+0x79>
		return r;
	assert(r <= n);
  80149d:	39 c6                	cmp    %eax,%esi
  80149f:	73 16                	jae    8014b7 <devfile_read+0x48>
  8014a1:	68 dc 26 80 00       	push   $0x8026dc
  8014a6:	68 e3 26 80 00       	push   $0x8026e3
  8014ab:	6a 7c                	push   $0x7c
  8014ad:	68 f8 26 80 00       	push   $0x8026f8
  8014b2:	e8 24 0a 00 00       	call   801edb <_panic>
	assert(r <= PGSIZE);
  8014b7:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8014bc:	7e 16                	jle    8014d4 <devfile_read+0x65>
  8014be:	68 03 27 80 00       	push   $0x802703
  8014c3:	68 e3 26 80 00       	push   $0x8026e3
  8014c8:	6a 7d                	push   $0x7d
  8014ca:	68 f8 26 80 00       	push   $0x8026f8
  8014cf:	e8 07 0a 00 00       	call   801edb <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8014d4:	83 ec 04             	sub    $0x4,%esp
  8014d7:	50                   	push   %eax
  8014d8:	68 00 50 80 00       	push   $0x805000
  8014dd:	ff 75 0c             	pushl  0xc(%ebp)
  8014e0:	e8 04 f4 ff ff       	call   8008e9 <memmove>
	return r;
  8014e5:	83 c4 10             	add    $0x10,%esp
}
  8014e8:	89 d8                	mov    %ebx,%eax
  8014ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014ed:	5b                   	pop    %ebx
  8014ee:	5e                   	pop    %esi
  8014ef:	5d                   	pop    %ebp
  8014f0:	c3                   	ret    

008014f1 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8014f1:	55                   	push   %ebp
  8014f2:	89 e5                	mov    %esp,%ebp
  8014f4:	53                   	push   %ebx
  8014f5:	83 ec 20             	sub    $0x20,%esp
  8014f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8014fb:	53                   	push   %ebx
  8014fc:	e8 1d f2 ff ff       	call   80071e <strlen>
  801501:	83 c4 10             	add    $0x10,%esp
  801504:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801509:	7f 67                	jg     801572 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80150b:	83 ec 0c             	sub    $0xc,%esp
  80150e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801511:	50                   	push   %eax
  801512:	e8 9a f8 ff ff       	call   800db1 <fd_alloc>
  801517:	83 c4 10             	add    $0x10,%esp
		return r;
  80151a:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80151c:	85 c0                	test   %eax,%eax
  80151e:	78 57                	js     801577 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801520:	83 ec 08             	sub    $0x8,%esp
  801523:	53                   	push   %ebx
  801524:	68 00 50 80 00       	push   $0x805000
  801529:	e8 29 f2 ff ff       	call   800757 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80152e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801531:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801536:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801539:	b8 01 00 00 00       	mov    $0x1,%eax
  80153e:	e8 f6 fd ff ff       	call   801339 <fsipc>
  801543:	89 c3                	mov    %eax,%ebx
  801545:	83 c4 10             	add    $0x10,%esp
  801548:	85 c0                	test   %eax,%eax
  80154a:	79 14                	jns    801560 <open+0x6f>
		fd_close(fd, 0);
  80154c:	83 ec 08             	sub    $0x8,%esp
  80154f:	6a 00                	push   $0x0
  801551:	ff 75 f4             	pushl  -0xc(%ebp)
  801554:	e8 50 f9 ff ff       	call   800ea9 <fd_close>
		return r;
  801559:	83 c4 10             	add    $0x10,%esp
  80155c:	89 da                	mov    %ebx,%edx
  80155e:	eb 17                	jmp    801577 <open+0x86>
	}

	return fd2num(fd);
  801560:	83 ec 0c             	sub    $0xc,%esp
  801563:	ff 75 f4             	pushl  -0xc(%ebp)
  801566:	e8 1f f8 ff ff       	call   800d8a <fd2num>
  80156b:	89 c2                	mov    %eax,%edx
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	eb 05                	jmp    801577 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801572:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801577:	89 d0                	mov    %edx,%eax
  801579:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157c:	c9                   	leave  
  80157d:	c3                   	ret    

0080157e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801584:	ba 00 00 00 00       	mov    $0x0,%edx
  801589:	b8 08 00 00 00       	mov    $0x8,%eax
  80158e:	e8 a6 fd ff ff       	call   801339 <fsipc>
}
  801593:	c9                   	leave  
  801594:	c3                   	ret    

00801595 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801595:	55                   	push   %ebp
  801596:	89 e5                	mov    %esp,%ebp
  801598:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80159b:	68 0f 27 80 00       	push   $0x80270f
  8015a0:	ff 75 0c             	pushl  0xc(%ebp)
  8015a3:	e8 af f1 ff ff       	call   800757 <strcpy>
	return 0;
}
  8015a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8015ad:	c9                   	leave  
  8015ae:	c3                   	ret    

008015af <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8015af:	55                   	push   %ebp
  8015b0:	89 e5                	mov    %esp,%ebp
  8015b2:	53                   	push   %ebx
  8015b3:	83 ec 10             	sub    $0x10,%esp
  8015b6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8015b9:	53                   	push   %ebx
  8015ba:	e8 58 0a 00 00       	call   802017 <pageref>
  8015bf:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8015c2:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8015c7:	83 f8 01             	cmp    $0x1,%eax
  8015ca:	75 10                	jne    8015dc <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8015cc:	83 ec 0c             	sub    $0xc,%esp
  8015cf:	ff 73 0c             	pushl  0xc(%ebx)
  8015d2:	e8 c0 02 00 00       	call   801897 <nsipc_close>
  8015d7:	89 c2                	mov    %eax,%edx
  8015d9:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8015dc:	89 d0                	mov    %edx,%eax
  8015de:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e1:	c9                   	leave  
  8015e2:	c3                   	ret    

008015e3 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8015e3:	55                   	push   %ebp
  8015e4:	89 e5                	mov    %esp,%ebp
  8015e6:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8015e9:	6a 00                	push   $0x0
  8015eb:	ff 75 10             	pushl  0x10(%ebp)
  8015ee:	ff 75 0c             	pushl  0xc(%ebp)
  8015f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f4:	ff 70 0c             	pushl  0xc(%eax)
  8015f7:	e8 78 03 00 00       	call   801974 <nsipc_send>
}
  8015fc:	c9                   	leave  
  8015fd:	c3                   	ret    

008015fe <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8015fe:	55                   	push   %ebp
  8015ff:	89 e5                	mov    %esp,%ebp
  801601:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801604:	6a 00                	push   $0x0
  801606:	ff 75 10             	pushl  0x10(%ebp)
  801609:	ff 75 0c             	pushl  0xc(%ebp)
  80160c:	8b 45 08             	mov    0x8(%ebp),%eax
  80160f:	ff 70 0c             	pushl  0xc(%eax)
  801612:	e8 f1 02 00 00       	call   801908 <nsipc_recv>
}
  801617:	c9                   	leave  
  801618:	c3                   	ret    

00801619 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801619:	55                   	push   %ebp
  80161a:	89 e5                	mov    %esp,%ebp
  80161c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  80161f:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801622:	52                   	push   %edx
  801623:	50                   	push   %eax
  801624:	e8 d7 f7 ff ff       	call   800e00 <fd_lookup>
  801629:	83 c4 10             	add    $0x10,%esp
  80162c:	85 c0                	test   %eax,%eax
  80162e:	78 17                	js     801647 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801630:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801633:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801639:	39 08                	cmp    %ecx,(%eax)
  80163b:	75 05                	jne    801642 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  80163d:	8b 40 0c             	mov    0xc(%eax),%eax
  801640:	eb 05                	jmp    801647 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801642:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801647:	c9                   	leave  
  801648:	c3                   	ret    

00801649 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801649:	55                   	push   %ebp
  80164a:	89 e5                	mov    %esp,%ebp
  80164c:	56                   	push   %esi
  80164d:	53                   	push   %ebx
  80164e:	83 ec 1c             	sub    $0x1c,%esp
  801651:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801653:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801656:	50                   	push   %eax
  801657:	e8 55 f7 ff ff       	call   800db1 <fd_alloc>
  80165c:	89 c3                	mov    %eax,%ebx
  80165e:	83 c4 10             	add    $0x10,%esp
  801661:	85 c0                	test   %eax,%eax
  801663:	78 1b                	js     801680 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801665:	83 ec 04             	sub    $0x4,%esp
  801668:	68 07 04 00 00       	push   $0x407
  80166d:	ff 75 f4             	pushl  -0xc(%ebp)
  801670:	6a 00                	push   $0x0
  801672:	e8 e3 f4 ff ff       	call   800b5a <sys_page_alloc>
  801677:	89 c3                	mov    %eax,%ebx
  801679:	83 c4 10             	add    $0x10,%esp
  80167c:	85 c0                	test   %eax,%eax
  80167e:	79 10                	jns    801690 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801680:	83 ec 0c             	sub    $0xc,%esp
  801683:	56                   	push   %esi
  801684:	e8 0e 02 00 00       	call   801897 <nsipc_close>
		return r;
  801689:	83 c4 10             	add    $0x10,%esp
  80168c:	89 d8                	mov    %ebx,%eax
  80168e:	eb 24                	jmp    8016b4 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801690:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801696:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801699:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80169b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  8016a5:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  8016a8:	83 ec 0c             	sub    $0xc,%esp
  8016ab:	50                   	push   %eax
  8016ac:	e8 d9 f6 ff ff       	call   800d8a <fd2num>
  8016b1:	83 c4 10             	add    $0x10,%esp
}
  8016b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8016b7:	5b                   	pop    %ebx
  8016b8:	5e                   	pop    %esi
  8016b9:	5d                   	pop    %ebp
  8016ba:	c3                   	ret    

008016bb <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c4:	e8 50 ff ff ff       	call   801619 <fd2sockid>
		return r;
  8016c9:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016cb:	85 c0                	test   %eax,%eax
  8016cd:	78 1f                	js     8016ee <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016cf:	83 ec 04             	sub    $0x4,%esp
  8016d2:	ff 75 10             	pushl  0x10(%ebp)
  8016d5:	ff 75 0c             	pushl  0xc(%ebp)
  8016d8:	50                   	push   %eax
  8016d9:	e8 12 01 00 00       	call   8017f0 <nsipc_accept>
  8016de:	83 c4 10             	add    $0x10,%esp
		return r;
  8016e1:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8016e3:	85 c0                	test   %eax,%eax
  8016e5:	78 07                	js     8016ee <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8016e7:	e8 5d ff ff ff       	call   801649 <alloc_sockfd>
  8016ec:	89 c1                	mov    %eax,%ecx
}
  8016ee:	89 c8                	mov    %ecx,%eax
  8016f0:	c9                   	leave  
  8016f1:	c3                   	ret    

008016f2 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8016f2:	55                   	push   %ebp
  8016f3:	89 e5                	mov    %esp,%ebp
  8016f5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8016f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016fb:	e8 19 ff ff ff       	call   801619 <fd2sockid>
  801700:	85 c0                	test   %eax,%eax
  801702:	78 12                	js     801716 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801704:	83 ec 04             	sub    $0x4,%esp
  801707:	ff 75 10             	pushl  0x10(%ebp)
  80170a:	ff 75 0c             	pushl  0xc(%ebp)
  80170d:	50                   	push   %eax
  80170e:	e8 2d 01 00 00       	call   801840 <nsipc_bind>
  801713:	83 c4 10             	add    $0x10,%esp
}
  801716:	c9                   	leave  
  801717:	c3                   	ret    

00801718 <shutdown>:

int
shutdown(int s, int how)
{
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80171e:	8b 45 08             	mov    0x8(%ebp),%eax
  801721:	e8 f3 fe ff ff       	call   801619 <fd2sockid>
  801726:	85 c0                	test   %eax,%eax
  801728:	78 0f                	js     801739 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  80172a:	83 ec 08             	sub    $0x8,%esp
  80172d:	ff 75 0c             	pushl  0xc(%ebp)
  801730:	50                   	push   %eax
  801731:	e8 3f 01 00 00       	call   801875 <nsipc_shutdown>
  801736:	83 c4 10             	add    $0x10,%esp
}
  801739:	c9                   	leave  
  80173a:	c3                   	ret    

0080173b <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  80173b:	55                   	push   %ebp
  80173c:	89 e5                	mov    %esp,%ebp
  80173e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801741:	8b 45 08             	mov    0x8(%ebp),%eax
  801744:	e8 d0 fe ff ff       	call   801619 <fd2sockid>
  801749:	85 c0                	test   %eax,%eax
  80174b:	78 12                	js     80175f <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  80174d:	83 ec 04             	sub    $0x4,%esp
  801750:	ff 75 10             	pushl  0x10(%ebp)
  801753:	ff 75 0c             	pushl  0xc(%ebp)
  801756:	50                   	push   %eax
  801757:	e8 55 01 00 00       	call   8018b1 <nsipc_connect>
  80175c:	83 c4 10             	add    $0x10,%esp
}
  80175f:	c9                   	leave  
  801760:	c3                   	ret    

00801761 <listen>:

int
listen(int s, int backlog)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801767:	8b 45 08             	mov    0x8(%ebp),%eax
  80176a:	e8 aa fe ff ff       	call   801619 <fd2sockid>
  80176f:	85 c0                	test   %eax,%eax
  801771:	78 0f                	js     801782 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801773:	83 ec 08             	sub    $0x8,%esp
  801776:	ff 75 0c             	pushl  0xc(%ebp)
  801779:	50                   	push   %eax
  80177a:	e8 67 01 00 00       	call   8018e6 <nsipc_listen>
  80177f:	83 c4 10             	add    $0x10,%esp
}
  801782:	c9                   	leave  
  801783:	c3                   	ret    

00801784 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  80178a:	ff 75 10             	pushl  0x10(%ebp)
  80178d:	ff 75 0c             	pushl  0xc(%ebp)
  801790:	ff 75 08             	pushl  0x8(%ebp)
  801793:	e8 3a 02 00 00       	call   8019d2 <nsipc_socket>
  801798:	83 c4 10             	add    $0x10,%esp
  80179b:	85 c0                	test   %eax,%eax
  80179d:	78 05                	js     8017a4 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  80179f:	e8 a5 fe ff ff       	call   801649 <alloc_sockfd>
}
  8017a4:	c9                   	leave  
  8017a5:	c3                   	ret    

008017a6 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	53                   	push   %ebx
  8017aa:	83 ec 04             	sub    $0x4,%esp
  8017ad:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  8017af:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  8017b6:	75 12                	jne    8017ca <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  8017b8:	83 ec 0c             	sub    $0xc,%esp
  8017bb:	6a 02                	push   $0x2
  8017bd:	e8 1c 08 00 00       	call   801fde <ipc_find_env>
  8017c2:	a3 04 40 80 00       	mov    %eax,0x804004
  8017c7:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  8017ca:	6a 07                	push   $0x7
  8017cc:	68 00 60 80 00       	push   $0x806000
  8017d1:	53                   	push   %ebx
  8017d2:	ff 35 04 40 80 00    	pushl  0x804004
  8017d8:	e8 ad 07 00 00       	call   801f8a <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  8017dd:	83 c4 0c             	add    $0xc,%esp
  8017e0:	6a 00                	push   $0x0
  8017e2:	6a 00                	push   $0x0
  8017e4:	6a 00                	push   $0x0
  8017e6:	e8 36 07 00 00       	call   801f21 <ipc_recv>
}
  8017eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ee:	c9                   	leave  
  8017ef:	c3                   	ret    

008017f0 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	56                   	push   %esi
  8017f4:	53                   	push   %ebx
  8017f5:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  8017f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fb:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801800:	8b 06                	mov    (%esi),%eax
  801802:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801807:	b8 01 00 00 00       	mov    $0x1,%eax
  80180c:	e8 95 ff ff ff       	call   8017a6 <nsipc>
  801811:	89 c3                	mov    %eax,%ebx
  801813:	85 c0                	test   %eax,%eax
  801815:	78 20                	js     801837 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801817:	83 ec 04             	sub    $0x4,%esp
  80181a:	ff 35 10 60 80 00    	pushl  0x806010
  801820:	68 00 60 80 00       	push   $0x806000
  801825:	ff 75 0c             	pushl  0xc(%ebp)
  801828:	e8 bc f0 ff ff       	call   8008e9 <memmove>
		*addrlen = ret->ret_addrlen;
  80182d:	a1 10 60 80 00       	mov    0x806010,%eax
  801832:	89 06                	mov    %eax,(%esi)
  801834:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801837:	89 d8                	mov    %ebx,%eax
  801839:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80183c:	5b                   	pop    %ebx
  80183d:	5e                   	pop    %esi
  80183e:	5d                   	pop    %ebp
  80183f:	c3                   	ret    

00801840 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	53                   	push   %ebx
  801844:	83 ec 08             	sub    $0x8,%esp
  801847:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  80184a:	8b 45 08             	mov    0x8(%ebp),%eax
  80184d:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801852:	53                   	push   %ebx
  801853:	ff 75 0c             	pushl  0xc(%ebp)
  801856:	68 04 60 80 00       	push   $0x806004
  80185b:	e8 89 f0 ff ff       	call   8008e9 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801860:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801866:	b8 02 00 00 00       	mov    $0x2,%eax
  80186b:	e8 36 ff ff ff       	call   8017a6 <nsipc>
}
  801870:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801873:	c9                   	leave  
  801874:	c3                   	ret    

00801875 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801875:	55                   	push   %ebp
  801876:	89 e5                	mov    %esp,%ebp
  801878:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  80187b:	8b 45 08             	mov    0x8(%ebp),%eax
  80187e:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801883:	8b 45 0c             	mov    0xc(%ebp),%eax
  801886:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  80188b:	b8 03 00 00 00       	mov    $0x3,%eax
  801890:	e8 11 ff ff ff       	call   8017a6 <nsipc>
}
  801895:	c9                   	leave  
  801896:	c3                   	ret    

00801897 <nsipc_close>:

int
nsipc_close(int s)
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  80189d:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a0:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  8018a5:	b8 04 00 00 00       	mov    $0x4,%eax
  8018aa:	e8 f7 fe ff ff       	call   8017a6 <nsipc>
}
  8018af:	c9                   	leave  
  8018b0:	c3                   	ret    

008018b1 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8018b1:	55                   	push   %ebp
  8018b2:	89 e5                	mov    %esp,%ebp
  8018b4:	53                   	push   %ebx
  8018b5:	83 ec 08             	sub    $0x8,%esp
  8018b8:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  8018bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8018be:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  8018c3:	53                   	push   %ebx
  8018c4:	ff 75 0c             	pushl  0xc(%ebp)
  8018c7:	68 04 60 80 00       	push   $0x806004
  8018cc:	e8 18 f0 ff ff       	call   8008e9 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  8018d1:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  8018d7:	b8 05 00 00 00       	mov    $0x5,%eax
  8018dc:	e8 c5 fe ff ff       	call   8017a6 <nsipc>
}
  8018e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018e4:	c9                   	leave  
  8018e5:	c3                   	ret    

008018e6 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  8018e6:	55                   	push   %ebp
  8018e7:	89 e5                	mov    %esp,%ebp
  8018e9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  8018ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ef:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  8018f4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018f7:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8018fc:	b8 06 00 00 00       	mov    $0x6,%eax
  801901:	e8 a0 fe ff ff       	call   8017a6 <nsipc>
}
  801906:	c9                   	leave  
  801907:	c3                   	ret    

00801908 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801908:	55                   	push   %ebp
  801909:	89 e5                	mov    %esp,%ebp
  80190b:	56                   	push   %esi
  80190c:	53                   	push   %ebx
  80190d:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801910:	8b 45 08             	mov    0x8(%ebp),%eax
  801913:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801918:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  80191e:	8b 45 14             	mov    0x14(%ebp),%eax
  801921:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801926:	b8 07 00 00 00       	mov    $0x7,%eax
  80192b:	e8 76 fe ff ff       	call   8017a6 <nsipc>
  801930:	89 c3                	mov    %eax,%ebx
  801932:	85 c0                	test   %eax,%eax
  801934:	78 35                	js     80196b <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801936:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80193b:	7f 04                	jg     801941 <nsipc_recv+0x39>
  80193d:	39 c6                	cmp    %eax,%esi
  80193f:	7d 16                	jge    801957 <nsipc_recv+0x4f>
  801941:	68 1b 27 80 00       	push   $0x80271b
  801946:	68 e3 26 80 00       	push   $0x8026e3
  80194b:	6a 62                	push   $0x62
  80194d:	68 30 27 80 00       	push   $0x802730
  801952:	e8 84 05 00 00       	call   801edb <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801957:	83 ec 04             	sub    $0x4,%esp
  80195a:	50                   	push   %eax
  80195b:	68 00 60 80 00       	push   $0x806000
  801960:	ff 75 0c             	pushl  0xc(%ebp)
  801963:	e8 81 ef ff ff       	call   8008e9 <memmove>
  801968:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80196b:	89 d8                	mov    %ebx,%eax
  80196d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801970:	5b                   	pop    %ebx
  801971:	5e                   	pop    %esi
  801972:	5d                   	pop    %ebp
  801973:	c3                   	ret    

00801974 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801974:	55                   	push   %ebp
  801975:	89 e5                	mov    %esp,%ebp
  801977:	53                   	push   %ebx
  801978:	83 ec 04             	sub    $0x4,%esp
  80197b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  80197e:	8b 45 08             	mov    0x8(%ebp),%eax
  801981:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801986:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  80198c:	7e 16                	jle    8019a4 <nsipc_send+0x30>
  80198e:	68 3c 27 80 00       	push   $0x80273c
  801993:	68 e3 26 80 00       	push   $0x8026e3
  801998:	6a 6d                	push   $0x6d
  80199a:	68 30 27 80 00       	push   $0x802730
  80199f:	e8 37 05 00 00       	call   801edb <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8019a4:	83 ec 04             	sub    $0x4,%esp
  8019a7:	53                   	push   %ebx
  8019a8:	ff 75 0c             	pushl  0xc(%ebp)
  8019ab:	68 0c 60 80 00       	push   $0x80600c
  8019b0:	e8 34 ef ff ff       	call   8008e9 <memmove>
	nsipcbuf.send.req_size = size;
  8019b5:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  8019bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8019be:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  8019c3:	b8 08 00 00 00       	mov    $0x8,%eax
  8019c8:	e8 d9 fd ff ff       	call   8017a6 <nsipc>
}
  8019cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d0:	c9                   	leave  
  8019d1:	c3                   	ret    

008019d2 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8019d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019db:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  8019e0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019e3:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  8019e8:	8b 45 10             	mov    0x10(%ebp),%eax
  8019eb:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  8019f0:	b8 09 00 00 00       	mov    $0x9,%eax
  8019f5:	e8 ac fd ff ff       	call   8017a6 <nsipc>
}
  8019fa:	c9                   	leave  
  8019fb:	c3                   	ret    

008019fc <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8019fc:	55                   	push   %ebp
  8019fd:	89 e5                	mov    %esp,%ebp
  8019ff:	56                   	push   %esi
  801a00:	53                   	push   %ebx
  801a01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a04:	83 ec 0c             	sub    $0xc,%esp
  801a07:	ff 75 08             	pushl  0x8(%ebp)
  801a0a:	e8 8b f3 ff ff       	call   800d9a <fd2data>
  801a0f:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801a11:	83 c4 08             	add    $0x8,%esp
  801a14:	68 48 27 80 00       	push   $0x802748
  801a19:	53                   	push   %ebx
  801a1a:	e8 38 ed ff ff       	call   800757 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801a1f:	8b 46 04             	mov    0x4(%esi),%eax
  801a22:	2b 06                	sub    (%esi),%eax
  801a24:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801a2a:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a31:	00 00 00 
	stat->st_dev = &devpipe;
  801a34:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801a3b:	30 80 00 
	return 0;
}
  801a3e:	b8 00 00 00 00       	mov    $0x0,%eax
  801a43:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a46:	5b                   	pop    %ebx
  801a47:	5e                   	pop    %esi
  801a48:	5d                   	pop    %ebp
  801a49:	c3                   	ret    

00801a4a <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801a4a:	55                   	push   %ebp
  801a4b:	89 e5                	mov    %esp,%ebp
  801a4d:	53                   	push   %ebx
  801a4e:	83 ec 0c             	sub    $0xc,%esp
  801a51:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801a54:	53                   	push   %ebx
  801a55:	6a 00                	push   $0x0
  801a57:	e8 83 f1 ff ff       	call   800bdf <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801a5c:	89 1c 24             	mov    %ebx,(%esp)
  801a5f:	e8 36 f3 ff ff       	call   800d9a <fd2data>
  801a64:	83 c4 08             	add    $0x8,%esp
  801a67:	50                   	push   %eax
  801a68:	6a 00                	push   $0x0
  801a6a:	e8 70 f1 ff ff       	call   800bdf <sys_page_unmap>
}
  801a6f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a72:	c9                   	leave  
  801a73:	c3                   	ret    

00801a74 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801a74:	55                   	push   %ebp
  801a75:	89 e5                	mov    %esp,%ebp
  801a77:	57                   	push   %edi
  801a78:	56                   	push   %esi
  801a79:	53                   	push   %ebx
  801a7a:	83 ec 1c             	sub    $0x1c,%esp
  801a7d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a80:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801a82:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801a87:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801a8a:	83 ec 0c             	sub    $0xc,%esp
  801a8d:	ff 75 e0             	pushl  -0x20(%ebp)
  801a90:	e8 82 05 00 00       	call   802017 <pageref>
  801a95:	89 c3                	mov    %eax,%ebx
  801a97:	89 3c 24             	mov    %edi,(%esp)
  801a9a:	e8 78 05 00 00       	call   802017 <pageref>
  801a9f:	83 c4 10             	add    $0x10,%esp
  801aa2:	39 c3                	cmp    %eax,%ebx
  801aa4:	0f 94 c1             	sete   %cl
  801aa7:	0f b6 c9             	movzbl %cl,%ecx
  801aaa:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801aad:	8b 15 0c 40 80 00    	mov    0x80400c,%edx
  801ab3:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ab6:	39 ce                	cmp    %ecx,%esi
  801ab8:	74 1b                	je     801ad5 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801aba:	39 c3                	cmp    %eax,%ebx
  801abc:	75 c4                	jne    801a82 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801abe:	8b 42 58             	mov    0x58(%edx),%eax
  801ac1:	ff 75 e4             	pushl  -0x1c(%ebp)
  801ac4:	50                   	push   %eax
  801ac5:	56                   	push   %esi
  801ac6:	68 4f 27 80 00       	push   $0x80274f
  801acb:	e8 83 e6 ff ff       	call   800153 <cprintf>
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	eb ad                	jmp    801a82 <_pipeisclosed+0xe>
	}
}
  801ad5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ad8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801adb:	5b                   	pop    %ebx
  801adc:	5e                   	pop    %esi
  801add:	5f                   	pop    %edi
  801ade:	5d                   	pop    %ebp
  801adf:	c3                   	ret    

00801ae0 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ae0:	55                   	push   %ebp
  801ae1:	89 e5                	mov    %esp,%ebp
  801ae3:	57                   	push   %edi
  801ae4:	56                   	push   %esi
  801ae5:	53                   	push   %ebx
  801ae6:	83 ec 28             	sub    $0x28,%esp
  801ae9:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801aec:	56                   	push   %esi
  801aed:	e8 a8 f2 ff ff       	call   800d9a <fd2data>
  801af2:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801af4:	83 c4 10             	add    $0x10,%esp
  801af7:	bf 00 00 00 00       	mov    $0x0,%edi
  801afc:	eb 4b                	jmp    801b49 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801afe:	89 da                	mov    %ebx,%edx
  801b00:	89 f0                	mov    %esi,%eax
  801b02:	e8 6d ff ff ff       	call   801a74 <_pipeisclosed>
  801b07:	85 c0                	test   %eax,%eax
  801b09:	75 48                	jne    801b53 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b0b:	e8 2b f0 ff ff       	call   800b3b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801b10:	8b 43 04             	mov    0x4(%ebx),%eax
  801b13:	8b 0b                	mov    (%ebx),%ecx
  801b15:	8d 51 20             	lea    0x20(%ecx),%edx
  801b18:	39 d0                	cmp    %edx,%eax
  801b1a:	73 e2                	jae    801afe <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801b1c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b1f:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801b23:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801b26:	89 c2                	mov    %eax,%edx
  801b28:	c1 fa 1f             	sar    $0x1f,%edx
  801b2b:	89 d1                	mov    %edx,%ecx
  801b2d:	c1 e9 1b             	shr    $0x1b,%ecx
  801b30:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801b33:	83 e2 1f             	and    $0x1f,%edx
  801b36:	29 ca                	sub    %ecx,%edx
  801b38:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801b3c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801b40:	83 c0 01             	add    $0x1,%eax
  801b43:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b46:	83 c7 01             	add    $0x1,%edi
  801b49:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801b4c:	75 c2                	jne    801b10 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801b4e:	8b 45 10             	mov    0x10(%ebp),%eax
  801b51:	eb 05                	jmp    801b58 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801b53:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801b58:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b5b:	5b                   	pop    %ebx
  801b5c:	5e                   	pop    %esi
  801b5d:	5f                   	pop    %edi
  801b5e:	5d                   	pop    %ebp
  801b5f:	c3                   	ret    

00801b60 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801b60:	55                   	push   %ebp
  801b61:	89 e5                	mov    %esp,%ebp
  801b63:	57                   	push   %edi
  801b64:	56                   	push   %esi
  801b65:	53                   	push   %ebx
  801b66:	83 ec 18             	sub    $0x18,%esp
  801b69:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801b6c:	57                   	push   %edi
  801b6d:	e8 28 f2 ff ff       	call   800d9a <fd2data>
  801b72:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b74:	83 c4 10             	add    $0x10,%esp
  801b77:	bb 00 00 00 00       	mov    $0x0,%ebx
  801b7c:	eb 3d                	jmp    801bbb <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801b7e:	85 db                	test   %ebx,%ebx
  801b80:	74 04                	je     801b86 <devpipe_read+0x26>
				return i;
  801b82:	89 d8                	mov    %ebx,%eax
  801b84:	eb 44                	jmp    801bca <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801b86:	89 f2                	mov    %esi,%edx
  801b88:	89 f8                	mov    %edi,%eax
  801b8a:	e8 e5 fe ff ff       	call   801a74 <_pipeisclosed>
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	75 32                	jne    801bc5 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801b93:	e8 a3 ef ff ff       	call   800b3b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801b98:	8b 06                	mov    (%esi),%eax
  801b9a:	3b 46 04             	cmp    0x4(%esi),%eax
  801b9d:	74 df                	je     801b7e <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b9f:	99                   	cltd   
  801ba0:	c1 ea 1b             	shr    $0x1b,%edx
  801ba3:	01 d0                	add    %edx,%eax
  801ba5:	83 e0 1f             	and    $0x1f,%eax
  801ba8:	29 d0                	sub    %edx,%eax
  801baa:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801baf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb2:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801bb5:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bb8:	83 c3 01             	add    $0x1,%ebx
  801bbb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801bbe:	75 d8                	jne    801b98 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801bc0:	8b 45 10             	mov    0x10(%ebp),%eax
  801bc3:	eb 05                	jmp    801bca <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bc5:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801bca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bcd:	5b                   	pop    %ebx
  801bce:	5e                   	pop    %esi
  801bcf:	5f                   	pop    %edi
  801bd0:	5d                   	pop    %ebp
  801bd1:	c3                   	ret    

00801bd2 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	56                   	push   %esi
  801bd6:	53                   	push   %ebx
  801bd7:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801bda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdd:	50                   	push   %eax
  801bde:	e8 ce f1 ff ff       	call   800db1 <fd_alloc>
  801be3:	83 c4 10             	add    $0x10,%esp
  801be6:	89 c2                	mov    %eax,%edx
  801be8:	85 c0                	test   %eax,%eax
  801bea:	0f 88 2c 01 00 00    	js     801d1c <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bf0:	83 ec 04             	sub    $0x4,%esp
  801bf3:	68 07 04 00 00       	push   $0x407
  801bf8:	ff 75 f4             	pushl  -0xc(%ebp)
  801bfb:	6a 00                	push   $0x0
  801bfd:	e8 58 ef ff ff       	call   800b5a <sys_page_alloc>
  801c02:	83 c4 10             	add    $0x10,%esp
  801c05:	89 c2                	mov    %eax,%edx
  801c07:	85 c0                	test   %eax,%eax
  801c09:	0f 88 0d 01 00 00    	js     801d1c <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801c0f:	83 ec 0c             	sub    $0xc,%esp
  801c12:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801c15:	50                   	push   %eax
  801c16:	e8 96 f1 ff ff       	call   800db1 <fd_alloc>
  801c1b:	89 c3                	mov    %eax,%ebx
  801c1d:	83 c4 10             	add    $0x10,%esp
  801c20:	85 c0                	test   %eax,%eax
  801c22:	0f 88 e2 00 00 00    	js     801d0a <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c28:	83 ec 04             	sub    $0x4,%esp
  801c2b:	68 07 04 00 00       	push   $0x407
  801c30:	ff 75 f0             	pushl  -0x10(%ebp)
  801c33:	6a 00                	push   $0x0
  801c35:	e8 20 ef ff ff       	call   800b5a <sys_page_alloc>
  801c3a:	89 c3                	mov    %eax,%ebx
  801c3c:	83 c4 10             	add    $0x10,%esp
  801c3f:	85 c0                	test   %eax,%eax
  801c41:	0f 88 c3 00 00 00    	js     801d0a <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801c47:	83 ec 0c             	sub    $0xc,%esp
  801c4a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c4d:	e8 48 f1 ff ff       	call   800d9a <fd2data>
  801c52:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c54:	83 c4 0c             	add    $0xc,%esp
  801c57:	68 07 04 00 00       	push   $0x407
  801c5c:	50                   	push   %eax
  801c5d:	6a 00                	push   $0x0
  801c5f:	e8 f6 ee ff ff       	call   800b5a <sys_page_alloc>
  801c64:	89 c3                	mov    %eax,%ebx
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	85 c0                	test   %eax,%eax
  801c6b:	0f 88 89 00 00 00    	js     801cfa <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c71:	83 ec 0c             	sub    $0xc,%esp
  801c74:	ff 75 f0             	pushl  -0x10(%ebp)
  801c77:	e8 1e f1 ff ff       	call   800d9a <fd2data>
  801c7c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801c83:	50                   	push   %eax
  801c84:	6a 00                	push   $0x0
  801c86:	56                   	push   %esi
  801c87:	6a 00                	push   $0x0
  801c89:	e8 0f ef ff ff       	call   800b9d <sys_page_map>
  801c8e:	89 c3                	mov    %eax,%ebx
  801c90:	83 c4 20             	add    $0x20,%esp
  801c93:	85 c0                	test   %eax,%eax
  801c95:	78 55                	js     801cec <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801c97:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c9d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca0:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801ca2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca5:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801cac:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cb5:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801cb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801cba:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801cc1:	83 ec 0c             	sub    $0xc,%esp
  801cc4:	ff 75 f4             	pushl  -0xc(%ebp)
  801cc7:	e8 be f0 ff ff       	call   800d8a <fd2num>
  801ccc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ccf:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801cd1:	83 c4 04             	add    $0x4,%esp
  801cd4:	ff 75 f0             	pushl  -0x10(%ebp)
  801cd7:	e8 ae f0 ff ff       	call   800d8a <fd2num>
  801cdc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801cdf:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ce2:	83 c4 10             	add    $0x10,%esp
  801ce5:	ba 00 00 00 00       	mov    $0x0,%edx
  801cea:	eb 30                	jmp    801d1c <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801cec:	83 ec 08             	sub    $0x8,%esp
  801cef:	56                   	push   %esi
  801cf0:	6a 00                	push   $0x0
  801cf2:	e8 e8 ee ff ff       	call   800bdf <sys_page_unmap>
  801cf7:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801cfa:	83 ec 08             	sub    $0x8,%esp
  801cfd:	ff 75 f0             	pushl  -0x10(%ebp)
  801d00:	6a 00                	push   $0x0
  801d02:	e8 d8 ee ff ff       	call   800bdf <sys_page_unmap>
  801d07:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d0a:	83 ec 08             	sub    $0x8,%esp
  801d0d:	ff 75 f4             	pushl  -0xc(%ebp)
  801d10:	6a 00                	push   $0x0
  801d12:	e8 c8 ee ff ff       	call   800bdf <sys_page_unmap>
  801d17:	83 c4 10             	add    $0x10,%esp
  801d1a:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801d1c:	89 d0                	mov    %edx,%eax
  801d1e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d21:	5b                   	pop    %ebx
  801d22:	5e                   	pop    %esi
  801d23:	5d                   	pop    %ebp
  801d24:	c3                   	ret    

00801d25 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801d25:	55                   	push   %ebp
  801d26:	89 e5                	mov    %esp,%ebp
  801d28:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801d2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d2e:	50                   	push   %eax
  801d2f:	ff 75 08             	pushl  0x8(%ebp)
  801d32:	e8 c9 f0 ff ff       	call   800e00 <fd_lookup>
  801d37:	83 c4 10             	add    $0x10,%esp
  801d3a:	85 c0                	test   %eax,%eax
  801d3c:	78 18                	js     801d56 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801d3e:	83 ec 0c             	sub    $0xc,%esp
  801d41:	ff 75 f4             	pushl  -0xc(%ebp)
  801d44:	e8 51 f0 ff ff       	call   800d9a <fd2data>
	return _pipeisclosed(fd, p);
  801d49:	89 c2                	mov    %eax,%edx
  801d4b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4e:	e8 21 fd ff ff       	call   801a74 <_pipeisclosed>
  801d53:	83 c4 10             	add    $0x10,%esp
}
  801d56:	c9                   	leave  
  801d57:	c3                   	ret    

00801d58 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801d58:	55                   	push   %ebp
  801d59:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801d5b:	b8 00 00 00 00       	mov    $0x0,%eax
  801d60:	5d                   	pop    %ebp
  801d61:	c3                   	ret    

00801d62 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801d62:	55                   	push   %ebp
  801d63:	89 e5                	mov    %esp,%ebp
  801d65:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801d68:	68 67 27 80 00       	push   $0x802767
  801d6d:	ff 75 0c             	pushl  0xc(%ebp)
  801d70:	e8 e2 e9 ff ff       	call   800757 <strcpy>
	return 0;
}
  801d75:	b8 00 00 00 00       	mov    $0x0,%eax
  801d7a:	c9                   	leave  
  801d7b:	c3                   	ret    

00801d7c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801d7c:	55                   	push   %ebp
  801d7d:	89 e5                	mov    %esp,%ebp
  801d7f:	57                   	push   %edi
  801d80:	56                   	push   %esi
  801d81:	53                   	push   %ebx
  801d82:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d88:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801d8d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801d93:	eb 2d                	jmp    801dc2 <devcons_write+0x46>
		m = n - tot;
  801d95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d98:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801d9a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801d9d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801da2:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801da5:	83 ec 04             	sub    $0x4,%esp
  801da8:	53                   	push   %ebx
  801da9:	03 45 0c             	add    0xc(%ebp),%eax
  801dac:	50                   	push   %eax
  801dad:	57                   	push   %edi
  801dae:	e8 36 eb ff ff       	call   8008e9 <memmove>
		sys_cputs(buf, m);
  801db3:	83 c4 08             	add    $0x8,%esp
  801db6:	53                   	push   %ebx
  801db7:	57                   	push   %edi
  801db8:	e8 e1 ec ff ff       	call   800a9e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801dbd:	01 de                	add    %ebx,%esi
  801dbf:	83 c4 10             	add    $0x10,%esp
  801dc2:	89 f0                	mov    %esi,%eax
  801dc4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dc7:	72 cc                	jb     801d95 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801dc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dcc:	5b                   	pop    %ebx
  801dcd:	5e                   	pop    %esi
  801dce:	5f                   	pop    %edi
  801dcf:	5d                   	pop    %ebp
  801dd0:	c3                   	ret    

00801dd1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801dd1:	55                   	push   %ebp
  801dd2:	89 e5                	mov    %esp,%ebp
  801dd4:	83 ec 08             	sub    $0x8,%esp
  801dd7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ddc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801de0:	74 2a                	je     801e0c <devcons_read+0x3b>
  801de2:	eb 05                	jmp    801de9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801de4:	e8 52 ed ff ff       	call   800b3b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801de9:	e8 ce ec ff ff       	call   800abc <sys_cgetc>
  801dee:	85 c0                	test   %eax,%eax
  801df0:	74 f2                	je     801de4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801df2:	85 c0                	test   %eax,%eax
  801df4:	78 16                	js     801e0c <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801df6:	83 f8 04             	cmp    $0x4,%eax
  801df9:	74 0c                	je     801e07 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801dfb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dfe:	88 02                	mov    %al,(%edx)
	return 1;
  801e00:	b8 01 00 00 00       	mov    $0x1,%eax
  801e05:	eb 05                	jmp    801e0c <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801e07:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801e0c:	c9                   	leave  
  801e0d:	c3                   	ret    

00801e0e <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801e0e:	55                   	push   %ebp
  801e0f:	89 e5                	mov    %esp,%ebp
  801e11:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801e14:	8b 45 08             	mov    0x8(%ebp),%eax
  801e17:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801e1a:	6a 01                	push   $0x1
  801e1c:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e1f:	50                   	push   %eax
  801e20:	e8 79 ec ff ff       	call   800a9e <sys_cputs>
}
  801e25:	83 c4 10             	add    $0x10,%esp
  801e28:	c9                   	leave  
  801e29:	c3                   	ret    

00801e2a <getchar>:

int
getchar(void)
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801e30:	6a 01                	push   $0x1
  801e32:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801e35:	50                   	push   %eax
  801e36:	6a 00                	push   $0x0
  801e38:	e8 29 f2 ff ff       	call   801066 <read>
	if (r < 0)
  801e3d:	83 c4 10             	add    $0x10,%esp
  801e40:	85 c0                	test   %eax,%eax
  801e42:	78 0f                	js     801e53 <getchar+0x29>
		return r;
	if (r < 1)
  801e44:	85 c0                	test   %eax,%eax
  801e46:	7e 06                	jle    801e4e <getchar+0x24>
		return -E_EOF;
	return c;
  801e48:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801e4c:	eb 05                	jmp    801e53 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801e4e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801e53:	c9                   	leave  
  801e54:	c3                   	ret    

00801e55 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801e55:	55                   	push   %ebp
  801e56:	89 e5                	mov    %esp,%ebp
  801e58:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e5b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e5e:	50                   	push   %eax
  801e5f:	ff 75 08             	pushl  0x8(%ebp)
  801e62:	e8 99 ef ff ff       	call   800e00 <fd_lookup>
  801e67:	83 c4 10             	add    $0x10,%esp
  801e6a:	85 c0                	test   %eax,%eax
  801e6c:	78 11                	js     801e7f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801e6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e71:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801e77:	39 10                	cmp    %edx,(%eax)
  801e79:	0f 94 c0             	sete   %al
  801e7c:	0f b6 c0             	movzbl %al,%eax
}
  801e7f:	c9                   	leave  
  801e80:	c3                   	ret    

00801e81 <opencons>:

int
opencons(void)
{
  801e81:	55                   	push   %ebp
  801e82:	89 e5                	mov    %esp,%ebp
  801e84:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e8a:	50                   	push   %eax
  801e8b:	e8 21 ef ff ff       	call   800db1 <fd_alloc>
  801e90:	83 c4 10             	add    $0x10,%esp
		return r;
  801e93:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801e95:	85 c0                	test   %eax,%eax
  801e97:	78 3e                	js     801ed7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801e99:	83 ec 04             	sub    $0x4,%esp
  801e9c:	68 07 04 00 00       	push   $0x407
  801ea1:	ff 75 f4             	pushl  -0xc(%ebp)
  801ea4:	6a 00                	push   $0x0
  801ea6:	e8 af ec ff ff       	call   800b5a <sys_page_alloc>
  801eab:	83 c4 10             	add    $0x10,%esp
		return r;
  801eae:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801eb0:	85 c0                	test   %eax,%eax
  801eb2:	78 23                	js     801ed7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801eb4:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801eba:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ebd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ec2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801ec9:	83 ec 0c             	sub    $0xc,%esp
  801ecc:	50                   	push   %eax
  801ecd:	e8 b8 ee ff ff       	call   800d8a <fd2num>
  801ed2:	89 c2                	mov    %eax,%edx
  801ed4:	83 c4 10             	add    $0x10,%esp
}
  801ed7:	89 d0                	mov    %edx,%eax
  801ed9:	c9                   	leave  
  801eda:	c3                   	ret    

00801edb <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801edb:	55                   	push   %ebp
  801edc:	89 e5                	mov    %esp,%ebp
  801ede:	56                   	push   %esi
  801edf:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ee0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ee3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801ee9:	e8 2e ec ff ff       	call   800b1c <sys_getenvid>
  801eee:	83 ec 0c             	sub    $0xc,%esp
  801ef1:	ff 75 0c             	pushl  0xc(%ebp)
  801ef4:	ff 75 08             	pushl  0x8(%ebp)
  801ef7:	56                   	push   %esi
  801ef8:	50                   	push   %eax
  801ef9:	68 74 27 80 00       	push   $0x802774
  801efe:	e8 50 e2 ff ff       	call   800153 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801f03:	83 c4 18             	add    $0x18,%esp
  801f06:	53                   	push   %ebx
  801f07:	ff 75 10             	pushl  0x10(%ebp)
  801f0a:	e8 f3 e1 ff ff       	call   800102 <vcprintf>
	cprintf("\n");
  801f0f:	c7 04 24 0c 23 80 00 	movl   $0x80230c,(%esp)
  801f16:	e8 38 e2 ff ff       	call   800153 <cprintf>
  801f1b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801f1e:	cc                   	int3   
  801f1f:	eb fd                	jmp    801f1e <_panic+0x43>

00801f21 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f21:	55                   	push   %ebp
  801f22:	89 e5                	mov    %esp,%ebp
  801f24:	56                   	push   %esi
  801f25:	53                   	push   %ebx
  801f26:	8b 75 08             	mov    0x8(%ebp),%esi
  801f29:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801f2f:	85 c0                	test   %eax,%eax
  801f31:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f36:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801f39:	83 ec 0c             	sub    $0xc,%esp
  801f3c:	50                   	push   %eax
  801f3d:	e8 c8 ed ff ff       	call   800d0a <sys_ipc_recv>
  801f42:	83 c4 10             	add    $0x10,%esp
  801f45:	85 c0                	test   %eax,%eax
  801f47:	79 16                	jns    801f5f <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801f49:	85 f6                	test   %esi,%esi
  801f4b:	74 06                	je     801f53 <ipc_recv+0x32>
            *from_env_store = 0;
  801f4d:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801f53:	85 db                	test   %ebx,%ebx
  801f55:	74 2c                	je     801f83 <ipc_recv+0x62>
            *perm_store = 0;
  801f57:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f5d:	eb 24                	jmp    801f83 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801f5f:	85 f6                	test   %esi,%esi
  801f61:	74 0a                	je     801f6d <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801f63:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801f68:	8b 40 74             	mov    0x74(%eax),%eax
  801f6b:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801f6d:	85 db                	test   %ebx,%ebx
  801f6f:	74 0a                	je     801f7b <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801f71:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801f76:	8b 40 78             	mov    0x78(%eax),%eax
  801f79:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801f7b:	a1 0c 40 80 00       	mov    0x80400c,%eax
  801f80:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801f83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f86:	5b                   	pop    %ebx
  801f87:	5e                   	pop    %esi
  801f88:	5d                   	pop    %ebp
  801f89:	c3                   	ret    

00801f8a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	57                   	push   %edi
  801f8e:	56                   	push   %esi
  801f8f:	53                   	push   %ebx
  801f90:	83 ec 0c             	sub    $0xc,%esp
  801f93:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f96:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f99:	8b 45 10             	mov    0x10(%ebp),%eax
  801f9c:	85 c0                	test   %eax,%eax
  801f9e:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801fa3:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801fa6:	eb 1c                	jmp    801fc4 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801fa8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801fab:	74 12                	je     801fbf <ipc_send+0x35>
  801fad:	50                   	push   %eax
  801fae:	68 98 27 80 00       	push   $0x802798
  801fb3:	6a 3b                	push   $0x3b
  801fb5:	68 ae 27 80 00       	push   $0x8027ae
  801fba:	e8 1c ff ff ff       	call   801edb <_panic>
		sys_yield();
  801fbf:	e8 77 eb ff ff       	call   800b3b <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801fc4:	ff 75 14             	pushl  0x14(%ebp)
  801fc7:	53                   	push   %ebx
  801fc8:	56                   	push   %esi
  801fc9:	57                   	push   %edi
  801fca:	e8 18 ed ff ff       	call   800ce7 <sys_ipc_try_send>
  801fcf:	83 c4 10             	add    $0x10,%esp
  801fd2:	85 c0                	test   %eax,%eax
  801fd4:	78 d2                	js     801fa8 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801fd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fd9:	5b                   	pop    %ebx
  801fda:	5e                   	pop    %esi
  801fdb:	5f                   	pop    %edi
  801fdc:	5d                   	pop    %ebp
  801fdd:	c3                   	ret    

00801fde <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fe4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fe9:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fec:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ff2:	8b 52 50             	mov    0x50(%edx),%edx
  801ff5:	39 ca                	cmp    %ecx,%edx
  801ff7:	75 0d                	jne    802006 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ff9:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ffc:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802001:	8b 40 48             	mov    0x48(%eax),%eax
  802004:	eb 0f                	jmp    802015 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802006:	83 c0 01             	add    $0x1,%eax
  802009:	3d 00 04 00 00       	cmp    $0x400,%eax
  80200e:	75 d9                	jne    801fe9 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802010:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802015:	5d                   	pop    %ebp
  802016:	c3                   	ret    

00802017 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802017:	55                   	push   %ebp
  802018:	89 e5                	mov    %esp,%ebp
  80201a:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80201d:	89 d0                	mov    %edx,%eax
  80201f:	c1 e8 16             	shr    $0x16,%eax
  802022:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802029:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80202e:	f6 c1 01             	test   $0x1,%cl
  802031:	74 1d                	je     802050 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802033:	c1 ea 0c             	shr    $0xc,%edx
  802036:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80203d:	f6 c2 01             	test   $0x1,%dl
  802040:	74 0e                	je     802050 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802042:	c1 ea 0c             	shr    $0xc,%edx
  802045:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80204c:	ef 
  80204d:	0f b7 c0             	movzwl %ax,%eax
}
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    
  802052:	66 90                	xchg   %ax,%ax
  802054:	66 90                	xchg   %ax,%ax
  802056:	66 90                	xchg   %ax,%ax
  802058:	66 90                	xchg   %ax,%ax
  80205a:	66 90                	xchg   %ax,%ax
  80205c:	66 90                	xchg   %ax,%ax
  80205e:	66 90                	xchg   %ax,%ax

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
