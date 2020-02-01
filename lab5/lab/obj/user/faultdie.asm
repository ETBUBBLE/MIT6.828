
obj/user/faultdie.debug：     文件格式 elf32-i386


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
  80002c:	e8 4f 00 00 00       	call   800080 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 0c             	sub    $0xc,%esp
  800039:	8b 55 08             	mov    0x8(%ebp),%edx
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  80003c:	8b 42 04             	mov    0x4(%edx),%eax
  80003f:	83 e0 07             	and    $0x7,%eax
  800042:	50                   	push   %eax
  800043:	ff 32                	pushl  (%edx)
  800045:	68 00 1f 80 00       	push   $0x801f00
  80004a:	e8 24 01 00 00       	call   800173 <cprintf>
	sys_env_destroy(sys_getenvid());
  80004f:	e8 e8 0a 00 00       	call   800b3c <sys_getenvid>
  800054:	89 04 24             	mov    %eax,(%esp)
  800057:	e8 9f 0a 00 00       	call   800afb <sys_env_destroy>
}
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	c9                   	leave  
  800060:	c3                   	ret    

00800061 <umain>:

void
umain(int argc, char **argv)
{
  800061:	55                   	push   %ebp
  800062:	89 e5                	mov    %esp,%ebp
  800064:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  800067:	68 33 00 80 00       	push   $0x800033
  80006c:	e8 fa 0c 00 00       	call   800d6b <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800071:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800078:	00 00 00 
}
  80007b:	83 c4 10             	add    $0x10,%esp
  80007e:	c9                   	leave  
  80007f:	c3                   	ret    

00800080 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800080:	55                   	push   %ebp
  800081:	89 e5                	mov    %esp,%ebp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800088:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  80008b:	e8 ac 0a 00 00       	call   800b3c <sys_getenvid>
  800090:	25 ff 03 00 00       	and    $0x3ff,%eax
  800095:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800098:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80009d:	a3 04 40 80 00       	mov    %eax,0x804004

    // save the name of the program so that panic() can use it
    if (argc > 0)
  8000a2:	85 db                	test   %ebx,%ebx
  8000a4:	7e 07                	jle    8000ad <libmain+0x2d>
        binaryname = argv[0];
  8000a6:	8b 06                	mov    (%esi),%eax
  8000a8:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  8000ad:	83 ec 08             	sub    $0x8,%esp
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	e8 aa ff ff ff       	call   800061 <umain>

    // exit gracefully
    exit();
  8000b7:	e8 0a 00 00 00       	call   8000c6 <exit>
}
  8000bc:	83 c4 10             	add    $0x10,%esp
  8000bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000c2:	5b                   	pop    %ebx
  8000c3:	5e                   	pop    %esi
  8000c4:	5d                   	pop    %ebp
  8000c5:	c3                   	ret    

008000c6 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000cc:	e8 ec 0e 00 00       	call   800fbd <close_all>
	sys_env_destroy(0);
  8000d1:	83 ec 0c             	sub    $0xc,%esp
  8000d4:	6a 00                	push   $0x0
  8000d6:	e8 20 0a 00 00       	call   800afb <sys_env_destroy>
}
  8000db:	83 c4 10             	add    $0x10,%esp
  8000de:	c9                   	leave  
  8000df:	c3                   	ret    

008000e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	53                   	push   %ebx
  8000e4:	83 ec 04             	sub    $0x4,%esp
  8000e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ea:	8b 13                	mov    (%ebx),%edx
  8000ec:	8d 42 01             	lea    0x1(%edx),%eax
  8000ef:	89 03                	mov    %eax,(%ebx)
  8000f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000f4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8000f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8000fd:	75 1a                	jne    800119 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8000ff:	83 ec 08             	sub    $0x8,%esp
  800102:	68 ff 00 00 00       	push   $0xff
  800107:	8d 43 08             	lea    0x8(%ebx),%eax
  80010a:	50                   	push   %eax
  80010b:	e8 ae 09 00 00       	call   800abe <sys_cputs>
		b->idx = 0;
  800110:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800116:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800119:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80011d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800120:	c9                   	leave  
  800121:	c3                   	ret    

00800122 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80012b:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800132:	00 00 00 
	b.cnt = 0;
  800135:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80013c:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80013f:	ff 75 0c             	pushl  0xc(%ebp)
  800142:	ff 75 08             	pushl  0x8(%ebp)
  800145:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80014b:	50                   	push   %eax
  80014c:	68 e0 00 80 00       	push   $0x8000e0
  800151:	e8 1a 01 00 00       	call   800270 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800156:	83 c4 08             	add    $0x8,%esp
  800159:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80015f:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800165:	50                   	push   %eax
  800166:	e8 53 09 00 00       	call   800abe <sys_cputs>

	return b.cnt;
}
  80016b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800179:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80017c:	50                   	push   %eax
  80017d:	ff 75 08             	pushl  0x8(%ebp)
  800180:	e8 9d ff ff ff       	call   800122 <vcprintf>
	va_end(ap);

	return cnt;
}
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	57                   	push   %edi
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 1c             	sub    $0x1c,%esp
  800190:	89 c7                	mov    %eax,%edi
  800192:	89 d6                	mov    %edx,%esi
  800194:	8b 45 08             	mov    0x8(%ebp),%eax
  800197:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80019d:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001a3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001a8:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ab:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ae:	39 d3                	cmp    %edx,%ebx
  8001b0:	72 05                	jb     8001b7 <printnum+0x30>
  8001b2:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001b5:	77 45                	ja     8001fc <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001b7:	83 ec 0c             	sub    $0xc,%esp
  8001ba:	ff 75 18             	pushl  0x18(%ebp)
  8001bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8001c0:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001c3:	53                   	push   %ebx
  8001c4:	ff 75 10             	pushl  0x10(%ebp)
  8001c7:	83 ec 08             	sub    $0x8,%esp
  8001ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001cd:	ff 75 e0             	pushl  -0x20(%ebp)
  8001d0:	ff 75 dc             	pushl  -0x24(%ebp)
  8001d3:	ff 75 d8             	pushl  -0x28(%ebp)
  8001d6:	e8 85 1a 00 00       	call   801c60 <__udivdi3>
  8001db:	83 c4 18             	add    $0x18,%esp
  8001de:	52                   	push   %edx
  8001df:	50                   	push   %eax
  8001e0:	89 f2                	mov    %esi,%edx
  8001e2:	89 f8                	mov    %edi,%eax
  8001e4:	e8 9e ff ff ff       	call   800187 <printnum>
  8001e9:	83 c4 20             	add    $0x20,%esp
  8001ec:	eb 18                	jmp    800206 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8001ee:	83 ec 08             	sub    $0x8,%esp
  8001f1:	56                   	push   %esi
  8001f2:	ff 75 18             	pushl  0x18(%ebp)
  8001f5:	ff d7                	call   *%edi
  8001f7:	83 c4 10             	add    $0x10,%esp
  8001fa:	eb 03                	jmp    8001ff <printnum+0x78>
  8001fc:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001ff:	83 eb 01             	sub    $0x1,%ebx
  800202:	85 db                	test   %ebx,%ebx
  800204:	7f e8                	jg     8001ee <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800206:	83 ec 08             	sub    $0x8,%esp
  800209:	56                   	push   %esi
  80020a:	83 ec 04             	sub    $0x4,%esp
  80020d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800210:	ff 75 e0             	pushl  -0x20(%ebp)
  800213:	ff 75 dc             	pushl  -0x24(%ebp)
  800216:	ff 75 d8             	pushl  -0x28(%ebp)
  800219:	e8 72 1b 00 00       	call   801d90 <__umoddi3>
  80021e:	83 c4 14             	add    $0x14,%esp
  800221:	0f be 80 26 1f 80 00 	movsbl 0x801f26(%eax),%eax
  800228:	50                   	push   %eax
  800229:	ff d7                	call   *%edi
}
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800231:	5b                   	pop    %ebx
  800232:	5e                   	pop    %esi
  800233:	5f                   	pop    %edi
  800234:	5d                   	pop    %ebp
  800235:	c3                   	ret    

00800236 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800236:	55                   	push   %ebp
  800237:	89 e5                	mov    %esp,%ebp
  800239:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80023c:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800240:	8b 10                	mov    (%eax),%edx
  800242:	3b 50 04             	cmp    0x4(%eax),%edx
  800245:	73 0a                	jae    800251 <sprintputch+0x1b>
		*b->buf++ = ch;
  800247:	8d 4a 01             	lea    0x1(%edx),%ecx
  80024a:	89 08                	mov    %ecx,(%eax)
  80024c:	8b 45 08             	mov    0x8(%ebp),%eax
  80024f:	88 02                	mov    %al,(%edx)
}
  800251:	5d                   	pop    %ebp
  800252:	c3                   	ret    

00800253 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800253:	55                   	push   %ebp
  800254:	89 e5                	mov    %esp,%ebp
  800256:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800259:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80025c:	50                   	push   %eax
  80025d:	ff 75 10             	pushl  0x10(%ebp)
  800260:	ff 75 0c             	pushl  0xc(%ebp)
  800263:	ff 75 08             	pushl  0x8(%ebp)
  800266:	e8 05 00 00 00       	call   800270 <vprintfmt>
	va_end(ap);
}
  80026b:	83 c4 10             	add    $0x10,%esp
  80026e:	c9                   	leave  
  80026f:	c3                   	ret    

00800270 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	57                   	push   %edi
  800274:	56                   	push   %esi
  800275:	53                   	push   %ebx
  800276:	83 ec 2c             	sub    $0x2c,%esp
  800279:	8b 75 08             	mov    0x8(%ebp),%esi
  80027c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80027f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800282:	eb 12                	jmp    800296 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800284:	85 c0                	test   %eax,%eax
  800286:	0f 84 42 04 00 00    	je     8006ce <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80028c:	83 ec 08             	sub    $0x8,%esp
  80028f:	53                   	push   %ebx
  800290:	50                   	push   %eax
  800291:	ff d6                	call   *%esi
  800293:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800296:	83 c7 01             	add    $0x1,%edi
  800299:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80029d:	83 f8 25             	cmp    $0x25,%eax
  8002a0:	75 e2                	jne    800284 <vprintfmt+0x14>
  8002a2:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002a6:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ad:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002b4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002bb:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002c0:	eb 07                	jmp    8002c9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002c5:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002c9:	8d 47 01             	lea    0x1(%edi),%eax
  8002cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002cf:	0f b6 07             	movzbl (%edi),%eax
  8002d2:	0f b6 d0             	movzbl %al,%edx
  8002d5:	83 e8 23             	sub    $0x23,%eax
  8002d8:	3c 55                	cmp    $0x55,%al
  8002da:	0f 87 d3 03 00 00    	ja     8006b3 <vprintfmt+0x443>
  8002e0:	0f b6 c0             	movzbl %al,%eax
  8002e3:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
  8002ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8002ed:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8002f1:	eb d6                	jmp    8002c9 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8002f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8002fb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8002fe:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800301:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800305:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800308:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80030b:	83 f9 09             	cmp    $0x9,%ecx
  80030e:	77 3f                	ja     80034f <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800310:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800313:	eb e9                	jmp    8002fe <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800315:	8b 45 14             	mov    0x14(%ebp),%eax
  800318:	8b 00                	mov    (%eax),%eax
  80031a:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80031d:	8b 45 14             	mov    0x14(%ebp),%eax
  800320:	8d 40 04             	lea    0x4(%eax),%eax
  800323:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800329:	eb 2a                	jmp    800355 <vprintfmt+0xe5>
  80032b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80032e:	85 c0                	test   %eax,%eax
  800330:	ba 00 00 00 00       	mov    $0x0,%edx
  800335:	0f 49 d0             	cmovns %eax,%edx
  800338:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80033e:	eb 89                	jmp    8002c9 <vprintfmt+0x59>
  800340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800343:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80034a:	e9 7a ff ff ff       	jmp    8002c9 <vprintfmt+0x59>
  80034f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800352:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800355:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800359:	0f 89 6a ff ff ff    	jns    8002c9 <vprintfmt+0x59>
				width = precision, precision = -1;
  80035f:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800362:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800365:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80036c:	e9 58 ff ff ff       	jmp    8002c9 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800371:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800374:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800377:	e9 4d ff ff ff       	jmp    8002c9 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80037c:	8b 45 14             	mov    0x14(%ebp),%eax
  80037f:	8d 78 04             	lea    0x4(%eax),%edi
  800382:	83 ec 08             	sub    $0x8,%esp
  800385:	53                   	push   %ebx
  800386:	ff 30                	pushl  (%eax)
  800388:	ff d6                	call   *%esi
			break;
  80038a:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80038d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800393:	e9 fe fe ff ff       	jmp    800296 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800398:	8b 45 14             	mov    0x14(%ebp),%eax
  80039b:	8d 78 04             	lea    0x4(%eax),%edi
  80039e:	8b 00                	mov    (%eax),%eax
  8003a0:	99                   	cltd   
  8003a1:	31 d0                	xor    %edx,%eax
  8003a3:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003a5:	83 f8 0f             	cmp    $0xf,%eax
  8003a8:	7f 0b                	jg     8003b5 <vprintfmt+0x145>
  8003aa:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  8003b1:	85 d2                	test   %edx,%edx
  8003b3:	75 1b                	jne    8003d0 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003b5:	50                   	push   %eax
  8003b6:	68 3e 1f 80 00       	push   $0x801f3e
  8003bb:	53                   	push   %ebx
  8003bc:	56                   	push   %esi
  8003bd:	e8 91 fe ff ff       	call   800253 <printfmt>
  8003c2:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003c5:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8003cb:	e9 c6 fe ff ff       	jmp    800296 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8003d0:	52                   	push   %edx
  8003d1:	68 15 23 80 00       	push   $0x802315
  8003d6:	53                   	push   %ebx
  8003d7:	56                   	push   %esi
  8003d8:	e8 76 fe ff ff       	call   800253 <printfmt>
  8003dd:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003e0:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003e6:	e9 ab fe ff ff       	jmp    800296 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8003eb:	8b 45 14             	mov    0x14(%ebp),%eax
  8003ee:	83 c0 04             	add    $0x4,%eax
  8003f1:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8003f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f7:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8003f9:	85 ff                	test   %edi,%edi
  8003fb:	b8 37 1f 80 00       	mov    $0x801f37,%eax
  800400:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800403:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800407:	0f 8e 94 00 00 00    	jle    8004a1 <vprintfmt+0x231>
  80040d:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800411:	0f 84 98 00 00 00    	je     8004af <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800417:	83 ec 08             	sub    $0x8,%esp
  80041a:	ff 75 d0             	pushl  -0x30(%ebp)
  80041d:	57                   	push   %edi
  80041e:	e8 33 03 00 00       	call   800756 <strnlen>
  800423:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800426:	29 c1                	sub    %eax,%ecx
  800428:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80042b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80042e:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800432:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800435:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800438:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80043a:	eb 0f                	jmp    80044b <vprintfmt+0x1db>
					putch(padc, putdat);
  80043c:	83 ec 08             	sub    $0x8,%esp
  80043f:	53                   	push   %ebx
  800440:	ff 75 e0             	pushl  -0x20(%ebp)
  800443:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800445:	83 ef 01             	sub    $0x1,%edi
  800448:	83 c4 10             	add    $0x10,%esp
  80044b:	85 ff                	test   %edi,%edi
  80044d:	7f ed                	jg     80043c <vprintfmt+0x1cc>
  80044f:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800452:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800455:	85 c9                	test   %ecx,%ecx
  800457:	b8 00 00 00 00       	mov    $0x0,%eax
  80045c:	0f 49 c1             	cmovns %ecx,%eax
  80045f:	29 c1                	sub    %eax,%ecx
  800461:	89 75 08             	mov    %esi,0x8(%ebp)
  800464:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800467:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80046a:	89 cb                	mov    %ecx,%ebx
  80046c:	eb 4d                	jmp    8004bb <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80046e:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800472:	74 1b                	je     80048f <vprintfmt+0x21f>
  800474:	0f be c0             	movsbl %al,%eax
  800477:	83 e8 20             	sub    $0x20,%eax
  80047a:	83 f8 5e             	cmp    $0x5e,%eax
  80047d:	76 10                	jbe    80048f <vprintfmt+0x21f>
					putch('?', putdat);
  80047f:	83 ec 08             	sub    $0x8,%esp
  800482:	ff 75 0c             	pushl  0xc(%ebp)
  800485:	6a 3f                	push   $0x3f
  800487:	ff 55 08             	call   *0x8(%ebp)
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	eb 0d                	jmp    80049c <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  80048f:	83 ec 08             	sub    $0x8,%esp
  800492:	ff 75 0c             	pushl  0xc(%ebp)
  800495:	52                   	push   %edx
  800496:	ff 55 08             	call   *0x8(%ebp)
  800499:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80049c:	83 eb 01             	sub    $0x1,%ebx
  80049f:	eb 1a                	jmp    8004bb <vprintfmt+0x24b>
  8004a1:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a4:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a7:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004aa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ad:	eb 0c                	jmp    8004bb <vprintfmt+0x24b>
  8004af:	89 75 08             	mov    %esi,0x8(%ebp)
  8004b2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004b5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004b8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004bb:	83 c7 01             	add    $0x1,%edi
  8004be:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004c2:	0f be d0             	movsbl %al,%edx
  8004c5:	85 d2                	test   %edx,%edx
  8004c7:	74 23                	je     8004ec <vprintfmt+0x27c>
  8004c9:	85 f6                	test   %esi,%esi
  8004cb:	78 a1                	js     80046e <vprintfmt+0x1fe>
  8004cd:	83 ee 01             	sub    $0x1,%esi
  8004d0:	79 9c                	jns    80046e <vprintfmt+0x1fe>
  8004d2:	89 df                	mov    %ebx,%edi
  8004d4:	8b 75 08             	mov    0x8(%ebp),%esi
  8004d7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004da:	eb 18                	jmp    8004f4 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8004dc:	83 ec 08             	sub    $0x8,%esp
  8004df:	53                   	push   %ebx
  8004e0:	6a 20                	push   $0x20
  8004e2:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8004e4:	83 ef 01             	sub    $0x1,%edi
  8004e7:	83 c4 10             	add    $0x10,%esp
  8004ea:	eb 08                	jmp    8004f4 <vprintfmt+0x284>
  8004ec:	89 df                	mov    %ebx,%edi
  8004ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f4:	85 ff                	test   %edi,%edi
  8004f6:	7f e4                	jg     8004dc <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004f8:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004fb:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8004fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800501:	e9 90 fd ff ff       	jmp    800296 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800506:	83 f9 01             	cmp    $0x1,%ecx
  800509:	7e 19                	jle    800524 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80050b:	8b 45 14             	mov    0x14(%ebp),%eax
  80050e:	8b 50 04             	mov    0x4(%eax),%edx
  800511:	8b 00                	mov    (%eax),%eax
  800513:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800516:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800519:	8b 45 14             	mov    0x14(%ebp),%eax
  80051c:	8d 40 08             	lea    0x8(%eax),%eax
  80051f:	89 45 14             	mov    %eax,0x14(%ebp)
  800522:	eb 38                	jmp    80055c <vprintfmt+0x2ec>
	else if (lflag)
  800524:	85 c9                	test   %ecx,%ecx
  800526:	74 1b                	je     800543 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8b 00                	mov    (%eax),%eax
  80052d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800530:	89 c1                	mov    %eax,%ecx
  800532:	c1 f9 1f             	sar    $0x1f,%ecx
  800535:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800538:	8b 45 14             	mov    0x14(%ebp),%eax
  80053b:	8d 40 04             	lea    0x4(%eax),%eax
  80053e:	89 45 14             	mov    %eax,0x14(%ebp)
  800541:	eb 19                	jmp    80055c <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800543:	8b 45 14             	mov    0x14(%ebp),%eax
  800546:	8b 00                	mov    (%eax),%eax
  800548:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054b:	89 c1                	mov    %eax,%ecx
  80054d:	c1 f9 1f             	sar    $0x1f,%ecx
  800550:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800553:	8b 45 14             	mov    0x14(%ebp),%eax
  800556:	8d 40 04             	lea    0x4(%eax),%eax
  800559:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80055c:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80055f:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800562:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800567:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80056b:	0f 89 0e 01 00 00    	jns    80067f <vprintfmt+0x40f>
				putch('-', putdat);
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	53                   	push   %ebx
  800575:	6a 2d                	push   $0x2d
  800577:	ff d6                	call   *%esi
				num = -(long long) num;
  800579:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80057c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80057f:	f7 da                	neg    %edx
  800581:	83 d1 00             	adc    $0x0,%ecx
  800584:	f7 d9                	neg    %ecx
  800586:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800589:	b8 0a 00 00 00       	mov    $0xa,%eax
  80058e:	e9 ec 00 00 00       	jmp    80067f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800593:	83 f9 01             	cmp    $0x1,%ecx
  800596:	7e 18                	jle    8005b0 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800598:	8b 45 14             	mov    0x14(%ebp),%eax
  80059b:	8b 10                	mov    (%eax),%edx
  80059d:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a0:	8d 40 08             	lea    0x8(%eax),%eax
  8005a3:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005a6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ab:	e9 cf 00 00 00       	jmp    80067f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005b0:	85 c9                	test   %ecx,%ecx
  8005b2:	74 1a                	je     8005ce <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b7:	8b 10                	mov    (%eax),%edx
  8005b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005be:	8d 40 04             	lea    0x4(%eax),%eax
  8005c1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005c4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c9:	e9 b1 00 00 00       	jmp    80067f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8005ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d1:	8b 10                	mov    (%eax),%edx
  8005d3:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d8:	8d 40 04             	lea    0x4(%eax),%eax
  8005db:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005de:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e3:	e9 97 00 00 00       	jmp    80067f <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	53                   	push   %ebx
  8005ec:	6a 58                	push   $0x58
  8005ee:	ff d6                	call   *%esi
			putch('X', putdat);
  8005f0:	83 c4 08             	add    $0x8,%esp
  8005f3:	53                   	push   %ebx
  8005f4:	6a 58                	push   $0x58
  8005f6:	ff d6                	call   *%esi
			putch('X', putdat);
  8005f8:	83 c4 08             	add    $0x8,%esp
  8005fb:	53                   	push   %ebx
  8005fc:	6a 58                	push   $0x58
  8005fe:	ff d6                	call   *%esi
			break;
  800600:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800603:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800606:	e9 8b fc ff ff       	jmp    800296 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	6a 30                	push   $0x30
  800611:	ff d6                	call   *%esi
			putch('x', putdat);
  800613:	83 c4 08             	add    $0x8,%esp
  800616:	53                   	push   %ebx
  800617:	6a 78                	push   $0x78
  800619:	ff d6                	call   *%esi
			num = (unsigned long long)
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8b 10                	mov    (%eax),%edx
  800620:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800625:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800628:	8d 40 04             	lea    0x4(%eax),%eax
  80062b:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80062e:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800633:	eb 4a                	jmp    80067f <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800635:	83 f9 01             	cmp    $0x1,%ecx
  800638:	7e 15                	jle    80064f <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80063a:	8b 45 14             	mov    0x14(%ebp),%eax
  80063d:	8b 10                	mov    (%eax),%edx
  80063f:	8b 48 04             	mov    0x4(%eax),%ecx
  800642:	8d 40 08             	lea    0x8(%eax),%eax
  800645:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800648:	b8 10 00 00 00       	mov    $0x10,%eax
  80064d:	eb 30                	jmp    80067f <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80064f:	85 c9                	test   %ecx,%ecx
  800651:	74 17                	je     80066a <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800653:	8b 45 14             	mov    0x14(%ebp),%eax
  800656:	8b 10                	mov    (%eax),%edx
  800658:	b9 00 00 00 00       	mov    $0x0,%ecx
  80065d:	8d 40 04             	lea    0x4(%eax),%eax
  800660:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800663:	b8 10 00 00 00       	mov    $0x10,%eax
  800668:	eb 15                	jmp    80067f <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80066a:	8b 45 14             	mov    0x14(%ebp),%eax
  80066d:	8b 10                	mov    (%eax),%edx
  80066f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800674:	8d 40 04             	lea    0x4(%eax),%eax
  800677:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80067a:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  80067f:	83 ec 0c             	sub    $0xc,%esp
  800682:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800686:	57                   	push   %edi
  800687:	ff 75 e0             	pushl  -0x20(%ebp)
  80068a:	50                   	push   %eax
  80068b:	51                   	push   %ecx
  80068c:	52                   	push   %edx
  80068d:	89 da                	mov    %ebx,%edx
  80068f:	89 f0                	mov    %esi,%eax
  800691:	e8 f1 fa ff ff       	call   800187 <printnum>
			break;
  800696:	83 c4 20             	add    $0x20,%esp
  800699:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80069c:	e9 f5 fb ff ff       	jmp    800296 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006a1:	83 ec 08             	sub    $0x8,%esp
  8006a4:	53                   	push   %ebx
  8006a5:	52                   	push   %edx
  8006a6:	ff d6                	call   *%esi
			break;
  8006a8:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ab:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ae:	e9 e3 fb ff ff       	jmp    800296 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006b3:	83 ec 08             	sub    $0x8,%esp
  8006b6:	53                   	push   %ebx
  8006b7:	6a 25                	push   $0x25
  8006b9:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006bb:	83 c4 10             	add    $0x10,%esp
  8006be:	eb 03                	jmp    8006c3 <vprintfmt+0x453>
  8006c0:	83 ef 01             	sub    $0x1,%edi
  8006c3:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006c7:	75 f7                	jne    8006c0 <vprintfmt+0x450>
  8006c9:	e9 c8 fb ff ff       	jmp    800296 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  8006ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d1:	5b                   	pop    %ebx
  8006d2:	5e                   	pop    %esi
  8006d3:	5f                   	pop    %edi
  8006d4:	5d                   	pop    %ebp
  8006d5:	c3                   	ret    

008006d6 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006d6:	55                   	push   %ebp
  8006d7:	89 e5                	mov    %esp,%ebp
  8006d9:	83 ec 18             	sub    $0x18,%esp
  8006dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8006df:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006e2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006e5:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006e9:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006ec:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006f3:	85 c0                	test   %eax,%eax
  8006f5:	74 26                	je     80071d <vsnprintf+0x47>
  8006f7:	85 d2                	test   %edx,%edx
  8006f9:	7e 22                	jle    80071d <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006fb:	ff 75 14             	pushl  0x14(%ebp)
  8006fe:	ff 75 10             	pushl  0x10(%ebp)
  800701:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800704:	50                   	push   %eax
  800705:	68 36 02 80 00       	push   $0x800236
  80070a:	e8 61 fb ff ff       	call   800270 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80070f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800712:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800715:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800718:	83 c4 10             	add    $0x10,%esp
  80071b:	eb 05                	jmp    800722 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80071d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800722:	c9                   	leave  
  800723:	c3                   	ret    

00800724 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800724:	55                   	push   %ebp
  800725:	89 e5                	mov    %esp,%ebp
  800727:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80072a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80072d:	50                   	push   %eax
  80072e:	ff 75 10             	pushl  0x10(%ebp)
  800731:	ff 75 0c             	pushl  0xc(%ebp)
  800734:	ff 75 08             	pushl  0x8(%ebp)
  800737:	e8 9a ff ff ff       	call   8006d6 <vsnprintf>
	va_end(ap);

	return rc;
}
  80073c:	c9                   	leave  
  80073d:	c3                   	ret    

0080073e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80073e:	55                   	push   %ebp
  80073f:	89 e5                	mov    %esp,%ebp
  800741:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800744:	b8 00 00 00 00       	mov    $0x0,%eax
  800749:	eb 03                	jmp    80074e <strlen+0x10>
		n++;
  80074b:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80074e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800752:	75 f7                	jne    80074b <strlen+0xd>
		n++;
	return n;
}
  800754:	5d                   	pop    %ebp
  800755:	c3                   	ret    

00800756 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800756:	55                   	push   %ebp
  800757:	89 e5                	mov    %esp,%ebp
  800759:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075c:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80075f:	ba 00 00 00 00       	mov    $0x0,%edx
  800764:	eb 03                	jmp    800769 <strnlen+0x13>
		n++;
  800766:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800769:	39 c2                	cmp    %eax,%edx
  80076b:	74 08                	je     800775 <strnlen+0x1f>
  80076d:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800771:	75 f3                	jne    800766 <strnlen+0x10>
  800773:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800775:	5d                   	pop    %ebp
  800776:	c3                   	ret    

00800777 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800777:	55                   	push   %ebp
  800778:	89 e5                	mov    %esp,%ebp
  80077a:	53                   	push   %ebx
  80077b:	8b 45 08             	mov    0x8(%ebp),%eax
  80077e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800781:	89 c2                	mov    %eax,%edx
  800783:	83 c2 01             	add    $0x1,%edx
  800786:	83 c1 01             	add    $0x1,%ecx
  800789:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  80078d:	88 5a ff             	mov    %bl,-0x1(%edx)
  800790:	84 db                	test   %bl,%bl
  800792:	75 ef                	jne    800783 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800794:	5b                   	pop    %ebx
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	53                   	push   %ebx
  80079b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80079e:	53                   	push   %ebx
  80079f:	e8 9a ff ff ff       	call   80073e <strlen>
  8007a4:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007a7:	ff 75 0c             	pushl  0xc(%ebp)
  8007aa:	01 d8                	add    %ebx,%eax
  8007ac:	50                   	push   %eax
  8007ad:	e8 c5 ff ff ff       	call   800777 <strcpy>
	return dst;
}
  8007b2:	89 d8                	mov    %ebx,%eax
  8007b4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b7:	c9                   	leave  
  8007b8:	c3                   	ret    

008007b9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	56                   	push   %esi
  8007bd:	53                   	push   %ebx
  8007be:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c4:	89 f3                	mov    %esi,%ebx
  8007c6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007c9:	89 f2                	mov    %esi,%edx
  8007cb:	eb 0f                	jmp    8007dc <strncpy+0x23>
		*dst++ = *src;
  8007cd:	83 c2 01             	add    $0x1,%edx
  8007d0:	0f b6 01             	movzbl (%ecx),%eax
  8007d3:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007d6:	80 39 01             	cmpb   $0x1,(%ecx)
  8007d9:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007dc:	39 da                	cmp    %ebx,%edx
  8007de:	75 ed                	jne    8007cd <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8007e0:	89 f0                	mov    %esi,%eax
  8007e2:	5b                   	pop    %ebx
  8007e3:	5e                   	pop    %esi
  8007e4:	5d                   	pop    %ebp
  8007e5:	c3                   	ret    

008007e6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007e6:	55                   	push   %ebp
  8007e7:	89 e5                	mov    %esp,%ebp
  8007e9:	56                   	push   %esi
  8007ea:	53                   	push   %ebx
  8007eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ee:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f1:	8b 55 10             	mov    0x10(%ebp),%edx
  8007f4:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007f6:	85 d2                	test   %edx,%edx
  8007f8:	74 21                	je     80081b <strlcpy+0x35>
  8007fa:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007fe:	89 f2                	mov    %esi,%edx
  800800:	eb 09                	jmp    80080b <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800802:	83 c2 01             	add    $0x1,%edx
  800805:	83 c1 01             	add    $0x1,%ecx
  800808:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80080b:	39 c2                	cmp    %eax,%edx
  80080d:	74 09                	je     800818 <strlcpy+0x32>
  80080f:	0f b6 19             	movzbl (%ecx),%ebx
  800812:	84 db                	test   %bl,%bl
  800814:	75 ec                	jne    800802 <strlcpy+0x1c>
  800816:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800818:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80081b:	29 f0                	sub    %esi,%eax
}
  80081d:	5b                   	pop    %ebx
  80081e:	5e                   	pop    %esi
  80081f:	5d                   	pop    %ebp
  800820:	c3                   	ret    

00800821 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800827:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80082a:	eb 06                	jmp    800832 <strcmp+0x11>
		p++, q++;
  80082c:	83 c1 01             	add    $0x1,%ecx
  80082f:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800832:	0f b6 01             	movzbl (%ecx),%eax
  800835:	84 c0                	test   %al,%al
  800837:	74 04                	je     80083d <strcmp+0x1c>
  800839:	3a 02                	cmp    (%edx),%al
  80083b:	74 ef                	je     80082c <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80083d:	0f b6 c0             	movzbl %al,%eax
  800840:	0f b6 12             	movzbl (%edx),%edx
  800843:	29 d0                	sub    %edx,%eax
}
  800845:	5d                   	pop    %ebp
  800846:	c3                   	ret    

00800847 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	53                   	push   %ebx
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800851:	89 c3                	mov    %eax,%ebx
  800853:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800856:	eb 06                	jmp    80085e <strncmp+0x17>
		n--, p++, q++;
  800858:	83 c0 01             	add    $0x1,%eax
  80085b:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80085e:	39 d8                	cmp    %ebx,%eax
  800860:	74 15                	je     800877 <strncmp+0x30>
  800862:	0f b6 08             	movzbl (%eax),%ecx
  800865:	84 c9                	test   %cl,%cl
  800867:	74 04                	je     80086d <strncmp+0x26>
  800869:	3a 0a                	cmp    (%edx),%cl
  80086b:	74 eb                	je     800858 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80086d:	0f b6 00             	movzbl (%eax),%eax
  800870:	0f b6 12             	movzbl (%edx),%edx
  800873:	29 d0                	sub    %edx,%eax
  800875:	eb 05                	jmp    80087c <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800877:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80087c:	5b                   	pop    %ebx
  80087d:	5d                   	pop    %ebp
  80087e:	c3                   	ret    

0080087f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80087f:	55                   	push   %ebp
  800880:	89 e5                	mov    %esp,%ebp
  800882:	8b 45 08             	mov    0x8(%ebp),%eax
  800885:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800889:	eb 07                	jmp    800892 <strchr+0x13>
		if (*s == c)
  80088b:	38 ca                	cmp    %cl,%dl
  80088d:	74 0f                	je     80089e <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80088f:	83 c0 01             	add    $0x1,%eax
  800892:	0f b6 10             	movzbl (%eax),%edx
  800895:	84 d2                	test   %dl,%dl
  800897:	75 f2                	jne    80088b <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800899:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80089e:	5d                   	pop    %ebp
  80089f:	c3                   	ret    

008008a0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008aa:	eb 03                	jmp    8008af <strfind+0xf>
  8008ac:	83 c0 01             	add    $0x1,%eax
  8008af:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008b2:	38 ca                	cmp    %cl,%dl
  8008b4:	74 04                	je     8008ba <strfind+0x1a>
  8008b6:	84 d2                	test   %dl,%dl
  8008b8:	75 f2                	jne    8008ac <strfind+0xc>
			break;
	return (char *) s;
}
  8008ba:	5d                   	pop    %ebp
  8008bb:	c3                   	ret    

008008bc <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008bc:	55                   	push   %ebp
  8008bd:	89 e5                	mov    %esp,%ebp
  8008bf:	57                   	push   %edi
  8008c0:	56                   	push   %esi
  8008c1:	53                   	push   %ebx
  8008c2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008c5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008c8:	85 c9                	test   %ecx,%ecx
  8008ca:	74 36                	je     800902 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008cc:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8008d2:	75 28                	jne    8008fc <memset+0x40>
  8008d4:	f6 c1 03             	test   $0x3,%cl
  8008d7:	75 23                	jne    8008fc <memset+0x40>
		c &= 0xFF;
  8008d9:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008dd:	89 d3                	mov    %edx,%ebx
  8008df:	c1 e3 08             	shl    $0x8,%ebx
  8008e2:	89 d6                	mov    %edx,%esi
  8008e4:	c1 e6 18             	shl    $0x18,%esi
  8008e7:	89 d0                	mov    %edx,%eax
  8008e9:	c1 e0 10             	shl    $0x10,%eax
  8008ec:	09 f0                	or     %esi,%eax
  8008ee:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  8008f0:	89 d8                	mov    %ebx,%eax
  8008f2:	09 d0                	or     %edx,%eax
  8008f4:	c1 e9 02             	shr    $0x2,%ecx
  8008f7:	fc                   	cld    
  8008f8:	f3 ab                	rep stos %eax,%es:(%edi)
  8008fa:	eb 06                	jmp    800902 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ff:	fc                   	cld    
  800900:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800902:	89 f8                	mov    %edi,%eax
  800904:	5b                   	pop    %ebx
  800905:	5e                   	pop    %esi
  800906:	5f                   	pop    %edi
  800907:	5d                   	pop    %ebp
  800908:	c3                   	ret    

00800909 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	57                   	push   %edi
  80090d:	56                   	push   %esi
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	8b 75 0c             	mov    0xc(%ebp),%esi
  800914:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800917:	39 c6                	cmp    %eax,%esi
  800919:	73 35                	jae    800950 <memmove+0x47>
  80091b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80091e:	39 d0                	cmp    %edx,%eax
  800920:	73 2e                	jae    800950 <memmove+0x47>
		s += n;
		d += n;
  800922:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800925:	89 d6                	mov    %edx,%esi
  800927:	09 fe                	or     %edi,%esi
  800929:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80092f:	75 13                	jne    800944 <memmove+0x3b>
  800931:	f6 c1 03             	test   $0x3,%cl
  800934:	75 0e                	jne    800944 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800936:	83 ef 04             	sub    $0x4,%edi
  800939:	8d 72 fc             	lea    -0x4(%edx),%esi
  80093c:	c1 e9 02             	shr    $0x2,%ecx
  80093f:	fd                   	std    
  800940:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800942:	eb 09                	jmp    80094d <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800944:	83 ef 01             	sub    $0x1,%edi
  800947:	8d 72 ff             	lea    -0x1(%edx),%esi
  80094a:	fd                   	std    
  80094b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80094d:	fc                   	cld    
  80094e:	eb 1d                	jmp    80096d <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800950:	89 f2                	mov    %esi,%edx
  800952:	09 c2                	or     %eax,%edx
  800954:	f6 c2 03             	test   $0x3,%dl
  800957:	75 0f                	jne    800968 <memmove+0x5f>
  800959:	f6 c1 03             	test   $0x3,%cl
  80095c:	75 0a                	jne    800968 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80095e:	c1 e9 02             	shr    $0x2,%ecx
  800961:	89 c7                	mov    %eax,%edi
  800963:	fc                   	cld    
  800964:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800966:	eb 05                	jmp    80096d <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800968:	89 c7                	mov    %eax,%edi
  80096a:	fc                   	cld    
  80096b:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  80096d:	5e                   	pop    %esi
  80096e:	5f                   	pop    %edi
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800974:	ff 75 10             	pushl  0x10(%ebp)
  800977:	ff 75 0c             	pushl  0xc(%ebp)
  80097a:	ff 75 08             	pushl  0x8(%ebp)
  80097d:	e8 87 ff ff ff       	call   800909 <memmove>
}
  800982:	c9                   	leave  
  800983:	c3                   	ret    

00800984 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	56                   	push   %esi
  800988:	53                   	push   %ebx
  800989:	8b 45 08             	mov    0x8(%ebp),%eax
  80098c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098f:	89 c6                	mov    %eax,%esi
  800991:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800994:	eb 1a                	jmp    8009b0 <memcmp+0x2c>
		if (*s1 != *s2)
  800996:	0f b6 08             	movzbl (%eax),%ecx
  800999:	0f b6 1a             	movzbl (%edx),%ebx
  80099c:	38 d9                	cmp    %bl,%cl
  80099e:	74 0a                	je     8009aa <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009a0:	0f b6 c1             	movzbl %cl,%eax
  8009a3:	0f b6 db             	movzbl %bl,%ebx
  8009a6:	29 d8                	sub    %ebx,%eax
  8009a8:	eb 0f                	jmp    8009b9 <memcmp+0x35>
		s1++, s2++;
  8009aa:	83 c0 01             	add    $0x1,%eax
  8009ad:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009b0:	39 f0                	cmp    %esi,%eax
  8009b2:	75 e2                	jne    800996 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009b9:	5b                   	pop    %ebx
  8009ba:	5e                   	pop    %esi
  8009bb:	5d                   	pop    %ebp
  8009bc:	c3                   	ret    

008009bd <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	53                   	push   %ebx
  8009c1:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009c4:	89 c1                	mov    %eax,%ecx
  8009c6:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c9:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009cd:	eb 0a                	jmp    8009d9 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009cf:	0f b6 10             	movzbl (%eax),%edx
  8009d2:	39 da                	cmp    %ebx,%edx
  8009d4:	74 07                	je     8009dd <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8009d6:	83 c0 01             	add    $0x1,%eax
  8009d9:	39 c8                	cmp    %ecx,%eax
  8009db:	72 f2                	jb     8009cf <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8009dd:	5b                   	pop    %ebx
  8009de:	5d                   	pop    %ebp
  8009df:	c3                   	ret    

008009e0 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	57                   	push   %edi
  8009e4:	56                   	push   %esi
  8009e5:	53                   	push   %ebx
  8009e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009e9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009ec:	eb 03                	jmp    8009f1 <strtol+0x11>
		s++;
  8009ee:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009f1:	0f b6 01             	movzbl (%ecx),%eax
  8009f4:	3c 20                	cmp    $0x20,%al
  8009f6:	74 f6                	je     8009ee <strtol+0xe>
  8009f8:	3c 09                	cmp    $0x9,%al
  8009fa:	74 f2                	je     8009ee <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  8009fc:	3c 2b                	cmp    $0x2b,%al
  8009fe:	75 0a                	jne    800a0a <strtol+0x2a>
		s++;
  800a00:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a03:	bf 00 00 00 00       	mov    $0x0,%edi
  800a08:	eb 11                	jmp    800a1b <strtol+0x3b>
  800a0a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a0f:	3c 2d                	cmp    $0x2d,%al
  800a11:	75 08                	jne    800a1b <strtol+0x3b>
		s++, neg = 1;
  800a13:	83 c1 01             	add    $0x1,%ecx
  800a16:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a1b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a21:	75 15                	jne    800a38 <strtol+0x58>
  800a23:	80 39 30             	cmpb   $0x30,(%ecx)
  800a26:	75 10                	jne    800a38 <strtol+0x58>
  800a28:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a2c:	75 7c                	jne    800aaa <strtol+0xca>
		s += 2, base = 16;
  800a2e:	83 c1 02             	add    $0x2,%ecx
  800a31:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a36:	eb 16                	jmp    800a4e <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a38:	85 db                	test   %ebx,%ebx
  800a3a:	75 12                	jne    800a4e <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a3c:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a41:	80 39 30             	cmpb   $0x30,(%ecx)
  800a44:	75 08                	jne    800a4e <strtol+0x6e>
		s++, base = 8;
  800a46:	83 c1 01             	add    $0x1,%ecx
  800a49:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a4e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a53:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a56:	0f b6 11             	movzbl (%ecx),%edx
  800a59:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a5c:	89 f3                	mov    %esi,%ebx
  800a5e:	80 fb 09             	cmp    $0x9,%bl
  800a61:	77 08                	ja     800a6b <strtol+0x8b>
			dig = *s - '0';
  800a63:	0f be d2             	movsbl %dl,%edx
  800a66:	83 ea 30             	sub    $0x30,%edx
  800a69:	eb 22                	jmp    800a8d <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800a6b:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a6e:	89 f3                	mov    %esi,%ebx
  800a70:	80 fb 19             	cmp    $0x19,%bl
  800a73:	77 08                	ja     800a7d <strtol+0x9d>
			dig = *s - 'a' + 10;
  800a75:	0f be d2             	movsbl %dl,%edx
  800a78:	83 ea 57             	sub    $0x57,%edx
  800a7b:	eb 10                	jmp    800a8d <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800a7d:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a80:	89 f3                	mov    %esi,%ebx
  800a82:	80 fb 19             	cmp    $0x19,%bl
  800a85:	77 16                	ja     800a9d <strtol+0xbd>
			dig = *s - 'A' + 10;
  800a87:	0f be d2             	movsbl %dl,%edx
  800a8a:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800a8d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a90:	7d 0b                	jge    800a9d <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800a92:	83 c1 01             	add    $0x1,%ecx
  800a95:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a99:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800a9b:	eb b9                	jmp    800a56 <strtol+0x76>

	if (endptr)
  800a9d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aa1:	74 0d                	je     800ab0 <strtol+0xd0>
		*endptr = (char *) s;
  800aa3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800aa6:	89 0e                	mov    %ecx,(%esi)
  800aa8:	eb 06                	jmp    800ab0 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aaa:	85 db                	test   %ebx,%ebx
  800aac:	74 98                	je     800a46 <strtol+0x66>
  800aae:	eb 9e                	jmp    800a4e <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ab0:	89 c2                	mov    %eax,%edx
  800ab2:	f7 da                	neg    %edx
  800ab4:	85 ff                	test   %edi,%edi
  800ab6:	0f 45 c2             	cmovne %edx,%eax
}
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800abe:	55                   	push   %ebp
  800abf:	89 e5                	mov    %esp,%ebp
  800ac1:	57                   	push   %edi
  800ac2:	56                   	push   %esi
  800ac3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ac4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ac9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800acc:	8b 55 08             	mov    0x8(%ebp),%edx
  800acf:	89 c3                	mov    %eax,%ebx
  800ad1:	89 c7                	mov    %eax,%edi
  800ad3:	89 c6                	mov    %eax,%esi
  800ad5:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    

00800adc <sys_cgetc>:

int
sys_cgetc(void)
{
  800adc:	55                   	push   %ebp
  800add:	89 e5                	mov    %esp,%ebp
  800adf:	57                   	push   %edi
  800ae0:	56                   	push   %esi
  800ae1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae7:	b8 01 00 00 00       	mov    $0x1,%eax
  800aec:	89 d1                	mov    %edx,%ecx
  800aee:	89 d3                	mov    %edx,%ebx
  800af0:	89 d7                	mov    %edx,%edi
  800af2:	89 d6                	mov    %edx,%esi
  800af4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5f                   	pop    %edi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	57                   	push   %edi
  800aff:	56                   	push   %esi
  800b00:	53                   	push   %ebx
  800b01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b04:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b09:	b8 03 00 00 00       	mov    $0x3,%eax
  800b0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b11:	89 cb                	mov    %ecx,%ebx
  800b13:	89 cf                	mov    %ecx,%edi
  800b15:	89 ce                	mov    %ecx,%esi
  800b17:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b19:	85 c0                	test   %eax,%eax
  800b1b:	7e 17                	jle    800b34 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1d:	83 ec 0c             	sub    $0xc,%esp
  800b20:	50                   	push   %eax
  800b21:	6a 03                	push   $0x3
  800b23:	68 1f 22 80 00       	push   $0x80221f
  800b28:	6a 23                	push   $0x23
  800b2a:	68 3c 22 80 00       	push   $0x80223c
  800b2f:	e8 a8 0f 00 00       	call   801adc <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	ba 00 00 00 00       	mov    $0x0,%edx
  800b47:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4c:	89 d1                	mov    %edx,%ecx
  800b4e:	89 d3                	mov    %edx,%ebx
  800b50:	89 d7                	mov    %edx,%edi
  800b52:	89 d6                	mov    %edx,%esi
  800b54:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b56:	5b                   	pop    %ebx
  800b57:	5e                   	pop    %esi
  800b58:	5f                   	pop    %edi
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <sys_yield>:

void
sys_yield(void)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b61:	ba 00 00 00 00       	mov    $0x0,%edx
  800b66:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b6b:	89 d1                	mov    %edx,%ecx
  800b6d:	89 d3                	mov    %edx,%ebx
  800b6f:	89 d7                	mov    %edx,%edi
  800b71:	89 d6                	mov    %edx,%esi
  800b73:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
  800b80:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b83:	be 00 00 00 00       	mov    $0x0,%esi
  800b88:	b8 04 00 00 00       	mov    $0x4,%eax
  800b8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b90:	8b 55 08             	mov    0x8(%ebp),%edx
  800b93:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800b96:	89 f7                	mov    %esi,%edi
  800b98:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b9a:	85 c0                	test   %eax,%eax
  800b9c:	7e 17                	jle    800bb5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9e:	83 ec 0c             	sub    $0xc,%esp
  800ba1:	50                   	push   %eax
  800ba2:	6a 04                	push   $0x4
  800ba4:	68 1f 22 80 00       	push   $0x80221f
  800ba9:	6a 23                	push   $0x23
  800bab:	68 3c 22 80 00       	push   $0x80223c
  800bb0:	e8 27 0f 00 00       	call   801adc <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bb5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bb8:	5b                   	pop    %ebx
  800bb9:	5e                   	pop    %esi
  800bba:	5f                   	pop    %edi
  800bbb:	5d                   	pop    %ebp
  800bbc:	c3                   	ret    

00800bbd <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bbd:	55                   	push   %ebp
  800bbe:	89 e5                	mov    %esp,%ebp
  800bc0:	57                   	push   %edi
  800bc1:	56                   	push   %esi
  800bc2:	53                   	push   %ebx
  800bc3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bce:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd4:	8b 7d 14             	mov    0x14(%ebp),%edi
  800bd7:	8b 75 18             	mov    0x18(%ebp),%esi
  800bda:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdc:	85 c0                	test   %eax,%eax
  800bde:	7e 17                	jle    800bf7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800be0:	83 ec 0c             	sub    $0xc,%esp
  800be3:	50                   	push   %eax
  800be4:	6a 05                	push   $0x5
  800be6:	68 1f 22 80 00       	push   $0x80221f
  800beb:	6a 23                	push   $0x23
  800bed:	68 3c 22 80 00       	push   $0x80223c
  800bf2:	e8 e5 0e 00 00       	call   801adc <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800bf7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bfa:	5b                   	pop    %ebx
  800bfb:	5e                   	pop    %esi
  800bfc:	5f                   	pop    %edi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	57                   	push   %edi
  800c03:	56                   	push   %esi
  800c04:	53                   	push   %ebx
  800c05:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c08:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c0d:	b8 06 00 00 00       	mov    $0x6,%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c15:	8b 55 08             	mov    0x8(%ebp),%edx
  800c18:	89 df                	mov    %ebx,%edi
  800c1a:	89 de                	mov    %ebx,%esi
  800c1c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1e:	85 c0                	test   %eax,%eax
  800c20:	7e 17                	jle    800c39 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c22:	83 ec 0c             	sub    $0xc,%esp
  800c25:	50                   	push   %eax
  800c26:	6a 06                	push   $0x6
  800c28:	68 1f 22 80 00       	push   $0x80221f
  800c2d:	6a 23                	push   $0x23
  800c2f:	68 3c 22 80 00       	push   $0x80223c
  800c34:	e8 a3 0e 00 00       	call   801adc <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c39:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3c:	5b                   	pop    %ebx
  800c3d:	5e                   	pop    %esi
  800c3e:	5f                   	pop    %edi
  800c3f:	5d                   	pop    %ebp
  800c40:	c3                   	ret    

00800c41 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c41:	55                   	push   %ebp
  800c42:	89 e5                	mov    %esp,%ebp
  800c44:	57                   	push   %edi
  800c45:	56                   	push   %esi
  800c46:	53                   	push   %ebx
  800c47:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4a:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4f:	b8 08 00 00 00       	mov    $0x8,%eax
  800c54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	89 df                	mov    %ebx,%edi
  800c5c:	89 de                	mov    %ebx,%esi
  800c5e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c60:	85 c0                	test   %eax,%eax
  800c62:	7e 17                	jle    800c7b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c64:	83 ec 0c             	sub    $0xc,%esp
  800c67:	50                   	push   %eax
  800c68:	6a 08                	push   $0x8
  800c6a:	68 1f 22 80 00       	push   $0x80221f
  800c6f:	6a 23                	push   $0x23
  800c71:	68 3c 22 80 00       	push   $0x80223c
  800c76:	e8 61 0e 00 00       	call   801adc <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800c7b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7e:	5b                   	pop    %ebx
  800c7f:	5e                   	pop    %esi
  800c80:	5f                   	pop    %edi
  800c81:	5d                   	pop    %ebp
  800c82:	c3                   	ret    

00800c83 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c83:	55                   	push   %ebp
  800c84:	89 e5                	mov    %esp,%ebp
  800c86:	57                   	push   %edi
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c91:	b8 09 00 00 00       	mov    $0x9,%eax
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9c:	89 df                	mov    %ebx,%edi
  800c9e:	89 de                	mov    %ebx,%esi
  800ca0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca2:	85 c0                	test   %eax,%eax
  800ca4:	7e 17                	jle    800cbd <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca6:	83 ec 0c             	sub    $0xc,%esp
  800ca9:	50                   	push   %eax
  800caa:	6a 09                	push   $0x9
  800cac:	68 1f 22 80 00       	push   $0x80221f
  800cb1:	6a 23                	push   $0x23
  800cb3:	68 3c 22 80 00       	push   $0x80223c
  800cb8:	e8 1f 0e 00 00       	call   801adc <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5f                   	pop    %edi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cce:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cd8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cdb:	8b 55 08             	mov    0x8(%ebp),%edx
  800cde:	89 df                	mov    %ebx,%edi
  800ce0:	89 de                	mov    %ebx,%esi
  800ce2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce4:	85 c0                	test   %eax,%eax
  800ce6:	7e 17                	jle    800cff <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce8:	83 ec 0c             	sub    $0xc,%esp
  800ceb:	50                   	push   %eax
  800cec:	6a 0a                	push   $0xa
  800cee:	68 1f 22 80 00       	push   $0x80221f
  800cf3:	6a 23                	push   $0x23
  800cf5:	68 3c 22 80 00       	push   $0x80223c
  800cfa:	e8 dd 0d 00 00       	call   801adc <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800cff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0d:	be 00 00 00 00       	mov    $0x0,%esi
  800d12:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d17:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d20:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d23:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	57                   	push   %edi
  800d2e:	56                   	push   %esi
  800d2f:	53                   	push   %ebx
  800d30:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d33:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d38:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d40:	89 cb                	mov    %ecx,%ebx
  800d42:	89 cf                	mov    %ecx,%edi
  800d44:	89 ce                	mov    %ecx,%esi
  800d46:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d48:	85 c0                	test   %eax,%eax
  800d4a:	7e 17                	jle    800d63 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d4c:	83 ec 0c             	sub    $0xc,%esp
  800d4f:	50                   	push   %eax
  800d50:	6a 0d                	push   $0xd
  800d52:	68 1f 22 80 00       	push   $0x80221f
  800d57:	6a 23                	push   $0x23
  800d59:	68 3c 22 80 00       	push   $0x80223c
  800d5e:	e8 79 0d 00 00       	call   801adc <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d63:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d71:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d78:	75 4a                	jne    800dc4 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  800d7a:	a1 04 40 80 00       	mov    0x804004,%eax
  800d7f:	8b 40 48             	mov    0x48(%eax),%eax
  800d82:	83 ec 04             	sub    $0x4,%esp
  800d85:	6a 07                	push   $0x7
  800d87:	68 00 f0 bf ee       	push   $0xeebff000
  800d8c:	50                   	push   %eax
  800d8d:	e8 e8 fd ff ff       	call   800b7a <sys_page_alloc>
  800d92:	83 c4 10             	add    $0x10,%esp
  800d95:	85 c0                	test   %eax,%eax
  800d97:	79 12                	jns    800dab <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  800d99:	50                   	push   %eax
  800d9a:	68 4a 22 80 00       	push   $0x80224a
  800d9f:	6a 21                	push   $0x21
  800da1:	68 62 22 80 00       	push   $0x802262
  800da6:	e8 31 0d 00 00       	call   801adc <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800dab:	a1 04 40 80 00       	mov    0x804004,%eax
  800db0:	8b 40 48             	mov    0x48(%eax),%eax
  800db3:	83 ec 08             	sub    $0x8,%esp
  800db6:	68 ce 0d 80 00       	push   $0x800dce
  800dbb:	50                   	push   %eax
  800dbc:	e8 04 ff ff ff       	call   800cc5 <sys_env_set_pgfault_upcall>
  800dc1:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800dc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc7:	a3 08 40 80 00       	mov    %eax,0x804008
  800dcc:	c9                   	leave  
  800dcd:	c3                   	ret    

00800dce <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800dce:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800dcf:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800dd4:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800dd6:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  800dd9:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  800ddc:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  800de0:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  800de5:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  800de9:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800deb:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  800dec:	83 c4 04             	add    $0x4,%esp
	popfl
  800def:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800df0:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  800df1:	c3                   	ret    

00800df2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800df5:	8b 45 08             	mov    0x8(%ebp),%eax
  800df8:	05 00 00 00 30       	add    $0x30000000,%eax
  800dfd:	c1 e8 0c             	shr    $0xc,%eax
}
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e05:	8b 45 08             	mov    0x8(%ebp),%eax
  800e08:	05 00 00 00 30       	add    $0x30000000,%eax
  800e0d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e12:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e1f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e24:	89 c2                	mov    %eax,%edx
  800e26:	c1 ea 16             	shr    $0x16,%edx
  800e29:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e30:	f6 c2 01             	test   $0x1,%dl
  800e33:	74 11                	je     800e46 <fd_alloc+0x2d>
  800e35:	89 c2                	mov    %eax,%edx
  800e37:	c1 ea 0c             	shr    $0xc,%edx
  800e3a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e41:	f6 c2 01             	test   $0x1,%dl
  800e44:	75 09                	jne    800e4f <fd_alloc+0x36>
			*fd_store = fd;
  800e46:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e48:	b8 00 00 00 00       	mov    $0x0,%eax
  800e4d:	eb 17                	jmp    800e66 <fd_alloc+0x4d>
  800e4f:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e54:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e59:	75 c9                	jne    800e24 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e5b:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e61:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e66:	5d                   	pop    %ebp
  800e67:	c3                   	ret    

00800e68 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e6e:	83 f8 1f             	cmp    $0x1f,%eax
  800e71:	77 36                	ja     800ea9 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e73:	c1 e0 0c             	shl    $0xc,%eax
  800e76:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e7b:	89 c2                	mov    %eax,%edx
  800e7d:	c1 ea 16             	shr    $0x16,%edx
  800e80:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e87:	f6 c2 01             	test   $0x1,%dl
  800e8a:	74 24                	je     800eb0 <fd_lookup+0x48>
  800e8c:	89 c2                	mov    %eax,%edx
  800e8e:	c1 ea 0c             	shr    $0xc,%edx
  800e91:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e98:	f6 c2 01             	test   $0x1,%dl
  800e9b:	74 1a                	je     800eb7 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ea0:	89 02                	mov    %eax,(%edx)
	return 0;
  800ea2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea7:	eb 13                	jmp    800ebc <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ea9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eae:	eb 0c                	jmp    800ebc <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eb0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eb5:	eb 05                	jmp    800ebc <fd_lookup+0x54>
  800eb7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	83 ec 08             	sub    $0x8,%esp
  800ec4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec7:	ba ec 22 80 00       	mov    $0x8022ec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ecc:	eb 13                	jmp    800ee1 <dev_lookup+0x23>
  800ece:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800ed1:	39 08                	cmp    %ecx,(%eax)
  800ed3:	75 0c                	jne    800ee1 <dev_lookup+0x23>
			*dev = devtab[i];
  800ed5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eda:	b8 00 00 00 00       	mov    $0x0,%eax
  800edf:	eb 2e                	jmp    800f0f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800ee1:	8b 02                	mov    (%edx),%eax
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	75 e7                	jne    800ece <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ee7:	a1 04 40 80 00       	mov    0x804004,%eax
  800eec:	8b 40 48             	mov    0x48(%eax),%eax
  800eef:	83 ec 04             	sub    $0x4,%esp
  800ef2:	51                   	push   %ecx
  800ef3:	50                   	push   %eax
  800ef4:	68 70 22 80 00       	push   $0x802270
  800ef9:	e8 75 f2 ff ff       	call   800173 <cprintf>
	*dev = 0;
  800efe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f01:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f07:	83 c4 10             	add    $0x10,%esp
  800f0a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f0f:	c9                   	leave  
  800f10:	c3                   	ret    

00800f11 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	56                   	push   %esi
  800f15:	53                   	push   %ebx
  800f16:	83 ec 10             	sub    $0x10,%esp
  800f19:	8b 75 08             	mov    0x8(%ebp),%esi
  800f1c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f1f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f22:	50                   	push   %eax
  800f23:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f29:	c1 e8 0c             	shr    $0xc,%eax
  800f2c:	50                   	push   %eax
  800f2d:	e8 36 ff ff ff       	call   800e68 <fd_lookup>
  800f32:	83 c4 08             	add    $0x8,%esp
  800f35:	85 c0                	test   %eax,%eax
  800f37:	78 05                	js     800f3e <fd_close+0x2d>
	    || fd != fd2)
  800f39:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f3c:	74 0c                	je     800f4a <fd_close+0x39>
		return (must_exist ? r : 0);
  800f3e:	84 db                	test   %bl,%bl
  800f40:	ba 00 00 00 00       	mov    $0x0,%edx
  800f45:	0f 44 c2             	cmove  %edx,%eax
  800f48:	eb 41                	jmp    800f8b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f4a:	83 ec 08             	sub    $0x8,%esp
  800f4d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f50:	50                   	push   %eax
  800f51:	ff 36                	pushl  (%esi)
  800f53:	e8 66 ff ff ff       	call   800ebe <dev_lookup>
  800f58:	89 c3                	mov    %eax,%ebx
  800f5a:	83 c4 10             	add    $0x10,%esp
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	78 1a                	js     800f7b <fd_close+0x6a>
		if (dev->dev_close)
  800f61:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f64:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f67:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	74 0b                	je     800f7b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f70:	83 ec 0c             	sub    $0xc,%esp
  800f73:	56                   	push   %esi
  800f74:	ff d0                	call   *%eax
  800f76:	89 c3                	mov    %eax,%ebx
  800f78:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f7b:	83 ec 08             	sub    $0x8,%esp
  800f7e:	56                   	push   %esi
  800f7f:	6a 00                	push   $0x0
  800f81:	e8 79 fc ff ff       	call   800bff <sys_page_unmap>
	return r;
  800f86:	83 c4 10             	add    $0x10,%esp
  800f89:	89 d8                	mov    %ebx,%eax
}
  800f8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f8e:	5b                   	pop    %ebx
  800f8f:	5e                   	pop    %esi
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    

00800f92 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f98:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f9b:	50                   	push   %eax
  800f9c:	ff 75 08             	pushl  0x8(%ebp)
  800f9f:	e8 c4 fe ff ff       	call   800e68 <fd_lookup>
  800fa4:	83 c4 08             	add    $0x8,%esp
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	78 10                	js     800fbb <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fab:	83 ec 08             	sub    $0x8,%esp
  800fae:	6a 01                	push   $0x1
  800fb0:	ff 75 f4             	pushl  -0xc(%ebp)
  800fb3:	e8 59 ff ff ff       	call   800f11 <fd_close>
  800fb8:	83 c4 10             	add    $0x10,%esp
}
  800fbb:	c9                   	leave  
  800fbc:	c3                   	ret    

00800fbd <close_all>:

void
close_all(void)
{
  800fbd:	55                   	push   %ebp
  800fbe:	89 e5                	mov    %esp,%ebp
  800fc0:	53                   	push   %ebx
  800fc1:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc4:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fc9:	83 ec 0c             	sub    $0xc,%esp
  800fcc:	53                   	push   %ebx
  800fcd:	e8 c0 ff ff ff       	call   800f92 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd2:	83 c3 01             	add    $0x1,%ebx
  800fd5:	83 c4 10             	add    $0x10,%esp
  800fd8:	83 fb 20             	cmp    $0x20,%ebx
  800fdb:	75 ec                	jne    800fc9 <close_all+0xc>
		close(i);
}
  800fdd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fe0:	c9                   	leave  
  800fe1:	c3                   	ret    

00800fe2 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	57                   	push   %edi
  800fe6:	56                   	push   %esi
  800fe7:	53                   	push   %ebx
  800fe8:	83 ec 2c             	sub    $0x2c,%esp
  800feb:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fee:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ff1:	50                   	push   %eax
  800ff2:	ff 75 08             	pushl  0x8(%ebp)
  800ff5:	e8 6e fe ff ff       	call   800e68 <fd_lookup>
  800ffa:	83 c4 08             	add    $0x8,%esp
  800ffd:	85 c0                	test   %eax,%eax
  800fff:	0f 88 c1 00 00 00    	js     8010c6 <dup+0xe4>
		return r;
	close(newfdnum);
  801005:	83 ec 0c             	sub    $0xc,%esp
  801008:	56                   	push   %esi
  801009:	e8 84 ff ff ff       	call   800f92 <close>

	newfd = INDEX2FD(newfdnum);
  80100e:	89 f3                	mov    %esi,%ebx
  801010:	c1 e3 0c             	shl    $0xc,%ebx
  801013:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801019:	83 c4 04             	add    $0x4,%esp
  80101c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80101f:	e8 de fd ff ff       	call   800e02 <fd2data>
  801024:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801026:	89 1c 24             	mov    %ebx,(%esp)
  801029:	e8 d4 fd ff ff       	call   800e02 <fd2data>
  80102e:	83 c4 10             	add    $0x10,%esp
  801031:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801034:	89 f8                	mov    %edi,%eax
  801036:	c1 e8 16             	shr    $0x16,%eax
  801039:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801040:	a8 01                	test   $0x1,%al
  801042:	74 37                	je     80107b <dup+0x99>
  801044:	89 f8                	mov    %edi,%eax
  801046:	c1 e8 0c             	shr    $0xc,%eax
  801049:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801050:	f6 c2 01             	test   $0x1,%dl
  801053:	74 26                	je     80107b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801055:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105c:	83 ec 0c             	sub    $0xc,%esp
  80105f:	25 07 0e 00 00       	and    $0xe07,%eax
  801064:	50                   	push   %eax
  801065:	ff 75 d4             	pushl  -0x2c(%ebp)
  801068:	6a 00                	push   $0x0
  80106a:	57                   	push   %edi
  80106b:	6a 00                	push   $0x0
  80106d:	e8 4b fb ff ff       	call   800bbd <sys_page_map>
  801072:	89 c7                	mov    %eax,%edi
  801074:	83 c4 20             	add    $0x20,%esp
  801077:	85 c0                	test   %eax,%eax
  801079:	78 2e                	js     8010a9 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80107b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80107e:	89 d0                	mov    %edx,%eax
  801080:	c1 e8 0c             	shr    $0xc,%eax
  801083:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108a:	83 ec 0c             	sub    $0xc,%esp
  80108d:	25 07 0e 00 00       	and    $0xe07,%eax
  801092:	50                   	push   %eax
  801093:	53                   	push   %ebx
  801094:	6a 00                	push   $0x0
  801096:	52                   	push   %edx
  801097:	6a 00                	push   $0x0
  801099:	e8 1f fb ff ff       	call   800bbd <sys_page_map>
  80109e:	89 c7                	mov    %eax,%edi
  8010a0:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010a3:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010a5:	85 ff                	test   %edi,%edi
  8010a7:	79 1d                	jns    8010c6 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010a9:	83 ec 08             	sub    $0x8,%esp
  8010ac:	53                   	push   %ebx
  8010ad:	6a 00                	push   $0x0
  8010af:	e8 4b fb ff ff       	call   800bff <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010b4:	83 c4 08             	add    $0x8,%esp
  8010b7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010ba:	6a 00                	push   $0x0
  8010bc:	e8 3e fb ff ff       	call   800bff <sys_page_unmap>
	return r;
  8010c1:	83 c4 10             	add    $0x10,%esp
  8010c4:	89 f8                	mov    %edi,%eax
}
  8010c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c9:	5b                   	pop    %ebx
  8010ca:	5e                   	pop    %esi
  8010cb:	5f                   	pop    %edi
  8010cc:	5d                   	pop    %ebp
  8010cd:	c3                   	ret    

008010ce <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010ce:	55                   	push   %ebp
  8010cf:	89 e5                	mov    %esp,%ebp
  8010d1:	53                   	push   %ebx
  8010d2:	83 ec 14             	sub    $0x14,%esp
  8010d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010db:	50                   	push   %eax
  8010dc:	53                   	push   %ebx
  8010dd:	e8 86 fd ff ff       	call   800e68 <fd_lookup>
  8010e2:	83 c4 08             	add    $0x8,%esp
  8010e5:	89 c2                	mov    %eax,%edx
  8010e7:	85 c0                	test   %eax,%eax
  8010e9:	78 6d                	js     801158 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010eb:	83 ec 08             	sub    $0x8,%esp
  8010ee:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f1:	50                   	push   %eax
  8010f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f5:	ff 30                	pushl  (%eax)
  8010f7:	e8 c2 fd ff ff       	call   800ebe <dev_lookup>
  8010fc:	83 c4 10             	add    $0x10,%esp
  8010ff:	85 c0                	test   %eax,%eax
  801101:	78 4c                	js     80114f <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801103:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801106:	8b 42 08             	mov    0x8(%edx),%eax
  801109:	83 e0 03             	and    $0x3,%eax
  80110c:	83 f8 01             	cmp    $0x1,%eax
  80110f:	75 21                	jne    801132 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801111:	a1 04 40 80 00       	mov    0x804004,%eax
  801116:	8b 40 48             	mov    0x48(%eax),%eax
  801119:	83 ec 04             	sub    $0x4,%esp
  80111c:	53                   	push   %ebx
  80111d:	50                   	push   %eax
  80111e:	68 b1 22 80 00       	push   $0x8022b1
  801123:	e8 4b f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  801128:	83 c4 10             	add    $0x10,%esp
  80112b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801130:	eb 26                	jmp    801158 <read+0x8a>
	}
	if (!dev->dev_read)
  801132:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801135:	8b 40 08             	mov    0x8(%eax),%eax
  801138:	85 c0                	test   %eax,%eax
  80113a:	74 17                	je     801153 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80113c:	83 ec 04             	sub    $0x4,%esp
  80113f:	ff 75 10             	pushl  0x10(%ebp)
  801142:	ff 75 0c             	pushl  0xc(%ebp)
  801145:	52                   	push   %edx
  801146:	ff d0                	call   *%eax
  801148:	89 c2                	mov    %eax,%edx
  80114a:	83 c4 10             	add    $0x10,%esp
  80114d:	eb 09                	jmp    801158 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80114f:	89 c2                	mov    %eax,%edx
  801151:	eb 05                	jmp    801158 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801153:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801158:	89 d0                	mov    %edx,%eax
  80115a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80115d:	c9                   	leave  
  80115e:	c3                   	ret    

0080115f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80115f:	55                   	push   %ebp
  801160:	89 e5                	mov    %esp,%ebp
  801162:	57                   	push   %edi
  801163:	56                   	push   %esi
  801164:	53                   	push   %ebx
  801165:	83 ec 0c             	sub    $0xc,%esp
  801168:	8b 7d 08             	mov    0x8(%ebp),%edi
  80116b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80116e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801173:	eb 21                	jmp    801196 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801175:	83 ec 04             	sub    $0x4,%esp
  801178:	89 f0                	mov    %esi,%eax
  80117a:	29 d8                	sub    %ebx,%eax
  80117c:	50                   	push   %eax
  80117d:	89 d8                	mov    %ebx,%eax
  80117f:	03 45 0c             	add    0xc(%ebp),%eax
  801182:	50                   	push   %eax
  801183:	57                   	push   %edi
  801184:	e8 45 ff ff ff       	call   8010ce <read>
		if (m < 0)
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	85 c0                	test   %eax,%eax
  80118e:	78 10                	js     8011a0 <readn+0x41>
			return m;
		if (m == 0)
  801190:	85 c0                	test   %eax,%eax
  801192:	74 0a                	je     80119e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801194:	01 c3                	add    %eax,%ebx
  801196:	39 f3                	cmp    %esi,%ebx
  801198:	72 db                	jb     801175 <readn+0x16>
  80119a:	89 d8                	mov    %ebx,%eax
  80119c:	eb 02                	jmp    8011a0 <readn+0x41>
  80119e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a3:	5b                   	pop    %ebx
  8011a4:	5e                   	pop    %esi
  8011a5:	5f                   	pop    %edi
  8011a6:	5d                   	pop    %ebp
  8011a7:	c3                   	ret    

008011a8 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	53                   	push   %ebx
  8011ac:	83 ec 14             	sub    $0x14,%esp
  8011af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b5:	50                   	push   %eax
  8011b6:	53                   	push   %ebx
  8011b7:	e8 ac fc ff ff       	call   800e68 <fd_lookup>
  8011bc:	83 c4 08             	add    $0x8,%esp
  8011bf:	89 c2                	mov    %eax,%edx
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	78 68                	js     80122d <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c5:	83 ec 08             	sub    $0x8,%esp
  8011c8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011cb:	50                   	push   %eax
  8011cc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cf:	ff 30                	pushl  (%eax)
  8011d1:	e8 e8 fc ff ff       	call   800ebe <dev_lookup>
  8011d6:	83 c4 10             	add    $0x10,%esp
  8011d9:	85 c0                	test   %eax,%eax
  8011db:	78 47                	js     801224 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011dd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e0:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011e4:	75 21                	jne    801207 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011e6:	a1 04 40 80 00       	mov    0x804004,%eax
  8011eb:	8b 40 48             	mov    0x48(%eax),%eax
  8011ee:	83 ec 04             	sub    $0x4,%esp
  8011f1:	53                   	push   %ebx
  8011f2:	50                   	push   %eax
  8011f3:	68 cd 22 80 00       	push   $0x8022cd
  8011f8:	e8 76 ef ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  8011fd:	83 c4 10             	add    $0x10,%esp
  801200:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801205:	eb 26                	jmp    80122d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801207:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80120a:	8b 52 0c             	mov    0xc(%edx),%edx
  80120d:	85 d2                	test   %edx,%edx
  80120f:	74 17                	je     801228 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801211:	83 ec 04             	sub    $0x4,%esp
  801214:	ff 75 10             	pushl  0x10(%ebp)
  801217:	ff 75 0c             	pushl  0xc(%ebp)
  80121a:	50                   	push   %eax
  80121b:	ff d2                	call   *%edx
  80121d:	89 c2                	mov    %eax,%edx
  80121f:	83 c4 10             	add    $0x10,%esp
  801222:	eb 09                	jmp    80122d <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801224:	89 c2                	mov    %eax,%edx
  801226:	eb 05                	jmp    80122d <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801228:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80122d:	89 d0                	mov    %edx,%eax
  80122f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801232:	c9                   	leave  
  801233:	c3                   	ret    

00801234 <seek>:

int
seek(int fdnum, off_t offset)
{
  801234:	55                   	push   %ebp
  801235:	89 e5                	mov    %esp,%ebp
  801237:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80123a:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80123d:	50                   	push   %eax
  80123e:	ff 75 08             	pushl  0x8(%ebp)
  801241:	e8 22 fc ff ff       	call   800e68 <fd_lookup>
  801246:	83 c4 08             	add    $0x8,%esp
  801249:	85 c0                	test   %eax,%eax
  80124b:	78 0e                	js     80125b <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80124d:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801250:	8b 55 0c             	mov    0xc(%ebp),%edx
  801253:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801256:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80125b:	c9                   	leave  
  80125c:	c3                   	ret    

0080125d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	53                   	push   %ebx
  801261:	83 ec 14             	sub    $0x14,%esp
  801264:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801267:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80126a:	50                   	push   %eax
  80126b:	53                   	push   %ebx
  80126c:	e8 f7 fb ff ff       	call   800e68 <fd_lookup>
  801271:	83 c4 08             	add    $0x8,%esp
  801274:	89 c2                	mov    %eax,%edx
  801276:	85 c0                	test   %eax,%eax
  801278:	78 65                	js     8012df <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80127a:	83 ec 08             	sub    $0x8,%esp
  80127d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801280:	50                   	push   %eax
  801281:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801284:	ff 30                	pushl  (%eax)
  801286:	e8 33 fc ff ff       	call   800ebe <dev_lookup>
  80128b:	83 c4 10             	add    $0x10,%esp
  80128e:	85 c0                	test   %eax,%eax
  801290:	78 44                	js     8012d6 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801292:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801295:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801299:	75 21                	jne    8012bc <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80129b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012a0:	8b 40 48             	mov    0x48(%eax),%eax
  8012a3:	83 ec 04             	sub    $0x4,%esp
  8012a6:	53                   	push   %ebx
  8012a7:	50                   	push   %eax
  8012a8:	68 90 22 80 00       	push   $0x802290
  8012ad:	e8 c1 ee ff ff       	call   800173 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012b2:	83 c4 10             	add    $0x10,%esp
  8012b5:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012ba:	eb 23                	jmp    8012df <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012bc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012bf:	8b 52 18             	mov    0x18(%edx),%edx
  8012c2:	85 d2                	test   %edx,%edx
  8012c4:	74 14                	je     8012da <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012c6:	83 ec 08             	sub    $0x8,%esp
  8012c9:	ff 75 0c             	pushl  0xc(%ebp)
  8012cc:	50                   	push   %eax
  8012cd:	ff d2                	call   *%edx
  8012cf:	89 c2                	mov    %eax,%edx
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	eb 09                	jmp    8012df <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012d6:	89 c2                	mov    %eax,%edx
  8012d8:	eb 05                	jmp    8012df <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012da:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012df:	89 d0                	mov    %edx,%eax
  8012e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012e4:	c9                   	leave  
  8012e5:	c3                   	ret    

008012e6 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012e6:	55                   	push   %ebp
  8012e7:	89 e5                	mov    %esp,%ebp
  8012e9:	53                   	push   %ebx
  8012ea:	83 ec 14             	sub    $0x14,%esp
  8012ed:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012f0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012f3:	50                   	push   %eax
  8012f4:	ff 75 08             	pushl  0x8(%ebp)
  8012f7:	e8 6c fb ff ff       	call   800e68 <fd_lookup>
  8012fc:	83 c4 08             	add    $0x8,%esp
  8012ff:	89 c2                	mov    %eax,%edx
  801301:	85 c0                	test   %eax,%eax
  801303:	78 58                	js     80135d <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801305:	83 ec 08             	sub    $0x8,%esp
  801308:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80130b:	50                   	push   %eax
  80130c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80130f:	ff 30                	pushl  (%eax)
  801311:	e8 a8 fb ff ff       	call   800ebe <dev_lookup>
  801316:	83 c4 10             	add    $0x10,%esp
  801319:	85 c0                	test   %eax,%eax
  80131b:	78 37                	js     801354 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80131d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801320:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801324:	74 32                	je     801358 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801326:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801329:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801330:	00 00 00 
	stat->st_isdir = 0;
  801333:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80133a:	00 00 00 
	stat->st_dev = dev;
  80133d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801343:	83 ec 08             	sub    $0x8,%esp
  801346:	53                   	push   %ebx
  801347:	ff 75 f0             	pushl  -0x10(%ebp)
  80134a:	ff 50 14             	call   *0x14(%eax)
  80134d:	89 c2                	mov    %eax,%edx
  80134f:	83 c4 10             	add    $0x10,%esp
  801352:	eb 09                	jmp    80135d <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801354:	89 c2                	mov    %eax,%edx
  801356:	eb 05                	jmp    80135d <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801358:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80135d:	89 d0                	mov    %edx,%eax
  80135f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801362:	c9                   	leave  
  801363:	c3                   	ret    

00801364 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801364:	55                   	push   %ebp
  801365:	89 e5                	mov    %esp,%ebp
  801367:	56                   	push   %esi
  801368:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801369:	83 ec 08             	sub    $0x8,%esp
  80136c:	6a 00                	push   $0x0
  80136e:	ff 75 08             	pushl  0x8(%ebp)
  801371:	e8 e3 01 00 00       	call   801559 <open>
  801376:	89 c3                	mov    %eax,%ebx
  801378:	83 c4 10             	add    $0x10,%esp
  80137b:	85 c0                	test   %eax,%eax
  80137d:	78 1b                	js     80139a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80137f:	83 ec 08             	sub    $0x8,%esp
  801382:	ff 75 0c             	pushl  0xc(%ebp)
  801385:	50                   	push   %eax
  801386:	e8 5b ff ff ff       	call   8012e6 <fstat>
  80138b:	89 c6                	mov    %eax,%esi
	close(fd);
  80138d:	89 1c 24             	mov    %ebx,(%esp)
  801390:	e8 fd fb ff ff       	call   800f92 <close>
	return r;
  801395:	83 c4 10             	add    $0x10,%esp
  801398:	89 f0                	mov    %esi,%eax
}
  80139a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80139d:	5b                   	pop    %ebx
  80139e:	5e                   	pop    %esi
  80139f:	5d                   	pop    %ebp
  8013a0:	c3                   	ret    

008013a1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	56                   	push   %esi
  8013a5:	53                   	push   %ebx
  8013a6:	89 c6                	mov    %eax,%esi
  8013a8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013aa:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013b1:	75 12                	jne    8013c5 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013b3:	83 ec 0c             	sub    $0xc,%esp
  8013b6:	6a 01                	push   $0x1
  8013b8:	e8 22 08 00 00       	call   801bdf <ipc_find_env>
  8013bd:	a3 00 40 80 00       	mov    %eax,0x804000
  8013c2:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013c5:	6a 07                	push   $0x7
  8013c7:	68 00 50 80 00       	push   $0x805000
  8013cc:	56                   	push   %esi
  8013cd:	ff 35 00 40 80 00    	pushl  0x804000
  8013d3:	e8 b3 07 00 00       	call   801b8b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013d8:	83 c4 0c             	add    $0xc,%esp
  8013db:	6a 00                	push   $0x0
  8013dd:	53                   	push   %ebx
  8013de:	6a 00                	push   $0x0
  8013e0:	e8 3d 07 00 00       	call   801b22 <ipc_recv>
}
  8013e5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e8:	5b                   	pop    %ebx
  8013e9:	5e                   	pop    %esi
  8013ea:	5d                   	pop    %ebp
  8013eb:	c3                   	ret    

008013ec <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013ec:	55                   	push   %ebp
  8013ed:	89 e5                	mov    %esp,%ebp
  8013ef:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8013f5:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013fd:	8b 45 0c             	mov    0xc(%ebp),%eax
  801400:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801405:	ba 00 00 00 00       	mov    $0x0,%edx
  80140a:	b8 02 00 00 00       	mov    $0x2,%eax
  80140f:	e8 8d ff ff ff       	call   8013a1 <fsipc>
}
  801414:	c9                   	leave  
  801415:	c3                   	ret    

00801416 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80141c:	8b 45 08             	mov    0x8(%ebp),%eax
  80141f:	8b 40 0c             	mov    0xc(%eax),%eax
  801422:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801427:	ba 00 00 00 00       	mov    $0x0,%edx
  80142c:	b8 06 00 00 00       	mov    $0x6,%eax
  801431:	e8 6b ff ff ff       	call   8013a1 <fsipc>
}
  801436:	c9                   	leave  
  801437:	c3                   	ret    

00801438 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801438:	55                   	push   %ebp
  801439:	89 e5                	mov    %esp,%ebp
  80143b:	53                   	push   %ebx
  80143c:	83 ec 04             	sub    $0x4,%esp
  80143f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801442:	8b 45 08             	mov    0x8(%ebp),%eax
  801445:	8b 40 0c             	mov    0xc(%eax),%eax
  801448:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80144d:	ba 00 00 00 00       	mov    $0x0,%edx
  801452:	b8 05 00 00 00       	mov    $0x5,%eax
  801457:	e8 45 ff ff ff       	call   8013a1 <fsipc>
  80145c:	85 c0                	test   %eax,%eax
  80145e:	78 2c                	js     80148c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801460:	83 ec 08             	sub    $0x8,%esp
  801463:	68 00 50 80 00       	push   $0x805000
  801468:	53                   	push   %ebx
  801469:	e8 09 f3 ff ff       	call   800777 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80146e:	a1 80 50 80 00       	mov    0x805080,%eax
  801473:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801479:	a1 84 50 80 00       	mov    0x805084,%eax
  80147e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80148c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80148f:	c9                   	leave  
  801490:	c3                   	ret    

00801491 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801491:	55                   	push   %ebp
  801492:	89 e5                	mov    %esp,%ebp
  801494:	83 ec 0c             	sub    $0xc,%esp
  801497:	8b 45 10             	mov    0x10(%ebp),%eax
  80149a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80149f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014a4:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014a7:	8b 55 08             	mov    0x8(%ebp),%edx
  8014aa:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ad:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014b3:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014b8:	50                   	push   %eax
  8014b9:	ff 75 0c             	pushl  0xc(%ebp)
  8014bc:	68 08 50 80 00       	push   $0x805008
  8014c1:	e8 43 f4 ff ff       	call   800909 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8014cb:	b8 04 00 00 00       	mov    $0x4,%eax
  8014d0:	e8 cc fe ff ff       	call   8013a1 <fsipc>
	//panic("devfile_write not implemented");
}
  8014d5:	c9                   	leave  
  8014d6:	c3                   	ret    

008014d7 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014d7:	55                   	push   %ebp
  8014d8:	89 e5                	mov    %esp,%ebp
  8014da:	56                   	push   %esi
  8014db:	53                   	push   %ebx
  8014dc:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014df:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e2:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e5:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014ea:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014f0:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f5:	b8 03 00 00 00       	mov    $0x3,%eax
  8014fa:	e8 a2 fe ff ff       	call   8013a1 <fsipc>
  8014ff:	89 c3                	mov    %eax,%ebx
  801501:	85 c0                	test   %eax,%eax
  801503:	78 4b                	js     801550 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801505:	39 c6                	cmp    %eax,%esi
  801507:	73 16                	jae    80151f <devfile_read+0x48>
  801509:	68 fc 22 80 00       	push   $0x8022fc
  80150e:	68 03 23 80 00       	push   $0x802303
  801513:	6a 7c                	push   $0x7c
  801515:	68 18 23 80 00       	push   $0x802318
  80151a:	e8 bd 05 00 00       	call   801adc <_panic>
	assert(r <= PGSIZE);
  80151f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801524:	7e 16                	jle    80153c <devfile_read+0x65>
  801526:	68 23 23 80 00       	push   $0x802323
  80152b:	68 03 23 80 00       	push   $0x802303
  801530:	6a 7d                	push   $0x7d
  801532:	68 18 23 80 00       	push   $0x802318
  801537:	e8 a0 05 00 00       	call   801adc <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80153c:	83 ec 04             	sub    $0x4,%esp
  80153f:	50                   	push   %eax
  801540:	68 00 50 80 00       	push   $0x805000
  801545:	ff 75 0c             	pushl  0xc(%ebp)
  801548:	e8 bc f3 ff ff       	call   800909 <memmove>
	return r;
  80154d:	83 c4 10             	add    $0x10,%esp
}
  801550:	89 d8                	mov    %ebx,%eax
  801552:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801555:	5b                   	pop    %ebx
  801556:	5e                   	pop    %esi
  801557:	5d                   	pop    %ebp
  801558:	c3                   	ret    

00801559 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	53                   	push   %ebx
  80155d:	83 ec 20             	sub    $0x20,%esp
  801560:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801563:	53                   	push   %ebx
  801564:	e8 d5 f1 ff ff       	call   80073e <strlen>
  801569:	83 c4 10             	add    $0x10,%esp
  80156c:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801571:	7f 67                	jg     8015da <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801573:	83 ec 0c             	sub    $0xc,%esp
  801576:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801579:	50                   	push   %eax
  80157a:	e8 9a f8 ff ff       	call   800e19 <fd_alloc>
  80157f:	83 c4 10             	add    $0x10,%esp
		return r;
  801582:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801584:	85 c0                	test   %eax,%eax
  801586:	78 57                	js     8015df <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801588:	83 ec 08             	sub    $0x8,%esp
  80158b:	53                   	push   %ebx
  80158c:	68 00 50 80 00       	push   $0x805000
  801591:	e8 e1 f1 ff ff       	call   800777 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801596:	8b 45 0c             	mov    0xc(%ebp),%eax
  801599:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80159e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a1:	b8 01 00 00 00       	mov    $0x1,%eax
  8015a6:	e8 f6 fd ff ff       	call   8013a1 <fsipc>
  8015ab:	89 c3                	mov    %eax,%ebx
  8015ad:	83 c4 10             	add    $0x10,%esp
  8015b0:	85 c0                	test   %eax,%eax
  8015b2:	79 14                	jns    8015c8 <open+0x6f>
		fd_close(fd, 0);
  8015b4:	83 ec 08             	sub    $0x8,%esp
  8015b7:	6a 00                	push   $0x0
  8015b9:	ff 75 f4             	pushl  -0xc(%ebp)
  8015bc:	e8 50 f9 ff ff       	call   800f11 <fd_close>
		return r;
  8015c1:	83 c4 10             	add    $0x10,%esp
  8015c4:	89 da                	mov    %ebx,%edx
  8015c6:	eb 17                	jmp    8015df <open+0x86>
	}

	return fd2num(fd);
  8015c8:	83 ec 0c             	sub    $0xc,%esp
  8015cb:	ff 75 f4             	pushl  -0xc(%ebp)
  8015ce:	e8 1f f8 ff ff       	call   800df2 <fd2num>
  8015d3:	89 c2                	mov    %eax,%edx
  8015d5:	83 c4 10             	add    $0x10,%esp
  8015d8:	eb 05                	jmp    8015df <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015da:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015df:	89 d0                	mov    %edx,%eax
  8015e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015e4:	c9                   	leave  
  8015e5:	c3                   	ret    

008015e6 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015e6:	55                   	push   %ebp
  8015e7:	89 e5                	mov    %esp,%ebp
  8015e9:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015ec:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f1:	b8 08 00 00 00       	mov    $0x8,%eax
  8015f6:	e8 a6 fd ff ff       	call   8013a1 <fsipc>
}
  8015fb:	c9                   	leave  
  8015fc:	c3                   	ret    

008015fd <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8015fd:	55                   	push   %ebp
  8015fe:	89 e5                	mov    %esp,%ebp
  801600:	56                   	push   %esi
  801601:	53                   	push   %ebx
  801602:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801605:	83 ec 0c             	sub    $0xc,%esp
  801608:	ff 75 08             	pushl  0x8(%ebp)
  80160b:	e8 f2 f7 ff ff       	call   800e02 <fd2data>
  801610:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801612:	83 c4 08             	add    $0x8,%esp
  801615:	68 2f 23 80 00       	push   $0x80232f
  80161a:	53                   	push   %ebx
  80161b:	e8 57 f1 ff ff       	call   800777 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801620:	8b 46 04             	mov    0x4(%esi),%eax
  801623:	2b 06                	sub    (%esi),%eax
  801625:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80162b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801632:	00 00 00 
	stat->st_dev = &devpipe;
  801635:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80163c:	30 80 00 
	return 0;
}
  80163f:	b8 00 00 00 00       	mov    $0x0,%eax
  801644:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801647:	5b                   	pop    %ebx
  801648:	5e                   	pop    %esi
  801649:	5d                   	pop    %ebp
  80164a:	c3                   	ret    

0080164b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80164b:	55                   	push   %ebp
  80164c:	89 e5                	mov    %esp,%ebp
  80164e:	53                   	push   %ebx
  80164f:	83 ec 0c             	sub    $0xc,%esp
  801652:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801655:	53                   	push   %ebx
  801656:	6a 00                	push   $0x0
  801658:	e8 a2 f5 ff ff       	call   800bff <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80165d:	89 1c 24             	mov    %ebx,(%esp)
  801660:	e8 9d f7 ff ff       	call   800e02 <fd2data>
  801665:	83 c4 08             	add    $0x8,%esp
  801668:	50                   	push   %eax
  801669:	6a 00                	push   $0x0
  80166b:	e8 8f f5 ff ff       	call   800bff <sys_page_unmap>
}
  801670:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801673:	c9                   	leave  
  801674:	c3                   	ret    

00801675 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801675:	55                   	push   %ebp
  801676:	89 e5                	mov    %esp,%ebp
  801678:	57                   	push   %edi
  801679:	56                   	push   %esi
  80167a:	53                   	push   %ebx
  80167b:	83 ec 1c             	sub    $0x1c,%esp
  80167e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801681:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801683:	a1 04 40 80 00       	mov    0x804004,%eax
  801688:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80168b:	83 ec 0c             	sub    $0xc,%esp
  80168e:	ff 75 e0             	pushl  -0x20(%ebp)
  801691:	e8 82 05 00 00       	call   801c18 <pageref>
  801696:	89 c3                	mov    %eax,%ebx
  801698:	89 3c 24             	mov    %edi,(%esp)
  80169b:	e8 78 05 00 00       	call   801c18 <pageref>
  8016a0:	83 c4 10             	add    $0x10,%esp
  8016a3:	39 c3                	cmp    %eax,%ebx
  8016a5:	0f 94 c1             	sete   %cl
  8016a8:	0f b6 c9             	movzbl %cl,%ecx
  8016ab:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8016ae:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016b4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016b7:	39 ce                	cmp    %ecx,%esi
  8016b9:	74 1b                	je     8016d6 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8016bb:	39 c3                	cmp    %eax,%ebx
  8016bd:	75 c4                	jne    801683 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016bf:	8b 42 58             	mov    0x58(%edx),%eax
  8016c2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016c5:	50                   	push   %eax
  8016c6:	56                   	push   %esi
  8016c7:	68 36 23 80 00       	push   $0x802336
  8016cc:	e8 a2 ea ff ff       	call   800173 <cprintf>
  8016d1:	83 c4 10             	add    $0x10,%esp
  8016d4:	eb ad                	jmp    801683 <_pipeisclosed+0xe>
	}
}
  8016d6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8016d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016dc:	5b                   	pop    %ebx
  8016dd:	5e                   	pop    %esi
  8016de:	5f                   	pop    %edi
  8016df:	5d                   	pop    %ebp
  8016e0:	c3                   	ret    

008016e1 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8016e1:	55                   	push   %ebp
  8016e2:	89 e5                	mov    %esp,%ebp
  8016e4:	57                   	push   %edi
  8016e5:	56                   	push   %esi
  8016e6:	53                   	push   %ebx
  8016e7:	83 ec 28             	sub    $0x28,%esp
  8016ea:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8016ed:	56                   	push   %esi
  8016ee:	e8 0f f7 ff ff       	call   800e02 <fd2data>
  8016f3:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8016f5:	83 c4 10             	add    $0x10,%esp
  8016f8:	bf 00 00 00 00       	mov    $0x0,%edi
  8016fd:	eb 4b                	jmp    80174a <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  8016ff:	89 da                	mov    %ebx,%edx
  801701:	89 f0                	mov    %esi,%eax
  801703:	e8 6d ff ff ff       	call   801675 <_pipeisclosed>
  801708:	85 c0                	test   %eax,%eax
  80170a:	75 48                	jne    801754 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80170c:	e8 4a f4 ff ff       	call   800b5b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801711:	8b 43 04             	mov    0x4(%ebx),%eax
  801714:	8b 0b                	mov    (%ebx),%ecx
  801716:	8d 51 20             	lea    0x20(%ecx),%edx
  801719:	39 d0                	cmp    %edx,%eax
  80171b:	73 e2                	jae    8016ff <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80171d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801720:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801724:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801727:	89 c2                	mov    %eax,%edx
  801729:	c1 fa 1f             	sar    $0x1f,%edx
  80172c:	89 d1                	mov    %edx,%ecx
  80172e:	c1 e9 1b             	shr    $0x1b,%ecx
  801731:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801734:	83 e2 1f             	and    $0x1f,%edx
  801737:	29 ca                	sub    %ecx,%edx
  801739:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80173d:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801741:	83 c0 01             	add    $0x1,%eax
  801744:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801747:	83 c7 01             	add    $0x1,%edi
  80174a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80174d:	75 c2                	jne    801711 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80174f:	8b 45 10             	mov    0x10(%ebp),%eax
  801752:	eb 05                	jmp    801759 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801754:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801759:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80175c:	5b                   	pop    %ebx
  80175d:	5e                   	pop    %esi
  80175e:	5f                   	pop    %edi
  80175f:	5d                   	pop    %ebp
  801760:	c3                   	ret    

00801761 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	57                   	push   %edi
  801765:	56                   	push   %esi
  801766:	53                   	push   %ebx
  801767:	83 ec 18             	sub    $0x18,%esp
  80176a:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  80176d:	57                   	push   %edi
  80176e:	e8 8f f6 ff ff       	call   800e02 <fd2data>
  801773:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801775:	83 c4 10             	add    $0x10,%esp
  801778:	bb 00 00 00 00       	mov    $0x0,%ebx
  80177d:	eb 3d                	jmp    8017bc <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  80177f:	85 db                	test   %ebx,%ebx
  801781:	74 04                	je     801787 <devpipe_read+0x26>
				return i;
  801783:	89 d8                	mov    %ebx,%eax
  801785:	eb 44                	jmp    8017cb <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801787:	89 f2                	mov    %esi,%edx
  801789:	89 f8                	mov    %edi,%eax
  80178b:	e8 e5 fe ff ff       	call   801675 <_pipeisclosed>
  801790:	85 c0                	test   %eax,%eax
  801792:	75 32                	jne    8017c6 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801794:	e8 c2 f3 ff ff       	call   800b5b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801799:	8b 06                	mov    (%esi),%eax
  80179b:	3b 46 04             	cmp    0x4(%esi),%eax
  80179e:	74 df                	je     80177f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017a0:	99                   	cltd   
  8017a1:	c1 ea 1b             	shr    $0x1b,%edx
  8017a4:	01 d0                	add    %edx,%eax
  8017a6:	83 e0 1f             	and    $0x1f,%eax
  8017a9:	29 d0                	sub    %edx,%eax
  8017ab:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8017b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017b3:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8017b6:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8017b9:	83 c3 01             	add    $0x1,%ebx
  8017bc:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8017bf:	75 d8                	jne    801799 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8017c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8017c4:	eb 05                	jmp    8017cb <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8017c6:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8017cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ce:	5b                   	pop    %ebx
  8017cf:	5e                   	pop    %esi
  8017d0:	5f                   	pop    %edi
  8017d1:	5d                   	pop    %ebp
  8017d2:	c3                   	ret    

008017d3 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8017d3:	55                   	push   %ebp
  8017d4:	89 e5                	mov    %esp,%ebp
  8017d6:	56                   	push   %esi
  8017d7:	53                   	push   %ebx
  8017d8:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8017db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017de:	50                   	push   %eax
  8017df:	e8 35 f6 ff ff       	call   800e19 <fd_alloc>
  8017e4:	83 c4 10             	add    $0x10,%esp
  8017e7:	89 c2                	mov    %eax,%edx
  8017e9:	85 c0                	test   %eax,%eax
  8017eb:	0f 88 2c 01 00 00    	js     80191d <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8017f1:	83 ec 04             	sub    $0x4,%esp
  8017f4:	68 07 04 00 00       	push   $0x407
  8017f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8017fc:	6a 00                	push   $0x0
  8017fe:	e8 77 f3 ff ff       	call   800b7a <sys_page_alloc>
  801803:	83 c4 10             	add    $0x10,%esp
  801806:	89 c2                	mov    %eax,%edx
  801808:	85 c0                	test   %eax,%eax
  80180a:	0f 88 0d 01 00 00    	js     80191d <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801810:	83 ec 0c             	sub    $0xc,%esp
  801813:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801816:	50                   	push   %eax
  801817:	e8 fd f5 ff ff       	call   800e19 <fd_alloc>
  80181c:	89 c3                	mov    %eax,%ebx
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	85 c0                	test   %eax,%eax
  801823:	0f 88 e2 00 00 00    	js     80190b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801829:	83 ec 04             	sub    $0x4,%esp
  80182c:	68 07 04 00 00       	push   $0x407
  801831:	ff 75 f0             	pushl  -0x10(%ebp)
  801834:	6a 00                	push   $0x0
  801836:	e8 3f f3 ff ff       	call   800b7a <sys_page_alloc>
  80183b:	89 c3                	mov    %eax,%ebx
  80183d:	83 c4 10             	add    $0x10,%esp
  801840:	85 c0                	test   %eax,%eax
  801842:	0f 88 c3 00 00 00    	js     80190b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801848:	83 ec 0c             	sub    $0xc,%esp
  80184b:	ff 75 f4             	pushl  -0xc(%ebp)
  80184e:	e8 af f5 ff ff       	call   800e02 <fd2data>
  801853:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801855:	83 c4 0c             	add    $0xc,%esp
  801858:	68 07 04 00 00       	push   $0x407
  80185d:	50                   	push   %eax
  80185e:	6a 00                	push   $0x0
  801860:	e8 15 f3 ff ff       	call   800b7a <sys_page_alloc>
  801865:	89 c3                	mov    %eax,%ebx
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	85 c0                	test   %eax,%eax
  80186c:	0f 88 89 00 00 00    	js     8018fb <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801872:	83 ec 0c             	sub    $0xc,%esp
  801875:	ff 75 f0             	pushl  -0x10(%ebp)
  801878:	e8 85 f5 ff ff       	call   800e02 <fd2data>
  80187d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801884:	50                   	push   %eax
  801885:	6a 00                	push   $0x0
  801887:	56                   	push   %esi
  801888:	6a 00                	push   $0x0
  80188a:	e8 2e f3 ff ff       	call   800bbd <sys_page_map>
  80188f:	89 c3                	mov    %eax,%ebx
  801891:	83 c4 20             	add    $0x20,%esp
  801894:	85 c0                	test   %eax,%eax
  801896:	78 55                	js     8018ed <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801898:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80189e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a1:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8018a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8018ad:	8b 15 20 30 80 00    	mov    0x803020,%edx
  8018b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b6:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8018b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018bb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8018c2:	83 ec 0c             	sub    $0xc,%esp
  8018c5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018c8:	e8 25 f5 ff ff       	call   800df2 <fd2num>
  8018cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018d0:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018d2:	83 c4 04             	add    $0x4,%esp
  8018d5:	ff 75 f0             	pushl  -0x10(%ebp)
  8018d8:	e8 15 f5 ff ff       	call   800df2 <fd2num>
  8018dd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018e0:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018e3:	83 c4 10             	add    $0x10,%esp
  8018e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8018eb:	eb 30                	jmp    80191d <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8018ed:	83 ec 08             	sub    $0x8,%esp
  8018f0:	56                   	push   %esi
  8018f1:	6a 00                	push   $0x0
  8018f3:	e8 07 f3 ff ff       	call   800bff <sys_page_unmap>
  8018f8:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8018fb:	83 ec 08             	sub    $0x8,%esp
  8018fe:	ff 75 f0             	pushl  -0x10(%ebp)
  801901:	6a 00                	push   $0x0
  801903:	e8 f7 f2 ff ff       	call   800bff <sys_page_unmap>
  801908:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80190b:	83 ec 08             	sub    $0x8,%esp
  80190e:	ff 75 f4             	pushl  -0xc(%ebp)
  801911:	6a 00                	push   $0x0
  801913:	e8 e7 f2 ff ff       	call   800bff <sys_page_unmap>
  801918:	83 c4 10             	add    $0x10,%esp
  80191b:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80191d:	89 d0                	mov    %edx,%eax
  80191f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801922:	5b                   	pop    %ebx
  801923:	5e                   	pop    %esi
  801924:	5d                   	pop    %ebp
  801925:	c3                   	ret    

00801926 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80192c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80192f:	50                   	push   %eax
  801930:	ff 75 08             	pushl  0x8(%ebp)
  801933:	e8 30 f5 ff ff       	call   800e68 <fd_lookup>
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	85 c0                	test   %eax,%eax
  80193d:	78 18                	js     801957 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80193f:	83 ec 0c             	sub    $0xc,%esp
  801942:	ff 75 f4             	pushl  -0xc(%ebp)
  801945:	e8 b8 f4 ff ff       	call   800e02 <fd2data>
	return _pipeisclosed(fd, p);
  80194a:	89 c2                	mov    %eax,%edx
  80194c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80194f:	e8 21 fd ff ff       	call   801675 <_pipeisclosed>
  801954:	83 c4 10             	add    $0x10,%esp
}
  801957:	c9                   	leave  
  801958:	c3                   	ret    

00801959 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801959:	55                   	push   %ebp
  80195a:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80195c:	b8 00 00 00 00       	mov    $0x0,%eax
  801961:	5d                   	pop    %ebp
  801962:	c3                   	ret    

00801963 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801963:	55                   	push   %ebp
  801964:	89 e5                	mov    %esp,%ebp
  801966:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801969:	68 4e 23 80 00       	push   $0x80234e
  80196e:	ff 75 0c             	pushl  0xc(%ebp)
  801971:	e8 01 ee ff ff       	call   800777 <strcpy>
	return 0;
}
  801976:	b8 00 00 00 00       	mov    $0x0,%eax
  80197b:	c9                   	leave  
  80197c:	c3                   	ret    

0080197d <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80197d:	55                   	push   %ebp
  80197e:	89 e5                	mov    %esp,%ebp
  801980:	57                   	push   %edi
  801981:	56                   	push   %esi
  801982:	53                   	push   %ebx
  801983:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801989:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  80198e:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801994:	eb 2d                	jmp    8019c3 <devcons_write+0x46>
		m = n - tot;
  801996:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801999:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80199b:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  80199e:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8019a3:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8019a6:	83 ec 04             	sub    $0x4,%esp
  8019a9:	53                   	push   %ebx
  8019aa:	03 45 0c             	add    0xc(%ebp),%eax
  8019ad:	50                   	push   %eax
  8019ae:	57                   	push   %edi
  8019af:	e8 55 ef ff ff       	call   800909 <memmove>
		sys_cputs(buf, m);
  8019b4:	83 c4 08             	add    $0x8,%esp
  8019b7:	53                   	push   %ebx
  8019b8:	57                   	push   %edi
  8019b9:	e8 00 f1 ff ff       	call   800abe <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8019be:	01 de                	add    %ebx,%esi
  8019c0:	83 c4 10             	add    $0x10,%esp
  8019c3:	89 f0                	mov    %esi,%eax
  8019c5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019c8:	72 cc                	jb     801996 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8019ca:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019cd:	5b                   	pop    %ebx
  8019ce:	5e                   	pop    %esi
  8019cf:	5f                   	pop    %edi
  8019d0:	5d                   	pop    %ebp
  8019d1:	c3                   	ret    

008019d2 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019d2:	55                   	push   %ebp
  8019d3:	89 e5                	mov    %esp,%ebp
  8019d5:	83 ec 08             	sub    $0x8,%esp
  8019d8:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8019dd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8019e1:	74 2a                	je     801a0d <devcons_read+0x3b>
  8019e3:	eb 05                	jmp    8019ea <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8019e5:	e8 71 f1 ff ff       	call   800b5b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8019ea:	e8 ed f0 ff ff       	call   800adc <sys_cgetc>
  8019ef:	85 c0                	test   %eax,%eax
  8019f1:	74 f2                	je     8019e5 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8019f3:	85 c0                	test   %eax,%eax
  8019f5:	78 16                	js     801a0d <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8019f7:	83 f8 04             	cmp    $0x4,%eax
  8019fa:	74 0c                	je     801a08 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8019fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019ff:	88 02                	mov    %al,(%edx)
	return 1;
  801a01:	b8 01 00 00 00       	mov    $0x1,%eax
  801a06:	eb 05                	jmp    801a0d <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801a08:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801a0d:	c9                   	leave  
  801a0e:	c3                   	ret    

00801a0f <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801a0f:	55                   	push   %ebp
  801a10:	89 e5                	mov    %esp,%ebp
  801a12:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a15:	8b 45 08             	mov    0x8(%ebp),%eax
  801a18:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801a1b:	6a 01                	push   $0x1
  801a1d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a20:	50                   	push   %eax
  801a21:	e8 98 f0 ff ff       	call   800abe <sys_cputs>
}
  801a26:	83 c4 10             	add    $0x10,%esp
  801a29:	c9                   	leave  
  801a2a:	c3                   	ret    

00801a2b <getchar>:

int
getchar(void)
{
  801a2b:	55                   	push   %ebp
  801a2c:	89 e5                	mov    %esp,%ebp
  801a2e:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801a31:	6a 01                	push   $0x1
  801a33:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a36:	50                   	push   %eax
  801a37:	6a 00                	push   $0x0
  801a39:	e8 90 f6 ff ff       	call   8010ce <read>
	if (r < 0)
  801a3e:	83 c4 10             	add    $0x10,%esp
  801a41:	85 c0                	test   %eax,%eax
  801a43:	78 0f                	js     801a54 <getchar+0x29>
		return r;
	if (r < 1)
  801a45:	85 c0                	test   %eax,%eax
  801a47:	7e 06                	jle    801a4f <getchar+0x24>
		return -E_EOF;
	return c;
  801a49:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801a4d:	eb 05                	jmp    801a54 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801a4f:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801a54:	c9                   	leave  
  801a55:	c3                   	ret    

00801a56 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801a56:	55                   	push   %ebp
  801a57:	89 e5                	mov    %esp,%ebp
  801a59:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a5f:	50                   	push   %eax
  801a60:	ff 75 08             	pushl  0x8(%ebp)
  801a63:	e8 00 f4 ff ff       	call   800e68 <fd_lookup>
  801a68:	83 c4 10             	add    $0x10,%esp
  801a6b:	85 c0                	test   %eax,%eax
  801a6d:	78 11                	js     801a80 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a72:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801a78:	39 10                	cmp    %edx,(%eax)
  801a7a:	0f 94 c0             	sete   %al
  801a7d:	0f b6 c0             	movzbl %al,%eax
}
  801a80:	c9                   	leave  
  801a81:	c3                   	ret    

00801a82 <opencons>:

int
opencons(void)
{
  801a82:	55                   	push   %ebp
  801a83:	89 e5                	mov    %esp,%ebp
  801a85:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a88:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a8b:	50                   	push   %eax
  801a8c:	e8 88 f3 ff ff       	call   800e19 <fd_alloc>
  801a91:	83 c4 10             	add    $0x10,%esp
		return r;
  801a94:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801a96:	85 c0                	test   %eax,%eax
  801a98:	78 3e                	js     801ad8 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801a9a:	83 ec 04             	sub    $0x4,%esp
  801a9d:	68 07 04 00 00       	push   $0x407
  801aa2:	ff 75 f4             	pushl  -0xc(%ebp)
  801aa5:	6a 00                	push   $0x0
  801aa7:	e8 ce f0 ff ff       	call   800b7a <sys_page_alloc>
  801aac:	83 c4 10             	add    $0x10,%esp
		return r;
  801aaf:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	78 23                	js     801ad8 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801ab5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801abb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801abe:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801ac0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ac3:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801aca:	83 ec 0c             	sub    $0xc,%esp
  801acd:	50                   	push   %eax
  801ace:	e8 1f f3 ff ff       	call   800df2 <fd2num>
  801ad3:	89 c2                	mov    %eax,%edx
  801ad5:	83 c4 10             	add    $0x10,%esp
}
  801ad8:	89 d0                	mov    %edx,%eax
  801ada:	c9                   	leave  
  801adb:	c3                   	ret    

00801adc <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801adc:	55                   	push   %ebp
  801add:	89 e5                	mov    %esp,%ebp
  801adf:	56                   	push   %esi
  801ae0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801ae1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801ae4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801aea:	e8 4d f0 ff ff       	call   800b3c <sys_getenvid>
  801aef:	83 ec 0c             	sub    $0xc,%esp
  801af2:	ff 75 0c             	pushl  0xc(%ebp)
  801af5:	ff 75 08             	pushl  0x8(%ebp)
  801af8:	56                   	push   %esi
  801af9:	50                   	push   %eax
  801afa:	68 5c 23 80 00       	push   $0x80235c
  801aff:	e8 6f e6 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801b04:	83 c4 18             	add    $0x18,%esp
  801b07:	53                   	push   %ebx
  801b08:	ff 75 10             	pushl  0x10(%ebp)
  801b0b:	e8 12 e6 ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  801b10:	c7 04 24 47 23 80 00 	movl   $0x802347,(%esp)
  801b17:	e8 57 e6 ff ff       	call   800173 <cprintf>
  801b1c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801b1f:	cc                   	int3   
  801b20:	eb fd                	jmp    801b1f <_panic+0x43>

00801b22 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b22:	55                   	push   %ebp
  801b23:	89 e5                	mov    %esp,%ebp
  801b25:	56                   	push   %esi
  801b26:	53                   	push   %ebx
  801b27:	8b 75 08             	mov    0x8(%ebp),%esi
  801b2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801b30:	85 c0                	test   %eax,%eax
  801b32:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b37:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801b3a:	83 ec 0c             	sub    $0xc,%esp
  801b3d:	50                   	push   %eax
  801b3e:	e8 e7 f1 ff ff       	call   800d2a <sys_ipc_recv>
  801b43:	83 c4 10             	add    $0x10,%esp
  801b46:	85 c0                	test   %eax,%eax
  801b48:	79 16                	jns    801b60 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801b4a:	85 f6                	test   %esi,%esi
  801b4c:	74 06                	je     801b54 <ipc_recv+0x32>
            *from_env_store = 0;
  801b4e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801b54:	85 db                	test   %ebx,%ebx
  801b56:	74 2c                	je     801b84 <ipc_recv+0x62>
            *perm_store = 0;
  801b58:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801b5e:	eb 24                	jmp    801b84 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801b60:	85 f6                	test   %esi,%esi
  801b62:	74 0a                	je     801b6e <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801b64:	a1 04 40 80 00       	mov    0x804004,%eax
  801b69:	8b 40 74             	mov    0x74(%eax),%eax
  801b6c:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801b6e:	85 db                	test   %ebx,%ebx
  801b70:	74 0a                	je     801b7c <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801b72:	a1 04 40 80 00       	mov    0x804004,%eax
  801b77:	8b 40 78             	mov    0x78(%eax),%eax
  801b7a:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801b7c:	a1 04 40 80 00       	mov    0x804004,%eax
  801b81:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801b84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b87:	5b                   	pop    %ebx
  801b88:	5e                   	pop    %esi
  801b89:	5d                   	pop    %ebp
  801b8a:	c3                   	ret    

00801b8b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	57                   	push   %edi
  801b8f:	56                   	push   %esi
  801b90:	53                   	push   %ebx
  801b91:	83 ec 0c             	sub    $0xc,%esp
  801b94:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b97:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b9a:	8b 45 10             	mov    0x10(%ebp),%eax
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801ba4:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801ba7:	eb 1c                	jmp    801bc5 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801ba9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bac:	74 12                	je     801bc0 <ipc_send+0x35>
  801bae:	50                   	push   %eax
  801baf:	68 80 23 80 00       	push   $0x802380
  801bb4:	6a 3a                	push   $0x3a
  801bb6:	68 96 23 80 00       	push   $0x802396
  801bbb:	e8 1c ff ff ff       	call   801adc <_panic>
		sys_yield();
  801bc0:	e8 96 ef ff ff       	call   800b5b <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801bc5:	ff 75 14             	pushl  0x14(%ebp)
  801bc8:	53                   	push   %ebx
  801bc9:	56                   	push   %esi
  801bca:	57                   	push   %edi
  801bcb:	e8 37 f1 ff ff       	call   800d07 <sys_ipc_try_send>
  801bd0:	83 c4 10             	add    $0x10,%esp
  801bd3:	85 c0                	test   %eax,%eax
  801bd5:	78 d2                	js     801ba9 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801bd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bda:	5b                   	pop    %ebx
  801bdb:	5e                   	pop    %esi
  801bdc:	5f                   	pop    %edi
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bdf:	55                   	push   %ebp
  801be0:	89 e5                	mov    %esp,%ebp
  801be2:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801be5:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bea:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bed:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bf3:	8b 52 50             	mov    0x50(%edx),%edx
  801bf6:	39 ca                	cmp    %ecx,%edx
  801bf8:	75 0d                	jne    801c07 <ipc_find_env+0x28>
			return envs[i].env_id;
  801bfa:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801bfd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c02:	8b 40 48             	mov    0x48(%eax),%eax
  801c05:	eb 0f                	jmp    801c16 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801c07:	83 c0 01             	add    $0x1,%eax
  801c0a:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c0f:	75 d9                	jne    801bea <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801c11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    

00801c18 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c18:	55                   	push   %ebp
  801c19:	89 e5                	mov    %esp,%ebp
  801c1b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c1e:	89 d0                	mov    %edx,%eax
  801c20:	c1 e8 16             	shr    $0x16,%eax
  801c23:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801c2a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c2f:	f6 c1 01             	test   $0x1,%cl
  801c32:	74 1d                	je     801c51 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801c34:	c1 ea 0c             	shr    $0xc,%edx
  801c37:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801c3e:	f6 c2 01             	test   $0x1,%dl
  801c41:	74 0e                	je     801c51 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c43:	c1 ea 0c             	shr    $0xc,%edx
  801c46:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801c4d:	ef 
  801c4e:	0f b7 c0             	movzwl %ax,%eax
}
  801c51:	5d                   	pop    %ebp
  801c52:	c3                   	ret    
  801c53:	66 90                	xchg   %ax,%ax
  801c55:	66 90                	xchg   %ax,%ax
  801c57:	66 90                	xchg   %ax,%ax
  801c59:	66 90                	xchg   %ax,%ax
  801c5b:	66 90                	xchg   %ax,%ax
  801c5d:	66 90                	xchg   %ax,%ax
  801c5f:	90                   	nop

00801c60 <__udivdi3>:
  801c60:	55                   	push   %ebp
  801c61:	57                   	push   %edi
  801c62:	56                   	push   %esi
  801c63:	53                   	push   %ebx
  801c64:	83 ec 1c             	sub    $0x1c,%esp
  801c67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801c6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801c6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801c73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c77:	85 f6                	test   %esi,%esi
  801c79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801c7d:	89 ca                	mov    %ecx,%edx
  801c7f:	89 f8                	mov    %edi,%eax
  801c81:	75 3d                	jne    801cc0 <__udivdi3+0x60>
  801c83:	39 cf                	cmp    %ecx,%edi
  801c85:	0f 87 c5 00 00 00    	ja     801d50 <__udivdi3+0xf0>
  801c8b:	85 ff                	test   %edi,%edi
  801c8d:	89 fd                	mov    %edi,%ebp
  801c8f:	75 0b                	jne    801c9c <__udivdi3+0x3c>
  801c91:	b8 01 00 00 00       	mov    $0x1,%eax
  801c96:	31 d2                	xor    %edx,%edx
  801c98:	f7 f7                	div    %edi
  801c9a:	89 c5                	mov    %eax,%ebp
  801c9c:	89 c8                	mov    %ecx,%eax
  801c9e:	31 d2                	xor    %edx,%edx
  801ca0:	f7 f5                	div    %ebp
  801ca2:	89 c1                	mov    %eax,%ecx
  801ca4:	89 d8                	mov    %ebx,%eax
  801ca6:	89 cf                	mov    %ecx,%edi
  801ca8:	f7 f5                	div    %ebp
  801caa:	89 c3                	mov    %eax,%ebx
  801cac:	89 d8                	mov    %ebx,%eax
  801cae:	89 fa                	mov    %edi,%edx
  801cb0:	83 c4 1c             	add    $0x1c,%esp
  801cb3:	5b                   	pop    %ebx
  801cb4:	5e                   	pop    %esi
  801cb5:	5f                   	pop    %edi
  801cb6:	5d                   	pop    %ebp
  801cb7:	c3                   	ret    
  801cb8:	90                   	nop
  801cb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cc0:	39 ce                	cmp    %ecx,%esi
  801cc2:	77 74                	ja     801d38 <__udivdi3+0xd8>
  801cc4:	0f bd fe             	bsr    %esi,%edi
  801cc7:	83 f7 1f             	xor    $0x1f,%edi
  801cca:	0f 84 98 00 00 00    	je     801d68 <__udivdi3+0x108>
  801cd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801cd5:	89 f9                	mov    %edi,%ecx
  801cd7:	89 c5                	mov    %eax,%ebp
  801cd9:	29 fb                	sub    %edi,%ebx
  801cdb:	d3 e6                	shl    %cl,%esi
  801cdd:	89 d9                	mov    %ebx,%ecx
  801cdf:	d3 ed                	shr    %cl,%ebp
  801ce1:	89 f9                	mov    %edi,%ecx
  801ce3:	d3 e0                	shl    %cl,%eax
  801ce5:	09 ee                	or     %ebp,%esi
  801ce7:	89 d9                	mov    %ebx,%ecx
  801ce9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801ced:	89 d5                	mov    %edx,%ebp
  801cef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cf3:	d3 ed                	shr    %cl,%ebp
  801cf5:	89 f9                	mov    %edi,%ecx
  801cf7:	d3 e2                	shl    %cl,%edx
  801cf9:	89 d9                	mov    %ebx,%ecx
  801cfb:	d3 e8                	shr    %cl,%eax
  801cfd:	09 c2                	or     %eax,%edx
  801cff:	89 d0                	mov    %edx,%eax
  801d01:	89 ea                	mov    %ebp,%edx
  801d03:	f7 f6                	div    %esi
  801d05:	89 d5                	mov    %edx,%ebp
  801d07:	89 c3                	mov    %eax,%ebx
  801d09:	f7 64 24 0c          	mull   0xc(%esp)
  801d0d:	39 d5                	cmp    %edx,%ebp
  801d0f:	72 10                	jb     801d21 <__udivdi3+0xc1>
  801d11:	8b 74 24 08          	mov    0x8(%esp),%esi
  801d15:	89 f9                	mov    %edi,%ecx
  801d17:	d3 e6                	shl    %cl,%esi
  801d19:	39 c6                	cmp    %eax,%esi
  801d1b:	73 07                	jae    801d24 <__udivdi3+0xc4>
  801d1d:	39 d5                	cmp    %edx,%ebp
  801d1f:	75 03                	jne    801d24 <__udivdi3+0xc4>
  801d21:	83 eb 01             	sub    $0x1,%ebx
  801d24:	31 ff                	xor    %edi,%edi
  801d26:	89 d8                	mov    %ebx,%eax
  801d28:	89 fa                	mov    %edi,%edx
  801d2a:	83 c4 1c             	add    $0x1c,%esp
  801d2d:	5b                   	pop    %ebx
  801d2e:	5e                   	pop    %esi
  801d2f:	5f                   	pop    %edi
  801d30:	5d                   	pop    %ebp
  801d31:	c3                   	ret    
  801d32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d38:	31 ff                	xor    %edi,%edi
  801d3a:	31 db                	xor    %ebx,%ebx
  801d3c:	89 d8                	mov    %ebx,%eax
  801d3e:	89 fa                	mov    %edi,%edx
  801d40:	83 c4 1c             	add    $0x1c,%esp
  801d43:	5b                   	pop    %ebx
  801d44:	5e                   	pop    %esi
  801d45:	5f                   	pop    %edi
  801d46:	5d                   	pop    %ebp
  801d47:	c3                   	ret    
  801d48:	90                   	nop
  801d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d50:	89 d8                	mov    %ebx,%eax
  801d52:	f7 f7                	div    %edi
  801d54:	31 ff                	xor    %edi,%edi
  801d56:	89 c3                	mov    %eax,%ebx
  801d58:	89 d8                	mov    %ebx,%eax
  801d5a:	89 fa                	mov    %edi,%edx
  801d5c:	83 c4 1c             	add    $0x1c,%esp
  801d5f:	5b                   	pop    %ebx
  801d60:	5e                   	pop    %esi
  801d61:	5f                   	pop    %edi
  801d62:	5d                   	pop    %ebp
  801d63:	c3                   	ret    
  801d64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d68:	39 ce                	cmp    %ecx,%esi
  801d6a:	72 0c                	jb     801d78 <__udivdi3+0x118>
  801d6c:	31 db                	xor    %ebx,%ebx
  801d6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801d72:	0f 87 34 ff ff ff    	ja     801cac <__udivdi3+0x4c>
  801d78:	bb 01 00 00 00       	mov    $0x1,%ebx
  801d7d:	e9 2a ff ff ff       	jmp    801cac <__udivdi3+0x4c>
  801d82:	66 90                	xchg   %ax,%ax
  801d84:	66 90                	xchg   %ax,%ax
  801d86:	66 90                	xchg   %ax,%ax
  801d88:	66 90                	xchg   %ax,%ax
  801d8a:	66 90                	xchg   %ax,%ax
  801d8c:	66 90                	xchg   %ax,%ax
  801d8e:	66 90                	xchg   %ax,%ax

00801d90 <__umoddi3>:
  801d90:	55                   	push   %ebp
  801d91:	57                   	push   %edi
  801d92:	56                   	push   %esi
  801d93:	53                   	push   %ebx
  801d94:	83 ec 1c             	sub    $0x1c,%esp
  801d97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801d9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801da3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801da7:	85 d2                	test   %edx,%edx
  801da9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801dad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801db1:	89 f3                	mov    %esi,%ebx
  801db3:	89 3c 24             	mov    %edi,(%esp)
  801db6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dba:	75 1c                	jne    801dd8 <__umoddi3+0x48>
  801dbc:	39 f7                	cmp    %esi,%edi
  801dbe:	76 50                	jbe    801e10 <__umoddi3+0x80>
  801dc0:	89 c8                	mov    %ecx,%eax
  801dc2:	89 f2                	mov    %esi,%edx
  801dc4:	f7 f7                	div    %edi
  801dc6:	89 d0                	mov    %edx,%eax
  801dc8:	31 d2                	xor    %edx,%edx
  801dca:	83 c4 1c             	add    $0x1c,%esp
  801dcd:	5b                   	pop    %ebx
  801dce:	5e                   	pop    %esi
  801dcf:	5f                   	pop    %edi
  801dd0:	5d                   	pop    %ebp
  801dd1:	c3                   	ret    
  801dd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801dd8:	39 f2                	cmp    %esi,%edx
  801dda:	89 d0                	mov    %edx,%eax
  801ddc:	77 52                	ja     801e30 <__umoddi3+0xa0>
  801dde:	0f bd ea             	bsr    %edx,%ebp
  801de1:	83 f5 1f             	xor    $0x1f,%ebp
  801de4:	75 5a                	jne    801e40 <__umoddi3+0xb0>
  801de6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801dea:	0f 82 e0 00 00 00    	jb     801ed0 <__umoddi3+0x140>
  801df0:	39 0c 24             	cmp    %ecx,(%esp)
  801df3:	0f 86 d7 00 00 00    	jbe    801ed0 <__umoddi3+0x140>
  801df9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801dfd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e01:	83 c4 1c             	add    $0x1c,%esp
  801e04:	5b                   	pop    %ebx
  801e05:	5e                   	pop    %esi
  801e06:	5f                   	pop    %edi
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    
  801e09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e10:	85 ff                	test   %edi,%edi
  801e12:	89 fd                	mov    %edi,%ebp
  801e14:	75 0b                	jne    801e21 <__umoddi3+0x91>
  801e16:	b8 01 00 00 00       	mov    $0x1,%eax
  801e1b:	31 d2                	xor    %edx,%edx
  801e1d:	f7 f7                	div    %edi
  801e1f:	89 c5                	mov    %eax,%ebp
  801e21:	89 f0                	mov    %esi,%eax
  801e23:	31 d2                	xor    %edx,%edx
  801e25:	f7 f5                	div    %ebp
  801e27:	89 c8                	mov    %ecx,%eax
  801e29:	f7 f5                	div    %ebp
  801e2b:	89 d0                	mov    %edx,%eax
  801e2d:	eb 99                	jmp    801dc8 <__umoddi3+0x38>
  801e2f:	90                   	nop
  801e30:	89 c8                	mov    %ecx,%eax
  801e32:	89 f2                	mov    %esi,%edx
  801e34:	83 c4 1c             	add    $0x1c,%esp
  801e37:	5b                   	pop    %ebx
  801e38:	5e                   	pop    %esi
  801e39:	5f                   	pop    %edi
  801e3a:	5d                   	pop    %ebp
  801e3b:	c3                   	ret    
  801e3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801e40:	8b 34 24             	mov    (%esp),%esi
  801e43:	bf 20 00 00 00       	mov    $0x20,%edi
  801e48:	89 e9                	mov    %ebp,%ecx
  801e4a:	29 ef                	sub    %ebp,%edi
  801e4c:	d3 e0                	shl    %cl,%eax
  801e4e:	89 f9                	mov    %edi,%ecx
  801e50:	89 f2                	mov    %esi,%edx
  801e52:	d3 ea                	shr    %cl,%edx
  801e54:	89 e9                	mov    %ebp,%ecx
  801e56:	09 c2                	or     %eax,%edx
  801e58:	89 d8                	mov    %ebx,%eax
  801e5a:	89 14 24             	mov    %edx,(%esp)
  801e5d:	89 f2                	mov    %esi,%edx
  801e5f:	d3 e2                	shl    %cl,%edx
  801e61:	89 f9                	mov    %edi,%ecx
  801e63:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801e6b:	d3 e8                	shr    %cl,%eax
  801e6d:	89 e9                	mov    %ebp,%ecx
  801e6f:	89 c6                	mov    %eax,%esi
  801e71:	d3 e3                	shl    %cl,%ebx
  801e73:	89 f9                	mov    %edi,%ecx
  801e75:	89 d0                	mov    %edx,%eax
  801e77:	d3 e8                	shr    %cl,%eax
  801e79:	89 e9                	mov    %ebp,%ecx
  801e7b:	09 d8                	or     %ebx,%eax
  801e7d:	89 d3                	mov    %edx,%ebx
  801e7f:	89 f2                	mov    %esi,%edx
  801e81:	f7 34 24             	divl   (%esp)
  801e84:	89 d6                	mov    %edx,%esi
  801e86:	d3 e3                	shl    %cl,%ebx
  801e88:	f7 64 24 04          	mull   0x4(%esp)
  801e8c:	39 d6                	cmp    %edx,%esi
  801e8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801e92:	89 d1                	mov    %edx,%ecx
  801e94:	89 c3                	mov    %eax,%ebx
  801e96:	72 08                	jb     801ea0 <__umoddi3+0x110>
  801e98:	75 11                	jne    801eab <__umoddi3+0x11b>
  801e9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801e9e:	73 0b                	jae    801eab <__umoddi3+0x11b>
  801ea0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801ea4:	1b 14 24             	sbb    (%esp),%edx
  801ea7:	89 d1                	mov    %edx,%ecx
  801ea9:	89 c3                	mov    %eax,%ebx
  801eab:	8b 54 24 08          	mov    0x8(%esp),%edx
  801eaf:	29 da                	sub    %ebx,%edx
  801eb1:	19 ce                	sbb    %ecx,%esi
  801eb3:	89 f9                	mov    %edi,%ecx
  801eb5:	89 f0                	mov    %esi,%eax
  801eb7:	d3 e0                	shl    %cl,%eax
  801eb9:	89 e9                	mov    %ebp,%ecx
  801ebb:	d3 ea                	shr    %cl,%edx
  801ebd:	89 e9                	mov    %ebp,%ecx
  801ebf:	d3 ee                	shr    %cl,%esi
  801ec1:	09 d0                	or     %edx,%eax
  801ec3:	89 f2                	mov    %esi,%edx
  801ec5:	83 c4 1c             	add    $0x1c,%esp
  801ec8:	5b                   	pop    %ebx
  801ec9:	5e                   	pop    %esi
  801eca:	5f                   	pop    %edi
  801ecb:	5d                   	pop    %ebp
  801ecc:	c3                   	ret    
  801ecd:	8d 76 00             	lea    0x0(%esi),%esi
  801ed0:	29 f9                	sub    %edi,%ecx
  801ed2:	19 d6                	sbb    %edx,%esi
  801ed4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801ed8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801edc:	e9 18 ff ff ff       	jmp    801df9 <__umoddi3+0x69>
