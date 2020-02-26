
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
  800045:	68 a0 23 80 00       	push   $0x8023a0
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
  80006c:	e8 39 0d 00 00       	call   800daa <set_pgfault_handler>
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
  80009d:	a3 08 40 80 00       	mov    %eax,0x804008

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
  8000cc:	e8 2b 0f 00 00       	call   800ffc <close_all>
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
  8001d6:	e8 25 1f 00 00       	call   802100 <__udivdi3>
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
  800219:	e8 12 20 00 00       	call   802230 <__umoddi3>
  80021e:	83 c4 14             	add    $0x14,%esp
  800221:	0f be 80 c6 23 80 00 	movsbl 0x8023c6(%eax),%eax
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
  8002e3:	ff 24 85 00 25 80 00 	jmp    *0x802500(,%eax,4)
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
  8003aa:	8b 14 85 60 26 80 00 	mov    0x802660(,%eax,4),%edx
  8003b1:	85 d2                	test   %edx,%edx
  8003b3:	75 1b                	jne    8003d0 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003b5:	50                   	push   %eax
  8003b6:	68 de 23 80 00       	push   $0x8023de
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
  8003d1:	68 b9 27 80 00       	push   $0x8027b9
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
  8003fb:	b8 d7 23 80 00       	mov    $0x8023d7,%eax
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
  800b23:	68 bf 26 80 00       	push   $0x8026bf
  800b28:	6a 23                	push   $0x23
  800b2a:	68 dc 26 80 00       	push   $0x8026dc
  800b2f:	e8 4e 14 00 00       	call   801f82 <_panic>

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
  800ba4:	68 bf 26 80 00       	push   $0x8026bf
  800ba9:	6a 23                	push   $0x23
  800bab:	68 dc 26 80 00       	push   $0x8026dc
  800bb0:	e8 cd 13 00 00       	call   801f82 <_panic>

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
  800be6:	68 bf 26 80 00       	push   $0x8026bf
  800beb:	6a 23                	push   $0x23
  800bed:	68 dc 26 80 00       	push   $0x8026dc
  800bf2:	e8 8b 13 00 00       	call   801f82 <_panic>

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
  800c28:	68 bf 26 80 00       	push   $0x8026bf
  800c2d:	6a 23                	push   $0x23
  800c2f:	68 dc 26 80 00       	push   $0x8026dc
  800c34:	e8 49 13 00 00       	call   801f82 <_panic>

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
  800c6a:	68 bf 26 80 00       	push   $0x8026bf
  800c6f:	6a 23                	push   $0x23
  800c71:	68 dc 26 80 00       	push   $0x8026dc
  800c76:	e8 07 13 00 00       	call   801f82 <_panic>

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
  800cac:	68 bf 26 80 00       	push   $0x8026bf
  800cb1:	6a 23                	push   $0x23
  800cb3:	68 dc 26 80 00       	push   $0x8026dc
  800cb8:	e8 c5 12 00 00       	call   801f82 <_panic>

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
  800cee:	68 bf 26 80 00       	push   $0x8026bf
  800cf3:	6a 23                	push   $0x23
  800cf5:	68 dc 26 80 00       	push   $0x8026dc
  800cfa:	e8 83 12 00 00       	call   801f82 <_panic>

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
  800d52:	68 bf 26 80 00       	push   $0x8026bf
  800d57:	6a 23                	push   $0x23
  800d59:	68 dc 26 80 00       	push   $0x8026dc
  800d5e:	e8 1f 12 00 00       	call   801f82 <_panic>

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

00800d6b <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	ba 00 00 00 00       	mov    $0x0,%edx
  800d76:	b8 0e 00 00 00       	mov    $0xe,%eax
  800d7b:	89 d1                	mov    %edx,%ecx
  800d7d:	89 d3                	mov    %edx,%ebx
  800d7f:	89 d7                	mov    %edx,%edi
  800d81:	89 d6                	mov    %edx,%esi
  800d83:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800d85:	5b                   	pop    %ebx
  800d86:	5e                   	pop    %esi
  800d87:	5f                   	pop    %edi
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
  800d8d:	57                   	push   %edi
  800d8e:	56                   	push   %esi
  800d8f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d95:	b8 10 00 00 00       	mov    $0x10,%eax
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	89 cb                	mov    %ecx,%ebx
  800d9f:	89 cf                	mov    %ecx,%edi
  800da1:	89 ce                	mov    %ecx,%esi
  800da3:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800da5:	5b                   	pop    %ebx
  800da6:	5e                   	pop    %esi
  800da7:	5f                   	pop    %edi
  800da8:	5d                   	pop    %ebp
  800da9:	c3                   	ret    

00800daa <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800db0:	83 3d 0c 40 80 00 00 	cmpl   $0x0,0x80400c
  800db7:	75 4a                	jne    800e03 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  800db9:	a1 08 40 80 00       	mov    0x804008,%eax
  800dbe:	8b 40 48             	mov    0x48(%eax),%eax
  800dc1:	83 ec 04             	sub    $0x4,%esp
  800dc4:	6a 07                	push   $0x7
  800dc6:	68 00 f0 bf ee       	push   $0xeebff000
  800dcb:	50                   	push   %eax
  800dcc:	e8 a9 fd ff ff       	call   800b7a <sys_page_alloc>
  800dd1:	83 c4 10             	add    $0x10,%esp
  800dd4:	85 c0                	test   %eax,%eax
  800dd6:	79 12                	jns    800dea <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  800dd8:	50                   	push   %eax
  800dd9:	68 ea 26 80 00       	push   $0x8026ea
  800dde:	6a 21                	push   $0x21
  800de0:	68 02 27 80 00       	push   $0x802702
  800de5:	e8 98 11 00 00       	call   801f82 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  800dea:	a1 08 40 80 00       	mov    0x804008,%eax
  800def:	8b 40 48             	mov    0x48(%eax),%eax
  800df2:	83 ec 08             	sub    $0x8,%esp
  800df5:	68 0d 0e 80 00       	push   $0x800e0d
  800dfa:	50                   	push   %eax
  800dfb:	e8 c5 fe ff ff       	call   800cc5 <sys_env_set_pgfault_upcall>
  800e00:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800e03:	8b 45 08             	mov    0x8(%ebp),%eax
  800e06:	a3 0c 40 80 00       	mov    %eax,0x80400c
  800e0b:	c9                   	leave  
  800e0c:	c3                   	ret    

00800e0d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800e0d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800e0e:	a1 0c 40 80 00       	mov    0x80400c,%eax
	call *%eax
  800e13:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800e15:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  800e18:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  800e1b:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  800e1f:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  800e24:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  800e28:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  800e2a:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  800e2b:	83 c4 04             	add    $0x4,%esp
	popfl
  800e2e:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800e2f:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  800e30:	c3                   	ret    

00800e31 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800e31:	55                   	push   %ebp
  800e32:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800e34:	8b 45 08             	mov    0x8(%ebp),%eax
  800e37:	05 00 00 00 30       	add    $0x30000000,%eax
  800e3c:	c1 e8 0c             	shr    $0xc,%eax
}
  800e3f:	5d                   	pop    %ebp
  800e40:	c3                   	ret    

00800e41 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800e44:	8b 45 08             	mov    0x8(%ebp),%eax
  800e47:	05 00 00 00 30       	add    $0x30000000,%eax
  800e4c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e51:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e56:	5d                   	pop    %ebp
  800e57:	c3                   	ret    

00800e58 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e58:	55                   	push   %ebp
  800e59:	89 e5                	mov    %esp,%ebp
  800e5b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e63:	89 c2                	mov    %eax,%edx
  800e65:	c1 ea 16             	shr    $0x16,%edx
  800e68:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e6f:	f6 c2 01             	test   $0x1,%dl
  800e72:	74 11                	je     800e85 <fd_alloc+0x2d>
  800e74:	89 c2                	mov    %eax,%edx
  800e76:	c1 ea 0c             	shr    $0xc,%edx
  800e79:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e80:	f6 c2 01             	test   $0x1,%dl
  800e83:	75 09                	jne    800e8e <fd_alloc+0x36>
			*fd_store = fd;
  800e85:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e87:	b8 00 00 00 00       	mov    $0x0,%eax
  800e8c:	eb 17                	jmp    800ea5 <fd_alloc+0x4d>
  800e8e:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e93:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e98:	75 c9                	jne    800e63 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e9a:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800ea0:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    

00800ea7 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800ead:	83 f8 1f             	cmp    $0x1f,%eax
  800eb0:	77 36                	ja     800ee8 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800eb2:	c1 e0 0c             	shl    $0xc,%eax
  800eb5:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800eba:	89 c2                	mov    %eax,%edx
  800ebc:	c1 ea 16             	shr    $0x16,%edx
  800ebf:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800ec6:	f6 c2 01             	test   $0x1,%dl
  800ec9:	74 24                	je     800eef <fd_lookup+0x48>
  800ecb:	89 c2                	mov    %eax,%edx
  800ecd:	c1 ea 0c             	shr    $0xc,%edx
  800ed0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800ed7:	f6 c2 01             	test   $0x1,%dl
  800eda:	74 1a                	je     800ef6 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800edc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800edf:	89 02                	mov    %eax,(%edx)
	return 0;
  800ee1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee6:	eb 13                	jmp    800efb <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ee8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eed:	eb 0c                	jmp    800efb <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800eef:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ef4:	eb 05                	jmp    800efb <fd_lookup+0x54>
  800ef6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800efb:	5d                   	pop    %ebp
  800efc:	c3                   	ret    

00800efd <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	83 ec 08             	sub    $0x8,%esp
  800f03:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f06:	ba 8c 27 80 00       	mov    $0x80278c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800f0b:	eb 13                	jmp    800f20 <dev_lookup+0x23>
  800f0d:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800f10:	39 08                	cmp    %ecx,(%eax)
  800f12:	75 0c                	jne    800f20 <dev_lookup+0x23>
			*dev = devtab[i];
  800f14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f17:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f19:	b8 00 00 00 00       	mov    $0x0,%eax
  800f1e:	eb 2e                	jmp    800f4e <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800f20:	8b 02                	mov    (%edx),%eax
  800f22:	85 c0                	test   %eax,%eax
  800f24:	75 e7                	jne    800f0d <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800f26:	a1 08 40 80 00       	mov    0x804008,%eax
  800f2b:	8b 40 48             	mov    0x48(%eax),%eax
  800f2e:	83 ec 04             	sub    $0x4,%esp
  800f31:	51                   	push   %ecx
  800f32:	50                   	push   %eax
  800f33:	68 10 27 80 00       	push   $0x802710
  800f38:	e8 36 f2 ff ff       	call   800173 <cprintf>
	*dev = 0;
  800f3d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f40:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f46:	83 c4 10             	add    $0x10,%esp
  800f49:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f4e:	c9                   	leave  
  800f4f:	c3                   	ret    

00800f50 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f50:	55                   	push   %ebp
  800f51:	89 e5                	mov    %esp,%ebp
  800f53:	56                   	push   %esi
  800f54:	53                   	push   %ebx
  800f55:	83 ec 10             	sub    $0x10,%esp
  800f58:	8b 75 08             	mov    0x8(%ebp),%esi
  800f5b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f61:	50                   	push   %eax
  800f62:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f68:	c1 e8 0c             	shr    $0xc,%eax
  800f6b:	50                   	push   %eax
  800f6c:	e8 36 ff ff ff       	call   800ea7 <fd_lookup>
  800f71:	83 c4 08             	add    $0x8,%esp
  800f74:	85 c0                	test   %eax,%eax
  800f76:	78 05                	js     800f7d <fd_close+0x2d>
	    || fd != fd2)
  800f78:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f7b:	74 0c                	je     800f89 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f7d:	84 db                	test   %bl,%bl
  800f7f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f84:	0f 44 c2             	cmove  %edx,%eax
  800f87:	eb 41                	jmp    800fca <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f89:	83 ec 08             	sub    $0x8,%esp
  800f8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f8f:	50                   	push   %eax
  800f90:	ff 36                	pushl  (%esi)
  800f92:	e8 66 ff ff ff       	call   800efd <dev_lookup>
  800f97:	89 c3                	mov    %eax,%ebx
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	78 1a                	js     800fba <fd_close+0x6a>
		if (dev->dev_close)
  800fa0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800fa3:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800fa6:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800fab:	85 c0                	test   %eax,%eax
  800fad:	74 0b                	je     800fba <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800faf:	83 ec 0c             	sub    $0xc,%esp
  800fb2:	56                   	push   %esi
  800fb3:	ff d0                	call   *%eax
  800fb5:	89 c3                	mov    %eax,%ebx
  800fb7:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800fba:	83 ec 08             	sub    $0x8,%esp
  800fbd:	56                   	push   %esi
  800fbe:	6a 00                	push   $0x0
  800fc0:	e8 3a fc ff ff       	call   800bff <sys_page_unmap>
	return r;
  800fc5:	83 c4 10             	add    $0x10,%esp
  800fc8:	89 d8                	mov    %ebx,%eax
}
  800fca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800fcd:	5b                   	pop    %ebx
  800fce:	5e                   	pop    %esi
  800fcf:	5d                   	pop    %ebp
  800fd0:	c3                   	ret    

00800fd1 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800fd1:	55                   	push   %ebp
  800fd2:	89 e5                	mov    %esp,%ebp
  800fd4:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fda:	50                   	push   %eax
  800fdb:	ff 75 08             	pushl  0x8(%ebp)
  800fde:	e8 c4 fe ff ff       	call   800ea7 <fd_lookup>
  800fe3:	83 c4 08             	add    $0x8,%esp
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	78 10                	js     800ffa <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fea:	83 ec 08             	sub    $0x8,%esp
  800fed:	6a 01                	push   $0x1
  800fef:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff2:	e8 59 ff ff ff       	call   800f50 <fd_close>
  800ff7:	83 c4 10             	add    $0x10,%esp
}
  800ffa:	c9                   	leave  
  800ffb:	c3                   	ret    

00800ffc <close_all>:

void
close_all(void)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	53                   	push   %ebx
  801000:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801003:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801008:	83 ec 0c             	sub    $0xc,%esp
  80100b:	53                   	push   %ebx
  80100c:	e8 c0 ff ff ff       	call   800fd1 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801011:	83 c3 01             	add    $0x1,%ebx
  801014:	83 c4 10             	add    $0x10,%esp
  801017:	83 fb 20             	cmp    $0x20,%ebx
  80101a:	75 ec                	jne    801008 <close_all+0xc>
		close(i);
}
  80101c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80101f:	c9                   	leave  
  801020:	c3                   	ret    

00801021 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	57                   	push   %edi
  801025:	56                   	push   %esi
  801026:	53                   	push   %ebx
  801027:	83 ec 2c             	sub    $0x2c,%esp
  80102a:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80102d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801030:	50                   	push   %eax
  801031:	ff 75 08             	pushl  0x8(%ebp)
  801034:	e8 6e fe ff ff       	call   800ea7 <fd_lookup>
  801039:	83 c4 08             	add    $0x8,%esp
  80103c:	85 c0                	test   %eax,%eax
  80103e:	0f 88 c1 00 00 00    	js     801105 <dup+0xe4>
		return r;
	close(newfdnum);
  801044:	83 ec 0c             	sub    $0xc,%esp
  801047:	56                   	push   %esi
  801048:	e8 84 ff ff ff       	call   800fd1 <close>

	newfd = INDEX2FD(newfdnum);
  80104d:	89 f3                	mov    %esi,%ebx
  80104f:	c1 e3 0c             	shl    $0xc,%ebx
  801052:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801058:	83 c4 04             	add    $0x4,%esp
  80105b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80105e:	e8 de fd ff ff       	call   800e41 <fd2data>
  801063:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801065:	89 1c 24             	mov    %ebx,(%esp)
  801068:	e8 d4 fd ff ff       	call   800e41 <fd2data>
  80106d:	83 c4 10             	add    $0x10,%esp
  801070:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801073:	89 f8                	mov    %edi,%eax
  801075:	c1 e8 16             	shr    $0x16,%eax
  801078:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80107f:	a8 01                	test   $0x1,%al
  801081:	74 37                	je     8010ba <dup+0x99>
  801083:	89 f8                	mov    %edi,%eax
  801085:	c1 e8 0c             	shr    $0xc,%eax
  801088:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80108f:	f6 c2 01             	test   $0x1,%dl
  801092:	74 26                	je     8010ba <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801094:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	25 07 0e 00 00       	and    $0xe07,%eax
  8010a3:	50                   	push   %eax
  8010a4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010a7:	6a 00                	push   $0x0
  8010a9:	57                   	push   %edi
  8010aa:	6a 00                	push   $0x0
  8010ac:	e8 0c fb ff ff       	call   800bbd <sys_page_map>
  8010b1:	89 c7                	mov    %eax,%edi
  8010b3:	83 c4 20             	add    $0x20,%esp
  8010b6:	85 c0                	test   %eax,%eax
  8010b8:	78 2e                	js     8010e8 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8010bd:	89 d0                	mov    %edx,%eax
  8010bf:	c1 e8 0c             	shr    $0xc,%eax
  8010c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010c9:	83 ec 0c             	sub    $0xc,%esp
  8010cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8010d1:	50                   	push   %eax
  8010d2:	53                   	push   %ebx
  8010d3:	6a 00                	push   $0x0
  8010d5:	52                   	push   %edx
  8010d6:	6a 00                	push   $0x0
  8010d8:	e8 e0 fa ff ff       	call   800bbd <sys_page_map>
  8010dd:	89 c7                	mov    %eax,%edi
  8010df:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8010e2:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8010e4:	85 ff                	test   %edi,%edi
  8010e6:	79 1d                	jns    801105 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010e8:	83 ec 08             	sub    $0x8,%esp
  8010eb:	53                   	push   %ebx
  8010ec:	6a 00                	push   $0x0
  8010ee:	e8 0c fb ff ff       	call   800bff <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010f3:	83 c4 08             	add    $0x8,%esp
  8010f6:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010f9:	6a 00                	push   $0x0
  8010fb:	e8 ff fa ff ff       	call   800bff <sys_page_unmap>
	return r;
  801100:	83 c4 10             	add    $0x10,%esp
  801103:	89 f8                	mov    %edi,%eax
}
  801105:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801108:	5b                   	pop    %ebx
  801109:	5e                   	pop    %esi
  80110a:	5f                   	pop    %edi
  80110b:	5d                   	pop    %ebp
  80110c:	c3                   	ret    

0080110d <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80110d:	55                   	push   %ebp
  80110e:	89 e5                	mov    %esp,%ebp
  801110:	53                   	push   %ebx
  801111:	83 ec 14             	sub    $0x14,%esp
  801114:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801117:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80111a:	50                   	push   %eax
  80111b:	53                   	push   %ebx
  80111c:	e8 86 fd ff ff       	call   800ea7 <fd_lookup>
  801121:	83 c4 08             	add    $0x8,%esp
  801124:	89 c2                	mov    %eax,%edx
  801126:	85 c0                	test   %eax,%eax
  801128:	78 6d                	js     801197 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80112a:	83 ec 08             	sub    $0x8,%esp
  80112d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801130:	50                   	push   %eax
  801131:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801134:	ff 30                	pushl  (%eax)
  801136:	e8 c2 fd ff ff       	call   800efd <dev_lookup>
  80113b:	83 c4 10             	add    $0x10,%esp
  80113e:	85 c0                	test   %eax,%eax
  801140:	78 4c                	js     80118e <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801142:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801145:	8b 42 08             	mov    0x8(%edx),%eax
  801148:	83 e0 03             	and    $0x3,%eax
  80114b:	83 f8 01             	cmp    $0x1,%eax
  80114e:	75 21                	jne    801171 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801150:	a1 08 40 80 00       	mov    0x804008,%eax
  801155:	8b 40 48             	mov    0x48(%eax),%eax
  801158:	83 ec 04             	sub    $0x4,%esp
  80115b:	53                   	push   %ebx
  80115c:	50                   	push   %eax
  80115d:	68 51 27 80 00       	push   $0x802751
  801162:	e8 0c f0 ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  801167:	83 c4 10             	add    $0x10,%esp
  80116a:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80116f:	eb 26                	jmp    801197 <read+0x8a>
	}
	if (!dev->dev_read)
  801171:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801174:	8b 40 08             	mov    0x8(%eax),%eax
  801177:	85 c0                	test   %eax,%eax
  801179:	74 17                	je     801192 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80117b:	83 ec 04             	sub    $0x4,%esp
  80117e:	ff 75 10             	pushl  0x10(%ebp)
  801181:	ff 75 0c             	pushl  0xc(%ebp)
  801184:	52                   	push   %edx
  801185:	ff d0                	call   *%eax
  801187:	89 c2                	mov    %eax,%edx
  801189:	83 c4 10             	add    $0x10,%esp
  80118c:	eb 09                	jmp    801197 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80118e:	89 c2                	mov    %eax,%edx
  801190:	eb 05                	jmp    801197 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  801192:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801197:	89 d0                	mov    %edx,%eax
  801199:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80119c:	c9                   	leave  
  80119d:	c3                   	ret    

0080119e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	57                   	push   %edi
  8011a2:	56                   	push   %esi
  8011a3:	53                   	push   %ebx
  8011a4:	83 ec 0c             	sub    $0xc,%esp
  8011a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8011aa:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011ad:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011b2:	eb 21                	jmp    8011d5 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011b4:	83 ec 04             	sub    $0x4,%esp
  8011b7:	89 f0                	mov    %esi,%eax
  8011b9:	29 d8                	sub    %ebx,%eax
  8011bb:	50                   	push   %eax
  8011bc:	89 d8                	mov    %ebx,%eax
  8011be:	03 45 0c             	add    0xc(%ebp),%eax
  8011c1:	50                   	push   %eax
  8011c2:	57                   	push   %edi
  8011c3:	e8 45 ff ff ff       	call   80110d <read>
		if (m < 0)
  8011c8:	83 c4 10             	add    $0x10,%esp
  8011cb:	85 c0                	test   %eax,%eax
  8011cd:	78 10                	js     8011df <readn+0x41>
			return m;
		if (m == 0)
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	74 0a                	je     8011dd <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8011d3:	01 c3                	add    %eax,%ebx
  8011d5:	39 f3                	cmp    %esi,%ebx
  8011d7:	72 db                	jb     8011b4 <readn+0x16>
  8011d9:	89 d8                	mov    %ebx,%eax
  8011db:	eb 02                	jmp    8011df <readn+0x41>
  8011dd:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8011df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e2:	5b                   	pop    %ebx
  8011e3:	5e                   	pop    %esi
  8011e4:	5f                   	pop    %edi
  8011e5:	5d                   	pop    %ebp
  8011e6:	c3                   	ret    

008011e7 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011e7:	55                   	push   %ebp
  8011e8:	89 e5                	mov    %esp,%ebp
  8011ea:	53                   	push   %ebx
  8011eb:	83 ec 14             	sub    $0x14,%esp
  8011ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011f4:	50                   	push   %eax
  8011f5:	53                   	push   %ebx
  8011f6:	e8 ac fc ff ff       	call   800ea7 <fd_lookup>
  8011fb:	83 c4 08             	add    $0x8,%esp
  8011fe:	89 c2                	mov    %eax,%edx
  801200:	85 c0                	test   %eax,%eax
  801202:	78 68                	js     80126c <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801204:	83 ec 08             	sub    $0x8,%esp
  801207:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80120a:	50                   	push   %eax
  80120b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80120e:	ff 30                	pushl  (%eax)
  801210:	e8 e8 fc ff ff       	call   800efd <dev_lookup>
  801215:	83 c4 10             	add    $0x10,%esp
  801218:	85 c0                	test   %eax,%eax
  80121a:	78 47                	js     801263 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80121c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80121f:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801223:	75 21                	jne    801246 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801225:	a1 08 40 80 00       	mov    0x804008,%eax
  80122a:	8b 40 48             	mov    0x48(%eax),%eax
  80122d:	83 ec 04             	sub    $0x4,%esp
  801230:	53                   	push   %ebx
  801231:	50                   	push   %eax
  801232:	68 6d 27 80 00       	push   $0x80276d
  801237:	e8 37 ef ff ff       	call   800173 <cprintf>
		return -E_INVAL;
  80123c:	83 c4 10             	add    $0x10,%esp
  80123f:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801244:	eb 26                	jmp    80126c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801246:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801249:	8b 52 0c             	mov    0xc(%edx),%edx
  80124c:	85 d2                	test   %edx,%edx
  80124e:	74 17                	je     801267 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801250:	83 ec 04             	sub    $0x4,%esp
  801253:	ff 75 10             	pushl  0x10(%ebp)
  801256:	ff 75 0c             	pushl  0xc(%ebp)
  801259:	50                   	push   %eax
  80125a:	ff d2                	call   *%edx
  80125c:	89 c2                	mov    %eax,%edx
  80125e:	83 c4 10             	add    $0x10,%esp
  801261:	eb 09                	jmp    80126c <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801263:	89 c2                	mov    %eax,%edx
  801265:	eb 05                	jmp    80126c <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801267:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80126c:	89 d0                	mov    %edx,%eax
  80126e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801271:	c9                   	leave  
  801272:	c3                   	ret    

00801273 <seek>:

int
seek(int fdnum, off_t offset)
{
  801273:	55                   	push   %ebp
  801274:	89 e5                	mov    %esp,%ebp
  801276:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801279:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80127c:	50                   	push   %eax
  80127d:	ff 75 08             	pushl  0x8(%ebp)
  801280:	e8 22 fc ff ff       	call   800ea7 <fd_lookup>
  801285:	83 c4 08             	add    $0x8,%esp
  801288:	85 c0                	test   %eax,%eax
  80128a:	78 0e                	js     80129a <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80128c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80128f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801292:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801295:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80129a:	c9                   	leave  
  80129b:	c3                   	ret    

0080129c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	53                   	push   %ebx
  8012a0:	83 ec 14             	sub    $0x14,%esp
  8012a3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012a9:	50                   	push   %eax
  8012aa:	53                   	push   %ebx
  8012ab:	e8 f7 fb ff ff       	call   800ea7 <fd_lookup>
  8012b0:	83 c4 08             	add    $0x8,%esp
  8012b3:	89 c2                	mov    %eax,%edx
  8012b5:	85 c0                	test   %eax,%eax
  8012b7:	78 65                	js     80131e <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012b9:	83 ec 08             	sub    $0x8,%esp
  8012bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012bf:	50                   	push   %eax
  8012c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c3:	ff 30                	pushl  (%eax)
  8012c5:	e8 33 fc ff ff       	call   800efd <dev_lookup>
  8012ca:	83 c4 10             	add    $0x10,%esp
  8012cd:	85 c0                	test   %eax,%eax
  8012cf:	78 44                	js     801315 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012d4:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012d8:	75 21                	jne    8012fb <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8012da:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012df:	8b 40 48             	mov    0x48(%eax),%eax
  8012e2:	83 ec 04             	sub    $0x4,%esp
  8012e5:	53                   	push   %ebx
  8012e6:	50                   	push   %eax
  8012e7:	68 30 27 80 00       	push   $0x802730
  8012ec:	e8 82 ee ff ff       	call   800173 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012f1:	83 c4 10             	add    $0x10,%esp
  8012f4:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012f9:	eb 23                	jmp    80131e <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012fe:	8b 52 18             	mov    0x18(%edx),%edx
  801301:	85 d2                	test   %edx,%edx
  801303:	74 14                	je     801319 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801305:	83 ec 08             	sub    $0x8,%esp
  801308:	ff 75 0c             	pushl  0xc(%ebp)
  80130b:	50                   	push   %eax
  80130c:	ff d2                	call   *%edx
  80130e:	89 c2                	mov    %eax,%edx
  801310:	83 c4 10             	add    $0x10,%esp
  801313:	eb 09                	jmp    80131e <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801315:	89 c2                	mov    %eax,%edx
  801317:	eb 05                	jmp    80131e <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801319:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80131e:	89 d0                	mov    %edx,%eax
  801320:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801323:	c9                   	leave  
  801324:	c3                   	ret    

00801325 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801325:	55                   	push   %ebp
  801326:	89 e5                	mov    %esp,%ebp
  801328:	53                   	push   %ebx
  801329:	83 ec 14             	sub    $0x14,%esp
  80132c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80132f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801332:	50                   	push   %eax
  801333:	ff 75 08             	pushl  0x8(%ebp)
  801336:	e8 6c fb ff ff       	call   800ea7 <fd_lookup>
  80133b:	83 c4 08             	add    $0x8,%esp
  80133e:	89 c2                	mov    %eax,%edx
  801340:	85 c0                	test   %eax,%eax
  801342:	78 58                	js     80139c <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801344:	83 ec 08             	sub    $0x8,%esp
  801347:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80134a:	50                   	push   %eax
  80134b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80134e:	ff 30                	pushl  (%eax)
  801350:	e8 a8 fb ff ff       	call   800efd <dev_lookup>
  801355:	83 c4 10             	add    $0x10,%esp
  801358:	85 c0                	test   %eax,%eax
  80135a:	78 37                	js     801393 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80135c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80135f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801363:	74 32                	je     801397 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801365:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801368:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80136f:	00 00 00 
	stat->st_isdir = 0;
  801372:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801379:	00 00 00 
	stat->st_dev = dev;
  80137c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801382:	83 ec 08             	sub    $0x8,%esp
  801385:	53                   	push   %ebx
  801386:	ff 75 f0             	pushl  -0x10(%ebp)
  801389:	ff 50 14             	call   *0x14(%eax)
  80138c:	89 c2                	mov    %eax,%edx
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	eb 09                	jmp    80139c <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801393:	89 c2                	mov    %eax,%edx
  801395:	eb 05                	jmp    80139c <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801397:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  80139c:	89 d0                	mov    %edx,%eax
  80139e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013a1:	c9                   	leave  
  8013a2:	c3                   	ret    

008013a3 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8013a3:	55                   	push   %ebp
  8013a4:	89 e5                	mov    %esp,%ebp
  8013a6:	56                   	push   %esi
  8013a7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8013a8:	83 ec 08             	sub    $0x8,%esp
  8013ab:	6a 00                	push   $0x0
  8013ad:	ff 75 08             	pushl  0x8(%ebp)
  8013b0:	e8 e3 01 00 00       	call   801598 <open>
  8013b5:	89 c3                	mov    %eax,%ebx
  8013b7:	83 c4 10             	add    $0x10,%esp
  8013ba:	85 c0                	test   %eax,%eax
  8013bc:	78 1b                	js     8013d9 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8013be:	83 ec 08             	sub    $0x8,%esp
  8013c1:	ff 75 0c             	pushl  0xc(%ebp)
  8013c4:	50                   	push   %eax
  8013c5:	e8 5b ff ff ff       	call   801325 <fstat>
  8013ca:	89 c6                	mov    %eax,%esi
	close(fd);
  8013cc:	89 1c 24             	mov    %ebx,(%esp)
  8013cf:	e8 fd fb ff ff       	call   800fd1 <close>
	return r;
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	89 f0                	mov    %esi,%eax
}
  8013d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013dc:	5b                   	pop    %ebx
  8013dd:	5e                   	pop    %esi
  8013de:	5d                   	pop    %ebp
  8013df:	c3                   	ret    

008013e0 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013e0:	55                   	push   %ebp
  8013e1:	89 e5                	mov    %esp,%ebp
  8013e3:	56                   	push   %esi
  8013e4:	53                   	push   %ebx
  8013e5:	89 c6                	mov    %eax,%esi
  8013e7:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013e9:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013f0:	75 12                	jne    801404 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013f2:	83 ec 0c             	sub    $0xc,%esp
  8013f5:	6a 01                	push   $0x1
  8013f7:	e8 89 0c 00 00       	call   802085 <ipc_find_env>
  8013fc:	a3 00 40 80 00       	mov    %eax,0x804000
  801401:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801404:	6a 07                	push   $0x7
  801406:	68 00 50 80 00       	push   $0x805000
  80140b:	56                   	push   %esi
  80140c:	ff 35 00 40 80 00    	pushl  0x804000
  801412:	e8 1a 0c 00 00       	call   802031 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801417:	83 c4 0c             	add    $0xc,%esp
  80141a:	6a 00                	push   $0x0
  80141c:	53                   	push   %ebx
  80141d:	6a 00                	push   $0x0
  80141f:	e8 a4 0b 00 00       	call   801fc8 <ipc_recv>
}
  801424:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801427:	5b                   	pop    %ebx
  801428:	5e                   	pop    %esi
  801429:	5d                   	pop    %ebp
  80142a:	c3                   	ret    

0080142b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80142b:	55                   	push   %ebp
  80142c:	89 e5                	mov    %esp,%ebp
  80142e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801431:	8b 45 08             	mov    0x8(%ebp),%eax
  801434:	8b 40 0c             	mov    0xc(%eax),%eax
  801437:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80143c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80143f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801444:	ba 00 00 00 00       	mov    $0x0,%edx
  801449:	b8 02 00 00 00       	mov    $0x2,%eax
  80144e:	e8 8d ff ff ff       	call   8013e0 <fsipc>
}
  801453:	c9                   	leave  
  801454:	c3                   	ret    

00801455 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80145b:	8b 45 08             	mov    0x8(%ebp),%eax
  80145e:	8b 40 0c             	mov    0xc(%eax),%eax
  801461:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801466:	ba 00 00 00 00       	mov    $0x0,%edx
  80146b:	b8 06 00 00 00       	mov    $0x6,%eax
  801470:	e8 6b ff ff ff       	call   8013e0 <fsipc>
}
  801475:	c9                   	leave  
  801476:	c3                   	ret    

00801477 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801477:	55                   	push   %ebp
  801478:	89 e5                	mov    %esp,%ebp
  80147a:	53                   	push   %ebx
  80147b:	83 ec 04             	sub    $0x4,%esp
  80147e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801481:	8b 45 08             	mov    0x8(%ebp),%eax
  801484:	8b 40 0c             	mov    0xc(%eax),%eax
  801487:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80148c:	ba 00 00 00 00       	mov    $0x0,%edx
  801491:	b8 05 00 00 00       	mov    $0x5,%eax
  801496:	e8 45 ff ff ff       	call   8013e0 <fsipc>
  80149b:	85 c0                	test   %eax,%eax
  80149d:	78 2c                	js     8014cb <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80149f:	83 ec 08             	sub    $0x8,%esp
  8014a2:	68 00 50 80 00       	push   $0x805000
  8014a7:	53                   	push   %ebx
  8014a8:	e8 ca f2 ff ff       	call   800777 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8014ad:	a1 80 50 80 00       	mov    0x805080,%eax
  8014b2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8014b8:	a1 84 50 80 00       	mov    0x805084,%eax
  8014bd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8014c3:	83 c4 10             	add    $0x10,%esp
  8014c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	83 ec 0c             	sub    $0xc,%esp
  8014d6:	8b 45 10             	mov    0x10(%ebp),%eax
  8014d9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014de:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014e3:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8014e9:	8b 52 0c             	mov    0xc(%edx),%edx
  8014ec:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014f2:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014f7:	50                   	push   %eax
  8014f8:	ff 75 0c             	pushl  0xc(%ebp)
  8014fb:	68 08 50 80 00       	push   $0x805008
  801500:	e8 04 f4 ff ff       	call   800909 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801505:	ba 00 00 00 00       	mov    $0x0,%edx
  80150a:	b8 04 00 00 00       	mov    $0x4,%eax
  80150f:	e8 cc fe ff ff       	call   8013e0 <fsipc>
	//panic("devfile_write not implemented");
}
  801514:	c9                   	leave  
  801515:	c3                   	ret    

00801516 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801516:	55                   	push   %ebp
  801517:	89 e5                	mov    %esp,%ebp
  801519:	56                   	push   %esi
  80151a:	53                   	push   %ebx
  80151b:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80151e:	8b 45 08             	mov    0x8(%ebp),%eax
  801521:	8b 40 0c             	mov    0xc(%eax),%eax
  801524:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801529:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80152f:	ba 00 00 00 00       	mov    $0x0,%edx
  801534:	b8 03 00 00 00       	mov    $0x3,%eax
  801539:	e8 a2 fe ff ff       	call   8013e0 <fsipc>
  80153e:	89 c3                	mov    %eax,%ebx
  801540:	85 c0                	test   %eax,%eax
  801542:	78 4b                	js     80158f <devfile_read+0x79>
		return r;
	assert(r <= n);
  801544:	39 c6                	cmp    %eax,%esi
  801546:	73 16                	jae    80155e <devfile_read+0x48>
  801548:	68 a0 27 80 00       	push   $0x8027a0
  80154d:	68 a7 27 80 00       	push   $0x8027a7
  801552:	6a 7c                	push   $0x7c
  801554:	68 bc 27 80 00       	push   $0x8027bc
  801559:	e8 24 0a 00 00       	call   801f82 <_panic>
	assert(r <= PGSIZE);
  80155e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801563:	7e 16                	jle    80157b <devfile_read+0x65>
  801565:	68 c7 27 80 00       	push   $0x8027c7
  80156a:	68 a7 27 80 00       	push   $0x8027a7
  80156f:	6a 7d                	push   $0x7d
  801571:	68 bc 27 80 00       	push   $0x8027bc
  801576:	e8 07 0a 00 00       	call   801f82 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80157b:	83 ec 04             	sub    $0x4,%esp
  80157e:	50                   	push   %eax
  80157f:	68 00 50 80 00       	push   $0x805000
  801584:	ff 75 0c             	pushl  0xc(%ebp)
  801587:	e8 7d f3 ff ff       	call   800909 <memmove>
	return r;
  80158c:	83 c4 10             	add    $0x10,%esp
}
  80158f:	89 d8                	mov    %ebx,%eax
  801591:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801594:	5b                   	pop    %ebx
  801595:	5e                   	pop    %esi
  801596:	5d                   	pop    %ebp
  801597:	c3                   	ret    

00801598 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801598:	55                   	push   %ebp
  801599:	89 e5                	mov    %esp,%ebp
  80159b:	53                   	push   %ebx
  80159c:	83 ec 20             	sub    $0x20,%esp
  80159f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8015a2:	53                   	push   %ebx
  8015a3:	e8 96 f1 ff ff       	call   80073e <strlen>
  8015a8:	83 c4 10             	add    $0x10,%esp
  8015ab:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8015b0:	7f 67                	jg     801619 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015b2:	83 ec 0c             	sub    $0xc,%esp
  8015b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015b8:	50                   	push   %eax
  8015b9:	e8 9a f8 ff ff       	call   800e58 <fd_alloc>
  8015be:	83 c4 10             	add    $0x10,%esp
		return r;
  8015c1:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8015c3:	85 c0                	test   %eax,%eax
  8015c5:	78 57                	js     80161e <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8015c7:	83 ec 08             	sub    $0x8,%esp
  8015ca:	53                   	push   %ebx
  8015cb:	68 00 50 80 00       	push   $0x805000
  8015d0:	e8 a2 f1 ff ff       	call   800777 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015d8:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015e0:	b8 01 00 00 00       	mov    $0x1,%eax
  8015e5:	e8 f6 fd ff ff       	call   8013e0 <fsipc>
  8015ea:	89 c3                	mov    %eax,%ebx
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	85 c0                	test   %eax,%eax
  8015f1:	79 14                	jns    801607 <open+0x6f>
		fd_close(fd, 0);
  8015f3:	83 ec 08             	sub    $0x8,%esp
  8015f6:	6a 00                	push   $0x0
  8015f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8015fb:	e8 50 f9 ff ff       	call   800f50 <fd_close>
		return r;
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	89 da                	mov    %ebx,%edx
  801605:	eb 17                	jmp    80161e <open+0x86>
	}

	return fd2num(fd);
  801607:	83 ec 0c             	sub    $0xc,%esp
  80160a:	ff 75 f4             	pushl  -0xc(%ebp)
  80160d:	e8 1f f8 ff ff       	call   800e31 <fd2num>
  801612:	89 c2                	mov    %eax,%edx
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	eb 05                	jmp    80161e <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801619:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80161e:	89 d0                	mov    %edx,%eax
  801620:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801623:	c9                   	leave  
  801624:	c3                   	ret    

00801625 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801625:	55                   	push   %ebp
  801626:	89 e5                	mov    %esp,%ebp
  801628:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80162b:	ba 00 00 00 00       	mov    $0x0,%edx
  801630:	b8 08 00 00 00       	mov    $0x8,%eax
  801635:	e8 a6 fd ff ff       	call   8013e0 <fsipc>
}
  80163a:	c9                   	leave  
  80163b:	c3                   	ret    

0080163c <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801642:	68 d3 27 80 00       	push   $0x8027d3
  801647:	ff 75 0c             	pushl  0xc(%ebp)
  80164a:	e8 28 f1 ff ff       	call   800777 <strcpy>
	return 0;
}
  80164f:	b8 00 00 00 00       	mov    $0x0,%eax
  801654:	c9                   	leave  
  801655:	c3                   	ret    

00801656 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801656:	55                   	push   %ebp
  801657:	89 e5                	mov    %esp,%ebp
  801659:	53                   	push   %ebx
  80165a:	83 ec 10             	sub    $0x10,%esp
  80165d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801660:	53                   	push   %ebx
  801661:	e8 58 0a 00 00       	call   8020be <pageref>
  801666:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801669:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  80166e:	83 f8 01             	cmp    $0x1,%eax
  801671:	75 10                	jne    801683 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801673:	83 ec 0c             	sub    $0xc,%esp
  801676:	ff 73 0c             	pushl  0xc(%ebx)
  801679:	e8 c0 02 00 00       	call   80193e <nsipc_close>
  80167e:	89 c2                	mov    %eax,%edx
  801680:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801683:	89 d0                	mov    %edx,%eax
  801685:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801688:	c9                   	leave  
  801689:	c3                   	ret    

0080168a <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  80168a:	55                   	push   %ebp
  80168b:	89 e5                	mov    %esp,%ebp
  80168d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801690:	6a 00                	push   $0x0
  801692:	ff 75 10             	pushl  0x10(%ebp)
  801695:	ff 75 0c             	pushl  0xc(%ebp)
  801698:	8b 45 08             	mov    0x8(%ebp),%eax
  80169b:	ff 70 0c             	pushl  0xc(%eax)
  80169e:	e8 78 03 00 00       	call   801a1b <nsipc_send>
}
  8016a3:	c9                   	leave  
  8016a4:	c3                   	ret    

008016a5 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8016ab:	6a 00                	push   $0x0
  8016ad:	ff 75 10             	pushl  0x10(%ebp)
  8016b0:	ff 75 0c             	pushl  0xc(%ebp)
  8016b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016b6:	ff 70 0c             	pushl  0xc(%eax)
  8016b9:	e8 f1 02 00 00       	call   8019af <nsipc_recv>
}
  8016be:	c9                   	leave  
  8016bf:	c3                   	ret    

008016c0 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  8016c0:	55                   	push   %ebp
  8016c1:	89 e5                	mov    %esp,%ebp
  8016c3:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  8016c6:	8d 55 f4             	lea    -0xc(%ebp),%edx
  8016c9:	52                   	push   %edx
  8016ca:	50                   	push   %eax
  8016cb:	e8 d7 f7 ff ff       	call   800ea7 <fd_lookup>
  8016d0:	83 c4 10             	add    $0x10,%esp
  8016d3:	85 c0                	test   %eax,%eax
  8016d5:	78 17                	js     8016ee <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  8016d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016da:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  8016e0:	39 08                	cmp    %ecx,(%eax)
  8016e2:	75 05                	jne    8016e9 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  8016e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8016e7:	eb 05                	jmp    8016ee <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  8016e9:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    

008016f0 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	56                   	push   %esi
  8016f4:	53                   	push   %ebx
  8016f5:	83 ec 1c             	sub    $0x1c,%esp
  8016f8:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  8016fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fd:	50                   	push   %eax
  8016fe:	e8 55 f7 ff ff       	call   800e58 <fd_alloc>
  801703:	89 c3                	mov    %eax,%ebx
  801705:	83 c4 10             	add    $0x10,%esp
  801708:	85 c0                	test   %eax,%eax
  80170a:	78 1b                	js     801727 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  80170c:	83 ec 04             	sub    $0x4,%esp
  80170f:	68 07 04 00 00       	push   $0x407
  801714:	ff 75 f4             	pushl  -0xc(%ebp)
  801717:	6a 00                	push   $0x0
  801719:	e8 5c f4 ff ff       	call   800b7a <sys_page_alloc>
  80171e:	89 c3                	mov    %eax,%ebx
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	85 c0                	test   %eax,%eax
  801725:	79 10                	jns    801737 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801727:	83 ec 0c             	sub    $0xc,%esp
  80172a:	56                   	push   %esi
  80172b:	e8 0e 02 00 00       	call   80193e <nsipc_close>
		return r;
  801730:	83 c4 10             	add    $0x10,%esp
  801733:	89 d8                	mov    %ebx,%eax
  801735:	eb 24                	jmp    80175b <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801737:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80173d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801740:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801742:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801745:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  80174c:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80174f:	83 ec 0c             	sub    $0xc,%esp
  801752:	50                   	push   %eax
  801753:	e8 d9 f6 ff ff       	call   800e31 <fd2num>
  801758:	83 c4 10             	add    $0x10,%esp
}
  80175b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80175e:	5b                   	pop    %ebx
  80175f:	5e                   	pop    %esi
  801760:	5d                   	pop    %ebp
  801761:	c3                   	ret    

00801762 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801762:	55                   	push   %ebp
  801763:	89 e5                	mov    %esp,%ebp
  801765:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801768:	8b 45 08             	mov    0x8(%ebp),%eax
  80176b:	e8 50 ff ff ff       	call   8016c0 <fd2sockid>
		return r;
  801770:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801772:	85 c0                	test   %eax,%eax
  801774:	78 1f                	js     801795 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801776:	83 ec 04             	sub    $0x4,%esp
  801779:	ff 75 10             	pushl  0x10(%ebp)
  80177c:	ff 75 0c             	pushl  0xc(%ebp)
  80177f:	50                   	push   %eax
  801780:	e8 12 01 00 00       	call   801897 <nsipc_accept>
  801785:	83 c4 10             	add    $0x10,%esp
		return r;
  801788:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  80178a:	85 c0                	test   %eax,%eax
  80178c:	78 07                	js     801795 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  80178e:	e8 5d ff ff ff       	call   8016f0 <alloc_sockfd>
  801793:	89 c1                	mov    %eax,%ecx
}
  801795:	89 c8                	mov    %ecx,%eax
  801797:	c9                   	leave  
  801798:	c3                   	ret    

00801799 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80179f:	8b 45 08             	mov    0x8(%ebp),%eax
  8017a2:	e8 19 ff ff ff       	call   8016c0 <fd2sockid>
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	78 12                	js     8017bd <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8017ab:	83 ec 04             	sub    $0x4,%esp
  8017ae:	ff 75 10             	pushl  0x10(%ebp)
  8017b1:	ff 75 0c             	pushl  0xc(%ebp)
  8017b4:	50                   	push   %eax
  8017b5:	e8 2d 01 00 00       	call   8018e7 <nsipc_bind>
  8017ba:	83 c4 10             	add    $0x10,%esp
}
  8017bd:	c9                   	leave  
  8017be:	c3                   	ret    

008017bf <shutdown>:

int
shutdown(int s, int how)
{
  8017bf:	55                   	push   %ebp
  8017c0:	89 e5                	mov    %esp,%ebp
  8017c2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c8:	e8 f3 fe ff ff       	call   8016c0 <fd2sockid>
  8017cd:	85 c0                	test   %eax,%eax
  8017cf:	78 0f                	js     8017e0 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  8017d1:	83 ec 08             	sub    $0x8,%esp
  8017d4:	ff 75 0c             	pushl  0xc(%ebp)
  8017d7:	50                   	push   %eax
  8017d8:	e8 3f 01 00 00       	call   80191c <nsipc_shutdown>
  8017dd:	83 c4 10             	add    $0x10,%esp
}
  8017e0:	c9                   	leave  
  8017e1:	c3                   	ret    

008017e2 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8017e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8017eb:	e8 d0 fe ff ff       	call   8016c0 <fd2sockid>
  8017f0:	85 c0                	test   %eax,%eax
  8017f2:	78 12                	js     801806 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  8017f4:	83 ec 04             	sub    $0x4,%esp
  8017f7:	ff 75 10             	pushl  0x10(%ebp)
  8017fa:	ff 75 0c             	pushl  0xc(%ebp)
  8017fd:	50                   	push   %eax
  8017fe:	e8 55 01 00 00       	call   801958 <nsipc_connect>
  801803:	83 c4 10             	add    $0x10,%esp
}
  801806:	c9                   	leave  
  801807:	c3                   	ret    

00801808 <listen>:

int
listen(int s, int backlog)
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  80180e:	8b 45 08             	mov    0x8(%ebp),%eax
  801811:	e8 aa fe ff ff       	call   8016c0 <fd2sockid>
  801816:	85 c0                	test   %eax,%eax
  801818:	78 0f                	js     801829 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  80181a:	83 ec 08             	sub    $0x8,%esp
  80181d:	ff 75 0c             	pushl  0xc(%ebp)
  801820:	50                   	push   %eax
  801821:	e8 67 01 00 00       	call   80198d <nsipc_listen>
  801826:	83 c4 10             	add    $0x10,%esp
}
  801829:	c9                   	leave  
  80182a:	c3                   	ret    

0080182b <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801831:	ff 75 10             	pushl  0x10(%ebp)
  801834:	ff 75 0c             	pushl  0xc(%ebp)
  801837:	ff 75 08             	pushl  0x8(%ebp)
  80183a:	e8 3a 02 00 00       	call   801a79 <nsipc_socket>
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	85 c0                	test   %eax,%eax
  801844:	78 05                	js     80184b <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801846:	e8 a5 fe ff ff       	call   8016f0 <alloc_sockfd>
}
  80184b:	c9                   	leave  
  80184c:	c3                   	ret    

0080184d <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	53                   	push   %ebx
  801851:	83 ec 04             	sub    $0x4,%esp
  801854:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801856:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  80185d:	75 12                	jne    801871 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  80185f:	83 ec 0c             	sub    $0xc,%esp
  801862:	6a 02                	push   $0x2
  801864:	e8 1c 08 00 00       	call   802085 <ipc_find_env>
  801869:	a3 04 40 80 00       	mov    %eax,0x804004
  80186e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801871:	6a 07                	push   $0x7
  801873:	68 00 60 80 00       	push   $0x806000
  801878:	53                   	push   %ebx
  801879:	ff 35 04 40 80 00    	pushl  0x804004
  80187f:	e8 ad 07 00 00       	call   802031 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801884:	83 c4 0c             	add    $0xc,%esp
  801887:	6a 00                	push   $0x0
  801889:	6a 00                	push   $0x0
  80188b:	6a 00                	push   $0x0
  80188d:	e8 36 07 00 00       	call   801fc8 <ipc_recv>
}
  801892:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801895:	c9                   	leave  
  801896:	c3                   	ret    

00801897 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	56                   	push   %esi
  80189b:	53                   	push   %ebx
  80189c:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  80189f:	8b 45 08             	mov    0x8(%ebp),%eax
  8018a2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  8018a7:	8b 06                	mov    (%esi),%eax
  8018a9:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  8018ae:	b8 01 00 00 00       	mov    $0x1,%eax
  8018b3:	e8 95 ff ff ff       	call   80184d <nsipc>
  8018b8:	89 c3                	mov    %eax,%ebx
  8018ba:	85 c0                	test   %eax,%eax
  8018bc:	78 20                	js     8018de <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  8018be:	83 ec 04             	sub    $0x4,%esp
  8018c1:	ff 35 10 60 80 00    	pushl  0x806010
  8018c7:	68 00 60 80 00       	push   $0x806000
  8018cc:	ff 75 0c             	pushl  0xc(%ebp)
  8018cf:	e8 35 f0 ff ff       	call   800909 <memmove>
		*addrlen = ret->ret_addrlen;
  8018d4:	a1 10 60 80 00       	mov    0x806010,%eax
  8018d9:	89 06                	mov    %eax,(%esi)
  8018db:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  8018de:	89 d8                	mov    %ebx,%eax
  8018e0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e3:	5b                   	pop    %ebx
  8018e4:	5e                   	pop    %esi
  8018e5:	5d                   	pop    %ebp
  8018e6:	c3                   	ret    

008018e7 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	53                   	push   %ebx
  8018eb:	83 ec 08             	sub    $0x8,%esp
  8018ee:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  8018f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f4:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  8018f9:	53                   	push   %ebx
  8018fa:	ff 75 0c             	pushl  0xc(%ebp)
  8018fd:	68 04 60 80 00       	push   $0x806004
  801902:	e8 02 f0 ff ff       	call   800909 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801907:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  80190d:	b8 02 00 00 00       	mov    $0x2,%eax
  801912:	e8 36 ff ff ff       	call   80184d <nsipc>
}
  801917:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80191a:	c9                   	leave  
  80191b:	c3                   	ret    

0080191c <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801922:	8b 45 08             	mov    0x8(%ebp),%eax
  801925:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  80192a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80192d:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801932:	b8 03 00 00 00       	mov    $0x3,%eax
  801937:	e8 11 ff ff ff       	call   80184d <nsipc>
}
  80193c:	c9                   	leave  
  80193d:	c3                   	ret    

0080193e <nsipc_close>:

int
nsipc_close(int s)
{
  80193e:	55                   	push   %ebp
  80193f:	89 e5                	mov    %esp,%ebp
  801941:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801944:	8b 45 08             	mov    0x8(%ebp),%eax
  801947:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  80194c:	b8 04 00 00 00       	mov    $0x4,%eax
  801951:	e8 f7 fe ff ff       	call   80184d <nsipc>
}
  801956:	c9                   	leave  
  801957:	c3                   	ret    

00801958 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	53                   	push   %ebx
  80195c:	83 ec 08             	sub    $0x8,%esp
  80195f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801962:	8b 45 08             	mov    0x8(%ebp),%eax
  801965:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  80196a:	53                   	push   %ebx
  80196b:	ff 75 0c             	pushl  0xc(%ebp)
  80196e:	68 04 60 80 00       	push   $0x806004
  801973:	e8 91 ef ff ff       	call   800909 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801978:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  80197e:	b8 05 00 00 00       	mov    $0x5,%eax
  801983:	e8 c5 fe ff ff       	call   80184d <nsipc>
}
  801988:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80198b:	c9                   	leave  
  80198c:	c3                   	ret    

0080198d <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  80198d:	55                   	push   %ebp
  80198e:	89 e5                	mov    %esp,%ebp
  801990:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801993:	8b 45 08             	mov    0x8(%ebp),%eax
  801996:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  80199b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199e:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  8019a3:	b8 06 00 00 00       	mov    $0x6,%eax
  8019a8:	e8 a0 fe ff ff       	call   80184d <nsipc>
}
  8019ad:	c9                   	leave  
  8019ae:	c3                   	ret    

008019af <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	56                   	push   %esi
  8019b3:	53                   	push   %ebx
  8019b4:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  8019b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ba:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  8019bf:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  8019c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8019c8:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  8019cd:	b8 07 00 00 00       	mov    $0x7,%eax
  8019d2:	e8 76 fe ff ff       	call   80184d <nsipc>
  8019d7:	89 c3                	mov    %eax,%ebx
  8019d9:	85 c0                	test   %eax,%eax
  8019db:	78 35                	js     801a12 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  8019dd:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  8019e2:	7f 04                	jg     8019e8 <nsipc_recv+0x39>
  8019e4:	39 c6                	cmp    %eax,%esi
  8019e6:	7d 16                	jge    8019fe <nsipc_recv+0x4f>
  8019e8:	68 df 27 80 00       	push   $0x8027df
  8019ed:	68 a7 27 80 00       	push   $0x8027a7
  8019f2:	6a 62                	push   $0x62
  8019f4:	68 f4 27 80 00       	push   $0x8027f4
  8019f9:	e8 84 05 00 00       	call   801f82 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  8019fe:	83 ec 04             	sub    $0x4,%esp
  801a01:	50                   	push   %eax
  801a02:	68 00 60 80 00       	push   $0x806000
  801a07:	ff 75 0c             	pushl  0xc(%ebp)
  801a0a:	e8 fa ee ff ff       	call   800909 <memmove>
  801a0f:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801a12:	89 d8                	mov    %ebx,%eax
  801a14:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a17:	5b                   	pop    %ebx
  801a18:	5e                   	pop    %esi
  801a19:	5d                   	pop    %ebp
  801a1a:	c3                   	ret    

00801a1b <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801a1b:	55                   	push   %ebp
  801a1c:	89 e5                	mov    %esp,%ebp
  801a1e:	53                   	push   %ebx
  801a1f:	83 ec 04             	sub    $0x4,%esp
  801a22:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801a25:	8b 45 08             	mov    0x8(%ebp),%eax
  801a28:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801a2d:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801a33:	7e 16                	jle    801a4b <nsipc_send+0x30>
  801a35:	68 00 28 80 00       	push   $0x802800
  801a3a:	68 a7 27 80 00       	push   $0x8027a7
  801a3f:	6a 6d                	push   $0x6d
  801a41:	68 f4 27 80 00       	push   $0x8027f4
  801a46:	e8 37 05 00 00       	call   801f82 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801a4b:	83 ec 04             	sub    $0x4,%esp
  801a4e:	53                   	push   %ebx
  801a4f:	ff 75 0c             	pushl  0xc(%ebp)
  801a52:	68 0c 60 80 00       	push   $0x80600c
  801a57:	e8 ad ee ff ff       	call   800909 <memmove>
	nsipcbuf.send.req_size = size;
  801a5c:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801a62:	8b 45 14             	mov    0x14(%ebp),%eax
  801a65:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801a6a:	b8 08 00 00 00       	mov    $0x8,%eax
  801a6f:	e8 d9 fd ff ff       	call   80184d <nsipc>
}
  801a74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a77:	c9                   	leave  
  801a78:	c3                   	ret    

00801a79 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801a79:	55                   	push   %ebp
  801a7a:	89 e5                	mov    %esp,%ebp
  801a7c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801a7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801a82:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801a87:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a8a:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801a8f:	8b 45 10             	mov    0x10(%ebp),%eax
  801a92:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801a97:	b8 09 00 00 00       	mov    $0x9,%eax
  801a9c:	e8 ac fd ff ff       	call   80184d <nsipc>
}
  801aa1:	c9                   	leave  
  801aa2:	c3                   	ret    

00801aa3 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801aa3:	55                   	push   %ebp
  801aa4:	89 e5                	mov    %esp,%ebp
  801aa6:	56                   	push   %esi
  801aa7:	53                   	push   %ebx
  801aa8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801aab:	83 ec 0c             	sub    $0xc,%esp
  801aae:	ff 75 08             	pushl  0x8(%ebp)
  801ab1:	e8 8b f3 ff ff       	call   800e41 <fd2data>
  801ab6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ab8:	83 c4 08             	add    $0x8,%esp
  801abb:	68 0c 28 80 00       	push   $0x80280c
  801ac0:	53                   	push   %ebx
  801ac1:	e8 b1 ec ff ff       	call   800777 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ac6:	8b 46 04             	mov    0x4(%esi),%eax
  801ac9:	2b 06                	sub    (%esi),%eax
  801acb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801ad1:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ad8:	00 00 00 
	stat->st_dev = &devpipe;
  801adb:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801ae2:	30 80 00 
	return 0;
}
  801ae5:	b8 00 00 00 00       	mov    $0x0,%eax
  801aea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aed:	5b                   	pop    %ebx
  801aee:	5e                   	pop    %esi
  801aef:	5d                   	pop    %ebp
  801af0:	c3                   	ret    

00801af1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801af1:	55                   	push   %ebp
  801af2:	89 e5                	mov    %esp,%ebp
  801af4:	53                   	push   %ebx
  801af5:	83 ec 0c             	sub    $0xc,%esp
  801af8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801afb:	53                   	push   %ebx
  801afc:	6a 00                	push   $0x0
  801afe:	e8 fc f0 ff ff       	call   800bff <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b03:	89 1c 24             	mov    %ebx,(%esp)
  801b06:	e8 36 f3 ff ff       	call   800e41 <fd2data>
  801b0b:	83 c4 08             	add    $0x8,%esp
  801b0e:	50                   	push   %eax
  801b0f:	6a 00                	push   $0x0
  801b11:	e8 e9 f0 ff ff       	call   800bff <sys_page_unmap>
}
  801b16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b19:	c9                   	leave  
  801b1a:	c3                   	ret    

00801b1b <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b1b:	55                   	push   %ebp
  801b1c:	89 e5                	mov    %esp,%ebp
  801b1e:	57                   	push   %edi
  801b1f:	56                   	push   %esi
  801b20:	53                   	push   %ebx
  801b21:	83 ec 1c             	sub    $0x1c,%esp
  801b24:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b27:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b29:	a1 08 40 80 00       	mov    0x804008,%eax
  801b2e:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b31:	83 ec 0c             	sub    $0xc,%esp
  801b34:	ff 75 e0             	pushl  -0x20(%ebp)
  801b37:	e8 82 05 00 00       	call   8020be <pageref>
  801b3c:	89 c3                	mov    %eax,%ebx
  801b3e:	89 3c 24             	mov    %edi,(%esp)
  801b41:	e8 78 05 00 00       	call   8020be <pageref>
  801b46:	83 c4 10             	add    $0x10,%esp
  801b49:	39 c3                	cmp    %eax,%ebx
  801b4b:	0f 94 c1             	sete   %cl
  801b4e:	0f b6 c9             	movzbl %cl,%ecx
  801b51:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b54:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801b5a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b5d:	39 ce                	cmp    %ecx,%esi
  801b5f:	74 1b                	je     801b7c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b61:	39 c3                	cmp    %eax,%ebx
  801b63:	75 c4                	jne    801b29 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b65:	8b 42 58             	mov    0x58(%edx),%eax
  801b68:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b6b:	50                   	push   %eax
  801b6c:	56                   	push   %esi
  801b6d:	68 13 28 80 00       	push   $0x802813
  801b72:	e8 fc e5 ff ff       	call   800173 <cprintf>
  801b77:	83 c4 10             	add    $0x10,%esp
  801b7a:	eb ad                	jmp    801b29 <_pipeisclosed+0xe>
	}
}
  801b7c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b7f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b82:	5b                   	pop    %ebx
  801b83:	5e                   	pop    %esi
  801b84:	5f                   	pop    %edi
  801b85:	5d                   	pop    %ebp
  801b86:	c3                   	ret    

00801b87 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b87:	55                   	push   %ebp
  801b88:	89 e5                	mov    %esp,%ebp
  801b8a:	57                   	push   %edi
  801b8b:	56                   	push   %esi
  801b8c:	53                   	push   %ebx
  801b8d:	83 ec 28             	sub    $0x28,%esp
  801b90:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b93:	56                   	push   %esi
  801b94:	e8 a8 f2 ff ff       	call   800e41 <fd2data>
  801b99:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b9b:	83 c4 10             	add    $0x10,%esp
  801b9e:	bf 00 00 00 00       	mov    $0x0,%edi
  801ba3:	eb 4b                	jmp    801bf0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ba5:	89 da                	mov    %ebx,%edx
  801ba7:	89 f0                	mov    %esi,%eax
  801ba9:	e8 6d ff ff ff       	call   801b1b <_pipeisclosed>
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	75 48                	jne    801bfa <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801bb2:	e8 a4 ef ff ff       	call   800b5b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801bb7:	8b 43 04             	mov    0x4(%ebx),%eax
  801bba:	8b 0b                	mov    (%ebx),%ecx
  801bbc:	8d 51 20             	lea    0x20(%ecx),%edx
  801bbf:	39 d0                	cmp    %edx,%eax
  801bc1:	73 e2                	jae    801ba5 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bc3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bc6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bca:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bcd:	89 c2                	mov    %eax,%edx
  801bcf:	c1 fa 1f             	sar    $0x1f,%edx
  801bd2:	89 d1                	mov    %edx,%ecx
  801bd4:	c1 e9 1b             	shr    $0x1b,%ecx
  801bd7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bda:	83 e2 1f             	and    $0x1f,%edx
  801bdd:	29 ca                	sub    %ecx,%edx
  801bdf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801be3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801be7:	83 c0 01             	add    $0x1,%eax
  801bea:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bed:	83 c7 01             	add    $0x1,%edi
  801bf0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bf3:	75 c2                	jne    801bb7 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bf5:	8b 45 10             	mov    0x10(%ebp),%eax
  801bf8:	eb 05                	jmp    801bff <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801bfa:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801bff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c02:	5b                   	pop    %ebx
  801c03:	5e                   	pop    %esi
  801c04:	5f                   	pop    %edi
  801c05:	5d                   	pop    %ebp
  801c06:	c3                   	ret    

00801c07 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c07:	55                   	push   %ebp
  801c08:	89 e5                	mov    %esp,%ebp
  801c0a:	57                   	push   %edi
  801c0b:	56                   	push   %esi
  801c0c:	53                   	push   %ebx
  801c0d:	83 ec 18             	sub    $0x18,%esp
  801c10:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801c13:	57                   	push   %edi
  801c14:	e8 28 f2 ff ff       	call   800e41 <fd2data>
  801c19:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c1b:	83 c4 10             	add    $0x10,%esp
  801c1e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c23:	eb 3d                	jmp    801c62 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c25:	85 db                	test   %ebx,%ebx
  801c27:	74 04                	je     801c2d <devpipe_read+0x26>
				return i;
  801c29:	89 d8                	mov    %ebx,%eax
  801c2b:	eb 44                	jmp    801c71 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c2d:	89 f2                	mov    %esi,%edx
  801c2f:	89 f8                	mov    %edi,%eax
  801c31:	e8 e5 fe ff ff       	call   801b1b <_pipeisclosed>
  801c36:	85 c0                	test   %eax,%eax
  801c38:	75 32                	jne    801c6c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c3a:	e8 1c ef ff ff       	call   800b5b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c3f:	8b 06                	mov    (%esi),%eax
  801c41:	3b 46 04             	cmp    0x4(%esi),%eax
  801c44:	74 df                	je     801c25 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c46:	99                   	cltd   
  801c47:	c1 ea 1b             	shr    $0x1b,%edx
  801c4a:	01 d0                	add    %edx,%eax
  801c4c:	83 e0 1f             	and    $0x1f,%eax
  801c4f:	29 d0                	sub    %edx,%eax
  801c51:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c56:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c59:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c5c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c5f:	83 c3 01             	add    $0x1,%ebx
  801c62:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c65:	75 d8                	jne    801c3f <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c67:	8b 45 10             	mov    0x10(%ebp),%eax
  801c6a:	eb 05                	jmp    801c71 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c6c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c71:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c74:	5b                   	pop    %ebx
  801c75:	5e                   	pop    %esi
  801c76:	5f                   	pop    %edi
  801c77:	5d                   	pop    %ebp
  801c78:	c3                   	ret    

00801c79 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c79:	55                   	push   %ebp
  801c7a:	89 e5                	mov    %esp,%ebp
  801c7c:	56                   	push   %esi
  801c7d:	53                   	push   %ebx
  801c7e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c81:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c84:	50                   	push   %eax
  801c85:	e8 ce f1 ff ff       	call   800e58 <fd_alloc>
  801c8a:	83 c4 10             	add    $0x10,%esp
  801c8d:	89 c2                	mov    %eax,%edx
  801c8f:	85 c0                	test   %eax,%eax
  801c91:	0f 88 2c 01 00 00    	js     801dc3 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c97:	83 ec 04             	sub    $0x4,%esp
  801c9a:	68 07 04 00 00       	push   $0x407
  801c9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca2:	6a 00                	push   $0x0
  801ca4:	e8 d1 ee ff ff       	call   800b7a <sys_page_alloc>
  801ca9:	83 c4 10             	add    $0x10,%esp
  801cac:	89 c2                	mov    %eax,%edx
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	0f 88 0d 01 00 00    	js     801dc3 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801cb6:	83 ec 0c             	sub    $0xc,%esp
  801cb9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801cbc:	50                   	push   %eax
  801cbd:	e8 96 f1 ff ff       	call   800e58 <fd_alloc>
  801cc2:	89 c3                	mov    %eax,%ebx
  801cc4:	83 c4 10             	add    $0x10,%esp
  801cc7:	85 c0                	test   %eax,%eax
  801cc9:	0f 88 e2 00 00 00    	js     801db1 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ccf:	83 ec 04             	sub    $0x4,%esp
  801cd2:	68 07 04 00 00       	push   $0x407
  801cd7:	ff 75 f0             	pushl  -0x10(%ebp)
  801cda:	6a 00                	push   $0x0
  801cdc:	e8 99 ee ff ff       	call   800b7a <sys_page_alloc>
  801ce1:	89 c3                	mov    %eax,%ebx
  801ce3:	83 c4 10             	add    $0x10,%esp
  801ce6:	85 c0                	test   %eax,%eax
  801ce8:	0f 88 c3 00 00 00    	js     801db1 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cee:	83 ec 0c             	sub    $0xc,%esp
  801cf1:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf4:	e8 48 f1 ff ff       	call   800e41 <fd2data>
  801cf9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cfb:	83 c4 0c             	add    $0xc,%esp
  801cfe:	68 07 04 00 00       	push   $0x407
  801d03:	50                   	push   %eax
  801d04:	6a 00                	push   $0x0
  801d06:	e8 6f ee ff ff       	call   800b7a <sys_page_alloc>
  801d0b:	89 c3                	mov    %eax,%ebx
  801d0d:	83 c4 10             	add    $0x10,%esp
  801d10:	85 c0                	test   %eax,%eax
  801d12:	0f 88 89 00 00 00    	js     801da1 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d18:	83 ec 0c             	sub    $0xc,%esp
  801d1b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d1e:	e8 1e f1 ff ff       	call   800e41 <fd2data>
  801d23:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d2a:	50                   	push   %eax
  801d2b:	6a 00                	push   $0x0
  801d2d:	56                   	push   %esi
  801d2e:	6a 00                	push   $0x0
  801d30:	e8 88 ee ff ff       	call   800bbd <sys_page_map>
  801d35:	89 c3                	mov    %eax,%ebx
  801d37:	83 c4 20             	add    $0x20,%esp
  801d3a:	85 c0                	test   %eax,%eax
  801d3c:	78 55                	js     801d93 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d3e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d44:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d47:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d49:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d4c:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d53:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d59:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d5c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d5e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d61:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d68:	83 ec 0c             	sub    $0xc,%esp
  801d6b:	ff 75 f4             	pushl  -0xc(%ebp)
  801d6e:	e8 be f0 ff ff       	call   800e31 <fd2num>
  801d73:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d76:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d78:	83 c4 04             	add    $0x4,%esp
  801d7b:	ff 75 f0             	pushl  -0x10(%ebp)
  801d7e:	e8 ae f0 ff ff       	call   800e31 <fd2num>
  801d83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d86:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d89:	83 c4 10             	add    $0x10,%esp
  801d8c:	ba 00 00 00 00       	mov    $0x0,%edx
  801d91:	eb 30                	jmp    801dc3 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d93:	83 ec 08             	sub    $0x8,%esp
  801d96:	56                   	push   %esi
  801d97:	6a 00                	push   $0x0
  801d99:	e8 61 ee ff ff       	call   800bff <sys_page_unmap>
  801d9e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801da1:	83 ec 08             	sub    $0x8,%esp
  801da4:	ff 75 f0             	pushl  -0x10(%ebp)
  801da7:	6a 00                	push   $0x0
  801da9:	e8 51 ee ff ff       	call   800bff <sys_page_unmap>
  801dae:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801db1:	83 ec 08             	sub    $0x8,%esp
  801db4:	ff 75 f4             	pushl  -0xc(%ebp)
  801db7:	6a 00                	push   $0x0
  801db9:	e8 41 ee ff ff       	call   800bff <sys_page_unmap>
  801dbe:	83 c4 10             	add    $0x10,%esp
  801dc1:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dc3:	89 d0                	mov    %edx,%eax
  801dc5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dc8:	5b                   	pop    %ebx
  801dc9:	5e                   	pop    %esi
  801dca:	5d                   	pop    %ebp
  801dcb:	c3                   	ret    

00801dcc <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801dcc:	55                   	push   %ebp
  801dcd:	89 e5                	mov    %esp,%ebp
  801dcf:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dd2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd5:	50                   	push   %eax
  801dd6:	ff 75 08             	pushl  0x8(%ebp)
  801dd9:	e8 c9 f0 ff ff       	call   800ea7 <fd_lookup>
  801dde:	83 c4 10             	add    $0x10,%esp
  801de1:	85 c0                	test   %eax,%eax
  801de3:	78 18                	js     801dfd <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801de5:	83 ec 0c             	sub    $0xc,%esp
  801de8:	ff 75 f4             	pushl  -0xc(%ebp)
  801deb:	e8 51 f0 ff ff       	call   800e41 <fd2data>
	return _pipeisclosed(fd, p);
  801df0:	89 c2                	mov    %eax,%edx
  801df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801df5:	e8 21 fd ff ff       	call   801b1b <_pipeisclosed>
  801dfa:	83 c4 10             	add    $0x10,%esp
}
  801dfd:	c9                   	leave  
  801dfe:	c3                   	ret    

00801dff <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801dff:	55                   	push   %ebp
  801e00:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e02:	b8 00 00 00 00       	mov    $0x0,%eax
  801e07:	5d                   	pop    %ebp
  801e08:	c3                   	ret    

00801e09 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e09:	55                   	push   %ebp
  801e0a:	89 e5                	mov    %esp,%ebp
  801e0c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e0f:	68 2b 28 80 00       	push   $0x80282b
  801e14:	ff 75 0c             	pushl  0xc(%ebp)
  801e17:	e8 5b e9 ff ff       	call   800777 <strcpy>
	return 0;
}
  801e1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801e21:	c9                   	leave  
  801e22:	c3                   	ret    

00801e23 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e23:	55                   	push   %ebp
  801e24:	89 e5                	mov    %esp,%ebp
  801e26:	57                   	push   %edi
  801e27:	56                   	push   %esi
  801e28:	53                   	push   %ebx
  801e29:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e2f:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e34:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e3a:	eb 2d                	jmp    801e69 <devcons_write+0x46>
		m = n - tot;
  801e3c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e3f:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e41:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e44:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e49:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e4c:	83 ec 04             	sub    $0x4,%esp
  801e4f:	53                   	push   %ebx
  801e50:	03 45 0c             	add    0xc(%ebp),%eax
  801e53:	50                   	push   %eax
  801e54:	57                   	push   %edi
  801e55:	e8 af ea ff ff       	call   800909 <memmove>
		sys_cputs(buf, m);
  801e5a:	83 c4 08             	add    $0x8,%esp
  801e5d:	53                   	push   %ebx
  801e5e:	57                   	push   %edi
  801e5f:	e8 5a ec ff ff       	call   800abe <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e64:	01 de                	add    %ebx,%esi
  801e66:	83 c4 10             	add    $0x10,%esp
  801e69:	89 f0                	mov    %esi,%eax
  801e6b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e6e:	72 cc                	jb     801e3c <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801e70:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e73:	5b                   	pop    %ebx
  801e74:	5e                   	pop    %esi
  801e75:	5f                   	pop    %edi
  801e76:	5d                   	pop    %ebp
  801e77:	c3                   	ret    

00801e78 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e78:	55                   	push   %ebp
  801e79:	89 e5                	mov    %esp,%ebp
  801e7b:	83 ec 08             	sub    $0x8,%esp
  801e7e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801e83:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801e87:	74 2a                	je     801eb3 <devcons_read+0x3b>
  801e89:	eb 05                	jmp    801e90 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801e8b:	e8 cb ec ff ff       	call   800b5b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801e90:	e8 47 ec ff ff       	call   800adc <sys_cgetc>
  801e95:	85 c0                	test   %eax,%eax
  801e97:	74 f2                	je     801e8b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801e99:	85 c0                	test   %eax,%eax
  801e9b:	78 16                	js     801eb3 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801e9d:	83 f8 04             	cmp    $0x4,%eax
  801ea0:	74 0c                	je     801eae <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801ea2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ea5:	88 02                	mov    %al,(%edx)
	return 1;
  801ea7:	b8 01 00 00 00       	mov    $0x1,%eax
  801eac:	eb 05                	jmp    801eb3 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801eae:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801eb3:	c9                   	leave  
  801eb4:	c3                   	ret    

00801eb5 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801eb5:	55                   	push   %ebp
  801eb6:	89 e5                	mov    %esp,%ebp
  801eb8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ebb:	8b 45 08             	mov    0x8(%ebp),%eax
  801ebe:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801ec1:	6a 01                	push   $0x1
  801ec3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ec6:	50                   	push   %eax
  801ec7:	e8 f2 eb ff ff       	call   800abe <sys_cputs>
}
  801ecc:	83 c4 10             	add    $0x10,%esp
  801ecf:	c9                   	leave  
  801ed0:	c3                   	ret    

00801ed1 <getchar>:

int
getchar(void)
{
  801ed1:	55                   	push   %ebp
  801ed2:	89 e5                	mov    %esp,%ebp
  801ed4:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801ed7:	6a 01                	push   $0x1
  801ed9:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801edc:	50                   	push   %eax
  801edd:	6a 00                	push   $0x0
  801edf:	e8 29 f2 ff ff       	call   80110d <read>
	if (r < 0)
  801ee4:	83 c4 10             	add    $0x10,%esp
  801ee7:	85 c0                	test   %eax,%eax
  801ee9:	78 0f                	js     801efa <getchar+0x29>
		return r;
	if (r < 1)
  801eeb:	85 c0                	test   %eax,%eax
  801eed:	7e 06                	jle    801ef5 <getchar+0x24>
		return -E_EOF;
	return c;
  801eef:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801ef3:	eb 05                	jmp    801efa <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801ef5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801efa:	c9                   	leave  
  801efb:	c3                   	ret    

00801efc <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801efc:	55                   	push   %ebp
  801efd:	89 e5                	mov    %esp,%ebp
  801eff:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f05:	50                   	push   %eax
  801f06:	ff 75 08             	pushl  0x8(%ebp)
  801f09:	e8 99 ef ff ff       	call   800ea7 <fd_lookup>
  801f0e:	83 c4 10             	add    $0x10,%esp
  801f11:	85 c0                	test   %eax,%eax
  801f13:	78 11                	js     801f26 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f15:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f18:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f1e:	39 10                	cmp    %edx,(%eax)
  801f20:	0f 94 c0             	sete   %al
  801f23:	0f b6 c0             	movzbl %al,%eax
}
  801f26:	c9                   	leave  
  801f27:	c3                   	ret    

00801f28 <opencons>:

int
opencons(void)
{
  801f28:	55                   	push   %ebp
  801f29:	89 e5                	mov    %esp,%ebp
  801f2b:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f2e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f31:	50                   	push   %eax
  801f32:	e8 21 ef ff ff       	call   800e58 <fd_alloc>
  801f37:	83 c4 10             	add    $0x10,%esp
		return r;
  801f3a:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f3c:	85 c0                	test   %eax,%eax
  801f3e:	78 3e                	js     801f7e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f40:	83 ec 04             	sub    $0x4,%esp
  801f43:	68 07 04 00 00       	push   $0x407
  801f48:	ff 75 f4             	pushl  -0xc(%ebp)
  801f4b:	6a 00                	push   $0x0
  801f4d:	e8 28 ec ff ff       	call   800b7a <sys_page_alloc>
  801f52:	83 c4 10             	add    $0x10,%esp
		return r;
  801f55:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f57:	85 c0                	test   %eax,%eax
  801f59:	78 23                	js     801f7e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f5b:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801f61:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f64:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f69:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801f70:	83 ec 0c             	sub    $0xc,%esp
  801f73:	50                   	push   %eax
  801f74:	e8 b8 ee ff ff       	call   800e31 <fd2num>
  801f79:	89 c2                	mov    %eax,%edx
  801f7b:	83 c4 10             	add    $0x10,%esp
}
  801f7e:	89 d0                	mov    %edx,%eax
  801f80:	c9                   	leave  
  801f81:	c3                   	ret    

00801f82 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801f82:	55                   	push   %ebp
  801f83:	89 e5                	mov    %esp,%ebp
  801f85:	56                   	push   %esi
  801f86:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801f87:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801f8a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801f90:	e8 a7 eb ff ff       	call   800b3c <sys_getenvid>
  801f95:	83 ec 0c             	sub    $0xc,%esp
  801f98:	ff 75 0c             	pushl  0xc(%ebp)
  801f9b:	ff 75 08             	pushl  0x8(%ebp)
  801f9e:	56                   	push   %esi
  801f9f:	50                   	push   %eax
  801fa0:	68 38 28 80 00       	push   $0x802838
  801fa5:	e8 c9 e1 ff ff       	call   800173 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801faa:	83 c4 18             	add    $0x18,%esp
  801fad:	53                   	push   %ebx
  801fae:	ff 75 10             	pushl  0x10(%ebp)
  801fb1:	e8 6c e1 ff ff       	call   800122 <vcprintf>
	cprintf("\n");
  801fb6:	c7 04 24 24 28 80 00 	movl   $0x802824,(%esp)
  801fbd:	e8 b1 e1 ff ff       	call   800173 <cprintf>
  801fc2:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801fc5:	cc                   	int3   
  801fc6:	eb fd                	jmp    801fc5 <_panic+0x43>

00801fc8 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801fc8:	55                   	push   %ebp
  801fc9:	89 e5                	mov    %esp,%ebp
  801fcb:	56                   	push   %esi
  801fcc:	53                   	push   %ebx
  801fcd:	8b 75 08             	mov    0x8(%ebp),%esi
  801fd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fd3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801fd6:	85 c0                	test   %eax,%eax
  801fd8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801fdd:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801fe0:	83 ec 0c             	sub    $0xc,%esp
  801fe3:	50                   	push   %eax
  801fe4:	e8 41 ed ff ff       	call   800d2a <sys_ipc_recv>
  801fe9:	83 c4 10             	add    $0x10,%esp
  801fec:	85 c0                	test   %eax,%eax
  801fee:	79 16                	jns    802006 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801ff0:	85 f6                	test   %esi,%esi
  801ff2:	74 06                	je     801ffa <ipc_recv+0x32>
            *from_env_store = 0;
  801ff4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801ffa:	85 db                	test   %ebx,%ebx
  801ffc:	74 2c                	je     80202a <ipc_recv+0x62>
            *perm_store = 0;
  801ffe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802004:	eb 24                	jmp    80202a <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  802006:	85 f6                	test   %esi,%esi
  802008:	74 0a                	je     802014 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  80200a:	a1 08 40 80 00       	mov    0x804008,%eax
  80200f:	8b 40 74             	mov    0x74(%eax),%eax
  802012:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  802014:	85 db                	test   %ebx,%ebx
  802016:	74 0a                	je     802022 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  802018:	a1 08 40 80 00       	mov    0x804008,%eax
  80201d:	8b 40 78             	mov    0x78(%eax),%eax
  802020:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  802022:	a1 08 40 80 00       	mov    0x804008,%eax
  802027:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  80202a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80202d:	5b                   	pop    %ebx
  80202e:	5e                   	pop    %esi
  80202f:	5d                   	pop    %ebp
  802030:	c3                   	ret    

00802031 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802031:	55                   	push   %ebp
  802032:	89 e5                	mov    %esp,%ebp
  802034:	57                   	push   %edi
  802035:	56                   	push   %esi
  802036:	53                   	push   %ebx
  802037:	83 ec 0c             	sub    $0xc,%esp
  80203a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80203d:	8b 75 0c             	mov    0xc(%ebp),%esi
  802040:	8b 45 10             	mov    0x10(%ebp),%eax
  802043:	85 c0                	test   %eax,%eax
  802045:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80204a:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80204d:	eb 1c                	jmp    80206b <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  80204f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802052:	74 12                	je     802066 <ipc_send+0x35>
  802054:	50                   	push   %eax
  802055:	68 5c 28 80 00       	push   $0x80285c
  80205a:	6a 3b                	push   $0x3b
  80205c:	68 72 28 80 00       	push   $0x802872
  802061:	e8 1c ff ff ff       	call   801f82 <_panic>
		sys_yield();
  802066:	e8 f0 ea ff ff       	call   800b5b <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80206b:	ff 75 14             	pushl  0x14(%ebp)
  80206e:	53                   	push   %ebx
  80206f:	56                   	push   %esi
  802070:	57                   	push   %edi
  802071:	e8 91 ec ff ff       	call   800d07 <sys_ipc_try_send>
  802076:	83 c4 10             	add    $0x10,%esp
  802079:	85 c0                	test   %eax,%eax
  80207b:	78 d2                	js     80204f <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  80207d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802080:	5b                   	pop    %ebx
  802081:	5e                   	pop    %esi
  802082:	5f                   	pop    %edi
  802083:	5d                   	pop    %ebp
  802084:	c3                   	ret    

00802085 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802085:	55                   	push   %ebp
  802086:	89 e5                	mov    %esp,%ebp
  802088:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80208b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802090:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802093:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802099:	8b 52 50             	mov    0x50(%edx),%edx
  80209c:	39 ca                	cmp    %ecx,%edx
  80209e:	75 0d                	jne    8020ad <ipc_find_env+0x28>
			return envs[i].env_id;
  8020a0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8020a3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8020a8:	8b 40 48             	mov    0x48(%eax),%eax
  8020ab:	eb 0f                	jmp    8020bc <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8020ad:	83 c0 01             	add    $0x1,%eax
  8020b0:	3d 00 04 00 00       	cmp    $0x400,%eax
  8020b5:	75 d9                	jne    802090 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8020b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8020bc:	5d                   	pop    %ebp
  8020bd:	c3                   	ret    

008020be <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8020be:	55                   	push   %ebp
  8020bf:	89 e5                	mov    %esp,%ebp
  8020c1:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020c4:	89 d0                	mov    %edx,%eax
  8020c6:	c1 e8 16             	shr    $0x16,%eax
  8020c9:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8020d0:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8020d5:	f6 c1 01             	test   $0x1,%cl
  8020d8:	74 1d                	je     8020f7 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8020da:	c1 ea 0c             	shr    $0xc,%edx
  8020dd:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8020e4:	f6 c2 01             	test   $0x1,%dl
  8020e7:	74 0e                	je     8020f7 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8020e9:	c1 ea 0c             	shr    $0xc,%edx
  8020ec:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8020f3:	ef 
  8020f4:	0f b7 c0             	movzwl %ax,%eax
}
  8020f7:	5d                   	pop    %ebp
  8020f8:	c3                   	ret    
  8020f9:	66 90                	xchg   %ax,%ax
  8020fb:	66 90                	xchg   %ax,%ax
  8020fd:	66 90                	xchg   %ax,%ax
  8020ff:	90                   	nop

00802100 <__udivdi3>:
  802100:	55                   	push   %ebp
  802101:	57                   	push   %edi
  802102:	56                   	push   %esi
  802103:	53                   	push   %ebx
  802104:	83 ec 1c             	sub    $0x1c,%esp
  802107:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80210b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80210f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802113:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802117:	85 f6                	test   %esi,%esi
  802119:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80211d:	89 ca                	mov    %ecx,%edx
  80211f:	89 f8                	mov    %edi,%eax
  802121:	75 3d                	jne    802160 <__udivdi3+0x60>
  802123:	39 cf                	cmp    %ecx,%edi
  802125:	0f 87 c5 00 00 00    	ja     8021f0 <__udivdi3+0xf0>
  80212b:	85 ff                	test   %edi,%edi
  80212d:	89 fd                	mov    %edi,%ebp
  80212f:	75 0b                	jne    80213c <__udivdi3+0x3c>
  802131:	b8 01 00 00 00       	mov    $0x1,%eax
  802136:	31 d2                	xor    %edx,%edx
  802138:	f7 f7                	div    %edi
  80213a:	89 c5                	mov    %eax,%ebp
  80213c:	89 c8                	mov    %ecx,%eax
  80213e:	31 d2                	xor    %edx,%edx
  802140:	f7 f5                	div    %ebp
  802142:	89 c1                	mov    %eax,%ecx
  802144:	89 d8                	mov    %ebx,%eax
  802146:	89 cf                	mov    %ecx,%edi
  802148:	f7 f5                	div    %ebp
  80214a:	89 c3                	mov    %eax,%ebx
  80214c:	89 d8                	mov    %ebx,%eax
  80214e:	89 fa                	mov    %edi,%edx
  802150:	83 c4 1c             	add    $0x1c,%esp
  802153:	5b                   	pop    %ebx
  802154:	5e                   	pop    %esi
  802155:	5f                   	pop    %edi
  802156:	5d                   	pop    %ebp
  802157:	c3                   	ret    
  802158:	90                   	nop
  802159:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802160:	39 ce                	cmp    %ecx,%esi
  802162:	77 74                	ja     8021d8 <__udivdi3+0xd8>
  802164:	0f bd fe             	bsr    %esi,%edi
  802167:	83 f7 1f             	xor    $0x1f,%edi
  80216a:	0f 84 98 00 00 00    	je     802208 <__udivdi3+0x108>
  802170:	bb 20 00 00 00       	mov    $0x20,%ebx
  802175:	89 f9                	mov    %edi,%ecx
  802177:	89 c5                	mov    %eax,%ebp
  802179:	29 fb                	sub    %edi,%ebx
  80217b:	d3 e6                	shl    %cl,%esi
  80217d:	89 d9                	mov    %ebx,%ecx
  80217f:	d3 ed                	shr    %cl,%ebp
  802181:	89 f9                	mov    %edi,%ecx
  802183:	d3 e0                	shl    %cl,%eax
  802185:	09 ee                	or     %ebp,%esi
  802187:	89 d9                	mov    %ebx,%ecx
  802189:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80218d:	89 d5                	mov    %edx,%ebp
  80218f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802193:	d3 ed                	shr    %cl,%ebp
  802195:	89 f9                	mov    %edi,%ecx
  802197:	d3 e2                	shl    %cl,%edx
  802199:	89 d9                	mov    %ebx,%ecx
  80219b:	d3 e8                	shr    %cl,%eax
  80219d:	09 c2                	or     %eax,%edx
  80219f:	89 d0                	mov    %edx,%eax
  8021a1:	89 ea                	mov    %ebp,%edx
  8021a3:	f7 f6                	div    %esi
  8021a5:	89 d5                	mov    %edx,%ebp
  8021a7:	89 c3                	mov    %eax,%ebx
  8021a9:	f7 64 24 0c          	mull   0xc(%esp)
  8021ad:	39 d5                	cmp    %edx,%ebp
  8021af:	72 10                	jb     8021c1 <__udivdi3+0xc1>
  8021b1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8021b5:	89 f9                	mov    %edi,%ecx
  8021b7:	d3 e6                	shl    %cl,%esi
  8021b9:	39 c6                	cmp    %eax,%esi
  8021bb:	73 07                	jae    8021c4 <__udivdi3+0xc4>
  8021bd:	39 d5                	cmp    %edx,%ebp
  8021bf:	75 03                	jne    8021c4 <__udivdi3+0xc4>
  8021c1:	83 eb 01             	sub    $0x1,%ebx
  8021c4:	31 ff                	xor    %edi,%edi
  8021c6:	89 d8                	mov    %ebx,%eax
  8021c8:	89 fa                	mov    %edi,%edx
  8021ca:	83 c4 1c             	add    $0x1c,%esp
  8021cd:	5b                   	pop    %ebx
  8021ce:	5e                   	pop    %esi
  8021cf:	5f                   	pop    %edi
  8021d0:	5d                   	pop    %ebp
  8021d1:	c3                   	ret    
  8021d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021d8:	31 ff                	xor    %edi,%edi
  8021da:	31 db                	xor    %ebx,%ebx
  8021dc:	89 d8                	mov    %ebx,%eax
  8021de:	89 fa                	mov    %edi,%edx
  8021e0:	83 c4 1c             	add    $0x1c,%esp
  8021e3:	5b                   	pop    %ebx
  8021e4:	5e                   	pop    %esi
  8021e5:	5f                   	pop    %edi
  8021e6:	5d                   	pop    %ebp
  8021e7:	c3                   	ret    
  8021e8:	90                   	nop
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	89 d8                	mov    %ebx,%eax
  8021f2:	f7 f7                	div    %edi
  8021f4:	31 ff                	xor    %edi,%edi
  8021f6:	89 c3                	mov    %eax,%ebx
  8021f8:	89 d8                	mov    %ebx,%eax
  8021fa:	89 fa                	mov    %edi,%edx
  8021fc:	83 c4 1c             	add    $0x1c,%esp
  8021ff:	5b                   	pop    %ebx
  802200:	5e                   	pop    %esi
  802201:	5f                   	pop    %edi
  802202:	5d                   	pop    %ebp
  802203:	c3                   	ret    
  802204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802208:	39 ce                	cmp    %ecx,%esi
  80220a:	72 0c                	jb     802218 <__udivdi3+0x118>
  80220c:	31 db                	xor    %ebx,%ebx
  80220e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802212:	0f 87 34 ff ff ff    	ja     80214c <__udivdi3+0x4c>
  802218:	bb 01 00 00 00       	mov    $0x1,%ebx
  80221d:	e9 2a ff ff ff       	jmp    80214c <__udivdi3+0x4c>
  802222:	66 90                	xchg   %ax,%ax
  802224:	66 90                	xchg   %ax,%ax
  802226:	66 90                	xchg   %ax,%ax
  802228:	66 90                	xchg   %ax,%ax
  80222a:	66 90                	xchg   %ax,%ax
  80222c:	66 90                	xchg   %ax,%ax
  80222e:	66 90                	xchg   %ax,%ax

00802230 <__umoddi3>:
  802230:	55                   	push   %ebp
  802231:	57                   	push   %edi
  802232:	56                   	push   %esi
  802233:	53                   	push   %ebx
  802234:	83 ec 1c             	sub    $0x1c,%esp
  802237:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80223b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80223f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802243:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802247:	85 d2                	test   %edx,%edx
  802249:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80224d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802251:	89 f3                	mov    %esi,%ebx
  802253:	89 3c 24             	mov    %edi,(%esp)
  802256:	89 74 24 04          	mov    %esi,0x4(%esp)
  80225a:	75 1c                	jne    802278 <__umoddi3+0x48>
  80225c:	39 f7                	cmp    %esi,%edi
  80225e:	76 50                	jbe    8022b0 <__umoddi3+0x80>
  802260:	89 c8                	mov    %ecx,%eax
  802262:	89 f2                	mov    %esi,%edx
  802264:	f7 f7                	div    %edi
  802266:	89 d0                	mov    %edx,%eax
  802268:	31 d2                	xor    %edx,%edx
  80226a:	83 c4 1c             	add    $0x1c,%esp
  80226d:	5b                   	pop    %ebx
  80226e:	5e                   	pop    %esi
  80226f:	5f                   	pop    %edi
  802270:	5d                   	pop    %ebp
  802271:	c3                   	ret    
  802272:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802278:	39 f2                	cmp    %esi,%edx
  80227a:	89 d0                	mov    %edx,%eax
  80227c:	77 52                	ja     8022d0 <__umoddi3+0xa0>
  80227e:	0f bd ea             	bsr    %edx,%ebp
  802281:	83 f5 1f             	xor    $0x1f,%ebp
  802284:	75 5a                	jne    8022e0 <__umoddi3+0xb0>
  802286:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80228a:	0f 82 e0 00 00 00    	jb     802370 <__umoddi3+0x140>
  802290:	39 0c 24             	cmp    %ecx,(%esp)
  802293:	0f 86 d7 00 00 00    	jbe    802370 <__umoddi3+0x140>
  802299:	8b 44 24 08          	mov    0x8(%esp),%eax
  80229d:	8b 54 24 04          	mov    0x4(%esp),%edx
  8022a1:	83 c4 1c             	add    $0x1c,%esp
  8022a4:	5b                   	pop    %ebx
  8022a5:	5e                   	pop    %esi
  8022a6:	5f                   	pop    %edi
  8022a7:	5d                   	pop    %ebp
  8022a8:	c3                   	ret    
  8022a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022b0:	85 ff                	test   %edi,%edi
  8022b2:	89 fd                	mov    %edi,%ebp
  8022b4:	75 0b                	jne    8022c1 <__umoddi3+0x91>
  8022b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022bb:	31 d2                	xor    %edx,%edx
  8022bd:	f7 f7                	div    %edi
  8022bf:	89 c5                	mov    %eax,%ebp
  8022c1:	89 f0                	mov    %esi,%eax
  8022c3:	31 d2                	xor    %edx,%edx
  8022c5:	f7 f5                	div    %ebp
  8022c7:	89 c8                	mov    %ecx,%eax
  8022c9:	f7 f5                	div    %ebp
  8022cb:	89 d0                	mov    %edx,%eax
  8022cd:	eb 99                	jmp    802268 <__umoddi3+0x38>
  8022cf:	90                   	nop
  8022d0:	89 c8                	mov    %ecx,%eax
  8022d2:	89 f2                	mov    %esi,%edx
  8022d4:	83 c4 1c             	add    $0x1c,%esp
  8022d7:	5b                   	pop    %ebx
  8022d8:	5e                   	pop    %esi
  8022d9:	5f                   	pop    %edi
  8022da:	5d                   	pop    %ebp
  8022db:	c3                   	ret    
  8022dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8022e0:	8b 34 24             	mov    (%esp),%esi
  8022e3:	bf 20 00 00 00       	mov    $0x20,%edi
  8022e8:	89 e9                	mov    %ebp,%ecx
  8022ea:	29 ef                	sub    %ebp,%edi
  8022ec:	d3 e0                	shl    %cl,%eax
  8022ee:	89 f9                	mov    %edi,%ecx
  8022f0:	89 f2                	mov    %esi,%edx
  8022f2:	d3 ea                	shr    %cl,%edx
  8022f4:	89 e9                	mov    %ebp,%ecx
  8022f6:	09 c2                	or     %eax,%edx
  8022f8:	89 d8                	mov    %ebx,%eax
  8022fa:	89 14 24             	mov    %edx,(%esp)
  8022fd:	89 f2                	mov    %esi,%edx
  8022ff:	d3 e2                	shl    %cl,%edx
  802301:	89 f9                	mov    %edi,%ecx
  802303:	89 54 24 04          	mov    %edx,0x4(%esp)
  802307:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80230b:	d3 e8                	shr    %cl,%eax
  80230d:	89 e9                	mov    %ebp,%ecx
  80230f:	89 c6                	mov    %eax,%esi
  802311:	d3 e3                	shl    %cl,%ebx
  802313:	89 f9                	mov    %edi,%ecx
  802315:	89 d0                	mov    %edx,%eax
  802317:	d3 e8                	shr    %cl,%eax
  802319:	89 e9                	mov    %ebp,%ecx
  80231b:	09 d8                	or     %ebx,%eax
  80231d:	89 d3                	mov    %edx,%ebx
  80231f:	89 f2                	mov    %esi,%edx
  802321:	f7 34 24             	divl   (%esp)
  802324:	89 d6                	mov    %edx,%esi
  802326:	d3 e3                	shl    %cl,%ebx
  802328:	f7 64 24 04          	mull   0x4(%esp)
  80232c:	39 d6                	cmp    %edx,%esi
  80232e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802332:	89 d1                	mov    %edx,%ecx
  802334:	89 c3                	mov    %eax,%ebx
  802336:	72 08                	jb     802340 <__umoddi3+0x110>
  802338:	75 11                	jne    80234b <__umoddi3+0x11b>
  80233a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80233e:	73 0b                	jae    80234b <__umoddi3+0x11b>
  802340:	2b 44 24 04          	sub    0x4(%esp),%eax
  802344:	1b 14 24             	sbb    (%esp),%edx
  802347:	89 d1                	mov    %edx,%ecx
  802349:	89 c3                	mov    %eax,%ebx
  80234b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80234f:	29 da                	sub    %ebx,%edx
  802351:	19 ce                	sbb    %ecx,%esi
  802353:	89 f9                	mov    %edi,%ecx
  802355:	89 f0                	mov    %esi,%eax
  802357:	d3 e0                	shl    %cl,%eax
  802359:	89 e9                	mov    %ebp,%ecx
  80235b:	d3 ea                	shr    %cl,%edx
  80235d:	89 e9                	mov    %ebp,%ecx
  80235f:	d3 ee                	shr    %cl,%esi
  802361:	09 d0                	or     %edx,%eax
  802363:	89 f2                	mov    %esi,%edx
  802365:	83 c4 1c             	add    $0x1c,%esp
  802368:	5b                   	pop    %ebx
  802369:	5e                   	pop    %esi
  80236a:	5f                   	pop    %edi
  80236b:	5d                   	pop    %ebp
  80236c:	c3                   	ret    
  80236d:	8d 76 00             	lea    0x0(%esi),%esi
  802370:	29 f9                	sub    %edi,%ecx
  802372:	19 d6                	sbb    %edx,%esi
  802374:	89 74 24 04          	mov    %esi,0x4(%esp)
  802378:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80237c:	e9 18 ff ff ff       	jmp    802299 <__umoddi3+0x69>
