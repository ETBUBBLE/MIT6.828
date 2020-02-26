
obj/user/pingpong.debug：     文件格式 elf32-i386


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
  80002c:	e8 8d 00 00 00       	call   8000be <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 99 0e 00 00       	call   800eda <fork>
  800041:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800044:	85 c0                	test   %eax,%eax
  800046:	74 27                	je     80006f <umain+0x3c>
  800048:	89 c3                	mov    %eax,%ebx
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 2b 0b 00 00       	call   800b7a <sys_getenvid>
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	53                   	push   %ebx
  800053:	50                   	push   %eax
  800054:	68 80 26 80 00       	push   $0x802680
  800059:	e8 53 01 00 00       	call   8001b1 <cprintf>
		ipc_send(who, 0, 0, 0);
  80005e:	6a 00                	push   $0x0
  800060:	6a 00                	push   $0x0
  800062:	6a 00                	push   $0x0
  800064:	ff 75 e4             	pushl  -0x1c(%ebp)
  800067:	e8 84 10 00 00       	call   8010f0 <ipc_send>
  80006c:	83 c4 20             	add    $0x20,%esp
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80006f:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  800072:	83 ec 04             	sub    $0x4,%esp
  800075:	6a 00                	push   $0x0
  800077:	6a 00                	push   $0x0
  800079:	56                   	push   %esi
  80007a:	e8 08 10 00 00       	call   801087 <ipc_recv>
  80007f:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  800081:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800084:	e8 f1 0a 00 00       	call   800b7a <sys_getenvid>
  800089:	57                   	push   %edi
  80008a:	53                   	push   %ebx
  80008b:	50                   	push   %eax
  80008c:	68 96 26 80 00       	push   $0x802696
  800091:	e8 1b 01 00 00       	call   8001b1 <cprintf>
		if (i == 10)
  800096:	83 c4 20             	add    $0x20,%esp
  800099:	83 fb 0a             	cmp    $0xa,%ebx
  80009c:	74 18                	je     8000b6 <umain+0x83>
			return;
		i++;
  80009e:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000a1:	6a 00                	push   $0x0
  8000a3:	6a 00                	push   $0x0
  8000a5:	53                   	push   %ebx
  8000a6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a9:	e8 42 10 00 00       	call   8010f0 <ipc_send>
		if (i == 10)
  8000ae:	83 c4 10             	add    $0x10,%esp
  8000b1:	83 fb 0a             	cmp    $0xa,%ebx
  8000b4:	75 bc                	jne    800072 <umain+0x3f>
			return;
	}

}
  8000b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000b9:	5b                   	pop    %ebx
  8000ba:	5e                   	pop    %esi
  8000bb:	5f                   	pop    %edi
  8000bc:	5d                   	pop    %ebp
  8000bd:	c3                   	ret    

008000be <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	56                   	push   %esi
  8000c2:	53                   	push   %ebx
  8000c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c6:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8000c9:	e8 ac 0a 00 00       	call   800b7a <sys_getenvid>
  8000ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000db:	a3 08 40 80 00       	mov    %eax,0x804008

    // save the name of the program so that panic() can use it
    if (argc > 0)
  8000e0:	85 db                	test   %ebx,%ebx
  8000e2:	7e 07                	jle    8000eb <libmain+0x2d>
        binaryname = argv[0];
  8000e4:	8b 06                	mov    (%esi),%eax
  8000e6:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  8000eb:	83 ec 08             	sub    $0x8,%esp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	e8 3e ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  8000f5:	e8 0a 00 00 00       	call   800104 <exit>
}
  8000fa:	83 c4 10             	add    $0x10,%esp
  8000fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800100:	5b                   	pop    %ebx
  800101:	5e                   	pop    %esi
  800102:	5d                   	pop    %ebp
  800103:	c3                   	ret    

00800104 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80010a:	e8 39 12 00 00       	call   801348 <close_all>
	sys_env_destroy(0);
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	6a 00                	push   $0x0
  800114:	e8 20 0a 00 00       	call   800b39 <sys_env_destroy>
}
  800119:	83 c4 10             	add    $0x10,%esp
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	53                   	push   %ebx
  800122:	83 ec 04             	sub    $0x4,%esp
  800125:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800128:	8b 13                	mov    (%ebx),%edx
  80012a:	8d 42 01             	lea    0x1(%edx),%eax
  80012d:	89 03                	mov    %eax,(%ebx)
  80012f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800132:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800136:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013b:	75 1a                	jne    800157 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80013d:	83 ec 08             	sub    $0x8,%esp
  800140:	68 ff 00 00 00       	push   $0xff
  800145:	8d 43 08             	lea    0x8(%ebx),%eax
  800148:	50                   	push   %eax
  800149:	e8 ae 09 00 00       	call   800afc <sys_cputs>
		b->idx = 0;
  80014e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800154:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800157:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800169:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800170:	00 00 00 
	b.cnt = 0;
  800173:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80017d:	ff 75 0c             	pushl  0xc(%ebp)
  800180:	ff 75 08             	pushl  0x8(%ebp)
  800183:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800189:	50                   	push   %eax
  80018a:	68 1e 01 80 00       	push   $0x80011e
  80018f:	e8 1a 01 00 00       	call   8002ae <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800194:	83 c4 08             	add    $0x8,%esp
  800197:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80019d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a3:	50                   	push   %eax
  8001a4:	e8 53 09 00 00       	call   800afc <sys_cputs>

	return b.cnt;
}
  8001a9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001af:	c9                   	leave  
  8001b0:	c3                   	ret    

008001b1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b1:	55                   	push   %ebp
  8001b2:	89 e5                	mov    %esp,%ebp
  8001b4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001b7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001ba:	50                   	push   %eax
  8001bb:	ff 75 08             	pushl  0x8(%ebp)
  8001be:	e8 9d ff ff ff       	call   800160 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	57                   	push   %edi
  8001c9:	56                   	push   %esi
  8001ca:	53                   	push   %ebx
  8001cb:	83 ec 1c             	sub    $0x1c,%esp
  8001ce:	89 c7                	mov    %eax,%edi
  8001d0:	89 d6                	mov    %edx,%esi
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001db:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001de:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e9:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ec:	39 d3                	cmp    %edx,%ebx
  8001ee:	72 05                	jb     8001f5 <printnum+0x30>
  8001f0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f3:	77 45                	ja     80023a <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	ff 75 18             	pushl  0x18(%ebp)
  8001fb:	8b 45 14             	mov    0x14(%ebp),%eax
  8001fe:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800201:	53                   	push   %ebx
  800202:	ff 75 10             	pushl  0x10(%ebp)
  800205:	83 ec 08             	sub    $0x8,%esp
  800208:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020b:	ff 75 e0             	pushl  -0x20(%ebp)
  80020e:	ff 75 dc             	pushl  -0x24(%ebp)
  800211:	ff 75 d8             	pushl  -0x28(%ebp)
  800214:	e8 c7 21 00 00       	call   8023e0 <__udivdi3>
  800219:	83 c4 18             	add    $0x18,%esp
  80021c:	52                   	push   %edx
  80021d:	50                   	push   %eax
  80021e:	89 f2                	mov    %esi,%edx
  800220:	89 f8                	mov    %edi,%eax
  800222:	e8 9e ff ff ff       	call   8001c5 <printnum>
  800227:	83 c4 20             	add    $0x20,%esp
  80022a:	eb 18                	jmp    800244 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022c:	83 ec 08             	sub    $0x8,%esp
  80022f:	56                   	push   %esi
  800230:	ff 75 18             	pushl  0x18(%ebp)
  800233:	ff d7                	call   *%edi
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	eb 03                	jmp    80023d <printnum+0x78>
  80023a:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f e8                	jg     80022c <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	83 ec 08             	sub    $0x8,%esp
  800247:	56                   	push   %esi
  800248:	83 ec 04             	sub    $0x4,%esp
  80024b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80024e:	ff 75 e0             	pushl  -0x20(%ebp)
  800251:	ff 75 dc             	pushl  -0x24(%ebp)
  800254:	ff 75 d8             	pushl  -0x28(%ebp)
  800257:	e8 b4 22 00 00       	call   802510 <__umoddi3>
  80025c:	83 c4 14             	add    $0x14,%esp
  80025f:	0f be 80 b3 26 80 00 	movsbl 0x8026b3(%eax),%eax
  800266:	50                   	push   %eax
  800267:	ff d7                	call   *%edi
}
  800269:	83 c4 10             	add    $0x10,%esp
  80026c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026f:	5b                   	pop    %ebx
  800270:	5e                   	pop    %esi
  800271:	5f                   	pop    %edi
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	3b 50 04             	cmp    0x4(%eax),%edx
  800283:	73 0a                	jae    80028f <sprintputch+0x1b>
		*b->buf++ = ch;
  800285:	8d 4a 01             	lea    0x1(%edx),%ecx
  800288:	89 08                	mov    %ecx,(%eax)
  80028a:	8b 45 08             	mov    0x8(%ebp),%eax
  80028d:	88 02                	mov    %al,(%edx)
}
  80028f:	5d                   	pop    %ebp
  800290:	c3                   	ret    

00800291 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800291:	55                   	push   %ebp
  800292:	89 e5                	mov    %esp,%ebp
  800294:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800297:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029a:	50                   	push   %eax
  80029b:	ff 75 10             	pushl  0x10(%ebp)
  80029e:	ff 75 0c             	pushl  0xc(%ebp)
  8002a1:	ff 75 08             	pushl  0x8(%ebp)
  8002a4:	e8 05 00 00 00       	call   8002ae <vprintfmt>
	va_end(ap);
}
  8002a9:	83 c4 10             	add    $0x10,%esp
  8002ac:	c9                   	leave  
  8002ad:	c3                   	ret    

008002ae <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 2c             	sub    $0x2c,%esp
  8002b7:	8b 75 08             	mov    0x8(%ebp),%esi
  8002ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002bd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c0:	eb 12                	jmp    8002d4 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002c2:	85 c0                	test   %eax,%eax
  8002c4:	0f 84 42 04 00 00    	je     80070c <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002ca:	83 ec 08             	sub    $0x8,%esp
  8002cd:	53                   	push   %ebx
  8002ce:	50                   	push   %eax
  8002cf:	ff d6                	call   *%esi
  8002d1:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d4:	83 c7 01             	add    $0x1,%edi
  8002d7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002db:	83 f8 25             	cmp    $0x25,%eax
  8002de:	75 e2                	jne    8002c2 <vprintfmt+0x14>
  8002e0:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e4:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002eb:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002f2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002fe:	eb 07                	jmp    800307 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800300:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800303:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800307:	8d 47 01             	lea    0x1(%edi),%eax
  80030a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80030d:	0f b6 07             	movzbl (%edi),%eax
  800310:	0f b6 d0             	movzbl %al,%edx
  800313:	83 e8 23             	sub    $0x23,%eax
  800316:	3c 55                	cmp    $0x55,%al
  800318:	0f 87 d3 03 00 00    	ja     8006f1 <vprintfmt+0x443>
  80031e:	0f b6 c0             	movzbl %al,%eax
  800321:	ff 24 85 00 28 80 00 	jmp    *0x802800(,%eax,4)
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80032b:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80032f:	eb d6                	jmp    800307 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800331:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800334:	b8 00 00 00 00       	mov    $0x0,%eax
  800339:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80033c:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80033f:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800343:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800346:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800349:	83 f9 09             	cmp    $0x9,%ecx
  80034c:	77 3f                	ja     80038d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80034e:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800351:	eb e9                	jmp    80033c <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800353:	8b 45 14             	mov    0x14(%ebp),%eax
  800356:	8b 00                	mov    (%eax),%eax
  800358:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80035b:	8b 45 14             	mov    0x14(%ebp),%eax
  80035e:	8d 40 04             	lea    0x4(%eax),%eax
  800361:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800364:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800367:	eb 2a                	jmp    800393 <vprintfmt+0xe5>
  800369:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036c:	85 c0                	test   %eax,%eax
  80036e:	ba 00 00 00 00       	mov    $0x0,%edx
  800373:	0f 49 d0             	cmovns %eax,%edx
  800376:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037c:	eb 89                	jmp    800307 <vprintfmt+0x59>
  80037e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800381:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800388:	e9 7a ff ff ff       	jmp    800307 <vprintfmt+0x59>
  80038d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800390:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800393:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800397:	0f 89 6a ff ff ff    	jns    800307 <vprintfmt+0x59>
				width = precision, precision = -1;
  80039d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a3:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003aa:	e9 58 ff ff ff       	jmp    800307 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003af:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003b5:	e9 4d ff ff ff       	jmp    800307 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8003bd:	8d 78 04             	lea    0x4(%eax),%edi
  8003c0:	83 ec 08             	sub    $0x8,%esp
  8003c3:	53                   	push   %ebx
  8003c4:	ff 30                	pushl  (%eax)
  8003c6:	ff d6                	call   *%esi
			break;
  8003c8:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003cb:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d1:	e9 fe fe ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d9:	8d 78 04             	lea    0x4(%eax),%edi
  8003dc:	8b 00                	mov    (%eax),%eax
  8003de:	99                   	cltd   
  8003df:	31 d0                	xor    %edx,%eax
  8003e1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e3:	83 f8 0f             	cmp    $0xf,%eax
  8003e6:	7f 0b                	jg     8003f3 <vprintfmt+0x145>
  8003e8:	8b 14 85 60 29 80 00 	mov    0x802960(,%eax,4),%edx
  8003ef:	85 d2                	test   %edx,%edx
  8003f1:	75 1b                	jne    80040e <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003f3:	50                   	push   %eax
  8003f4:	68 cb 26 80 00       	push   $0x8026cb
  8003f9:	53                   	push   %ebx
  8003fa:	56                   	push   %esi
  8003fb:	e8 91 fe ff ff       	call   800291 <printfmt>
  800400:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800403:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800406:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800409:	e9 c6 fe ff ff       	jmp    8002d4 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80040e:	52                   	push   %edx
  80040f:	68 59 2b 80 00       	push   $0x802b59
  800414:	53                   	push   %ebx
  800415:	56                   	push   %esi
  800416:	e8 76 fe ff ff       	call   800291 <printfmt>
  80041b:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80041e:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800421:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800424:	e9 ab fe ff ff       	jmp    8002d4 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	83 c0 04             	add    $0x4,%eax
  80042f:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800432:	8b 45 14             	mov    0x14(%ebp),%eax
  800435:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800437:	85 ff                	test   %edi,%edi
  800439:	b8 c4 26 80 00       	mov    $0x8026c4,%eax
  80043e:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800441:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800445:	0f 8e 94 00 00 00    	jle    8004df <vprintfmt+0x231>
  80044b:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80044f:	0f 84 98 00 00 00    	je     8004ed <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	ff 75 d0             	pushl  -0x30(%ebp)
  80045b:	57                   	push   %edi
  80045c:	e8 33 03 00 00       	call   800794 <strnlen>
  800461:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800464:	29 c1                	sub    %eax,%ecx
  800466:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800469:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80046c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800470:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800473:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800476:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800478:	eb 0f                	jmp    800489 <vprintfmt+0x1db>
					putch(padc, putdat);
  80047a:	83 ec 08             	sub    $0x8,%esp
  80047d:	53                   	push   %ebx
  80047e:	ff 75 e0             	pushl  -0x20(%ebp)
  800481:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800483:	83 ef 01             	sub    $0x1,%edi
  800486:	83 c4 10             	add    $0x10,%esp
  800489:	85 ff                	test   %edi,%edi
  80048b:	7f ed                	jg     80047a <vprintfmt+0x1cc>
  80048d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800490:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800493:	85 c9                	test   %ecx,%ecx
  800495:	b8 00 00 00 00       	mov    $0x0,%eax
  80049a:	0f 49 c1             	cmovns %ecx,%eax
  80049d:	29 c1                	sub    %eax,%ecx
  80049f:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004a8:	89 cb                	mov    %ecx,%ebx
  8004aa:	eb 4d                	jmp    8004f9 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004ac:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b0:	74 1b                	je     8004cd <vprintfmt+0x21f>
  8004b2:	0f be c0             	movsbl %al,%eax
  8004b5:	83 e8 20             	sub    $0x20,%eax
  8004b8:	83 f8 5e             	cmp    $0x5e,%eax
  8004bb:	76 10                	jbe    8004cd <vprintfmt+0x21f>
					putch('?', putdat);
  8004bd:	83 ec 08             	sub    $0x8,%esp
  8004c0:	ff 75 0c             	pushl  0xc(%ebp)
  8004c3:	6a 3f                	push   $0x3f
  8004c5:	ff 55 08             	call   *0x8(%ebp)
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	eb 0d                	jmp    8004da <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004cd:	83 ec 08             	sub    $0x8,%esp
  8004d0:	ff 75 0c             	pushl  0xc(%ebp)
  8004d3:	52                   	push   %edx
  8004d4:	ff 55 08             	call   *0x8(%ebp)
  8004d7:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004da:	83 eb 01             	sub    $0x1,%ebx
  8004dd:	eb 1a                	jmp    8004f9 <vprintfmt+0x24b>
  8004df:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e2:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e5:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004e8:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004eb:	eb 0c                	jmp    8004f9 <vprintfmt+0x24b>
  8004ed:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f9:	83 c7 01             	add    $0x1,%edi
  8004fc:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800500:	0f be d0             	movsbl %al,%edx
  800503:	85 d2                	test   %edx,%edx
  800505:	74 23                	je     80052a <vprintfmt+0x27c>
  800507:	85 f6                	test   %esi,%esi
  800509:	78 a1                	js     8004ac <vprintfmt+0x1fe>
  80050b:	83 ee 01             	sub    $0x1,%esi
  80050e:	79 9c                	jns    8004ac <vprintfmt+0x1fe>
  800510:	89 df                	mov    %ebx,%edi
  800512:	8b 75 08             	mov    0x8(%ebp),%esi
  800515:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800518:	eb 18                	jmp    800532 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80051a:	83 ec 08             	sub    $0x8,%esp
  80051d:	53                   	push   %ebx
  80051e:	6a 20                	push   $0x20
  800520:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800522:	83 ef 01             	sub    $0x1,%edi
  800525:	83 c4 10             	add    $0x10,%esp
  800528:	eb 08                	jmp    800532 <vprintfmt+0x284>
  80052a:	89 df                	mov    %ebx,%edi
  80052c:	8b 75 08             	mov    0x8(%ebp),%esi
  80052f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800532:	85 ff                	test   %edi,%edi
  800534:	7f e4                	jg     80051a <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800536:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800539:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80053f:	e9 90 fd ff ff       	jmp    8002d4 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800544:	83 f9 01             	cmp    $0x1,%ecx
  800547:	7e 19                	jle    800562 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800549:	8b 45 14             	mov    0x14(%ebp),%eax
  80054c:	8b 50 04             	mov    0x4(%eax),%edx
  80054f:	8b 00                	mov    (%eax),%eax
  800551:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800554:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800557:	8b 45 14             	mov    0x14(%ebp),%eax
  80055a:	8d 40 08             	lea    0x8(%eax),%eax
  80055d:	89 45 14             	mov    %eax,0x14(%ebp)
  800560:	eb 38                	jmp    80059a <vprintfmt+0x2ec>
	else if (lflag)
  800562:	85 c9                	test   %ecx,%ecx
  800564:	74 1b                	je     800581 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800566:	8b 45 14             	mov    0x14(%ebp),%eax
  800569:	8b 00                	mov    (%eax),%eax
  80056b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80056e:	89 c1                	mov    %eax,%ecx
  800570:	c1 f9 1f             	sar    $0x1f,%ecx
  800573:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800576:	8b 45 14             	mov    0x14(%ebp),%eax
  800579:	8d 40 04             	lea    0x4(%eax),%eax
  80057c:	89 45 14             	mov    %eax,0x14(%ebp)
  80057f:	eb 19                	jmp    80059a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800581:	8b 45 14             	mov    0x14(%ebp),%eax
  800584:	8b 00                	mov    (%eax),%eax
  800586:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800589:	89 c1                	mov    %eax,%ecx
  80058b:	c1 f9 1f             	sar    $0x1f,%ecx
  80058e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8d 40 04             	lea    0x4(%eax),%eax
  800597:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80059d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a0:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a9:	0f 89 0e 01 00 00    	jns    8006bd <vprintfmt+0x40f>
				putch('-', putdat);
  8005af:	83 ec 08             	sub    $0x8,%esp
  8005b2:	53                   	push   %ebx
  8005b3:	6a 2d                	push   $0x2d
  8005b5:	ff d6                	call   *%esi
				num = -(long long) num;
  8005b7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005ba:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005bd:	f7 da                	neg    %edx
  8005bf:	83 d1 00             	adc    $0x0,%ecx
  8005c2:	f7 d9                	neg    %ecx
  8005c4:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005c7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cc:	e9 ec 00 00 00       	jmp    8006bd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d1:	83 f9 01             	cmp    $0x1,%ecx
  8005d4:	7e 18                	jle    8005ee <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005d6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d9:	8b 10                	mov    (%eax),%edx
  8005db:	8b 48 04             	mov    0x4(%eax),%ecx
  8005de:	8d 40 08             	lea    0x8(%eax),%eax
  8005e1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005e4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e9:	e9 cf 00 00 00       	jmp    8006bd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005ee:	85 c9                	test   %ecx,%ecx
  8005f0:	74 1a                	je     80060c <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f5:	8b 10                	mov    (%eax),%edx
  8005f7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005fc:	8d 40 04             	lea    0x4(%eax),%eax
  8005ff:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800602:	b8 0a 00 00 00       	mov    $0xa,%eax
  800607:	e9 b1 00 00 00       	jmp    8006bd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80060c:	8b 45 14             	mov    0x14(%ebp),%eax
  80060f:	8b 10                	mov    (%eax),%edx
  800611:	b9 00 00 00 00       	mov    $0x0,%ecx
  800616:	8d 40 04             	lea    0x4(%eax),%eax
  800619:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80061c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800621:	e9 97 00 00 00       	jmp    8006bd <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800626:	83 ec 08             	sub    $0x8,%esp
  800629:	53                   	push   %ebx
  80062a:	6a 58                	push   $0x58
  80062c:	ff d6                	call   *%esi
			putch('X', putdat);
  80062e:	83 c4 08             	add    $0x8,%esp
  800631:	53                   	push   %ebx
  800632:	6a 58                	push   $0x58
  800634:	ff d6                	call   *%esi
			putch('X', putdat);
  800636:	83 c4 08             	add    $0x8,%esp
  800639:	53                   	push   %ebx
  80063a:	6a 58                	push   $0x58
  80063c:	ff d6                	call   *%esi
			break;
  80063e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800641:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800644:	e9 8b fc ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800649:	83 ec 08             	sub    $0x8,%esp
  80064c:	53                   	push   %ebx
  80064d:	6a 30                	push   $0x30
  80064f:	ff d6                	call   *%esi
			putch('x', putdat);
  800651:	83 c4 08             	add    $0x8,%esp
  800654:	53                   	push   %ebx
  800655:	6a 78                	push   $0x78
  800657:	ff d6                	call   *%esi
			num = (unsigned long long)
  800659:	8b 45 14             	mov    0x14(%ebp),%eax
  80065c:	8b 10                	mov    (%eax),%edx
  80065e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800663:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800666:	8d 40 04             	lea    0x4(%eax),%eax
  800669:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800671:	eb 4a                	jmp    8006bd <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800673:	83 f9 01             	cmp    $0x1,%ecx
  800676:	7e 15                	jle    80068d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800678:	8b 45 14             	mov    0x14(%ebp),%eax
  80067b:	8b 10                	mov    (%eax),%edx
  80067d:	8b 48 04             	mov    0x4(%eax),%ecx
  800680:	8d 40 08             	lea    0x8(%eax),%eax
  800683:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800686:	b8 10 00 00 00       	mov    $0x10,%eax
  80068b:	eb 30                	jmp    8006bd <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80068d:	85 c9                	test   %ecx,%ecx
  80068f:	74 17                	je     8006a8 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800691:	8b 45 14             	mov    0x14(%ebp),%eax
  800694:	8b 10                	mov    (%eax),%edx
  800696:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069b:	8d 40 04             	lea    0x4(%eax),%eax
  80069e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006a1:	b8 10 00 00 00       	mov    $0x10,%eax
  8006a6:	eb 15                	jmp    8006bd <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ab:	8b 10                	mov    (%eax),%edx
  8006ad:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b2:	8d 40 04             	lea    0x4(%eax),%eax
  8006b5:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006b8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006bd:	83 ec 0c             	sub    $0xc,%esp
  8006c0:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c4:	57                   	push   %edi
  8006c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006c8:	50                   	push   %eax
  8006c9:	51                   	push   %ecx
  8006ca:	52                   	push   %edx
  8006cb:	89 da                	mov    %ebx,%edx
  8006cd:	89 f0                	mov    %esi,%eax
  8006cf:	e8 f1 fa ff ff       	call   8001c5 <printnum>
			break;
  8006d4:	83 c4 20             	add    $0x20,%esp
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006da:	e9 f5 fb ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006df:	83 ec 08             	sub    $0x8,%esp
  8006e2:	53                   	push   %ebx
  8006e3:	52                   	push   %edx
  8006e4:	ff d6                	call   *%esi
			break;
  8006e6:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ec:	e9 e3 fb ff ff       	jmp    8002d4 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f1:	83 ec 08             	sub    $0x8,%esp
  8006f4:	53                   	push   %ebx
  8006f5:	6a 25                	push   $0x25
  8006f7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f9:	83 c4 10             	add    $0x10,%esp
  8006fc:	eb 03                	jmp    800701 <vprintfmt+0x453>
  8006fe:	83 ef 01             	sub    $0x1,%edi
  800701:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800705:	75 f7                	jne    8006fe <vprintfmt+0x450>
  800707:	e9 c8 fb ff ff       	jmp    8002d4 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80070c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070f:	5b                   	pop    %ebx
  800710:	5e                   	pop    %esi
  800711:	5f                   	pop    %edi
  800712:	5d                   	pop    %ebp
  800713:	c3                   	ret    

00800714 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	83 ec 18             	sub    $0x18,%esp
  80071a:	8b 45 08             	mov    0x8(%ebp),%eax
  80071d:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800720:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800723:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800727:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800731:	85 c0                	test   %eax,%eax
  800733:	74 26                	je     80075b <vsnprintf+0x47>
  800735:	85 d2                	test   %edx,%edx
  800737:	7e 22                	jle    80075b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800739:	ff 75 14             	pushl  0x14(%ebp)
  80073c:	ff 75 10             	pushl  0x10(%ebp)
  80073f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800742:	50                   	push   %eax
  800743:	68 74 02 80 00       	push   $0x800274
  800748:	e8 61 fb ff ff       	call   8002ae <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80074d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800750:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800753:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	eb 05                	jmp    800760 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800760:	c9                   	leave  
  800761:	c3                   	ret    

00800762 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800762:	55                   	push   %ebp
  800763:	89 e5                	mov    %esp,%ebp
  800765:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800768:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076b:	50                   	push   %eax
  80076c:	ff 75 10             	pushl  0x10(%ebp)
  80076f:	ff 75 0c             	pushl  0xc(%ebp)
  800772:	ff 75 08             	pushl  0x8(%ebp)
  800775:	e8 9a ff ff ff       	call   800714 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077a:	c9                   	leave  
  80077b:	c3                   	ret    

0080077c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800782:	b8 00 00 00 00       	mov    $0x0,%eax
  800787:	eb 03                	jmp    80078c <strlen+0x10>
		n++;
  800789:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800790:	75 f7                	jne    800789 <strlen+0xd>
		n++;
	return n;
}
  800792:	5d                   	pop    %ebp
  800793:	c3                   	ret    

00800794 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800794:	55                   	push   %ebp
  800795:	89 e5                	mov    %esp,%ebp
  800797:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079d:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a2:	eb 03                	jmp    8007a7 <strnlen+0x13>
		n++;
  8007a4:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a7:	39 c2                	cmp    %eax,%edx
  8007a9:	74 08                	je     8007b3 <strnlen+0x1f>
  8007ab:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007af:	75 f3                	jne    8007a4 <strnlen+0x10>
  8007b1:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b5:	55                   	push   %ebp
  8007b6:	89 e5                	mov    %esp,%ebp
  8007b8:	53                   	push   %ebx
  8007b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007bf:	89 c2                	mov    %eax,%edx
  8007c1:	83 c2 01             	add    $0x1,%edx
  8007c4:	83 c1 01             	add    $0x1,%ecx
  8007c7:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007cb:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007ce:	84 db                	test   %bl,%bl
  8007d0:	75 ef                	jne    8007c1 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d2:	5b                   	pop    %ebx
  8007d3:	5d                   	pop    %ebp
  8007d4:	c3                   	ret    

008007d5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	53                   	push   %ebx
  8007d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007dc:	53                   	push   %ebx
  8007dd:	e8 9a ff ff ff       	call   80077c <strlen>
  8007e2:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e5:	ff 75 0c             	pushl  0xc(%ebp)
  8007e8:	01 d8                	add    %ebx,%eax
  8007ea:	50                   	push   %eax
  8007eb:	e8 c5 ff ff ff       	call   8007b5 <strcpy>
	return dst;
}
  8007f0:	89 d8                	mov    %ebx,%eax
  8007f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f5:	c9                   	leave  
  8007f6:	c3                   	ret    

008007f7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800802:	89 f3                	mov    %esi,%ebx
  800804:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800807:	89 f2                	mov    %esi,%edx
  800809:	eb 0f                	jmp    80081a <strncpy+0x23>
		*dst++ = *src;
  80080b:	83 c2 01             	add    $0x1,%edx
  80080e:	0f b6 01             	movzbl (%ecx),%eax
  800811:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800814:	80 39 01             	cmpb   $0x1,(%ecx)
  800817:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081a:	39 da                	cmp    %ebx,%edx
  80081c:	75 ed                	jne    80080b <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80081e:	89 f0                	mov    %esi,%eax
  800820:	5b                   	pop    %ebx
  800821:	5e                   	pop    %esi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	56                   	push   %esi
  800828:	53                   	push   %ebx
  800829:	8b 75 08             	mov    0x8(%ebp),%esi
  80082c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80082f:	8b 55 10             	mov    0x10(%ebp),%edx
  800832:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800834:	85 d2                	test   %edx,%edx
  800836:	74 21                	je     800859 <strlcpy+0x35>
  800838:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083c:	89 f2                	mov    %esi,%edx
  80083e:	eb 09                	jmp    800849 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800840:	83 c2 01             	add    $0x1,%edx
  800843:	83 c1 01             	add    $0x1,%ecx
  800846:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800849:	39 c2                	cmp    %eax,%edx
  80084b:	74 09                	je     800856 <strlcpy+0x32>
  80084d:	0f b6 19             	movzbl (%ecx),%ebx
  800850:	84 db                	test   %bl,%bl
  800852:	75 ec                	jne    800840 <strlcpy+0x1c>
  800854:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800856:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800859:	29 f0                	sub    %esi,%eax
}
  80085b:	5b                   	pop    %ebx
  80085c:	5e                   	pop    %esi
  80085d:	5d                   	pop    %ebp
  80085e:	c3                   	ret    

0080085f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80085f:	55                   	push   %ebp
  800860:	89 e5                	mov    %esp,%ebp
  800862:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800865:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800868:	eb 06                	jmp    800870 <strcmp+0x11>
		p++, q++;
  80086a:	83 c1 01             	add    $0x1,%ecx
  80086d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800870:	0f b6 01             	movzbl (%ecx),%eax
  800873:	84 c0                	test   %al,%al
  800875:	74 04                	je     80087b <strcmp+0x1c>
  800877:	3a 02                	cmp    (%edx),%al
  800879:	74 ef                	je     80086a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087b:	0f b6 c0             	movzbl %al,%eax
  80087e:	0f b6 12             	movzbl (%edx),%edx
  800881:	29 d0                	sub    %edx,%eax
}
  800883:	5d                   	pop    %ebp
  800884:	c3                   	ret    

00800885 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	53                   	push   %ebx
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088f:	89 c3                	mov    %eax,%ebx
  800891:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800894:	eb 06                	jmp    80089c <strncmp+0x17>
		n--, p++, q++;
  800896:	83 c0 01             	add    $0x1,%eax
  800899:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089c:	39 d8                	cmp    %ebx,%eax
  80089e:	74 15                	je     8008b5 <strncmp+0x30>
  8008a0:	0f b6 08             	movzbl (%eax),%ecx
  8008a3:	84 c9                	test   %cl,%cl
  8008a5:	74 04                	je     8008ab <strncmp+0x26>
  8008a7:	3a 0a                	cmp    (%edx),%cl
  8008a9:	74 eb                	je     800896 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ab:	0f b6 00             	movzbl (%eax),%eax
  8008ae:	0f b6 12             	movzbl (%edx),%edx
  8008b1:	29 d0                	sub    %edx,%eax
  8008b3:	eb 05                	jmp    8008ba <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b5:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008ba:	5b                   	pop    %ebx
  8008bb:	5d                   	pop    %ebp
  8008bc:	c3                   	ret    

008008bd <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c7:	eb 07                	jmp    8008d0 <strchr+0x13>
		if (*s == c)
  8008c9:	38 ca                	cmp    %cl,%dl
  8008cb:	74 0f                	je     8008dc <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008cd:	83 c0 01             	add    $0x1,%eax
  8008d0:	0f b6 10             	movzbl (%eax),%edx
  8008d3:	84 d2                	test   %dl,%dl
  8008d5:	75 f2                	jne    8008c9 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008d7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e8:	eb 03                	jmp    8008ed <strfind+0xf>
  8008ea:	83 c0 01             	add    $0x1,%eax
  8008ed:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f0:	38 ca                	cmp    %cl,%dl
  8008f2:	74 04                	je     8008f8 <strfind+0x1a>
  8008f4:	84 d2                	test   %dl,%dl
  8008f6:	75 f2                	jne    8008ea <strfind+0xc>
			break;
	return (char *) s;
}
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	57                   	push   %edi
  8008fe:	56                   	push   %esi
  8008ff:	53                   	push   %ebx
  800900:	8b 7d 08             	mov    0x8(%ebp),%edi
  800903:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800906:	85 c9                	test   %ecx,%ecx
  800908:	74 36                	je     800940 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090a:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800910:	75 28                	jne    80093a <memset+0x40>
  800912:	f6 c1 03             	test   $0x3,%cl
  800915:	75 23                	jne    80093a <memset+0x40>
		c &= 0xFF;
  800917:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091b:	89 d3                	mov    %edx,%ebx
  80091d:	c1 e3 08             	shl    $0x8,%ebx
  800920:	89 d6                	mov    %edx,%esi
  800922:	c1 e6 18             	shl    $0x18,%esi
  800925:	89 d0                	mov    %edx,%eax
  800927:	c1 e0 10             	shl    $0x10,%eax
  80092a:	09 f0                	or     %esi,%eax
  80092c:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80092e:	89 d8                	mov    %ebx,%eax
  800930:	09 d0                	or     %edx,%eax
  800932:	c1 e9 02             	shr    $0x2,%ecx
  800935:	fc                   	cld    
  800936:	f3 ab                	rep stos %eax,%es:(%edi)
  800938:	eb 06                	jmp    800940 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093d:	fc                   	cld    
  80093e:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800940:	89 f8                	mov    %edi,%eax
  800942:	5b                   	pop    %ebx
  800943:	5e                   	pop    %esi
  800944:	5f                   	pop    %edi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800947:	55                   	push   %ebp
  800948:	89 e5                	mov    %esp,%ebp
  80094a:	57                   	push   %edi
  80094b:	56                   	push   %esi
  80094c:	8b 45 08             	mov    0x8(%ebp),%eax
  80094f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800952:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800955:	39 c6                	cmp    %eax,%esi
  800957:	73 35                	jae    80098e <memmove+0x47>
  800959:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095c:	39 d0                	cmp    %edx,%eax
  80095e:	73 2e                	jae    80098e <memmove+0x47>
		s += n;
		d += n;
  800960:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800963:	89 d6                	mov    %edx,%esi
  800965:	09 fe                	or     %edi,%esi
  800967:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80096d:	75 13                	jne    800982 <memmove+0x3b>
  80096f:	f6 c1 03             	test   $0x3,%cl
  800972:	75 0e                	jne    800982 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800974:	83 ef 04             	sub    $0x4,%edi
  800977:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097a:	c1 e9 02             	shr    $0x2,%ecx
  80097d:	fd                   	std    
  80097e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800980:	eb 09                	jmp    80098b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800982:	83 ef 01             	sub    $0x1,%edi
  800985:	8d 72 ff             	lea    -0x1(%edx),%esi
  800988:	fd                   	std    
  800989:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098b:	fc                   	cld    
  80098c:	eb 1d                	jmp    8009ab <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098e:	89 f2                	mov    %esi,%edx
  800990:	09 c2                	or     %eax,%edx
  800992:	f6 c2 03             	test   $0x3,%dl
  800995:	75 0f                	jne    8009a6 <memmove+0x5f>
  800997:	f6 c1 03             	test   $0x3,%cl
  80099a:	75 0a                	jne    8009a6 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80099c:	c1 e9 02             	shr    $0x2,%ecx
  80099f:	89 c7                	mov    %eax,%edi
  8009a1:	fc                   	cld    
  8009a2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a4:	eb 05                	jmp    8009ab <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a6:	89 c7                	mov    %eax,%edi
  8009a8:	fc                   	cld    
  8009a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ab:	5e                   	pop    %esi
  8009ac:	5f                   	pop    %edi
  8009ad:	5d                   	pop    %ebp
  8009ae:	c3                   	ret    

008009af <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009af:	55                   	push   %ebp
  8009b0:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b2:	ff 75 10             	pushl  0x10(%ebp)
  8009b5:	ff 75 0c             	pushl  0xc(%ebp)
  8009b8:	ff 75 08             	pushl  0x8(%ebp)
  8009bb:	e8 87 ff ff ff       	call   800947 <memmove>
}
  8009c0:	c9                   	leave  
  8009c1:	c3                   	ret    

008009c2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c2:	55                   	push   %ebp
  8009c3:	89 e5                	mov    %esp,%ebp
  8009c5:	56                   	push   %esi
  8009c6:	53                   	push   %ebx
  8009c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009cd:	89 c6                	mov    %eax,%esi
  8009cf:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d2:	eb 1a                	jmp    8009ee <memcmp+0x2c>
		if (*s1 != *s2)
  8009d4:	0f b6 08             	movzbl (%eax),%ecx
  8009d7:	0f b6 1a             	movzbl (%edx),%ebx
  8009da:	38 d9                	cmp    %bl,%cl
  8009dc:	74 0a                	je     8009e8 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009de:	0f b6 c1             	movzbl %cl,%eax
  8009e1:	0f b6 db             	movzbl %bl,%ebx
  8009e4:	29 d8                	sub    %ebx,%eax
  8009e6:	eb 0f                	jmp    8009f7 <memcmp+0x35>
		s1++, s2++;
  8009e8:	83 c0 01             	add    $0x1,%eax
  8009eb:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009ee:	39 f0                	cmp    %esi,%eax
  8009f0:	75 e2                	jne    8009d4 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f7:	5b                   	pop    %ebx
  8009f8:	5e                   	pop    %esi
  8009f9:	5d                   	pop    %ebp
  8009fa:	c3                   	ret    

008009fb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	53                   	push   %ebx
  8009ff:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a02:	89 c1                	mov    %eax,%ecx
  800a04:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a07:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0b:	eb 0a                	jmp    800a17 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0d:	0f b6 10             	movzbl (%eax),%edx
  800a10:	39 da                	cmp    %ebx,%edx
  800a12:	74 07                	je     800a1b <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a14:	83 c0 01             	add    $0x1,%eax
  800a17:	39 c8                	cmp    %ecx,%eax
  800a19:	72 f2                	jb     800a0d <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1b:	5b                   	pop    %ebx
  800a1c:	5d                   	pop    %ebp
  800a1d:	c3                   	ret    

00800a1e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	57                   	push   %edi
  800a22:	56                   	push   %esi
  800a23:	53                   	push   %ebx
  800a24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2a:	eb 03                	jmp    800a2f <strtol+0x11>
		s++;
  800a2c:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2f:	0f b6 01             	movzbl (%ecx),%eax
  800a32:	3c 20                	cmp    $0x20,%al
  800a34:	74 f6                	je     800a2c <strtol+0xe>
  800a36:	3c 09                	cmp    $0x9,%al
  800a38:	74 f2                	je     800a2c <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3a:	3c 2b                	cmp    $0x2b,%al
  800a3c:	75 0a                	jne    800a48 <strtol+0x2a>
		s++;
  800a3e:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a41:	bf 00 00 00 00       	mov    $0x0,%edi
  800a46:	eb 11                	jmp    800a59 <strtol+0x3b>
  800a48:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a4d:	3c 2d                	cmp    $0x2d,%al
  800a4f:	75 08                	jne    800a59 <strtol+0x3b>
		s++, neg = 1;
  800a51:	83 c1 01             	add    $0x1,%ecx
  800a54:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a59:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a5f:	75 15                	jne    800a76 <strtol+0x58>
  800a61:	80 39 30             	cmpb   $0x30,(%ecx)
  800a64:	75 10                	jne    800a76 <strtol+0x58>
  800a66:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6a:	75 7c                	jne    800ae8 <strtol+0xca>
		s += 2, base = 16;
  800a6c:	83 c1 02             	add    $0x2,%ecx
  800a6f:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a74:	eb 16                	jmp    800a8c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a76:	85 db                	test   %ebx,%ebx
  800a78:	75 12                	jne    800a8c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a7f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a82:	75 08                	jne    800a8c <strtol+0x6e>
		s++, base = 8;
  800a84:	83 c1 01             	add    $0x1,%ecx
  800a87:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a8c:	b8 00 00 00 00       	mov    $0x0,%eax
  800a91:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a94:	0f b6 11             	movzbl (%ecx),%edx
  800a97:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9a:	89 f3                	mov    %esi,%ebx
  800a9c:	80 fb 09             	cmp    $0x9,%bl
  800a9f:	77 08                	ja     800aa9 <strtol+0x8b>
			dig = *s - '0';
  800aa1:	0f be d2             	movsbl %dl,%edx
  800aa4:	83 ea 30             	sub    $0x30,%edx
  800aa7:	eb 22                	jmp    800acb <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aa9:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aac:	89 f3                	mov    %esi,%ebx
  800aae:	80 fb 19             	cmp    $0x19,%bl
  800ab1:	77 08                	ja     800abb <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab3:	0f be d2             	movsbl %dl,%edx
  800ab6:	83 ea 57             	sub    $0x57,%edx
  800ab9:	eb 10                	jmp    800acb <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abb:	8d 72 bf             	lea    -0x41(%edx),%esi
  800abe:	89 f3                	mov    %esi,%ebx
  800ac0:	80 fb 19             	cmp    $0x19,%bl
  800ac3:	77 16                	ja     800adb <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac5:	0f be d2             	movsbl %dl,%edx
  800ac8:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800acb:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ace:	7d 0b                	jge    800adb <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad0:	83 c1 01             	add    $0x1,%ecx
  800ad3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ad7:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ad9:	eb b9                	jmp    800a94 <strtol+0x76>

	if (endptr)
  800adb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800adf:	74 0d                	je     800aee <strtol+0xd0>
		*endptr = (char *) s;
  800ae1:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae4:	89 0e                	mov    %ecx,(%esi)
  800ae6:	eb 06                	jmp    800aee <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ae8:	85 db                	test   %ebx,%ebx
  800aea:	74 98                	je     800a84 <strtol+0x66>
  800aec:	eb 9e                	jmp    800a8c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800aee:	89 c2                	mov    %eax,%edx
  800af0:	f7 da                	neg    %edx
  800af2:	85 ff                	test   %edi,%edi
  800af4:	0f 45 c2             	cmovne %edx,%eax
}
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5f                   	pop    %edi
  800afa:	5d                   	pop    %ebp
  800afb:	c3                   	ret    

00800afc <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800afc:	55                   	push   %ebp
  800afd:	89 e5                	mov    %esp,%ebp
  800aff:	57                   	push   %edi
  800b00:	56                   	push   %esi
  800b01:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b02:	b8 00 00 00 00       	mov    $0x0,%eax
  800b07:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0a:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0d:	89 c3                	mov    %eax,%ebx
  800b0f:	89 c7                	mov    %eax,%edi
  800b11:	89 c6                	mov    %eax,%esi
  800b13:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5f                   	pop    %edi
  800b18:	5d                   	pop    %ebp
  800b19:	c3                   	ret    

00800b1a <sys_cgetc>:

int
sys_cgetc(void)
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
  800b25:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2a:	89 d1                	mov    %edx,%ecx
  800b2c:	89 d3                	mov    %edx,%ebx
  800b2e:	89 d7                	mov    %edx,%edi
  800b30:	89 d6                	mov    %edx,%esi
  800b32:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b34:	5b                   	pop    %ebx
  800b35:	5e                   	pop    %esi
  800b36:	5f                   	pop    %edi
  800b37:	5d                   	pop    %ebp
  800b38:	c3                   	ret    

00800b39 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b39:	55                   	push   %ebp
  800b3a:	89 e5                	mov    %esp,%ebp
  800b3c:	57                   	push   %edi
  800b3d:	56                   	push   %esi
  800b3e:	53                   	push   %ebx
  800b3f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b42:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b47:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4c:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4f:	89 cb                	mov    %ecx,%ebx
  800b51:	89 cf                	mov    %ecx,%edi
  800b53:	89 ce                	mov    %ecx,%esi
  800b55:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b57:	85 c0                	test   %eax,%eax
  800b59:	7e 17                	jle    800b72 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5b:	83 ec 0c             	sub    $0xc,%esp
  800b5e:	50                   	push   %eax
  800b5f:	6a 03                	push   $0x3
  800b61:	68 bf 29 80 00       	push   $0x8029bf
  800b66:	6a 23                	push   $0x23
  800b68:	68 dc 29 80 00       	push   $0x8029dc
  800b6d:	e8 5c 17 00 00       	call   8022ce <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b72:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b75:	5b                   	pop    %ebx
  800b76:	5e                   	pop    %esi
  800b77:	5f                   	pop    %edi
  800b78:	5d                   	pop    %ebp
  800b79:	c3                   	ret    

00800b7a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	57                   	push   %edi
  800b7e:	56                   	push   %esi
  800b7f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b80:	ba 00 00 00 00       	mov    $0x0,%edx
  800b85:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8a:	89 d1                	mov    %edx,%ecx
  800b8c:	89 d3                	mov    %edx,%ebx
  800b8e:	89 d7                	mov    %edx,%edi
  800b90:	89 d6                	mov    %edx,%esi
  800b92:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b94:	5b                   	pop    %ebx
  800b95:	5e                   	pop    %esi
  800b96:	5f                   	pop    %edi
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <sys_yield>:

void
sys_yield(void)
{
  800b99:	55                   	push   %ebp
  800b9a:	89 e5                	mov    %esp,%ebp
  800b9c:	57                   	push   %edi
  800b9d:	56                   	push   %esi
  800b9e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b9f:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ba9:	89 d1                	mov    %edx,%ecx
  800bab:	89 d3                	mov    %edx,%ebx
  800bad:	89 d7                	mov    %edx,%edi
  800baf:	89 d6                	mov    %edx,%esi
  800bb1:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb3:	5b                   	pop    %ebx
  800bb4:	5e                   	pop    %esi
  800bb5:	5f                   	pop    %edi
  800bb6:	5d                   	pop    %ebp
  800bb7:	c3                   	ret    

00800bb8 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	57                   	push   %edi
  800bbc:	56                   	push   %esi
  800bbd:	53                   	push   %ebx
  800bbe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc1:	be 00 00 00 00       	mov    $0x0,%esi
  800bc6:	b8 04 00 00 00       	mov    $0x4,%eax
  800bcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bce:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd4:	89 f7                	mov    %esi,%edi
  800bd6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bd8:	85 c0                	test   %eax,%eax
  800bda:	7e 17                	jle    800bf3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	50                   	push   %eax
  800be0:	6a 04                	push   $0x4
  800be2:	68 bf 29 80 00       	push   $0x8029bf
  800be7:	6a 23                	push   $0x23
  800be9:	68 dc 29 80 00       	push   $0x8029dc
  800bee:	e8 db 16 00 00       	call   8022ce <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf6:	5b                   	pop    %ebx
  800bf7:	5e                   	pop    %esi
  800bf8:	5f                   	pop    %edi
  800bf9:	5d                   	pop    %ebp
  800bfa:	c3                   	ret    

00800bfb <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfb:	55                   	push   %ebp
  800bfc:	89 e5                	mov    %esp,%ebp
  800bfe:	57                   	push   %edi
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c04:	b8 05 00 00 00       	mov    $0x5,%eax
  800c09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c12:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c15:	8b 75 18             	mov    0x18(%ebp),%esi
  800c18:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1a:	85 c0                	test   %eax,%eax
  800c1c:	7e 17                	jle    800c35 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c1e:	83 ec 0c             	sub    $0xc,%esp
  800c21:	50                   	push   %eax
  800c22:	6a 05                	push   $0x5
  800c24:	68 bf 29 80 00       	push   $0x8029bf
  800c29:	6a 23                	push   $0x23
  800c2b:	68 dc 29 80 00       	push   $0x8029dc
  800c30:	e8 99 16 00 00       	call   8022ce <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c38:	5b                   	pop    %ebx
  800c39:	5e                   	pop    %esi
  800c3a:	5f                   	pop    %edi
  800c3b:	5d                   	pop    %ebp
  800c3c:	c3                   	ret    

00800c3d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c3d:	55                   	push   %ebp
  800c3e:	89 e5                	mov    %esp,%ebp
  800c40:	57                   	push   %edi
  800c41:	56                   	push   %esi
  800c42:	53                   	push   %ebx
  800c43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4b:	b8 06 00 00 00       	mov    $0x6,%eax
  800c50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c53:	8b 55 08             	mov    0x8(%ebp),%edx
  800c56:	89 df                	mov    %ebx,%edi
  800c58:	89 de                	mov    %ebx,%esi
  800c5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5c:	85 c0                	test   %eax,%eax
  800c5e:	7e 17                	jle    800c77 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c60:	83 ec 0c             	sub    $0xc,%esp
  800c63:	50                   	push   %eax
  800c64:	6a 06                	push   $0x6
  800c66:	68 bf 29 80 00       	push   $0x8029bf
  800c6b:	6a 23                	push   $0x23
  800c6d:	68 dc 29 80 00       	push   $0x8029dc
  800c72:	e8 57 16 00 00       	call   8022ce <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7a:	5b                   	pop    %ebx
  800c7b:	5e                   	pop    %esi
  800c7c:	5f                   	pop    %edi
  800c7d:	5d                   	pop    %ebp
  800c7e:	c3                   	ret    

00800c7f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	57                   	push   %edi
  800c83:	56                   	push   %esi
  800c84:	53                   	push   %ebx
  800c85:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c88:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c8d:	b8 08 00 00 00       	mov    $0x8,%eax
  800c92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c95:	8b 55 08             	mov    0x8(%ebp),%edx
  800c98:	89 df                	mov    %ebx,%edi
  800c9a:	89 de                	mov    %ebx,%esi
  800c9c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c9e:	85 c0                	test   %eax,%eax
  800ca0:	7e 17                	jle    800cb9 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca2:	83 ec 0c             	sub    $0xc,%esp
  800ca5:	50                   	push   %eax
  800ca6:	6a 08                	push   $0x8
  800ca8:	68 bf 29 80 00       	push   $0x8029bf
  800cad:	6a 23                	push   $0x23
  800caf:	68 dc 29 80 00       	push   $0x8029dc
  800cb4:	e8 15 16 00 00       	call   8022ce <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	57                   	push   %edi
  800cc5:	56                   	push   %esi
  800cc6:	53                   	push   %ebx
  800cc7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccf:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cda:	89 df                	mov    %ebx,%edi
  800cdc:	89 de                	mov    %ebx,%esi
  800cde:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce0:	85 c0                	test   %eax,%eax
  800ce2:	7e 17                	jle    800cfb <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce4:	83 ec 0c             	sub    $0xc,%esp
  800ce7:	50                   	push   %eax
  800ce8:	6a 09                	push   $0x9
  800cea:	68 bf 29 80 00       	push   $0x8029bf
  800cef:	6a 23                	push   $0x23
  800cf1:	68 dc 29 80 00       	push   $0x8029dc
  800cf6:	e8 d3 15 00 00       	call   8022ce <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cfb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cfe:	5b                   	pop    %ebx
  800cff:	5e                   	pop    %esi
  800d00:	5f                   	pop    %edi
  800d01:	5d                   	pop    %ebp
  800d02:	c3                   	ret    

00800d03 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d03:	55                   	push   %ebp
  800d04:	89 e5                	mov    %esp,%ebp
  800d06:	57                   	push   %edi
  800d07:	56                   	push   %esi
  800d08:	53                   	push   %ebx
  800d09:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d11:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d16:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d19:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1c:	89 df                	mov    %ebx,%edi
  800d1e:	89 de                	mov    %ebx,%esi
  800d20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d22:	85 c0                	test   %eax,%eax
  800d24:	7e 17                	jle    800d3d <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d26:	83 ec 0c             	sub    $0xc,%esp
  800d29:	50                   	push   %eax
  800d2a:	6a 0a                	push   $0xa
  800d2c:	68 bf 29 80 00       	push   $0x8029bf
  800d31:	6a 23                	push   $0x23
  800d33:	68 dc 29 80 00       	push   $0x8029dc
  800d38:	e8 91 15 00 00       	call   8022ce <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d3d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d40:	5b                   	pop    %ebx
  800d41:	5e                   	pop    %esi
  800d42:	5f                   	pop    %edi
  800d43:	5d                   	pop    %ebp
  800d44:	c3                   	ret    

00800d45 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	57                   	push   %edi
  800d49:	56                   	push   %esi
  800d4a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4b:	be 00 00 00 00       	mov    $0x0,%esi
  800d50:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d55:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d58:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d5e:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d61:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d63:	5b                   	pop    %ebx
  800d64:	5e                   	pop    %esi
  800d65:	5f                   	pop    %edi
  800d66:	5d                   	pop    %ebp
  800d67:	c3                   	ret    

00800d68 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d68:	55                   	push   %ebp
  800d69:	89 e5                	mov    %esp,%ebp
  800d6b:	57                   	push   %edi
  800d6c:	56                   	push   %esi
  800d6d:	53                   	push   %ebx
  800d6e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d71:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d76:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7e:	89 cb                	mov    %ecx,%ebx
  800d80:	89 cf                	mov    %ecx,%edi
  800d82:	89 ce                	mov    %ecx,%esi
  800d84:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d86:	85 c0                	test   %eax,%eax
  800d88:	7e 17                	jle    800da1 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8a:	83 ec 0c             	sub    $0xc,%esp
  800d8d:	50                   	push   %eax
  800d8e:	6a 0d                	push   $0xd
  800d90:	68 bf 29 80 00       	push   $0x8029bf
  800d95:	6a 23                	push   $0x23
  800d97:	68 dc 29 80 00       	push   $0x8029dc
  800d9c:	e8 2d 15 00 00       	call   8022ce <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da4:	5b                   	pop    %ebx
  800da5:	5e                   	pop    %esi
  800da6:	5f                   	pop    %edi
  800da7:	5d                   	pop    %ebp
  800da8:	c3                   	ret    

00800da9 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800da9:	55                   	push   %ebp
  800daa:	89 e5                	mov    %esp,%ebp
  800dac:	57                   	push   %edi
  800dad:	56                   	push   %esi
  800dae:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daf:	ba 00 00 00 00       	mov    $0x0,%edx
  800db4:	b8 0e 00 00 00       	mov    $0xe,%eax
  800db9:	89 d1                	mov    %edx,%ecx
  800dbb:	89 d3                	mov    %edx,%ebx
  800dbd:	89 d7                	mov    %edx,%edi
  800dbf:	89 d6                	mov    %edx,%esi
  800dc1:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dc3:	5b                   	pop    %ebx
  800dc4:	5e                   	pop    %esi
  800dc5:	5f                   	pop    %edi
  800dc6:	5d                   	pop    %ebp
  800dc7:	c3                   	ret    

00800dc8 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800dc8:	55                   	push   %ebp
  800dc9:	89 e5                	mov    %esp,%ebp
  800dcb:	57                   	push   %edi
  800dcc:	56                   	push   %esi
  800dcd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dce:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd3:	b8 10 00 00 00       	mov    $0x10,%eax
  800dd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ddb:	89 cb                	mov    %ecx,%ebx
  800ddd:	89 cf                	mov    %ecx,%edi
  800ddf:	89 ce                	mov    %ecx,%esi
  800de1:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    

00800de8 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800de8:	55                   	push   %ebp
  800de9:	89 e5                	mov    %esp,%ebp
  800deb:	53                   	push   %ebx
  800dec:	83 ec 04             	sub    $0x4,%esp
  800def:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800df2:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800df4:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800df8:	74 2d                	je     800e27 <pgfault+0x3f>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800dfa:	89 d8                	mov    %ebx,%eax
  800dfc:	c1 e8 16             	shr    $0x16,%eax
  800dff:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800e06:	a8 01                	test   $0x1,%al
  800e08:	74 1d                	je     800e27 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e0a:	89 d8                	mov    %ebx,%eax
  800e0c:	c1 e8 0c             	shr    $0xc,%eax
  800e0f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800e16:	f6 c2 01             	test   $0x1,%dl
  800e19:	74 0c                	je     800e27 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e1b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800e22:	f6 c4 08             	test   $0x8,%ah
  800e25:	75 14                	jne    800e3b <pgfault+0x53>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
	)) panic("Neither the fault is a write nor copy-on-write page.\n");
  800e27:	83 ec 04             	sub    $0x4,%esp
  800e2a:	68 ec 29 80 00       	push   $0x8029ec
  800e2f:	6a 1f                	push   $0x1f
  800e31:	68 22 2a 80 00       	push   $0x802a22
  800e36:	e8 93 14 00 00       	call   8022ce <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W)) < 0){
  800e3b:	83 ec 04             	sub    $0x4,%esp
  800e3e:	6a 07                	push   $0x7
  800e40:	68 00 f0 7f 00       	push   $0x7ff000
  800e45:	6a 00                	push   $0x0
  800e47:	e8 6c fd ff ff       	call   800bb8 <sys_page_alloc>
  800e4c:	83 c4 10             	add    $0x10,%esp
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	79 12                	jns    800e65 <pgfault+0x7d>
		 panic("sys_page_alloc: %e\n", r);
  800e53:	50                   	push   %eax
  800e54:	68 2d 2a 80 00       	push   $0x802a2d
  800e59:	6a 29                	push   $0x29
  800e5b:	68 22 2a 80 00       	push   $0x802a22
  800e60:	e8 69 14 00 00       	call   8022ce <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e65:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800e6b:	83 ec 04             	sub    $0x4,%esp
  800e6e:	68 00 10 00 00       	push   $0x1000
  800e73:	53                   	push   %ebx
  800e74:	68 00 f0 7f 00       	push   $0x7ff000
  800e79:	e8 31 fb ff ff       	call   8009af <memcpy>
	if ((r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  800e7e:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e85:	53                   	push   %ebx
  800e86:	6a 00                	push   $0x0
  800e88:	68 00 f0 7f 00       	push   $0x7ff000
  800e8d:	6a 00                	push   $0x0
  800e8f:	e8 67 fd ff ff       	call   800bfb <sys_page_map>
  800e94:	83 c4 20             	add    $0x20,%esp
  800e97:	85 c0                	test   %eax,%eax
  800e99:	79 12                	jns    800ead <pgfault+0xc5>
        panic("sys_page_map: %e\n", r);
  800e9b:	50                   	push   %eax
  800e9c:	68 41 2a 80 00       	push   $0x802a41
  800ea1:	6a 2e                	push   $0x2e
  800ea3:	68 22 2a 80 00       	push   $0x802a22
  800ea8:	e8 21 14 00 00       	call   8022ce <_panic>
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800ead:	83 ec 08             	sub    $0x8,%esp
  800eb0:	68 00 f0 7f 00       	push   $0x7ff000
  800eb5:	6a 00                	push   $0x0
  800eb7:	e8 81 fd ff ff       	call   800c3d <sys_page_unmap>
  800ebc:	83 c4 10             	add    $0x10,%esp
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	79 12                	jns    800ed5 <pgfault+0xed>
        panic("sys_page_unmap: %e\n", r);
  800ec3:	50                   	push   %eax
  800ec4:	68 53 2a 80 00       	push   $0x802a53
  800ec9:	6a 30                	push   $0x30
  800ecb:	68 22 2a 80 00       	push   $0x802a22
  800ed0:	e8 f9 13 00 00       	call   8022ce <_panic>
	//panic("pgfault not implemented");
}
  800ed5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed8:	c9                   	leave  
  800ed9:	c3                   	ret    

00800eda <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800eda:	55                   	push   %ebp
  800edb:	89 e5                	mov    %esp,%ebp
  800edd:	57                   	push   %edi
  800ede:	56                   	push   %esi
  800edf:	53                   	push   %ebx
  800ee0:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	envid_t cenvid;
    unsigned pn;
    int r;
	set_pgfault_handler(pgfault);
  800ee3:	68 e8 0d 80 00       	push   $0x800de8
  800ee8:	e8 27 14 00 00       	call   802314 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800eed:	b8 07 00 00 00       	mov    $0x7,%eax
  800ef2:	cd 30                	int    $0x30
  800ef4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((cenvid = sys_exofork()) < 0){
  800ef7:	83 c4 10             	add    $0x10,%esp
  800efa:	85 c0                	test   %eax,%eax
  800efc:	79 14                	jns    800f12 <fork+0x38>
		panic("sys_exofork failed");
  800efe:	83 ec 04             	sub    $0x4,%esp
  800f01:	68 67 2a 80 00       	push   $0x802a67
  800f06:	6a 6f                	push   $0x6f
  800f08:	68 22 2a 80 00       	push   $0x802a22
  800f0d:	e8 bc 13 00 00       	call   8022ce <_panic>
  800f12:	89 c7                	mov    %eax,%edi
		return cenvid;
	}
	if(cenvid>0){
  800f14:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f18:	0f 8e 2b 01 00 00    	jle    801049 <fork+0x16f>
  800f1e:	bb 00 08 00 00       	mov    $0x800,%ebx
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
  800f23:	89 d8                	mov    %ebx,%eax
  800f25:	c1 e8 0a             	shr    $0xa,%eax
  800f28:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f2f:	a8 01                	test   $0x1,%al
  800f31:	0f 84 bf 00 00 00    	je     800ff6 <fork+0x11c>
  800f37:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f3e:	a8 01                	test   $0x1,%al
  800f40:	0f 84 b0 00 00 00    	je     800ff6 <fork+0x11c>
  800f46:	89 de                	mov    %ebx,%esi
  800f48:	c1 e6 0c             	shl    $0xc,%esi
{
	int r;

	// LAB 4: Your code here.
	void* vaddr=(void*)(pn*PGSIZE);
	if(uvpt[pn]&PTE_SHARE){
  800f4b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f52:	f6 c4 04             	test   $0x4,%ah
  800f55:	74 29                	je     800f80 <fork+0xa6>
		if((r=sys_page_map(0,vaddr,envid,vaddr,uvpt[pn]&PTE_SYSCALL))<0)return r;
  800f57:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f5e:	83 ec 0c             	sub    $0xc,%esp
  800f61:	25 07 0e 00 00       	and    $0xe07,%eax
  800f66:	50                   	push   %eax
  800f67:	56                   	push   %esi
  800f68:	57                   	push   %edi
  800f69:	56                   	push   %esi
  800f6a:	6a 00                	push   $0x0
  800f6c:	e8 8a fc ff ff       	call   800bfb <sys_page_map>
  800f71:	83 c4 20             	add    $0x20,%esp
  800f74:	85 c0                	test   %eax,%eax
  800f76:	ba 00 00 00 00       	mov    $0x0,%edx
  800f7b:	0f 4f c2             	cmovg  %edx,%eax
  800f7e:	eb 72                	jmp    800ff2 <fork+0x118>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  800f80:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f87:	a8 02                	test   $0x2,%al
  800f89:	75 0c                	jne    800f97 <fork+0xbd>
  800f8b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f92:	f6 c4 08             	test   $0x8,%ah
  800f95:	74 3f                	je     800fd6 <fork+0xfc>
		if ((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  800f97:	83 ec 0c             	sub    $0xc,%esp
  800f9a:	68 05 08 00 00       	push   $0x805
  800f9f:	56                   	push   %esi
  800fa0:	57                   	push   %edi
  800fa1:	56                   	push   %esi
  800fa2:	6a 00                	push   $0x0
  800fa4:	e8 52 fc ff ff       	call   800bfb <sys_page_map>
  800fa9:	83 c4 20             	add    $0x20,%esp
  800fac:	85 c0                	test   %eax,%eax
  800fae:	0f 88 b1 00 00 00    	js     801065 <fork+0x18b>
            return r;
        if ((r = sys_page_map(0, vaddr, 0, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  800fb4:	83 ec 0c             	sub    $0xc,%esp
  800fb7:	68 05 08 00 00       	push   $0x805
  800fbc:	56                   	push   %esi
  800fbd:	6a 00                	push   $0x0
  800fbf:	56                   	push   %esi
  800fc0:	6a 00                	push   $0x0
  800fc2:	e8 34 fc ff ff       	call   800bfb <sys_page_map>
  800fc7:	83 c4 20             	add    $0x20,%esp
  800fca:	85 c0                	test   %eax,%eax
  800fcc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fd1:	0f 4f c1             	cmovg  %ecx,%eax
  800fd4:	eb 1c                	jmp    800ff2 <fork+0x118>
            return r;
	}
	else if((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U)) < 0) {
  800fd6:	83 ec 0c             	sub    $0xc,%esp
  800fd9:	6a 05                	push   $0x5
  800fdb:	56                   	push   %esi
  800fdc:	57                   	push   %edi
  800fdd:	56                   	push   %esi
  800fde:	6a 00                	push   $0x0
  800fe0:	e8 16 fc ff ff       	call   800bfb <sys_page_map>
  800fe5:	83 c4 20             	add    $0x20,%esp
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fef:	0f 4f c1             	cmovg  %ecx,%eax
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
  800ff2:	85 c0                	test   %eax,%eax
  800ff4:	78 6f                	js     801065 <fork+0x18b>
	if ((cenvid = sys_exofork()) < 0){
		panic("sys_exofork failed");
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  800ff6:	83 c3 01             	add    $0x1,%ebx
  800ff9:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800fff:	0f 85 1e ff ff ff    	jne    800f23 <fork+0x49>
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
                    return r;
		}
		if ((r = sys_page_alloc(cenvid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  801005:	83 ec 04             	sub    $0x4,%esp
  801008:	6a 07                	push   $0x7
  80100a:	68 00 f0 bf ee       	push   $0xeebff000
  80100f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801012:	57                   	push   %edi
  801013:	e8 a0 fb ff ff       	call   800bb8 <sys_page_alloc>
  801018:	83 c4 10             	add    $0x10,%esp
  80101b:	85 c0                	test   %eax,%eax
  80101d:	78 46                	js     801065 <fork+0x18b>
            return r;
		extern void _pgfault_upcall(void);
		if ((r = sys_env_set_pgfault_upcall(cenvid, _pgfault_upcall)) < 0)
  80101f:	83 ec 08             	sub    $0x8,%esp
  801022:	68 77 23 80 00       	push   $0x802377
  801027:	57                   	push   %edi
  801028:	e8 d6 fc ff ff       	call   800d03 <sys_env_set_pgfault_upcall>
  80102d:	83 c4 10             	add    $0x10,%esp
  801030:	85 c0                	test   %eax,%eax
  801032:	78 31                	js     801065 <fork+0x18b>
            return r;
		if ((r = sys_env_set_status(cenvid, ENV_RUNNABLE)) < 0)
  801034:	83 ec 08             	sub    $0x8,%esp
  801037:	6a 02                	push   $0x2
  801039:	57                   	push   %edi
  80103a:	e8 40 fc ff ff       	call   800c7f <sys_env_set_status>
  80103f:	83 c4 10             	add    $0x10,%esp
            return r;
        return cenvid;
  801042:	85 c0                	test   %eax,%eax
  801044:	0f 49 c7             	cmovns %edi,%eax
  801047:	eb 1c                	jmp    801065 <fork+0x18b>
	}
	else {
		thisenv = &envs[ENVX(sys_getenvid())];
  801049:	e8 2c fb ff ff       	call   800b7a <sys_getenvid>
  80104e:	25 ff 03 00 00       	and    $0x3ff,%eax
  801053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80105b:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  801060:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//panic("fork not implemented");
	
}
  801065:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801068:	5b                   	pop    %ebx
  801069:	5e                   	pop    %esi
  80106a:	5f                   	pop    %edi
  80106b:	5d                   	pop    %ebp
  80106c:	c3                   	ret    

0080106d <sfork>:

// Challenge!
int
sfork(void)
{
  80106d:	55                   	push   %ebp
  80106e:	89 e5                	mov    %esp,%ebp
  801070:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801073:	68 7a 2a 80 00       	push   $0x802a7a
  801078:	68 8d 00 00 00       	push   $0x8d
  80107d:	68 22 2a 80 00       	push   $0x802a22
  801082:	e8 47 12 00 00       	call   8022ce <_panic>

00801087 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801087:	55                   	push   %ebp
  801088:	89 e5                	mov    %esp,%ebp
  80108a:	56                   	push   %esi
  80108b:	53                   	push   %ebx
  80108c:	8b 75 08             	mov    0x8(%ebp),%esi
  80108f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801092:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801095:	85 c0                	test   %eax,%eax
  801097:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80109c:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  80109f:	83 ec 0c             	sub    $0xc,%esp
  8010a2:	50                   	push   %eax
  8010a3:	e8 c0 fc ff ff       	call   800d68 <sys_ipc_recv>
  8010a8:	83 c4 10             	add    $0x10,%esp
  8010ab:	85 c0                	test   %eax,%eax
  8010ad:	79 16                	jns    8010c5 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  8010af:	85 f6                	test   %esi,%esi
  8010b1:	74 06                	je     8010b9 <ipc_recv+0x32>
            *from_env_store = 0;
  8010b3:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  8010b9:	85 db                	test   %ebx,%ebx
  8010bb:	74 2c                	je     8010e9 <ipc_recv+0x62>
            *perm_store = 0;
  8010bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010c3:	eb 24                	jmp    8010e9 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  8010c5:	85 f6                	test   %esi,%esi
  8010c7:	74 0a                	je     8010d3 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  8010c9:	a1 08 40 80 00       	mov    0x804008,%eax
  8010ce:	8b 40 74             	mov    0x74(%eax),%eax
  8010d1:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  8010d3:	85 db                	test   %ebx,%ebx
  8010d5:	74 0a                	je     8010e1 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  8010d7:	a1 08 40 80 00       	mov    0x804008,%eax
  8010dc:	8b 40 78             	mov    0x78(%eax),%eax
  8010df:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  8010e1:	a1 08 40 80 00       	mov    0x804008,%eax
  8010e6:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  8010e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8010ec:	5b                   	pop    %ebx
  8010ed:	5e                   	pop    %esi
  8010ee:	5d                   	pop    %ebp
  8010ef:	c3                   	ret    

008010f0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010f0:	55                   	push   %ebp
  8010f1:	89 e5                	mov    %esp,%ebp
  8010f3:	57                   	push   %edi
  8010f4:	56                   	push   %esi
  8010f5:	53                   	push   %ebx
  8010f6:	83 ec 0c             	sub    $0xc,%esp
  8010f9:	8b 7d 08             	mov    0x8(%ebp),%edi
  8010fc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010ff:	8b 45 10             	mov    0x10(%ebp),%eax
  801102:	85 c0                	test   %eax,%eax
  801104:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801109:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80110c:	eb 1c                	jmp    80112a <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  80110e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801111:	74 12                	je     801125 <ipc_send+0x35>
  801113:	50                   	push   %eax
  801114:	68 90 2a 80 00       	push   $0x802a90
  801119:	6a 3b                	push   $0x3b
  80111b:	68 a6 2a 80 00       	push   $0x802aa6
  801120:	e8 a9 11 00 00       	call   8022ce <_panic>
		sys_yield();
  801125:	e8 6f fa ff ff       	call   800b99 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80112a:	ff 75 14             	pushl  0x14(%ebp)
  80112d:	53                   	push   %ebx
  80112e:	56                   	push   %esi
  80112f:	57                   	push   %edi
  801130:	e8 10 fc ff ff       	call   800d45 <sys_ipc_try_send>
  801135:	83 c4 10             	add    $0x10,%esp
  801138:	85 c0                	test   %eax,%eax
  80113a:	78 d2                	js     80110e <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  80113c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80113f:	5b                   	pop    %ebx
  801140:	5e                   	pop    %esi
  801141:	5f                   	pop    %edi
  801142:	5d                   	pop    %ebp
  801143:	c3                   	ret    

00801144 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801144:	55                   	push   %ebp
  801145:	89 e5                	mov    %esp,%ebp
  801147:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80114a:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80114f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801152:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801158:	8b 52 50             	mov    0x50(%edx),%edx
  80115b:	39 ca                	cmp    %ecx,%edx
  80115d:	75 0d                	jne    80116c <ipc_find_env+0x28>
			return envs[i].env_id;
  80115f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801162:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801167:	8b 40 48             	mov    0x48(%eax),%eax
  80116a:	eb 0f                	jmp    80117b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80116c:	83 c0 01             	add    $0x1,%eax
  80116f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801174:	75 d9                	jne    80114f <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801176:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80117b:	5d                   	pop    %ebp
  80117c:	c3                   	ret    

0080117d <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801180:	8b 45 08             	mov    0x8(%ebp),%eax
  801183:	05 00 00 00 30       	add    $0x30000000,%eax
  801188:	c1 e8 0c             	shr    $0xc,%eax
}
  80118b:	5d                   	pop    %ebp
  80118c:	c3                   	ret    

0080118d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80118d:	55                   	push   %ebp
  80118e:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801190:	8b 45 08             	mov    0x8(%ebp),%eax
  801193:	05 00 00 00 30       	add    $0x30000000,%eax
  801198:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80119d:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8011a4:	55                   	push   %ebp
  8011a5:	89 e5                	mov    %esp,%ebp
  8011a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011aa:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8011af:	89 c2                	mov    %eax,%edx
  8011b1:	c1 ea 16             	shr    $0x16,%edx
  8011b4:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8011bb:	f6 c2 01             	test   $0x1,%dl
  8011be:	74 11                	je     8011d1 <fd_alloc+0x2d>
  8011c0:	89 c2                	mov    %eax,%edx
  8011c2:	c1 ea 0c             	shr    $0xc,%edx
  8011c5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8011cc:	f6 c2 01             	test   $0x1,%dl
  8011cf:	75 09                	jne    8011da <fd_alloc+0x36>
			*fd_store = fd;
  8011d1:	89 01                	mov    %eax,(%ecx)
			return 0;
  8011d3:	b8 00 00 00 00       	mov    $0x0,%eax
  8011d8:	eb 17                	jmp    8011f1 <fd_alloc+0x4d>
  8011da:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8011df:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8011e4:	75 c9                	jne    8011af <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8011e6:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8011ec:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8011f1:	5d                   	pop    %ebp
  8011f2:	c3                   	ret    

008011f3 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8011f3:	55                   	push   %ebp
  8011f4:	89 e5                	mov    %esp,%ebp
  8011f6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8011f9:	83 f8 1f             	cmp    $0x1f,%eax
  8011fc:	77 36                	ja     801234 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8011fe:	c1 e0 0c             	shl    $0xc,%eax
  801201:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801206:	89 c2                	mov    %eax,%edx
  801208:	c1 ea 16             	shr    $0x16,%edx
  80120b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801212:	f6 c2 01             	test   $0x1,%dl
  801215:	74 24                	je     80123b <fd_lookup+0x48>
  801217:	89 c2                	mov    %eax,%edx
  801219:	c1 ea 0c             	shr    $0xc,%edx
  80121c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801223:	f6 c2 01             	test   $0x1,%dl
  801226:	74 1a                	je     801242 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801228:	8b 55 0c             	mov    0xc(%ebp),%edx
  80122b:	89 02                	mov    %eax,(%edx)
	return 0;
  80122d:	b8 00 00 00 00       	mov    $0x0,%eax
  801232:	eb 13                	jmp    801247 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801234:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801239:	eb 0c                	jmp    801247 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80123b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801240:	eb 05                	jmp    801247 <fd_lookup+0x54>
  801242:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    

00801249 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	83 ec 08             	sub    $0x8,%esp
  80124f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801252:	ba 2c 2b 80 00       	mov    $0x802b2c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801257:	eb 13                	jmp    80126c <dev_lookup+0x23>
  801259:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80125c:	39 08                	cmp    %ecx,(%eax)
  80125e:	75 0c                	jne    80126c <dev_lookup+0x23>
			*dev = devtab[i];
  801260:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801263:	89 01                	mov    %eax,(%ecx)
			return 0;
  801265:	b8 00 00 00 00       	mov    $0x0,%eax
  80126a:	eb 2e                	jmp    80129a <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80126c:	8b 02                	mov    (%edx),%eax
  80126e:	85 c0                	test   %eax,%eax
  801270:	75 e7                	jne    801259 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801272:	a1 08 40 80 00       	mov    0x804008,%eax
  801277:	8b 40 48             	mov    0x48(%eax),%eax
  80127a:	83 ec 04             	sub    $0x4,%esp
  80127d:	51                   	push   %ecx
  80127e:	50                   	push   %eax
  80127f:	68 b0 2a 80 00       	push   $0x802ab0
  801284:	e8 28 ef ff ff       	call   8001b1 <cprintf>
	*dev = 0;
  801289:	8b 45 0c             	mov    0xc(%ebp),%eax
  80128c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801292:	83 c4 10             	add    $0x10,%esp
  801295:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80129a:	c9                   	leave  
  80129b:	c3                   	ret    

0080129c <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	56                   	push   %esi
  8012a0:	53                   	push   %ebx
  8012a1:	83 ec 10             	sub    $0x10,%esp
  8012a4:	8b 75 08             	mov    0x8(%ebp),%esi
  8012a7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8012aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012ad:	50                   	push   %eax
  8012ae:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8012b4:	c1 e8 0c             	shr    $0xc,%eax
  8012b7:	50                   	push   %eax
  8012b8:	e8 36 ff ff ff       	call   8011f3 <fd_lookup>
  8012bd:	83 c4 08             	add    $0x8,%esp
  8012c0:	85 c0                	test   %eax,%eax
  8012c2:	78 05                	js     8012c9 <fd_close+0x2d>
	    || fd != fd2)
  8012c4:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8012c7:	74 0c                	je     8012d5 <fd_close+0x39>
		return (must_exist ? r : 0);
  8012c9:	84 db                	test   %bl,%bl
  8012cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d0:	0f 44 c2             	cmove  %edx,%eax
  8012d3:	eb 41                	jmp    801316 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8012d5:	83 ec 08             	sub    $0x8,%esp
  8012d8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012db:	50                   	push   %eax
  8012dc:	ff 36                	pushl  (%esi)
  8012de:	e8 66 ff ff ff       	call   801249 <dev_lookup>
  8012e3:	89 c3                	mov    %eax,%ebx
  8012e5:	83 c4 10             	add    $0x10,%esp
  8012e8:	85 c0                	test   %eax,%eax
  8012ea:	78 1a                	js     801306 <fd_close+0x6a>
		if (dev->dev_close)
  8012ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012ef:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8012f2:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	74 0b                	je     801306 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8012fb:	83 ec 0c             	sub    $0xc,%esp
  8012fe:	56                   	push   %esi
  8012ff:	ff d0                	call   *%eax
  801301:	89 c3                	mov    %eax,%ebx
  801303:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801306:	83 ec 08             	sub    $0x8,%esp
  801309:	56                   	push   %esi
  80130a:	6a 00                	push   $0x0
  80130c:	e8 2c f9 ff ff       	call   800c3d <sys_page_unmap>
	return r;
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	89 d8                	mov    %ebx,%eax
}
  801316:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801319:	5b                   	pop    %ebx
  80131a:	5e                   	pop    %esi
  80131b:	5d                   	pop    %ebp
  80131c:	c3                   	ret    

0080131d <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80131d:	55                   	push   %ebp
  80131e:	89 e5                	mov    %esp,%ebp
  801320:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801323:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801326:	50                   	push   %eax
  801327:	ff 75 08             	pushl  0x8(%ebp)
  80132a:	e8 c4 fe ff ff       	call   8011f3 <fd_lookup>
  80132f:	83 c4 08             	add    $0x8,%esp
  801332:	85 c0                	test   %eax,%eax
  801334:	78 10                	js     801346 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801336:	83 ec 08             	sub    $0x8,%esp
  801339:	6a 01                	push   $0x1
  80133b:	ff 75 f4             	pushl  -0xc(%ebp)
  80133e:	e8 59 ff ff ff       	call   80129c <fd_close>
  801343:	83 c4 10             	add    $0x10,%esp
}
  801346:	c9                   	leave  
  801347:	c3                   	ret    

00801348 <close_all>:

void
close_all(void)
{
  801348:	55                   	push   %ebp
  801349:	89 e5                	mov    %esp,%ebp
  80134b:	53                   	push   %ebx
  80134c:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80134f:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801354:	83 ec 0c             	sub    $0xc,%esp
  801357:	53                   	push   %ebx
  801358:	e8 c0 ff ff ff       	call   80131d <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80135d:	83 c3 01             	add    $0x1,%ebx
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	83 fb 20             	cmp    $0x20,%ebx
  801366:	75 ec                	jne    801354 <close_all+0xc>
		close(i);
}
  801368:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80136b:	c9                   	leave  
  80136c:	c3                   	ret    

0080136d <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80136d:	55                   	push   %ebp
  80136e:	89 e5                	mov    %esp,%ebp
  801370:	57                   	push   %edi
  801371:	56                   	push   %esi
  801372:	53                   	push   %ebx
  801373:	83 ec 2c             	sub    $0x2c,%esp
  801376:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801379:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80137c:	50                   	push   %eax
  80137d:	ff 75 08             	pushl  0x8(%ebp)
  801380:	e8 6e fe ff ff       	call   8011f3 <fd_lookup>
  801385:	83 c4 08             	add    $0x8,%esp
  801388:	85 c0                	test   %eax,%eax
  80138a:	0f 88 c1 00 00 00    	js     801451 <dup+0xe4>
		return r;
	close(newfdnum);
  801390:	83 ec 0c             	sub    $0xc,%esp
  801393:	56                   	push   %esi
  801394:	e8 84 ff ff ff       	call   80131d <close>

	newfd = INDEX2FD(newfdnum);
  801399:	89 f3                	mov    %esi,%ebx
  80139b:	c1 e3 0c             	shl    $0xc,%ebx
  80139e:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8013a4:	83 c4 04             	add    $0x4,%esp
  8013a7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8013aa:	e8 de fd ff ff       	call   80118d <fd2data>
  8013af:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8013b1:	89 1c 24             	mov    %ebx,(%esp)
  8013b4:	e8 d4 fd ff ff       	call   80118d <fd2data>
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8013bf:	89 f8                	mov    %edi,%eax
  8013c1:	c1 e8 16             	shr    $0x16,%eax
  8013c4:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8013cb:	a8 01                	test   $0x1,%al
  8013cd:	74 37                	je     801406 <dup+0x99>
  8013cf:	89 f8                	mov    %edi,%eax
  8013d1:	c1 e8 0c             	shr    $0xc,%eax
  8013d4:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8013db:	f6 c2 01             	test   $0x1,%dl
  8013de:	74 26                	je     801406 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8013e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8013e7:	83 ec 0c             	sub    $0xc,%esp
  8013ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8013ef:	50                   	push   %eax
  8013f0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8013f3:	6a 00                	push   $0x0
  8013f5:	57                   	push   %edi
  8013f6:	6a 00                	push   $0x0
  8013f8:	e8 fe f7 ff ff       	call   800bfb <sys_page_map>
  8013fd:	89 c7                	mov    %eax,%edi
  8013ff:	83 c4 20             	add    $0x20,%esp
  801402:	85 c0                	test   %eax,%eax
  801404:	78 2e                	js     801434 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801406:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801409:	89 d0                	mov    %edx,%eax
  80140b:	c1 e8 0c             	shr    $0xc,%eax
  80140e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801415:	83 ec 0c             	sub    $0xc,%esp
  801418:	25 07 0e 00 00       	and    $0xe07,%eax
  80141d:	50                   	push   %eax
  80141e:	53                   	push   %ebx
  80141f:	6a 00                	push   $0x0
  801421:	52                   	push   %edx
  801422:	6a 00                	push   $0x0
  801424:	e8 d2 f7 ff ff       	call   800bfb <sys_page_map>
  801429:	89 c7                	mov    %eax,%edi
  80142b:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80142e:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801430:	85 ff                	test   %edi,%edi
  801432:	79 1d                	jns    801451 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801434:	83 ec 08             	sub    $0x8,%esp
  801437:	53                   	push   %ebx
  801438:	6a 00                	push   $0x0
  80143a:	e8 fe f7 ff ff       	call   800c3d <sys_page_unmap>
	sys_page_unmap(0, nva);
  80143f:	83 c4 08             	add    $0x8,%esp
  801442:	ff 75 d4             	pushl  -0x2c(%ebp)
  801445:	6a 00                	push   $0x0
  801447:	e8 f1 f7 ff ff       	call   800c3d <sys_page_unmap>
	return r;
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	89 f8                	mov    %edi,%eax
}
  801451:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801454:	5b                   	pop    %ebx
  801455:	5e                   	pop    %esi
  801456:	5f                   	pop    %edi
  801457:	5d                   	pop    %ebp
  801458:	c3                   	ret    

00801459 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801459:	55                   	push   %ebp
  80145a:	89 e5                	mov    %esp,%ebp
  80145c:	53                   	push   %ebx
  80145d:	83 ec 14             	sub    $0x14,%esp
  801460:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801463:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801466:	50                   	push   %eax
  801467:	53                   	push   %ebx
  801468:	e8 86 fd ff ff       	call   8011f3 <fd_lookup>
  80146d:	83 c4 08             	add    $0x8,%esp
  801470:	89 c2                	mov    %eax,%edx
  801472:	85 c0                	test   %eax,%eax
  801474:	78 6d                	js     8014e3 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801476:	83 ec 08             	sub    $0x8,%esp
  801479:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147c:	50                   	push   %eax
  80147d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801480:	ff 30                	pushl  (%eax)
  801482:	e8 c2 fd ff ff       	call   801249 <dev_lookup>
  801487:	83 c4 10             	add    $0x10,%esp
  80148a:	85 c0                	test   %eax,%eax
  80148c:	78 4c                	js     8014da <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80148e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801491:	8b 42 08             	mov    0x8(%edx),%eax
  801494:	83 e0 03             	and    $0x3,%eax
  801497:	83 f8 01             	cmp    $0x1,%eax
  80149a:	75 21                	jne    8014bd <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80149c:	a1 08 40 80 00       	mov    0x804008,%eax
  8014a1:	8b 40 48             	mov    0x48(%eax),%eax
  8014a4:	83 ec 04             	sub    $0x4,%esp
  8014a7:	53                   	push   %ebx
  8014a8:	50                   	push   %eax
  8014a9:	68 f1 2a 80 00       	push   $0x802af1
  8014ae:	e8 fe ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8014bb:	eb 26                	jmp    8014e3 <read+0x8a>
	}
	if (!dev->dev_read)
  8014bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c0:	8b 40 08             	mov    0x8(%eax),%eax
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	74 17                	je     8014de <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8014c7:	83 ec 04             	sub    $0x4,%esp
  8014ca:	ff 75 10             	pushl  0x10(%ebp)
  8014cd:	ff 75 0c             	pushl  0xc(%ebp)
  8014d0:	52                   	push   %edx
  8014d1:	ff d0                	call   *%eax
  8014d3:	89 c2                	mov    %eax,%edx
  8014d5:	83 c4 10             	add    $0x10,%esp
  8014d8:	eb 09                	jmp    8014e3 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014da:	89 c2                	mov    %eax,%edx
  8014dc:	eb 05                	jmp    8014e3 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8014de:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8014e3:	89 d0                	mov    %edx,%eax
  8014e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e8:	c9                   	leave  
  8014e9:	c3                   	ret    

008014ea <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8014ea:	55                   	push   %ebp
  8014eb:	89 e5                	mov    %esp,%ebp
  8014ed:	57                   	push   %edi
  8014ee:	56                   	push   %esi
  8014ef:	53                   	push   %ebx
  8014f0:	83 ec 0c             	sub    $0xc,%esp
  8014f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8014f6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8014f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8014fe:	eb 21                	jmp    801521 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801500:	83 ec 04             	sub    $0x4,%esp
  801503:	89 f0                	mov    %esi,%eax
  801505:	29 d8                	sub    %ebx,%eax
  801507:	50                   	push   %eax
  801508:	89 d8                	mov    %ebx,%eax
  80150a:	03 45 0c             	add    0xc(%ebp),%eax
  80150d:	50                   	push   %eax
  80150e:	57                   	push   %edi
  80150f:	e8 45 ff ff ff       	call   801459 <read>
		if (m < 0)
  801514:	83 c4 10             	add    $0x10,%esp
  801517:	85 c0                	test   %eax,%eax
  801519:	78 10                	js     80152b <readn+0x41>
			return m;
		if (m == 0)
  80151b:	85 c0                	test   %eax,%eax
  80151d:	74 0a                	je     801529 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80151f:	01 c3                	add    %eax,%ebx
  801521:	39 f3                	cmp    %esi,%ebx
  801523:	72 db                	jb     801500 <readn+0x16>
  801525:	89 d8                	mov    %ebx,%eax
  801527:	eb 02                	jmp    80152b <readn+0x41>
  801529:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80152b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80152e:	5b                   	pop    %ebx
  80152f:	5e                   	pop    %esi
  801530:	5f                   	pop    %edi
  801531:	5d                   	pop    %ebp
  801532:	c3                   	ret    

00801533 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	53                   	push   %ebx
  801537:	83 ec 14             	sub    $0x14,%esp
  80153a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801540:	50                   	push   %eax
  801541:	53                   	push   %ebx
  801542:	e8 ac fc ff ff       	call   8011f3 <fd_lookup>
  801547:	83 c4 08             	add    $0x8,%esp
  80154a:	89 c2                	mov    %eax,%edx
  80154c:	85 c0                	test   %eax,%eax
  80154e:	78 68                	js     8015b8 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801550:	83 ec 08             	sub    $0x8,%esp
  801553:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801556:	50                   	push   %eax
  801557:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155a:	ff 30                	pushl  (%eax)
  80155c:	e8 e8 fc ff ff       	call   801249 <dev_lookup>
  801561:	83 c4 10             	add    $0x10,%esp
  801564:	85 c0                	test   %eax,%eax
  801566:	78 47                	js     8015af <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801568:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80156b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80156f:	75 21                	jne    801592 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801571:	a1 08 40 80 00       	mov    0x804008,%eax
  801576:	8b 40 48             	mov    0x48(%eax),%eax
  801579:	83 ec 04             	sub    $0x4,%esp
  80157c:	53                   	push   %ebx
  80157d:	50                   	push   %eax
  80157e:	68 0d 2b 80 00       	push   $0x802b0d
  801583:	e8 29 ec ff ff       	call   8001b1 <cprintf>
		return -E_INVAL;
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801590:	eb 26                	jmp    8015b8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801592:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801595:	8b 52 0c             	mov    0xc(%edx),%edx
  801598:	85 d2                	test   %edx,%edx
  80159a:	74 17                	je     8015b3 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80159c:	83 ec 04             	sub    $0x4,%esp
  80159f:	ff 75 10             	pushl  0x10(%ebp)
  8015a2:	ff 75 0c             	pushl  0xc(%ebp)
  8015a5:	50                   	push   %eax
  8015a6:	ff d2                	call   *%edx
  8015a8:	89 c2                	mov    %eax,%edx
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	eb 09                	jmp    8015b8 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015af:	89 c2                	mov    %eax,%edx
  8015b1:	eb 05                	jmp    8015b8 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8015b3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8015b8:	89 d0                	mov    %edx,%eax
  8015ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015bd:	c9                   	leave  
  8015be:	c3                   	ret    

008015bf <seek>:

int
seek(int fdnum, off_t offset)
{
  8015bf:	55                   	push   %ebp
  8015c0:	89 e5                	mov    %esp,%ebp
  8015c2:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015c5:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8015c8:	50                   	push   %eax
  8015c9:	ff 75 08             	pushl  0x8(%ebp)
  8015cc:	e8 22 fc ff ff       	call   8011f3 <fd_lookup>
  8015d1:	83 c4 08             	add    $0x8,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 0e                	js     8015e6 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8015d8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8015db:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015de:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8015e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8015e6:	c9                   	leave  
  8015e7:	c3                   	ret    

008015e8 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8015e8:	55                   	push   %ebp
  8015e9:	89 e5                	mov    %esp,%ebp
  8015eb:	53                   	push   %ebx
  8015ec:	83 ec 14             	sub    $0x14,%esp
  8015ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015f5:	50                   	push   %eax
  8015f6:	53                   	push   %ebx
  8015f7:	e8 f7 fb ff ff       	call   8011f3 <fd_lookup>
  8015fc:	83 c4 08             	add    $0x8,%esp
  8015ff:	89 c2                	mov    %eax,%edx
  801601:	85 c0                	test   %eax,%eax
  801603:	78 65                	js     80166a <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801605:	83 ec 08             	sub    $0x8,%esp
  801608:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160b:	50                   	push   %eax
  80160c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80160f:	ff 30                	pushl  (%eax)
  801611:	e8 33 fc ff ff       	call   801249 <dev_lookup>
  801616:	83 c4 10             	add    $0x10,%esp
  801619:	85 c0                	test   %eax,%eax
  80161b:	78 44                	js     801661 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80161d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801620:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801624:	75 21                	jne    801647 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801626:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80162b:	8b 40 48             	mov    0x48(%eax),%eax
  80162e:	83 ec 04             	sub    $0x4,%esp
  801631:	53                   	push   %ebx
  801632:	50                   	push   %eax
  801633:	68 d0 2a 80 00       	push   $0x802ad0
  801638:	e8 74 eb ff ff       	call   8001b1 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80163d:	83 c4 10             	add    $0x10,%esp
  801640:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801645:	eb 23                	jmp    80166a <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801647:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80164a:	8b 52 18             	mov    0x18(%edx),%edx
  80164d:	85 d2                	test   %edx,%edx
  80164f:	74 14                	je     801665 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801651:	83 ec 08             	sub    $0x8,%esp
  801654:	ff 75 0c             	pushl  0xc(%ebp)
  801657:	50                   	push   %eax
  801658:	ff d2                	call   *%edx
  80165a:	89 c2                	mov    %eax,%edx
  80165c:	83 c4 10             	add    $0x10,%esp
  80165f:	eb 09                	jmp    80166a <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801661:	89 c2                	mov    %eax,%edx
  801663:	eb 05                	jmp    80166a <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801665:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80166a:	89 d0                	mov    %edx,%eax
  80166c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80166f:	c9                   	leave  
  801670:	c3                   	ret    

00801671 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801671:	55                   	push   %ebp
  801672:	89 e5                	mov    %esp,%ebp
  801674:	53                   	push   %ebx
  801675:	83 ec 14             	sub    $0x14,%esp
  801678:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80167b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80167e:	50                   	push   %eax
  80167f:	ff 75 08             	pushl  0x8(%ebp)
  801682:	e8 6c fb ff ff       	call   8011f3 <fd_lookup>
  801687:	83 c4 08             	add    $0x8,%esp
  80168a:	89 c2                	mov    %eax,%edx
  80168c:	85 c0                	test   %eax,%eax
  80168e:	78 58                	js     8016e8 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801690:	83 ec 08             	sub    $0x8,%esp
  801693:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801696:	50                   	push   %eax
  801697:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80169a:	ff 30                	pushl  (%eax)
  80169c:	e8 a8 fb ff ff       	call   801249 <dev_lookup>
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	78 37                	js     8016df <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8016a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016ab:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8016af:	74 32                	je     8016e3 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8016b1:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8016b4:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8016bb:	00 00 00 
	stat->st_isdir = 0;
  8016be:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8016c5:	00 00 00 
	stat->st_dev = dev;
  8016c8:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8016ce:	83 ec 08             	sub    $0x8,%esp
  8016d1:	53                   	push   %ebx
  8016d2:	ff 75 f0             	pushl  -0x10(%ebp)
  8016d5:	ff 50 14             	call   *0x14(%eax)
  8016d8:	89 c2                	mov    %eax,%edx
  8016da:	83 c4 10             	add    $0x10,%esp
  8016dd:	eb 09                	jmp    8016e8 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016df:	89 c2                	mov    %eax,%edx
  8016e1:	eb 05                	jmp    8016e8 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8016e3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8016e8:	89 d0                	mov    %edx,%eax
  8016ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ed:	c9                   	leave  
  8016ee:	c3                   	ret    

008016ef <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8016ef:	55                   	push   %ebp
  8016f0:	89 e5                	mov    %esp,%ebp
  8016f2:	56                   	push   %esi
  8016f3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8016f4:	83 ec 08             	sub    $0x8,%esp
  8016f7:	6a 00                	push   $0x0
  8016f9:	ff 75 08             	pushl  0x8(%ebp)
  8016fc:	e8 e3 01 00 00       	call   8018e4 <open>
  801701:	89 c3                	mov    %eax,%ebx
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	85 c0                	test   %eax,%eax
  801708:	78 1b                	js     801725 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80170a:	83 ec 08             	sub    $0x8,%esp
  80170d:	ff 75 0c             	pushl  0xc(%ebp)
  801710:	50                   	push   %eax
  801711:	e8 5b ff ff ff       	call   801671 <fstat>
  801716:	89 c6                	mov    %eax,%esi
	close(fd);
  801718:	89 1c 24             	mov    %ebx,(%esp)
  80171b:	e8 fd fb ff ff       	call   80131d <close>
	return r;
  801720:	83 c4 10             	add    $0x10,%esp
  801723:	89 f0                	mov    %esi,%eax
}
  801725:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801728:	5b                   	pop    %ebx
  801729:	5e                   	pop    %esi
  80172a:	5d                   	pop    %ebp
  80172b:	c3                   	ret    

0080172c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80172c:	55                   	push   %ebp
  80172d:	89 e5                	mov    %esp,%ebp
  80172f:	56                   	push   %esi
  801730:	53                   	push   %ebx
  801731:	89 c6                	mov    %eax,%esi
  801733:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801735:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80173c:	75 12                	jne    801750 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80173e:	83 ec 0c             	sub    $0xc,%esp
  801741:	6a 01                	push   $0x1
  801743:	e8 fc f9 ff ff       	call   801144 <ipc_find_env>
  801748:	a3 00 40 80 00       	mov    %eax,0x804000
  80174d:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801750:	6a 07                	push   $0x7
  801752:	68 00 50 80 00       	push   $0x805000
  801757:	56                   	push   %esi
  801758:	ff 35 00 40 80 00    	pushl  0x804000
  80175e:	e8 8d f9 ff ff       	call   8010f0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801763:	83 c4 0c             	add    $0xc,%esp
  801766:	6a 00                	push   $0x0
  801768:	53                   	push   %ebx
  801769:	6a 00                	push   $0x0
  80176b:	e8 17 f9 ff ff       	call   801087 <ipc_recv>
}
  801770:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801773:	5b                   	pop    %ebx
  801774:	5e                   	pop    %esi
  801775:	5d                   	pop    %ebp
  801776:	c3                   	ret    

00801777 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801777:	55                   	push   %ebp
  801778:	89 e5                	mov    %esp,%ebp
  80177a:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80177d:	8b 45 08             	mov    0x8(%ebp),%eax
  801780:	8b 40 0c             	mov    0xc(%eax),%eax
  801783:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801788:	8b 45 0c             	mov    0xc(%ebp),%eax
  80178b:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801790:	ba 00 00 00 00       	mov    $0x0,%edx
  801795:	b8 02 00 00 00       	mov    $0x2,%eax
  80179a:	e8 8d ff ff ff       	call   80172c <fsipc>
}
  80179f:	c9                   	leave  
  8017a0:	c3                   	ret    

008017a1 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8017a1:	55                   	push   %ebp
  8017a2:	89 e5                	mov    %esp,%ebp
  8017a4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8017a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8017aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8017ad:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8017b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8017b7:	b8 06 00 00 00       	mov    $0x6,%eax
  8017bc:	e8 6b ff ff ff       	call   80172c <fsipc>
}
  8017c1:	c9                   	leave  
  8017c2:	c3                   	ret    

008017c3 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8017c3:	55                   	push   %ebp
  8017c4:	89 e5                	mov    %esp,%ebp
  8017c6:	53                   	push   %ebx
  8017c7:	83 ec 04             	sub    $0x4,%esp
  8017ca:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8017cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d0:	8b 40 0c             	mov    0xc(%eax),%eax
  8017d3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8017d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8017dd:	b8 05 00 00 00       	mov    $0x5,%eax
  8017e2:	e8 45 ff ff ff       	call   80172c <fsipc>
  8017e7:	85 c0                	test   %eax,%eax
  8017e9:	78 2c                	js     801817 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8017eb:	83 ec 08             	sub    $0x8,%esp
  8017ee:	68 00 50 80 00       	push   $0x805000
  8017f3:	53                   	push   %ebx
  8017f4:	e8 bc ef ff ff       	call   8007b5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8017f9:	a1 80 50 80 00       	mov    0x805080,%eax
  8017fe:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801804:	a1 84 50 80 00       	mov    0x805084,%eax
  801809:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80180f:	83 c4 10             	add    $0x10,%esp
  801812:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801817:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80181a:	c9                   	leave  
  80181b:	c3                   	ret    

0080181c <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80181c:	55                   	push   %ebp
  80181d:	89 e5                	mov    %esp,%ebp
  80181f:	83 ec 0c             	sub    $0xc,%esp
  801822:	8b 45 10             	mov    0x10(%ebp),%eax
  801825:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80182a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80182f:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801832:	8b 55 08             	mov    0x8(%ebp),%edx
  801835:	8b 52 0c             	mov    0xc(%edx),%edx
  801838:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80183e:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801843:	50                   	push   %eax
  801844:	ff 75 0c             	pushl  0xc(%ebp)
  801847:	68 08 50 80 00       	push   $0x805008
  80184c:	e8 f6 f0 ff ff       	call   800947 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801851:	ba 00 00 00 00       	mov    $0x0,%edx
  801856:	b8 04 00 00 00       	mov    $0x4,%eax
  80185b:	e8 cc fe ff ff       	call   80172c <fsipc>
	//panic("devfile_write not implemented");
}
  801860:	c9                   	leave  
  801861:	c3                   	ret    

00801862 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801862:	55                   	push   %ebp
  801863:	89 e5                	mov    %esp,%ebp
  801865:	56                   	push   %esi
  801866:	53                   	push   %ebx
  801867:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80186a:	8b 45 08             	mov    0x8(%ebp),%eax
  80186d:	8b 40 0c             	mov    0xc(%eax),%eax
  801870:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801875:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80187b:	ba 00 00 00 00       	mov    $0x0,%edx
  801880:	b8 03 00 00 00       	mov    $0x3,%eax
  801885:	e8 a2 fe ff ff       	call   80172c <fsipc>
  80188a:	89 c3                	mov    %eax,%ebx
  80188c:	85 c0                	test   %eax,%eax
  80188e:	78 4b                	js     8018db <devfile_read+0x79>
		return r;
	assert(r <= n);
  801890:	39 c6                	cmp    %eax,%esi
  801892:	73 16                	jae    8018aa <devfile_read+0x48>
  801894:	68 40 2b 80 00       	push   $0x802b40
  801899:	68 47 2b 80 00       	push   $0x802b47
  80189e:	6a 7c                	push   $0x7c
  8018a0:	68 5c 2b 80 00       	push   $0x802b5c
  8018a5:	e8 24 0a 00 00       	call   8022ce <_panic>
	assert(r <= PGSIZE);
  8018aa:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8018af:	7e 16                	jle    8018c7 <devfile_read+0x65>
  8018b1:	68 67 2b 80 00       	push   $0x802b67
  8018b6:	68 47 2b 80 00       	push   $0x802b47
  8018bb:	6a 7d                	push   $0x7d
  8018bd:	68 5c 2b 80 00       	push   $0x802b5c
  8018c2:	e8 07 0a 00 00       	call   8022ce <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8018c7:	83 ec 04             	sub    $0x4,%esp
  8018ca:	50                   	push   %eax
  8018cb:	68 00 50 80 00       	push   $0x805000
  8018d0:	ff 75 0c             	pushl  0xc(%ebp)
  8018d3:	e8 6f f0 ff ff       	call   800947 <memmove>
	return r;
  8018d8:	83 c4 10             	add    $0x10,%esp
}
  8018db:	89 d8                	mov    %ebx,%eax
  8018dd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018e0:	5b                   	pop    %ebx
  8018e1:	5e                   	pop    %esi
  8018e2:	5d                   	pop    %ebp
  8018e3:	c3                   	ret    

008018e4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8018e4:	55                   	push   %ebp
  8018e5:	89 e5                	mov    %esp,%ebp
  8018e7:	53                   	push   %ebx
  8018e8:	83 ec 20             	sub    $0x20,%esp
  8018eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8018ee:	53                   	push   %ebx
  8018ef:	e8 88 ee ff ff       	call   80077c <strlen>
  8018f4:	83 c4 10             	add    $0x10,%esp
  8018f7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8018fc:	7f 67                	jg     801965 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8018fe:	83 ec 0c             	sub    $0xc,%esp
  801901:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801904:	50                   	push   %eax
  801905:	e8 9a f8 ff ff       	call   8011a4 <fd_alloc>
  80190a:	83 c4 10             	add    $0x10,%esp
		return r;
  80190d:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80190f:	85 c0                	test   %eax,%eax
  801911:	78 57                	js     80196a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801913:	83 ec 08             	sub    $0x8,%esp
  801916:	53                   	push   %ebx
  801917:	68 00 50 80 00       	push   $0x805000
  80191c:	e8 94 ee ff ff       	call   8007b5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801921:	8b 45 0c             	mov    0xc(%ebp),%eax
  801924:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801929:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80192c:	b8 01 00 00 00       	mov    $0x1,%eax
  801931:	e8 f6 fd ff ff       	call   80172c <fsipc>
  801936:	89 c3                	mov    %eax,%ebx
  801938:	83 c4 10             	add    $0x10,%esp
  80193b:	85 c0                	test   %eax,%eax
  80193d:	79 14                	jns    801953 <open+0x6f>
		fd_close(fd, 0);
  80193f:	83 ec 08             	sub    $0x8,%esp
  801942:	6a 00                	push   $0x0
  801944:	ff 75 f4             	pushl  -0xc(%ebp)
  801947:	e8 50 f9 ff ff       	call   80129c <fd_close>
		return r;
  80194c:	83 c4 10             	add    $0x10,%esp
  80194f:	89 da                	mov    %ebx,%edx
  801951:	eb 17                	jmp    80196a <open+0x86>
	}

	return fd2num(fd);
  801953:	83 ec 0c             	sub    $0xc,%esp
  801956:	ff 75 f4             	pushl  -0xc(%ebp)
  801959:	e8 1f f8 ff ff       	call   80117d <fd2num>
  80195e:	89 c2                	mov    %eax,%edx
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	eb 05                	jmp    80196a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801965:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80196a:	89 d0                	mov    %edx,%eax
  80196c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80196f:	c9                   	leave  
  801970:	c3                   	ret    

00801971 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801971:	55                   	push   %ebp
  801972:	89 e5                	mov    %esp,%ebp
  801974:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801977:	ba 00 00 00 00       	mov    $0x0,%edx
  80197c:	b8 08 00 00 00       	mov    $0x8,%eax
  801981:	e8 a6 fd ff ff       	call   80172c <fsipc>
}
  801986:	c9                   	leave  
  801987:	c3                   	ret    

00801988 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801988:	55                   	push   %ebp
  801989:	89 e5                	mov    %esp,%ebp
  80198b:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80198e:	68 73 2b 80 00       	push   $0x802b73
  801993:	ff 75 0c             	pushl  0xc(%ebp)
  801996:	e8 1a ee ff ff       	call   8007b5 <strcpy>
	return 0;
}
  80199b:	b8 00 00 00 00       	mov    $0x0,%eax
  8019a0:	c9                   	leave  
  8019a1:	c3                   	ret    

008019a2 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	53                   	push   %ebx
  8019a6:	83 ec 10             	sub    $0x10,%esp
  8019a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8019ac:	53                   	push   %ebx
  8019ad:	e8 e9 09 00 00       	call   80239b <pageref>
  8019b2:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8019b5:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8019ba:	83 f8 01             	cmp    $0x1,%eax
  8019bd:	75 10                	jne    8019cf <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8019bf:	83 ec 0c             	sub    $0xc,%esp
  8019c2:	ff 73 0c             	pushl  0xc(%ebx)
  8019c5:	e8 c0 02 00 00       	call   801c8a <nsipc_close>
  8019ca:	89 c2                	mov    %eax,%edx
  8019cc:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8019cf:	89 d0                	mov    %edx,%eax
  8019d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019d4:	c9                   	leave  
  8019d5:	c3                   	ret    

008019d6 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8019d6:	55                   	push   %ebp
  8019d7:	89 e5                	mov    %esp,%ebp
  8019d9:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8019dc:	6a 00                	push   $0x0
  8019de:	ff 75 10             	pushl  0x10(%ebp)
  8019e1:	ff 75 0c             	pushl  0xc(%ebp)
  8019e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e7:	ff 70 0c             	pushl  0xc(%eax)
  8019ea:	e8 78 03 00 00       	call   801d67 <nsipc_send>
}
  8019ef:	c9                   	leave  
  8019f0:	c3                   	ret    

008019f1 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8019f1:	55                   	push   %ebp
  8019f2:	89 e5                	mov    %esp,%ebp
  8019f4:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8019f7:	6a 00                	push   $0x0
  8019f9:	ff 75 10             	pushl  0x10(%ebp)
  8019fc:	ff 75 0c             	pushl  0xc(%ebp)
  8019ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801a02:	ff 70 0c             	pushl  0xc(%eax)
  801a05:	e8 f1 02 00 00       	call   801cfb <nsipc_recv>
}
  801a0a:	c9                   	leave  
  801a0b:	c3                   	ret    

00801a0c <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801a12:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801a15:	52                   	push   %edx
  801a16:	50                   	push   %eax
  801a17:	e8 d7 f7 ff ff       	call   8011f3 <fd_lookup>
  801a1c:	83 c4 10             	add    $0x10,%esp
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	78 17                	js     801a3a <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801a23:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a26:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801a2c:	39 08                	cmp    %ecx,(%eax)
  801a2e:	75 05                	jne    801a35 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801a30:	8b 40 0c             	mov    0xc(%eax),%eax
  801a33:	eb 05                	jmp    801a3a <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801a35:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801a3a:	c9                   	leave  
  801a3b:	c3                   	ret    

00801a3c <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	56                   	push   %esi
  801a40:	53                   	push   %ebx
  801a41:	83 ec 1c             	sub    $0x1c,%esp
  801a44:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801a46:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a49:	50                   	push   %eax
  801a4a:	e8 55 f7 ff ff       	call   8011a4 <fd_alloc>
  801a4f:	89 c3                	mov    %eax,%ebx
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	85 c0                	test   %eax,%eax
  801a56:	78 1b                	js     801a73 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801a58:	83 ec 04             	sub    $0x4,%esp
  801a5b:	68 07 04 00 00       	push   $0x407
  801a60:	ff 75 f4             	pushl  -0xc(%ebp)
  801a63:	6a 00                	push   $0x0
  801a65:	e8 4e f1 ff ff       	call   800bb8 <sys_page_alloc>
  801a6a:	89 c3                	mov    %eax,%ebx
  801a6c:	83 c4 10             	add    $0x10,%esp
  801a6f:	85 c0                	test   %eax,%eax
  801a71:	79 10                	jns    801a83 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801a73:	83 ec 0c             	sub    $0xc,%esp
  801a76:	56                   	push   %esi
  801a77:	e8 0e 02 00 00       	call   801c8a <nsipc_close>
		return r;
  801a7c:	83 c4 10             	add    $0x10,%esp
  801a7f:	89 d8                	mov    %ebx,%eax
  801a81:	eb 24                	jmp    801aa7 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801a83:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a8c:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801a8e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a91:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801a98:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801a9b:	83 ec 0c             	sub    $0xc,%esp
  801a9e:	50                   	push   %eax
  801a9f:	e8 d9 f6 ff ff       	call   80117d <fd2num>
  801aa4:	83 c4 10             	add    $0x10,%esp
}
  801aa7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aaa:	5b                   	pop    %ebx
  801aab:	5e                   	pop    %esi
  801aac:	5d                   	pop    %ebp
  801aad:	c3                   	ret    

00801aae <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801aae:	55                   	push   %ebp
  801aaf:	89 e5                	mov    %esp,%ebp
  801ab1:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ab7:	e8 50 ff ff ff       	call   801a0c <fd2sockid>
		return r;
  801abc:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801abe:	85 c0                	test   %eax,%eax
  801ac0:	78 1f                	js     801ae1 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ac2:	83 ec 04             	sub    $0x4,%esp
  801ac5:	ff 75 10             	pushl  0x10(%ebp)
  801ac8:	ff 75 0c             	pushl  0xc(%ebp)
  801acb:	50                   	push   %eax
  801acc:	e8 12 01 00 00       	call   801be3 <nsipc_accept>
  801ad1:	83 c4 10             	add    $0x10,%esp
		return r;
  801ad4:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ad6:	85 c0                	test   %eax,%eax
  801ad8:	78 07                	js     801ae1 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ada:	e8 5d ff ff ff       	call   801a3c <alloc_sockfd>
  801adf:	89 c1                	mov    %eax,%ecx
}
  801ae1:	89 c8                	mov    %ecx,%eax
  801ae3:	c9                   	leave  
  801ae4:	c3                   	ret    

00801ae5 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801aeb:	8b 45 08             	mov    0x8(%ebp),%eax
  801aee:	e8 19 ff ff ff       	call   801a0c <fd2sockid>
  801af3:	85 c0                	test   %eax,%eax
  801af5:	78 12                	js     801b09 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801af7:	83 ec 04             	sub    $0x4,%esp
  801afa:	ff 75 10             	pushl  0x10(%ebp)
  801afd:	ff 75 0c             	pushl  0xc(%ebp)
  801b00:	50                   	push   %eax
  801b01:	e8 2d 01 00 00       	call   801c33 <nsipc_bind>
  801b06:	83 c4 10             	add    $0x10,%esp
}
  801b09:	c9                   	leave  
  801b0a:	c3                   	ret    

00801b0b <shutdown>:

int
shutdown(int s, int how)
{
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b11:	8b 45 08             	mov    0x8(%ebp),%eax
  801b14:	e8 f3 fe ff ff       	call   801a0c <fd2sockid>
  801b19:	85 c0                	test   %eax,%eax
  801b1b:	78 0f                	js     801b2c <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801b1d:	83 ec 08             	sub    $0x8,%esp
  801b20:	ff 75 0c             	pushl  0xc(%ebp)
  801b23:	50                   	push   %eax
  801b24:	e8 3f 01 00 00       	call   801c68 <nsipc_shutdown>
  801b29:	83 c4 10             	add    $0x10,%esp
}
  801b2c:	c9                   	leave  
  801b2d:	c3                   	ret    

00801b2e <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801b2e:	55                   	push   %ebp
  801b2f:	89 e5                	mov    %esp,%ebp
  801b31:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b34:	8b 45 08             	mov    0x8(%ebp),%eax
  801b37:	e8 d0 fe ff ff       	call   801a0c <fd2sockid>
  801b3c:	85 c0                	test   %eax,%eax
  801b3e:	78 12                	js     801b52 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801b40:	83 ec 04             	sub    $0x4,%esp
  801b43:	ff 75 10             	pushl  0x10(%ebp)
  801b46:	ff 75 0c             	pushl  0xc(%ebp)
  801b49:	50                   	push   %eax
  801b4a:	e8 55 01 00 00       	call   801ca4 <nsipc_connect>
  801b4f:	83 c4 10             	add    $0x10,%esp
}
  801b52:	c9                   	leave  
  801b53:	c3                   	ret    

00801b54 <listen>:

int
listen(int s, int backlog)
{
  801b54:	55                   	push   %ebp
  801b55:	89 e5                	mov    %esp,%ebp
  801b57:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5d:	e8 aa fe ff ff       	call   801a0c <fd2sockid>
  801b62:	85 c0                	test   %eax,%eax
  801b64:	78 0f                	js     801b75 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801b66:	83 ec 08             	sub    $0x8,%esp
  801b69:	ff 75 0c             	pushl  0xc(%ebp)
  801b6c:	50                   	push   %eax
  801b6d:	e8 67 01 00 00       	call   801cd9 <nsipc_listen>
  801b72:	83 c4 10             	add    $0x10,%esp
}
  801b75:	c9                   	leave  
  801b76:	c3                   	ret    

00801b77 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801b77:	55                   	push   %ebp
  801b78:	89 e5                	mov    %esp,%ebp
  801b7a:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801b7d:	ff 75 10             	pushl  0x10(%ebp)
  801b80:	ff 75 0c             	pushl  0xc(%ebp)
  801b83:	ff 75 08             	pushl  0x8(%ebp)
  801b86:	e8 3a 02 00 00       	call   801dc5 <nsipc_socket>
  801b8b:	83 c4 10             	add    $0x10,%esp
  801b8e:	85 c0                	test   %eax,%eax
  801b90:	78 05                	js     801b97 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801b92:	e8 a5 fe ff ff       	call   801a3c <alloc_sockfd>
}
  801b97:	c9                   	leave  
  801b98:	c3                   	ret    

00801b99 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801b99:	55                   	push   %ebp
  801b9a:	89 e5                	mov    %esp,%ebp
  801b9c:	53                   	push   %ebx
  801b9d:	83 ec 04             	sub    $0x4,%esp
  801ba0:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801ba2:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801ba9:	75 12                	jne    801bbd <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801bab:	83 ec 0c             	sub    $0xc,%esp
  801bae:	6a 02                	push   $0x2
  801bb0:	e8 8f f5 ff ff       	call   801144 <ipc_find_env>
  801bb5:	a3 04 40 80 00       	mov    %eax,0x804004
  801bba:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801bbd:	6a 07                	push   $0x7
  801bbf:	68 00 60 80 00       	push   $0x806000
  801bc4:	53                   	push   %ebx
  801bc5:	ff 35 04 40 80 00    	pushl  0x804004
  801bcb:	e8 20 f5 ff ff       	call   8010f0 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801bd0:	83 c4 0c             	add    $0xc,%esp
  801bd3:	6a 00                	push   $0x0
  801bd5:	6a 00                	push   $0x0
  801bd7:	6a 00                	push   $0x0
  801bd9:	e8 a9 f4 ff ff       	call   801087 <ipc_recv>
}
  801bde:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be1:	c9                   	leave  
  801be2:	c3                   	ret    

00801be3 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801be3:	55                   	push   %ebp
  801be4:	89 e5                	mov    %esp,%ebp
  801be6:	56                   	push   %esi
  801be7:	53                   	push   %ebx
  801be8:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801beb:	8b 45 08             	mov    0x8(%ebp),%eax
  801bee:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801bf3:	8b 06                	mov    (%esi),%eax
  801bf5:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801bfa:	b8 01 00 00 00       	mov    $0x1,%eax
  801bff:	e8 95 ff ff ff       	call   801b99 <nsipc>
  801c04:	89 c3                	mov    %eax,%ebx
  801c06:	85 c0                	test   %eax,%eax
  801c08:	78 20                	js     801c2a <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801c0a:	83 ec 04             	sub    $0x4,%esp
  801c0d:	ff 35 10 60 80 00    	pushl  0x806010
  801c13:	68 00 60 80 00       	push   $0x806000
  801c18:	ff 75 0c             	pushl  0xc(%ebp)
  801c1b:	e8 27 ed ff ff       	call   800947 <memmove>
		*addrlen = ret->ret_addrlen;
  801c20:	a1 10 60 80 00       	mov    0x806010,%eax
  801c25:	89 06                	mov    %eax,(%esi)
  801c27:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801c2a:	89 d8                	mov    %ebx,%eax
  801c2c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2f:	5b                   	pop    %ebx
  801c30:	5e                   	pop    %esi
  801c31:	5d                   	pop    %ebp
  801c32:	c3                   	ret    

00801c33 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801c33:	55                   	push   %ebp
  801c34:	89 e5                	mov    %esp,%ebp
  801c36:	53                   	push   %ebx
  801c37:	83 ec 08             	sub    $0x8,%esp
  801c3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801c3d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c40:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801c45:	53                   	push   %ebx
  801c46:	ff 75 0c             	pushl  0xc(%ebp)
  801c49:	68 04 60 80 00       	push   $0x806004
  801c4e:	e8 f4 ec ff ff       	call   800947 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801c53:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801c59:	b8 02 00 00 00       	mov    $0x2,%eax
  801c5e:	e8 36 ff ff ff       	call   801b99 <nsipc>
}
  801c63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c66:	c9                   	leave  
  801c67:	c3                   	ret    

00801c68 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801c6e:	8b 45 08             	mov    0x8(%ebp),%eax
  801c71:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801c76:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c79:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801c7e:	b8 03 00 00 00       	mov    $0x3,%eax
  801c83:	e8 11 ff ff ff       	call   801b99 <nsipc>
}
  801c88:	c9                   	leave  
  801c89:	c3                   	ret    

00801c8a <nsipc_close>:

int
nsipc_close(int s)
{
  801c8a:	55                   	push   %ebp
  801c8b:	89 e5                	mov    %esp,%ebp
  801c8d:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801c90:	8b 45 08             	mov    0x8(%ebp),%eax
  801c93:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801c98:	b8 04 00 00 00       	mov    $0x4,%eax
  801c9d:	e8 f7 fe ff ff       	call   801b99 <nsipc>
}
  801ca2:	c9                   	leave  
  801ca3:	c3                   	ret    

00801ca4 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ca4:	55                   	push   %ebp
  801ca5:	89 e5                	mov    %esp,%ebp
  801ca7:	53                   	push   %ebx
  801ca8:	83 ec 08             	sub    $0x8,%esp
  801cab:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801cae:	8b 45 08             	mov    0x8(%ebp),%eax
  801cb1:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801cb6:	53                   	push   %ebx
  801cb7:	ff 75 0c             	pushl  0xc(%ebp)
  801cba:	68 04 60 80 00       	push   $0x806004
  801cbf:	e8 83 ec ff ff       	call   800947 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801cc4:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801cca:	b8 05 00 00 00       	mov    $0x5,%eax
  801ccf:	e8 c5 fe ff ff       	call   801b99 <nsipc>
}
  801cd4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cd7:	c9                   	leave  
  801cd8:	c3                   	ret    

00801cd9 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801cd9:	55                   	push   %ebp
  801cda:	89 e5                	mov    %esp,%ebp
  801cdc:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801cdf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ce2:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ce7:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cea:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801cef:	b8 06 00 00 00       	mov    $0x6,%eax
  801cf4:	e8 a0 fe ff ff       	call   801b99 <nsipc>
}
  801cf9:	c9                   	leave  
  801cfa:	c3                   	ret    

00801cfb <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	56                   	push   %esi
  801cff:	53                   	push   %ebx
  801d00:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801d03:	8b 45 08             	mov    0x8(%ebp),%eax
  801d06:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801d0b:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801d11:	8b 45 14             	mov    0x14(%ebp),%eax
  801d14:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801d19:	b8 07 00 00 00       	mov    $0x7,%eax
  801d1e:	e8 76 fe ff ff       	call   801b99 <nsipc>
  801d23:	89 c3                	mov    %eax,%ebx
  801d25:	85 c0                	test   %eax,%eax
  801d27:	78 35                	js     801d5e <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801d29:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801d2e:	7f 04                	jg     801d34 <nsipc_recv+0x39>
  801d30:	39 c6                	cmp    %eax,%esi
  801d32:	7d 16                	jge    801d4a <nsipc_recv+0x4f>
  801d34:	68 7f 2b 80 00       	push   $0x802b7f
  801d39:	68 47 2b 80 00       	push   $0x802b47
  801d3e:	6a 62                	push   $0x62
  801d40:	68 94 2b 80 00       	push   $0x802b94
  801d45:	e8 84 05 00 00       	call   8022ce <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801d4a:	83 ec 04             	sub    $0x4,%esp
  801d4d:	50                   	push   %eax
  801d4e:	68 00 60 80 00       	push   $0x806000
  801d53:	ff 75 0c             	pushl  0xc(%ebp)
  801d56:	e8 ec eb ff ff       	call   800947 <memmove>
  801d5b:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801d5e:	89 d8                	mov    %ebx,%eax
  801d60:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d63:	5b                   	pop    %ebx
  801d64:	5e                   	pop    %esi
  801d65:	5d                   	pop    %ebp
  801d66:	c3                   	ret    

00801d67 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801d67:	55                   	push   %ebp
  801d68:	89 e5                	mov    %esp,%ebp
  801d6a:	53                   	push   %ebx
  801d6b:	83 ec 04             	sub    $0x4,%esp
  801d6e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801d71:	8b 45 08             	mov    0x8(%ebp),%eax
  801d74:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801d79:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801d7f:	7e 16                	jle    801d97 <nsipc_send+0x30>
  801d81:	68 a0 2b 80 00       	push   $0x802ba0
  801d86:	68 47 2b 80 00       	push   $0x802b47
  801d8b:	6a 6d                	push   $0x6d
  801d8d:	68 94 2b 80 00       	push   $0x802b94
  801d92:	e8 37 05 00 00       	call   8022ce <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801d97:	83 ec 04             	sub    $0x4,%esp
  801d9a:	53                   	push   %ebx
  801d9b:	ff 75 0c             	pushl  0xc(%ebp)
  801d9e:	68 0c 60 80 00       	push   $0x80600c
  801da3:	e8 9f eb ff ff       	call   800947 <memmove>
	nsipcbuf.send.req_size = size;
  801da8:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801dae:	8b 45 14             	mov    0x14(%ebp),%eax
  801db1:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801db6:	b8 08 00 00 00       	mov    $0x8,%eax
  801dbb:	e8 d9 fd ff ff       	call   801b99 <nsipc>
}
  801dc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dc3:	c9                   	leave  
  801dc4:	c3                   	ret    

00801dc5 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801dcb:	8b 45 08             	mov    0x8(%ebp),%eax
  801dce:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801dd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  801dd6:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801ddb:	8b 45 10             	mov    0x10(%ebp),%eax
  801dde:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801de3:	b8 09 00 00 00       	mov    $0x9,%eax
  801de8:	e8 ac fd ff ff       	call   801b99 <nsipc>
}
  801ded:	c9                   	leave  
  801dee:	c3                   	ret    

00801def <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801def:	55                   	push   %ebp
  801df0:	89 e5                	mov    %esp,%ebp
  801df2:	56                   	push   %esi
  801df3:	53                   	push   %ebx
  801df4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801df7:	83 ec 0c             	sub    $0xc,%esp
  801dfa:	ff 75 08             	pushl  0x8(%ebp)
  801dfd:	e8 8b f3 ff ff       	call   80118d <fd2data>
  801e02:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801e04:	83 c4 08             	add    $0x8,%esp
  801e07:	68 ac 2b 80 00       	push   $0x802bac
  801e0c:	53                   	push   %ebx
  801e0d:	e8 a3 e9 ff ff       	call   8007b5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801e12:	8b 46 04             	mov    0x4(%esi),%eax
  801e15:	2b 06                	sub    (%esi),%eax
  801e17:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801e1d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801e24:	00 00 00 
	stat->st_dev = &devpipe;
  801e27:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801e2e:	30 80 00 
	return 0;
}
  801e31:	b8 00 00 00 00       	mov    $0x0,%eax
  801e36:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e39:	5b                   	pop    %ebx
  801e3a:	5e                   	pop    %esi
  801e3b:	5d                   	pop    %ebp
  801e3c:	c3                   	ret    

00801e3d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801e3d:	55                   	push   %ebp
  801e3e:	89 e5                	mov    %esp,%ebp
  801e40:	53                   	push   %ebx
  801e41:	83 ec 0c             	sub    $0xc,%esp
  801e44:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801e47:	53                   	push   %ebx
  801e48:	6a 00                	push   $0x0
  801e4a:	e8 ee ed ff ff       	call   800c3d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801e4f:	89 1c 24             	mov    %ebx,(%esp)
  801e52:	e8 36 f3 ff ff       	call   80118d <fd2data>
  801e57:	83 c4 08             	add    $0x8,%esp
  801e5a:	50                   	push   %eax
  801e5b:	6a 00                	push   $0x0
  801e5d:	e8 db ed ff ff       	call   800c3d <sys_page_unmap>
}
  801e62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e65:	c9                   	leave  
  801e66:	c3                   	ret    

00801e67 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801e67:	55                   	push   %ebp
  801e68:	89 e5                	mov    %esp,%ebp
  801e6a:	57                   	push   %edi
  801e6b:	56                   	push   %esi
  801e6c:	53                   	push   %ebx
  801e6d:	83 ec 1c             	sub    $0x1c,%esp
  801e70:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801e73:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801e75:	a1 08 40 80 00       	mov    0x804008,%eax
  801e7a:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801e7d:	83 ec 0c             	sub    $0xc,%esp
  801e80:	ff 75 e0             	pushl  -0x20(%ebp)
  801e83:	e8 13 05 00 00       	call   80239b <pageref>
  801e88:	89 c3                	mov    %eax,%ebx
  801e8a:	89 3c 24             	mov    %edi,(%esp)
  801e8d:	e8 09 05 00 00       	call   80239b <pageref>
  801e92:	83 c4 10             	add    $0x10,%esp
  801e95:	39 c3                	cmp    %eax,%ebx
  801e97:	0f 94 c1             	sete   %cl
  801e9a:	0f b6 c9             	movzbl %cl,%ecx
  801e9d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801ea0:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ea6:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801ea9:	39 ce                	cmp    %ecx,%esi
  801eab:	74 1b                	je     801ec8 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801ead:	39 c3                	cmp    %eax,%ebx
  801eaf:	75 c4                	jne    801e75 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801eb1:	8b 42 58             	mov    0x58(%edx),%eax
  801eb4:	ff 75 e4             	pushl  -0x1c(%ebp)
  801eb7:	50                   	push   %eax
  801eb8:	56                   	push   %esi
  801eb9:	68 b3 2b 80 00       	push   $0x802bb3
  801ebe:	e8 ee e2 ff ff       	call   8001b1 <cprintf>
  801ec3:	83 c4 10             	add    $0x10,%esp
  801ec6:	eb ad                	jmp    801e75 <_pipeisclosed+0xe>
	}
}
  801ec8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ecb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ece:	5b                   	pop    %ebx
  801ecf:	5e                   	pop    %esi
  801ed0:	5f                   	pop    %edi
  801ed1:	5d                   	pop    %ebp
  801ed2:	c3                   	ret    

00801ed3 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801ed3:	55                   	push   %ebp
  801ed4:	89 e5                	mov    %esp,%ebp
  801ed6:	57                   	push   %edi
  801ed7:	56                   	push   %esi
  801ed8:	53                   	push   %ebx
  801ed9:	83 ec 28             	sub    $0x28,%esp
  801edc:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801edf:	56                   	push   %esi
  801ee0:	e8 a8 f2 ff ff       	call   80118d <fd2data>
  801ee5:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801ee7:	83 c4 10             	add    $0x10,%esp
  801eea:	bf 00 00 00 00       	mov    $0x0,%edi
  801eef:	eb 4b                	jmp    801f3c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801ef1:	89 da                	mov    %ebx,%edx
  801ef3:	89 f0                	mov    %esi,%eax
  801ef5:	e8 6d ff ff ff       	call   801e67 <_pipeisclosed>
  801efa:	85 c0                	test   %eax,%eax
  801efc:	75 48                	jne    801f46 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801efe:	e8 96 ec ff ff       	call   800b99 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801f03:	8b 43 04             	mov    0x4(%ebx),%eax
  801f06:	8b 0b                	mov    (%ebx),%ecx
  801f08:	8d 51 20             	lea    0x20(%ecx),%edx
  801f0b:	39 d0                	cmp    %edx,%eax
  801f0d:	73 e2                	jae    801ef1 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801f0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f12:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801f16:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801f19:	89 c2                	mov    %eax,%edx
  801f1b:	c1 fa 1f             	sar    $0x1f,%edx
  801f1e:	89 d1                	mov    %edx,%ecx
  801f20:	c1 e9 1b             	shr    $0x1b,%ecx
  801f23:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801f26:	83 e2 1f             	and    $0x1f,%edx
  801f29:	29 ca                	sub    %ecx,%edx
  801f2b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801f2f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801f33:	83 c0 01             	add    $0x1,%eax
  801f36:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f39:	83 c7 01             	add    $0x1,%edi
  801f3c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801f3f:	75 c2                	jne    801f03 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801f41:	8b 45 10             	mov    0x10(%ebp),%eax
  801f44:	eb 05                	jmp    801f4b <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801f46:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801f4b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f4e:	5b                   	pop    %ebx
  801f4f:	5e                   	pop    %esi
  801f50:	5f                   	pop    %edi
  801f51:	5d                   	pop    %ebp
  801f52:	c3                   	ret    

00801f53 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801f53:	55                   	push   %ebp
  801f54:	89 e5                	mov    %esp,%ebp
  801f56:	57                   	push   %edi
  801f57:	56                   	push   %esi
  801f58:	53                   	push   %ebx
  801f59:	83 ec 18             	sub    $0x18,%esp
  801f5c:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801f5f:	57                   	push   %edi
  801f60:	e8 28 f2 ff ff       	call   80118d <fd2data>
  801f65:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801f67:	83 c4 10             	add    $0x10,%esp
  801f6a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f6f:	eb 3d                	jmp    801fae <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801f71:	85 db                	test   %ebx,%ebx
  801f73:	74 04                	je     801f79 <devpipe_read+0x26>
				return i;
  801f75:	89 d8                	mov    %ebx,%eax
  801f77:	eb 44                	jmp    801fbd <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801f79:	89 f2                	mov    %esi,%edx
  801f7b:	89 f8                	mov    %edi,%eax
  801f7d:	e8 e5 fe ff ff       	call   801e67 <_pipeisclosed>
  801f82:	85 c0                	test   %eax,%eax
  801f84:	75 32                	jne    801fb8 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801f86:	e8 0e ec ff ff       	call   800b99 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801f8b:	8b 06                	mov    (%esi),%eax
  801f8d:	3b 46 04             	cmp    0x4(%esi),%eax
  801f90:	74 df                	je     801f71 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801f92:	99                   	cltd   
  801f93:	c1 ea 1b             	shr    $0x1b,%edx
  801f96:	01 d0                	add    %edx,%eax
  801f98:	83 e0 1f             	and    $0x1f,%eax
  801f9b:	29 d0                	sub    %edx,%eax
  801f9d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801fa2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fa5:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801fa8:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801fab:	83 c3 01             	add    $0x1,%ebx
  801fae:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801fb1:	75 d8                	jne    801f8b <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801fb3:	8b 45 10             	mov    0x10(%ebp),%eax
  801fb6:	eb 05                	jmp    801fbd <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801fb8:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801fbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc0:	5b                   	pop    %ebx
  801fc1:	5e                   	pop    %esi
  801fc2:	5f                   	pop    %edi
  801fc3:	5d                   	pop    %ebp
  801fc4:	c3                   	ret    

00801fc5 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
  801fc8:	56                   	push   %esi
  801fc9:	53                   	push   %ebx
  801fca:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801fcd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fd0:	50                   	push   %eax
  801fd1:	e8 ce f1 ff ff       	call   8011a4 <fd_alloc>
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	89 c2                	mov    %eax,%edx
  801fdb:	85 c0                	test   %eax,%eax
  801fdd:	0f 88 2c 01 00 00    	js     80210f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801fe3:	83 ec 04             	sub    $0x4,%esp
  801fe6:	68 07 04 00 00       	push   $0x407
  801feb:	ff 75 f4             	pushl  -0xc(%ebp)
  801fee:	6a 00                	push   $0x0
  801ff0:	e8 c3 eb ff ff       	call   800bb8 <sys_page_alloc>
  801ff5:	83 c4 10             	add    $0x10,%esp
  801ff8:	89 c2                	mov    %eax,%edx
  801ffa:	85 c0                	test   %eax,%eax
  801ffc:	0f 88 0d 01 00 00    	js     80210f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802002:	83 ec 0c             	sub    $0xc,%esp
  802005:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802008:	50                   	push   %eax
  802009:	e8 96 f1 ff ff       	call   8011a4 <fd_alloc>
  80200e:	89 c3                	mov    %eax,%ebx
  802010:	83 c4 10             	add    $0x10,%esp
  802013:	85 c0                	test   %eax,%eax
  802015:	0f 88 e2 00 00 00    	js     8020fd <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80201b:	83 ec 04             	sub    $0x4,%esp
  80201e:	68 07 04 00 00       	push   $0x407
  802023:	ff 75 f0             	pushl  -0x10(%ebp)
  802026:	6a 00                	push   $0x0
  802028:	e8 8b eb ff ff       	call   800bb8 <sys_page_alloc>
  80202d:	89 c3                	mov    %eax,%ebx
  80202f:	83 c4 10             	add    $0x10,%esp
  802032:	85 c0                	test   %eax,%eax
  802034:	0f 88 c3 00 00 00    	js     8020fd <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80203a:	83 ec 0c             	sub    $0xc,%esp
  80203d:	ff 75 f4             	pushl  -0xc(%ebp)
  802040:	e8 48 f1 ff ff       	call   80118d <fd2data>
  802045:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802047:	83 c4 0c             	add    $0xc,%esp
  80204a:	68 07 04 00 00       	push   $0x407
  80204f:	50                   	push   %eax
  802050:	6a 00                	push   $0x0
  802052:	e8 61 eb ff ff       	call   800bb8 <sys_page_alloc>
  802057:	89 c3                	mov    %eax,%ebx
  802059:	83 c4 10             	add    $0x10,%esp
  80205c:	85 c0                	test   %eax,%eax
  80205e:	0f 88 89 00 00 00    	js     8020ed <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802064:	83 ec 0c             	sub    $0xc,%esp
  802067:	ff 75 f0             	pushl  -0x10(%ebp)
  80206a:	e8 1e f1 ff ff       	call   80118d <fd2data>
  80206f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802076:	50                   	push   %eax
  802077:	6a 00                	push   $0x0
  802079:	56                   	push   %esi
  80207a:	6a 00                	push   $0x0
  80207c:	e8 7a eb ff ff       	call   800bfb <sys_page_map>
  802081:	89 c3                	mov    %eax,%ebx
  802083:	83 c4 20             	add    $0x20,%esp
  802086:	85 c0                	test   %eax,%eax
  802088:	78 55                	js     8020df <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80208a:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802090:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802093:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  802095:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802098:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  80209f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020a8:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8020aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8020ad:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8020b4:	83 ec 0c             	sub    $0xc,%esp
  8020b7:	ff 75 f4             	pushl  -0xc(%ebp)
  8020ba:	e8 be f0 ff ff       	call   80117d <fd2num>
  8020bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020c2:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8020c4:	83 c4 04             	add    $0x4,%esp
  8020c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8020ca:	e8 ae f0 ff ff       	call   80117d <fd2num>
  8020cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8020d2:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8020d5:	83 c4 10             	add    $0x10,%esp
  8020d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8020dd:	eb 30                	jmp    80210f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8020df:	83 ec 08             	sub    $0x8,%esp
  8020e2:	56                   	push   %esi
  8020e3:	6a 00                	push   $0x0
  8020e5:	e8 53 eb ff ff       	call   800c3d <sys_page_unmap>
  8020ea:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8020ed:	83 ec 08             	sub    $0x8,%esp
  8020f0:	ff 75 f0             	pushl  -0x10(%ebp)
  8020f3:	6a 00                	push   $0x0
  8020f5:	e8 43 eb ff ff       	call   800c3d <sys_page_unmap>
  8020fa:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  8020fd:	83 ec 08             	sub    $0x8,%esp
  802100:	ff 75 f4             	pushl  -0xc(%ebp)
  802103:	6a 00                	push   $0x0
  802105:	e8 33 eb ff ff       	call   800c3d <sys_page_unmap>
  80210a:	83 c4 10             	add    $0x10,%esp
  80210d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  80210f:	89 d0                	mov    %edx,%eax
  802111:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802114:	5b                   	pop    %ebx
  802115:	5e                   	pop    %esi
  802116:	5d                   	pop    %ebp
  802117:	c3                   	ret    

00802118 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802118:	55                   	push   %ebp
  802119:	89 e5                	mov    %esp,%ebp
  80211b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80211e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802121:	50                   	push   %eax
  802122:	ff 75 08             	pushl  0x8(%ebp)
  802125:	e8 c9 f0 ff ff       	call   8011f3 <fd_lookup>
  80212a:	83 c4 10             	add    $0x10,%esp
  80212d:	85 c0                	test   %eax,%eax
  80212f:	78 18                	js     802149 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802131:	83 ec 0c             	sub    $0xc,%esp
  802134:	ff 75 f4             	pushl  -0xc(%ebp)
  802137:	e8 51 f0 ff ff       	call   80118d <fd2data>
	return _pipeisclosed(fd, p);
  80213c:	89 c2                	mov    %eax,%edx
  80213e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802141:	e8 21 fd ff ff       	call   801e67 <_pipeisclosed>
  802146:	83 c4 10             	add    $0x10,%esp
}
  802149:	c9                   	leave  
  80214a:	c3                   	ret    

0080214b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80214b:	55                   	push   %ebp
  80214c:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80214e:	b8 00 00 00 00       	mov    $0x0,%eax
  802153:	5d                   	pop    %ebp
  802154:	c3                   	ret    

00802155 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802155:	55                   	push   %ebp
  802156:	89 e5                	mov    %esp,%ebp
  802158:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80215b:	68 cb 2b 80 00       	push   $0x802bcb
  802160:	ff 75 0c             	pushl  0xc(%ebp)
  802163:	e8 4d e6 ff ff       	call   8007b5 <strcpy>
	return 0;
}
  802168:	b8 00 00 00 00       	mov    $0x0,%eax
  80216d:	c9                   	leave  
  80216e:	c3                   	ret    

0080216f <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80216f:	55                   	push   %ebp
  802170:	89 e5                	mov    %esp,%ebp
  802172:	57                   	push   %edi
  802173:	56                   	push   %esi
  802174:	53                   	push   %ebx
  802175:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80217b:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802180:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802186:	eb 2d                	jmp    8021b5 <devcons_write+0x46>
		m = n - tot;
  802188:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80218b:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80218d:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802190:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802195:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802198:	83 ec 04             	sub    $0x4,%esp
  80219b:	53                   	push   %ebx
  80219c:	03 45 0c             	add    0xc(%ebp),%eax
  80219f:	50                   	push   %eax
  8021a0:	57                   	push   %edi
  8021a1:	e8 a1 e7 ff ff       	call   800947 <memmove>
		sys_cputs(buf, m);
  8021a6:	83 c4 08             	add    $0x8,%esp
  8021a9:	53                   	push   %ebx
  8021aa:	57                   	push   %edi
  8021ab:	e8 4c e9 ff ff       	call   800afc <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8021b0:	01 de                	add    %ebx,%esi
  8021b2:	83 c4 10             	add    $0x10,%esp
  8021b5:	89 f0                	mov    %esi,%eax
  8021b7:	3b 75 10             	cmp    0x10(%ebp),%esi
  8021ba:	72 cc                	jb     802188 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8021bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021bf:	5b                   	pop    %ebx
  8021c0:	5e                   	pop    %esi
  8021c1:	5f                   	pop    %edi
  8021c2:	5d                   	pop    %ebp
  8021c3:	c3                   	ret    

008021c4 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8021c4:	55                   	push   %ebp
  8021c5:	89 e5                	mov    %esp,%ebp
  8021c7:	83 ec 08             	sub    $0x8,%esp
  8021ca:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8021cf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8021d3:	74 2a                	je     8021ff <devcons_read+0x3b>
  8021d5:	eb 05                	jmp    8021dc <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8021d7:	e8 bd e9 ff ff       	call   800b99 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8021dc:	e8 39 e9 ff ff       	call   800b1a <sys_cgetc>
  8021e1:	85 c0                	test   %eax,%eax
  8021e3:	74 f2                	je     8021d7 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8021e5:	85 c0                	test   %eax,%eax
  8021e7:	78 16                	js     8021ff <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8021e9:	83 f8 04             	cmp    $0x4,%eax
  8021ec:	74 0c                	je     8021fa <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8021ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8021f1:	88 02                	mov    %al,(%edx)
	return 1;
  8021f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8021f8:	eb 05                	jmp    8021ff <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8021fa:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  8021ff:	c9                   	leave  
  802200:	c3                   	ret    

00802201 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  802201:	55                   	push   %ebp
  802202:	89 e5                	mov    %esp,%ebp
  802204:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802207:	8b 45 08             	mov    0x8(%ebp),%eax
  80220a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80220d:	6a 01                	push   $0x1
  80220f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802212:	50                   	push   %eax
  802213:	e8 e4 e8 ff ff       	call   800afc <sys_cputs>
}
  802218:	83 c4 10             	add    $0x10,%esp
  80221b:	c9                   	leave  
  80221c:	c3                   	ret    

0080221d <getchar>:

int
getchar(void)
{
  80221d:	55                   	push   %ebp
  80221e:	89 e5                	mov    %esp,%ebp
  802220:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802223:	6a 01                	push   $0x1
  802225:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802228:	50                   	push   %eax
  802229:	6a 00                	push   $0x0
  80222b:	e8 29 f2 ff ff       	call   801459 <read>
	if (r < 0)
  802230:	83 c4 10             	add    $0x10,%esp
  802233:	85 c0                	test   %eax,%eax
  802235:	78 0f                	js     802246 <getchar+0x29>
		return r;
	if (r < 1)
  802237:	85 c0                	test   %eax,%eax
  802239:	7e 06                	jle    802241 <getchar+0x24>
		return -E_EOF;
	return c;
  80223b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  80223f:	eb 05                	jmp    802246 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802241:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802246:	c9                   	leave  
  802247:	c3                   	ret    

00802248 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802248:	55                   	push   %ebp
  802249:	89 e5                	mov    %esp,%ebp
  80224b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80224e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802251:	50                   	push   %eax
  802252:	ff 75 08             	pushl  0x8(%ebp)
  802255:	e8 99 ef ff ff       	call   8011f3 <fd_lookup>
  80225a:	83 c4 10             	add    $0x10,%esp
  80225d:	85 c0                	test   %eax,%eax
  80225f:	78 11                	js     802272 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802261:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802264:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80226a:	39 10                	cmp    %edx,(%eax)
  80226c:	0f 94 c0             	sete   %al
  80226f:	0f b6 c0             	movzbl %al,%eax
}
  802272:	c9                   	leave  
  802273:	c3                   	ret    

00802274 <opencons>:

int
opencons(void)
{
  802274:	55                   	push   %ebp
  802275:	89 e5                	mov    %esp,%ebp
  802277:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80227a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80227d:	50                   	push   %eax
  80227e:	e8 21 ef ff ff       	call   8011a4 <fd_alloc>
  802283:	83 c4 10             	add    $0x10,%esp
		return r;
  802286:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802288:	85 c0                	test   %eax,%eax
  80228a:	78 3e                	js     8022ca <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80228c:	83 ec 04             	sub    $0x4,%esp
  80228f:	68 07 04 00 00       	push   $0x407
  802294:	ff 75 f4             	pushl  -0xc(%ebp)
  802297:	6a 00                	push   $0x0
  802299:	e8 1a e9 ff ff       	call   800bb8 <sys_page_alloc>
  80229e:	83 c4 10             	add    $0x10,%esp
		return r;
  8022a1:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8022a3:	85 c0                	test   %eax,%eax
  8022a5:	78 23                	js     8022ca <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8022a7:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8022ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b0:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8022b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022b5:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8022bc:	83 ec 0c             	sub    $0xc,%esp
  8022bf:	50                   	push   %eax
  8022c0:	e8 b8 ee ff ff       	call   80117d <fd2num>
  8022c5:	89 c2                	mov    %eax,%edx
  8022c7:	83 c4 10             	add    $0x10,%esp
}
  8022ca:	89 d0                	mov    %edx,%eax
  8022cc:	c9                   	leave  
  8022cd:	c3                   	ret    

008022ce <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8022ce:	55                   	push   %ebp
  8022cf:	89 e5                	mov    %esp,%ebp
  8022d1:	56                   	push   %esi
  8022d2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8022d3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8022d6:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8022dc:	e8 99 e8 ff ff       	call   800b7a <sys_getenvid>
  8022e1:	83 ec 0c             	sub    $0xc,%esp
  8022e4:	ff 75 0c             	pushl  0xc(%ebp)
  8022e7:	ff 75 08             	pushl  0x8(%ebp)
  8022ea:	56                   	push   %esi
  8022eb:	50                   	push   %eax
  8022ec:	68 d8 2b 80 00       	push   $0x802bd8
  8022f1:	e8 bb de ff ff       	call   8001b1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8022f6:	83 c4 18             	add    $0x18,%esp
  8022f9:	53                   	push   %ebx
  8022fa:	ff 75 10             	pushl  0x10(%ebp)
  8022fd:	e8 5e de ff ff       	call   800160 <vcprintf>
	cprintf("\n");
  802302:	c7 04 24 c4 2b 80 00 	movl   $0x802bc4,(%esp)
  802309:	e8 a3 de ff ff       	call   8001b1 <cprintf>
  80230e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802311:	cc                   	int3   
  802312:	eb fd                	jmp    802311 <_panic+0x43>

00802314 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802314:	55                   	push   %ebp
  802315:	89 e5                	mov    %esp,%ebp
  802317:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80231a:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802321:	75 4a                	jne    80236d <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  802323:	a1 08 40 80 00       	mov    0x804008,%eax
  802328:	8b 40 48             	mov    0x48(%eax),%eax
  80232b:	83 ec 04             	sub    $0x4,%esp
  80232e:	6a 07                	push   $0x7
  802330:	68 00 f0 bf ee       	push   $0xeebff000
  802335:	50                   	push   %eax
  802336:	e8 7d e8 ff ff       	call   800bb8 <sys_page_alloc>
  80233b:	83 c4 10             	add    $0x10,%esp
  80233e:	85 c0                	test   %eax,%eax
  802340:	79 12                	jns    802354 <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  802342:	50                   	push   %eax
  802343:	68 fc 2b 80 00       	push   $0x802bfc
  802348:	6a 21                	push   $0x21
  80234a:	68 14 2c 80 00       	push   $0x802c14
  80234f:	e8 7a ff ff ff       	call   8022ce <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  802354:	a1 08 40 80 00       	mov    0x804008,%eax
  802359:	8b 40 48             	mov    0x48(%eax),%eax
  80235c:	83 ec 08             	sub    $0x8,%esp
  80235f:	68 77 23 80 00       	push   $0x802377
  802364:	50                   	push   %eax
  802365:	e8 99 e9 ff ff       	call   800d03 <sys_env_set_pgfault_upcall>
  80236a:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80236d:	8b 45 08             	mov    0x8(%ebp),%eax
  802370:	a3 00 70 80 00       	mov    %eax,0x807000
  802375:	c9                   	leave  
  802376:	c3                   	ret    

00802377 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802377:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802378:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80237d:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80237f:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  802382:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  802385:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  802389:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  80238e:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  802392:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  802394:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  802395:	83 c4 04             	add    $0x4,%esp
	popfl
  802398:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802399:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  80239a:	c3                   	ret    

0080239b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80239b:	55                   	push   %ebp
  80239c:	89 e5                	mov    %esp,%ebp
  80239e:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023a1:	89 d0                	mov    %edx,%eax
  8023a3:	c1 e8 16             	shr    $0x16,%eax
  8023a6:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023ad:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023b2:	f6 c1 01             	test   $0x1,%cl
  8023b5:	74 1d                	je     8023d4 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023b7:	c1 ea 0c             	shr    $0xc,%edx
  8023ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023c1:	f6 c2 01             	test   $0x1,%dl
  8023c4:	74 0e                	je     8023d4 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023c6:	c1 ea 0c             	shr    $0xc,%edx
  8023c9:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023d0:	ef 
  8023d1:	0f b7 c0             	movzwl %ax,%eax
}
  8023d4:	5d                   	pop    %ebp
  8023d5:	c3                   	ret    
  8023d6:	66 90                	xchg   %ax,%ax
  8023d8:	66 90                	xchg   %ax,%ax
  8023da:	66 90                	xchg   %ax,%ax
  8023dc:	66 90                	xchg   %ax,%ax
  8023de:	66 90                	xchg   %ax,%ax

008023e0 <__udivdi3>:
  8023e0:	55                   	push   %ebp
  8023e1:	57                   	push   %edi
  8023e2:	56                   	push   %esi
  8023e3:	53                   	push   %ebx
  8023e4:	83 ec 1c             	sub    $0x1c,%esp
  8023e7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8023eb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8023ef:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8023f3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023f7:	85 f6                	test   %esi,%esi
  8023f9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023fd:	89 ca                	mov    %ecx,%edx
  8023ff:	89 f8                	mov    %edi,%eax
  802401:	75 3d                	jne    802440 <__udivdi3+0x60>
  802403:	39 cf                	cmp    %ecx,%edi
  802405:	0f 87 c5 00 00 00    	ja     8024d0 <__udivdi3+0xf0>
  80240b:	85 ff                	test   %edi,%edi
  80240d:	89 fd                	mov    %edi,%ebp
  80240f:	75 0b                	jne    80241c <__udivdi3+0x3c>
  802411:	b8 01 00 00 00       	mov    $0x1,%eax
  802416:	31 d2                	xor    %edx,%edx
  802418:	f7 f7                	div    %edi
  80241a:	89 c5                	mov    %eax,%ebp
  80241c:	89 c8                	mov    %ecx,%eax
  80241e:	31 d2                	xor    %edx,%edx
  802420:	f7 f5                	div    %ebp
  802422:	89 c1                	mov    %eax,%ecx
  802424:	89 d8                	mov    %ebx,%eax
  802426:	89 cf                	mov    %ecx,%edi
  802428:	f7 f5                	div    %ebp
  80242a:	89 c3                	mov    %eax,%ebx
  80242c:	89 d8                	mov    %ebx,%eax
  80242e:	89 fa                	mov    %edi,%edx
  802430:	83 c4 1c             	add    $0x1c,%esp
  802433:	5b                   	pop    %ebx
  802434:	5e                   	pop    %esi
  802435:	5f                   	pop    %edi
  802436:	5d                   	pop    %ebp
  802437:	c3                   	ret    
  802438:	90                   	nop
  802439:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802440:	39 ce                	cmp    %ecx,%esi
  802442:	77 74                	ja     8024b8 <__udivdi3+0xd8>
  802444:	0f bd fe             	bsr    %esi,%edi
  802447:	83 f7 1f             	xor    $0x1f,%edi
  80244a:	0f 84 98 00 00 00    	je     8024e8 <__udivdi3+0x108>
  802450:	bb 20 00 00 00       	mov    $0x20,%ebx
  802455:	89 f9                	mov    %edi,%ecx
  802457:	89 c5                	mov    %eax,%ebp
  802459:	29 fb                	sub    %edi,%ebx
  80245b:	d3 e6                	shl    %cl,%esi
  80245d:	89 d9                	mov    %ebx,%ecx
  80245f:	d3 ed                	shr    %cl,%ebp
  802461:	89 f9                	mov    %edi,%ecx
  802463:	d3 e0                	shl    %cl,%eax
  802465:	09 ee                	or     %ebp,%esi
  802467:	89 d9                	mov    %ebx,%ecx
  802469:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80246d:	89 d5                	mov    %edx,%ebp
  80246f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802473:	d3 ed                	shr    %cl,%ebp
  802475:	89 f9                	mov    %edi,%ecx
  802477:	d3 e2                	shl    %cl,%edx
  802479:	89 d9                	mov    %ebx,%ecx
  80247b:	d3 e8                	shr    %cl,%eax
  80247d:	09 c2                	or     %eax,%edx
  80247f:	89 d0                	mov    %edx,%eax
  802481:	89 ea                	mov    %ebp,%edx
  802483:	f7 f6                	div    %esi
  802485:	89 d5                	mov    %edx,%ebp
  802487:	89 c3                	mov    %eax,%ebx
  802489:	f7 64 24 0c          	mull   0xc(%esp)
  80248d:	39 d5                	cmp    %edx,%ebp
  80248f:	72 10                	jb     8024a1 <__udivdi3+0xc1>
  802491:	8b 74 24 08          	mov    0x8(%esp),%esi
  802495:	89 f9                	mov    %edi,%ecx
  802497:	d3 e6                	shl    %cl,%esi
  802499:	39 c6                	cmp    %eax,%esi
  80249b:	73 07                	jae    8024a4 <__udivdi3+0xc4>
  80249d:	39 d5                	cmp    %edx,%ebp
  80249f:	75 03                	jne    8024a4 <__udivdi3+0xc4>
  8024a1:	83 eb 01             	sub    $0x1,%ebx
  8024a4:	31 ff                	xor    %edi,%edi
  8024a6:	89 d8                	mov    %ebx,%eax
  8024a8:	89 fa                	mov    %edi,%edx
  8024aa:	83 c4 1c             	add    $0x1c,%esp
  8024ad:	5b                   	pop    %ebx
  8024ae:	5e                   	pop    %esi
  8024af:	5f                   	pop    %edi
  8024b0:	5d                   	pop    %ebp
  8024b1:	c3                   	ret    
  8024b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024b8:	31 ff                	xor    %edi,%edi
  8024ba:	31 db                	xor    %ebx,%ebx
  8024bc:	89 d8                	mov    %ebx,%eax
  8024be:	89 fa                	mov    %edi,%edx
  8024c0:	83 c4 1c             	add    $0x1c,%esp
  8024c3:	5b                   	pop    %ebx
  8024c4:	5e                   	pop    %esi
  8024c5:	5f                   	pop    %edi
  8024c6:	5d                   	pop    %ebp
  8024c7:	c3                   	ret    
  8024c8:	90                   	nop
  8024c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024d0:	89 d8                	mov    %ebx,%eax
  8024d2:	f7 f7                	div    %edi
  8024d4:	31 ff                	xor    %edi,%edi
  8024d6:	89 c3                	mov    %eax,%ebx
  8024d8:	89 d8                	mov    %ebx,%eax
  8024da:	89 fa                	mov    %edi,%edx
  8024dc:	83 c4 1c             	add    $0x1c,%esp
  8024df:	5b                   	pop    %ebx
  8024e0:	5e                   	pop    %esi
  8024e1:	5f                   	pop    %edi
  8024e2:	5d                   	pop    %ebp
  8024e3:	c3                   	ret    
  8024e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024e8:	39 ce                	cmp    %ecx,%esi
  8024ea:	72 0c                	jb     8024f8 <__udivdi3+0x118>
  8024ec:	31 db                	xor    %ebx,%ebx
  8024ee:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8024f2:	0f 87 34 ff ff ff    	ja     80242c <__udivdi3+0x4c>
  8024f8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8024fd:	e9 2a ff ff ff       	jmp    80242c <__udivdi3+0x4c>
  802502:	66 90                	xchg   %ax,%ax
  802504:	66 90                	xchg   %ax,%ax
  802506:	66 90                	xchg   %ax,%ax
  802508:	66 90                	xchg   %ax,%ax
  80250a:	66 90                	xchg   %ax,%ax
  80250c:	66 90                	xchg   %ax,%ax
  80250e:	66 90                	xchg   %ax,%ax

00802510 <__umoddi3>:
  802510:	55                   	push   %ebp
  802511:	57                   	push   %edi
  802512:	56                   	push   %esi
  802513:	53                   	push   %ebx
  802514:	83 ec 1c             	sub    $0x1c,%esp
  802517:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80251b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80251f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802523:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802527:	85 d2                	test   %edx,%edx
  802529:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80252d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802531:	89 f3                	mov    %esi,%ebx
  802533:	89 3c 24             	mov    %edi,(%esp)
  802536:	89 74 24 04          	mov    %esi,0x4(%esp)
  80253a:	75 1c                	jne    802558 <__umoddi3+0x48>
  80253c:	39 f7                	cmp    %esi,%edi
  80253e:	76 50                	jbe    802590 <__umoddi3+0x80>
  802540:	89 c8                	mov    %ecx,%eax
  802542:	89 f2                	mov    %esi,%edx
  802544:	f7 f7                	div    %edi
  802546:	89 d0                	mov    %edx,%eax
  802548:	31 d2                	xor    %edx,%edx
  80254a:	83 c4 1c             	add    $0x1c,%esp
  80254d:	5b                   	pop    %ebx
  80254e:	5e                   	pop    %esi
  80254f:	5f                   	pop    %edi
  802550:	5d                   	pop    %ebp
  802551:	c3                   	ret    
  802552:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802558:	39 f2                	cmp    %esi,%edx
  80255a:	89 d0                	mov    %edx,%eax
  80255c:	77 52                	ja     8025b0 <__umoddi3+0xa0>
  80255e:	0f bd ea             	bsr    %edx,%ebp
  802561:	83 f5 1f             	xor    $0x1f,%ebp
  802564:	75 5a                	jne    8025c0 <__umoddi3+0xb0>
  802566:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80256a:	0f 82 e0 00 00 00    	jb     802650 <__umoddi3+0x140>
  802570:	39 0c 24             	cmp    %ecx,(%esp)
  802573:	0f 86 d7 00 00 00    	jbe    802650 <__umoddi3+0x140>
  802579:	8b 44 24 08          	mov    0x8(%esp),%eax
  80257d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802581:	83 c4 1c             	add    $0x1c,%esp
  802584:	5b                   	pop    %ebx
  802585:	5e                   	pop    %esi
  802586:	5f                   	pop    %edi
  802587:	5d                   	pop    %ebp
  802588:	c3                   	ret    
  802589:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802590:	85 ff                	test   %edi,%edi
  802592:	89 fd                	mov    %edi,%ebp
  802594:	75 0b                	jne    8025a1 <__umoddi3+0x91>
  802596:	b8 01 00 00 00       	mov    $0x1,%eax
  80259b:	31 d2                	xor    %edx,%edx
  80259d:	f7 f7                	div    %edi
  80259f:	89 c5                	mov    %eax,%ebp
  8025a1:	89 f0                	mov    %esi,%eax
  8025a3:	31 d2                	xor    %edx,%edx
  8025a5:	f7 f5                	div    %ebp
  8025a7:	89 c8                	mov    %ecx,%eax
  8025a9:	f7 f5                	div    %ebp
  8025ab:	89 d0                	mov    %edx,%eax
  8025ad:	eb 99                	jmp    802548 <__umoddi3+0x38>
  8025af:	90                   	nop
  8025b0:	89 c8                	mov    %ecx,%eax
  8025b2:	89 f2                	mov    %esi,%edx
  8025b4:	83 c4 1c             	add    $0x1c,%esp
  8025b7:	5b                   	pop    %ebx
  8025b8:	5e                   	pop    %esi
  8025b9:	5f                   	pop    %edi
  8025ba:	5d                   	pop    %ebp
  8025bb:	c3                   	ret    
  8025bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025c0:	8b 34 24             	mov    (%esp),%esi
  8025c3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025c8:	89 e9                	mov    %ebp,%ecx
  8025ca:	29 ef                	sub    %ebp,%edi
  8025cc:	d3 e0                	shl    %cl,%eax
  8025ce:	89 f9                	mov    %edi,%ecx
  8025d0:	89 f2                	mov    %esi,%edx
  8025d2:	d3 ea                	shr    %cl,%edx
  8025d4:	89 e9                	mov    %ebp,%ecx
  8025d6:	09 c2                	or     %eax,%edx
  8025d8:	89 d8                	mov    %ebx,%eax
  8025da:	89 14 24             	mov    %edx,(%esp)
  8025dd:	89 f2                	mov    %esi,%edx
  8025df:	d3 e2                	shl    %cl,%edx
  8025e1:	89 f9                	mov    %edi,%ecx
  8025e3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025e7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8025eb:	d3 e8                	shr    %cl,%eax
  8025ed:	89 e9                	mov    %ebp,%ecx
  8025ef:	89 c6                	mov    %eax,%esi
  8025f1:	d3 e3                	shl    %cl,%ebx
  8025f3:	89 f9                	mov    %edi,%ecx
  8025f5:	89 d0                	mov    %edx,%eax
  8025f7:	d3 e8                	shr    %cl,%eax
  8025f9:	89 e9                	mov    %ebp,%ecx
  8025fb:	09 d8                	or     %ebx,%eax
  8025fd:	89 d3                	mov    %edx,%ebx
  8025ff:	89 f2                	mov    %esi,%edx
  802601:	f7 34 24             	divl   (%esp)
  802604:	89 d6                	mov    %edx,%esi
  802606:	d3 e3                	shl    %cl,%ebx
  802608:	f7 64 24 04          	mull   0x4(%esp)
  80260c:	39 d6                	cmp    %edx,%esi
  80260e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802612:	89 d1                	mov    %edx,%ecx
  802614:	89 c3                	mov    %eax,%ebx
  802616:	72 08                	jb     802620 <__umoddi3+0x110>
  802618:	75 11                	jne    80262b <__umoddi3+0x11b>
  80261a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80261e:	73 0b                	jae    80262b <__umoddi3+0x11b>
  802620:	2b 44 24 04          	sub    0x4(%esp),%eax
  802624:	1b 14 24             	sbb    (%esp),%edx
  802627:	89 d1                	mov    %edx,%ecx
  802629:	89 c3                	mov    %eax,%ebx
  80262b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80262f:	29 da                	sub    %ebx,%edx
  802631:	19 ce                	sbb    %ecx,%esi
  802633:	89 f9                	mov    %edi,%ecx
  802635:	89 f0                	mov    %esi,%eax
  802637:	d3 e0                	shl    %cl,%eax
  802639:	89 e9                	mov    %ebp,%ecx
  80263b:	d3 ea                	shr    %cl,%edx
  80263d:	89 e9                	mov    %ebp,%ecx
  80263f:	d3 ee                	shr    %cl,%esi
  802641:	09 d0                	or     %edx,%eax
  802643:	89 f2                	mov    %esi,%edx
  802645:	83 c4 1c             	add    $0x1c,%esp
  802648:	5b                   	pop    %ebx
  802649:	5e                   	pop    %esi
  80264a:	5f                   	pop    %edi
  80264b:	5d                   	pop    %ebp
  80264c:	c3                   	ret    
  80264d:	8d 76 00             	lea    0x0(%esi),%esi
  802650:	29 f9                	sub    %edi,%ecx
  802652:	19 d6                	sbb    %edx,%esi
  802654:	89 74 24 04          	mov    %esi,0x4(%esp)
  802658:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80265c:	e9 18 ff ff ff       	jmp    802579 <__umoddi3+0x69>
