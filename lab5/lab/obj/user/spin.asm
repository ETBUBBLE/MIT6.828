
obj/user/spin.debug：     文件格式 elf32-i386


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
  80002c:	e8 84 00 00 00       	call   8000b5 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 10             	sub    $0x10,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  80003a:	68 c0 21 80 00       	push   $0x8021c0
  80003f:	e8 64 01 00 00       	call   8001a8 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 49 0e 00 00       	call   800e92 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 38 22 80 00       	push   $0x802238
  800058:	e8 4b 01 00 00       	call   8001a8 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 e8 21 80 00       	push   $0x8021e8
  80006c:	e8 37 01 00 00       	call   8001a8 <cprintf>
	sys_yield();
  800071:	e8 1a 0b 00 00       	call   800b90 <sys_yield>
	sys_yield();
  800076:	e8 15 0b 00 00       	call   800b90 <sys_yield>
	sys_yield();
  80007b:	e8 10 0b 00 00       	call   800b90 <sys_yield>
	sys_yield();
  800080:	e8 0b 0b 00 00       	call   800b90 <sys_yield>
	sys_yield();
  800085:	e8 06 0b 00 00       	call   800b90 <sys_yield>
	sys_yield();
  80008a:	e8 01 0b 00 00       	call   800b90 <sys_yield>
	sys_yield();
  80008f:	e8 fc 0a 00 00       	call   800b90 <sys_yield>
	sys_yield();
  800094:	e8 f7 0a 00 00       	call   800b90 <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  800099:	c7 04 24 10 22 80 00 	movl   $0x802210,(%esp)
  8000a0:	e8 03 01 00 00       	call   8001a8 <cprintf>
	sys_env_destroy(env);
  8000a5:	89 1c 24             	mov    %ebx,(%esp)
  8000a8:	e8 83 0a 00 00       	call   800b30 <sys_env_destroy>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8000b3:	c9                   	leave  
  8000b4:	c3                   	ret    

008000b5 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000b5:	55                   	push   %ebp
  8000b6:	89 e5                	mov    %esp,%ebp
  8000b8:	56                   	push   %esi
  8000b9:	53                   	push   %ebx
  8000ba:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000bd:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8000c0:	e8 ac 0a 00 00       	call   800b71 <sys_getenvid>
  8000c5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ca:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000cd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000d2:	a3 04 40 80 00       	mov    %eax,0x804004

    // save the name of the program so that panic() can use it
    if (argc > 0)
  8000d7:	85 db                	test   %ebx,%ebx
  8000d9:	7e 07                	jle    8000e2 <libmain+0x2d>
        binaryname = argv[0];
  8000db:	8b 06                	mov    (%esi),%eax
  8000dd:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  8000e2:	83 ec 08             	sub    $0x8,%esp
  8000e5:	56                   	push   %esi
  8000e6:	53                   	push   %ebx
  8000e7:	e8 47 ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  8000ec:	e8 0a 00 00 00       	call   8000fb <exit>
}
  8000f1:	83 c4 10             	add    $0x10,%esp
  8000f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5d                   	pop    %ebp
  8000fa:	c3                   	ret    

008000fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800101:	e8 04 11 00 00       	call   80120a <close_all>
	sys_env_destroy(0);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	6a 00                	push   $0x0
  80010b:	e8 20 0a 00 00       	call   800b30 <sys_env_destroy>
}
  800110:	83 c4 10             	add    $0x10,%esp
  800113:	c9                   	leave  
  800114:	c3                   	ret    

00800115 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	53                   	push   %ebx
  800119:	83 ec 04             	sub    $0x4,%esp
  80011c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80011f:	8b 13                	mov    (%ebx),%edx
  800121:	8d 42 01             	lea    0x1(%edx),%eax
  800124:	89 03                	mov    %eax,(%ebx)
  800126:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800129:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80012d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800132:	75 1a                	jne    80014e <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800134:	83 ec 08             	sub    $0x8,%esp
  800137:	68 ff 00 00 00       	push   $0xff
  80013c:	8d 43 08             	lea    0x8(%ebx),%eax
  80013f:	50                   	push   %eax
  800140:	e8 ae 09 00 00       	call   800af3 <sys_cputs>
		b->idx = 0;
  800145:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80014b:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80014e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800152:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800155:	c9                   	leave  
  800156:	c3                   	ret    

00800157 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800160:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800167:	00 00 00 
	b.cnt = 0;
  80016a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800171:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800174:	ff 75 0c             	pushl  0xc(%ebp)
  800177:	ff 75 08             	pushl  0x8(%ebp)
  80017a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	68 15 01 80 00       	push   $0x800115
  800186:	e8 1a 01 00 00       	call   8002a5 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80018b:	83 c4 08             	add    $0x8,%esp
  80018e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800194:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80019a:	50                   	push   %eax
  80019b:	e8 53 09 00 00       	call   800af3 <sys_cputs>

	return b.cnt;
}
  8001a0:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001a6:	c9                   	leave  
  8001a7:	c3                   	ret    

008001a8 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ae:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001b1:	50                   	push   %eax
  8001b2:	ff 75 08             	pushl  0x8(%ebp)
  8001b5:	e8 9d ff ff ff       	call   800157 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001ba:	c9                   	leave  
  8001bb:	c3                   	ret    

008001bc <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001bc:	55                   	push   %ebp
  8001bd:	89 e5                	mov    %esp,%ebp
  8001bf:	57                   	push   %edi
  8001c0:	56                   	push   %esi
  8001c1:	53                   	push   %ebx
  8001c2:	83 ec 1c             	sub    $0x1c,%esp
  8001c5:	89 c7                	mov    %eax,%edi
  8001c7:	89 d6                	mov    %edx,%esi
  8001c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001d5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001d8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001dd:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001e0:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001e3:	39 d3                	cmp    %edx,%ebx
  8001e5:	72 05                	jb     8001ec <printnum+0x30>
  8001e7:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001ea:	77 45                	ja     800231 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001ec:	83 ec 0c             	sub    $0xc,%esp
  8001ef:	ff 75 18             	pushl  0x18(%ebp)
  8001f2:	8b 45 14             	mov    0x14(%ebp),%eax
  8001f5:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8001f8:	53                   	push   %ebx
  8001f9:	ff 75 10             	pushl  0x10(%ebp)
  8001fc:	83 ec 08             	sub    $0x8,%esp
  8001ff:	ff 75 e4             	pushl  -0x1c(%ebp)
  800202:	ff 75 e0             	pushl  -0x20(%ebp)
  800205:	ff 75 dc             	pushl  -0x24(%ebp)
  800208:	ff 75 d8             	pushl  -0x28(%ebp)
  80020b:	e8 20 1d 00 00       	call   801f30 <__udivdi3>
  800210:	83 c4 18             	add    $0x18,%esp
  800213:	52                   	push   %edx
  800214:	50                   	push   %eax
  800215:	89 f2                	mov    %esi,%edx
  800217:	89 f8                	mov    %edi,%eax
  800219:	e8 9e ff ff ff       	call   8001bc <printnum>
  80021e:	83 c4 20             	add    $0x20,%esp
  800221:	eb 18                	jmp    80023b <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	83 ec 08             	sub    $0x8,%esp
  800226:	56                   	push   %esi
  800227:	ff 75 18             	pushl  0x18(%ebp)
  80022a:	ff d7                	call   *%edi
  80022c:	83 c4 10             	add    $0x10,%esp
  80022f:	eb 03                	jmp    800234 <printnum+0x78>
  800231:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800234:	83 eb 01             	sub    $0x1,%ebx
  800237:	85 db                	test   %ebx,%ebx
  800239:	7f e8                	jg     800223 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80023b:	83 ec 08             	sub    $0x8,%esp
  80023e:	56                   	push   %esi
  80023f:	83 ec 04             	sub    $0x4,%esp
  800242:	ff 75 e4             	pushl  -0x1c(%ebp)
  800245:	ff 75 e0             	pushl  -0x20(%ebp)
  800248:	ff 75 dc             	pushl  -0x24(%ebp)
  80024b:	ff 75 d8             	pushl  -0x28(%ebp)
  80024e:	e8 0d 1e 00 00       	call   802060 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 80 60 22 80 00 	movsbl 0x802260(%eax),%eax
  80025d:	50                   	push   %eax
  80025e:	ff d7                	call   *%edi
}
  800260:	83 c4 10             	add    $0x10,%esp
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800271:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800275:	8b 10                	mov    (%eax),%edx
  800277:	3b 50 04             	cmp    0x4(%eax),%edx
  80027a:	73 0a                	jae    800286 <sprintputch+0x1b>
		*b->buf++ = ch;
  80027c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80027f:	89 08                	mov    %ecx,(%eax)
  800281:	8b 45 08             	mov    0x8(%ebp),%eax
  800284:	88 02                	mov    %al,(%edx)
}
  800286:	5d                   	pop    %ebp
  800287:	c3                   	ret    

00800288 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800288:	55                   	push   %ebp
  800289:	89 e5                	mov    %esp,%ebp
  80028b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80028e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800291:	50                   	push   %eax
  800292:	ff 75 10             	pushl  0x10(%ebp)
  800295:	ff 75 0c             	pushl  0xc(%ebp)
  800298:	ff 75 08             	pushl  0x8(%ebp)
  80029b:	e8 05 00 00 00       	call   8002a5 <vprintfmt>
	va_end(ap);
}
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 2c             	sub    $0x2c,%esp
  8002ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8002b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002b4:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002b7:	eb 12                	jmp    8002cb <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002b9:	85 c0                	test   %eax,%eax
  8002bb:	0f 84 42 04 00 00    	je     800703 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002c1:	83 ec 08             	sub    $0x8,%esp
  8002c4:	53                   	push   %ebx
  8002c5:	50                   	push   %eax
  8002c6:	ff d6                	call   *%esi
  8002c8:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002cb:	83 c7 01             	add    $0x1,%edi
  8002ce:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002d2:	83 f8 25             	cmp    $0x25,%eax
  8002d5:	75 e2                	jne    8002b9 <vprintfmt+0x14>
  8002d7:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002db:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002e2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002e9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002f0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002f5:	eb 07                	jmp    8002fe <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8002fa:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8002fe:	8d 47 01             	lea    0x1(%edi),%eax
  800301:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800304:	0f b6 07             	movzbl (%edi),%eax
  800307:	0f b6 d0             	movzbl %al,%edx
  80030a:	83 e8 23             	sub    $0x23,%eax
  80030d:	3c 55                	cmp    $0x55,%al
  80030f:	0f 87 d3 03 00 00    	ja     8006e8 <vprintfmt+0x443>
  800315:	0f b6 c0             	movzbl %al,%eax
  800318:	ff 24 85 a0 23 80 00 	jmp    *0x8023a0(,%eax,4)
  80031f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800322:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800326:	eb d6                	jmp    8002fe <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800328:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80032b:	b8 00 00 00 00       	mov    $0x0,%eax
  800330:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800333:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800336:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80033a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80033d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800340:	83 f9 09             	cmp    $0x9,%ecx
  800343:	77 3f                	ja     800384 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800345:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800348:	eb e9                	jmp    800333 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80034a:	8b 45 14             	mov    0x14(%ebp),%eax
  80034d:	8b 00                	mov    (%eax),%eax
  80034f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800352:	8b 45 14             	mov    0x14(%ebp),%eax
  800355:	8d 40 04             	lea    0x4(%eax),%eax
  800358:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80035b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80035e:	eb 2a                	jmp    80038a <vprintfmt+0xe5>
  800360:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800363:	85 c0                	test   %eax,%eax
  800365:	ba 00 00 00 00       	mov    $0x0,%edx
  80036a:	0f 49 d0             	cmovns %eax,%edx
  80036d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800370:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800373:	eb 89                	jmp    8002fe <vprintfmt+0x59>
  800375:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800378:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80037f:	e9 7a ff ff ff       	jmp    8002fe <vprintfmt+0x59>
  800384:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800387:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80038a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80038e:	0f 89 6a ff ff ff    	jns    8002fe <vprintfmt+0x59>
				width = precision, precision = -1;
  800394:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800397:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003a1:	e9 58 ff ff ff       	jmp    8002fe <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003a6:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003a9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003ac:	e9 4d ff ff ff       	jmp    8002fe <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8003b4:	8d 78 04             	lea    0x4(%eax),%edi
  8003b7:	83 ec 08             	sub    $0x8,%esp
  8003ba:	53                   	push   %ebx
  8003bb:	ff 30                	pushl  (%eax)
  8003bd:	ff d6                	call   *%esi
			break;
  8003bf:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003c2:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003c8:	e9 fe fe ff ff       	jmp    8002cb <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003d0:	8d 78 04             	lea    0x4(%eax),%edi
  8003d3:	8b 00                	mov    (%eax),%eax
  8003d5:	99                   	cltd   
  8003d6:	31 d0                	xor    %edx,%eax
  8003d8:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003da:	83 f8 0f             	cmp    $0xf,%eax
  8003dd:	7f 0b                	jg     8003ea <vprintfmt+0x145>
  8003df:	8b 14 85 00 25 80 00 	mov    0x802500(,%eax,4),%edx
  8003e6:	85 d2                	test   %edx,%edx
  8003e8:	75 1b                	jne    800405 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003ea:	50                   	push   %eax
  8003eb:	68 78 22 80 00       	push   $0x802278
  8003f0:	53                   	push   %ebx
  8003f1:	56                   	push   %esi
  8003f2:	e8 91 fe ff ff       	call   800288 <printfmt>
  8003f7:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003fa:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800400:	e9 c6 fe ff ff       	jmp    8002cb <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800405:	52                   	push   %edx
  800406:	68 d5 26 80 00       	push   $0x8026d5
  80040b:	53                   	push   %ebx
  80040c:	56                   	push   %esi
  80040d:	e8 76 fe ff ff       	call   800288 <printfmt>
  800412:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800415:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800418:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80041b:	e9 ab fe ff ff       	jmp    8002cb <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	83 c0 04             	add    $0x4,%eax
  800426:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800429:	8b 45 14             	mov    0x14(%ebp),%eax
  80042c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80042e:	85 ff                	test   %edi,%edi
  800430:	b8 71 22 80 00       	mov    $0x802271,%eax
  800435:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800438:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80043c:	0f 8e 94 00 00 00    	jle    8004d6 <vprintfmt+0x231>
  800442:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800446:	0f 84 98 00 00 00    	je     8004e4 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80044c:	83 ec 08             	sub    $0x8,%esp
  80044f:	ff 75 d0             	pushl  -0x30(%ebp)
  800452:	57                   	push   %edi
  800453:	e8 33 03 00 00       	call   80078b <strnlen>
  800458:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80045b:	29 c1                	sub    %eax,%ecx
  80045d:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800460:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800463:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800467:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80046a:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80046d:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80046f:	eb 0f                	jmp    800480 <vprintfmt+0x1db>
					putch(padc, putdat);
  800471:	83 ec 08             	sub    $0x8,%esp
  800474:	53                   	push   %ebx
  800475:	ff 75 e0             	pushl  -0x20(%ebp)
  800478:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047a:	83 ef 01             	sub    $0x1,%edi
  80047d:	83 c4 10             	add    $0x10,%esp
  800480:	85 ff                	test   %edi,%edi
  800482:	7f ed                	jg     800471 <vprintfmt+0x1cc>
  800484:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800487:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80048a:	85 c9                	test   %ecx,%ecx
  80048c:	b8 00 00 00 00       	mov    $0x0,%eax
  800491:	0f 49 c1             	cmovns %ecx,%eax
  800494:	29 c1                	sub    %eax,%ecx
  800496:	89 75 08             	mov    %esi,0x8(%ebp)
  800499:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80049c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80049f:	89 cb                	mov    %ecx,%ebx
  8004a1:	eb 4d                	jmp    8004f0 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004a3:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004a7:	74 1b                	je     8004c4 <vprintfmt+0x21f>
  8004a9:	0f be c0             	movsbl %al,%eax
  8004ac:	83 e8 20             	sub    $0x20,%eax
  8004af:	83 f8 5e             	cmp    $0x5e,%eax
  8004b2:	76 10                	jbe    8004c4 <vprintfmt+0x21f>
					putch('?', putdat);
  8004b4:	83 ec 08             	sub    $0x8,%esp
  8004b7:	ff 75 0c             	pushl  0xc(%ebp)
  8004ba:	6a 3f                	push   $0x3f
  8004bc:	ff 55 08             	call   *0x8(%ebp)
  8004bf:	83 c4 10             	add    $0x10,%esp
  8004c2:	eb 0d                	jmp    8004d1 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004c4:	83 ec 08             	sub    $0x8,%esp
  8004c7:	ff 75 0c             	pushl  0xc(%ebp)
  8004ca:	52                   	push   %edx
  8004cb:	ff 55 08             	call   *0x8(%ebp)
  8004ce:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d1:	83 eb 01             	sub    $0x1,%ebx
  8004d4:	eb 1a                	jmp    8004f0 <vprintfmt+0x24b>
  8004d6:	89 75 08             	mov    %esi,0x8(%ebp)
  8004d9:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004dc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004df:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004e2:	eb 0c                	jmp    8004f0 <vprintfmt+0x24b>
  8004e4:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e7:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004ea:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ed:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004f0:	83 c7 01             	add    $0x1,%edi
  8004f3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004f7:	0f be d0             	movsbl %al,%edx
  8004fa:	85 d2                	test   %edx,%edx
  8004fc:	74 23                	je     800521 <vprintfmt+0x27c>
  8004fe:	85 f6                	test   %esi,%esi
  800500:	78 a1                	js     8004a3 <vprintfmt+0x1fe>
  800502:	83 ee 01             	sub    $0x1,%esi
  800505:	79 9c                	jns    8004a3 <vprintfmt+0x1fe>
  800507:	89 df                	mov    %ebx,%edi
  800509:	8b 75 08             	mov    0x8(%ebp),%esi
  80050c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80050f:	eb 18                	jmp    800529 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800511:	83 ec 08             	sub    $0x8,%esp
  800514:	53                   	push   %ebx
  800515:	6a 20                	push   $0x20
  800517:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800519:	83 ef 01             	sub    $0x1,%edi
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	eb 08                	jmp    800529 <vprintfmt+0x284>
  800521:	89 df                	mov    %ebx,%edi
  800523:	8b 75 08             	mov    0x8(%ebp),%esi
  800526:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800529:	85 ff                	test   %edi,%edi
  80052b:	7f e4                	jg     800511 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80052d:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800530:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800533:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800536:	e9 90 fd ff ff       	jmp    8002cb <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80053b:	83 f9 01             	cmp    $0x1,%ecx
  80053e:	7e 19                	jle    800559 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8b 50 04             	mov    0x4(%eax),%edx
  800546:	8b 00                	mov    (%eax),%eax
  800548:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80054b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80054e:	8b 45 14             	mov    0x14(%ebp),%eax
  800551:	8d 40 08             	lea    0x8(%eax),%eax
  800554:	89 45 14             	mov    %eax,0x14(%ebp)
  800557:	eb 38                	jmp    800591 <vprintfmt+0x2ec>
	else if (lflag)
  800559:	85 c9                	test   %ecx,%ecx
  80055b:	74 1b                	je     800578 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  80055d:	8b 45 14             	mov    0x14(%ebp),%eax
  800560:	8b 00                	mov    (%eax),%eax
  800562:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800565:	89 c1                	mov    %eax,%ecx
  800567:	c1 f9 1f             	sar    $0x1f,%ecx
  80056a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80056d:	8b 45 14             	mov    0x14(%ebp),%eax
  800570:	8d 40 04             	lea    0x4(%eax),%eax
  800573:	89 45 14             	mov    %eax,0x14(%ebp)
  800576:	eb 19                	jmp    800591 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800578:	8b 45 14             	mov    0x14(%ebp),%eax
  80057b:	8b 00                	mov    (%eax),%eax
  80057d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800580:	89 c1                	mov    %eax,%ecx
  800582:	c1 f9 1f             	sar    $0x1f,%ecx
  800585:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800588:	8b 45 14             	mov    0x14(%ebp),%eax
  80058b:	8d 40 04             	lea    0x4(%eax),%eax
  80058e:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800591:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800594:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800597:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  80059c:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005a0:	0f 89 0e 01 00 00    	jns    8006b4 <vprintfmt+0x40f>
				putch('-', putdat);
  8005a6:	83 ec 08             	sub    $0x8,%esp
  8005a9:	53                   	push   %ebx
  8005aa:	6a 2d                	push   $0x2d
  8005ac:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ae:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005b4:	f7 da                	neg    %edx
  8005b6:	83 d1 00             	adc    $0x0,%ecx
  8005b9:	f7 d9                	neg    %ecx
  8005bb:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c3:	e9 ec 00 00 00       	jmp    8006b4 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005c8:	83 f9 01             	cmp    $0x1,%ecx
  8005cb:	7e 18                	jle    8005e5 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005cd:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d0:	8b 10                	mov    (%eax),%edx
  8005d2:	8b 48 04             	mov    0x4(%eax),%ecx
  8005d5:	8d 40 08             	lea    0x8(%eax),%eax
  8005d8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005db:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e0:	e9 cf 00 00 00       	jmp    8006b4 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005e5:	85 c9                	test   %ecx,%ecx
  8005e7:	74 1a                	je     800603 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005e9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ec:	8b 10                	mov    (%eax),%edx
  8005ee:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005f3:	8d 40 04             	lea    0x4(%eax),%eax
  8005f6:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005fe:	e9 b1 00 00 00       	jmp    8006b4 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800603:	8b 45 14             	mov    0x14(%ebp),%eax
  800606:	8b 10                	mov    (%eax),%edx
  800608:	b9 00 00 00 00       	mov    $0x0,%ecx
  80060d:	8d 40 04             	lea    0x4(%eax),%eax
  800610:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800613:	b8 0a 00 00 00       	mov    $0xa,%eax
  800618:	e9 97 00 00 00       	jmp    8006b4 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	53                   	push   %ebx
  800621:	6a 58                	push   $0x58
  800623:	ff d6                	call   *%esi
			putch('X', putdat);
  800625:	83 c4 08             	add    $0x8,%esp
  800628:	53                   	push   %ebx
  800629:	6a 58                	push   $0x58
  80062b:	ff d6                	call   *%esi
			putch('X', putdat);
  80062d:	83 c4 08             	add    $0x8,%esp
  800630:	53                   	push   %ebx
  800631:	6a 58                	push   $0x58
  800633:	ff d6                	call   *%esi
			break;
  800635:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800638:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80063b:	e9 8b fc ff ff       	jmp    8002cb <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	53                   	push   %ebx
  800644:	6a 30                	push   $0x30
  800646:	ff d6                	call   *%esi
			putch('x', putdat);
  800648:	83 c4 08             	add    $0x8,%esp
  80064b:	53                   	push   %ebx
  80064c:	6a 78                	push   $0x78
  80064e:	ff d6                	call   *%esi
			num = (unsigned long long)
  800650:	8b 45 14             	mov    0x14(%ebp),%eax
  800653:	8b 10                	mov    (%eax),%edx
  800655:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80065a:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80065d:	8d 40 04             	lea    0x4(%eax),%eax
  800660:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800663:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800668:	eb 4a                	jmp    8006b4 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066a:	83 f9 01             	cmp    $0x1,%ecx
  80066d:	7e 15                	jle    800684 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80066f:	8b 45 14             	mov    0x14(%ebp),%eax
  800672:	8b 10                	mov    (%eax),%edx
  800674:	8b 48 04             	mov    0x4(%eax),%ecx
  800677:	8d 40 08             	lea    0x8(%eax),%eax
  80067a:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  80067d:	b8 10 00 00 00       	mov    $0x10,%eax
  800682:	eb 30                	jmp    8006b4 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800684:	85 c9                	test   %ecx,%ecx
  800686:	74 17                	je     80069f <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800688:	8b 45 14             	mov    0x14(%ebp),%eax
  80068b:	8b 10                	mov    (%eax),%edx
  80068d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800692:	8d 40 04             	lea    0x4(%eax),%eax
  800695:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800698:	b8 10 00 00 00       	mov    $0x10,%eax
  80069d:	eb 15                	jmp    8006b4 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80069f:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a2:	8b 10                	mov    (%eax),%edx
  8006a4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006a9:	8d 40 04             	lea    0x4(%eax),%eax
  8006ac:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006af:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b4:	83 ec 0c             	sub    $0xc,%esp
  8006b7:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006bb:	57                   	push   %edi
  8006bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8006bf:	50                   	push   %eax
  8006c0:	51                   	push   %ecx
  8006c1:	52                   	push   %edx
  8006c2:	89 da                	mov    %ebx,%edx
  8006c4:	89 f0                	mov    %esi,%eax
  8006c6:	e8 f1 fa ff ff       	call   8001bc <printnum>
			break;
  8006cb:	83 c4 20             	add    $0x20,%esp
  8006ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006d1:	e9 f5 fb ff ff       	jmp    8002cb <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d6:	83 ec 08             	sub    $0x8,%esp
  8006d9:	53                   	push   %ebx
  8006da:	52                   	push   %edx
  8006db:	ff d6                	call   *%esi
			break;
  8006dd:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006e3:	e9 e3 fb ff ff       	jmp    8002cb <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e8:	83 ec 08             	sub    $0x8,%esp
  8006eb:	53                   	push   %ebx
  8006ec:	6a 25                	push   $0x25
  8006ee:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	eb 03                	jmp    8006f8 <vprintfmt+0x453>
  8006f5:	83 ef 01             	sub    $0x1,%edi
  8006f8:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8006fc:	75 f7                	jne    8006f5 <vprintfmt+0x450>
  8006fe:	e9 c8 fb ff ff       	jmp    8002cb <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800703:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800706:	5b                   	pop    %ebx
  800707:	5e                   	pop    %esi
  800708:	5f                   	pop    %edi
  800709:	5d                   	pop    %ebp
  80070a:	c3                   	ret    

0080070b <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070b:	55                   	push   %ebp
  80070c:	89 e5                	mov    %esp,%ebp
  80070e:	83 ec 18             	sub    $0x18,%esp
  800711:	8b 45 08             	mov    0x8(%ebp),%eax
  800714:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800717:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80071a:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80071e:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800721:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800728:	85 c0                	test   %eax,%eax
  80072a:	74 26                	je     800752 <vsnprintf+0x47>
  80072c:	85 d2                	test   %edx,%edx
  80072e:	7e 22                	jle    800752 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800730:	ff 75 14             	pushl  0x14(%ebp)
  800733:	ff 75 10             	pushl  0x10(%ebp)
  800736:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	68 6b 02 80 00       	push   $0x80026b
  80073f:	e8 61 fb ff ff       	call   8002a5 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800744:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800747:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80074a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80074d:	83 c4 10             	add    $0x10,%esp
  800750:	eb 05                	jmp    800757 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800752:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800757:	c9                   	leave  
  800758:	c3                   	ret    

00800759 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800759:	55                   	push   %ebp
  80075a:	89 e5                	mov    %esp,%ebp
  80075c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80075f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800762:	50                   	push   %eax
  800763:	ff 75 10             	pushl  0x10(%ebp)
  800766:	ff 75 0c             	pushl  0xc(%ebp)
  800769:	ff 75 08             	pushl  0x8(%ebp)
  80076c:	e8 9a ff ff ff       	call   80070b <vsnprintf>
	va_end(ap);

	return rc;
}
  800771:	c9                   	leave  
  800772:	c3                   	ret    

00800773 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800773:	55                   	push   %ebp
  800774:	89 e5                	mov    %esp,%ebp
  800776:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800779:	b8 00 00 00 00       	mov    $0x0,%eax
  80077e:	eb 03                	jmp    800783 <strlen+0x10>
		n++;
  800780:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800783:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800787:	75 f7                	jne    800780 <strlen+0xd>
		n++;
	return n;
}
  800789:	5d                   	pop    %ebp
  80078a:	c3                   	ret    

0080078b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800791:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800794:	ba 00 00 00 00       	mov    $0x0,%edx
  800799:	eb 03                	jmp    80079e <strnlen+0x13>
		n++;
  80079b:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80079e:	39 c2                	cmp    %eax,%edx
  8007a0:	74 08                	je     8007aa <strnlen+0x1f>
  8007a2:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007a6:	75 f3                	jne    80079b <strnlen+0x10>
  8007a8:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007aa:	5d                   	pop    %ebp
  8007ab:	c3                   	ret    

008007ac <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007ac:	55                   	push   %ebp
  8007ad:	89 e5                	mov    %esp,%ebp
  8007af:	53                   	push   %ebx
  8007b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8007b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b6:	89 c2                	mov    %eax,%edx
  8007b8:	83 c2 01             	add    $0x1,%edx
  8007bb:	83 c1 01             	add    $0x1,%ecx
  8007be:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007c2:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007c5:	84 db                	test   %bl,%bl
  8007c7:	75 ef                	jne    8007b8 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007c9:	5b                   	pop    %ebx
  8007ca:	5d                   	pop    %ebp
  8007cb:	c3                   	ret    

008007cc <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007cc:	55                   	push   %ebp
  8007cd:	89 e5                	mov    %esp,%ebp
  8007cf:	53                   	push   %ebx
  8007d0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d3:	53                   	push   %ebx
  8007d4:	e8 9a ff ff ff       	call   800773 <strlen>
  8007d9:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007dc:	ff 75 0c             	pushl  0xc(%ebp)
  8007df:	01 d8                	add    %ebx,%eax
  8007e1:	50                   	push   %eax
  8007e2:	e8 c5 ff ff ff       	call   8007ac <strcpy>
	return dst;
}
  8007e7:	89 d8                	mov    %ebx,%eax
  8007e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ec:	c9                   	leave  
  8007ed:	c3                   	ret    

008007ee <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	56                   	push   %esi
  8007f2:	53                   	push   %ebx
  8007f3:	8b 75 08             	mov    0x8(%ebp),%esi
  8007f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007f9:	89 f3                	mov    %esi,%ebx
  8007fb:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007fe:	89 f2                	mov    %esi,%edx
  800800:	eb 0f                	jmp    800811 <strncpy+0x23>
		*dst++ = *src;
  800802:	83 c2 01             	add    $0x1,%edx
  800805:	0f b6 01             	movzbl (%ecx),%eax
  800808:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80080b:	80 39 01             	cmpb   $0x1,(%ecx)
  80080e:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800811:	39 da                	cmp    %ebx,%edx
  800813:	75 ed                	jne    800802 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800815:	89 f0                	mov    %esi,%eax
  800817:	5b                   	pop    %ebx
  800818:	5e                   	pop    %esi
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	56                   	push   %esi
  80081f:	53                   	push   %ebx
  800820:	8b 75 08             	mov    0x8(%ebp),%esi
  800823:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800826:	8b 55 10             	mov    0x10(%ebp),%edx
  800829:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80082b:	85 d2                	test   %edx,%edx
  80082d:	74 21                	je     800850 <strlcpy+0x35>
  80082f:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800833:	89 f2                	mov    %esi,%edx
  800835:	eb 09                	jmp    800840 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800837:	83 c2 01             	add    $0x1,%edx
  80083a:	83 c1 01             	add    $0x1,%ecx
  80083d:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800840:	39 c2                	cmp    %eax,%edx
  800842:	74 09                	je     80084d <strlcpy+0x32>
  800844:	0f b6 19             	movzbl (%ecx),%ebx
  800847:	84 db                	test   %bl,%bl
  800849:	75 ec                	jne    800837 <strlcpy+0x1c>
  80084b:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80084d:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800850:	29 f0                	sub    %esi,%eax
}
  800852:	5b                   	pop    %ebx
  800853:	5e                   	pop    %esi
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80085c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085f:	eb 06                	jmp    800867 <strcmp+0x11>
		p++, q++;
  800861:	83 c1 01             	add    $0x1,%ecx
  800864:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800867:	0f b6 01             	movzbl (%ecx),%eax
  80086a:	84 c0                	test   %al,%al
  80086c:	74 04                	je     800872 <strcmp+0x1c>
  80086e:	3a 02                	cmp    (%edx),%al
  800870:	74 ef                	je     800861 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800872:	0f b6 c0             	movzbl %al,%eax
  800875:	0f b6 12             	movzbl (%edx),%edx
  800878:	29 d0                	sub    %edx,%eax
}
  80087a:	5d                   	pop    %ebp
  80087b:	c3                   	ret    

0080087c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	53                   	push   %ebx
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	8b 55 0c             	mov    0xc(%ebp),%edx
  800886:	89 c3                	mov    %eax,%ebx
  800888:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088b:	eb 06                	jmp    800893 <strncmp+0x17>
		n--, p++, q++;
  80088d:	83 c0 01             	add    $0x1,%eax
  800890:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800893:	39 d8                	cmp    %ebx,%eax
  800895:	74 15                	je     8008ac <strncmp+0x30>
  800897:	0f b6 08             	movzbl (%eax),%ecx
  80089a:	84 c9                	test   %cl,%cl
  80089c:	74 04                	je     8008a2 <strncmp+0x26>
  80089e:	3a 0a                	cmp    (%edx),%cl
  8008a0:	74 eb                	je     80088d <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a2:	0f b6 00             	movzbl (%eax),%eax
  8008a5:	0f b6 12             	movzbl (%edx),%edx
  8008a8:	29 d0                	sub    %edx,%eax
  8008aa:	eb 05                	jmp    8008b1 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008ac:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008b1:	5b                   	pop    %ebx
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ba:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008be:	eb 07                	jmp    8008c7 <strchr+0x13>
		if (*s == c)
  8008c0:	38 ca                	cmp    %cl,%dl
  8008c2:	74 0f                	je     8008d3 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008c4:	83 c0 01             	add    $0x1,%eax
  8008c7:	0f b6 10             	movzbl (%eax),%edx
  8008ca:	84 d2                	test   %dl,%dl
  8008cc:	75 f2                	jne    8008c0 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008db:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008df:	eb 03                	jmp    8008e4 <strfind+0xf>
  8008e1:	83 c0 01             	add    $0x1,%eax
  8008e4:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008e7:	38 ca                	cmp    %cl,%dl
  8008e9:	74 04                	je     8008ef <strfind+0x1a>
  8008eb:	84 d2                	test   %dl,%dl
  8008ed:	75 f2                	jne    8008e1 <strfind+0xc>
			break;
	return (char *) s;
}
  8008ef:	5d                   	pop    %ebp
  8008f0:	c3                   	ret    

008008f1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f1:	55                   	push   %ebp
  8008f2:	89 e5                	mov    %esp,%ebp
  8008f4:	57                   	push   %edi
  8008f5:	56                   	push   %esi
  8008f6:	53                   	push   %ebx
  8008f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8008fa:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8008fd:	85 c9                	test   %ecx,%ecx
  8008ff:	74 36                	je     800937 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800901:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800907:	75 28                	jne    800931 <memset+0x40>
  800909:	f6 c1 03             	test   $0x3,%cl
  80090c:	75 23                	jne    800931 <memset+0x40>
		c &= 0xFF;
  80090e:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800912:	89 d3                	mov    %edx,%ebx
  800914:	c1 e3 08             	shl    $0x8,%ebx
  800917:	89 d6                	mov    %edx,%esi
  800919:	c1 e6 18             	shl    $0x18,%esi
  80091c:	89 d0                	mov    %edx,%eax
  80091e:	c1 e0 10             	shl    $0x10,%eax
  800921:	09 f0                	or     %esi,%eax
  800923:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800925:	89 d8                	mov    %ebx,%eax
  800927:	09 d0                	or     %edx,%eax
  800929:	c1 e9 02             	shr    $0x2,%ecx
  80092c:	fc                   	cld    
  80092d:	f3 ab                	rep stos %eax,%es:(%edi)
  80092f:	eb 06                	jmp    800937 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800931:	8b 45 0c             	mov    0xc(%ebp),%eax
  800934:	fc                   	cld    
  800935:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800937:	89 f8                	mov    %edi,%eax
  800939:	5b                   	pop    %ebx
  80093a:	5e                   	pop    %esi
  80093b:	5f                   	pop    %edi
  80093c:	5d                   	pop    %ebp
  80093d:	c3                   	ret    

0080093e <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80093e:	55                   	push   %ebp
  80093f:	89 e5                	mov    %esp,%ebp
  800941:	57                   	push   %edi
  800942:	56                   	push   %esi
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	8b 75 0c             	mov    0xc(%ebp),%esi
  800949:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80094c:	39 c6                	cmp    %eax,%esi
  80094e:	73 35                	jae    800985 <memmove+0x47>
  800950:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800953:	39 d0                	cmp    %edx,%eax
  800955:	73 2e                	jae    800985 <memmove+0x47>
		s += n;
		d += n;
  800957:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80095a:	89 d6                	mov    %edx,%esi
  80095c:	09 fe                	or     %edi,%esi
  80095e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800964:	75 13                	jne    800979 <memmove+0x3b>
  800966:	f6 c1 03             	test   $0x3,%cl
  800969:	75 0e                	jne    800979 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80096b:	83 ef 04             	sub    $0x4,%edi
  80096e:	8d 72 fc             	lea    -0x4(%edx),%esi
  800971:	c1 e9 02             	shr    $0x2,%ecx
  800974:	fd                   	std    
  800975:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800977:	eb 09                	jmp    800982 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800979:	83 ef 01             	sub    $0x1,%edi
  80097c:	8d 72 ff             	lea    -0x1(%edx),%esi
  80097f:	fd                   	std    
  800980:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800982:	fc                   	cld    
  800983:	eb 1d                	jmp    8009a2 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800985:	89 f2                	mov    %esi,%edx
  800987:	09 c2                	or     %eax,%edx
  800989:	f6 c2 03             	test   $0x3,%dl
  80098c:	75 0f                	jne    80099d <memmove+0x5f>
  80098e:	f6 c1 03             	test   $0x3,%cl
  800991:	75 0a                	jne    80099d <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800993:	c1 e9 02             	shr    $0x2,%ecx
  800996:	89 c7                	mov    %eax,%edi
  800998:	fc                   	cld    
  800999:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80099b:	eb 05                	jmp    8009a2 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  80099d:	89 c7                	mov    %eax,%edi
  80099f:	fc                   	cld    
  8009a0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a2:	5e                   	pop    %esi
  8009a3:	5f                   	pop    %edi
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009a9:	ff 75 10             	pushl  0x10(%ebp)
  8009ac:	ff 75 0c             	pushl  0xc(%ebp)
  8009af:	ff 75 08             	pushl  0x8(%ebp)
  8009b2:	e8 87 ff ff ff       	call   80093e <memmove>
}
  8009b7:	c9                   	leave  
  8009b8:	c3                   	ret    

008009b9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	56                   	push   %esi
  8009bd:	53                   	push   %ebx
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c4:	89 c6                	mov    %eax,%esi
  8009c6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c9:	eb 1a                	jmp    8009e5 <memcmp+0x2c>
		if (*s1 != *s2)
  8009cb:	0f b6 08             	movzbl (%eax),%ecx
  8009ce:	0f b6 1a             	movzbl (%edx),%ebx
  8009d1:	38 d9                	cmp    %bl,%cl
  8009d3:	74 0a                	je     8009df <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009d5:	0f b6 c1             	movzbl %cl,%eax
  8009d8:	0f b6 db             	movzbl %bl,%ebx
  8009db:	29 d8                	sub    %ebx,%eax
  8009dd:	eb 0f                	jmp    8009ee <memcmp+0x35>
		s1++, s2++;
  8009df:	83 c0 01             	add    $0x1,%eax
  8009e2:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009e5:	39 f0                	cmp    %esi,%eax
  8009e7:	75 e2                	jne    8009cb <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ee:	5b                   	pop    %ebx
  8009ef:	5e                   	pop    %esi
  8009f0:	5d                   	pop    %ebp
  8009f1:	c3                   	ret    

008009f2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009f2:	55                   	push   %ebp
  8009f3:	89 e5                	mov    %esp,%ebp
  8009f5:	53                   	push   %ebx
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  8009f9:	89 c1                	mov    %eax,%ecx
  8009fb:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  8009fe:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a02:	eb 0a                	jmp    800a0e <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a04:	0f b6 10             	movzbl (%eax),%edx
  800a07:	39 da                	cmp    %ebx,%edx
  800a09:	74 07                	je     800a12 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0b:	83 c0 01             	add    $0x1,%eax
  800a0e:	39 c8                	cmp    %ecx,%eax
  800a10:	72 f2                	jb     800a04 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a12:	5b                   	pop    %ebx
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	57                   	push   %edi
  800a19:	56                   	push   %esi
  800a1a:	53                   	push   %ebx
  800a1b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a21:	eb 03                	jmp    800a26 <strtol+0x11>
		s++;
  800a23:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a26:	0f b6 01             	movzbl (%ecx),%eax
  800a29:	3c 20                	cmp    $0x20,%al
  800a2b:	74 f6                	je     800a23 <strtol+0xe>
  800a2d:	3c 09                	cmp    $0x9,%al
  800a2f:	74 f2                	je     800a23 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a31:	3c 2b                	cmp    $0x2b,%al
  800a33:	75 0a                	jne    800a3f <strtol+0x2a>
		s++;
  800a35:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a38:	bf 00 00 00 00       	mov    $0x0,%edi
  800a3d:	eb 11                	jmp    800a50 <strtol+0x3b>
  800a3f:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a44:	3c 2d                	cmp    $0x2d,%al
  800a46:	75 08                	jne    800a50 <strtol+0x3b>
		s++, neg = 1;
  800a48:	83 c1 01             	add    $0x1,%ecx
  800a4b:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a50:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a56:	75 15                	jne    800a6d <strtol+0x58>
  800a58:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5b:	75 10                	jne    800a6d <strtol+0x58>
  800a5d:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a61:	75 7c                	jne    800adf <strtol+0xca>
		s += 2, base = 16;
  800a63:	83 c1 02             	add    $0x2,%ecx
  800a66:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a6b:	eb 16                	jmp    800a83 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a6d:	85 db                	test   %ebx,%ebx
  800a6f:	75 12                	jne    800a83 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a71:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a76:	80 39 30             	cmpb   $0x30,(%ecx)
  800a79:	75 08                	jne    800a83 <strtol+0x6e>
		s++, base = 8;
  800a7b:	83 c1 01             	add    $0x1,%ecx
  800a7e:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a83:	b8 00 00 00 00       	mov    $0x0,%eax
  800a88:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a8b:	0f b6 11             	movzbl (%ecx),%edx
  800a8e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a91:	89 f3                	mov    %esi,%ebx
  800a93:	80 fb 09             	cmp    $0x9,%bl
  800a96:	77 08                	ja     800aa0 <strtol+0x8b>
			dig = *s - '0';
  800a98:	0f be d2             	movsbl %dl,%edx
  800a9b:	83 ea 30             	sub    $0x30,%edx
  800a9e:	eb 22                	jmp    800ac2 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aa0:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aa3:	89 f3                	mov    %esi,%ebx
  800aa5:	80 fb 19             	cmp    $0x19,%bl
  800aa8:	77 08                	ja     800ab2 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800aaa:	0f be d2             	movsbl %dl,%edx
  800aad:	83 ea 57             	sub    $0x57,%edx
  800ab0:	eb 10                	jmp    800ac2 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800ab2:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ab5:	89 f3                	mov    %esi,%ebx
  800ab7:	80 fb 19             	cmp    $0x19,%bl
  800aba:	77 16                	ja     800ad2 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800abc:	0f be d2             	movsbl %dl,%edx
  800abf:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ac2:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac5:	7d 0b                	jge    800ad2 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ac7:	83 c1 01             	add    $0x1,%ecx
  800aca:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ace:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ad0:	eb b9                	jmp    800a8b <strtol+0x76>

	if (endptr)
  800ad2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad6:	74 0d                	je     800ae5 <strtol+0xd0>
		*endptr = (char *) s;
  800ad8:	8b 75 0c             	mov    0xc(%ebp),%esi
  800adb:	89 0e                	mov    %ecx,(%esi)
  800add:	eb 06                	jmp    800ae5 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800adf:	85 db                	test   %ebx,%ebx
  800ae1:	74 98                	je     800a7b <strtol+0x66>
  800ae3:	eb 9e                	jmp    800a83 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ae5:	89 c2                	mov    %eax,%edx
  800ae7:	f7 da                	neg    %edx
  800ae9:	85 ff                	test   %edi,%edi
  800aeb:	0f 45 c2             	cmovne %edx,%eax
}
  800aee:	5b                   	pop    %ebx
  800aef:	5e                   	pop    %esi
  800af0:	5f                   	pop    %edi
  800af1:	5d                   	pop    %ebp
  800af2:	c3                   	ret    

00800af3 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800af3:	55                   	push   %ebp
  800af4:	89 e5                	mov    %esp,%ebp
  800af6:	57                   	push   %edi
  800af7:	56                   	push   %esi
  800af8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800af9:	b8 00 00 00 00       	mov    $0x0,%eax
  800afe:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b01:	8b 55 08             	mov    0x8(%ebp),%edx
  800b04:	89 c3                	mov    %eax,%ebx
  800b06:	89 c7                	mov    %eax,%edi
  800b08:	89 c6                	mov    %eax,%esi
  800b0a:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b0c:	5b                   	pop    %ebx
  800b0d:	5e                   	pop    %esi
  800b0e:	5f                   	pop    %edi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    

00800b11 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b11:	55                   	push   %ebp
  800b12:	89 e5                	mov    %esp,%ebp
  800b14:	57                   	push   %edi
  800b15:	56                   	push   %esi
  800b16:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b17:	ba 00 00 00 00       	mov    $0x0,%edx
  800b1c:	b8 01 00 00 00       	mov    $0x1,%eax
  800b21:	89 d1                	mov    %edx,%ecx
  800b23:	89 d3                	mov    %edx,%ebx
  800b25:	89 d7                	mov    %edx,%edi
  800b27:	89 d6                	mov    %edx,%esi
  800b29:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b2b:	5b                   	pop    %ebx
  800b2c:	5e                   	pop    %esi
  800b2d:	5f                   	pop    %edi
  800b2e:	5d                   	pop    %ebp
  800b2f:	c3                   	ret    

00800b30 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
  800b33:	57                   	push   %edi
  800b34:	56                   	push   %esi
  800b35:	53                   	push   %ebx
  800b36:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b3e:	b8 03 00 00 00       	mov    $0x3,%eax
  800b43:	8b 55 08             	mov    0x8(%ebp),%edx
  800b46:	89 cb                	mov    %ecx,%ebx
  800b48:	89 cf                	mov    %ecx,%edi
  800b4a:	89 ce                	mov    %ecx,%esi
  800b4c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b4e:	85 c0                	test   %eax,%eax
  800b50:	7e 17                	jle    800b69 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b52:	83 ec 0c             	sub    $0xc,%esp
  800b55:	50                   	push   %eax
  800b56:	6a 03                	push   $0x3
  800b58:	68 5f 25 80 00       	push   $0x80255f
  800b5d:	6a 23                	push   $0x23
  800b5f:	68 7c 25 80 00       	push   $0x80257c
  800b64:	e8 c0 11 00 00       	call   801d29 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b6c:	5b                   	pop    %ebx
  800b6d:	5e                   	pop    %esi
  800b6e:	5f                   	pop    %edi
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	57                   	push   %edi
  800b75:	56                   	push   %esi
  800b76:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b77:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7c:	b8 02 00 00 00       	mov    $0x2,%eax
  800b81:	89 d1                	mov    %edx,%ecx
  800b83:	89 d3                	mov    %edx,%ebx
  800b85:	89 d7                	mov    %edx,%edi
  800b87:	89 d6                	mov    %edx,%esi
  800b89:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b8b:	5b                   	pop    %ebx
  800b8c:	5e                   	pop    %esi
  800b8d:	5f                   	pop    %edi
  800b8e:	5d                   	pop    %ebp
  800b8f:	c3                   	ret    

00800b90 <sys_yield>:

void
sys_yield(void)
{
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b96:	ba 00 00 00 00       	mov    $0x0,%edx
  800b9b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ba0:	89 d1                	mov    %edx,%ecx
  800ba2:	89 d3                	mov    %edx,%ebx
  800ba4:	89 d7                	mov    %edx,%edi
  800ba6:	89 d6                	mov    %edx,%esi
  800ba8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800baa:	5b                   	pop    %ebx
  800bab:	5e                   	pop    %esi
  800bac:	5f                   	pop    %edi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800baf:	55                   	push   %ebp
  800bb0:	89 e5                	mov    %esp,%ebp
  800bb2:	57                   	push   %edi
  800bb3:	56                   	push   %esi
  800bb4:	53                   	push   %ebx
  800bb5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bb8:	be 00 00 00 00       	mov    $0x0,%esi
  800bbd:	b8 04 00 00 00       	mov    $0x4,%eax
  800bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bc5:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bcb:	89 f7                	mov    %esi,%edi
  800bcd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bcf:	85 c0                	test   %eax,%eax
  800bd1:	7e 17                	jle    800bea <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bd3:	83 ec 0c             	sub    $0xc,%esp
  800bd6:	50                   	push   %eax
  800bd7:	6a 04                	push   $0x4
  800bd9:	68 5f 25 80 00       	push   $0x80255f
  800bde:	6a 23                	push   $0x23
  800be0:	68 7c 25 80 00       	push   $0x80257c
  800be5:	e8 3f 11 00 00       	call   801d29 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bea:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5f                   	pop    %edi
  800bf0:	5d                   	pop    %ebp
  800bf1:	c3                   	ret    

00800bf2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	57                   	push   %edi
  800bf6:	56                   	push   %esi
  800bf7:	53                   	push   %ebx
  800bf8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bfb:	b8 05 00 00 00       	mov    $0x5,%eax
  800c00:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c03:	8b 55 08             	mov    0x8(%ebp),%edx
  800c06:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c09:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c0c:	8b 75 18             	mov    0x18(%ebp),%esi
  800c0f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c11:	85 c0                	test   %eax,%eax
  800c13:	7e 17                	jle    800c2c <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c15:	83 ec 0c             	sub    $0xc,%esp
  800c18:	50                   	push   %eax
  800c19:	6a 05                	push   $0x5
  800c1b:	68 5f 25 80 00       	push   $0x80255f
  800c20:	6a 23                	push   $0x23
  800c22:	68 7c 25 80 00       	push   $0x80257c
  800c27:	e8 fd 10 00 00       	call   801d29 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2f:	5b                   	pop    %ebx
  800c30:	5e                   	pop    %esi
  800c31:	5f                   	pop    %edi
  800c32:	5d                   	pop    %ebp
  800c33:	c3                   	ret    

00800c34 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	57                   	push   %edi
  800c38:	56                   	push   %esi
  800c39:	53                   	push   %ebx
  800c3a:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c42:	b8 06 00 00 00       	mov    $0x6,%eax
  800c47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c4a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4d:	89 df                	mov    %ebx,%edi
  800c4f:	89 de                	mov    %ebx,%esi
  800c51:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c53:	85 c0                	test   %eax,%eax
  800c55:	7e 17                	jle    800c6e <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c57:	83 ec 0c             	sub    $0xc,%esp
  800c5a:	50                   	push   %eax
  800c5b:	6a 06                	push   $0x6
  800c5d:	68 5f 25 80 00       	push   $0x80255f
  800c62:	6a 23                	push   $0x23
  800c64:	68 7c 25 80 00       	push   $0x80257c
  800c69:	e8 bb 10 00 00       	call   801d29 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c71:	5b                   	pop    %ebx
  800c72:	5e                   	pop    %esi
  800c73:	5f                   	pop    %edi
  800c74:	5d                   	pop    %ebp
  800c75:	c3                   	ret    

00800c76 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c76:	55                   	push   %ebp
  800c77:	89 e5                	mov    %esp,%ebp
  800c79:	57                   	push   %edi
  800c7a:	56                   	push   %esi
  800c7b:	53                   	push   %ebx
  800c7c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c84:	b8 08 00 00 00       	mov    $0x8,%eax
  800c89:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8c:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8f:	89 df                	mov    %ebx,%edi
  800c91:	89 de                	mov    %ebx,%esi
  800c93:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c95:	85 c0                	test   %eax,%eax
  800c97:	7e 17                	jle    800cb0 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c99:	83 ec 0c             	sub    $0xc,%esp
  800c9c:	50                   	push   %eax
  800c9d:	6a 08                	push   $0x8
  800c9f:	68 5f 25 80 00       	push   $0x80255f
  800ca4:	6a 23                	push   $0x23
  800ca6:	68 7c 25 80 00       	push   $0x80257c
  800cab:	e8 79 10 00 00       	call   801d29 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb8:	55                   	push   %ebp
  800cb9:	89 e5                	mov    %esp,%ebp
  800cbb:	57                   	push   %edi
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
  800cbe:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cc6:	b8 09 00 00 00       	mov    $0x9,%eax
  800ccb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cce:	8b 55 08             	mov    0x8(%ebp),%edx
  800cd1:	89 df                	mov    %ebx,%edi
  800cd3:	89 de                	mov    %ebx,%esi
  800cd5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800cd7:	85 c0                	test   %eax,%eax
  800cd9:	7e 17                	jle    800cf2 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cdb:	83 ec 0c             	sub    $0xc,%esp
  800cde:	50                   	push   %eax
  800cdf:	6a 09                	push   $0x9
  800ce1:	68 5f 25 80 00       	push   $0x80255f
  800ce6:	6a 23                	push   $0x23
  800ce8:	68 7c 25 80 00       	push   $0x80257c
  800ced:	e8 37 10 00 00       	call   801d29 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cf2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	57                   	push   %edi
  800cfe:	56                   	push   %esi
  800cff:	53                   	push   %ebx
  800d00:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d03:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d08:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d10:	8b 55 08             	mov    0x8(%ebp),%edx
  800d13:	89 df                	mov    %ebx,%edi
  800d15:	89 de                	mov    %ebx,%esi
  800d17:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d19:	85 c0                	test   %eax,%eax
  800d1b:	7e 17                	jle    800d34 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1d:	83 ec 0c             	sub    $0xc,%esp
  800d20:	50                   	push   %eax
  800d21:	6a 0a                	push   $0xa
  800d23:	68 5f 25 80 00       	push   $0x80255f
  800d28:	6a 23                	push   $0x23
  800d2a:	68 7c 25 80 00       	push   $0x80257c
  800d2f:	e8 f5 0f 00 00       	call   801d29 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d37:	5b                   	pop    %ebx
  800d38:	5e                   	pop    %esi
  800d39:	5f                   	pop    %edi
  800d3a:	5d                   	pop    %ebp
  800d3b:	c3                   	ret    

00800d3c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d3c:	55                   	push   %ebp
  800d3d:	89 e5                	mov    %esp,%ebp
  800d3f:	57                   	push   %edi
  800d40:	56                   	push   %esi
  800d41:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d42:	be 00 00 00 00       	mov    $0x0,%esi
  800d47:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d4c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d52:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d55:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d58:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d5a:	5b                   	pop    %ebx
  800d5b:	5e                   	pop    %esi
  800d5c:	5f                   	pop    %edi
  800d5d:	5d                   	pop    %ebp
  800d5e:	c3                   	ret    

00800d5f <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d5f:	55                   	push   %ebp
  800d60:	89 e5                	mov    %esp,%ebp
  800d62:	57                   	push   %edi
  800d63:	56                   	push   %esi
  800d64:	53                   	push   %ebx
  800d65:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d68:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d72:	8b 55 08             	mov    0x8(%ebp),%edx
  800d75:	89 cb                	mov    %ecx,%ebx
  800d77:	89 cf                	mov    %ecx,%edi
  800d79:	89 ce                	mov    %ecx,%esi
  800d7b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d7d:	85 c0                	test   %eax,%eax
  800d7f:	7e 17                	jle    800d98 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	50                   	push   %eax
  800d85:	6a 0d                	push   $0xd
  800d87:	68 5f 25 80 00       	push   $0x80255f
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 7c 25 80 00       	push   $0x80257c
  800d93:	e8 91 0f 00 00       	call   801d29 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d98:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d9b:	5b                   	pop    %ebx
  800d9c:	5e                   	pop    %esi
  800d9d:	5f                   	pop    %edi
  800d9e:	5d                   	pop    %ebp
  800d9f:	c3                   	ret    

00800da0 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	53                   	push   %ebx
  800da4:	83 ec 04             	sub    $0x4,%esp
  800da7:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800daa:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800dac:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800db0:	74 2d                	je     800ddf <pgfault+0x3f>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800db2:	89 d8                	mov    %ebx,%eax
  800db4:	c1 e8 16             	shr    $0x16,%eax
  800db7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800dbe:	a8 01                	test   $0x1,%al
  800dc0:	74 1d                	je     800ddf <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800dc2:	89 d8                	mov    %ebx,%eax
  800dc4:	c1 e8 0c             	shr    $0xc,%eax
  800dc7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800dce:	f6 c2 01             	test   $0x1,%dl
  800dd1:	74 0c                	je     800ddf <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800dd3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800dda:	f6 c4 08             	test   $0x8,%ah
  800ddd:	75 14                	jne    800df3 <pgfault+0x53>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
	)) panic("Neither the fault is a write nor copy-on-write page.\n");
  800ddf:	83 ec 04             	sub    $0x4,%esp
  800de2:	68 8c 25 80 00       	push   $0x80258c
  800de7:	6a 1f                	push   $0x1f
  800de9:	68 c2 25 80 00       	push   $0x8025c2
  800dee:	e8 36 0f 00 00       	call   801d29 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W)) < 0){
  800df3:	83 ec 04             	sub    $0x4,%esp
  800df6:	6a 07                	push   $0x7
  800df8:	68 00 f0 7f 00       	push   $0x7ff000
  800dfd:	6a 00                	push   $0x0
  800dff:	e8 ab fd ff ff       	call   800baf <sys_page_alloc>
  800e04:	83 c4 10             	add    $0x10,%esp
  800e07:	85 c0                	test   %eax,%eax
  800e09:	79 12                	jns    800e1d <pgfault+0x7d>
		 panic("sys_page_alloc: %e\n", r);
  800e0b:	50                   	push   %eax
  800e0c:	68 cd 25 80 00       	push   $0x8025cd
  800e11:	6a 29                	push   $0x29
  800e13:	68 c2 25 80 00       	push   $0x8025c2
  800e18:	e8 0c 0f 00 00       	call   801d29 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e1d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800e23:	83 ec 04             	sub    $0x4,%esp
  800e26:	68 00 10 00 00       	push   $0x1000
  800e2b:	53                   	push   %ebx
  800e2c:	68 00 f0 7f 00       	push   $0x7ff000
  800e31:	e8 70 fb ff ff       	call   8009a6 <memcpy>
	if ((r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  800e36:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e3d:	53                   	push   %ebx
  800e3e:	6a 00                	push   $0x0
  800e40:	68 00 f0 7f 00       	push   $0x7ff000
  800e45:	6a 00                	push   $0x0
  800e47:	e8 a6 fd ff ff       	call   800bf2 <sys_page_map>
  800e4c:	83 c4 20             	add    $0x20,%esp
  800e4f:	85 c0                	test   %eax,%eax
  800e51:	79 12                	jns    800e65 <pgfault+0xc5>
        panic("sys_page_map: %e\n", r);
  800e53:	50                   	push   %eax
  800e54:	68 e1 25 80 00       	push   $0x8025e1
  800e59:	6a 2e                	push   $0x2e
  800e5b:	68 c2 25 80 00       	push   $0x8025c2
  800e60:	e8 c4 0e 00 00       	call   801d29 <_panic>
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800e65:	83 ec 08             	sub    $0x8,%esp
  800e68:	68 00 f0 7f 00       	push   $0x7ff000
  800e6d:	6a 00                	push   $0x0
  800e6f:	e8 c0 fd ff ff       	call   800c34 <sys_page_unmap>
  800e74:	83 c4 10             	add    $0x10,%esp
  800e77:	85 c0                	test   %eax,%eax
  800e79:	79 12                	jns    800e8d <pgfault+0xed>
        panic("sys_page_unmap: %e\n", r);
  800e7b:	50                   	push   %eax
  800e7c:	68 f3 25 80 00       	push   $0x8025f3
  800e81:	6a 30                	push   $0x30
  800e83:	68 c2 25 80 00       	push   $0x8025c2
  800e88:	e8 9c 0e 00 00       	call   801d29 <_panic>
	//panic("pgfault not implemented");
}
  800e8d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e90:	c9                   	leave  
  800e91:	c3                   	ret    

00800e92 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	57                   	push   %edi
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
  800e98:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	envid_t cenvid;
    unsigned pn;
    int r;
	set_pgfault_handler(pgfault);
  800e9b:	68 a0 0d 80 00       	push   $0x800da0
  800ea0:	e8 ca 0e 00 00       	call   801d6f <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ea5:	b8 07 00 00 00       	mov    $0x7,%eax
  800eaa:	cd 30                	int    $0x30
  800eac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((cenvid = sys_exofork()) < 0){
  800eaf:	83 c4 10             	add    $0x10,%esp
  800eb2:	85 c0                	test   %eax,%eax
  800eb4:	79 14                	jns    800eca <fork+0x38>
		panic("sys_exofork failed");
  800eb6:	83 ec 04             	sub    $0x4,%esp
  800eb9:	68 07 26 80 00       	push   $0x802607
  800ebe:	6a 6f                	push   $0x6f
  800ec0:	68 c2 25 80 00       	push   $0x8025c2
  800ec5:	e8 5f 0e 00 00       	call   801d29 <_panic>
  800eca:	89 c7                	mov    %eax,%edi
		return cenvid;
	}
	if(cenvid>0){
  800ecc:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ed0:	0f 8e 2b 01 00 00    	jle    801001 <fork+0x16f>
  800ed6:	bb 00 08 00 00       	mov    $0x800,%ebx
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
  800edb:	89 d8                	mov    %ebx,%eax
  800edd:	c1 e8 0a             	shr    $0xa,%eax
  800ee0:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800ee7:	a8 01                	test   $0x1,%al
  800ee9:	0f 84 bf 00 00 00    	je     800fae <fork+0x11c>
  800eef:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800ef6:	a8 01                	test   $0x1,%al
  800ef8:	0f 84 b0 00 00 00    	je     800fae <fork+0x11c>
  800efe:	89 de                	mov    %ebx,%esi
  800f00:	c1 e6 0c             	shl    $0xc,%esi
{
	int r;

	// LAB 4: Your code here.
	void* vaddr=(void*)(pn*PGSIZE);
	if(uvpt[pn]&PTE_SHARE){
  800f03:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f0a:	f6 c4 04             	test   $0x4,%ah
  800f0d:	74 29                	je     800f38 <fork+0xa6>
		if((r=sys_page_map(0,vaddr,envid,vaddr,uvpt[pn]&PTE_SYSCALL))<0)return r;
  800f0f:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f16:	83 ec 0c             	sub    $0xc,%esp
  800f19:	25 07 0e 00 00       	and    $0xe07,%eax
  800f1e:	50                   	push   %eax
  800f1f:	56                   	push   %esi
  800f20:	57                   	push   %edi
  800f21:	56                   	push   %esi
  800f22:	6a 00                	push   $0x0
  800f24:	e8 c9 fc ff ff       	call   800bf2 <sys_page_map>
  800f29:	83 c4 20             	add    $0x20,%esp
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f33:	0f 4f c2             	cmovg  %edx,%eax
  800f36:	eb 72                	jmp    800faa <fork+0x118>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  800f38:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f3f:	a8 02                	test   $0x2,%al
  800f41:	75 0c                	jne    800f4f <fork+0xbd>
  800f43:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f4a:	f6 c4 08             	test   $0x8,%ah
  800f4d:	74 3f                	je     800f8e <fork+0xfc>
		if ((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  800f4f:	83 ec 0c             	sub    $0xc,%esp
  800f52:	68 05 08 00 00       	push   $0x805
  800f57:	56                   	push   %esi
  800f58:	57                   	push   %edi
  800f59:	56                   	push   %esi
  800f5a:	6a 00                	push   $0x0
  800f5c:	e8 91 fc ff ff       	call   800bf2 <sys_page_map>
  800f61:	83 c4 20             	add    $0x20,%esp
  800f64:	85 c0                	test   %eax,%eax
  800f66:	0f 88 b1 00 00 00    	js     80101d <fork+0x18b>
            return r;
        if ((r = sys_page_map(0, vaddr, 0, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  800f6c:	83 ec 0c             	sub    $0xc,%esp
  800f6f:	68 05 08 00 00       	push   $0x805
  800f74:	56                   	push   %esi
  800f75:	6a 00                	push   $0x0
  800f77:	56                   	push   %esi
  800f78:	6a 00                	push   $0x0
  800f7a:	e8 73 fc ff ff       	call   800bf2 <sys_page_map>
  800f7f:	83 c4 20             	add    $0x20,%esp
  800f82:	85 c0                	test   %eax,%eax
  800f84:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f89:	0f 4f c1             	cmovg  %ecx,%eax
  800f8c:	eb 1c                	jmp    800faa <fork+0x118>
            return r;
	}
	else if((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U)) < 0) {
  800f8e:	83 ec 0c             	sub    $0xc,%esp
  800f91:	6a 05                	push   $0x5
  800f93:	56                   	push   %esi
  800f94:	57                   	push   %edi
  800f95:	56                   	push   %esi
  800f96:	6a 00                	push   $0x0
  800f98:	e8 55 fc ff ff       	call   800bf2 <sys_page_map>
  800f9d:	83 c4 20             	add    $0x20,%esp
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fa7:	0f 4f c1             	cmovg  %ecx,%eax
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
  800faa:	85 c0                	test   %eax,%eax
  800fac:	78 6f                	js     80101d <fork+0x18b>
	if ((cenvid = sys_exofork()) < 0){
		panic("sys_exofork failed");
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  800fae:	83 c3 01             	add    $0x1,%ebx
  800fb1:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800fb7:	0f 85 1e ff ff ff    	jne    800edb <fork+0x49>
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
                    return r;
		}
		if ((r = sys_page_alloc(cenvid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  800fbd:	83 ec 04             	sub    $0x4,%esp
  800fc0:	6a 07                	push   $0x7
  800fc2:	68 00 f0 bf ee       	push   $0xeebff000
  800fc7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800fca:	57                   	push   %edi
  800fcb:	e8 df fb ff ff       	call   800baf <sys_page_alloc>
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	78 46                	js     80101d <fork+0x18b>
            return r;
		extern void _pgfault_upcall(void);
		if ((r = sys_env_set_pgfault_upcall(cenvid, _pgfault_upcall)) < 0)
  800fd7:	83 ec 08             	sub    $0x8,%esp
  800fda:	68 d2 1d 80 00       	push   $0x801dd2
  800fdf:	57                   	push   %edi
  800fe0:	e8 15 fd ff ff       	call   800cfa <sys_env_set_pgfault_upcall>
  800fe5:	83 c4 10             	add    $0x10,%esp
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	78 31                	js     80101d <fork+0x18b>
            return r;
		if ((r = sys_env_set_status(cenvid, ENV_RUNNABLE)) < 0)
  800fec:	83 ec 08             	sub    $0x8,%esp
  800fef:	6a 02                	push   $0x2
  800ff1:	57                   	push   %edi
  800ff2:	e8 7f fc ff ff       	call   800c76 <sys_env_set_status>
  800ff7:	83 c4 10             	add    $0x10,%esp
            return r;
        return cenvid;
  800ffa:	85 c0                	test   %eax,%eax
  800ffc:	0f 49 c7             	cmovns %edi,%eax
  800fff:	eb 1c                	jmp    80101d <fork+0x18b>
	}
	else {
		thisenv = &envs[ENVX(sys_getenvid())];
  801001:	e8 6b fb ff ff       	call   800b71 <sys_getenvid>
  801006:	25 ff 03 00 00       	and    $0x3ff,%eax
  80100b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80100e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801013:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801018:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//panic("fork not implemented");
	
}
  80101d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801020:	5b                   	pop    %ebx
  801021:	5e                   	pop    %esi
  801022:	5f                   	pop    %edi
  801023:	5d                   	pop    %ebp
  801024:	c3                   	ret    

00801025 <sfork>:

// Challenge!
int
sfork(void)
{
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80102b:	68 1a 26 80 00       	push   $0x80261a
  801030:	68 8d 00 00 00       	push   $0x8d
  801035:	68 c2 25 80 00       	push   $0x8025c2
  80103a:	e8 ea 0c 00 00       	call   801d29 <_panic>

0080103f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80103f:	55                   	push   %ebp
  801040:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801042:	8b 45 08             	mov    0x8(%ebp),%eax
  801045:	05 00 00 00 30       	add    $0x30000000,%eax
  80104a:	c1 e8 0c             	shr    $0xc,%eax
}
  80104d:	5d                   	pop    %ebp
  80104e:	c3                   	ret    

0080104f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801052:	8b 45 08             	mov    0x8(%ebp),%eax
  801055:	05 00 00 00 30       	add    $0x30000000,%eax
  80105a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80105f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    

00801066 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801066:	55                   	push   %ebp
  801067:	89 e5                	mov    %esp,%ebp
  801069:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80106c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801071:	89 c2                	mov    %eax,%edx
  801073:	c1 ea 16             	shr    $0x16,%edx
  801076:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80107d:	f6 c2 01             	test   $0x1,%dl
  801080:	74 11                	je     801093 <fd_alloc+0x2d>
  801082:	89 c2                	mov    %eax,%edx
  801084:	c1 ea 0c             	shr    $0xc,%edx
  801087:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80108e:	f6 c2 01             	test   $0x1,%dl
  801091:	75 09                	jne    80109c <fd_alloc+0x36>
			*fd_store = fd;
  801093:	89 01                	mov    %eax,(%ecx)
			return 0;
  801095:	b8 00 00 00 00       	mov    $0x0,%eax
  80109a:	eb 17                	jmp    8010b3 <fd_alloc+0x4d>
  80109c:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010a1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010a6:	75 c9                	jne    801071 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010a8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010ae:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010b3:	5d                   	pop    %ebp
  8010b4:	c3                   	ret    

008010b5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010b5:	55                   	push   %ebp
  8010b6:	89 e5                	mov    %esp,%ebp
  8010b8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010bb:	83 f8 1f             	cmp    $0x1f,%eax
  8010be:	77 36                	ja     8010f6 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010c0:	c1 e0 0c             	shl    $0xc,%eax
  8010c3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010c8:	89 c2                	mov    %eax,%edx
  8010ca:	c1 ea 16             	shr    $0x16,%edx
  8010cd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010d4:	f6 c2 01             	test   $0x1,%dl
  8010d7:	74 24                	je     8010fd <fd_lookup+0x48>
  8010d9:	89 c2                	mov    %eax,%edx
  8010db:	c1 ea 0c             	shr    $0xc,%edx
  8010de:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010e5:	f6 c2 01             	test   $0x1,%dl
  8010e8:	74 1a                	je     801104 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010ed:	89 02                	mov    %eax,(%edx)
	return 0;
  8010ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f4:	eb 13                	jmp    801109 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010f6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010fb:	eb 0c                	jmp    801109 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  8010fd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801102:	eb 05                	jmp    801109 <fd_lookup+0x54>
  801104:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801109:	5d                   	pop    %ebp
  80110a:	c3                   	ret    

0080110b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	83 ec 08             	sub    $0x8,%esp
  801111:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801114:	ba ac 26 80 00       	mov    $0x8026ac,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801119:	eb 13                	jmp    80112e <dev_lookup+0x23>
  80111b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80111e:	39 08                	cmp    %ecx,(%eax)
  801120:	75 0c                	jne    80112e <dev_lookup+0x23>
			*dev = devtab[i];
  801122:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801125:	89 01                	mov    %eax,(%ecx)
			return 0;
  801127:	b8 00 00 00 00       	mov    $0x0,%eax
  80112c:	eb 2e                	jmp    80115c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80112e:	8b 02                	mov    (%edx),%eax
  801130:	85 c0                	test   %eax,%eax
  801132:	75 e7                	jne    80111b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801134:	a1 04 40 80 00       	mov    0x804004,%eax
  801139:	8b 40 48             	mov    0x48(%eax),%eax
  80113c:	83 ec 04             	sub    $0x4,%esp
  80113f:	51                   	push   %ecx
  801140:	50                   	push   %eax
  801141:	68 30 26 80 00       	push   $0x802630
  801146:	e8 5d f0 ff ff       	call   8001a8 <cprintf>
	*dev = 0;
  80114b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80114e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801154:	83 c4 10             	add    $0x10,%esp
  801157:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80115c:	c9                   	leave  
  80115d:	c3                   	ret    

0080115e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80115e:	55                   	push   %ebp
  80115f:	89 e5                	mov    %esp,%ebp
  801161:	56                   	push   %esi
  801162:	53                   	push   %ebx
  801163:	83 ec 10             	sub    $0x10,%esp
  801166:	8b 75 08             	mov    0x8(%ebp),%esi
  801169:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80116c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80116f:	50                   	push   %eax
  801170:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  801176:	c1 e8 0c             	shr    $0xc,%eax
  801179:	50                   	push   %eax
  80117a:	e8 36 ff ff ff       	call   8010b5 <fd_lookup>
  80117f:	83 c4 08             	add    $0x8,%esp
  801182:	85 c0                	test   %eax,%eax
  801184:	78 05                	js     80118b <fd_close+0x2d>
	    || fd != fd2)
  801186:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  801189:	74 0c                	je     801197 <fd_close+0x39>
		return (must_exist ? r : 0);
  80118b:	84 db                	test   %bl,%bl
  80118d:	ba 00 00 00 00       	mov    $0x0,%edx
  801192:	0f 44 c2             	cmove  %edx,%eax
  801195:	eb 41                	jmp    8011d8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801197:	83 ec 08             	sub    $0x8,%esp
  80119a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80119d:	50                   	push   %eax
  80119e:	ff 36                	pushl  (%esi)
  8011a0:	e8 66 ff ff ff       	call   80110b <dev_lookup>
  8011a5:	89 c3                	mov    %eax,%ebx
  8011a7:	83 c4 10             	add    $0x10,%esp
  8011aa:	85 c0                	test   %eax,%eax
  8011ac:	78 1a                	js     8011c8 <fd_close+0x6a>
		if (dev->dev_close)
  8011ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011b1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011b4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	74 0b                	je     8011c8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011bd:	83 ec 0c             	sub    $0xc,%esp
  8011c0:	56                   	push   %esi
  8011c1:	ff d0                	call   *%eax
  8011c3:	89 c3                	mov    %eax,%ebx
  8011c5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8011c8:	83 ec 08             	sub    $0x8,%esp
  8011cb:	56                   	push   %esi
  8011cc:	6a 00                	push   $0x0
  8011ce:	e8 61 fa ff ff       	call   800c34 <sys_page_unmap>
	return r;
  8011d3:	83 c4 10             	add    $0x10,%esp
  8011d6:	89 d8                	mov    %ebx,%eax
}
  8011d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8011db:	5b                   	pop    %ebx
  8011dc:	5e                   	pop    %esi
  8011dd:	5d                   	pop    %ebp
  8011de:	c3                   	ret    

008011df <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8011df:	55                   	push   %ebp
  8011e0:	89 e5                	mov    %esp,%ebp
  8011e2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e8:	50                   	push   %eax
  8011e9:	ff 75 08             	pushl  0x8(%ebp)
  8011ec:	e8 c4 fe ff ff       	call   8010b5 <fd_lookup>
  8011f1:	83 c4 08             	add    $0x8,%esp
  8011f4:	85 c0                	test   %eax,%eax
  8011f6:	78 10                	js     801208 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  8011f8:	83 ec 08             	sub    $0x8,%esp
  8011fb:	6a 01                	push   $0x1
  8011fd:	ff 75 f4             	pushl  -0xc(%ebp)
  801200:	e8 59 ff ff ff       	call   80115e <fd_close>
  801205:	83 c4 10             	add    $0x10,%esp
}
  801208:	c9                   	leave  
  801209:	c3                   	ret    

0080120a <close_all>:

void
close_all(void)
{
  80120a:	55                   	push   %ebp
  80120b:	89 e5                	mov    %esp,%ebp
  80120d:	53                   	push   %ebx
  80120e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801211:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801216:	83 ec 0c             	sub    $0xc,%esp
  801219:	53                   	push   %ebx
  80121a:	e8 c0 ff ff ff       	call   8011df <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80121f:	83 c3 01             	add    $0x1,%ebx
  801222:	83 c4 10             	add    $0x10,%esp
  801225:	83 fb 20             	cmp    $0x20,%ebx
  801228:	75 ec                	jne    801216 <close_all+0xc>
		close(i);
}
  80122a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122d:	c9                   	leave  
  80122e:	c3                   	ret    

0080122f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	57                   	push   %edi
  801233:	56                   	push   %esi
  801234:	53                   	push   %ebx
  801235:	83 ec 2c             	sub    $0x2c,%esp
  801238:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80123b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80123e:	50                   	push   %eax
  80123f:	ff 75 08             	pushl  0x8(%ebp)
  801242:	e8 6e fe ff ff       	call   8010b5 <fd_lookup>
  801247:	83 c4 08             	add    $0x8,%esp
  80124a:	85 c0                	test   %eax,%eax
  80124c:	0f 88 c1 00 00 00    	js     801313 <dup+0xe4>
		return r;
	close(newfdnum);
  801252:	83 ec 0c             	sub    $0xc,%esp
  801255:	56                   	push   %esi
  801256:	e8 84 ff ff ff       	call   8011df <close>

	newfd = INDEX2FD(newfdnum);
  80125b:	89 f3                	mov    %esi,%ebx
  80125d:	c1 e3 0c             	shl    $0xc,%ebx
  801260:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801266:	83 c4 04             	add    $0x4,%esp
  801269:	ff 75 e4             	pushl  -0x1c(%ebp)
  80126c:	e8 de fd ff ff       	call   80104f <fd2data>
  801271:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  801273:	89 1c 24             	mov    %ebx,(%esp)
  801276:	e8 d4 fd ff ff       	call   80104f <fd2data>
  80127b:	83 c4 10             	add    $0x10,%esp
  80127e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801281:	89 f8                	mov    %edi,%eax
  801283:	c1 e8 16             	shr    $0x16,%eax
  801286:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80128d:	a8 01                	test   $0x1,%al
  80128f:	74 37                	je     8012c8 <dup+0x99>
  801291:	89 f8                	mov    %edi,%eax
  801293:	c1 e8 0c             	shr    $0xc,%eax
  801296:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80129d:	f6 c2 01             	test   $0x1,%dl
  8012a0:	74 26                	je     8012c8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012a2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012a9:	83 ec 0c             	sub    $0xc,%esp
  8012ac:	25 07 0e 00 00       	and    $0xe07,%eax
  8012b1:	50                   	push   %eax
  8012b2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012b5:	6a 00                	push   $0x0
  8012b7:	57                   	push   %edi
  8012b8:	6a 00                	push   $0x0
  8012ba:	e8 33 f9 ff ff       	call   800bf2 <sys_page_map>
  8012bf:	89 c7                	mov    %eax,%edi
  8012c1:	83 c4 20             	add    $0x20,%esp
  8012c4:	85 c0                	test   %eax,%eax
  8012c6:	78 2e                	js     8012f6 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012c8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012cb:	89 d0                	mov    %edx,%eax
  8012cd:	c1 e8 0c             	shr    $0xc,%eax
  8012d0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012d7:	83 ec 0c             	sub    $0xc,%esp
  8012da:	25 07 0e 00 00       	and    $0xe07,%eax
  8012df:	50                   	push   %eax
  8012e0:	53                   	push   %ebx
  8012e1:	6a 00                	push   $0x0
  8012e3:	52                   	push   %edx
  8012e4:	6a 00                	push   $0x0
  8012e6:	e8 07 f9 ff ff       	call   800bf2 <sys_page_map>
  8012eb:	89 c7                	mov    %eax,%edi
  8012ed:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8012f0:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012f2:	85 ff                	test   %edi,%edi
  8012f4:	79 1d                	jns    801313 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8012f6:	83 ec 08             	sub    $0x8,%esp
  8012f9:	53                   	push   %ebx
  8012fa:	6a 00                	push   $0x0
  8012fc:	e8 33 f9 ff ff       	call   800c34 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801301:	83 c4 08             	add    $0x8,%esp
  801304:	ff 75 d4             	pushl  -0x2c(%ebp)
  801307:	6a 00                	push   $0x0
  801309:	e8 26 f9 ff ff       	call   800c34 <sys_page_unmap>
	return r;
  80130e:	83 c4 10             	add    $0x10,%esp
  801311:	89 f8                	mov    %edi,%eax
}
  801313:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801316:	5b                   	pop    %ebx
  801317:	5e                   	pop    %esi
  801318:	5f                   	pop    %edi
  801319:	5d                   	pop    %ebp
  80131a:	c3                   	ret    

0080131b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80131b:	55                   	push   %ebp
  80131c:	89 e5                	mov    %esp,%ebp
  80131e:	53                   	push   %ebx
  80131f:	83 ec 14             	sub    $0x14,%esp
  801322:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801325:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801328:	50                   	push   %eax
  801329:	53                   	push   %ebx
  80132a:	e8 86 fd ff ff       	call   8010b5 <fd_lookup>
  80132f:	83 c4 08             	add    $0x8,%esp
  801332:	89 c2                	mov    %eax,%edx
  801334:	85 c0                	test   %eax,%eax
  801336:	78 6d                	js     8013a5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801338:	83 ec 08             	sub    $0x8,%esp
  80133b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80133e:	50                   	push   %eax
  80133f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801342:	ff 30                	pushl  (%eax)
  801344:	e8 c2 fd ff ff       	call   80110b <dev_lookup>
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	85 c0                	test   %eax,%eax
  80134e:	78 4c                	js     80139c <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801350:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801353:	8b 42 08             	mov    0x8(%edx),%eax
  801356:	83 e0 03             	and    $0x3,%eax
  801359:	83 f8 01             	cmp    $0x1,%eax
  80135c:	75 21                	jne    80137f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80135e:	a1 04 40 80 00       	mov    0x804004,%eax
  801363:	8b 40 48             	mov    0x48(%eax),%eax
  801366:	83 ec 04             	sub    $0x4,%esp
  801369:	53                   	push   %ebx
  80136a:	50                   	push   %eax
  80136b:	68 71 26 80 00       	push   $0x802671
  801370:	e8 33 ee ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80137d:	eb 26                	jmp    8013a5 <read+0x8a>
	}
	if (!dev->dev_read)
  80137f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801382:	8b 40 08             	mov    0x8(%eax),%eax
  801385:	85 c0                	test   %eax,%eax
  801387:	74 17                	je     8013a0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801389:	83 ec 04             	sub    $0x4,%esp
  80138c:	ff 75 10             	pushl  0x10(%ebp)
  80138f:	ff 75 0c             	pushl  0xc(%ebp)
  801392:	52                   	push   %edx
  801393:	ff d0                	call   *%eax
  801395:	89 c2                	mov    %eax,%edx
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	eb 09                	jmp    8013a5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80139c:	89 c2                	mov    %eax,%edx
  80139e:	eb 05                	jmp    8013a5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013a0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013a5:	89 d0                	mov    %edx,%eax
  8013a7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013aa:	c9                   	leave  
  8013ab:	c3                   	ret    

008013ac <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013ac:	55                   	push   %ebp
  8013ad:	89 e5                	mov    %esp,%ebp
  8013af:	57                   	push   %edi
  8013b0:	56                   	push   %esi
  8013b1:	53                   	push   %ebx
  8013b2:	83 ec 0c             	sub    $0xc,%esp
  8013b5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013b8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013bb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013c0:	eb 21                	jmp    8013e3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013c2:	83 ec 04             	sub    $0x4,%esp
  8013c5:	89 f0                	mov    %esi,%eax
  8013c7:	29 d8                	sub    %ebx,%eax
  8013c9:	50                   	push   %eax
  8013ca:	89 d8                	mov    %ebx,%eax
  8013cc:	03 45 0c             	add    0xc(%ebp),%eax
  8013cf:	50                   	push   %eax
  8013d0:	57                   	push   %edi
  8013d1:	e8 45 ff ff ff       	call   80131b <read>
		if (m < 0)
  8013d6:	83 c4 10             	add    $0x10,%esp
  8013d9:	85 c0                	test   %eax,%eax
  8013db:	78 10                	js     8013ed <readn+0x41>
			return m;
		if (m == 0)
  8013dd:	85 c0                	test   %eax,%eax
  8013df:	74 0a                	je     8013eb <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013e1:	01 c3                	add    %eax,%ebx
  8013e3:	39 f3                	cmp    %esi,%ebx
  8013e5:	72 db                	jb     8013c2 <readn+0x16>
  8013e7:	89 d8                	mov    %ebx,%eax
  8013e9:	eb 02                	jmp    8013ed <readn+0x41>
  8013eb:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8013ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013f0:	5b                   	pop    %ebx
  8013f1:	5e                   	pop    %esi
  8013f2:	5f                   	pop    %edi
  8013f3:	5d                   	pop    %ebp
  8013f4:	c3                   	ret    

008013f5 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013f5:	55                   	push   %ebp
  8013f6:	89 e5                	mov    %esp,%ebp
  8013f8:	53                   	push   %ebx
  8013f9:	83 ec 14             	sub    $0x14,%esp
  8013fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801402:	50                   	push   %eax
  801403:	53                   	push   %ebx
  801404:	e8 ac fc ff ff       	call   8010b5 <fd_lookup>
  801409:	83 c4 08             	add    $0x8,%esp
  80140c:	89 c2                	mov    %eax,%edx
  80140e:	85 c0                	test   %eax,%eax
  801410:	78 68                	js     80147a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801412:	83 ec 08             	sub    $0x8,%esp
  801415:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801418:	50                   	push   %eax
  801419:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80141c:	ff 30                	pushl  (%eax)
  80141e:	e8 e8 fc ff ff       	call   80110b <dev_lookup>
  801423:	83 c4 10             	add    $0x10,%esp
  801426:	85 c0                	test   %eax,%eax
  801428:	78 47                	js     801471 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80142a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80142d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801431:	75 21                	jne    801454 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801433:	a1 04 40 80 00       	mov    0x804004,%eax
  801438:	8b 40 48             	mov    0x48(%eax),%eax
  80143b:	83 ec 04             	sub    $0x4,%esp
  80143e:	53                   	push   %ebx
  80143f:	50                   	push   %eax
  801440:	68 8d 26 80 00       	push   $0x80268d
  801445:	e8 5e ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  80144a:	83 c4 10             	add    $0x10,%esp
  80144d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801452:	eb 26                	jmp    80147a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801454:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801457:	8b 52 0c             	mov    0xc(%edx),%edx
  80145a:	85 d2                	test   %edx,%edx
  80145c:	74 17                	je     801475 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80145e:	83 ec 04             	sub    $0x4,%esp
  801461:	ff 75 10             	pushl  0x10(%ebp)
  801464:	ff 75 0c             	pushl  0xc(%ebp)
  801467:	50                   	push   %eax
  801468:	ff d2                	call   *%edx
  80146a:	89 c2                	mov    %eax,%edx
  80146c:	83 c4 10             	add    $0x10,%esp
  80146f:	eb 09                	jmp    80147a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801471:	89 c2                	mov    %eax,%edx
  801473:	eb 05                	jmp    80147a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801475:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80147a:	89 d0                	mov    %edx,%eax
  80147c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80147f:	c9                   	leave  
  801480:	c3                   	ret    

00801481 <seek>:

int
seek(int fdnum, off_t offset)
{
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801487:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80148a:	50                   	push   %eax
  80148b:	ff 75 08             	pushl  0x8(%ebp)
  80148e:	e8 22 fc ff ff       	call   8010b5 <fd_lookup>
  801493:	83 c4 08             	add    $0x8,%esp
  801496:	85 c0                	test   %eax,%eax
  801498:	78 0e                	js     8014a8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  80149a:	8b 45 fc             	mov    -0x4(%ebp),%eax
  80149d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014a0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014a8:	c9                   	leave  
  8014a9:	c3                   	ret    

008014aa <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014aa:	55                   	push   %ebp
  8014ab:	89 e5                	mov    %esp,%ebp
  8014ad:	53                   	push   %ebx
  8014ae:	83 ec 14             	sub    $0x14,%esp
  8014b1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014b4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014b7:	50                   	push   %eax
  8014b8:	53                   	push   %ebx
  8014b9:	e8 f7 fb ff ff       	call   8010b5 <fd_lookup>
  8014be:	83 c4 08             	add    $0x8,%esp
  8014c1:	89 c2                	mov    %eax,%edx
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 65                	js     80152c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014c7:	83 ec 08             	sub    $0x8,%esp
  8014ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014cd:	50                   	push   %eax
  8014ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014d1:	ff 30                	pushl  (%eax)
  8014d3:	e8 33 fc ff ff       	call   80110b <dev_lookup>
  8014d8:	83 c4 10             	add    $0x10,%esp
  8014db:	85 c0                	test   %eax,%eax
  8014dd:	78 44                	js     801523 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014e2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014e6:	75 21                	jne    801509 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8014e8:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014ed:	8b 40 48             	mov    0x48(%eax),%eax
  8014f0:	83 ec 04             	sub    $0x4,%esp
  8014f3:	53                   	push   %ebx
  8014f4:	50                   	push   %eax
  8014f5:	68 50 26 80 00       	push   $0x802650
  8014fa:	e8 a9 ec ff ff       	call   8001a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8014ff:	83 c4 10             	add    $0x10,%esp
  801502:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801507:	eb 23                	jmp    80152c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801509:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80150c:	8b 52 18             	mov    0x18(%edx),%edx
  80150f:	85 d2                	test   %edx,%edx
  801511:	74 14                	je     801527 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801513:	83 ec 08             	sub    $0x8,%esp
  801516:	ff 75 0c             	pushl  0xc(%ebp)
  801519:	50                   	push   %eax
  80151a:	ff d2                	call   *%edx
  80151c:	89 c2                	mov    %eax,%edx
  80151e:	83 c4 10             	add    $0x10,%esp
  801521:	eb 09                	jmp    80152c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801523:	89 c2                	mov    %eax,%edx
  801525:	eb 05                	jmp    80152c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801527:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80152c:	89 d0                	mov    %edx,%eax
  80152e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801531:	c9                   	leave  
  801532:	c3                   	ret    

00801533 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801533:	55                   	push   %ebp
  801534:	89 e5                	mov    %esp,%ebp
  801536:	53                   	push   %ebx
  801537:	83 ec 14             	sub    $0x14,%esp
  80153a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80153d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801540:	50                   	push   %eax
  801541:	ff 75 08             	pushl  0x8(%ebp)
  801544:	e8 6c fb ff ff       	call   8010b5 <fd_lookup>
  801549:	83 c4 08             	add    $0x8,%esp
  80154c:	89 c2                	mov    %eax,%edx
  80154e:	85 c0                	test   %eax,%eax
  801550:	78 58                	js     8015aa <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801552:	83 ec 08             	sub    $0x8,%esp
  801555:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801558:	50                   	push   %eax
  801559:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80155c:	ff 30                	pushl  (%eax)
  80155e:	e8 a8 fb ff ff       	call   80110b <dev_lookup>
  801563:	83 c4 10             	add    $0x10,%esp
  801566:	85 c0                	test   %eax,%eax
  801568:	78 37                	js     8015a1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80156a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80156d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801571:	74 32                	je     8015a5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801573:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801576:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80157d:	00 00 00 
	stat->st_isdir = 0;
  801580:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801587:	00 00 00 
	stat->st_dev = dev;
  80158a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801590:	83 ec 08             	sub    $0x8,%esp
  801593:	53                   	push   %ebx
  801594:	ff 75 f0             	pushl  -0x10(%ebp)
  801597:	ff 50 14             	call   *0x14(%eax)
  80159a:	89 c2                	mov    %eax,%edx
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	eb 09                	jmp    8015aa <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015a1:	89 c2                	mov    %eax,%edx
  8015a3:	eb 05                	jmp    8015aa <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015a5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015aa:	89 d0                	mov    %edx,%eax
  8015ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015af:	c9                   	leave  
  8015b0:	c3                   	ret    

008015b1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015b1:	55                   	push   %ebp
  8015b2:	89 e5                	mov    %esp,%ebp
  8015b4:	56                   	push   %esi
  8015b5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015b6:	83 ec 08             	sub    $0x8,%esp
  8015b9:	6a 00                	push   $0x0
  8015bb:	ff 75 08             	pushl  0x8(%ebp)
  8015be:	e8 e3 01 00 00       	call   8017a6 <open>
  8015c3:	89 c3                	mov    %eax,%ebx
  8015c5:	83 c4 10             	add    $0x10,%esp
  8015c8:	85 c0                	test   %eax,%eax
  8015ca:	78 1b                	js     8015e7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8015cc:	83 ec 08             	sub    $0x8,%esp
  8015cf:	ff 75 0c             	pushl  0xc(%ebp)
  8015d2:	50                   	push   %eax
  8015d3:	e8 5b ff ff ff       	call   801533 <fstat>
  8015d8:	89 c6                	mov    %eax,%esi
	close(fd);
  8015da:	89 1c 24             	mov    %ebx,(%esp)
  8015dd:	e8 fd fb ff ff       	call   8011df <close>
	return r;
  8015e2:	83 c4 10             	add    $0x10,%esp
  8015e5:	89 f0                	mov    %esi,%eax
}
  8015e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ea:	5b                   	pop    %ebx
  8015eb:	5e                   	pop    %esi
  8015ec:	5d                   	pop    %ebp
  8015ed:	c3                   	ret    

008015ee <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	56                   	push   %esi
  8015f2:	53                   	push   %ebx
  8015f3:	89 c6                	mov    %eax,%esi
  8015f5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015f7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8015fe:	75 12                	jne    801612 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801600:	83 ec 0c             	sub    $0xc,%esp
  801603:	6a 01                	push   $0x1
  801605:	e8 a9 08 00 00       	call   801eb3 <ipc_find_env>
  80160a:	a3 00 40 80 00       	mov    %eax,0x804000
  80160f:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801612:	6a 07                	push   $0x7
  801614:	68 00 50 80 00       	push   $0x805000
  801619:	56                   	push   %esi
  80161a:	ff 35 00 40 80 00    	pushl  0x804000
  801620:	e8 3a 08 00 00       	call   801e5f <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801625:	83 c4 0c             	add    $0xc,%esp
  801628:	6a 00                	push   $0x0
  80162a:	53                   	push   %ebx
  80162b:	6a 00                	push   $0x0
  80162d:	e8 c4 07 00 00       	call   801df6 <ipc_recv>
}
  801632:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801635:	5b                   	pop    %ebx
  801636:	5e                   	pop    %esi
  801637:	5d                   	pop    %ebp
  801638:	c3                   	ret    

00801639 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
  80163c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80163f:	8b 45 08             	mov    0x8(%ebp),%eax
  801642:	8b 40 0c             	mov    0xc(%eax),%eax
  801645:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80164a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80164d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801652:	ba 00 00 00 00       	mov    $0x0,%edx
  801657:	b8 02 00 00 00       	mov    $0x2,%eax
  80165c:	e8 8d ff ff ff       	call   8015ee <fsipc>
}
  801661:	c9                   	leave  
  801662:	c3                   	ret    

00801663 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801669:	8b 45 08             	mov    0x8(%ebp),%eax
  80166c:	8b 40 0c             	mov    0xc(%eax),%eax
  80166f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801674:	ba 00 00 00 00       	mov    $0x0,%edx
  801679:	b8 06 00 00 00       	mov    $0x6,%eax
  80167e:	e8 6b ff ff ff       	call   8015ee <fsipc>
}
  801683:	c9                   	leave  
  801684:	c3                   	ret    

00801685 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801685:	55                   	push   %ebp
  801686:	89 e5                	mov    %esp,%ebp
  801688:	53                   	push   %ebx
  801689:	83 ec 04             	sub    $0x4,%esp
  80168c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80168f:	8b 45 08             	mov    0x8(%ebp),%eax
  801692:	8b 40 0c             	mov    0xc(%eax),%eax
  801695:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80169a:	ba 00 00 00 00       	mov    $0x0,%edx
  80169f:	b8 05 00 00 00       	mov    $0x5,%eax
  8016a4:	e8 45 ff ff ff       	call   8015ee <fsipc>
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	78 2c                	js     8016d9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016ad:	83 ec 08             	sub    $0x8,%esp
  8016b0:	68 00 50 80 00       	push   $0x805000
  8016b5:	53                   	push   %ebx
  8016b6:	e8 f1 f0 ff ff       	call   8007ac <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016bb:	a1 80 50 80 00       	mov    0x805080,%eax
  8016c0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016c6:	a1 84 50 80 00       	mov    0x805084,%eax
  8016cb:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016d1:	83 c4 10             	add    $0x10,%esp
  8016d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016dc:	c9                   	leave  
  8016dd:	c3                   	ret    

008016de <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8016de:	55                   	push   %ebp
  8016df:	89 e5                	mov    %esp,%ebp
  8016e1:	83 ec 0c             	sub    $0xc,%esp
  8016e4:	8b 45 10             	mov    0x10(%ebp),%eax
  8016e7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016ec:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8016f1:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8016f7:	8b 52 0c             	mov    0xc(%edx),%edx
  8016fa:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801700:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801705:	50                   	push   %eax
  801706:	ff 75 0c             	pushl  0xc(%ebp)
  801709:	68 08 50 80 00       	push   $0x805008
  80170e:	e8 2b f2 ff ff       	call   80093e <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801713:	ba 00 00 00 00       	mov    $0x0,%edx
  801718:	b8 04 00 00 00       	mov    $0x4,%eax
  80171d:	e8 cc fe ff ff       	call   8015ee <fsipc>
	//panic("devfile_write not implemented");
}
  801722:	c9                   	leave  
  801723:	c3                   	ret    

00801724 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801724:	55                   	push   %ebp
  801725:	89 e5                	mov    %esp,%ebp
  801727:	56                   	push   %esi
  801728:	53                   	push   %ebx
  801729:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80172c:	8b 45 08             	mov    0x8(%ebp),%eax
  80172f:	8b 40 0c             	mov    0xc(%eax),%eax
  801732:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801737:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80173d:	ba 00 00 00 00       	mov    $0x0,%edx
  801742:	b8 03 00 00 00       	mov    $0x3,%eax
  801747:	e8 a2 fe ff ff       	call   8015ee <fsipc>
  80174c:	89 c3                	mov    %eax,%ebx
  80174e:	85 c0                	test   %eax,%eax
  801750:	78 4b                	js     80179d <devfile_read+0x79>
		return r;
	assert(r <= n);
  801752:	39 c6                	cmp    %eax,%esi
  801754:	73 16                	jae    80176c <devfile_read+0x48>
  801756:	68 bc 26 80 00       	push   $0x8026bc
  80175b:	68 c3 26 80 00       	push   $0x8026c3
  801760:	6a 7c                	push   $0x7c
  801762:	68 d8 26 80 00       	push   $0x8026d8
  801767:	e8 bd 05 00 00       	call   801d29 <_panic>
	assert(r <= PGSIZE);
  80176c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801771:	7e 16                	jle    801789 <devfile_read+0x65>
  801773:	68 e3 26 80 00       	push   $0x8026e3
  801778:	68 c3 26 80 00       	push   $0x8026c3
  80177d:	6a 7d                	push   $0x7d
  80177f:	68 d8 26 80 00       	push   $0x8026d8
  801784:	e8 a0 05 00 00       	call   801d29 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801789:	83 ec 04             	sub    $0x4,%esp
  80178c:	50                   	push   %eax
  80178d:	68 00 50 80 00       	push   $0x805000
  801792:	ff 75 0c             	pushl  0xc(%ebp)
  801795:	e8 a4 f1 ff ff       	call   80093e <memmove>
	return r;
  80179a:	83 c4 10             	add    $0x10,%esp
}
  80179d:	89 d8                	mov    %ebx,%eax
  80179f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017a2:	5b                   	pop    %ebx
  8017a3:	5e                   	pop    %esi
  8017a4:	5d                   	pop    %ebp
  8017a5:	c3                   	ret    

008017a6 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	53                   	push   %ebx
  8017aa:	83 ec 20             	sub    $0x20,%esp
  8017ad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017b0:	53                   	push   %ebx
  8017b1:	e8 bd ef ff ff       	call   800773 <strlen>
  8017b6:	83 c4 10             	add    $0x10,%esp
  8017b9:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017be:	7f 67                	jg     801827 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017c0:	83 ec 0c             	sub    $0xc,%esp
  8017c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c6:	50                   	push   %eax
  8017c7:	e8 9a f8 ff ff       	call   801066 <fd_alloc>
  8017cc:	83 c4 10             	add    $0x10,%esp
		return r;
  8017cf:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017d1:	85 c0                	test   %eax,%eax
  8017d3:	78 57                	js     80182c <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  8017d5:	83 ec 08             	sub    $0x8,%esp
  8017d8:	53                   	push   %ebx
  8017d9:	68 00 50 80 00       	push   $0x805000
  8017de:	e8 c9 ef ff ff       	call   8007ac <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017e6:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8017f3:	e8 f6 fd ff ff       	call   8015ee <fsipc>
  8017f8:	89 c3                	mov    %eax,%ebx
  8017fa:	83 c4 10             	add    $0x10,%esp
  8017fd:	85 c0                	test   %eax,%eax
  8017ff:	79 14                	jns    801815 <open+0x6f>
		fd_close(fd, 0);
  801801:	83 ec 08             	sub    $0x8,%esp
  801804:	6a 00                	push   $0x0
  801806:	ff 75 f4             	pushl  -0xc(%ebp)
  801809:	e8 50 f9 ff ff       	call   80115e <fd_close>
		return r;
  80180e:	83 c4 10             	add    $0x10,%esp
  801811:	89 da                	mov    %ebx,%edx
  801813:	eb 17                	jmp    80182c <open+0x86>
	}

	return fd2num(fd);
  801815:	83 ec 0c             	sub    $0xc,%esp
  801818:	ff 75 f4             	pushl  -0xc(%ebp)
  80181b:	e8 1f f8 ff ff       	call   80103f <fd2num>
  801820:	89 c2                	mov    %eax,%edx
  801822:	83 c4 10             	add    $0x10,%esp
  801825:	eb 05                	jmp    80182c <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801827:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80182c:	89 d0                	mov    %edx,%eax
  80182e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801831:	c9                   	leave  
  801832:	c3                   	ret    

00801833 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801833:	55                   	push   %ebp
  801834:	89 e5                	mov    %esp,%ebp
  801836:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801839:	ba 00 00 00 00       	mov    $0x0,%edx
  80183e:	b8 08 00 00 00       	mov    $0x8,%eax
  801843:	e8 a6 fd ff ff       	call   8015ee <fsipc>
}
  801848:	c9                   	leave  
  801849:	c3                   	ret    

0080184a <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80184a:	55                   	push   %ebp
  80184b:	89 e5                	mov    %esp,%ebp
  80184d:	56                   	push   %esi
  80184e:	53                   	push   %ebx
  80184f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801852:	83 ec 0c             	sub    $0xc,%esp
  801855:	ff 75 08             	pushl  0x8(%ebp)
  801858:	e8 f2 f7 ff ff       	call   80104f <fd2data>
  80185d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80185f:	83 c4 08             	add    $0x8,%esp
  801862:	68 ef 26 80 00       	push   $0x8026ef
  801867:	53                   	push   %ebx
  801868:	e8 3f ef ff ff       	call   8007ac <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80186d:	8b 46 04             	mov    0x4(%esi),%eax
  801870:	2b 06                	sub    (%esi),%eax
  801872:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801878:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80187f:	00 00 00 
	stat->st_dev = &devpipe;
  801882:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801889:	30 80 00 
	return 0;
}
  80188c:	b8 00 00 00 00       	mov    $0x0,%eax
  801891:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801894:	5b                   	pop    %ebx
  801895:	5e                   	pop    %esi
  801896:	5d                   	pop    %ebp
  801897:	c3                   	ret    

00801898 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	53                   	push   %ebx
  80189c:	83 ec 0c             	sub    $0xc,%esp
  80189f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8018a2:	53                   	push   %ebx
  8018a3:	6a 00                	push   $0x0
  8018a5:	e8 8a f3 ff ff       	call   800c34 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8018aa:	89 1c 24             	mov    %ebx,(%esp)
  8018ad:	e8 9d f7 ff ff       	call   80104f <fd2data>
  8018b2:	83 c4 08             	add    $0x8,%esp
  8018b5:	50                   	push   %eax
  8018b6:	6a 00                	push   $0x0
  8018b8:	e8 77 f3 ff ff       	call   800c34 <sys_page_unmap>
}
  8018bd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018c0:	c9                   	leave  
  8018c1:	c3                   	ret    

008018c2 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8018c2:	55                   	push   %ebp
  8018c3:	89 e5                	mov    %esp,%ebp
  8018c5:	57                   	push   %edi
  8018c6:	56                   	push   %esi
  8018c7:	53                   	push   %ebx
  8018c8:	83 ec 1c             	sub    $0x1c,%esp
  8018cb:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8018ce:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8018d0:	a1 04 40 80 00       	mov    0x804004,%eax
  8018d5:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8018d8:	83 ec 0c             	sub    $0xc,%esp
  8018db:	ff 75 e0             	pushl  -0x20(%ebp)
  8018de:	e8 09 06 00 00       	call   801eec <pageref>
  8018e3:	89 c3                	mov    %eax,%ebx
  8018e5:	89 3c 24             	mov    %edi,(%esp)
  8018e8:	e8 ff 05 00 00       	call   801eec <pageref>
  8018ed:	83 c4 10             	add    $0x10,%esp
  8018f0:	39 c3                	cmp    %eax,%ebx
  8018f2:	0f 94 c1             	sete   %cl
  8018f5:	0f b6 c9             	movzbl %cl,%ecx
  8018f8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8018fb:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801901:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801904:	39 ce                	cmp    %ecx,%esi
  801906:	74 1b                	je     801923 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801908:	39 c3                	cmp    %eax,%ebx
  80190a:	75 c4                	jne    8018d0 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80190c:	8b 42 58             	mov    0x58(%edx),%eax
  80190f:	ff 75 e4             	pushl  -0x1c(%ebp)
  801912:	50                   	push   %eax
  801913:	56                   	push   %esi
  801914:	68 f6 26 80 00       	push   $0x8026f6
  801919:	e8 8a e8 ff ff       	call   8001a8 <cprintf>
  80191e:	83 c4 10             	add    $0x10,%esp
  801921:	eb ad                	jmp    8018d0 <_pipeisclosed+0xe>
	}
}
  801923:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801926:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801929:	5b                   	pop    %ebx
  80192a:	5e                   	pop    %esi
  80192b:	5f                   	pop    %edi
  80192c:	5d                   	pop    %ebp
  80192d:	c3                   	ret    

0080192e <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80192e:	55                   	push   %ebp
  80192f:	89 e5                	mov    %esp,%ebp
  801931:	57                   	push   %edi
  801932:	56                   	push   %esi
  801933:	53                   	push   %ebx
  801934:	83 ec 28             	sub    $0x28,%esp
  801937:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  80193a:	56                   	push   %esi
  80193b:	e8 0f f7 ff ff       	call   80104f <fd2data>
  801940:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801942:	83 c4 10             	add    $0x10,%esp
  801945:	bf 00 00 00 00       	mov    $0x0,%edi
  80194a:	eb 4b                	jmp    801997 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80194c:	89 da                	mov    %ebx,%edx
  80194e:	89 f0                	mov    %esi,%eax
  801950:	e8 6d ff ff ff       	call   8018c2 <_pipeisclosed>
  801955:	85 c0                	test   %eax,%eax
  801957:	75 48                	jne    8019a1 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801959:	e8 32 f2 ff ff       	call   800b90 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80195e:	8b 43 04             	mov    0x4(%ebx),%eax
  801961:	8b 0b                	mov    (%ebx),%ecx
  801963:	8d 51 20             	lea    0x20(%ecx),%edx
  801966:	39 d0                	cmp    %edx,%eax
  801968:	73 e2                	jae    80194c <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80196a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80196d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801971:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801974:	89 c2                	mov    %eax,%edx
  801976:	c1 fa 1f             	sar    $0x1f,%edx
  801979:	89 d1                	mov    %edx,%ecx
  80197b:	c1 e9 1b             	shr    $0x1b,%ecx
  80197e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801981:	83 e2 1f             	and    $0x1f,%edx
  801984:	29 ca                	sub    %ecx,%edx
  801986:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80198a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80198e:	83 c0 01             	add    $0x1,%eax
  801991:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801994:	83 c7 01             	add    $0x1,%edi
  801997:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80199a:	75 c2                	jne    80195e <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80199c:	8b 45 10             	mov    0x10(%ebp),%eax
  80199f:	eb 05                	jmp    8019a6 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8019a1:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  8019a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019a9:	5b                   	pop    %ebx
  8019aa:	5e                   	pop    %esi
  8019ab:	5f                   	pop    %edi
  8019ac:	5d                   	pop    %ebp
  8019ad:	c3                   	ret    

008019ae <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  8019ae:	55                   	push   %ebp
  8019af:	89 e5                	mov    %esp,%ebp
  8019b1:	57                   	push   %edi
  8019b2:	56                   	push   %esi
  8019b3:	53                   	push   %ebx
  8019b4:	83 ec 18             	sub    $0x18,%esp
  8019b7:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8019ba:	57                   	push   %edi
  8019bb:	e8 8f f6 ff ff       	call   80104f <fd2data>
  8019c0:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8019c2:	83 c4 10             	add    $0x10,%esp
  8019c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8019ca:	eb 3d                	jmp    801a09 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8019cc:	85 db                	test   %ebx,%ebx
  8019ce:	74 04                	je     8019d4 <devpipe_read+0x26>
				return i;
  8019d0:	89 d8                	mov    %ebx,%eax
  8019d2:	eb 44                	jmp    801a18 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8019d4:	89 f2                	mov    %esi,%edx
  8019d6:	89 f8                	mov    %edi,%eax
  8019d8:	e8 e5 fe ff ff       	call   8018c2 <_pipeisclosed>
  8019dd:	85 c0                	test   %eax,%eax
  8019df:	75 32                	jne    801a13 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8019e1:	e8 aa f1 ff ff       	call   800b90 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8019e6:	8b 06                	mov    (%esi),%eax
  8019e8:	3b 46 04             	cmp    0x4(%esi),%eax
  8019eb:	74 df                	je     8019cc <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8019ed:	99                   	cltd   
  8019ee:	c1 ea 1b             	shr    $0x1b,%edx
  8019f1:	01 d0                	add    %edx,%eax
  8019f3:	83 e0 1f             	and    $0x1f,%eax
  8019f6:	29 d0                	sub    %edx,%eax
  8019f8:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8019fd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a00:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801a03:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801a06:	83 c3 01             	add    $0x1,%ebx
  801a09:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801a0c:	75 d8                	jne    8019e6 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801a0e:	8b 45 10             	mov    0x10(%ebp),%eax
  801a11:	eb 05                	jmp    801a18 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801a13:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801a18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a1b:	5b                   	pop    %ebx
  801a1c:	5e                   	pop    %esi
  801a1d:	5f                   	pop    %edi
  801a1e:	5d                   	pop    %ebp
  801a1f:	c3                   	ret    

00801a20 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801a20:	55                   	push   %ebp
  801a21:	89 e5                	mov    %esp,%ebp
  801a23:	56                   	push   %esi
  801a24:	53                   	push   %ebx
  801a25:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801a28:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a2b:	50                   	push   %eax
  801a2c:	e8 35 f6 ff ff       	call   801066 <fd_alloc>
  801a31:	83 c4 10             	add    $0x10,%esp
  801a34:	89 c2                	mov    %eax,%edx
  801a36:	85 c0                	test   %eax,%eax
  801a38:	0f 88 2c 01 00 00    	js     801b6a <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a3e:	83 ec 04             	sub    $0x4,%esp
  801a41:	68 07 04 00 00       	push   $0x407
  801a46:	ff 75 f4             	pushl  -0xc(%ebp)
  801a49:	6a 00                	push   $0x0
  801a4b:	e8 5f f1 ff ff       	call   800baf <sys_page_alloc>
  801a50:	83 c4 10             	add    $0x10,%esp
  801a53:	89 c2                	mov    %eax,%edx
  801a55:	85 c0                	test   %eax,%eax
  801a57:	0f 88 0d 01 00 00    	js     801b6a <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801a5d:	83 ec 0c             	sub    $0xc,%esp
  801a60:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a63:	50                   	push   %eax
  801a64:	e8 fd f5 ff ff       	call   801066 <fd_alloc>
  801a69:	89 c3                	mov    %eax,%ebx
  801a6b:	83 c4 10             	add    $0x10,%esp
  801a6e:	85 c0                	test   %eax,%eax
  801a70:	0f 88 e2 00 00 00    	js     801b58 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801a76:	83 ec 04             	sub    $0x4,%esp
  801a79:	68 07 04 00 00       	push   $0x407
  801a7e:	ff 75 f0             	pushl  -0x10(%ebp)
  801a81:	6a 00                	push   $0x0
  801a83:	e8 27 f1 ff ff       	call   800baf <sys_page_alloc>
  801a88:	89 c3                	mov    %eax,%ebx
  801a8a:	83 c4 10             	add    $0x10,%esp
  801a8d:	85 c0                	test   %eax,%eax
  801a8f:	0f 88 c3 00 00 00    	js     801b58 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801a95:	83 ec 0c             	sub    $0xc,%esp
  801a98:	ff 75 f4             	pushl  -0xc(%ebp)
  801a9b:	e8 af f5 ff ff       	call   80104f <fd2data>
  801aa0:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801aa2:	83 c4 0c             	add    $0xc,%esp
  801aa5:	68 07 04 00 00       	push   $0x407
  801aaa:	50                   	push   %eax
  801aab:	6a 00                	push   $0x0
  801aad:	e8 fd f0 ff ff       	call   800baf <sys_page_alloc>
  801ab2:	89 c3                	mov    %eax,%ebx
  801ab4:	83 c4 10             	add    $0x10,%esp
  801ab7:	85 c0                	test   %eax,%eax
  801ab9:	0f 88 89 00 00 00    	js     801b48 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801abf:	83 ec 0c             	sub    $0xc,%esp
  801ac2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ac5:	e8 85 f5 ff ff       	call   80104f <fd2data>
  801aca:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ad1:	50                   	push   %eax
  801ad2:	6a 00                	push   $0x0
  801ad4:	56                   	push   %esi
  801ad5:	6a 00                	push   $0x0
  801ad7:	e8 16 f1 ff ff       	call   800bf2 <sys_page_map>
  801adc:	89 c3                	mov    %eax,%ebx
  801ade:	83 c4 20             	add    $0x20,%esp
  801ae1:	85 c0                	test   %eax,%eax
  801ae3:	78 55                	js     801b3a <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801ae5:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801aeb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aee:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af3:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801afa:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801b00:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b03:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801b05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b08:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801b0f:	83 ec 0c             	sub    $0xc,%esp
  801b12:	ff 75 f4             	pushl  -0xc(%ebp)
  801b15:	e8 25 f5 ff ff       	call   80103f <fd2num>
  801b1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b1d:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801b1f:	83 c4 04             	add    $0x4,%esp
  801b22:	ff 75 f0             	pushl  -0x10(%ebp)
  801b25:	e8 15 f5 ff ff       	call   80103f <fd2num>
  801b2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801b2d:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801b30:	83 c4 10             	add    $0x10,%esp
  801b33:	ba 00 00 00 00       	mov    $0x0,%edx
  801b38:	eb 30                	jmp    801b6a <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801b3a:	83 ec 08             	sub    $0x8,%esp
  801b3d:	56                   	push   %esi
  801b3e:	6a 00                	push   $0x0
  801b40:	e8 ef f0 ff ff       	call   800c34 <sys_page_unmap>
  801b45:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801b48:	83 ec 08             	sub    $0x8,%esp
  801b4b:	ff 75 f0             	pushl  -0x10(%ebp)
  801b4e:	6a 00                	push   $0x0
  801b50:	e8 df f0 ff ff       	call   800c34 <sys_page_unmap>
  801b55:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801b58:	83 ec 08             	sub    $0x8,%esp
  801b5b:	ff 75 f4             	pushl  -0xc(%ebp)
  801b5e:	6a 00                	push   $0x0
  801b60:	e8 cf f0 ff ff       	call   800c34 <sys_page_unmap>
  801b65:	83 c4 10             	add    $0x10,%esp
  801b68:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801b6a:	89 d0                	mov    %edx,%eax
  801b6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6f:	5b                   	pop    %ebx
  801b70:	5e                   	pop    %esi
  801b71:	5d                   	pop    %ebp
  801b72:	c3                   	ret    

00801b73 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801b79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b7c:	50                   	push   %eax
  801b7d:	ff 75 08             	pushl  0x8(%ebp)
  801b80:	e8 30 f5 ff ff       	call   8010b5 <fd_lookup>
  801b85:	83 c4 10             	add    $0x10,%esp
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	78 18                	js     801ba4 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801b8c:	83 ec 0c             	sub    $0xc,%esp
  801b8f:	ff 75 f4             	pushl  -0xc(%ebp)
  801b92:	e8 b8 f4 ff ff       	call   80104f <fd2data>
	return _pipeisclosed(fd, p);
  801b97:	89 c2                	mov    %eax,%edx
  801b99:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b9c:	e8 21 fd ff ff       	call   8018c2 <_pipeisclosed>
  801ba1:	83 c4 10             	add    $0x10,%esp
}
  801ba4:	c9                   	leave  
  801ba5:	c3                   	ret    

00801ba6 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ba6:	55                   	push   %ebp
  801ba7:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801ba9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bae:	5d                   	pop    %ebp
  801baf:	c3                   	ret    

00801bb0 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801bb0:	55                   	push   %ebp
  801bb1:	89 e5                	mov    %esp,%ebp
  801bb3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801bb6:	68 0e 27 80 00       	push   $0x80270e
  801bbb:	ff 75 0c             	pushl  0xc(%ebp)
  801bbe:	e8 e9 eb ff ff       	call   8007ac <strcpy>
	return 0;
}
  801bc3:	b8 00 00 00 00       	mov    $0x0,%eax
  801bc8:	c9                   	leave  
  801bc9:	c3                   	ret    

00801bca <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801bca:	55                   	push   %ebp
  801bcb:	89 e5                	mov    %esp,%ebp
  801bcd:	57                   	push   %edi
  801bce:	56                   	push   %esi
  801bcf:	53                   	push   %ebx
  801bd0:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801bd6:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bdb:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801be1:	eb 2d                	jmp    801c10 <devcons_write+0x46>
		m = n - tot;
  801be3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801be6:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801be8:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801beb:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801bf0:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801bf3:	83 ec 04             	sub    $0x4,%esp
  801bf6:	53                   	push   %ebx
  801bf7:	03 45 0c             	add    0xc(%ebp),%eax
  801bfa:	50                   	push   %eax
  801bfb:	57                   	push   %edi
  801bfc:	e8 3d ed ff ff       	call   80093e <memmove>
		sys_cputs(buf, m);
  801c01:	83 c4 08             	add    $0x8,%esp
  801c04:	53                   	push   %ebx
  801c05:	57                   	push   %edi
  801c06:	e8 e8 ee ff ff       	call   800af3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801c0b:	01 de                	add    %ebx,%esi
  801c0d:	83 c4 10             	add    $0x10,%esp
  801c10:	89 f0                	mov    %esi,%eax
  801c12:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c15:	72 cc                	jb     801be3 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801c17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c1a:	5b                   	pop    %ebx
  801c1b:	5e                   	pop    %esi
  801c1c:	5f                   	pop    %edi
  801c1d:	5d                   	pop    %ebp
  801c1e:	c3                   	ret    

00801c1f <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801c1f:	55                   	push   %ebp
  801c20:	89 e5                	mov    %esp,%ebp
  801c22:	83 ec 08             	sub    $0x8,%esp
  801c25:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801c2a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801c2e:	74 2a                	je     801c5a <devcons_read+0x3b>
  801c30:	eb 05                	jmp    801c37 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801c32:	e8 59 ef ff ff       	call   800b90 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801c37:	e8 d5 ee ff ff       	call   800b11 <sys_cgetc>
  801c3c:	85 c0                	test   %eax,%eax
  801c3e:	74 f2                	je     801c32 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801c40:	85 c0                	test   %eax,%eax
  801c42:	78 16                	js     801c5a <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801c44:	83 f8 04             	cmp    $0x4,%eax
  801c47:	74 0c                	je     801c55 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801c49:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c4c:	88 02                	mov    %al,(%edx)
	return 1;
  801c4e:	b8 01 00 00 00       	mov    $0x1,%eax
  801c53:	eb 05                	jmp    801c5a <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801c55:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801c5a:	c9                   	leave  
  801c5b:	c3                   	ret    

00801c5c <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801c5c:	55                   	push   %ebp
  801c5d:	89 e5                	mov    %esp,%ebp
  801c5f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801c62:	8b 45 08             	mov    0x8(%ebp),%eax
  801c65:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801c68:	6a 01                	push   $0x1
  801c6a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c6d:	50                   	push   %eax
  801c6e:	e8 80 ee ff ff       	call   800af3 <sys_cputs>
}
  801c73:	83 c4 10             	add    $0x10,%esp
  801c76:	c9                   	leave  
  801c77:	c3                   	ret    

00801c78 <getchar>:

int
getchar(void)
{
  801c78:	55                   	push   %ebp
  801c79:	89 e5                	mov    %esp,%ebp
  801c7b:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801c7e:	6a 01                	push   $0x1
  801c80:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801c83:	50                   	push   %eax
  801c84:	6a 00                	push   $0x0
  801c86:	e8 90 f6 ff ff       	call   80131b <read>
	if (r < 0)
  801c8b:	83 c4 10             	add    $0x10,%esp
  801c8e:	85 c0                	test   %eax,%eax
  801c90:	78 0f                	js     801ca1 <getchar+0x29>
		return r;
	if (r < 1)
  801c92:	85 c0                	test   %eax,%eax
  801c94:	7e 06                	jle    801c9c <getchar+0x24>
		return -E_EOF;
	return c;
  801c96:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801c9a:	eb 05                	jmp    801ca1 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801c9c:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801ca1:	c9                   	leave  
  801ca2:	c3                   	ret    

00801ca3 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801ca3:	55                   	push   %ebp
  801ca4:	89 e5                	mov    %esp,%ebp
  801ca6:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ca9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cac:	50                   	push   %eax
  801cad:	ff 75 08             	pushl  0x8(%ebp)
  801cb0:	e8 00 f4 ff ff       	call   8010b5 <fd_lookup>
  801cb5:	83 c4 10             	add    $0x10,%esp
  801cb8:	85 c0                	test   %eax,%eax
  801cba:	78 11                	js     801ccd <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801cbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cbf:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801cc5:	39 10                	cmp    %edx,(%eax)
  801cc7:	0f 94 c0             	sete   %al
  801cca:	0f b6 c0             	movzbl %al,%eax
}
  801ccd:	c9                   	leave  
  801cce:	c3                   	ret    

00801ccf <opencons>:

int
opencons(void)
{
  801ccf:	55                   	push   %ebp
  801cd0:	89 e5                	mov    %esp,%ebp
  801cd2:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801cd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cd8:	50                   	push   %eax
  801cd9:	e8 88 f3 ff ff       	call   801066 <fd_alloc>
  801cde:	83 c4 10             	add    $0x10,%esp
		return r;
  801ce1:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801ce3:	85 c0                	test   %eax,%eax
  801ce5:	78 3e                	js     801d25 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ce7:	83 ec 04             	sub    $0x4,%esp
  801cea:	68 07 04 00 00       	push   $0x407
  801cef:	ff 75 f4             	pushl  -0xc(%ebp)
  801cf2:	6a 00                	push   $0x0
  801cf4:	e8 b6 ee ff ff       	call   800baf <sys_page_alloc>
  801cf9:	83 c4 10             	add    $0x10,%esp
		return r;
  801cfc:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801cfe:	85 c0                	test   %eax,%eax
  801d00:	78 23                	js     801d25 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801d02:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d0b:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801d0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d10:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801d17:	83 ec 0c             	sub    $0xc,%esp
  801d1a:	50                   	push   %eax
  801d1b:	e8 1f f3 ff ff       	call   80103f <fd2num>
  801d20:	89 c2                	mov    %eax,%edx
  801d22:	83 c4 10             	add    $0x10,%esp
}
  801d25:	89 d0                	mov    %edx,%eax
  801d27:	c9                   	leave  
  801d28:	c3                   	ret    

00801d29 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801d29:	55                   	push   %ebp
  801d2a:	89 e5                	mov    %esp,%ebp
  801d2c:	56                   	push   %esi
  801d2d:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801d2e:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801d31:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801d37:	e8 35 ee ff ff       	call   800b71 <sys_getenvid>
  801d3c:	83 ec 0c             	sub    $0xc,%esp
  801d3f:	ff 75 0c             	pushl  0xc(%ebp)
  801d42:	ff 75 08             	pushl  0x8(%ebp)
  801d45:	56                   	push   %esi
  801d46:	50                   	push   %eax
  801d47:	68 1c 27 80 00       	push   $0x80271c
  801d4c:	e8 57 e4 ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801d51:	83 c4 18             	add    $0x18,%esp
  801d54:	53                   	push   %ebx
  801d55:	ff 75 10             	pushl  0x10(%ebp)
  801d58:	e8 fa e3 ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  801d5d:	c7 04 24 54 22 80 00 	movl   $0x802254,(%esp)
  801d64:	e8 3f e4 ff ff       	call   8001a8 <cprintf>
  801d69:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801d6c:	cc                   	int3   
  801d6d:	eb fd                	jmp    801d6c <_panic+0x43>

00801d6f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801d6f:	55                   	push   %ebp
  801d70:	89 e5                	mov    %esp,%ebp
  801d72:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801d75:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801d7c:	75 4a                	jne    801dc8 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  801d7e:	a1 04 40 80 00       	mov    0x804004,%eax
  801d83:	8b 40 48             	mov    0x48(%eax),%eax
  801d86:	83 ec 04             	sub    $0x4,%esp
  801d89:	6a 07                	push   $0x7
  801d8b:	68 00 f0 bf ee       	push   $0xeebff000
  801d90:	50                   	push   %eax
  801d91:	e8 19 ee ff ff       	call   800baf <sys_page_alloc>
  801d96:	83 c4 10             	add    $0x10,%esp
  801d99:	85 c0                	test   %eax,%eax
  801d9b:	79 12                	jns    801daf <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  801d9d:	50                   	push   %eax
  801d9e:	68 40 27 80 00       	push   $0x802740
  801da3:	6a 21                	push   $0x21
  801da5:	68 58 27 80 00       	push   $0x802758
  801daa:	e8 7a ff ff ff       	call   801d29 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801daf:	a1 04 40 80 00       	mov    0x804004,%eax
  801db4:	8b 40 48             	mov    0x48(%eax),%eax
  801db7:	83 ec 08             	sub    $0x8,%esp
  801dba:	68 d2 1d 80 00       	push   $0x801dd2
  801dbf:	50                   	push   %eax
  801dc0:	e8 35 ef ff ff       	call   800cfa <sys_env_set_pgfault_upcall>
  801dc5:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  801dcb:	a3 00 60 80 00       	mov    %eax,0x806000
  801dd0:	c9                   	leave  
  801dd1:	c3                   	ret    

00801dd2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  801dd2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  801dd3:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  801dd8:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801dda:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  801ddd:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  801de0:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  801de4:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  801de9:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  801ded:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801def:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  801df0:	83 c4 04             	add    $0x4,%esp
	popfl
  801df3:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  801df4:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  801df5:	c3                   	ret    

00801df6 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801df6:	55                   	push   %ebp
  801df7:	89 e5                	mov    %esp,%ebp
  801df9:	56                   	push   %esi
  801dfa:	53                   	push   %ebx
  801dfb:	8b 75 08             	mov    0x8(%ebp),%esi
  801dfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e01:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801e04:	85 c0                	test   %eax,%eax
  801e06:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801e0b:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801e0e:	83 ec 0c             	sub    $0xc,%esp
  801e11:	50                   	push   %eax
  801e12:	e8 48 ef ff ff       	call   800d5f <sys_ipc_recv>
  801e17:	83 c4 10             	add    $0x10,%esp
  801e1a:	85 c0                	test   %eax,%eax
  801e1c:	79 16                	jns    801e34 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801e1e:	85 f6                	test   %esi,%esi
  801e20:	74 06                	je     801e28 <ipc_recv+0x32>
            *from_env_store = 0;
  801e22:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801e28:	85 db                	test   %ebx,%ebx
  801e2a:	74 2c                	je     801e58 <ipc_recv+0x62>
            *perm_store = 0;
  801e2c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801e32:	eb 24                	jmp    801e58 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801e34:	85 f6                	test   %esi,%esi
  801e36:	74 0a                	je     801e42 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801e38:	a1 04 40 80 00       	mov    0x804004,%eax
  801e3d:	8b 40 74             	mov    0x74(%eax),%eax
  801e40:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801e42:	85 db                	test   %ebx,%ebx
  801e44:	74 0a                	je     801e50 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801e46:	a1 04 40 80 00       	mov    0x804004,%eax
  801e4b:	8b 40 78             	mov    0x78(%eax),%eax
  801e4e:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801e50:	a1 04 40 80 00       	mov    0x804004,%eax
  801e55:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801e58:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e5b:	5b                   	pop    %ebx
  801e5c:	5e                   	pop    %esi
  801e5d:	5d                   	pop    %ebp
  801e5e:	c3                   	ret    

00801e5f <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801e5f:	55                   	push   %ebp
  801e60:	89 e5                	mov    %esp,%ebp
  801e62:	57                   	push   %edi
  801e63:	56                   	push   %esi
  801e64:	53                   	push   %ebx
  801e65:	83 ec 0c             	sub    $0xc,%esp
  801e68:	8b 7d 08             	mov    0x8(%ebp),%edi
  801e6b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801e6e:	8b 45 10             	mov    0x10(%ebp),%eax
  801e71:	85 c0                	test   %eax,%eax
  801e73:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801e78:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801e7b:	eb 1c                	jmp    801e99 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801e7d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801e80:	74 12                	je     801e94 <ipc_send+0x35>
  801e82:	50                   	push   %eax
  801e83:	68 66 27 80 00       	push   $0x802766
  801e88:	6a 3a                	push   $0x3a
  801e8a:	68 7c 27 80 00       	push   $0x80277c
  801e8f:	e8 95 fe ff ff       	call   801d29 <_panic>
		sys_yield();
  801e94:	e8 f7 ec ff ff       	call   800b90 <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801e99:	ff 75 14             	pushl  0x14(%ebp)
  801e9c:	53                   	push   %ebx
  801e9d:	56                   	push   %esi
  801e9e:	57                   	push   %edi
  801e9f:	e8 98 ee ff ff       	call   800d3c <sys_ipc_try_send>
  801ea4:	83 c4 10             	add    $0x10,%esp
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	78 d2                	js     801e7d <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801eab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eae:	5b                   	pop    %ebx
  801eaf:	5e                   	pop    %esi
  801eb0:	5f                   	pop    %edi
  801eb1:	5d                   	pop    %ebp
  801eb2:	c3                   	ret    

00801eb3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801eb3:	55                   	push   %ebp
  801eb4:	89 e5                	mov    %esp,%ebp
  801eb6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801eb9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ebe:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ec1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ec7:	8b 52 50             	mov    0x50(%edx),%edx
  801eca:	39 ca                	cmp    %ecx,%edx
  801ecc:	75 0d                	jne    801edb <ipc_find_env+0x28>
			return envs[i].env_id;
  801ece:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ed1:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ed6:	8b 40 48             	mov    0x48(%eax),%eax
  801ed9:	eb 0f                	jmp    801eea <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801edb:	83 c0 01             	add    $0x1,%eax
  801ede:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ee3:	75 d9                	jne    801ebe <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ee5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eea:	5d                   	pop    %ebp
  801eeb:	c3                   	ret    

00801eec <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801eec:	55                   	push   %ebp
  801eed:	89 e5                	mov    %esp,%ebp
  801eef:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801ef2:	89 d0                	mov    %edx,%eax
  801ef4:	c1 e8 16             	shr    $0x16,%eax
  801ef7:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801efe:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801f03:	f6 c1 01             	test   $0x1,%cl
  801f06:	74 1d                	je     801f25 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801f08:	c1 ea 0c             	shr    $0xc,%edx
  801f0b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801f12:	f6 c2 01             	test   $0x1,%dl
  801f15:	74 0e                	je     801f25 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801f17:	c1 ea 0c             	shr    $0xc,%edx
  801f1a:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801f21:	ef 
  801f22:	0f b7 c0             	movzwl %ax,%eax
}
  801f25:	5d                   	pop    %ebp
  801f26:	c3                   	ret    
  801f27:	66 90                	xchg   %ax,%ax
  801f29:	66 90                	xchg   %ax,%ax
  801f2b:	66 90                	xchg   %ax,%ax
  801f2d:	66 90                	xchg   %ax,%ax
  801f2f:	90                   	nop

00801f30 <__udivdi3>:
  801f30:	55                   	push   %ebp
  801f31:	57                   	push   %edi
  801f32:	56                   	push   %esi
  801f33:	53                   	push   %ebx
  801f34:	83 ec 1c             	sub    $0x1c,%esp
  801f37:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801f3b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801f3f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801f43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f47:	85 f6                	test   %esi,%esi
  801f49:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801f4d:	89 ca                	mov    %ecx,%edx
  801f4f:	89 f8                	mov    %edi,%eax
  801f51:	75 3d                	jne    801f90 <__udivdi3+0x60>
  801f53:	39 cf                	cmp    %ecx,%edi
  801f55:	0f 87 c5 00 00 00    	ja     802020 <__udivdi3+0xf0>
  801f5b:	85 ff                	test   %edi,%edi
  801f5d:	89 fd                	mov    %edi,%ebp
  801f5f:	75 0b                	jne    801f6c <__udivdi3+0x3c>
  801f61:	b8 01 00 00 00       	mov    $0x1,%eax
  801f66:	31 d2                	xor    %edx,%edx
  801f68:	f7 f7                	div    %edi
  801f6a:	89 c5                	mov    %eax,%ebp
  801f6c:	89 c8                	mov    %ecx,%eax
  801f6e:	31 d2                	xor    %edx,%edx
  801f70:	f7 f5                	div    %ebp
  801f72:	89 c1                	mov    %eax,%ecx
  801f74:	89 d8                	mov    %ebx,%eax
  801f76:	89 cf                	mov    %ecx,%edi
  801f78:	f7 f5                	div    %ebp
  801f7a:	89 c3                	mov    %eax,%ebx
  801f7c:	89 d8                	mov    %ebx,%eax
  801f7e:	89 fa                	mov    %edi,%edx
  801f80:	83 c4 1c             	add    $0x1c,%esp
  801f83:	5b                   	pop    %ebx
  801f84:	5e                   	pop    %esi
  801f85:	5f                   	pop    %edi
  801f86:	5d                   	pop    %ebp
  801f87:	c3                   	ret    
  801f88:	90                   	nop
  801f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f90:	39 ce                	cmp    %ecx,%esi
  801f92:	77 74                	ja     802008 <__udivdi3+0xd8>
  801f94:	0f bd fe             	bsr    %esi,%edi
  801f97:	83 f7 1f             	xor    $0x1f,%edi
  801f9a:	0f 84 98 00 00 00    	je     802038 <__udivdi3+0x108>
  801fa0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801fa5:	89 f9                	mov    %edi,%ecx
  801fa7:	89 c5                	mov    %eax,%ebp
  801fa9:	29 fb                	sub    %edi,%ebx
  801fab:	d3 e6                	shl    %cl,%esi
  801fad:	89 d9                	mov    %ebx,%ecx
  801faf:	d3 ed                	shr    %cl,%ebp
  801fb1:	89 f9                	mov    %edi,%ecx
  801fb3:	d3 e0                	shl    %cl,%eax
  801fb5:	09 ee                	or     %ebp,%esi
  801fb7:	89 d9                	mov    %ebx,%ecx
  801fb9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801fbd:	89 d5                	mov    %edx,%ebp
  801fbf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801fc3:	d3 ed                	shr    %cl,%ebp
  801fc5:	89 f9                	mov    %edi,%ecx
  801fc7:	d3 e2                	shl    %cl,%edx
  801fc9:	89 d9                	mov    %ebx,%ecx
  801fcb:	d3 e8                	shr    %cl,%eax
  801fcd:	09 c2                	or     %eax,%edx
  801fcf:	89 d0                	mov    %edx,%eax
  801fd1:	89 ea                	mov    %ebp,%edx
  801fd3:	f7 f6                	div    %esi
  801fd5:	89 d5                	mov    %edx,%ebp
  801fd7:	89 c3                	mov    %eax,%ebx
  801fd9:	f7 64 24 0c          	mull   0xc(%esp)
  801fdd:	39 d5                	cmp    %edx,%ebp
  801fdf:	72 10                	jb     801ff1 <__udivdi3+0xc1>
  801fe1:	8b 74 24 08          	mov    0x8(%esp),%esi
  801fe5:	89 f9                	mov    %edi,%ecx
  801fe7:	d3 e6                	shl    %cl,%esi
  801fe9:	39 c6                	cmp    %eax,%esi
  801feb:	73 07                	jae    801ff4 <__udivdi3+0xc4>
  801fed:	39 d5                	cmp    %edx,%ebp
  801fef:	75 03                	jne    801ff4 <__udivdi3+0xc4>
  801ff1:	83 eb 01             	sub    $0x1,%ebx
  801ff4:	31 ff                	xor    %edi,%edi
  801ff6:	89 d8                	mov    %ebx,%eax
  801ff8:	89 fa                	mov    %edi,%edx
  801ffa:	83 c4 1c             	add    $0x1c,%esp
  801ffd:	5b                   	pop    %ebx
  801ffe:	5e                   	pop    %esi
  801fff:	5f                   	pop    %edi
  802000:	5d                   	pop    %ebp
  802001:	c3                   	ret    
  802002:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802008:	31 ff                	xor    %edi,%edi
  80200a:	31 db                	xor    %ebx,%ebx
  80200c:	89 d8                	mov    %ebx,%eax
  80200e:	89 fa                	mov    %edi,%edx
  802010:	83 c4 1c             	add    $0x1c,%esp
  802013:	5b                   	pop    %ebx
  802014:	5e                   	pop    %esi
  802015:	5f                   	pop    %edi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    
  802018:	90                   	nop
  802019:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802020:	89 d8                	mov    %ebx,%eax
  802022:	f7 f7                	div    %edi
  802024:	31 ff                	xor    %edi,%edi
  802026:	89 c3                	mov    %eax,%ebx
  802028:	89 d8                	mov    %ebx,%eax
  80202a:	89 fa                	mov    %edi,%edx
  80202c:	83 c4 1c             	add    $0x1c,%esp
  80202f:	5b                   	pop    %ebx
  802030:	5e                   	pop    %esi
  802031:	5f                   	pop    %edi
  802032:	5d                   	pop    %ebp
  802033:	c3                   	ret    
  802034:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802038:	39 ce                	cmp    %ecx,%esi
  80203a:	72 0c                	jb     802048 <__udivdi3+0x118>
  80203c:	31 db                	xor    %ebx,%ebx
  80203e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802042:	0f 87 34 ff ff ff    	ja     801f7c <__udivdi3+0x4c>
  802048:	bb 01 00 00 00       	mov    $0x1,%ebx
  80204d:	e9 2a ff ff ff       	jmp    801f7c <__udivdi3+0x4c>
  802052:	66 90                	xchg   %ax,%ax
  802054:	66 90                	xchg   %ax,%ax
  802056:	66 90                	xchg   %ax,%ax
  802058:	66 90                	xchg   %ax,%ax
  80205a:	66 90                	xchg   %ax,%ax
  80205c:	66 90                	xchg   %ax,%ax
  80205e:	66 90                	xchg   %ax,%ax

00802060 <__umoddi3>:
  802060:	55                   	push   %ebp
  802061:	57                   	push   %edi
  802062:	56                   	push   %esi
  802063:	53                   	push   %ebx
  802064:	83 ec 1c             	sub    $0x1c,%esp
  802067:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80206b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80206f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802073:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802077:	85 d2                	test   %edx,%edx
  802079:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80207d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802081:	89 f3                	mov    %esi,%ebx
  802083:	89 3c 24             	mov    %edi,(%esp)
  802086:	89 74 24 04          	mov    %esi,0x4(%esp)
  80208a:	75 1c                	jne    8020a8 <__umoddi3+0x48>
  80208c:	39 f7                	cmp    %esi,%edi
  80208e:	76 50                	jbe    8020e0 <__umoddi3+0x80>
  802090:	89 c8                	mov    %ecx,%eax
  802092:	89 f2                	mov    %esi,%edx
  802094:	f7 f7                	div    %edi
  802096:	89 d0                	mov    %edx,%eax
  802098:	31 d2                	xor    %edx,%edx
  80209a:	83 c4 1c             	add    $0x1c,%esp
  80209d:	5b                   	pop    %ebx
  80209e:	5e                   	pop    %esi
  80209f:	5f                   	pop    %edi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    
  8020a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8020a8:	39 f2                	cmp    %esi,%edx
  8020aa:	89 d0                	mov    %edx,%eax
  8020ac:	77 52                	ja     802100 <__umoddi3+0xa0>
  8020ae:	0f bd ea             	bsr    %edx,%ebp
  8020b1:	83 f5 1f             	xor    $0x1f,%ebp
  8020b4:	75 5a                	jne    802110 <__umoddi3+0xb0>
  8020b6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8020ba:	0f 82 e0 00 00 00    	jb     8021a0 <__umoddi3+0x140>
  8020c0:	39 0c 24             	cmp    %ecx,(%esp)
  8020c3:	0f 86 d7 00 00 00    	jbe    8021a0 <__umoddi3+0x140>
  8020c9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020cd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8020d1:	83 c4 1c             	add    $0x1c,%esp
  8020d4:	5b                   	pop    %ebx
  8020d5:	5e                   	pop    %esi
  8020d6:	5f                   	pop    %edi
  8020d7:	5d                   	pop    %ebp
  8020d8:	c3                   	ret    
  8020d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020e0:	85 ff                	test   %edi,%edi
  8020e2:	89 fd                	mov    %edi,%ebp
  8020e4:	75 0b                	jne    8020f1 <__umoddi3+0x91>
  8020e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8020eb:	31 d2                	xor    %edx,%edx
  8020ed:	f7 f7                	div    %edi
  8020ef:	89 c5                	mov    %eax,%ebp
  8020f1:	89 f0                	mov    %esi,%eax
  8020f3:	31 d2                	xor    %edx,%edx
  8020f5:	f7 f5                	div    %ebp
  8020f7:	89 c8                	mov    %ecx,%eax
  8020f9:	f7 f5                	div    %ebp
  8020fb:	89 d0                	mov    %edx,%eax
  8020fd:	eb 99                	jmp    802098 <__umoddi3+0x38>
  8020ff:	90                   	nop
  802100:	89 c8                	mov    %ecx,%eax
  802102:	89 f2                	mov    %esi,%edx
  802104:	83 c4 1c             	add    $0x1c,%esp
  802107:	5b                   	pop    %ebx
  802108:	5e                   	pop    %esi
  802109:	5f                   	pop    %edi
  80210a:	5d                   	pop    %ebp
  80210b:	c3                   	ret    
  80210c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802110:	8b 34 24             	mov    (%esp),%esi
  802113:	bf 20 00 00 00       	mov    $0x20,%edi
  802118:	89 e9                	mov    %ebp,%ecx
  80211a:	29 ef                	sub    %ebp,%edi
  80211c:	d3 e0                	shl    %cl,%eax
  80211e:	89 f9                	mov    %edi,%ecx
  802120:	89 f2                	mov    %esi,%edx
  802122:	d3 ea                	shr    %cl,%edx
  802124:	89 e9                	mov    %ebp,%ecx
  802126:	09 c2                	or     %eax,%edx
  802128:	89 d8                	mov    %ebx,%eax
  80212a:	89 14 24             	mov    %edx,(%esp)
  80212d:	89 f2                	mov    %esi,%edx
  80212f:	d3 e2                	shl    %cl,%edx
  802131:	89 f9                	mov    %edi,%ecx
  802133:	89 54 24 04          	mov    %edx,0x4(%esp)
  802137:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80213b:	d3 e8                	shr    %cl,%eax
  80213d:	89 e9                	mov    %ebp,%ecx
  80213f:	89 c6                	mov    %eax,%esi
  802141:	d3 e3                	shl    %cl,%ebx
  802143:	89 f9                	mov    %edi,%ecx
  802145:	89 d0                	mov    %edx,%eax
  802147:	d3 e8                	shr    %cl,%eax
  802149:	89 e9                	mov    %ebp,%ecx
  80214b:	09 d8                	or     %ebx,%eax
  80214d:	89 d3                	mov    %edx,%ebx
  80214f:	89 f2                	mov    %esi,%edx
  802151:	f7 34 24             	divl   (%esp)
  802154:	89 d6                	mov    %edx,%esi
  802156:	d3 e3                	shl    %cl,%ebx
  802158:	f7 64 24 04          	mull   0x4(%esp)
  80215c:	39 d6                	cmp    %edx,%esi
  80215e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802162:	89 d1                	mov    %edx,%ecx
  802164:	89 c3                	mov    %eax,%ebx
  802166:	72 08                	jb     802170 <__umoddi3+0x110>
  802168:	75 11                	jne    80217b <__umoddi3+0x11b>
  80216a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80216e:	73 0b                	jae    80217b <__umoddi3+0x11b>
  802170:	2b 44 24 04          	sub    0x4(%esp),%eax
  802174:	1b 14 24             	sbb    (%esp),%edx
  802177:	89 d1                	mov    %edx,%ecx
  802179:	89 c3                	mov    %eax,%ebx
  80217b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80217f:	29 da                	sub    %ebx,%edx
  802181:	19 ce                	sbb    %ecx,%esi
  802183:	89 f9                	mov    %edi,%ecx
  802185:	89 f0                	mov    %esi,%eax
  802187:	d3 e0                	shl    %cl,%eax
  802189:	89 e9                	mov    %ebp,%ecx
  80218b:	d3 ea                	shr    %cl,%edx
  80218d:	89 e9                	mov    %ebp,%ecx
  80218f:	d3 ee                	shr    %cl,%esi
  802191:	09 d0                	or     %edx,%eax
  802193:	89 f2                	mov    %esi,%edx
  802195:	83 c4 1c             	add    $0x1c,%esp
  802198:	5b                   	pop    %ebx
  802199:	5e                   	pop    %esi
  80219a:	5f                   	pop    %edi
  80219b:	5d                   	pop    %ebp
  80219c:	c3                   	ret    
  80219d:	8d 76 00             	lea    0x0(%esi),%esi
  8021a0:	29 f9                	sub    %edi,%ecx
  8021a2:	19 d6                	sbb    %edx,%esi
  8021a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8021a8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8021ac:	e9 18 ff ff ff       	jmp    8020c9 <__umoddi3+0x69>
