
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
  80003a:	68 60 26 80 00       	push   $0x802660
  80003f:	e8 64 01 00 00       	call   8001a8 <cprintf>
	if ((env = fork()) == 0) {
  800044:	e8 88 0e 00 00       	call   800ed1 <fork>
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	85 c0                	test   %eax,%eax
  80004e:	75 12                	jne    800062 <umain+0x2f>
		cprintf("I am the child.  Spinning...\n");
  800050:	83 ec 0c             	sub    $0xc,%esp
  800053:	68 d8 26 80 00       	push   $0x8026d8
  800058:	e8 4b 01 00 00       	call   8001a8 <cprintf>
  80005d:	83 c4 10             	add    $0x10,%esp
  800060:	eb fe                	jmp    800060 <umain+0x2d>
  800062:	89 c3                	mov    %eax,%ebx
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  800064:	83 ec 0c             	sub    $0xc,%esp
  800067:	68 88 26 80 00       	push   $0x802688
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
  800099:	c7 04 24 b0 26 80 00 	movl   $0x8026b0,(%esp)
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
  8000d2:	a3 08 40 80 00       	mov    %eax,0x804008

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
  800101:	e8 43 11 00 00       	call   801249 <close_all>
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
  80020b:	e8 c0 21 00 00       	call   8023d0 <__udivdi3>
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
  80024e:	e8 ad 22 00 00       	call   802500 <__umoddi3>
  800253:	83 c4 14             	add    $0x14,%esp
  800256:	0f be 80 00 27 80 00 	movsbl 0x802700(%eax),%eax
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
  800318:	ff 24 85 40 28 80 00 	jmp    *0x802840(,%eax,4)
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
  8003df:	8b 14 85 a0 29 80 00 	mov    0x8029a0(,%eax,4),%edx
  8003e6:	85 d2                	test   %edx,%edx
  8003e8:	75 1b                	jne    800405 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003ea:	50                   	push   %eax
  8003eb:	68 18 27 80 00       	push   $0x802718
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
  800406:	68 79 2b 80 00       	push   $0x802b79
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
  800430:	b8 11 27 80 00       	mov    $0x802711,%eax
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
  800b58:	68 ff 29 80 00       	push   $0x8029ff
  800b5d:	6a 23                	push   $0x23
  800b5f:	68 1c 2a 80 00       	push   $0x802a1c
  800b64:	e8 66 16 00 00       	call   8021cf <_panic>

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
  800bd9:	68 ff 29 80 00       	push   $0x8029ff
  800bde:	6a 23                	push   $0x23
  800be0:	68 1c 2a 80 00       	push   $0x802a1c
  800be5:	e8 e5 15 00 00       	call   8021cf <_panic>

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
  800c1b:	68 ff 29 80 00       	push   $0x8029ff
  800c20:	6a 23                	push   $0x23
  800c22:	68 1c 2a 80 00       	push   $0x802a1c
  800c27:	e8 a3 15 00 00       	call   8021cf <_panic>

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
  800c5d:	68 ff 29 80 00       	push   $0x8029ff
  800c62:	6a 23                	push   $0x23
  800c64:	68 1c 2a 80 00       	push   $0x802a1c
  800c69:	e8 61 15 00 00       	call   8021cf <_panic>

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
  800c9f:	68 ff 29 80 00       	push   $0x8029ff
  800ca4:	6a 23                	push   $0x23
  800ca6:	68 1c 2a 80 00       	push   $0x802a1c
  800cab:	e8 1f 15 00 00       	call   8021cf <_panic>

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
  800ce1:	68 ff 29 80 00       	push   $0x8029ff
  800ce6:	6a 23                	push   $0x23
  800ce8:	68 1c 2a 80 00       	push   $0x802a1c
  800ced:	e8 dd 14 00 00       	call   8021cf <_panic>

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
  800d23:	68 ff 29 80 00       	push   $0x8029ff
  800d28:	6a 23                	push   $0x23
  800d2a:	68 1c 2a 80 00       	push   $0x802a1c
  800d2f:	e8 9b 14 00 00       	call   8021cf <_panic>

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
  800d87:	68 ff 29 80 00       	push   $0x8029ff
  800d8c:	6a 23                	push   $0x23
  800d8e:	68 1c 2a 80 00       	push   $0x802a1c
  800d93:	e8 37 14 00 00       	call   8021cf <_panic>

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

00800da0 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800da0:	55                   	push   %ebp
  800da1:	89 e5                	mov    %esp,%ebp
  800da3:	57                   	push   %edi
  800da4:	56                   	push   %esi
  800da5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da6:	ba 00 00 00 00       	mov    $0x0,%edx
  800dab:	b8 0e 00 00 00       	mov    $0xe,%eax
  800db0:	89 d1                	mov    %edx,%ecx
  800db2:	89 d3                	mov    %edx,%ebx
  800db4:	89 d7                	mov    %edx,%edi
  800db6:	89 d6                	mov    %edx,%esi
  800db8:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dba:	5b                   	pop    %ebx
  800dbb:	5e                   	pop    %esi
  800dbc:	5f                   	pop    %edi
  800dbd:	5d                   	pop    %ebp
  800dbe:	c3                   	ret    

00800dbf <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800dbf:	55                   	push   %ebp
  800dc0:	89 e5                	mov    %esp,%ebp
  800dc2:	57                   	push   %edi
  800dc3:	56                   	push   %esi
  800dc4:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dca:	b8 10 00 00 00       	mov    $0x10,%eax
  800dcf:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd2:	89 cb                	mov    %ecx,%ebx
  800dd4:	89 cf                	mov    %ecx,%edi
  800dd6:	89 ce                	mov    %ecx,%esi
  800dd8:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800dda:	5b                   	pop    %ebx
  800ddb:	5e                   	pop    %esi
  800ddc:	5f                   	pop    %edi
  800ddd:	5d                   	pop    %ebp
  800dde:	c3                   	ret    

00800ddf <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800ddf:	55                   	push   %ebp
  800de0:	89 e5                	mov    %esp,%ebp
  800de2:	53                   	push   %ebx
  800de3:	83 ec 04             	sub    $0x4,%esp
  800de6:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800de9:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800deb:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800def:	74 2d                	je     800e1e <pgfault+0x3f>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800df1:	89 d8                	mov    %ebx,%eax
  800df3:	c1 e8 16             	shr    $0x16,%eax
  800df6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800dfd:	a8 01                	test   $0x1,%al
  800dff:	74 1d                	je     800e1e <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e01:	89 d8                	mov    %ebx,%eax
  800e03:	c1 e8 0c             	shr    $0xc,%eax
  800e06:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800e0d:	f6 c2 01             	test   $0x1,%dl
  800e10:	74 0c                	je     800e1e <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  800e12:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800e19:	f6 c4 08             	test   $0x8,%ah
  800e1c:	75 14                	jne    800e32 <pgfault+0x53>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
	)) panic("Neither the fault is a write nor copy-on-write page.\n");
  800e1e:	83 ec 04             	sub    $0x4,%esp
  800e21:	68 2c 2a 80 00       	push   $0x802a2c
  800e26:	6a 1f                	push   $0x1f
  800e28:	68 62 2a 80 00       	push   $0x802a62
  800e2d:	e8 9d 13 00 00       	call   8021cf <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W)) < 0){
  800e32:	83 ec 04             	sub    $0x4,%esp
  800e35:	6a 07                	push   $0x7
  800e37:	68 00 f0 7f 00       	push   $0x7ff000
  800e3c:	6a 00                	push   $0x0
  800e3e:	e8 6c fd ff ff       	call   800baf <sys_page_alloc>
  800e43:	83 c4 10             	add    $0x10,%esp
  800e46:	85 c0                	test   %eax,%eax
  800e48:	79 12                	jns    800e5c <pgfault+0x7d>
		 panic("sys_page_alloc: %e\n", r);
  800e4a:	50                   	push   %eax
  800e4b:	68 6d 2a 80 00       	push   $0x802a6d
  800e50:	6a 29                	push   $0x29
  800e52:	68 62 2a 80 00       	push   $0x802a62
  800e57:	e8 73 13 00 00       	call   8021cf <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  800e5c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP, addr, PGSIZE);
  800e62:	83 ec 04             	sub    $0x4,%esp
  800e65:	68 00 10 00 00       	push   $0x1000
  800e6a:	53                   	push   %ebx
  800e6b:	68 00 f0 7f 00       	push   $0x7ff000
  800e70:	e8 31 fb ff ff       	call   8009a6 <memcpy>
	if ((r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  800e75:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800e7c:	53                   	push   %ebx
  800e7d:	6a 00                	push   $0x0
  800e7f:	68 00 f0 7f 00       	push   $0x7ff000
  800e84:	6a 00                	push   $0x0
  800e86:	e8 67 fd ff ff       	call   800bf2 <sys_page_map>
  800e8b:	83 c4 20             	add    $0x20,%esp
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	79 12                	jns    800ea4 <pgfault+0xc5>
        panic("sys_page_map: %e\n", r);
  800e92:	50                   	push   %eax
  800e93:	68 81 2a 80 00       	push   $0x802a81
  800e98:	6a 2e                	push   $0x2e
  800e9a:	68 62 2a 80 00       	push   $0x802a62
  800e9f:	e8 2b 13 00 00       	call   8021cf <_panic>
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  800ea4:	83 ec 08             	sub    $0x8,%esp
  800ea7:	68 00 f0 7f 00       	push   $0x7ff000
  800eac:	6a 00                	push   $0x0
  800eae:	e8 81 fd ff ff       	call   800c34 <sys_page_unmap>
  800eb3:	83 c4 10             	add    $0x10,%esp
  800eb6:	85 c0                	test   %eax,%eax
  800eb8:	79 12                	jns    800ecc <pgfault+0xed>
        panic("sys_page_unmap: %e\n", r);
  800eba:	50                   	push   %eax
  800ebb:	68 93 2a 80 00       	push   $0x802a93
  800ec0:	6a 30                	push   $0x30
  800ec2:	68 62 2a 80 00       	push   $0x802a62
  800ec7:	e8 03 13 00 00       	call   8021cf <_panic>
	//panic("pgfault not implemented");
}
  800ecc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ecf:	c9                   	leave  
  800ed0:	c3                   	ret    

00800ed1 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	57                   	push   %edi
  800ed5:	56                   	push   %esi
  800ed6:	53                   	push   %ebx
  800ed7:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	envid_t cenvid;
    unsigned pn;
    int r;
	set_pgfault_handler(pgfault);
  800eda:	68 df 0d 80 00       	push   $0x800ddf
  800edf:	e8 31 13 00 00       	call   802215 <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800ee4:	b8 07 00 00 00       	mov    $0x7,%eax
  800ee9:	cd 30                	int    $0x30
  800eeb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((cenvid = sys_exofork()) < 0){
  800eee:	83 c4 10             	add    $0x10,%esp
  800ef1:	85 c0                	test   %eax,%eax
  800ef3:	79 14                	jns    800f09 <fork+0x38>
		panic("sys_exofork failed");
  800ef5:	83 ec 04             	sub    $0x4,%esp
  800ef8:	68 a7 2a 80 00       	push   $0x802aa7
  800efd:	6a 6f                	push   $0x6f
  800eff:	68 62 2a 80 00       	push   $0x802a62
  800f04:	e8 c6 12 00 00       	call   8021cf <_panic>
  800f09:	89 c7                	mov    %eax,%edi
		return cenvid;
	}
	if(cenvid>0){
  800f0b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f0f:	0f 8e 2b 01 00 00    	jle    801040 <fork+0x16f>
  800f15:	bb 00 08 00 00       	mov    $0x800,%ebx
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
  800f1a:	89 d8                	mov    %ebx,%eax
  800f1c:	c1 e8 0a             	shr    $0xa,%eax
  800f1f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f26:	a8 01                	test   $0x1,%al
  800f28:	0f 84 bf 00 00 00    	je     800fed <fork+0x11c>
  800f2e:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f35:	a8 01                	test   $0x1,%al
  800f37:	0f 84 b0 00 00 00    	je     800fed <fork+0x11c>
  800f3d:	89 de                	mov    %ebx,%esi
  800f3f:	c1 e6 0c             	shl    $0xc,%esi
{
	int r;

	// LAB 4: Your code here.
	void* vaddr=(void*)(pn*PGSIZE);
	if(uvpt[pn]&PTE_SHARE){
  800f42:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f49:	f6 c4 04             	test   $0x4,%ah
  800f4c:	74 29                	je     800f77 <fork+0xa6>
		if((r=sys_page_map(0,vaddr,envid,vaddr,uvpt[pn]&PTE_SYSCALL))<0)return r;
  800f4e:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f55:	83 ec 0c             	sub    $0xc,%esp
  800f58:	25 07 0e 00 00       	and    $0xe07,%eax
  800f5d:	50                   	push   %eax
  800f5e:	56                   	push   %esi
  800f5f:	57                   	push   %edi
  800f60:	56                   	push   %esi
  800f61:	6a 00                	push   $0x0
  800f63:	e8 8a fc ff ff       	call   800bf2 <sys_page_map>
  800f68:	83 c4 20             	add    $0x20,%esp
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	ba 00 00 00 00       	mov    $0x0,%edx
  800f72:	0f 4f c2             	cmovg  %edx,%eax
  800f75:	eb 72                	jmp    800fe9 <fork+0x118>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  800f77:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f7e:	a8 02                	test   $0x2,%al
  800f80:	75 0c                	jne    800f8e <fork+0xbd>
  800f82:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  800f89:	f6 c4 08             	test   $0x8,%ah
  800f8c:	74 3f                	je     800fcd <fork+0xfc>
		if ((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  800f8e:	83 ec 0c             	sub    $0xc,%esp
  800f91:	68 05 08 00 00       	push   $0x805
  800f96:	56                   	push   %esi
  800f97:	57                   	push   %edi
  800f98:	56                   	push   %esi
  800f99:	6a 00                	push   $0x0
  800f9b:	e8 52 fc ff ff       	call   800bf2 <sys_page_map>
  800fa0:	83 c4 20             	add    $0x20,%esp
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	0f 88 b1 00 00 00    	js     80105c <fork+0x18b>
            return r;
        if ((r = sys_page_map(0, vaddr, 0, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  800fab:	83 ec 0c             	sub    $0xc,%esp
  800fae:	68 05 08 00 00       	push   $0x805
  800fb3:	56                   	push   %esi
  800fb4:	6a 00                	push   $0x0
  800fb6:	56                   	push   %esi
  800fb7:	6a 00                	push   $0x0
  800fb9:	e8 34 fc ff ff       	call   800bf2 <sys_page_map>
  800fbe:	83 c4 20             	add    $0x20,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fc8:	0f 4f c1             	cmovg  %ecx,%eax
  800fcb:	eb 1c                	jmp    800fe9 <fork+0x118>
            return r;
	}
	else if((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U)) < 0) {
  800fcd:	83 ec 0c             	sub    $0xc,%esp
  800fd0:	6a 05                	push   $0x5
  800fd2:	56                   	push   %esi
  800fd3:	57                   	push   %edi
  800fd4:	56                   	push   %esi
  800fd5:	6a 00                	push   $0x0
  800fd7:	e8 16 fc ff ff       	call   800bf2 <sys_page_map>
  800fdc:	83 c4 20             	add    $0x20,%esp
  800fdf:	85 c0                	test   %eax,%eax
  800fe1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe6:	0f 4f c1             	cmovg  %ecx,%eax
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
  800fe9:	85 c0                	test   %eax,%eax
  800feb:	78 6f                	js     80105c <fork+0x18b>
	if ((cenvid = sys_exofork()) < 0){
		panic("sys_exofork failed");
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  800fed:	83 c3 01             	add    $0x1,%ebx
  800ff0:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  800ff6:	0f 85 1e ff ff ff    	jne    800f1a <fork+0x49>
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
                    return r;
		}
		if ((r = sys_page_alloc(cenvid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  800ffc:	83 ec 04             	sub    $0x4,%esp
  800fff:	6a 07                	push   $0x7
  801001:	68 00 f0 bf ee       	push   $0xeebff000
  801006:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801009:	57                   	push   %edi
  80100a:	e8 a0 fb ff ff       	call   800baf <sys_page_alloc>
  80100f:	83 c4 10             	add    $0x10,%esp
  801012:	85 c0                	test   %eax,%eax
  801014:	78 46                	js     80105c <fork+0x18b>
            return r;
		extern void _pgfault_upcall(void);
		if ((r = sys_env_set_pgfault_upcall(cenvid, _pgfault_upcall)) < 0)
  801016:	83 ec 08             	sub    $0x8,%esp
  801019:	68 78 22 80 00       	push   $0x802278
  80101e:	57                   	push   %edi
  80101f:	e8 d6 fc ff ff       	call   800cfa <sys_env_set_pgfault_upcall>
  801024:	83 c4 10             	add    $0x10,%esp
  801027:	85 c0                	test   %eax,%eax
  801029:	78 31                	js     80105c <fork+0x18b>
            return r;
		if ((r = sys_env_set_status(cenvid, ENV_RUNNABLE)) < 0)
  80102b:	83 ec 08             	sub    $0x8,%esp
  80102e:	6a 02                	push   $0x2
  801030:	57                   	push   %edi
  801031:	e8 40 fc ff ff       	call   800c76 <sys_env_set_status>
  801036:	83 c4 10             	add    $0x10,%esp
            return r;
        return cenvid;
  801039:	85 c0                	test   %eax,%eax
  80103b:	0f 49 c7             	cmovns %edi,%eax
  80103e:	eb 1c                	jmp    80105c <fork+0x18b>
	}
	else {
		thisenv = &envs[ENVX(sys_getenvid())];
  801040:	e8 2c fb ff ff       	call   800b71 <sys_getenvid>
  801045:	25 ff 03 00 00       	and    $0x3ff,%eax
  80104a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80104d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801052:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  801057:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//panic("fork not implemented");
	
}
  80105c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80105f:	5b                   	pop    %ebx
  801060:	5e                   	pop    %esi
  801061:	5f                   	pop    %edi
  801062:	5d                   	pop    %ebp
  801063:	c3                   	ret    

00801064 <sfork>:

// Challenge!
int
sfork(void)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80106a:	68 ba 2a 80 00       	push   $0x802aba
  80106f:	68 8d 00 00 00       	push   $0x8d
  801074:	68 62 2a 80 00       	push   $0x802a62
  801079:	e8 51 11 00 00       	call   8021cf <_panic>

0080107e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801081:	8b 45 08             	mov    0x8(%ebp),%eax
  801084:	05 00 00 00 30       	add    $0x30000000,%eax
  801089:	c1 e8 0c             	shr    $0xc,%eax
}
  80108c:	5d                   	pop    %ebp
  80108d:	c3                   	ret    

0080108e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80108e:	55                   	push   %ebp
  80108f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801091:	8b 45 08             	mov    0x8(%ebp),%eax
  801094:	05 00 00 00 30       	add    $0x30000000,%eax
  801099:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80109e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8010a3:	5d                   	pop    %ebp
  8010a4:	c3                   	ret    

008010a5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8010a5:	55                   	push   %ebp
  8010a6:	89 e5                	mov    %esp,%ebp
  8010a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ab:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8010b0:	89 c2                	mov    %eax,%edx
  8010b2:	c1 ea 16             	shr    $0x16,%edx
  8010b5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8010bc:	f6 c2 01             	test   $0x1,%dl
  8010bf:	74 11                	je     8010d2 <fd_alloc+0x2d>
  8010c1:	89 c2                	mov    %eax,%edx
  8010c3:	c1 ea 0c             	shr    $0xc,%edx
  8010c6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010cd:	f6 c2 01             	test   $0x1,%dl
  8010d0:	75 09                	jne    8010db <fd_alloc+0x36>
			*fd_store = fd;
  8010d2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8010d9:	eb 17                	jmp    8010f2 <fd_alloc+0x4d>
  8010db:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8010e0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010e5:	75 c9                	jne    8010b0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010e7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8010ed:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8010f2:	5d                   	pop    %ebp
  8010f3:	c3                   	ret    

008010f4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010f4:	55                   	push   %ebp
  8010f5:	89 e5                	mov    %esp,%ebp
  8010f7:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010fa:	83 f8 1f             	cmp    $0x1f,%eax
  8010fd:	77 36                	ja     801135 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010ff:	c1 e0 0c             	shl    $0xc,%eax
  801102:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801107:	89 c2                	mov    %eax,%edx
  801109:	c1 ea 16             	shr    $0x16,%edx
  80110c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801113:	f6 c2 01             	test   $0x1,%dl
  801116:	74 24                	je     80113c <fd_lookup+0x48>
  801118:	89 c2                	mov    %eax,%edx
  80111a:	c1 ea 0c             	shr    $0xc,%edx
  80111d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801124:	f6 c2 01             	test   $0x1,%dl
  801127:	74 1a                	je     801143 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801129:	8b 55 0c             	mov    0xc(%ebp),%edx
  80112c:	89 02                	mov    %eax,(%edx)
	return 0;
  80112e:	b8 00 00 00 00       	mov    $0x0,%eax
  801133:	eb 13                	jmp    801148 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801135:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80113a:	eb 0c                	jmp    801148 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80113c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801141:	eb 05                	jmp    801148 <fd_lookup+0x54>
  801143:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801148:	5d                   	pop    %ebp
  801149:	c3                   	ret    

0080114a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80114a:	55                   	push   %ebp
  80114b:	89 e5                	mov    %esp,%ebp
  80114d:	83 ec 08             	sub    $0x8,%esp
  801150:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801153:	ba 4c 2b 80 00       	mov    $0x802b4c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801158:	eb 13                	jmp    80116d <dev_lookup+0x23>
  80115a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80115d:	39 08                	cmp    %ecx,(%eax)
  80115f:	75 0c                	jne    80116d <dev_lookup+0x23>
			*dev = devtab[i];
  801161:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801164:	89 01                	mov    %eax,(%ecx)
			return 0;
  801166:	b8 00 00 00 00       	mov    $0x0,%eax
  80116b:	eb 2e                	jmp    80119b <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80116d:	8b 02                	mov    (%edx),%eax
  80116f:	85 c0                	test   %eax,%eax
  801171:	75 e7                	jne    80115a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801173:	a1 08 40 80 00       	mov    0x804008,%eax
  801178:	8b 40 48             	mov    0x48(%eax),%eax
  80117b:	83 ec 04             	sub    $0x4,%esp
  80117e:	51                   	push   %ecx
  80117f:	50                   	push   %eax
  801180:	68 d0 2a 80 00       	push   $0x802ad0
  801185:	e8 1e f0 ff ff       	call   8001a8 <cprintf>
	*dev = 0;
  80118a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80118d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801193:	83 c4 10             	add    $0x10,%esp
  801196:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80119b:	c9                   	leave  
  80119c:	c3                   	ret    

0080119d <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	56                   	push   %esi
  8011a1:	53                   	push   %ebx
  8011a2:	83 ec 10             	sub    $0x10,%esp
  8011a5:	8b 75 08             	mov    0x8(%ebp),%esi
  8011a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8011ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011ae:	50                   	push   %eax
  8011af:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8011b5:	c1 e8 0c             	shr    $0xc,%eax
  8011b8:	50                   	push   %eax
  8011b9:	e8 36 ff ff ff       	call   8010f4 <fd_lookup>
  8011be:	83 c4 08             	add    $0x8,%esp
  8011c1:	85 c0                	test   %eax,%eax
  8011c3:	78 05                	js     8011ca <fd_close+0x2d>
	    || fd != fd2)
  8011c5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8011c8:	74 0c                	je     8011d6 <fd_close+0x39>
		return (must_exist ? r : 0);
  8011ca:	84 db                	test   %bl,%bl
  8011cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8011d1:	0f 44 c2             	cmove  %edx,%eax
  8011d4:	eb 41                	jmp    801217 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011d6:	83 ec 08             	sub    $0x8,%esp
  8011d9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011dc:	50                   	push   %eax
  8011dd:	ff 36                	pushl  (%esi)
  8011df:	e8 66 ff ff ff       	call   80114a <dev_lookup>
  8011e4:	89 c3                	mov    %eax,%ebx
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	85 c0                	test   %eax,%eax
  8011eb:	78 1a                	js     801207 <fd_close+0x6a>
		if (dev->dev_close)
  8011ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f0:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8011f3:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8011f8:	85 c0                	test   %eax,%eax
  8011fa:	74 0b                	je     801207 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8011fc:	83 ec 0c             	sub    $0xc,%esp
  8011ff:	56                   	push   %esi
  801200:	ff d0                	call   *%eax
  801202:	89 c3                	mov    %eax,%ebx
  801204:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801207:	83 ec 08             	sub    $0x8,%esp
  80120a:	56                   	push   %esi
  80120b:	6a 00                	push   $0x0
  80120d:	e8 22 fa ff ff       	call   800c34 <sys_page_unmap>
	return r;
  801212:	83 c4 10             	add    $0x10,%esp
  801215:	89 d8                	mov    %ebx,%eax
}
  801217:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80121a:	5b                   	pop    %ebx
  80121b:	5e                   	pop    %esi
  80121c:	5d                   	pop    %ebp
  80121d:	c3                   	ret    

0080121e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80121e:	55                   	push   %ebp
  80121f:	89 e5                	mov    %esp,%ebp
  801221:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801224:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801227:	50                   	push   %eax
  801228:	ff 75 08             	pushl  0x8(%ebp)
  80122b:	e8 c4 fe ff ff       	call   8010f4 <fd_lookup>
  801230:	83 c4 08             	add    $0x8,%esp
  801233:	85 c0                	test   %eax,%eax
  801235:	78 10                	js     801247 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801237:	83 ec 08             	sub    $0x8,%esp
  80123a:	6a 01                	push   $0x1
  80123c:	ff 75 f4             	pushl  -0xc(%ebp)
  80123f:	e8 59 ff ff ff       	call   80119d <fd_close>
  801244:	83 c4 10             	add    $0x10,%esp
}
  801247:	c9                   	leave  
  801248:	c3                   	ret    

00801249 <close_all>:

void
close_all(void)
{
  801249:	55                   	push   %ebp
  80124a:	89 e5                	mov    %esp,%ebp
  80124c:	53                   	push   %ebx
  80124d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801250:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801255:	83 ec 0c             	sub    $0xc,%esp
  801258:	53                   	push   %ebx
  801259:	e8 c0 ff ff ff       	call   80121e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80125e:	83 c3 01             	add    $0x1,%ebx
  801261:	83 c4 10             	add    $0x10,%esp
  801264:	83 fb 20             	cmp    $0x20,%ebx
  801267:	75 ec                	jne    801255 <close_all+0xc>
		close(i);
}
  801269:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    

0080126e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	57                   	push   %edi
  801272:	56                   	push   %esi
  801273:	53                   	push   %ebx
  801274:	83 ec 2c             	sub    $0x2c,%esp
  801277:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80127a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80127d:	50                   	push   %eax
  80127e:	ff 75 08             	pushl  0x8(%ebp)
  801281:	e8 6e fe ff ff       	call   8010f4 <fd_lookup>
  801286:	83 c4 08             	add    $0x8,%esp
  801289:	85 c0                	test   %eax,%eax
  80128b:	0f 88 c1 00 00 00    	js     801352 <dup+0xe4>
		return r;
	close(newfdnum);
  801291:	83 ec 0c             	sub    $0xc,%esp
  801294:	56                   	push   %esi
  801295:	e8 84 ff ff ff       	call   80121e <close>

	newfd = INDEX2FD(newfdnum);
  80129a:	89 f3                	mov    %esi,%ebx
  80129c:	c1 e3 0c             	shl    $0xc,%ebx
  80129f:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8012a5:	83 c4 04             	add    $0x4,%esp
  8012a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012ab:	e8 de fd ff ff       	call   80108e <fd2data>
  8012b0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8012b2:	89 1c 24             	mov    %ebx,(%esp)
  8012b5:	e8 d4 fd ff ff       	call   80108e <fd2data>
  8012ba:	83 c4 10             	add    $0x10,%esp
  8012bd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012c0:	89 f8                	mov    %edi,%eax
  8012c2:	c1 e8 16             	shr    $0x16,%eax
  8012c5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012cc:	a8 01                	test   $0x1,%al
  8012ce:	74 37                	je     801307 <dup+0x99>
  8012d0:	89 f8                	mov    %edi,%eax
  8012d2:	c1 e8 0c             	shr    $0xc,%eax
  8012d5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012dc:	f6 c2 01             	test   $0x1,%dl
  8012df:	74 26                	je     801307 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012e1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e8:	83 ec 0c             	sub    $0xc,%esp
  8012eb:	25 07 0e 00 00       	and    $0xe07,%eax
  8012f0:	50                   	push   %eax
  8012f1:	ff 75 d4             	pushl  -0x2c(%ebp)
  8012f4:	6a 00                	push   $0x0
  8012f6:	57                   	push   %edi
  8012f7:	6a 00                	push   $0x0
  8012f9:	e8 f4 f8 ff ff       	call   800bf2 <sys_page_map>
  8012fe:	89 c7                	mov    %eax,%edi
  801300:	83 c4 20             	add    $0x20,%esp
  801303:	85 c0                	test   %eax,%eax
  801305:	78 2e                	js     801335 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801307:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80130a:	89 d0                	mov    %edx,%eax
  80130c:	c1 e8 0c             	shr    $0xc,%eax
  80130f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801316:	83 ec 0c             	sub    $0xc,%esp
  801319:	25 07 0e 00 00       	and    $0xe07,%eax
  80131e:	50                   	push   %eax
  80131f:	53                   	push   %ebx
  801320:	6a 00                	push   $0x0
  801322:	52                   	push   %edx
  801323:	6a 00                	push   $0x0
  801325:	e8 c8 f8 ff ff       	call   800bf2 <sys_page_map>
  80132a:	89 c7                	mov    %eax,%edi
  80132c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80132f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801331:	85 ff                	test   %edi,%edi
  801333:	79 1d                	jns    801352 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801335:	83 ec 08             	sub    $0x8,%esp
  801338:	53                   	push   %ebx
  801339:	6a 00                	push   $0x0
  80133b:	e8 f4 f8 ff ff       	call   800c34 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801340:	83 c4 08             	add    $0x8,%esp
  801343:	ff 75 d4             	pushl  -0x2c(%ebp)
  801346:	6a 00                	push   $0x0
  801348:	e8 e7 f8 ff ff       	call   800c34 <sys_page_unmap>
	return r;
  80134d:	83 c4 10             	add    $0x10,%esp
  801350:	89 f8                	mov    %edi,%eax
}
  801352:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801355:	5b                   	pop    %ebx
  801356:	5e                   	pop    %esi
  801357:	5f                   	pop    %edi
  801358:	5d                   	pop    %ebp
  801359:	c3                   	ret    

0080135a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80135a:	55                   	push   %ebp
  80135b:	89 e5                	mov    %esp,%ebp
  80135d:	53                   	push   %ebx
  80135e:	83 ec 14             	sub    $0x14,%esp
  801361:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801364:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801367:	50                   	push   %eax
  801368:	53                   	push   %ebx
  801369:	e8 86 fd ff ff       	call   8010f4 <fd_lookup>
  80136e:	83 c4 08             	add    $0x8,%esp
  801371:	89 c2                	mov    %eax,%edx
  801373:	85 c0                	test   %eax,%eax
  801375:	78 6d                	js     8013e4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801377:	83 ec 08             	sub    $0x8,%esp
  80137a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80137d:	50                   	push   %eax
  80137e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801381:	ff 30                	pushl  (%eax)
  801383:	e8 c2 fd ff ff       	call   80114a <dev_lookup>
  801388:	83 c4 10             	add    $0x10,%esp
  80138b:	85 c0                	test   %eax,%eax
  80138d:	78 4c                	js     8013db <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80138f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801392:	8b 42 08             	mov    0x8(%edx),%eax
  801395:	83 e0 03             	and    $0x3,%eax
  801398:	83 f8 01             	cmp    $0x1,%eax
  80139b:	75 21                	jne    8013be <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80139d:	a1 08 40 80 00       	mov    0x804008,%eax
  8013a2:	8b 40 48             	mov    0x48(%eax),%eax
  8013a5:	83 ec 04             	sub    $0x4,%esp
  8013a8:	53                   	push   %ebx
  8013a9:	50                   	push   %eax
  8013aa:	68 11 2b 80 00       	push   $0x802b11
  8013af:	e8 f4 ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  8013b4:	83 c4 10             	add    $0x10,%esp
  8013b7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8013bc:	eb 26                	jmp    8013e4 <read+0x8a>
	}
	if (!dev->dev_read)
  8013be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8013c1:	8b 40 08             	mov    0x8(%eax),%eax
  8013c4:	85 c0                	test   %eax,%eax
  8013c6:	74 17                	je     8013df <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8013c8:	83 ec 04             	sub    $0x4,%esp
  8013cb:	ff 75 10             	pushl  0x10(%ebp)
  8013ce:	ff 75 0c             	pushl  0xc(%ebp)
  8013d1:	52                   	push   %edx
  8013d2:	ff d0                	call   *%eax
  8013d4:	89 c2                	mov    %eax,%edx
  8013d6:	83 c4 10             	add    $0x10,%esp
  8013d9:	eb 09                	jmp    8013e4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013db:	89 c2                	mov    %eax,%edx
  8013dd:	eb 05                	jmp    8013e4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8013df:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8013e4:	89 d0                	mov    %edx,%eax
  8013e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013e9:	c9                   	leave  
  8013ea:	c3                   	ret    

008013eb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013eb:	55                   	push   %ebp
  8013ec:	89 e5                	mov    %esp,%ebp
  8013ee:	57                   	push   %edi
  8013ef:	56                   	push   %esi
  8013f0:	53                   	push   %ebx
  8013f1:	83 ec 0c             	sub    $0xc,%esp
  8013f4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013f7:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013fa:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013ff:	eb 21                	jmp    801422 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801401:	83 ec 04             	sub    $0x4,%esp
  801404:	89 f0                	mov    %esi,%eax
  801406:	29 d8                	sub    %ebx,%eax
  801408:	50                   	push   %eax
  801409:	89 d8                	mov    %ebx,%eax
  80140b:	03 45 0c             	add    0xc(%ebp),%eax
  80140e:	50                   	push   %eax
  80140f:	57                   	push   %edi
  801410:	e8 45 ff ff ff       	call   80135a <read>
		if (m < 0)
  801415:	83 c4 10             	add    $0x10,%esp
  801418:	85 c0                	test   %eax,%eax
  80141a:	78 10                	js     80142c <readn+0x41>
			return m;
		if (m == 0)
  80141c:	85 c0                	test   %eax,%eax
  80141e:	74 0a                	je     80142a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801420:	01 c3                	add    %eax,%ebx
  801422:	39 f3                	cmp    %esi,%ebx
  801424:	72 db                	jb     801401 <readn+0x16>
  801426:	89 d8                	mov    %ebx,%eax
  801428:	eb 02                	jmp    80142c <readn+0x41>
  80142a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80142c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80142f:	5b                   	pop    %ebx
  801430:	5e                   	pop    %esi
  801431:	5f                   	pop    %edi
  801432:	5d                   	pop    %ebp
  801433:	c3                   	ret    

00801434 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801434:	55                   	push   %ebp
  801435:	89 e5                	mov    %esp,%ebp
  801437:	53                   	push   %ebx
  801438:	83 ec 14             	sub    $0x14,%esp
  80143b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80143e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801441:	50                   	push   %eax
  801442:	53                   	push   %ebx
  801443:	e8 ac fc ff ff       	call   8010f4 <fd_lookup>
  801448:	83 c4 08             	add    $0x8,%esp
  80144b:	89 c2                	mov    %eax,%edx
  80144d:	85 c0                	test   %eax,%eax
  80144f:	78 68                	js     8014b9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801451:	83 ec 08             	sub    $0x8,%esp
  801454:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801457:	50                   	push   %eax
  801458:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145b:	ff 30                	pushl  (%eax)
  80145d:	e8 e8 fc ff ff       	call   80114a <dev_lookup>
  801462:	83 c4 10             	add    $0x10,%esp
  801465:	85 c0                	test   %eax,%eax
  801467:	78 47                	js     8014b0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801469:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80146c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801470:	75 21                	jne    801493 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801472:	a1 08 40 80 00       	mov    0x804008,%eax
  801477:	8b 40 48             	mov    0x48(%eax),%eax
  80147a:	83 ec 04             	sub    $0x4,%esp
  80147d:	53                   	push   %ebx
  80147e:	50                   	push   %eax
  80147f:	68 2d 2b 80 00       	push   $0x802b2d
  801484:	e8 1f ed ff ff       	call   8001a8 <cprintf>
		return -E_INVAL;
  801489:	83 c4 10             	add    $0x10,%esp
  80148c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801491:	eb 26                	jmp    8014b9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801493:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801496:	8b 52 0c             	mov    0xc(%edx),%edx
  801499:	85 d2                	test   %edx,%edx
  80149b:	74 17                	je     8014b4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80149d:	83 ec 04             	sub    $0x4,%esp
  8014a0:	ff 75 10             	pushl  0x10(%ebp)
  8014a3:	ff 75 0c             	pushl  0xc(%ebp)
  8014a6:	50                   	push   %eax
  8014a7:	ff d2                	call   *%edx
  8014a9:	89 c2                	mov    %eax,%edx
  8014ab:	83 c4 10             	add    $0x10,%esp
  8014ae:	eb 09                	jmp    8014b9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014b0:	89 c2                	mov    %eax,%edx
  8014b2:	eb 05                	jmp    8014b9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8014b4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8014b9:	89 d0                	mov    %edx,%eax
  8014bb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014be:	c9                   	leave  
  8014bf:	c3                   	ret    

008014c0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8014c0:	55                   	push   %ebp
  8014c1:	89 e5                	mov    %esp,%ebp
  8014c3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014c6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8014c9:	50                   	push   %eax
  8014ca:	ff 75 08             	pushl  0x8(%ebp)
  8014cd:	e8 22 fc ff ff       	call   8010f4 <fd_lookup>
  8014d2:	83 c4 08             	add    $0x8,%esp
  8014d5:	85 c0                	test   %eax,%eax
  8014d7:	78 0e                	js     8014e7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8014d9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8014dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014df:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014e2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014e7:	c9                   	leave  
  8014e8:	c3                   	ret    

008014e9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014e9:	55                   	push   %ebp
  8014ea:	89 e5                	mov    %esp,%ebp
  8014ec:	53                   	push   %ebx
  8014ed:	83 ec 14             	sub    $0x14,%esp
  8014f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014f6:	50                   	push   %eax
  8014f7:	53                   	push   %ebx
  8014f8:	e8 f7 fb ff ff       	call   8010f4 <fd_lookup>
  8014fd:	83 c4 08             	add    $0x8,%esp
  801500:	89 c2                	mov    %eax,%edx
  801502:	85 c0                	test   %eax,%eax
  801504:	78 65                	js     80156b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801506:	83 ec 08             	sub    $0x8,%esp
  801509:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80150c:	50                   	push   %eax
  80150d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801510:	ff 30                	pushl  (%eax)
  801512:	e8 33 fc ff ff       	call   80114a <dev_lookup>
  801517:	83 c4 10             	add    $0x10,%esp
  80151a:	85 c0                	test   %eax,%eax
  80151c:	78 44                	js     801562 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80151e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801521:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801525:	75 21                	jne    801548 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801527:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80152c:	8b 40 48             	mov    0x48(%eax),%eax
  80152f:	83 ec 04             	sub    $0x4,%esp
  801532:	53                   	push   %ebx
  801533:	50                   	push   %eax
  801534:	68 f0 2a 80 00       	push   $0x802af0
  801539:	e8 6a ec ff ff       	call   8001a8 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80153e:	83 c4 10             	add    $0x10,%esp
  801541:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801546:	eb 23                	jmp    80156b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801548:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80154b:	8b 52 18             	mov    0x18(%edx),%edx
  80154e:	85 d2                	test   %edx,%edx
  801550:	74 14                	je     801566 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801552:	83 ec 08             	sub    $0x8,%esp
  801555:	ff 75 0c             	pushl  0xc(%ebp)
  801558:	50                   	push   %eax
  801559:	ff d2                	call   *%edx
  80155b:	89 c2                	mov    %eax,%edx
  80155d:	83 c4 10             	add    $0x10,%esp
  801560:	eb 09                	jmp    80156b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801562:	89 c2                	mov    %eax,%edx
  801564:	eb 05                	jmp    80156b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801566:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80156b:	89 d0                	mov    %edx,%eax
  80156d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801570:	c9                   	leave  
  801571:	c3                   	ret    

00801572 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801572:	55                   	push   %ebp
  801573:	89 e5                	mov    %esp,%ebp
  801575:	53                   	push   %ebx
  801576:	83 ec 14             	sub    $0x14,%esp
  801579:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80157c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80157f:	50                   	push   %eax
  801580:	ff 75 08             	pushl  0x8(%ebp)
  801583:	e8 6c fb ff ff       	call   8010f4 <fd_lookup>
  801588:	83 c4 08             	add    $0x8,%esp
  80158b:	89 c2                	mov    %eax,%edx
  80158d:	85 c0                	test   %eax,%eax
  80158f:	78 58                	js     8015e9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801591:	83 ec 08             	sub    $0x8,%esp
  801594:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801597:	50                   	push   %eax
  801598:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80159b:	ff 30                	pushl  (%eax)
  80159d:	e8 a8 fb ff ff       	call   80114a <dev_lookup>
  8015a2:	83 c4 10             	add    $0x10,%esp
  8015a5:	85 c0                	test   %eax,%eax
  8015a7:	78 37                	js     8015e0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8015a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015ac:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8015b0:	74 32                	je     8015e4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8015b2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8015b5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015bc:	00 00 00 
	stat->st_isdir = 0;
  8015bf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015c6:	00 00 00 
	stat->st_dev = dev;
  8015c9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015cf:	83 ec 08             	sub    $0x8,%esp
  8015d2:	53                   	push   %ebx
  8015d3:	ff 75 f0             	pushl  -0x10(%ebp)
  8015d6:	ff 50 14             	call   *0x14(%eax)
  8015d9:	89 c2                	mov    %eax,%edx
  8015db:	83 c4 10             	add    $0x10,%esp
  8015de:	eb 09                	jmp    8015e9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015e0:	89 c2                	mov    %eax,%edx
  8015e2:	eb 05                	jmp    8015e9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8015e4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8015e9:	89 d0                	mov    %edx,%eax
  8015eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ee:	c9                   	leave  
  8015ef:	c3                   	ret    

008015f0 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015f0:	55                   	push   %ebp
  8015f1:	89 e5                	mov    %esp,%ebp
  8015f3:	56                   	push   %esi
  8015f4:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015f5:	83 ec 08             	sub    $0x8,%esp
  8015f8:	6a 00                	push   $0x0
  8015fa:	ff 75 08             	pushl  0x8(%ebp)
  8015fd:	e8 e3 01 00 00       	call   8017e5 <open>
  801602:	89 c3                	mov    %eax,%ebx
  801604:	83 c4 10             	add    $0x10,%esp
  801607:	85 c0                	test   %eax,%eax
  801609:	78 1b                	js     801626 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80160b:	83 ec 08             	sub    $0x8,%esp
  80160e:	ff 75 0c             	pushl  0xc(%ebp)
  801611:	50                   	push   %eax
  801612:	e8 5b ff ff ff       	call   801572 <fstat>
  801617:	89 c6                	mov    %eax,%esi
	close(fd);
  801619:	89 1c 24             	mov    %ebx,(%esp)
  80161c:	e8 fd fb ff ff       	call   80121e <close>
	return r;
  801621:	83 c4 10             	add    $0x10,%esp
  801624:	89 f0                	mov    %esi,%eax
}
  801626:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801629:	5b                   	pop    %ebx
  80162a:	5e                   	pop    %esi
  80162b:	5d                   	pop    %ebp
  80162c:	c3                   	ret    

0080162d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80162d:	55                   	push   %ebp
  80162e:	89 e5                	mov    %esp,%ebp
  801630:	56                   	push   %esi
  801631:	53                   	push   %ebx
  801632:	89 c6                	mov    %eax,%esi
  801634:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801636:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80163d:	75 12                	jne    801651 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80163f:	83 ec 0c             	sub    $0xc,%esp
  801642:	6a 01                	push   $0x1
  801644:	e8 10 0d 00 00       	call   802359 <ipc_find_env>
  801649:	a3 00 40 80 00       	mov    %eax,0x804000
  80164e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801651:	6a 07                	push   $0x7
  801653:	68 00 50 80 00       	push   $0x805000
  801658:	56                   	push   %esi
  801659:	ff 35 00 40 80 00    	pushl  0x804000
  80165f:	e8 a1 0c 00 00       	call   802305 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801664:	83 c4 0c             	add    $0xc,%esp
  801667:	6a 00                	push   $0x0
  801669:	53                   	push   %ebx
  80166a:	6a 00                	push   $0x0
  80166c:	e8 2b 0c 00 00       	call   80229c <ipc_recv>
}
  801671:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801674:	5b                   	pop    %ebx
  801675:	5e                   	pop    %esi
  801676:	5d                   	pop    %ebp
  801677:	c3                   	ret    

00801678 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801678:	55                   	push   %ebp
  801679:	89 e5                	mov    %esp,%ebp
  80167b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80167e:	8b 45 08             	mov    0x8(%ebp),%eax
  801681:	8b 40 0c             	mov    0xc(%eax),%eax
  801684:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801689:	8b 45 0c             	mov    0xc(%ebp),%eax
  80168c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801691:	ba 00 00 00 00       	mov    $0x0,%edx
  801696:	b8 02 00 00 00       	mov    $0x2,%eax
  80169b:	e8 8d ff ff ff       	call   80162d <fsipc>
}
  8016a0:	c9                   	leave  
  8016a1:	c3                   	ret    

008016a2 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8016a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ae:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8016b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8016b8:	b8 06 00 00 00       	mov    $0x6,%eax
  8016bd:	e8 6b ff ff ff       	call   80162d <fsipc>
}
  8016c2:	c9                   	leave  
  8016c3:	c3                   	ret    

008016c4 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	53                   	push   %ebx
  8016c8:	83 ec 04             	sub    $0x4,%esp
  8016cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8016d1:	8b 40 0c             	mov    0xc(%eax),%eax
  8016d4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8016de:	b8 05 00 00 00       	mov    $0x5,%eax
  8016e3:	e8 45 ff ff ff       	call   80162d <fsipc>
  8016e8:	85 c0                	test   %eax,%eax
  8016ea:	78 2c                	js     801718 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016ec:	83 ec 08             	sub    $0x8,%esp
  8016ef:	68 00 50 80 00       	push   $0x805000
  8016f4:	53                   	push   %ebx
  8016f5:	e8 b2 f0 ff ff       	call   8007ac <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016fa:	a1 80 50 80 00       	mov    0x805080,%eax
  8016ff:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801705:	a1 84 50 80 00       	mov    0x805084,%eax
  80170a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801710:	83 c4 10             	add    $0x10,%esp
  801713:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801718:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171b:	c9                   	leave  
  80171c:	c3                   	ret    

0080171d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	83 ec 0c             	sub    $0xc,%esp
  801723:	8b 45 10             	mov    0x10(%ebp),%eax
  801726:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80172b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801730:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801733:	8b 55 08             	mov    0x8(%ebp),%edx
  801736:	8b 52 0c             	mov    0xc(%edx),%edx
  801739:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  80173f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801744:	50                   	push   %eax
  801745:	ff 75 0c             	pushl  0xc(%ebp)
  801748:	68 08 50 80 00       	push   $0x805008
  80174d:	e8 ec f1 ff ff       	call   80093e <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801752:	ba 00 00 00 00       	mov    $0x0,%edx
  801757:	b8 04 00 00 00       	mov    $0x4,%eax
  80175c:	e8 cc fe ff ff       	call   80162d <fsipc>
	//panic("devfile_write not implemented");
}
  801761:	c9                   	leave  
  801762:	c3                   	ret    

00801763 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801763:	55                   	push   %ebp
  801764:	89 e5                	mov    %esp,%ebp
  801766:	56                   	push   %esi
  801767:	53                   	push   %ebx
  801768:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80176b:	8b 45 08             	mov    0x8(%ebp),%eax
  80176e:	8b 40 0c             	mov    0xc(%eax),%eax
  801771:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801776:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80177c:	ba 00 00 00 00       	mov    $0x0,%edx
  801781:	b8 03 00 00 00       	mov    $0x3,%eax
  801786:	e8 a2 fe ff ff       	call   80162d <fsipc>
  80178b:	89 c3                	mov    %eax,%ebx
  80178d:	85 c0                	test   %eax,%eax
  80178f:	78 4b                	js     8017dc <devfile_read+0x79>
		return r;
	assert(r <= n);
  801791:	39 c6                	cmp    %eax,%esi
  801793:	73 16                	jae    8017ab <devfile_read+0x48>
  801795:	68 60 2b 80 00       	push   $0x802b60
  80179a:	68 67 2b 80 00       	push   $0x802b67
  80179f:	6a 7c                	push   $0x7c
  8017a1:	68 7c 2b 80 00       	push   $0x802b7c
  8017a6:	e8 24 0a 00 00       	call   8021cf <_panic>
	assert(r <= PGSIZE);
  8017ab:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8017b0:	7e 16                	jle    8017c8 <devfile_read+0x65>
  8017b2:	68 87 2b 80 00       	push   $0x802b87
  8017b7:	68 67 2b 80 00       	push   $0x802b67
  8017bc:	6a 7d                	push   $0x7d
  8017be:	68 7c 2b 80 00       	push   $0x802b7c
  8017c3:	e8 07 0a 00 00       	call   8021cf <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8017c8:	83 ec 04             	sub    $0x4,%esp
  8017cb:	50                   	push   %eax
  8017cc:	68 00 50 80 00       	push   $0x805000
  8017d1:	ff 75 0c             	pushl  0xc(%ebp)
  8017d4:	e8 65 f1 ff ff       	call   80093e <memmove>
	return r;
  8017d9:	83 c4 10             	add    $0x10,%esp
}
  8017dc:	89 d8                	mov    %ebx,%eax
  8017de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017e1:	5b                   	pop    %ebx
  8017e2:	5e                   	pop    %esi
  8017e3:	5d                   	pop    %ebp
  8017e4:	c3                   	ret    

008017e5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8017e5:	55                   	push   %ebp
  8017e6:	89 e5                	mov    %esp,%ebp
  8017e8:	53                   	push   %ebx
  8017e9:	83 ec 20             	sub    $0x20,%esp
  8017ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8017ef:	53                   	push   %ebx
  8017f0:	e8 7e ef ff ff       	call   800773 <strlen>
  8017f5:	83 c4 10             	add    $0x10,%esp
  8017f8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017fd:	7f 67                	jg     801866 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  8017ff:	83 ec 0c             	sub    $0xc,%esp
  801802:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801805:	50                   	push   %eax
  801806:	e8 9a f8 ff ff       	call   8010a5 <fd_alloc>
  80180b:	83 c4 10             	add    $0x10,%esp
		return r;
  80180e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801810:	85 c0                	test   %eax,%eax
  801812:	78 57                	js     80186b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801814:	83 ec 08             	sub    $0x8,%esp
  801817:	53                   	push   %ebx
  801818:	68 00 50 80 00       	push   $0x805000
  80181d:	e8 8a ef ff ff       	call   8007ac <strcpy>
	fsipcbuf.open.req_omode = mode;
  801822:	8b 45 0c             	mov    0xc(%ebp),%eax
  801825:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80182a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80182d:	b8 01 00 00 00       	mov    $0x1,%eax
  801832:	e8 f6 fd ff ff       	call   80162d <fsipc>
  801837:	89 c3                	mov    %eax,%ebx
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	85 c0                	test   %eax,%eax
  80183e:	79 14                	jns    801854 <open+0x6f>
		fd_close(fd, 0);
  801840:	83 ec 08             	sub    $0x8,%esp
  801843:	6a 00                	push   $0x0
  801845:	ff 75 f4             	pushl  -0xc(%ebp)
  801848:	e8 50 f9 ff ff       	call   80119d <fd_close>
		return r;
  80184d:	83 c4 10             	add    $0x10,%esp
  801850:	89 da                	mov    %ebx,%edx
  801852:	eb 17                	jmp    80186b <open+0x86>
	}

	return fd2num(fd);
  801854:	83 ec 0c             	sub    $0xc,%esp
  801857:	ff 75 f4             	pushl  -0xc(%ebp)
  80185a:	e8 1f f8 ff ff       	call   80107e <fd2num>
  80185f:	89 c2                	mov    %eax,%edx
  801861:	83 c4 10             	add    $0x10,%esp
  801864:	eb 05                	jmp    80186b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801866:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  80186b:	89 d0                	mov    %edx,%eax
  80186d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801870:	c9                   	leave  
  801871:	c3                   	ret    

00801872 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801872:	55                   	push   %ebp
  801873:	89 e5                	mov    %esp,%ebp
  801875:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801878:	ba 00 00 00 00       	mov    $0x0,%edx
  80187d:	b8 08 00 00 00       	mov    $0x8,%eax
  801882:	e8 a6 fd ff ff       	call   80162d <fsipc>
}
  801887:	c9                   	leave  
  801888:	c3                   	ret    

00801889 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801889:	55                   	push   %ebp
  80188a:	89 e5                	mov    %esp,%ebp
  80188c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  80188f:	68 93 2b 80 00       	push   $0x802b93
  801894:	ff 75 0c             	pushl  0xc(%ebp)
  801897:	e8 10 ef ff ff       	call   8007ac <strcpy>
	return 0;
}
  80189c:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a1:	c9                   	leave  
  8018a2:	c3                   	ret    

008018a3 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  8018a3:	55                   	push   %ebp
  8018a4:	89 e5                	mov    %esp,%ebp
  8018a6:	53                   	push   %ebx
  8018a7:	83 ec 10             	sub    $0x10,%esp
  8018aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  8018ad:	53                   	push   %ebx
  8018ae:	e8 df 0a 00 00       	call   802392 <pageref>
  8018b3:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  8018b6:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  8018bb:	83 f8 01             	cmp    $0x1,%eax
  8018be:	75 10                	jne    8018d0 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  8018c0:	83 ec 0c             	sub    $0xc,%esp
  8018c3:	ff 73 0c             	pushl  0xc(%ebx)
  8018c6:	e8 c0 02 00 00       	call   801b8b <nsipc_close>
  8018cb:	89 c2                	mov    %eax,%edx
  8018cd:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  8018d0:	89 d0                	mov    %edx,%eax
  8018d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d5:	c9                   	leave  
  8018d6:	c3                   	ret    

008018d7 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  8018d7:	55                   	push   %ebp
  8018d8:	89 e5                	mov    %esp,%ebp
  8018da:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  8018dd:	6a 00                	push   $0x0
  8018df:	ff 75 10             	pushl  0x10(%ebp)
  8018e2:	ff 75 0c             	pushl  0xc(%ebp)
  8018e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e8:	ff 70 0c             	pushl  0xc(%eax)
  8018eb:	e8 78 03 00 00       	call   801c68 <nsipc_send>
}
  8018f0:	c9                   	leave  
  8018f1:	c3                   	ret    

008018f2 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  8018f2:	55                   	push   %ebp
  8018f3:	89 e5                	mov    %esp,%ebp
  8018f5:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  8018f8:	6a 00                	push   $0x0
  8018fa:	ff 75 10             	pushl  0x10(%ebp)
  8018fd:	ff 75 0c             	pushl  0xc(%ebp)
  801900:	8b 45 08             	mov    0x8(%ebp),%eax
  801903:	ff 70 0c             	pushl  0xc(%eax)
  801906:	e8 f1 02 00 00       	call   801bfc <nsipc_recv>
}
  80190b:	c9                   	leave  
  80190c:	c3                   	ret    

0080190d <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  80190d:	55                   	push   %ebp
  80190e:	89 e5                	mov    %esp,%ebp
  801910:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801913:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801916:	52                   	push   %edx
  801917:	50                   	push   %eax
  801918:	e8 d7 f7 ff ff       	call   8010f4 <fd_lookup>
  80191d:	83 c4 10             	add    $0x10,%esp
  801920:	85 c0                	test   %eax,%eax
  801922:	78 17                	js     80193b <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801924:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801927:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  80192d:	39 08                	cmp    %ecx,(%eax)
  80192f:	75 05                	jne    801936 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801931:	8b 40 0c             	mov    0xc(%eax),%eax
  801934:	eb 05                	jmp    80193b <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801936:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  80193b:	c9                   	leave  
  80193c:	c3                   	ret    

0080193d <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	56                   	push   %esi
  801941:	53                   	push   %ebx
  801942:	83 ec 1c             	sub    $0x1c,%esp
  801945:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801947:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194a:	50                   	push   %eax
  80194b:	e8 55 f7 ff ff       	call   8010a5 <fd_alloc>
  801950:	89 c3                	mov    %eax,%ebx
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	85 c0                	test   %eax,%eax
  801957:	78 1b                	js     801974 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801959:	83 ec 04             	sub    $0x4,%esp
  80195c:	68 07 04 00 00       	push   $0x407
  801961:	ff 75 f4             	pushl  -0xc(%ebp)
  801964:	6a 00                	push   $0x0
  801966:	e8 44 f2 ff ff       	call   800baf <sys_page_alloc>
  80196b:	89 c3                	mov    %eax,%ebx
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	85 c0                	test   %eax,%eax
  801972:	79 10                	jns    801984 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801974:	83 ec 0c             	sub    $0xc,%esp
  801977:	56                   	push   %esi
  801978:	e8 0e 02 00 00       	call   801b8b <nsipc_close>
		return r;
  80197d:	83 c4 10             	add    $0x10,%esp
  801980:	89 d8                	mov    %ebx,%eax
  801982:	eb 24                	jmp    8019a8 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801984:	8b 15 20 30 80 00    	mov    0x803020,%edx
  80198a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80198d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  80198f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801992:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801999:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  80199c:	83 ec 0c             	sub    $0xc,%esp
  80199f:	50                   	push   %eax
  8019a0:	e8 d9 f6 ff ff       	call   80107e <fd2num>
  8019a5:	83 c4 10             	add    $0x10,%esp
}
  8019a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ab:	5b                   	pop    %ebx
  8019ac:	5e                   	pop    %esi
  8019ad:	5d                   	pop    %ebp
  8019ae:	c3                   	ret    

008019af <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8019b8:	e8 50 ff ff ff       	call   80190d <fd2sockid>
		return r;
  8019bd:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019bf:	85 c0                	test   %eax,%eax
  8019c1:	78 1f                	js     8019e2 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019c3:	83 ec 04             	sub    $0x4,%esp
  8019c6:	ff 75 10             	pushl  0x10(%ebp)
  8019c9:	ff 75 0c             	pushl  0xc(%ebp)
  8019cc:	50                   	push   %eax
  8019cd:	e8 12 01 00 00       	call   801ae4 <nsipc_accept>
  8019d2:	83 c4 10             	add    $0x10,%esp
		return r;
  8019d5:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  8019d7:	85 c0                	test   %eax,%eax
  8019d9:	78 07                	js     8019e2 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  8019db:	e8 5d ff ff ff       	call   80193d <alloc_sockfd>
  8019e0:	89 c1                	mov    %eax,%ecx
}
  8019e2:	89 c8                	mov    %ecx,%eax
  8019e4:	c9                   	leave  
  8019e5:	c3                   	ret    

008019e6 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  8019ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ef:	e8 19 ff ff ff       	call   80190d <fd2sockid>
  8019f4:	85 c0                	test   %eax,%eax
  8019f6:	78 12                	js     801a0a <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  8019f8:	83 ec 04             	sub    $0x4,%esp
  8019fb:	ff 75 10             	pushl  0x10(%ebp)
  8019fe:	ff 75 0c             	pushl  0xc(%ebp)
  801a01:	50                   	push   %eax
  801a02:	e8 2d 01 00 00       	call   801b34 <nsipc_bind>
  801a07:	83 c4 10             	add    $0x10,%esp
}
  801a0a:	c9                   	leave  
  801a0b:	c3                   	ret    

00801a0c <shutdown>:

int
shutdown(int s, int how)
{
  801a0c:	55                   	push   %ebp
  801a0d:	89 e5                	mov    %esp,%ebp
  801a0f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a12:	8b 45 08             	mov    0x8(%ebp),%eax
  801a15:	e8 f3 fe ff ff       	call   80190d <fd2sockid>
  801a1a:	85 c0                	test   %eax,%eax
  801a1c:	78 0f                	js     801a2d <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801a1e:	83 ec 08             	sub    $0x8,%esp
  801a21:	ff 75 0c             	pushl  0xc(%ebp)
  801a24:	50                   	push   %eax
  801a25:	e8 3f 01 00 00       	call   801b69 <nsipc_shutdown>
  801a2a:	83 c4 10             	add    $0x10,%esp
}
  801a2d:	c9                   	leave  
  801a2e:	c3                   	ret    

00801a2f <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a35:	8b 45 08             	mov    0x8(%ebp),%eax
  801a38:	e8 d0 fe ff ff       	call   80190d <fd2sockid>
  801a3d:	85 c0                	test   %eax,%eax
  801a3f:	78 12                	js     801a53 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801a41:	83 ec 04             	sub    $0x4,%esp
  801a44:	ff 75 10             	pushl  0x10(%ebp)
  801a47:	ff 75 0c             	pushl  0xc(%ebp)
  801a4a:	50                   	push   %eax
  801a4b:	e8 55 01 00 00       	call   801ba5 <nsipc_connect>
  801a50:	83 c4 10             	add    $0x10,%esp
}
  801a53:	c9                   	leave  
  801a54:	c3                   	ret    

00801a55 <listen>:

int
listen(int s, int backlog)
{
  801a55:	55                   	push   %ebp
  801a56:	89 e5                	mov    %esp,%ebp
  801a58:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801a5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5e:	e8 aa fe ff ff       	call   80190d <fd2sockid>
  801a63:	85 c0                	test   %eax,%eax
  801a65:	78 0f                	js     801a76 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801a67:	83 ec 08             	sub    $0x8,%esp
  801a6a:	ff 75 0c             	pushl  0xc(%ebp)
  801a6d:	50                   	push   %eax
  801a6e:	e8 67 01 00 00       	call   801bda <nsipc_listen>
  801a73:	83 c4 10             	add    $0x10,%esp
}
  801a76:	c9                   	leave  
  801a77:	c3                   	ret    

00801a78 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801a78:	55                   	push   %ebp
  801a79:	89 e5                	mov    %esp,%ebp
  801a7b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801a7e:	ff 75 10             	pushl  0x10(%ebp)
  801a81:	ff 75 0c             	pushl  0xc(%ebp)
  801a84:	ff 75 08             	pushl  0x8(%ebp)
  801a87:	e8 3a 02 00 00       	call   801cc6 <nsipc_socket>
  801a8c:	83 c4 10             	add    $0x10,%esp
  801a8f:	85 c0                	test   %eax,%eax
  801a91:	78 05                	js     801a98 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801a93:	e8 a5 fe ff ff       	call   80193d <alloc_sockfd>
}
  801a98:	c9                   	leave  
  801a99:	c3                   	ret    

00801a9a <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801a9a:	55                   	push   %ebp
  801a9b:	89 e5                	mov    %esp,%ebp
  801a9d:	53                   	push   %ebx
  801a9e:	83 ec 04             	sub    $0x4,%esp
  801aa1:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801aa3:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801aaa:	75 12                	jne    801abe <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801aac:	83 ec 0c             	sub    $0xc,%esp
  801aaf:	6a 02                	push   $0x2
  801ab1:	e8 a3 08 00 00       	call   802359 <ipc_find_env>
  801ab6:	a3 04 40 80 00       	mov    %eax,0x804004
  801abb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801abe:	6a 07                	push   $0x7
  801ac0:	68 00 60 80 00       	push   $0x806000
  801ac5:	53                   	push   %ebx
  801ac6:	ff 35 04 40 80 00    	pushl  0x804004
  801acc:	e8 34 08 00 00       	call   802305 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ad1:	83 c4 0c             	add    $0xc,%esp
  801ad4:	6a 00                	push   $0x0
  801ad6:	6a 00                	push   $0x0
  801ad8:	6a 00                	push   $0x0
  801ada:	e8 bd 07 00 00       	call   80229c <ipc_recv>
}
  801adf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ae2:	c9                   	leave  
  801ae3:	c3                   	ret    

00801ae4 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	56                   	push   %esi
  801ae8:	53                   	push   %ebx
  801ae9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801aec:	8b 45 08             	mov    0x8(%ebp),%eax
  801aef:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801af4:	8b 06                	mov    (%esi),%eax
  801af6:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801afb:	b8 01 00 00 00       	mov    $0x1,%eax
  801b00:	e8 95 ff ff ff       	call   801a9a <nsipc>
  801b05:	89 c3                	mov    %eax,%ebx
  801b07:	85 c0                	test   %eax,%eax
  801b09:	78 20                	js     801b2b <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801b0b:	83 ec 04             	sub    $0x4,%esp
  801b0e:	ff 35 10 60 80 00    	pushl  0x806010
  801b14:	68 00 60 80 00       	push   $0x806000
  801b19:	ff 75 0c             	pushl  0xc(%ebp)
  801b1c:	e8 1d ee ff ff       	call   80093e <memmove>
		*addrlen = ret->ret_addrlen;
  801b21:	a1 10 60 80 00       	mov    0x806010,%eax
  801b26:	89 06                	mov    %eax,(%esi)
  801b28:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801b2b:	89 d8                	mov    %ebx,%eax
  801b2d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b30:	5b                   	pop    %ebx
  801b31:	5e                   	pop    %esi
  801b32:	5d                   	pop    %ebp
  801b33:	c3                   	ret    

00801b34 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801b34:	55                   	push   %ebp
  801b35:	89 e5                	mov    %esp,%ebp
  801b37:	53                   	push   %ebx
  801b38:	83 ec 08             	sub    $0x8,%esp
  801b3b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801b3e:	8b 45 08             	mov    0x8(%ebp),%eax
  801b41:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801b46:	53                   	push   %ebx
  801b47:	ff 75 0c             	pushl  0xc(%ebp)
  801b4a:	68 04 60 80 00       	push   $0x806004
  801b4f:	e8 ea ed ff ff       	call   80093e <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801b54:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801b5a:	b8 02 00 00 00       	mov    $0x2,%eax
  801b5f:	e8 36 ff ff ff       	call   801a9a <nsipc>
}
  801b64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b67:	c9                   	leave  
  801b68:	c3                   	ret    

00801b69 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801b69:	55                   	push   %ebp
  801b6a:	89 e5                	mov    %esp,%ebp
  801b6c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801b6f:	8b 45 08             	mov    0x8(%ebp),%eax
  801b72:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801b77:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b7a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801b7f:	b8 03 00 00 00       	mov    $0x3,%eax
  801b84:	e8 11 ff ff ff       	call   801a9a <nsipc>
}
  801b89:	c9                   	leave  
  801b8a:	c3                   	ret    

00801b8b <nsipc_close>:

int
nsipc_close(int s)
{
  801b8b:	55                   	push   %ebp
  801b8c:	89 e5                	mov    %esp,%ebp
  801b8e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801b91:	8b 45 08             	mov    0x8(%ebp),%eax
  801b94:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801b99:	b8 04 00 00 00       	mov    $0x4,%eax
  801b9e:	e8 f7 fe ff ff       	call   801a9a <nsipc>
}
  801ba3:	c9                   	leave  
  801ba4:	c3                   	ret    

00801ba5 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801ba5:	55                   	push   %ebp
  801ba6:	89 e5                	mov    %esp,%ebp
  801ba8:	53                   	push   %ebx
  801ba9:	83 ec 08             	sub    $0x8,%esp
  801bac:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801baf:	8b 45 08             	mov    0x8(%ebp),%eax
  801bb2:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801bb7:	53                   	push   %ebx
  801bb8:	ff 75 0c             	pushl  0xc(%ebp)
  801bbb:	68 04 60 80 00       	push   $0x806004
  801bc0:	e8 79 ed ff ff       	call   80093e <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801bc5:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801bcb:	b8 05 00 00 00       	mov    $0x5,%eax
  801bd0:	e8 c5 fe ff ff       	call   801a9a <nsipc>
}
  801bd5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801bd8:	c9                   	leave  
  801bd9:	c3                   	ret    

00801bda <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801bda:	55                   	push   %ebp
  801bdb:	89 e5                	mov    %esp,%ebp
  801bdd:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801be0:	8b 45 08             	mov    0x8(%ebp),%eax
  801be3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801be8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801beb:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801bf0:	b8 06 00 00 00       	mov    $0x6,%eax
  801bf5:	e8 a0 fe ff ff       	call   801a9a <nsipc>
}
  801bfa:	c9                   	leave  
  801bfb:	c3                   	ret    

00801bfc <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801bfc:	55                   	push   %ebp
  801bfd:	89 e5                	mov    %esp,%ebp
  801bff:	56                   	push   %esi
  801c00:	53                   	push   %ebx
  801c01:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801c04:	8b 45 08             	mov    0x8(%ebp),%eax
  801c07:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801c0c:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801c12:	8b 45 14             	mov    0x14(%ebp),%eax
  801c15:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801c1a:	b8 07 00 00 00       	mov    $0x7,%eax
  801c1f:	e8 76 fe ff ff       	call   801a9a <nsipc>
  801c24:	89 c3                	mov    %eax,%ebx
  801c26:	85 c0                	test   %eax,%eax
  801c28:	78 35                	js     801c5f <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801c2a:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801c2f:	7f 04                	jg     801c35 <nsipc_recv+0x39>
  801c31:	39 c6                	cmp    %eax,%esi
  801c33:	7d 16                	jge    801c4b <nsipc_recv+0x4f>
  801c35:	68 9f 2b 80 00       	push   $0x802b9f
  801c3a:	68 67 2b 80 00       	push   $0x802b67
  801c3f:	6a 62                	push   $0x62
  801c41:	68 b4 2b 80 00       	push   $0x802bb4
  801c46:	e8 84 05 00 00       	call   8021cf <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801c4b:	83 ec 04             	sub    $0x4,%esp
  801c4e:	50                   	push   %eax
  801c4f:	68 00 60 80 00       	push   $0x806000
  801c54:	ff 75 0c             	pushl  0xc(%ebp)
  801c57:	e8 e2 ec ff ff       	call   80093e <memmove>
  801c5c:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801c5f:	89 d8                	mov    %ebx,%eax
  801c61:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c64:	5b                   	pop    %ebx
  801c65:	5e                   	pop    %esi
  801c66:	5d                   	pop    %ebp
  801c67:	c3                   	ret    

00801c68 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801c68:	55                   	push   %ebp
  801c69:	89 e5                	mov    %esp,%ebp
  801c6b:	53                   	push   %ebx
  801c6c:	83 ec 04             	sub    $0x4,%esp
  801c6f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801c72:	8b 45 08             	mov    0x8(%ebp),%eax
  801c75:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801c7a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801c80:	7e 16                	jle    801c98 <nsipc_send+0x30>
  801c82:	68 c0 2b 80 00       	push   $0x802bc0
  801c87:	68 67 2b 80 00       	push   $0x802b67
  801c8c:	6a 6d                	push   $0x6d
  801c8e:	68 b4 2b 80 00       	push   $0x802bb4
  801c93:	e8 37 05 00 00       	call   8021cf <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801c98:	83 ec 04             	sub    $0x4,%esp
  801c9b:	53                   	push   %ebx
  801c9c:	ff 75 0c             	pushl  0xc(%ebp)
  801c9f:	68 0c 60 80 00       	push   $0x80600c
  801ca4:	e8 95 ec ff ff       	call   80093e <memmove>
	nsipcbuf.send.req_size = size;
  801ca9:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801caf:	8b 45 14             	mov    0x14(%ebp),%eax
  801cb2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801cb7:	b8 08 00 00 00       	mov    $0x8,%eax
  801cbc:	e8 d9 fd ff ff       	call   801a9a <nsipc>
}
  801cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cc4:	c9                   	leave  
  801cc5:	c3                   	ret    

00801cc6 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801cc6:	55                   	push   %ebp
  801cc7:	89 e5                	mov    %esp,%ebp
  801cc9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801cd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cd7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801cdc:	8b 45 10             	mov    0x10(%ebp),%eax
  801cdf:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ce4:	b8 09 00 00 00       	mov    $0x9,%eax
  801ce9:	e8 ac fd ff ff       	call   801a9a <nsipc>
}
  801cee:	c9                   	leave  
  801cef:	c3                   	ret    

00801cf0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801cf0:	55                   	push   %ebp
  801cf1:	89 e5                	mov    %esp,%ebp
  801cf3:	56                   	push   %esi
  801cf4:	53                   	push   %ebx
  801cf5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cf8:	83 ec 0c             	sub    $0xc,%esp
  801cfb:	ff 75 08             	pushl  0x8(%ebp)
  801cfe:	e8 8b f3 ff ff       	call   80108e <fd2data>
  801d03:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d05:	83 c4 08             	add    $0x8,%esp
  801d08:	68 cc 2b 80 00       	push   $0x802bcc
  801d0d:	53                   	push   %ebx
  801d0e:	e8 99 ea ff ff       	call   8007ac <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d13:	8b 46 04             	mov    0x4(%esi),%eax
  801d16:	2b 06                	sub    (%esi),%eax
  801d18:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d1e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d25:	00 00 00 
	stat->st_dev = &devpipe;
  801d28:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801d2f:	30 80 00 
	return 0;
}
  801d32:	b8 00 00 00 00       	mov    $0x0,%eax
  801d37:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d3a:	5b                   	pop    %ebx
  801d3b:	5e                   	pop    %esi
  801d3c:	5d                   	pop    %ebp
  801d3d:	c3                   	ret    

00801d3e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	53                   	push   %ebx
  801d42:	83 ec 0c             	sub    $0xc,%esp
  801d45:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d48:	53                   	push   %ebx
  801d49:	6a 00                	push   $0x0
  801d4b:	e8 e4 ee ff ff       	call   800c34 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d50:	89 1c 24             	mov    %ebx,(%esp)
  801d53:	e8 36 f3 ff ff       	call   80108e <fd2data>
  801d58:	83 c4 08             	add    $0x8,%esp
  801d5b:	50                   	push   %eax
  801d5c:	6a 00                	push   $0x0
  801d5e:	e8 d1 ee ff ff       	call   800c34 <sys_page_unmap>
}
  801d63:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d66:	c9                   	leave  
  801d67:	c3                   	ret    

00801d68 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801d68:	55                   	push   %ebp
  801d69:	89 e5                	mov    %esp,%ebp
  801d6b:	57                   	push   %edi
  801d6c:	56                   	push   %esi
  801d6d:	53                   	push   %ebx
  801d6e:	83 ec 1c             	sub    $0x1c,%esp
  801d71:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801d74:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801d76:	a1 08 40 80 00       	mov    0x804008,%eax
  801d7b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801d7e:	83 ec 0c             	sub    $0xc,%esp
  801d81:	ff 75 e0             	pushl  -0x20(%ebp)
  801d84:	e8 09 06 00 00       	call   802392 <pageref>
  801d89:	89 c3                	mov    %eax,%ebx
  801d8b:	89 3c 24             	mov    %edi,(%esp)
  801d8e:	e8 ff 05 00 00       	call   802392 <pageref>
  801d93:	83 c4 10             	add    $0x10,%esp
  801d96:	39 c3                	cmp    %eax,%ebx
  801d98:	0f 94 c1             	sete   %cl
  801d9b:	0f b6 c9             	movzbl %cl,%ecx
  801d9e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801da1:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801da7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801daa:	39 ce                	cmp    %ecx,%esi
  801dac:	74 1b                	je     801dc9 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801dae:	39 c3                	cmp    %eax,%ebx
  801db0:	75 c4                	jne    801d76 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801db2:	8b 42 58             	mov    0x58(%edx),%eax
  801db5:	ff 75 e4             	pushl  -0x1c(%ebp)
  801db8:	50                   	push   %eax
  801db9:	56                   	push   %esi
  801dba:	68 d3 2b 80 00       	push   $0x802bd3
  801dbf:	e8 e4 e3 ff ff       	call   8001a8 <cprintf>
  801dc4:	83 c4 10             	add    $0x10,%esp
  801dc7:	eb ad                	jmp    801d76 <_pipeisclosed+0xe>
	}
}
  801dc9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801dcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dcf:	5b                   	pop    %ebx
  801dd0:	5e                   	pop    %esi
  801dd1:	5f                   	pop    %edi
  801dd2:	5d                   	pop    %ebp
  801dd3:	c3                   	ret    

00801dd4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801dd4:	55                   	push   %ebp
  801dd5:	89 e5                	mov    %esp,%ebp
  801dd7:	57                   	push   %edi
  801dd8:	56                   	push   %esi
  801dd9:	53                   	push   %ebx
  801dda:	83 ec 28             	sub    $0x28,%esp
  801ddd:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801de0:	56                   	push   %esi
  801de1:	e8 a8 f2 ff ff       	call   80108e <fd2data>
  801de6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801de8:	83 c4 10             	add    $0x10,%esp
  801deb:	bf 00 00 00 00       	mov    $0x0,%edi
  801df0:	eb 4b                	jmp    801e3d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801df2:	89 da                	mov    %ebx,%edx
  801df4:	89 f0                	mov    %esi,%eax
  801df6:	e8 6d ff ff ff       	call   801d68 <_pipeisclosed>
  801dfb:	85 c0                	test   %eax,%eax
  801dfd:	75 48                	jne    801e47 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801dff:	e8 8c ed ff ff       	call   800b90 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801e04:	8b 43 04             	mov    0x4(%ebx),%eax
  801e07:	8b 0b                	mov    (%ebx),%ecx
  801e09:	8d 51 20             	lea    0x20(%ecx),%edx
  801e0c:	39 d0                	cmp    %edx,%eax
  801e0e:	73 e2                	jae    801df2 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e10:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e13:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e17:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e1a:	89 c2                	mov    %eax,%edx
  801e1c:	c1 fa 1f             	sar    $0x1f,%edx
  801e1f:	89 d1                	mov    %edx,%ecx
  801e21:	c1 e9 1b             	shr    $0x1b,%ecx
  801e24:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e27:	83 e2 1f             	and    $0x1f,%edx
  801e2a:	29 ca                	sub    %ecx,%edx
  801e2c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e30:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e34:	83 c0 01             	add    $0x1,%eax
  801e37:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e3a:	83 c7 01             	add    $0x1,%edi
  801e3d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801e40:	75 c2                	jne    801e04 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801e42:	8b 45 10             	mov    0x10(%ebp),%eax
  801e45:	eb 05                	jmp    801e4c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801e47:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801e4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e4f:	5b                   	pop    %ebx
  801e50:	5e                   	pop    %esi
  801e51:	5f                   	pop    %edi
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    

00801e54 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801e54:	55                   	push   %ebp
  801e55:	89 e5                	mov    %esp,%ebp
  801e57:	57                   	push   %edi
  801e58:	56                   	push   %esi
  801e59:	53                   	push   %ebx
  801e5a:	83 ec 18             	sub    $0x18,%esp
  801e5d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801e60:	57                   	push   %edi
  801e61:	e8 28 f2 ff ff       	call   80108e <fd2data>
  801e66:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801e68:	83 c4 10             	add    $0x10,%esp
  801e6b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e70:	eb 3d                	jmp    801eaf <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801e72:	85 db                	test   %ebx,%ebx
  801e74:	74 04                	je     801e7a <devpipe_read+0x26>
				return i;
  801e76:	89 d8                	mov    %ebx,%eax
  801e78:	eb 44                	jmp    801ebe <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801e7a:	89 f2                	mov    %esi,%edx
  801e7c:	89 f8                	mov    %edi,%eax
  801e7e:	e8 e5 fe ff ff       	call   801d68 <_pipeisclosed>
  801e83:	85 c0                	test   %eax,%eax
  801e85:	75 32                	jne    801eb9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801e87:	e8 04 ed ff ff       	call   800b90 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801e8c:	8b 06                	mov    (%esi),%eax
  801e8e:	3b 46 04             	cmp    0x4(%esi),%eax
  801e91:	74 df                	je     801e72 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e93:	99                   	cltd   
  801e94:	c1 ea 1b             	shr    $0x1b,%edx
  801e97:	01 d0                	add    %edx,%eax
  801e99:	83 e0 1f             	and    $0x1f,%eax
  801e9c:	29 d0                	sub    %edx,%eax
  801e9e:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801ea3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ea6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801ea9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801eac:	83 c3 01             	add    $0x1,%ebx
  801eaf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801eb2:	75 d8                	jne    801e8c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801eb4:	8b 45 10             	mov    0x10(%ebp),%eax
  801eb7:	eb 05                	jmp    801ebe <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801eb9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801ebe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ec1:	5b                   	pop    %ebx
  801ec2:	5e                   	pop    %esi
  801ec3:	5f                   	pop    %edi
  801ec4:	5d                   	pop    %ebp
  801ec5:	c3                   	ret    

00801ec6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801ec6:	55                   	push   %ebp
  801ec7:	89 e5                	mov    %esp,%ebp
  801ec9:	56                   	push   %esi
  801eca:	53                   	push   %ebx
  801ecb:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801ece:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed1:	50                   	push   %eax
  801ed2:	e8 ce f1 ff ff       	call   8010a5 <fd_alloc>
  801ed7:	83 c4 10             	add    $0x10,%esp
  801eda:	89 c2                	mov    %eax,%edx
  801edc:	85 c0                	test   %eax,%eax
  801ede:	0f 88 2c 01 00 00    	js     802010 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ee4:	83 ec 04             	sub    $0x4,%esp
  801ee7:	68 07 04 00 00       	push   $0x407
  801eec:	ff 75 f4             	pushl  -0xc(%ebp)
  801eef:	6a 00                	push   $0x0
  801ef1:	e8 b9 ec ff ff       	call   800baf <sys_page_alloc>
  801ef6:	83 c4 10             	add    $0x10,%esp
  801ef9:	89 c2                	mov    %eax,%edx
  801efb:	85 c0                	test   %eax,%eax
  801efd:	0f 88 0d 01 00 00    	js     802010 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801f03:	83 ec 0c             	sub    $0xc,%esp
  801f06:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f09:	50                   	push   %eax
  801f0a:	e8 96 f1 ff ff       	call   8010a5 <fd_alloc>
  801f0f:	89 c3                	mov    %eax,%ebx
  801f11:	83 c4 10             	add    $0x10,%esp
  801f14:	85 c0                	test   %eax,%eax
  801f16:	0f 88 e2 00 00 00    	js     801ffe <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f1c:	83 ec 04             	sub    $0x4,%esp
  801f1f:	68 07 04 00 00       	push   $0x407
  801f24:	ff 75 f0             	pushl  -0x10(%ebp)
  801f27:	6a 00                	push   $0x0
  801f29:	e8 81 ec ff ff       	call   800baf <sys_page_alloc>
  801f2e:	89 c3                	mov    %eax,%ebx
  801f30:	83 c4 10             	add    $0x10,%esp
  801f33:	85 c0                	test   %eax,%eax
  801f35:	0f 88 c3 00 00 00    	js     801ffe <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801f3b:	83 ec 0c             	sub    $0xc,%esp
  801f3e:	ff 75 f4             	pushl  -0xc(%ebp)
  801f41:	e8 48 f1 ff ff       	call   80108e <fd2data>
  801f46:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f48:	83 c4 0c             	add    $0xc,%esp
  801f4b:	68 07 04 00 00       	push   $0x407
  801f50:	50                   	push   %eax
  801f51:	6a 00                	push   $0x0
  801f53:	e8 57 ec ff ff       	call   800baf <sys_page_alloc>
  801f58:	89 c3                	mov    %eax,%ebx
  801f5a:	83 c4 10             	add    $0x10,%esp
  801f5d:	85 c0                	test   %eax,%eax
  801f5f:	0f 88 89 00 00 00    	js     801fee <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f65:	83 ec 0c             	sub    $0xc,%esp
  801f68:	ff 75 f0             	pushl  -0x10(%ebp)
  801f6b:	e8 1e f1 ff ff       	call   80108e <fd2data>
  801f70:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f77:	50                   	push   %eax
  801f78:	6a 00                	push   $0x0
  801f7a:	56                   	push   %esi
  801f7b:	6a 00                	push   $0x0
  801f7d:	e8 70 ec ff ff       	call   800bf2 <sys_page_map>
  801f82:	89 c3                	mov    %eax,%ebx
  801f84:	83 c4 20             	add    $0x20,%esp
  801f87:	85 c0                	test   %eax,%eax
  801f89:	78 55                	js     801fe0 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801f8b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f91:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f94:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801f96:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f99:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801fa0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fa6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fa9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801fab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801fae:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801fb5:	83 ec 0c             	sub    $0xc,%esp
  801fb8:	ff 75 f4             	pushl  -0xc(%ebp)
  801fbb:	e8 be f0 ff ff       	call   80107e <fd2num>
  801fc0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fc3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fc5:	83 c4 04             	add    $0x4,%esp
  801fc8:	ff 75 f0             	pushl  -0x10(%ebp)
  801fcb:	e8 ae f0 ff ff       	call   80107e <fd2num>
  801fd0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fd3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801fd6:	83 c4 10             	add    $0x10,%esp
  801fd9:	ba 00 00 00 00       	mov    $0x0,%edx
  801fde:	eb 30                	jmp    802010 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801fe0:	83 ec 08             	sub    $0x8,%esp
  801fe3:	56                   	push   %esi
  801fe4:	6a 00                	push   $0x0
  801fe6:	e8 49 ec ff ff       	call   800c34 <sys_page_unmap>
  801feb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801fee:	83 ec 08             	sub    $0x8,%esp
  801ff1:	ff 75 f0             	pushl  -0x10(%ebp)
  801ff4:	6a 00                	push   $0x0
  801ff6:	e8 39 ec ff ff       	call   800c34 <sys_page_unmap>
  801ffb:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801ffe:	83 ec 08             	sub    $0x8,%esp
  802001:	ff 75 f4             	pushl  -0xc(%ebp)
  802004:	6a 00                	push   $0x0
  802006:	e8 29 ec ff ff       	call   800c34 <sys_page_unmap>
  80200b:	83 c4 10             	add    $0x10,%esp
  80200e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802010:	89 d0                	mov    %edx,%eax
  802012:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802015:	5b                   	pop    %ebx
  802016:	5e                   	pop    %esi
  802017:	5d                   	pop    %ebp
  802018:	c3                   	ret    

00802019 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802019:	55                   	push   %ebp
  80201a:	89 e5                	mov    %esp,%ebp
  80201c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80201f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802022:	50                   	push   %eax
  802023:	ff 75 08             	pushl  0x8(%ebp)
  802026:	e8 c9 f0 ff ff       	call   8010f4 <fd_lookup>
  80202b:	83 c4 10             	add    $0x10,%esp
  80202e:	85 c0                	test   %eax,%eax
  802030:	78 18                	js     80204a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802032:	83 ec 0c             	sub    $0xc,%esp
  802035:	ff 75 f4             	pushl  -0xc(%ebp)
  802038:	e8 51 f0 ff ff       	call   80108e <fd2data>
	return _pipeisclosed(fd, p);
  80203d:	89 c2                	mov    %eax,%edx
  80203f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802042:	e8 21 fd ff ff       	call   801d68 <_pipeisclosed>
  802047:	83 c4 10             	add    $0x10,%esp
}
  80204a:	c9                   	leave  
  80204b:	c3                   	ret    

0080204c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80204c:	55                   	push   %ebp
  80204d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80204f:	b8 00 00 00 00       	mov    $0x0,%eax
  802054:	5d                   	pop    %ebp
  802055:	c3                   	ret    

00802056 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802056:	55                   	push   %ebp
  802057:	89 e5                	mov    %esp,%ebp
  802059:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80205c:	68 eb 2b 80 00       	push   $0x802beb
  802061:	ff 75 0c             	pushl  0xc(%ebp)
  802064:	e8 43 e7 ff ff       	call   8007ac <strcpy>
	return 0;
}
  802069:	b8 00 00 00 00       	mov    $0x0,%eax
  80206e:	c9                   	leave  
  80206f:	c3                   	ret    

00802070 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802070:	55                   	push   %ebp
  802071:	89 e5                	mov    %esp,%ebp
  802073:	57                   	push   %edi
  802074:	56                   	push   %esi
  802075:	53                   	push   %ebx
  802076:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80207c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802081:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802087:	eb 2d                	jmp    8020b6 <devcons_write+0x46>
		m = n - tot;
  802089:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80208c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80208e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  802091:	ba 7f 00 00 00       	mov    $0x7f,%edx
  802096:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802099:	83 ec 04             	sub    $0x4,%esp
  80209c:	53                   	push   %ebx
  80209d:	03 45 0c             	add    0xc(%ebp),%eax
  8020a0:	50                   	push   %eax
  8020a1:	57                   	push   %edi
  8020a2:	e8 97 e8 ff ff       	call   80093e <memmove>
		sys_cputs(buf, m);
  8020a7:	83 c4 08             	add    $0x8,%esp
  8020aa:	53                   	push   %ebx
  8020ab:	57                   	push   %edi
  8020ac:	e8 42 ea ff ff       	call   800af3 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8020b1:	01 de                	add    %ebx,%esi
  8020b3:	83 c4 10             	add    $0x10,%esp
  8020b6:	89 f0                	mov    %esi,%eax
  8020b8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020bb:	72 cc                	jb     802089 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8020bd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020c0:	5b                   	pop    %ebx
  8020c1:	5e                   	pop    %esi
  8020c2:	5f                   	pop    %edi
  8020c3:	5d                   	pop    %ebp
  8020c4:	c3                   	ret    

008020c5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8020c5:	55                   	push   %ebp
  8020c6:	89 e5                	mov    %esp,%ebp
  8020c8:	83 ec 08             	sub    $0x8,%esp
  8020cb:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8020d0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8020d4:	74 2a                	je     802100 <devcons_read+0x3b>
  8020d6:	eb 05                	jmp    8020dd <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8020d8:	e8 b3 ea ff ff       	call   800b90 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8020dd:	e8 2f ea ff ff       	call   800b11 <sys_cgetc>
  8020e2:	85 c0                	test   %eax,%eax
  8020e4:	74 f2                	je     8020d8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8020e6:	85 c0                	test   %eax,%eax
  8020e8:	78 16                	js     802100 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8020ea:	83 f8 04             	cmp    $0x4,%eax
  8020ed:	74 0c                	je     8020fb <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8020ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020f2:	88 02                	mov    %al,(%edx)
	return 1;
  8020f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8020f9:	eb 05                	jmp    802100 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  8020fb:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802100:	c9                   	leave  
  802101:	c3                   	ret    

00802102 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  802102:	55                   	push   %ebp
  802103:	89 e5                	mov    %esp,%ebp
  802105:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802108:	8b 45 08             	mov    0x8(%ebp),%eax
  80210b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80210e:	6a 01                	push   $0x1
  802110:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802113:	50                   	push   %eax
  802114:	e8 da e9 ff ff       	call   800af3 <sys_cputs>
}
  802119:	83 c4 10             	add    $0x10,%esp
  80211c:	c9                   	leave  
  80211d:	c3                   	ret    

0080211e <getchar>:

int
getchar(void)
{
  80211e:	55                   	push   %ebp
  80211f:	89 e5                	mov    %esp,%ebp
  802121:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802124:	6a 01                	push   $0x1
  802126:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802129:	50                   	push   %eax
  80212a:	6a 00                	push   $0x0
  80212c:	e8 29 f2 ff ff       	call   80135a <read>
	if (r < 0)
  802131:	83 c4 10             	add    $0x10,%esp
  802134:	85 c0                	test   %eax,%eax
  802136:	78 0f                	js     802147 <getchar+0x29>
		return r;
	if (r < 1)
  802138:	85 c0                	test   %eax,%eax
  80213a:	7e 06                	jle    802142 <getchar+0x24>
		return -E_EOF;
	return c;
  80213c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802140:	eb 05                	jmp    802147 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802142:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802147:	c9                   	leave  
  802148:	c3                   	ret    

00802149 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802149:	55                   	push   %ebp
  80214a:	89 e5                	mov    %esp,%ebp
  80214c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80214f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802152:	50                   	push   %eax
  802153:	ff 75 08             	pushl  0x8(%ebp)
  802156:	e8 99 ef ff ff       	call   8010f4 <fd_lookup>
  80215b:	83 c4 10             	add    $0x10,%esp
  80215e:	85 c0                	test   %eax,%eax
  802160:	78 11                	js     802173 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802162:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802165:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80216b:	39 10                	cmp    %edx,(%eax)
  80216d:	0f 94 c0             	sete   %al
  802170:	0f b6 c0             	movzbl %al,%eax
}
  802173:	c9                   	leave  
  802174:	c3                   	ret    

00802175 <opencons>:

int
opencons(void)
{
  802175:	55                   	push   %ebp
  802176:	89 e5                	mov    %esp,%ebp
  802178:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80217b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80217e:	50                   	push   %eax
  80217f:	e8 21 ef ff ff       	call   8010a5 <fd_alloc>
  802184:	83 c4 10             	add    $0x10,%esp
		return r;
  802187:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802189:	85 c0                	test   %eax,%eax
  80218b:	78 3e                	js     8021cb <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80218d:	83 ec 04             	sub    $0x4,%esp
  802190:	68 07 04 00 00       	push   $0x407
  802195:	ff 75 f4             	pushl  -0xc(%ebp)
  802198:	6a 00                	push   $0x0
  80219a:	e8 10 ea ff ff       	call   800baf <sys_page_alloc>
  80219f:	83 c4 10             	add    $0x10,%esp
		return r;
  8021a2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021a4:	85 c0                	test   %eax,%eax
  8021a6:	78 23                	js     8021cb <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8021a8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8021ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8021b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021b6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8021bd:	83 ec 0c             	sub    $0xc,%esp
  8021c0:	50                   	push   %eax
  8021c1:	e8 b8 ee ff ff       	call   80107e <fd2num>
  8021c6:	89 c2                	mov    %eax,%edx
  8021c8:	83 c4 10             	add    $0x10,%esp
}
  8021cb:	89 d0                	mov    %edx,%eax
  8021cd:	c9                   	leave  
  8021ce:	c3                   	ret    

008021cf <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8021cf:	55                   	push   %ebp
  8021d0:	89 e5                	mov    %esp,%ebp
  8021d2:	56                   	push   %esi
  8021d3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8021d4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8021d7:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8021dd:	e8 8f e9 ff ff       	call   800b71 <sys_getenvid>
  8021e2:	83 ec 0c             	sub    $0xc,%esp
  8021e5:	ff 75 0c             	pushl  0xc(%ebp)
  8021e8:	ff 75 08             	pushl  0x8(%ebp)
  8021eb:	56                   	push   %esi
  8021ec:	50                   	push   %eax
  8021ed:	68 f8 2b 80 00       	push   $0x802bf8
  8021f2:	e8 b1 df ff ff       	call   8001a8 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021f7:	83 c4 18             	add    $0x18,%esp
  8021fa:	53                   	push   %ebx
  8021fb:	ff 75 10             	pushl  0x10(%ebp)
  8021fe:	e8 54 df ff ff       	call   800157 <vcprintf>
	cprintf("\n");
  802203:	c7 04 24 f4 26 80 00 	movl   $0x8026f4,(%esp)
  80220a:	e8 99 df ff ff       	call   8001a8 <cprintf>
  80220f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802212:	cc                   	int3   
  802213:	eb fd                	jmp    802212 <_panic+0x43>

00802215 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80221b:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802222:	75 4a                	jne    80226e <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  802224:	a1 08 40 80 00       	mov    0x804008,%eax
  802229:	8b 40 48             	mov    0x48(%eax),%eax
  80222c:	83 ec 04             	sub    $0x4,%esp
  80222f:	6a 07                	push   $0x7
  802231:	68 00 f0 bf ee       	push   $0xeebff000
  802236:	50                   	push   %eax
  802237:	e8 73 e9 ff ff       	call   800baf <sys_page_alloc>
  80223c:	83 c4 10             	add    $0x10,%esp
  80223f:	85 c0                	test   %eax,%eax
  802241:	79 12                	jns    802255 <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  802243:	50                   	push   %eax
  802244:	68 1c 2c 80 00       	push   $0x802c1c
  802249:	6a 21                	push   $0x21
  80224b:	68 34 2c 80 00       	push   $0x802c34
  802250:	e8 7a ff ff ff       	call   8021cf <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  802255:	a1 08 40 80 00       	mov    0x804008,%eax
  80225a:	8b 40 48             	mov    0x48(%eax),%eax
  80225d:	83 ec 08             	sub    $0x8,%esp
  802260:	68 78 22 80 00       	push   $0x802278
  802265:	50                   	push   %eax
  802266:	e8 8f ea ff ff       	call   800cfa <sys_env_set_pgfault_upcall>
  80226b:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80226e:	8b 45 08             	mov    0x8(%ebp),%eax
  802271:	a3 00 70 80 00       	mov    %eax,0x807000
  802276:	c9                   	leave  
  802277:	c3                   	ret    

00802278 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802278:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802279:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  80227e:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802280:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  802283:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  802286:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  80228a:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  80228f:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  802293:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  802295:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  802296:	83 c4 04             	add    $0x4,%esp
	popfl
  802299:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80229a:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  80229b:	c3                   	ret    

0080229c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80229c:	55                   	push   %ebp
  80229d:	89 e5                	mov    %esp,%ebp
  80229f:	56                   	push   %esi
  8022a0:	53                   	push   %ebx
  8022a1:	8b 75 08             	mov    0x8(%ebp),%esi
  8022a4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022a7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  8022aa:	85 c0                	test   %eax,%eax
  8022ac:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8022b1:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  8022b4:	83 ec 0c             	sub    $0xc,%esp
  8022b7:	50                   	push   %eax
  8022b8:	e8 a2 ea ff ff       	call   800d5f <sys_ipc_recv>
  8022bd:	83 c4 10             	add    $0x10,%esp
  8022c0:	85 c0                	test   %eax,%eax
  8022c2:	79 16                	jns    8022da <ipc_recv+0x3e>
        if (from_env_store != NULL)
  8022c4:	85 f6                	test   %esi,%esi
  8022c6:	74 06                	je     8022ce <ipc_recv+0x32>
            *from_env_store = 0;
  8022c8:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  8022ce:	85 db                	test   %ebx,%ebx
  8022d0:	74 2c                	je     8022fe <ipc_recv+0x62>
            *perm_store = 0;
  8022d2:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8022d8:	eb 24                	jmp    8022fe <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  8022da:	85 f6                	test   %esi,%esi
  8022dc:	74 0a                	je     8022e8 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  8022de:	a1 08 40 80 00       	mov    0x804008,%eax
  8022e3:	8b 40 74             	mov    0x74(%eax),%eax
  8022e6:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  8022e8:	85 db                	test   %ebx,%ebx
  8022ea:	74 0a                	je     8022f6 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  8022ec:	a1 08 40 80 00       	mov    0x804008,%eax
  8022f1:	8b 40 78             	mov    0x78(%eax),%eax
  8022f4:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  8022f6:	a1 08 40 80 00       	mov    0x804008,%eax
  8022fb:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  8022fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802301:	5b                   	pop    %ebx
  802302:	5e                   	pop    %esi
  802303:	5d                   	pop    %ebp
  802304:	c3                   	ret    

00802305 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802305:	55                   	push   %ebp
  802306:	89 e5                	mov    %esp,%ebp
  802308:	57                   	push   %edi
  802309:	56                   	push   %esi
  80230a:	53                   	push   %ebx
  80230b:	83 ec 0c             	sub    $0xc,%esp
  80230e:	8b 7d 08             	mov    0x8(%ebp),%edi
  802311:	8b 75 0c             	mov    0xc(%ebp),%esi
  802314:	8b 45 10             	mov    0x10(%ebp),%eax
  802317:	85 c0                	test   %eax,%eax
  802319:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80231e:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802321:	eb 1c                	jmp    80233f <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  802323:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802326:	74 12                	je     80233a <ipc_send+0x35>
  802328:	50                   	push   %eax
  802329:	68 42 2c 80 00       	push   $0x802c42
  80232e:	6a 3b                	push   $0x3b
  802330:	68 58 2c 80 00       	push   $0x802c58
  802335:	e8 95 fe ff ff       	call   8021cf <_panic>
		sys_yield();
  80233a:	e8 51 e8 ff ff       	call   800b90 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80233f:	ff 75 14             	pushl  0x14(%ebp)
  802342:	53                   	push   %ebx
  802343:	56                   	push   %esi
  802344:	57                   	push   %edi
  802345:	e8 f2 e9 ff ff       	call   800d3c <sys_ipc_try_send>
  80234a:	83 c4 10             	add    $0x10,%esp
  80234d:	85 c0                	test   %eax,%eax
  80234f:	78 d2                	js     802323 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  802351:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802354:	5b                   	pop    %ebx
  802355:	5e                   	pop    %esi
  802356:	5f                   	pop    %edi
  802357:	5d                   	pop    %ebp
  802358:	c3                   	ret    

00802359 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802359:	55                   	push   %ebp
  80235a:	89 e5                	mov    %esp,%ebp
  80235c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80235f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802364:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802367:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80236d:	8b 52 50             	mov    0x50(%edx),%edx
  802370:	39 ca                	cmp    %ecx,%edx
  802372:	75 0d                	jne    802381 <ipc_find_env+0x28>
			return envs[i].env_id;
  802374:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802377:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80237c:	8b 40 48             	mov    0x48(%eax),%eax
  80237f:	eb 0f                	jmp    802390 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802381:	83 c0 01             	add    $0x1,%eax
  802384:	3d 00 04 00 00       	cmp    $0x400,%eax
  802389:	75 d9                	jne    802364 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  80238b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802390:	5d                   	pop    %ebp
  802391:	c3                   	ret    

00802392 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802392:	55                   	push   %ebp
  802393:	89 e5                	mov    %esp,%ebp
  802395:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802398:	89 d0                	mov    %edx,%eax
  80239a:	c1 e8 16             	shr    $0x16,%eax
  80239d:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8023a4:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023a9:	f6 c1 01             	test   $0x1,%cl
  8023ac:	74 1d                	je     8023cb <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8023ae:	c1 ea 0c             	shr    $0xc,%edx
  8023b1:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8023b8:	f6 c2 01             	test   $0x1,%dl
  8023bb:	74 0e                	je     8023cb <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023bd:	c1 ea 0c             	shr    $0xc,%edx
  8023c0:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  8023c7:	ef 
  8023c8:	0f b7 c0             	movzwl %ax,%eax
}
  8023cb:	5d                   	pop    %ebp
  8023cc:	c3                   	ret    
  8023cd:	66 90                	xchg   %ax,%ax
  8023cf:	90                   	nop

008023d0 <__udivdi3>:
  8023d0:	55                   	push   %ebp
  8023d1:	57                   	push   %edi
  8023d2:	56                   	push   %esi
  8023d3:	53                   	push   %ebx
  8023d4:	83 ec 1c             	sub    $0x1c,%esp
  8023d7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  8023db:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  8023df:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  8023e3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023e7:	85 f6                	test   %esi,%esi
  8023e9:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023ed:	89 ca                	mov    %ecx,%edx
  8023ef:	89 f8                	mov    %edi,%eax
  8023f1:	75 3d                	jne    802430 <__udivdi3+0x60>
  8023f3:	39 cf                	cmp    %ecx,%edi
  8023f5:	0f 87 c5 00 00 00    	ja     8024c0 <__udivdi3+0xf0>
  8023fb:	85 ff                	test   %edi,%edi
  8023fd:	89 fd                	mov    %edi,%ebp
  8023ff:	75 0b                	jne    80240c <__udivdi3+0x3c>
  802401:	b8 01 00 00 00       	mov    $0x1,%eax
  802406:	31 d2                	xor    %edx,%edx
  802408:	f7 f7                	div    %edi
  80240a:	89 c5                	mov    %eax,%ebp
  80240c:	89 c8                	mov    %ecx,%eax
  80240e:	31 d2                	xor    %edx,%edx
  802410:	f7 f5                	div    %ebp
  802412:	89 c1                	mov    %eax,%ecx
  802414:	89 d8                	mov    %ebx,%eax
  802416:	89 cf                	mov    %ecx,%edi
  802418:	f7 f5                	div    %ebp
  80241a:	89 c3                	mov    %eax,%ebx
  80241c:	89 d8                	mov    %ebx,%eax
  80241e:	89 fa                	mov    %edi,%edx
  802420:	83 c4 1c             	add    $0x1c,%esp
  802423:	5b                   	pop    %ebx
  802424:	5e                   	pop    %esi
  802425:	5f                   	pop    %edi
  802426:	5d                   	pop    %ebp
  802427:	c3                   	ret    
  802428:	90                   	nop
  802429:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802430:	39 ce                	cmp    %ecx,%esi
  802432:	77 74                	ja     8024a8 <__udivdi3+0xd8>
  802434:	0f bd fe             	bsr    %esi,%edi
  802437:	83 f7 1f             	xor    $0x1f,%edi
  80243a:	0f 84 98 00 00 00    	je     8024d8 <__udivdi3+0x108>
  802440:	bb 20 00 00 00       	mov    $0x20,%ebx
  802445:	89 f9                	mov    %edi,%ecx
  802447:	89 c5                	mov    %eax,%ebp
  802449:	29 fb                	sub    %edi,%ebx
  80244b:	d3 e6                	shl    %cl,%esi
  80244d:	89 d9                	mov    %ebx,%ecx
  80244f:	d3 ed                	shr    %cl,%ebp
  802451:	89 f9                	mov    %edi,%ecx
  802453:	d3 e0                	shl    %cl,%eax
  802455:	09 ee                	or     %ebp,%esi
  802457:	89 d9                	mov    %ebx,%ecx
  802459:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80245d:	89 d5                	mov    %edx,%ebp
  80245f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802463:	d3 ed                	shr    %cl,%ebp
  802465:	89 f9                	mov    %edi,%ecx
  802467:	d3 e2                	shl    %cl,%edx
  802469:	89 d9                	mov    %ebx,%ecx
  80246b:	d3 e8                	shr    %cl,%eax
  80246d:	09 c2                	or     %eax,%edx
  80246f:	89 d0                	mov    %edx,%eax
  802471:	89 ea                	mov    %ebp,%edx
  802473:	f7 f6                	div    %esi
  802475:	89 d5                	mov    %edx,%ebp
  802477:	89 c3                	mov    %eax,%ebx
  802479:	f7 64 24 0c          	mull   0xc(%esp)
  80247d:	39 d5                	cmp    %edx,%ebp
  80247f:	72 10                	jb     802491 <__udivdi3+0xc1>
  802481:	8b 74 24 08          	mov    0x8(%esp),%esi
  802485:	89 f9                	mov    %edi,%ecx
  802487:	d3 e6                	shl    %cl,%esi
  802489:	39 c6                	cmp    %eax,%esi
  80248b:	73 07                	jae    802494 <__udivdi3+0xc4>
  80248d:	39 d5                	cmp    %edx,%ebp
  80248f:	75 03                	jne    802494 <__udivdi3+0xc4>
  802491:	83 eb 01             	sub    $0x1,%ebx
  802494:	31 ff                	xor    %edi,%edi
  802496:	89 d8                	mov    %ebx,%eax
  802498:	89 fa                	mov    %edi,%edx
  80249a:	83 c4 1c             	add    $0x1c,%esp
  80249d:	5b                   	pop    %ebx
  80249e:	5e                   	pop    %esi
  80249f:	5f                   	pop    %edi
  8024a0:	5d                   	pop    %ebp
  8024a1:	c3                   	ret    
  8024a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8024a8:	31 ff                	xor    %edi,%edi
  8024aa:	31 db                	xor    %ebx,%ebx
  8024ac:	89 d8                	mov    %ebx,%eax
  8024ae:	89 fa                	mov    %edi,%edx
  8024b0:	83 c4 1c             	add    $0x1c,%esp
  8024b3:	5b                   	pop    %ebx
  8024b4:	5e                   	pop    %esi
  8024b5:	5f                   	pop    %edi
  8024b6:	5d                   	pop    %ebp
  8024b7:	c3                   	ret    
  8024b8:	90                   	nop
  8024b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024c0:	89 d8                	mov    %ebx,%eax
  8024c2:	f7 f7                	div    %edi
  8024c4:	31 ff                	xor    %edi,%edi
  8024c6:	89 c3                	mov    %eax,%ebx
  8024c8:	89 d8                	mov    %ebx,%eax
  8024ca:	89 fa                	mov    %edi,%edx
  8024cc:	83 c4 1c             	add    $0x1c,%esp
  8024cf:	5b                   	pop    %ebx
  8024d0:	5e                   	pop    %esi
  8024d1:	5f                   	pop    %edi
  8024d2:	5d                   	pop    %ebp
  8024d3:	c3                   	ret    
  8024d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8024d8:	39 ce                	cmp    %ecx,%esi
  8024da:	72 0c                	jb     8024e8 <__udivdi3+0x118>
  8024dc:	31 db                	xor    %ebx,%ebx
  8024de:	3b 44 24 08          	cmp    0x8(%esp),%eax
  8024e2:	0f 87 34 ff ff ff    	ja     80241c <__udivdi3+0x4c>
  8024e8:	bb 01 00 00 00       	mov    $0x1,%ebx
  8024ed:	e9 2a ff ff ff       	jmp    80241c <__udivdi3+0x4c>
  8024f2:	66 90                	xchg   %ax,%ax
  8024f4:	66 90                	xchg   %ax,%ax
  8024f6:	66 90                	xchg   %ax,%ax
  8024f8:	66 90                	xchg   %ax,%ax
  8024fa:	66 90                	xchg   %ax,%ax
  8024fc:	66 90                	xchg   %ax,%ax
  8024fe:	66 90                	xchg   %ax,%ax

00802500 <__umoddi3>:
  802500:	55                   	push   %ebp
  802501:	57                   	push   %edi
  802502:	56                   	push   %esi
  802503:	53                   	push   %ebx
  802504:	83 ec 1c             	sub    $0x1c,%esp
  802507:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80250b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80250f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802513:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802517:	85 d2                	test   %edx,%edx
  802519:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80251d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802521:	89 f3                	mov    %esi,%ebx
  802523:	89 3c 24             	mov    %edi,(%esp)
  802526:	89 74 24 04          	mov    %esi,0x4(%esp)
  80252a:	75 1c                	jne    802548 <__umoddi3+0x48>
  80252c:	39 f7                	cmp    %esi,%edi
  80252e:	76 50                	jbe    802580 <__umoddi3+0x80>
  802530:	89 c8                	mov    %ecx,%eax
  802532:	89 f2                	mov    %esi,%edx
  802534:	f7 f7                	div    %edi
  802536:	89 d0                	mov    %edx,%eax
  802538:	31 d2                	xor    %edx,%edx
  80253a:	83 c4 1c             	add    $0x1c,%esp
  80253d:	5b                   	pop    %ebx
  80253e:	5e                   	pop    %esi
  80253f:	5f                   	pop    %edi
  802540:	5d                   	pop    %ebp
  802541:	c3                   	ret    
  802542:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802548:	39 f2                	cmp    %esi,%edx
  80254a:	89 d0                	mov    %edx,%eax
  80254c:	77 52                	ja     8025a0 <__umoddi3+0xa0>
  80254e:	0f bd ea             	bsr    %edx,%ebp
  802551:	83 f5 1f             	xor    $0x1f,%ebp
  802554:	75 5a                	jne    8025b0 <__umoddi3+0xb0>
  802556:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80255a:	0f 82 e0 00 00 00    	jb     802640 <__umoddi3+0x140>
  802560:	39 0c 24             	cmp    %ecx,(%esp)
  802563:	0f 86 d7 00 00 00    	jbe    802640 <__umoddi3+0x140>
  802569:	8b 44 24 08          	mov    0x8(%esp),%eax
  80256d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802571:	83 c4 1c             	add    $0x1c,%esp
  802574:	5b                   	pop    %ebx
  802575:	5e                   	pop    %esi
  802576:	5f                   	pop    %edi
  802577:	5d                   	pop    %ebp
  802578:	c3                   	ret    
  802579:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802580:	85 ff                	test   %edi,%edi
  802582:	89 fd                	mov    %edi,%ebp
  802584:	75 0b                	jne    802591 <__umoddi3+0x91>
  802586:	b8 01 00 00 00       	mov    $0x1,%eax
  80258b:	31 d2                	xor    %edx,%edx
  80258d:	f7 f7                	div    %edi
  80258f:	89 c5                	mov    %eax,%ebp
  802591:	89 f0                	mov    %esi,%eax
  802593:	31 d2                	xor    %edx,%edx
  802595:	f7 f5                	div    %ebp
  802597:	89 c8                	mov    %ecx,%eax
  802599:	f7 f5                	div    %ebp
  80259b:	89 d0                	mov    %edx,%eax
  80259d:	eb 99                	jmp    802538 <__umoddi3+0x38>
  80259f:	90                   	nop
  8025a0:	89 c8                	mov    %ecx,%eax
  8025a2:	89 f2                	mov    %esi,%edx
  8025a4:	83 c4 1c             	add    $0x1c,%esp
  8025a7:	5b                   	pop    %ebx
  8025a8:	5e                   	pop    %esi
  8025a9:	5f                   	pop    %edi
  8025aa:	5d                   	pop    %ebp
  8025ab:	c3                   	ret    
  8025ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8025b0:	8b 34 24             	mov    (%esp),%esi
  8025b3:	bf 20 00 00 00       	mov    $0x20,%edi
  8025b8:	89 e9                	mov    %ebp,%ecx
  8025ba:	29 ef                	sub    %ebp,%edi
  8025bc:	d3 e0                	shl    %cl,%eax
  8025be:	89 f9                	mov    %edi,%ecx
  8025c0:	89 f2                	mov    %esi,%edx
  8025c2:	d3 ea                	shr    %cl,%edx
  8025c4:	89 e9                	mov    %ebp,%ecx
  8025c6:	09 c2                	or     %eax,%edx
  8025c8:	89 d8                	mov    %ebx,%eax
  8025ca:	89 14 24             	mov    %edx,(%esp)
  8025cd:	89 f2                	mov    %esi,%edx
  8025cf:	d3 e2                	shl    %cl,%edx
  8025d1:	89 f9                	mov    %edi,%ecx
  8025d3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025d7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8025db:	d3 e8                	shr    %cl,%eax
  8025dd:	89 e9                	mov    %ebp,%ecx
  8025df:	89 c6                	mov    %eax,%esi
  8025e1:	d3 e3                	shl    %cl,%ebx
  8025e3:	89 f9                	mov    %edi,%ecx
  8025e5:	89 d0                	mov    %edx,%eax
  8025e7:	d3 e8                	shr    %cl,%eax
  8025e9:	89 e9                	mov    %ebp,%ecx
  8025eb:	09 d8                	or     %ebx,%eax
  8025ed:	89 d3                	mov    %edx,%ebx
  8025ef:	89 f2                	mov    %esi,%edx
  8025f1:	f7 34 24             	divl   (%esp)
  8025f4:	89 d6                	mov    %edx,%esi
  8025f6:	d3 e3                	shl    %cl,%ebx
  8025f8:	f7 64 24 04          	mull   0x4(%esp)
  8025fc:	39 d6                	cmp    %edx,%esi
  8025fe:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802602:	89 d1                	mov    %edx,%ecx
  802604:	89 c3                	mov    %eax,%ebx
  802606:	72 08                	jb     802610 <__umoddi3+0x110>
  802608:	75 11                	jne    80261b <__umoddi3+0x11b>
  80260a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80260e:	73 0b                	jae    80261b <__umoddi3+0x11b>
  802610:	2b 44 24 04          	sub    0x4(%esp),%eax
  802614:	1b 14 24             	sbb    (%esp),%edx
  802617:	89 d1                	mov    %edx,%ecx
  802619:	89 c3                	mov    %eax,%ebx
  80261b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80261f:	29 da                	sub    %ebx,%edx
  802621:	19 ce                	sbb    %ecx,%esi
  802623:	89 f9                	mov    %edi,%ecx
  802625:	89 f0                	mov    %esi,%eax
  802627:	d3 e0                	shl    %cl,%eax
  802629:	89 e9                	mov    %ebp,%ecx
  80262b:	d3 ea                	shr    %cl,%edx
  80262d:	89 e9                	mov    %ebp,%ecx
  80262f:	d3 ee                	shr    %cl,%esi
  802631:	09 d0                	or     %edx,%eax
  802633:	89 f2                	mov    %esi,%edx
  802635:	83 c4 1c             	add    $0x1c,%esp
  802638:	5b                   	pop    %ebx
  802639:	5e                   	pop    %esi
  80263a:	5f                   	pop    %edi
  80263b:	5d                   	pop    %ebp
  80263c:	c3                   	ret    
  80263d:	8d 76 00             	lea    0x0(%esi),%esi
  802640:	29 f9                	sub    %edi,%ecx
  802642:	19 d6                	sbb    %edx,%esi
  802644:	89 74 24 04          	mov    %esi,0x4(%esp)
  802648:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80264c:	e9 18 ff ff ff       	jmp    802569 <__umoddi3+0x69>
