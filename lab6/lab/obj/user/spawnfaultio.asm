
obj/user/spawnfaultio.debug：     文件格式 elf32-i386


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
  80002c:	e8 4a 00 00 00       	call   80007b <libmain>
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
	int r;
	cprintf("i am parent environment %08x\n", thisenv->env_id);
  800039:	a1 08 40 80 00       	mov    0x804008,%eax
  80003e:	8b 40 48             	mov    0x48(%eax),%eax
  800041:	50                   	push   %eax
  800042:	68 e0 28 80 00       	push   $0x8028e0
  800047:	e8 68 01 00 00       	call   8001b4 <cprintf>
	if ((r = spawnl("faultio", "faultio", 0)) < 0)
  80004c:	83 c4 0c             	add    $0xc,%esp
  80004f:	6a 00                	push   $0x0
  800051:	68 fe 28 80 00       	push   $0x8028fe
  800056:	68 fe 28 80 00       	push   $0x8028fe
  80005b:	e8 fe 1a 00 00       	call   801b5e <spawnl>
  800060:	83 c4 10             	add    $0x10,%esp
  800063:	85 c0                	test   %eax,%eax
  800065:	79 12                	jns    800079 <umain+0x46>
		panic("spawn(faultio) failed: %e", r);
  800067:	50                   	push   %eax
  800068:	68 06 29 80 00       	push   $0x802906
  80006d:	6a 09                	push   $0x9
  80006f:	68 20 29 80 00       	push   $0x802920
  800074:	e8 62 00 00 00       	call   8000db <_panic>
}
  800079:	c9                   	leave  
  80007a:	c3                   	ret    

0080007b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80007b:	55                   	push   %ebp
  80007c:	89 e5                	mov    %esp,%ebp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800083:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800086:	e8 f2 0a 00 00       	call   800b7d <sys_getenvid>
  80008b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800090:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800093:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800098:	a3 08 40 80 00       	mov    %eax,0x804008

    // save the name of the program so that panic() can use it
    if (argc > 0)
  80009d:	85 db                	test   %ebx,%ebx
  80009f:	7e 07                	jle    8000a8 <libmain+0x2d>
        binaryname = argv[0];
  8000a1:	8b 06                	mov    (%esi),%eax
  8000a3:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  8000a8:	83 ec 08             	sub    $0x8,%esp
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
  8000ad:	e8 81 ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  8000b2:	e8 0a 00 00 00       	call   8000c1 <exit>
}
  8000b7:	83 c4 10             	add    $0x10,%esp
  8000ba:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000bd:	5b                   	pop    %ebx
  8000be:	5e                   	pop    %esi
  8000bf:	5d                   	pop    %ebp
  8000c0:	c3                   	ret    

008000c1 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c7:	e8 ea 0e 00 00       	call   800fb6 <close_all>
	sys_env_destroy(0);
  8000cc:	83 ec 0c             	sub    $0xc,%esp
  8000cf:	6a 00                	push   $0x0
  8000d1:	e8 66 0a 00 00       	call   800b3c <sys_env_destroy>
}
  8000d6:	83 c4 10             	add    $0x10,%esp
  8000d9:	c9                   	leave  
  8000da:	c3                   	ret    

008000db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	56                   	push   %esi
  8000df:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8000e0:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8000e3:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8000e9:	e8 8f 0a 00 00       	call   800b7d <sys_getenvid>
  8000ee:	83 ec 0c             	sub    $0xc,%esp
  8000f1:	ff 75 0c             	pushl  0xc(%ebp)
  8000f4:	ff 75 08             	pushl  0x8(%ebp)
  8000f7:	56                   	push   %esi
  8000f8:	50                   	push   %eax
  8000f9:	68 40 29 80 00       	push   $0x802940
  8000fe:	e8 b1 00 00 00       	call   8001b4 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800103:	83 c4 18             	add    $0x18,%esp
  800106:	53                   	push   %ebx
  800107:	ff 75 10             	pushl  0x10(%ebp)
  80010a:	e8 54 00 00 00       	call   800163 <vcprintf>
	cprintf("\n");
  80010f:	c7 04 24 55 2e 80 00 	movl   $0x802e55,(%esp)
  800116:	e8 99 00 00 00       	call   8001b4 <cprintf>
  80011b:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80011e:	cc                   	int3   
  80011f:	eb fd                	jmp    80011e <_panic+0x43>

00800121 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800121:	55                   	push   %ebp
  800122:	89 e5                	mov    %esp,%ebp
  800124:	53                   	push   %ebx
  800125:	83 ec 04             	sub    $0x4,%esp
  800128:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80012b:	8b 13                	mov    (%ebx),%edx
  80012d:	8d 42 01             	lea    0x1(%edx),%eax
  800130:	89 03                	mov    %eax,(%ebx)
  800132:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800135:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800139:	3d ff 00 00 00       	cmp    $0xff,%eax
  80013e:	75 1a                	jne    80015a <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800140:	83 ec 08             	sub    $0x8,%esp
  800143:	68 ff 00 00 00       	push   $0xff
  800148:	8d 43 08             	lea    0x8(%ebx),%eax
  80014b:	50                   	push   %eax
  80014c:	e8 ae 09 00 00       	call   800aff <sys_cputs>
		b->idx = 0;
  800151:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800157:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  80015a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80015e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800161:	c9                   	leave  
  800162:	c3                   	ret    

00800163 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80016c:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800173:	00 00 00 
	b.cnt = 0;
  800176:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017d:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800180:	ff 75 0c             	pushl  0xc(%ebp)
  800183:	ff 75 08             	pushl  0x8(%ebp)
  800186:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80018c:	50                   	push   %eax
  80018d:	68 21 01 80 00       	push   $0x800121
  800192:	e8 1a 01 00 00       	call   8002b1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800197:	83 c4 08             	add    $0x8,%esp
  80019a:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001a0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001a6:	50                   	push   %eax
  8001a7:	e8 53 09 00 00       	call   800aff <sys_cputs>

	return b.cnt;
}
  8001ac:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    

008001b4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001b4:	55                   	push   %ebp
  8001b5:	89 e5                	mov    %esp,%ebp
  8001b7:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001ba:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001bd:	50                   	push   %eax
  8001be:	ff 75 08             	pushl  0x8(%ebp)
  8001c1:	e8 9d ff ff ff       	call   800163 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001c6:	c9                   	leave  
  8001c7:	c3                   	ret    

008001c8 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c8:	55                   	push   %ebp
  8001c9:	89 e5                	mov    %esp,%ebp
  8001cb:	57                   	push   %edi
  8001cc:	56                   	push   %esi
  8001cd:	53                   	push   %ebx
  8001ce:	83 ec 1c             	sub    $0x1c,%esp
  8001d1:	89 c7                	mov    %eax,%edi
  8001d3:	89 d6                	mov    %edx,%esi
  8001d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001db:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001de:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8001e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e9:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8001ec:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8001ef:	39 d3                	cmp    %edx,%ebx
  8001f1:	72 05                	jb     8001f8 <printnum+0x30>
  8001f3:	39 45 10             	cmp    %eax,0x10(%ebp)
  8001f6:	77 45                	ja     80023d <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001f8:	83 ec 0c             	sub    $0xc,%esp
  8001fb:	ff 75 18             	pushl  0x18(%ebp)
  8001fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800201:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800204:	53                   	push   %ebx
  800205:	ff 75 10             	pushl  0x10(%ebp)
  800208:	83 ec 08             	sub    $0x8,%esp
  80020b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80020e:	ff 75 e0             	pushl  -0x20(%ebp)
  800211:	ff 75 dc             	pushl  -0x24(%ebp)
  800214:	ff 75 d8             	pushl  -0x28(%ebp)
  800217:	e8 34 24 00 00       	call   802650 <__udivdi3>
  80021c:	83 c4 18             	add    $0x18,%esp
  80021f:	52                   	push   %edx
  800220:	50                   	push   %eax
  800221:	89 f2                	mov    %esi,%edx
  800223:	89 f8                	mov    %edi,%eax
  800225:	e8 9e ff ff ff       	call   8001c8 <printnum>
  80022a:	83 c4 20             	add    $0x20,%esp
  80022d:	eb 18                	jmp    800247 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80022f:	83 ec 08             	sub    $0x8,%esp
  800232:	56                   	push   %esi
  800233:	ff 75 18             	pushl  0x18(%ebp)
  800236:	ff d7                	call   *%edi
  800238:	83 c4 10             	add    $0x10,%esp
  80023b:	eb 03                	jmp    800240 <printnum+0x78>
  80023d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800240:	83 eb 01             	sub    $0x1,%ebx
  800243:	85 db                	test   %ebx,%ebx
  800245:	7f e8                	jg     80022f <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800247:	83 ec 08             	sub    $0x8,%esp
  80024a:	56                   	push   %esi
  80024b:	83 ec 04             	sub    $0x4,%esp
  80024e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800251:	ff 75 e0             	pushl  -0x20(%ebp)
  800254:	ff 75 dc             	pushl  -0x24(%ebp)
  800257:	ff 75 d8             	pushl  -0x28(%ebp)
  80025a:	e8 21 25 00 00       	call   802780 <__umoddi3>
  80025f:	83 c4 14             	add    $0x14,%esp
  800262:	0f be 80 63 29 80 00 	movsbl 0x802963(%eax),%eax
  800269:	50                   	push   %eax
  80026a:	ff d7                	call   *%edi
}
  80026c:	83 c4 10             	add    $0x10,%esp
  80026f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800272:	5b                   	pop    %ebx
  800273:	5e                   	pop    %esi
  800274:	5f                   	pop    %edi
  800275:	5d                   	pop    %ebp
  800276:	c3                   	ret    

00800277 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800277:	55                   	push   %ebp
  800278:	89 e5                	mov    %esp,%ebp
  80027a:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80027d:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800281:	8b 10                	mov    (%eax),%edx
  800283:	3b 50 04             	cmp    0x4(%eax),%edx
  800286:	73 0a                	jae    800292 <sprintputch+0x1b>
		*b->buf++ = ch;
  800288:	8d 4a 01             	lea    0x1(%edx),%ecx
  80028b:	89 08                	mov    %ecx,(%eax)
  80028d:	8b 45 08             	mov    0x8(%ebp),%eax
  800290:	88 02                	mov    %al,(%edx)
}
  800292:	5d                   	pop    %ebp
  800293:	c3                   	ret    

00800294 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800294:	55                   	push   %ebp
  800295:	89 e5                	mov    %esp,%ebp
  800297:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80029a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80029d:	50                   	push   %eax
  80029e:	ff 75 10             	pushl  0x10(%ebp)
  8002a1:	ff 75 0c             	pushl  0xc(%ebp)
  8002a4:	ff 75 08             	pushl  0x8(%ebp)
  8002a7:	e8 05 00 00 00       	call   8002b1 <vprintfmt>
	va_end(ap);
}
  8002ac:	83 c4 10             	add    $0x10,%esp
  8002af:	c9                   	leave  
  8002b0:	c3                   	ret    

008002b1 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002b1:	55                   	push   %ebp
  8002b2:	89 e5                	mov    %esp,%ebp
  8002b4:	57                   	push   %edi
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	83 ec 2c             	sub    $0x2c,%esp
  8002ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8002bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8002c0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8002c3:	eb 12                	jmp    8002d7 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002c5:	85 c0                	test   %eax,%eax
  8002c7:	0f 84 42 04 00 00    	je     80070f <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8002cd:	83 ec 08             	sub    $0x8,%esp
  8002d0:	53                   	push   %ebx
  8002d1:	50                   	push   %eax
  8002d2:	ff d6                	call   *%esi
  8002d4:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002d7:	83 c7 01             	add    $0x1,%edi
  8002da:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8002de:	83 f8 25             	cmp    $0x25,%eax
  8002e1:	75 e2                	jne    8002c5 <vprintfmt+0x14>
  8002e3:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8002e7:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8002ee:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8002f5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8002fc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800301:	eb 07                	jmp    80030a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800303:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800306:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80030a:	8d 47 01             	lea    0x1(%edi),%eax
  80030d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800310:	0f b6 07             	movzbl (%edi),%eax
  800313:	0f b6 d0             	movzbl %al,%edx
  800316:	83 e8 23             	sub    $0x23,%eax
  800319:	3c 55                	cmp    $0x55,%al
  80031b:	0f 87 d3 03 00 00    	ja     8006f4 <vprintfmt+0x443>
  800321:	0f b6 c0             	movzbl %al,%eax
  800324:	ff 24 85 a0 2a 80 00 	jmp    *0x802aa0(,%eax,4)
  80032b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80032e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800332:	eb d6                	jmp    80030a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800334:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800337:	b8 00 00 00 00       	mov    $0x0,%eax
  80033c:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80033f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800342:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800346:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800349:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80034c:	83 f9 09             	cmp    $0x9,%ecx
  80034f:	77 3f                	ja     800390 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800351:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800354:	eb e9                	jmp    80033f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800356:	8b 45 14             	mov    0x14(%ebp),%eax
  800359:	8b 00                	mov    (%eax),%eax
  80035b:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80035e:	8b 45 14             	mov    0x14(%ebp),%eax
  800361:	8d 40 04             	lea    0x4(%eax),%eax
  800364:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80036a:	eb 2a                	jmp    800396 <vprintfmt+0xe5>
  80036c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80036f:	85 c0                	test   %eax,%eax
  800371:	ba 00 00 00 00       	mov    $0x0,%edx
  800376:	0f 49 d0             	cmovns %eax,%edx
  800379:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80037f:	eb 89                	jmp    80030a <vprintfmt+0x59>
  800381:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800384:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80038b:	e9 7a ff ff ff       	jmp    80030a <vprintfmt+0x59>
  800390:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800393:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800396:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80039a:	0f 89 6a ff ff ff    	jns    80030a <vprintfmt+0x59>
				width = precision, precision = -1;
  8003a0:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8003a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a6:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8003ad:	e9 58 ff ff ff       	jmp    80030a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003b2:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003b5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8003b8:	e9 4d ff ff ff       	jmp    80030a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003bd:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c0:	8d 78 04             	lea    0x4(%eax),%edi
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	53                   	push   %ebx
  8003c7:	ff 30                	pushl  (%eax)
  8003c9:	ff d6                	call   *%esi
			break;
  8003cb:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003ce:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8003d4:	e9 fe fe ff ff       	jmp    8002d7 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003dc:	8d 78 04             	lea    0x4(%eax),%edi
  8003df:	8b 00                	mov    (%eax),%eax
  8003e1:	99                   	cltd   
  8003e2:	31 d0                	xor    %edx,%eax
  8003e4:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8003e6:	83 f8 0f             	cmp    $0xf,%eax
  8003e9:	7f 0b                	jg     8003f6 <vprintfmt+0x145>
  8003eb:	8b 14 85 00 2c 80 00 	mov    0x802c00(,%eax,4),%edx
  8003f2:	85 d2                	test   %edx,%edx
  8003f4:	75 1b                	jne    800411 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8003f6:	50                   	push   %eax
  8003f7:	68 7b 29 80 00       	push   $0x80297b
  8003fc:	53                   	push   %ebx
  8003fd:	56                   	push   %esi
  8003fe:	e8 91 fe ff ff       	call   800294 <printfmt>
  800403:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800406:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800409:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80040c:	e9 c6 fe ff ff       	jmp    8002d7 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800411:	52                   	push   %edx
  800412:	68 35 2d 80 00       	push   $0x802d35
  800417:	53                   	push   %ebx
  800418:	56                   	push   %esi
  800419:	e8 76 fe ff ff       	call   800294 <printfmt>
  80041e:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800421:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800424:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800427:	e9 ab fe ff ff       	jmp    8002d7 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80042c:	8b 45 14             	mov    0x14(%ebp),%eax
  80042f:	83 c0 04             	add    $0x4,%eax
  800432:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80043a:	85 ff                	test   %edi,%edi
  80043c:	b8 74 29 80 00       	mov    $0x802974,%eax
  800441:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800444:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800448:	0f 8e 94 00 00 00    	jle    8004e2 <vprintfmt+0x231>
  80044e:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800452:	0f 84 98 00 00 00    	je     8004f0 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800458:	83 ec 08             	sub    $0x8,%esp
  80045b:	ff 75 d0             	pushl  -0x30(%ebp)
  80045e:	57                   	push   %edi
  80045f:	e8 33 03 00 00       	call   800797 <strnlen>
  800464:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800467:	29 c1                	sub    %eax,%ecx
  800469:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  80046c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80046f:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800473:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800476:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800479:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80047b:	eb 0f                	jmp    80048c <vprintfmt+0x1db>
					putch(padc, putdat);
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	53                   	push   %ebx
  800481:	ff 75 e0             	pushl  -0x20(%ebp)
  800484:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800486:	83 ef 01             	sub    $0x1,%edi
  800489:	83 c4 10             	add    $0x10,%esp
  80048c:	85 ff                	test   %edi,%edi
  80048e:	7f ed                	jg     80047d <vprintfmt+0x1cc>
  800490:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800493:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800496:	85 c9                	test   %ecx,%ecx
  800498:	b8 00 00 00 00       	mov    $0x0,%eax
  80049d:	0f 49 c1             	cmovns %ecx,%eax
  8004a0:	29 c1                	sub    %eax,%ecx
  8004a2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004a5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004a8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004ab:	89 cb                	mov    %ecx,%ebx
  8004ad:	eb 4d                	jmp    8004fc <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004af:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004b3:	74 1b                	je     8004d0 <vprintfmt+0x21f>
  8004b5:	0f be c0             	movsbl %al,%eax
  8004b8:	83 e8 20             	sub    $0x20,%eax
  8004bb:	83 f8 5e             	cmp    $0x5e,%eax
  8004be:	76 10                	jbe    8004d0 <vprintfmt+0x21f>
					putch('?', putdat);
  8004c0:	83 ec 08             	sub    $0x8,%esp
  8004c3:	ff 75 0c             	pushl  0xc(%ebp)
  8004c6:	6a 3f                	push   $0x3f
  8004c8:	ff 55 08             	call   *0x8(%ebp)
  8004cb:	83 c4 10             	add    $0x10,%esp
  8004ce:	eb 0d                	jmp    8004dd <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8004d0:	83 ec 08             	sub    $0x8,%esp
  8004d3:	ff 75 0c             	pushl  0xc(%ebp)
  8004d6:	52                   	push   %edx
  8004d7:	ff 55 08             	call   *0x8(%ebp)
  8004da:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004dd:	83 eb 01             	sub    $0x1,%ebx
  8004e0:	eb 1a                	jmp    8004fc <vprintfmt+0x24b>
  8004e2:	89 75 08             	mov    %esi,0x8(%ebp)
  8004e5:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004e8:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004eb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ee:	eb 0c                	jmp    8004fc <vprintfmt+0x24b>
  8004f0:	89 75 08             	mov    %esi,0x8(%ebp)
  8004f3:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8004f6:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8004f9:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004fc:	83 c7 01             	add    $0x1,%edi
  8004ff:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800503:	0f be d0             	movsbl %al,%edx
  800506:	85 d2                	test   %edx,%edx
  800508:	74 23                	je     80052d <vprintfmt+0x27c>
  80050a:	85 f6                	test   %esi,%esi
  80050c:	78 a1                	js     8004af <vprintfmt+0x1fe>
  80050e:	83 ee 01             	sub    $0x1,%esi
  800511:	79 9c                	jns    8004af <vprintfmt+0x1fe>
  800513:	89 df                	mov    %ebx,%edi
  800515:	8b 75 08             	mov    0x8(%ebp),%esi
  800518:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80051b:	eb 18                	jmp    800535 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80051d:	83 ec 08             	sub    $0x8,%esp
  800520:	53                   	push   %ebx
  800521:	6a 20                	push   $0x20
  800523:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800525:	83 ef 01             	sub    $0x1,%edi
  800528:	83 c4 10             	add    $0x10,%esp
  80052b:	eb 08                	jmp    800535 <vprintfmt+0x284>
  80052d:	89 df                	mov    %ebx,%edi
  80052f:	8b 75 08             	mov    0x8(%ebp),%esi
  800532:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800535:	85 ff                	test   %edi,%edi
  800537:	7f e4                	jg     80051d <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800539:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80053c:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800542:	e9 90 fd ff ff       	jmp    8002d7 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800547:	83 f9 01             	cmp    $0x1,%ecx
  80054a:	7e 19                	jle    800565 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  80054c:	8b 45 14             	mov    0x14(%ebp),%eax
  80054f:	8b 50 04             	mov    0x4(%eax),%edx
  800552:	8b 00                	mov    (%eax),%eax
  800554:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800557:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80055a:	8b 45 14             	mov    0x14(%ebp),%eax
  80055d:	8d 40 08             	lea    0x8(%eax),%eax
  800560:	89 45 14             	mov    %eax,0x14(%ebp)
  800563:	eb 38                	jmp    80059d <vprintfmt+0x2ec>
	else if (lflag)
  800565:	85 c9                	test   %ecx,%ecx
  800567:	74 1b                	je     800584 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800569:	8b 45 14             	mov    0x14(%ebp),%eax
  80056c:	8b 00                	mov    (%eax),%eax
  80056e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800571:	89 c1                	mov    %eax,%ecx
  800573:	c1 f9 1f             	sar    $0x1f,%ecx
  800576:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800579:	8b 45 14             	mov    0x14(%ebp),%eax
  80057c:	8d 40 04             	lea    0x4(%eax),%eax
  80057f:	89 45 14             	mov    %eax,0x14(%ebp)
  800582:	eb 19                	jmp    80059d <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800584:	8b 45 14             	mov    0x14(%ebp),%eax
  800587:	8b 00                	mov    (%eax),%eax
  800589:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80058c:	89 c1                	mov    %eax,%ecx
  80058e:	c1 f9 1f             	sar    $0x1f,%ecx
  800591:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800594:	8b 45 14             	mov    0x14(%ebp),%eax
  800597:	8d 40 04             	lea    0x4(%eax),%eax
  80059a:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80059d:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8005a3:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8005a8:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8005ac:	0f 89 0e 01 00 00    	jns    8006c0 <vprintfmt+0x40f>
				putch('-', putdat);
  8005b2:	83 ec 08             	sub    $0x8,%esp
  8005b5:	53                   	push   %ebx
  8005b6:	6a 2d                	push   $0x2d
  8005b8:	ff d6                	call   *%esi
				num = -(long long) num;
  8005ba:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005bd:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005c0:	f7 da                	neg    %edx
  8005c2:	83 d1 00             	adc    $0x0,%ecx
  8005c5:	f7 d9                	neg    %ecx
  8005c7:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8005ca:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005cf:	e9 ec 00 00 00       	jmp    8006c0 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d4:	83 f9 01             	cmp    $0x1,%ecx
  8005d7:	7e 18                	jle    8005f1 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8005d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8005dc:	8b 10                	mov    (%eax),%edx
  8005de:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e1:	8d 40 08             	lea    0x8(%eax),%eax
  8005e4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8005e7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ec:	e9 cf 00 00 00       	jmp    8006c0 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005f1:	85 c9                	test   %ecx,%ecx
  8005f3:	74 1a                	je     80060f <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8005f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f8:	8b 10                	mov    (%eax),%edx
  8005fa:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ff:	8d 40 04             	lea    0x4(%eax),%eax
  800602:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800605:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060a:	e9 b1 00 00 00       	jmp    8006c0 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  80060f:	8b 45 14             	mov    0x14(%ebp),%eax
  800612:	8b 10                	mov    (%eax),%edx
  800614:	b9 00 00 00 00       	mov    $0x0,%ecx
  800619:	8d 40 04             	lea    0x4(%eax),%eax
  80061c:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80061f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800624:	e9 97 00 00 00       	jmp    8006c0 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	6a 58                	push   $0x58
  80062f:	ff d6                	call   *%esi
			putch('X', putdat);
  800631:	83 c4 08             	add    $0x8,%esp
  800634:	53                   	push   %ebx
  800635:	6a 58                	push   $0x58
  800637:	ff d6                	call   *%esi
			putch('X', putdat);
  800639:	83 c4 08             	add    $0x8,%esp
  80063c:	53                   	push   %ebx
  80063d:	6a 58                	push   $0x58
  80063f:	ff d6                	call   *%esi
			break;
  800641:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800644:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800647:	e9 8b fc ff ff       	jmp    8002d7 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	53                   	push   %ebx
  800650:	6a 30                	push   $0x30
  800652:	ff d6                	call   *%esi
			putch('x', putdat);
  800654:	83 c4 08             	add    $0x8,%esp
  800657:	53                   	push   %ebx
  800658:	6a 78                	push   $0x78
  80065a:	ff d6                	call   *%esi
			num = (unsigned long long)
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8b 10                	mov    (%eax),%edx
  800661:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800666:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800669:	8d 40 04             	lea    0x4(%eax),%eax
  80066c:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  80066f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800674:	eb 4a                	jmp    8006c0 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800676:	83 f9 01             	cmp    $0x1,%ecx
  800679:	7e 15                	jle    800690 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8b 10                	mov    (%eax),%edx
  800680:	8b 48 04             	mov    0x4(%eax),%ecx
  800683:	8d 40 08             	lea    0x8(%eax),%eax
  800686:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800689:	b8 10 00 00 00       	mov    $0x10,%eax
  80068e:	eb 30                	jmp    8006c0 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800690:	85 c9                	test   %ecx,%ecx
  800692:	74 17                	je     8006ab <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8b 10                	mov    (%eax),%edx
  800699:	b9 00 00 00 00       	mov    $0x0,%ecx
  80069e:	8d 40 04             	lea    0x4(%eax),%eax
  8006a1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006a4:	b8 10 00 00 00       	mov    $0x10,%eax
  8006a9:	eb 15                	jmp    8006c0 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8006ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ae:	8b 10                	mov    (%eax),%edx
  8006b0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006b5:	8d 40 04             	lea    0x4(%eax),%eax
  8006b8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8006bb:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006c0:	83 ec 0c             	sub    $0xc,%esp
  8006c3:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8006c7:	57                   	push   %edi
  8006c8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006cb:	50                   	push   %eax
  8006cc:	51                   	push   %ecx
  8006cd:	52                   	push   %edx
  8006ce:	89 da                	mov    %ebx,%edx
  8006d0:	89 f0                	mov    %esi,%eax
  8006d2:	e8 f1 fa ff ff       	call   8001c8 <printnum>
			break;
  8006d7:	83 c4 20             	add    $0x20,%esp
  8006da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006dd:	e9 f5 fb ff ff       	jmp    8002d7 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e2:	83 ec 08             	sub    $0x8,%esp
  8006e5:	53                   	push   %ebx
  8006e6:	52                   	push   %edx
  8006e7:	ff d6                	call   *%esi
			break;
  8006e9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8006ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8006ef:	e9 e3 fb ff ff       	jmp    8002d7 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f4:	83 ec 08             	sub    $0x8,%esp
  8006f7:	53                   	push   %ebx
  8006f8:	6a 25                	push   $0x25
  8006fa:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006fc:	83 c4 10             	add    $0x10,%esp
  8006ff:	eb 03                	jmp    800704 <vprintfmt+0x453>
  800701:	83 ef 01             	sub    $0x1,%edi
  800704:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800708:	75 f7                	jne    800701 <vprintfmt+0x450>
  80070a:	e9 c8 fb ff ff       	jmp    8002d7 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80070f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800712:	5b                   	pop    %ebx
  800713:	5e                   	pop    %esi
  800714:	5f                   	pop    %edi
  800715:	5d                   	pop    %ebp
  800716:	c3                   	ret    

00800717 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800717:	55                   	push   %ebp
  800718:	89 e5                	mov    %esp,%ebp
  80071a:	83 ec 18             	sub    $0x18,%esp
  80071d:	8b 45 08             	mov    0x8(%ebp),%eax
  800720:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800723:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800726:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80072a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80072d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800734:	85 c0                	test   %eax,%eax
  800736:	74 26                	je     80075e <vsnprintf+0x47>
  800738:	85 d2                	test   %edx,%edx
  80073a:	7e 22                	jle    80075e <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073c:	ff 75 14             	pushl  0x14(%ebp)
  80073f:	ff 75 10             	pushl  0x10(%ebp)
  800742:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800745:	50                   	push   %eax
  800746:	68 77 02 80 00       	push   $0x800277
  80074b:	e8 61 fb ff ff       	call   8002b1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800750:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800753:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800756:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800759:	83 c4 10             	add    $0x10,%esp
  80075c:	eb 05                	jmp    800763 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80075e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800763:	c9                   	leave  
  800764:	c3                   	ret    

00800765 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80076b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80076e:	50                   	push   %eax
  80076f:	ff 75 10             	pushl  0x10(%ebp)
  800772:	ff 75 0c             	pushl  0xc(%ebp)
  800775:	ff 75 08             	pushl  0x8(%ebp)
  800778:	e8 9a ff ff ff       	call   800717 <vsnprintf>
	va_end(ap);

	return rc;
}
  80077d:	c9                   	leave  
  80077e:	c3                   	ret    

0080077f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80077f:	55                   	push   %ebp
  800780:	89 e5                	mov    %esp,%ebp
  800782:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800785:	b8 00 00 00 00       	mov    $0x0,%eax
  80078a:	eb 03                	jmp    80078f <strlen+0x10>
		n++;
  80078c:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  80078f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800793:	75 f7                	jne    80078c <strlen+0xd>
		n++;
	return n;
}
  800795:	5d                   	pop    %ebp
  800796:	c3                   	ret    

00800797 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800797:	55                   	push   %ebp
  800798:	89 e5                	mov    %esp,%ebp
  80079a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079d:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a5:	eb 03                	jmp    8007aa <strnlen+0x13>
		n++;
  8007a7:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007aa:	39 c2                	cmp    %eax,%edx
  8007ac:	74 08                	je     8007b6 <strnlen+0x1f>
  8007ae:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8007b2:	75 f3                	jne    8007a7 <strnlen+0x10>
  8007b4:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8007b6:	5d                   	pop    %ebp
  8007b7:	c3                   	ret    

008007b8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007b8:	55                   	push   %ebp
  8007b9:	89 e5                	mov    %esp,%ebp
  8007bb:	53                   	push   %ebx
  8007bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007c2:	89 c2                	mov    %eax,%edx
  8007c4:	83 c2 01             	add    $0x1,%edx
  8007c7:	83 c1 01             	add    $0x1,%ecx
  8007ca:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8007ce:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007d1:	84 db                	test   %bl,%bl
  8007d3:	75 ef                	jne    8007c4 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8007d5:	5b                   	pop    %ebx
  8007d6:	5d                   	pop    %ebp
  8007d7:	c3                   	ret    

008007d8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007d8:	55                   	push   %ebp
  8007d9:	89 e5                	mov    %esp,%ebp
  8007db:	53                   	push   %ebx
  8007dc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007df:	53                   	push   %ebx
  8007e0:	e8 9a ff ff ff       	call   80077f <strlen>
  8007e5:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8007e8:	ff 75 0c             	pushl  0xc(%ebp)
  8007eb:	01 d8                	add    %ebx,%eax
  8007ed:	50                   	push   %eax
  8007ee:	e8 c5 ff ff ff       	call   8007b8 <strcpy>
	return dst;
}
  8007f3:	89 d8                	mov    %ebx,%eax
  8007f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f8:	c9                   	leave  
  8007f9:	c3                   	ret    

008007fa <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	56                   	push   %esi
  8007fe:	53                   	push   %ebx
  8007ff:	8b 75 08             	mov    0x8(%ebp),%esi
  800802:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800805:	89 f3                	mov    %esi,%ebx
  800807:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80080a:	89 f2                	mov    %esi,%edx
  80080c:	eb 0f                	jmp    80081d <strncpy+0x23>
		*dst++ = *src;
  80080e:	83 c2 01             	add    $0x1,%edx
  800811:	0f b6 01             	movzbl (%ecx),%eax
  800814:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800817:	80 39 01             	cmpb   $0x1,(%ecx)
  80081a:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80081d:	39 da                	cmp    %ebx,%edx
  80081f:	75 ed                	jne    80080e <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800821:	89 f0                	mov    %esi,%eax
  800823:	5b                   	pop    %ebx
  800824:	5e                   	pop    %esi
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800827:	55                   	push   %ebp
  800828:	89 e5                	mov    %esp,%ebp
  80082a:	56                   	push   %esi
  80082b:	53                   	push   %ebx
  80082c:	8b 75 08             	mov    0x8(%ebp),%esi
  80082f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800832:	8b 55 10             	mov    0x10(%ebp),%edx
  800835:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800837:	85 d2                	test   %edx,%edx
  800839:	74 21                	je     80085c <strlcpy+0x35>
  80083b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80083f:	89 f2                	mov    %esi,%edx
  800841:	eb 09                	jmp    80084c <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800843:	83 c2 01             	add    $0x1,%edx
  800846:	83 c1 01             	add    $0x1,%ecx
  800849:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80084c:	39 c2                	cmp    %eax,%edx
  80084e:	74 09                	je     800859 <strlcpy+0x32>
  800850:	0f b6 19             	movzbl (%ecx),%ebx
  800853:	84 db                	test   %bl,%bl
  800855:	75 ec                	jne    800843 <strlcpy+0x1c>
  800857:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800859:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085c:	29 f0                	sub    %esi,%eax
}
  80085e:	5b                   	pop    %ebx
  80085f:	5e                   	pop    %esi
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800862:	55                   	push   %ebp
  800863:	89 e5                	mov    %esp,%ebp
  800865:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800868:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80086b:	eb 06                	jmp    800873 <strcmp+0x11>
		p++, q++;
  80086d:	83 c1 01             	add    $0x1,%ecx
  800870:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800873:	0f b6 01             	movzbl (%ecx),%eax
  800876:	84 c0                	test   %al,%al
  800878:	74 04                	je     80087e <strcmp+0x1c>
  80087a:	3a 02                	cmp    (%edx),%al
  80087c:	74 ef                	je     80086d <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80087e:	0f b6 c0             	movzbl %al,%eax
  800881:	0f b6 12             	movzbl (%edx),%edx
  800884:	29 d0                	sub    %edx,%eax
}
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800888:	55                   	push   %ebp
  800889:	89 e5                	mov    %esp,%ebp
  80088b:	53                   	push   %ebx
  80088c:	8b 45 08             	mov    0x8(%ebp),%eax
  80088f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800892:	89 c3                	mov    %eax,%ebx
  800894:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800897:	eb 06                	jmp    80089f <strncmp+0x17>
		n--, p++, q++;
  800899:	83 c0 01             	add    $0x1,%eax
  80089c:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80089f:	39 d8                	cmp    %ebx,%eax
  8008a1:	74 15                	je     8008b8 <strncmp+0x30>
  8008a3:	0f b6 08             	movzbl (%eax),%ecx
  8008a6:	84 c9                	test   %cl,%cl
  8008a8:	74 04                	je     8008ae <strncmp+0x26>
  8008aa:	3a 0a                	cmp    (%edx),%cl
  8008ac:	74 eb                	je     800899 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008ae:	0f b6 00             	movzbl (%eax),%eax
  8008b1:	0f b6 12             	movzbl (%edx),%edx
  8008b4:	29 d0                	sub    %edx,%eax
  8008b6:	eb 05                	jmp    8008bd <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8008b8:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008bd:	5b                   	pop    %ebx
  8008be:	5d                   	pop    %ebp
  8008bf:	c3                   	ret    

008008c0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ca:	eb 07                	jmp    8008d3 <strchr+0x13>
		if (*s == c)
  8008cc:	38 ca                	cmp    %cl,%dl
  8008ce:	74 0f                	je     8008df <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8008d0:	83 c0 01             	add    $0x1,%eax
  8008d3:	0f b6 10             	movzbl (%eax),%edx
  8008d6:	84 d2                	test   %dl,%dl
  8008d8:	75 f2                	jne    8008cc <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8008da:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008df:	5d                   	pop    %ebp
  8008e0:	c3                   	ret    

008008e1 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008e1:	55                   	push   %ebp
  8008e2:	89 e5                	mov    %esp,%ebp
  8008e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008eb:	eb 03                	jmp    8008f0 <strfind+0xf>
  8008ed:	83 c0 01             	add    $0x1,%eax
  8008f0:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008f3:	38 ca                	cmp    %cl,%dl
  8008f5:	74 04                	je     8008fb <strfind+0x1a>
  8008f7:	84 d2                	test   %dl,%dl
  8008f9:	75 f2                	jne    8008ed <strfind+0xc>
			break;
	return (char *) s;
}
  8008fb:	5d                   	pop    %ebp
  8008fc:	c3                   	ret    

008008fd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	57                   	push   %edi
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	8b 7d 08             	mov    0x8(%ebp),%edi
  800906:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800909:	85 c9                	test   %ecx,%ecx
  80090b:	74 36                	je     800943 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090d:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800913:	75 28                	jne    80093d <memset+0x40>
  800915:	f6 c1 03             	test   $0x3,%cl
  800918:	75 23                	jne    80093d <memset+0x40>
		c &= 0xFF;
  80091a:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091e:	89 d3                	mov    %edx,%ebx
  800920:	c1 e3 08             	shl    $0x8,%ebx
  800923:	89 d6                	mov    %edx,%esi
  800925:	c1 e6 18             	shl    $0x18,%esi
  800928:	89 d0                	mov    %edx,%eax
  80092a:	c1 e0 10             	shl    $0x10,%eax
  80092d:	09 f0                	or     %esi,%eax
  80092f:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800931:	89 d8                	mov    %ebx,%eax
  800933:	09 d0                	or     %edx,%eax
  800935:	c1 e9 02             	shr    $0x2,%ecx
  800938:	fc                   	cld    
  800939:	f3 ab                	rep stos %eax,%es:(%edi)
  80093b:	eb 06                	jmp    800943 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80093d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800940:	fc                   	cld    
  800941:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800943:	89 f8                	mov    %edi,%eax
  800945:	5b                   	pop    %ebx
  800946:	5e                   	pop    %esi
  800947:	5f                   	pop    %edi
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	57                   	push   %edi
  80094e:	56                   	push   %esi
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 75 0c             	mov    0xc(%ebp),%esi
  800955:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800958:	39 c6                	cmp    %eax,%esi
  80095a:	73 35                	jae    800991 <memmove+0x47>
  80095c:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80095f:	39 d0                	cmp    %edx,%eax
  800961:	73 2e                	jae    800991 <memmove+0x47>
		s += n;
		d += n;
  800963:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800966:	89 d6                	mov    %edx,%esi
  800968:	09 fe                	or     %edi,%esi
  80096a:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800970:	75 13                	jne    800985 <memmove+0x3b>
  800972:	f6 c1 03             	test   $0x3,%cl
  800975:	75 0e                	jne    800985 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800977:	83 ef 04             	sub    $0x4,%edi
  80097a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097d:	c1 e9 02             	shr    $0x2,%ecx
  800980:	fd                   	std    
  800981:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800983:	eb 09                	jmp    80098e <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800985:	83 ef 01             	sub    $0x1,%edi
  800988:	8d 72 ff             	lea    -0x1(%edx),%esi
  80098b:	fd                   	std    
  80098c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098e:	fc                   	cld    
  80098f:	eb 1d                	jmp    8009ae <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800991:	89 f2                	mov    %esi,%edx
  800993:	09 c2                	or     %eax,%edx
  800995:	f6 c2 03             	test   $0x3,%dl
  800998:	75 0f                	jne    8009a9 <memmove+0x5f>
  80099a:	f6 c1 03             	test   $0x3,%cl
  80099d:	75 0a                	jne    8009a9 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  80099f:	c1 e9 02             	shr    $0x2,%ecx
  8009a2:	89 c7                	mov    %eax,%edi
  8009a4:	fc                   	cld    
  8009a5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a7:	eb 05                	jmp    8009ae <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8009a9:	89 c7                	mov    %eax,%edi
  8009ab:	fc                   	cld    
  8009ac:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009ae:	5e                   	pop    %esi
  8009af:	5f                   	pop    %edi
  8009b0:	5d                   	pop    %ebp
  8009b1:	c3                   	ret    

008009b2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009b2:	55                   	push   %ebp
  8009b3:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8009b5:	ff 75 10             	pushl  0x10(%ebp)
  8009b8:	ff 75 0c             	pushl  0xc(%ebp)
  8009bb:	ff 75 08             	pushl  0x8(%ebp)
  8009be:	e8 87 ff ff ff       	call   80094a <memmove>
}
  8009c3:	c9                   	leave  
  8009c4:	c3                   	ret    

008009c5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	56                   	push   %esi
  8009c9:	53                   	push   %ebx
  8009ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8009cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d0:	89 c6                	mov    %eax,%esi
  8009d2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009d5:	eb 1a                	jmp    8009f1 <memcmp+0x2c>
		if (*s1 != *s2)
  8009d7:	0f b6 08             	movzbl (%eax),%ecx
  8009da:	0f b6 1a             	movzbl (%edx),%ebx
  8009dd:	38 d9                	cmp    %bl,%cl
  8009df:	74 0a                	je     8009eb <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8009e1:	0f b6 c1             	movzbl %cl,%eax
  8009e4:	0f b6 db             	movzbl %bl,%ebx
  8009e7:	29 d8                	sub    %ebx,%eax
  8009e9:	eb 0f                	jmp    8009fa <memcmp+0x35>
		s1++, s2++;
  8009eb:	83 c0 01             	add    $0x1,%eax
  8009ee:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f1:	39 f0                	cmp    %esi,%eax
  8009f3:	75 e2                	jne    8009d7 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  8009f5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009fa:	5b                   	pop    %ebx
  8009fb:	5e                   	pop    %esi
  8009fc:	5d                   	pop    %ebp
  8009fd:	c3                   	ret    

008009fe <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009fe:	55                   	push   %ebp
  8009ff:	89 e5                	mov    %esp,%ebp
  800a01:	53                   	push   %ebx
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800a05:	89 c1                	mov    %eax,%ecx
  800a07:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800a0a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a0e:	eb 0a                	jmp    800a1a <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a10:	0f b6 10             	movzbl (%eax),%edx
  800a13:	39 da                	cmp    %ebx,%edx
  800a15:	74 07                	je     800a1e <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800a17:	83 c0 01             	add    $0x1,%eax
  800a1a:	39 c8                	cmp    %ecx,%eax
  800a1c:	72 f2                	jb     800a10 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800a1e:	5b                   	pop    %ebx
  800a1f:	5d                   	pop    %ebp
  800a20:	c3                   	ret    

00800a21 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a21:	55                   	push   %ebp
  800a22:	89 e5                	mov    %esp,%ebp
  800a24:	57                   	push   %edi
  800a25:	56                   	push   %esi
  800a26:	53                   	push   %ebx
  800a27:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a2d:	eb 03                	jmp    800a32 <strtol+0x11>
		s++;
  800a2f:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a32:	0f b6 01             	movzbl (%ecx),%eax
  800a35:	3c 20                	cmp    $0x20,%al
  800a37:	74 f6                	je     800a2f <strtol+0xe>
  800a39:	3c 09                	cmp    $0x9,%al
  800a3b:	74 f2                	je     800a2f <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800a3d:	3c 2b                	cmp    $0x2b,%al
  800a3f:	75 0a                	jne    800a4b <strtol+0x2a>
		s++;
  800a41:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800a44:	bf 00 00 00 00       	mov    $0x0,%edi
  800a49:	eb 11                	jmp    800a5c <strtol+0x3b>
  800a4b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800a50:	3c 2d                	cmp    $0x2d,%al
  800a52:	75 08                	jne    800a5c <strtol+0x3b>
		s++, neg = 1;
  800a54:	83 c1 01             	add    $0x1,%ecx
  800a57:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a5c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a62:	75 15                	jne    800a79 <strtol+0x58>
  800a64:	80 39 30             	cmpb   $0x30,(%ecx)
  800a67:	75 10                	jne    800a79 <strtol+0x58>
  800a69:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a6d:	75 7c                	jne    800aeb <strtol+0xca>
		s += 2, base = 16;
  800a6f:	83 c1 02             	add    $0x2,%ecx
  800a72:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a77:	eb 16                	jmp    800a8f <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800a79:	85 db                	test   %ebx,%ebx
  800a7b:	75 12                	jne    800a8f <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a7d:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800a82:	80 39 30             	cmpb   $0x30,(%ecx)
  800a85:	75 08                	jne    800a8f <strtol+0x6e>
		s++, base = 8;
  800a87:	83 c1 01             	add    $0x1,%ecx
  800a8a:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800a8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800a94:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800a97:	0f b6 11             	movzbl (%ecx),%edx
  800a9a:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a9d:	89 f3                	mov    %esi,%ebx
  800a9f:	80 fb 09             	cmp    $0x9,%bl
  800aa2:	77 08                	ja     800aac <strtol+0x8b>
			dig = *s - '0';
  800aa4:	0f be d2             	movsbl %dl,%edx
  800aa7:	83 ea 30             	sub    $0x30,%edx
  800aaa:	eb 22                	jmp    800ace <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800aac:	8d 72 9f             	lea    -0x61(%edx),%esi
  800aaf:	89 f3                	mov    %esi,%ebx
  800ab1:	80 fb 19             	cmp    $0x19,%bl
  800ab4:	77 08                	ja     800abe <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ab6:	0f be d2             	movsbl %dl,%edx
  800ab9:	83 ea 57             	sub    $0x57,%edx
  800abc:	eb 10                	jmp    800ace <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800abe:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac1:	89 f3                	mov    %esi,%ebx
  800ac3:	80 fb 19             	cmp    $0x19,%bl
  800ac6:	77 16                	ja     800ade <strtol+0xbd>
			dig = *s - 'A' + 10;
  800ac8:	0f be d2             	movsbl %dl,%edx
  800acb:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ace:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ad1:	7d 0b                	jge    800ade <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800ad3:	83 c1 01             	add    $0x1,%ecx
  800ad6:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ada:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800adc:	eb b9                	jmp    800a97 <strtol+0x76>

	if (endptr)
  800ade:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ae2:	74 0d                	je     800af1 <strtol+0xd0>
		*endptr = (char *) s;
  800ae4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ae7:	89 0e                	mov    %ecx,(%esi)
  800ae9:	eb 06                	jmp    800af1 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800aeb:	85 db                	test   %ebx,%ebx
  800aed:	74 98                	je     800a87 <strtol+0x66>
  800aef:	eb 9e                	jmp    800a8f <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800af1:	89 c2                	mov    %eax,%edx
  800af3:	f7 da                	neg    %edx
  800af5:	85 ff                	test   %edi,%edi
  800af7:	0f 45 c2             	cmovne %edx,%eax
}
  800afa:	5b                   	pop    %ebx
  800afb:	5e                   	pop    %esi
  800afc:	5f                   	pop    %edi
  800afd:	5d                   	pop    %ebp
  800afe:	c3                   	ret    

00800aff <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800aff:	55                   	push   %ebp
  800b00:	89 e5                	mov    %esp,%ebp
  800b02:	57                   	push   %edi
  800b03:	56                   	push   %esi
  800b04:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b05:	b8 00 00 00 00       	mov    $0x0,%eax
  800b0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b10:	89 c3                	mov    %eax,%ebx
  800b12:	89 c7                	mov    %eax,%edi
  800b14:	89 c6                	mov    %eax,%esi
  800b16:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800b18:	5b                   	pop    %ebx
  800b19:	5e                   	pop    %esi
  800b1a:	5f                   	pop    %edi
  800b1b:	5d                   	pop    %ebp
  800b1c:	c3                   	ret    

00800b1d <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1d:	55                   	push   %ebp
  800b1e:	89 e5                	mov    %esp,%ebp
  800b20:	57                   	push   %edi
  800b21:	56                   	push   %esi
  800b22:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b23:	ba 00 00 00 00       	mov    $0x0,%edx
  800b28:	b8 01 00 00 00       	mov    $0x1,%eax
  800b2d:	89 d1                	mov    %edx,%ecx
  800b2f:	89 d3                	mov    %edx,%ebx
  800b31:	89 d7                	mov    %edx,%edi
  800b33:	89 d6                	mov    %edx,%esi
  800b35:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800b37:	5b                   	pop    %ebx
  800b38:	5e                   	pop    %esi
  800b39:	5f                   	pop    %edi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	57                   	push   %edi
  800b40:	56                   	push   %esi
  800b41:	53                   	push   %ebx
  800b42:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b45:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b4a:	b8 03 00 00 00       	mov    $0x3,%eax
  800b4f:	8b 55 08             	mov    0x8(%ebp),%edx
  800b52:	89 cb                	mov    %ecx,%ebx
  800b54:	89 cf                	mov    %ecx,%edi
  800b56:	89 ce                	mov    %ecx,%esi
  800b58:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b5a:	85 c0                	test   %eax,%eax
  800b5c:	7e 17                	jle    800b75 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800b5e:	83 ec 0c             	sub    $0xc,%esp
  800b61:	50                   	push   %eax
  800b62:	6a 03                	push   $0x3
  800b64:	68 5f 2c 80 00       	push   $0x802c5f
  800b69:	6a 23                	push   $0x23
  800b6b:	68 7c 2c 80 00       	push   $0x802c7c
  800b70:	e8 66 f5 ff ff       	call   8000db <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800b75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b78:	5b                   	pop    %ebx
  800b79:	5e                   	pop    %esi
  800b7a:	5f                   	pop    %edi
  800b7b:	5d                   	pop    %ebp
  800b7c:	c3                   	ret    

00800b7d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	57                   	push   %edi
  800b81:	56                   	push   %esi
  800b82:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b83:	ba 00 00 00 00       	mov    $0x0,%edx
  800b88:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8d:	89 d1                	mov    %edx,%ecx
  800b8f:	89 d3                	mov    %edx,%ebx
  800b91:	89 d7                	mov    %edx,%edi
  800b93:	89 d6                	mov    %edx,%esi
  800b95:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800b97:	5b                   	pop    %ebx
  800b98:	5e                   	pop    %esi
  800b99:	5f                   	pop    %edi
  800b9a:	5d                   	pop    %ebp
  800b9b:	c3                   	ret    

00800b9c <sys_yield>:

void
sys_yield(void)
{
  800b9c:	55                   	push   %ebp
  800b9d:	89 e5                	mov    %esp,%ebp
  800b9f:	57                   	push   %edi
  800ba0:	56                   	push   %esi
  800ba1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ba2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba7:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bac:	89 d1                	mov    %edx,%ecx
  800bae:	89 d3                	mov    %edx,%ebx
  800bb0:	89 d7                	mov    %edx,%edi
  800bb2:	89 d6                	mov    %edx,%esi
  800bb4:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800bb6:	5b                   	pop    %ebx
  800bb7:	5e                   	pop    %esi
  800bb8:	5f                   	pop    %edi
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
  800bc1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bc4:	be 00 00 00 00       	mov    $0x0,%esi
  800bc9:	b8 04 00 00 00       	mov    $0x4,%eax
  800bce:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800bd1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bd4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800bd7:	89 f7                	mov    %esi,%edi
  800bd9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bdb:	85 c0                	test   %eax,%eax
  800bdd:	7e 17                	jle    800bf6 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800bdf:	83 ec 0c             	sub    $0xc,%esp
  800be2:	50                   	push   %eax
  800be3:	6a 04                	push   $0x4
  800be5:	68 5f 2c 80 00       	push   $0x802c5f
  800bea:	6a 23                	push   $0x23
  800bec:	68 7c 2c 80 00       	push   $0x802c7c
  800bf1:	e8 e5 f4 ff ff       	call   8000db <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800bf6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bf9:	5b                   	pop    %ebx
  800bfa:	5e                   	pop    %esi
  800bfb:	5f                   	pop    %edi
  800bfc:	5d                   	pop    %ebp
  800bfd:	c3                   	ret    

00800bfe <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800bfe:	55                   	push   %ebp
  800bff:	89 e5                	mov    %esp,%ebp
  800c01:	57                   	push   %edi
  800c02:	56                   	push   %esi
  800c03:	53                   	push   %ebx
  800c04:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c07:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c0f:	8b 55 08             	mov    0x8(%ebp),%edx
  800c12:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800c15:	8b 7d 14             	mov    0x14(%ebp),%edi
  800c18:	8b 75 18             	mov    0x18(%ebp),%esi
  800c1b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c1d:	85 c0                	test   %eax,%eax
  800c1f:	7e 17                	jle    800c38 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c21:	83 ec 0c             	sub    $0xc,%esp
  800c24:	50                   	push   %eax
  800c25:	6a 05                	push   $0x5
  800c27:	68 5f 2c 80 00       	push   $0x802c5f
  800c2c:	6a 23                	push   $0x23
  800c2e:	68 7c 2c 80 00       	push   $0x802c7c
  800c33:	e8 a3 f4 ff ff       	call   8000db <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800c38:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3b:	5b                   	pop    %ebx
  800c3c:	5e                   	pop    %esi
  800c3d:	5f                   	pop    %edi
  800c3e:	5d                   	pop    %ebp
  800c3f:	c3                   	ret    

00800c40 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c40:	55                   	push   %ebp
  800c41:	89 e5                	mov    %esp,%ebp
  800c43:	57                   	push   %edi
  800c44:	56                   	push   %esi
  800c45:	53                   	push   %ebx
  800c46:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c49:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c4e:	b8 06 00 00 00       	mov    $0x6,%eax
  800c53:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c56:	8b 55 08             	mov    0x8(%ebp),%edx
  800c59:	89 df                	mov    %ebx,%edi
  800c5b:	89 de                	mov    %ebx,%esi
  800c5d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c5f:	85 c0                	test   %eax,%eax
  800c61:	7e 17                	jle    800c7a <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c63:	83 ec 0c             	sub    $0xc,%esp
  800c66:	50                   	push   %eax
  800c67:	6a 06                	push   $0x6
  800c69:	68 5f 2c 80 00       	push   $0x802c5f
  800c6e:	6a 23                	push   $0x23
  800c70:	68 7c 2c 80 00       	push   $0x802c7c
  800c75:	e8 61 f4 ff ff       	call   8000db <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c7d:	5b                   	pop    %ebx
  800c7e:	5e                   	pop    %esi
  800c7f:	5f                   	pop    %edi
  800c80:	5d                   	pop    %ebp
  800c81:	c3                   	ret    

00800c82 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	57                   	push   %edi
  800c86:	56                   	push   %esi
  800c87:	53                   	push   %ebx
  800c88:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c90:	b8 08 00 00 00       	mov    $0x8,%eax
  800c95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c98:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9b:	89 df                	mov    %ebx,%edi
  800c9d:	89 de                	mov    %ebx,%esi
  800c9f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ca1:	85 c0                	test   %eax,%eax
  800ca3:	7e 17                	jle    800cbc <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ca5:	83 ec 0c             	sub    $0xc,%esp
  800ca8:	50                   	push   %eax
  800ca9:	6a 08                	push   $0x8
  800cab:	68 5f 2c 80 00       	push   $0x802c5f
  800cb0:	6a 23                	push   $0x23
  800cb2:	68 7c 2c 80 00       	push   $0x802c7c
  800cb7:	e8 1f f4 ff ff       	call   8000db <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	57                   	push   %edi
  800cc8:	56                   	push   %esi
  800cc9:	53                   	push   %ebx
  800cca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd2:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cda:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdd:	89 df                	mov    %ebx,%edi
  800cdf:	89 de                	mov    %ebx,%esi
  800ce1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ce3:	85 c0                	test   %eax,%eax
  800ce5:	7e 17                	jle    800cfe <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ce7:	83 ec 0c             	sub    $0xc,%esp
  800cea:	50                   	push   %eax
  800ceb:	6a 09                	push   $0x9
  800ced:	68 5f 2c 80 00       	push   $0x802c5f
  800cf2:	6a 23                	push   $0x23
  800cf4:	68 7c 2c 80 00       	push   $0x802c7c
  800cf9:	e8 dd f3 ff ff       	call   8000db <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800cfe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d01:	5b                   	pop    %ebx
  800d02:	5e                   	pop    %esi
  800d03:	5f                   	pop    %edi
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	57                   	push   %edi
  800d0a:	56                   	push   %esi
  800d0b:	53                   	push   %ebx
  800d0c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d14:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d19:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1c:	8b 55 08             	mov    0x8(%ebp),%edx
  800d1f:	89 df                	mov    %ebx,%edi
  800d21:	89 de                	mov    %ebx,%esi
  800d23:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d25:	85 c0                	test   %eax,%eax
  800d27:	7e 17                	jle    800d40 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d29:	83 ec 0c             	sub    $0xc,%esp
  800d2c:	50                   	push   %eax
  800d2d:	6a 0a                	push   $0xa
  800d2f:	68 5f 2c 80 00       	push   $0x802c5f
  800d34:	6a 23                	push   $0x23
  800d36:	68 7c 2c 80 00       	push   $0x802c7c
  800d3b:	e8 9b f3 ff ff       	call   8000db <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    

00800d48 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	57                   	push   %edi
  800d4c:	56                   	push   %esi
  800d4d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d4e:	be 00 00 00 00       	mov    $0x0,%esi
  800d53:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d58:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d5b:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d61:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d64:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d66:	5b                   	pop    %ebx
  800d67:	5e                   	pop    %esi
  800d68:	5f                   	pop    %edi
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	57                   	push   %edi
  800d6f:	56                   	push   %esi
  800d70:	53                   	push   %ebx
  800d71:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d74:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d79:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d81:	89 cb                	mov    %ecx,%ebx
  800d83:	89 cf                	mov    %ecx,%edi
  800d85:	89 ce                	mov    %ecx,%esi
  800d87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	7e 17                	jle    800da4 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8d:	83 ec 0c             	sub    $0xc,%esp
  800d90:	50                   	push   %eax
  800d91:	6a 0d                	push   $0xd
  800d93:	68 5f 2c 80 00       	push   $0x802c5f
  800d98:	6a 23                	push   $0x23
  800d9a:	68 7c 2c 80 00       	push   $0x802c7c
  800d9f:	e8 37 f3 ff ff       	call   8000db <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800da4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800da7:	5b                   	pop    %ebx
  800da8:	5e                   	pop    %esi
  800da9:	5f                   	pop    %edi
  800daa:	5d                   	pop    %ebp
  800dab:	c3                   	ret    

00800dac <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800dac:	55                   	push   %ebp
  800dad:	89 e5                	mov    %esp,%ebp
  800daf:	57                   	push   %edi
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db2:	ba 00 00 00 00       	mov    $0x0,%edx
  800db7:	b8 0e 00 00 00       	mov    $0xe,%eax
  800dbc:	89 d1                	mov    %edx,%ecx
  800dbe:	89 d3                	mov    %edx,%ebx
  800dc0:	89 d7                	mov    %edx,%edi
  800dc2:	89 d6                	mov    %edx,%esi
  800dc4:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  800dc6:	5b                   	pop    %ebx
  800dc7:	5e                   	pop    %esi
  800dc8:	5f                   	pop    %edi
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800dcb:	55                   	push   %ebp
  800dcc:	89 e5                	mov    %esp,%ebp
  800dce:	57                   	push   %edi
  800dcf:	56                   	push   %esi
  800dd0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dd6:	b8 10 00 00 00       	mov    $0x10,%eax
  800ddb:	8b 55 08             	mov    0x8(%ebp),%edx
  800dde:	89 cb                	mov    %ecx,%ebx
  800de0:	89 cf                	mov    %ecx,%edi
  800de2:	89 ce                	mov    %ecx,%esi
  800de4:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  800de6:	5b                   	pop    %ebx
  800de7:	5e                   	pop    %esi
  800de8:	5f                   	pop    %edi
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800deb:	55                   	push   %ebp
  800dec:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
  800df1:	05 00 00 00 30       	add    $0x30000000,%eax
  800df6:	c1 e8 0c             	shr    $0xc,%eax
}
  800df9:	5d                   	pop    %ebp
  800dfa:	c3                   	ret    

00800dfb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800dfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800e01:	05 00 00 00 30       	add    $0x30000000,%eax
  800e06:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800e0b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e10:	5d                   	pop    %ebp
  800e11:	c3                   	ret    

00800e12 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e12:	55                   	push   %ebp
  800e13:	89 e5                	mov    %esp,%ebp
  800e15:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e18:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e1d:	89 c2                	mov    %eax,%edx
  800e1f:	c1 ea 16             	shr    $0x16,%edx
  800e22:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e29:	f6 c2 01             	test   $0x1,%dl
  800e2c:	74 11                	je     800e3f <fd_alloc+0x2d>
  800e2e:	89 c2                	mov    %eax,%edx
  800e30:	c1 ea 0c             	shr    $0xc,%edx
  800e33:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e3a:	f6 c2 01             	test   $0x1,%dl
  800e3d:	75 09                	jne    800e48 <fd_alloc+0x36>
			*fd_store = fd;
  800e3f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e41:	b8 00 00 00 00       	mov    $0x0,%eax
  800e46:	eb 17                	jmp    800e5f <fd_alloc+0x4d>
  800e48:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  800e4d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e52:	75 c9                	jne    800e1d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e54:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800e5a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e67:	83 f8 1f             	cmp    $0x1f,%eax
  800e6a:	77 36                	ja     800ea2 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e6c:	c1 e0 0c             	shl    $0xc,%eax
  800e6f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e74:	89 c2                	mov    %eax,%edx
  800e76:	c1 ea 16             	shr    $0x16,%edx
  800e79:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e80:	f6 c2 01             	test   $0x1,%dl
  800e83:	74 24                	je     800ea9 <fd_lookup+0x48>
  800e85:	89 c2                	mov    %eax,%edx
  800e87:	c1 ea 0c             	shr    $0xc,%edx
  800e8a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e91:	f6 c2 01             	test   $0x1,%dl
  800e94:	74 1a                	je     800eb0 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e96:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e99:	89 02                	mov    %eax,(%edx)
	return 0;
  800e9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800ea0:	eb 13                	jmp    800eb5 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ea2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea7:	eb 0c                	jmp    800eb5 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800ea9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eae:	eb 05                	jmp    800eb5 <fd_lookup+0x54>
  800eb0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800eb5:	5d                   	pop    %ebp
  800eb6:	c3                   	ret    

00800eb7 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eb7:	55                   	push   %ebp
  800eb8:	89 e5                	mov    %esp,%ebp
  800eba:	83 ec 08             	sub    $0x8,%esp
  800ebd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec0:	ba 08 2d 80 00       	mov    $0x802d08,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ec5:	eb 13                	jmp    800eda <dev_lookup+0x23>
  800ec7:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800eca:	39 08                	cmp    %ecx,(%eax)
  800ecc:	75 0c                	jne    800eda <dev_lookup+0x23>
			*dev = devtab[i];
  800ece:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ed1:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ed3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed8:	eb 2e                	jmp    800f08 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800eda:	8b 02                	mov    (%edx),%eax
  800edc:	85 c0                	test   %eax,%eax
  800ede:	75 e7                	jne    800ec7 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ee0:	a1 08 40 80 00       	mov    0x804008,%eax
  800ee5:	8b 40 48             	mov    0x48(%eax),%eax
  800ee8:	83 ec 04             	sub    $0x4,%esp
  800eeb:	51                   	push   %ecx
  800eec:	50                   	push   %eax
  800eed:	68 8c 2c 80 00       	push   $0x802c8c
  800ef2:	e8 bd f2 ff ff       	call   8001b4 <cprintf>
	*dev = 0;
  800ef7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800efa:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800f00:	83 c4 10             	add    $0x10,%esp
  800f03:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f08:	c9                   	leave  
  800f09:	c3                   	ret    

00800f0a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800f0a:	55                   	push   %ebp
  800f0b:	89 e5                	mov    %esp,%ebp
  800f0d:	56                   	push   %esi
  800f0e:	53                   	push   %ebx
  800f0f:	83 ec 10             	sub    $0x10,%esp
  800f12:	8b 75 08             	mov    0x8(%ebp),%esi
  800f15:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f18:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f1b:	50                   	push   %eax
  800f1c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800f22:	c1 e8 0c             	shr    $0xc,%eax
  800f25:	50                   	push   %eax
  800f26:	e8 36 ff ff ff       	call   800e61 <fd_lookup>
  800f2b:	83 c4 08             	add    $0x8,%esp
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	78 05                	js     800f37 <fd_close+0x2d>
	    || fd != fd2)
  800f32:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800f35:	74 0c                	je     800f43 <fd_close+0x39>
		return (must_exist ? r : 0);
  800f37:	84 db                	test   %bl,%bl
  800f39:	ba 00 00 00 00       	mov    $0x0,%edx
  800f3e:	0f 44 c2             	cmove  %edx,%eax
  800f41:	eb 41                	jmp    800f84 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f43:	83 ec 08             	sub    $0x8,%esp
  800f46:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800f49:	50                   	push   %eax
  800f4a:	ff 36                	pushl  (%esi)
  800f4c:	e8 66 ff ff ff       	call   800eb7 <dev_lookup>
  800f51:	89 c3                	mov    %eax,%ebx
  800f53:	83 c4 10             	add    $0x10,%esp
  800f56:	85 c0                	test   %eax,%eax
  800f58:	78 1a                	js     800f74 <fd_close+0x6a>
		if (dev->dev_close)
  800f5a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f5d:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800f60:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  800f65:	85 c0                	test   %eax,%eax
  800f67:	74 0b                	je     800f74 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800f69:	83 ec 0c             	sub    $0xc,%esp
  800f6c:	56                   	push   %esi
  800f6d:	ff d0                	call   *%eax
  800f6f:	89 c3                	mov    %eax,%ebx
  800f71:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  800f74:	83 ec 08             	sub    $0x8,%esp
  800f77:	56                   	push   %esi
  800f78:	6a 00                	push   $0x0
  800f7a:	e8 c1 fc ff ff       	call   800c40 <sys_page_unmap>
	return r;
  800f7f:	83 c4 10             	add    $0x10,%esp
  800f82:	89 d8                	mov    %ebx,%eax
}
  800f84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f87:	5b                   	pop    %ebx
  800f88:	5e                   	pop    %esi
  800f89:	5d                   	pop    %ebp
  800f8a:	c3                   	ret    

00800f8b <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800f8b:	55                   	push   %ebp
  800f8c:	89 e5                	mov    %esp,%ebp
  800f8e:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f91:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f94:	50                   	push   %eax
  800f95:	ff 75 08             	pushl  0x8(%ebp)
  800f98:	e8 c4 fe ff ff       	call   800e61 <fd_lookup>
  800f9d:	83 c4 08             	add    $0x8,%esp
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	78 10                	js     800fb4 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800fa4:	83 ec 08             	sub    $0x8,%esp
  800fa7:	6a 01                	push   $0x1
  800fa9:	ff 75 f4             	pushl  -0xc(%ebp)
  800fac:	e8 59 ff ff ff       	call   800f0a <fd_close>
  800fb1:	83 c4 10             	add    $0x10,%esp
}
  800fb4:	c9                   	leave  
  800fb5:	c3                   	ret    

00800fb6 <close_all>:

void
close_all(void)
{
  800fb6:	55                   	push   %ebp
  800fb7:	89 e5                	mov    %esp,%ebp
  800fb9:	53                   	push   %ebx
  800fba:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fbd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fc2:	83 ec 0c             	sub    $0xc,%esp
  800fc5:	53                   	push   %ebx
  800fc6:	e8 c0 ff ff ff       	call   800f8b <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800fcb:	83 c3 01             	add    $0x1,%ebx
  800fce:	83 c4 10             	add    $0x10,%esp
  800fd1:	83 fb 20             	cmp    $0x20,%ebx
  800fd4:	75 ec                	jne    800fc2 <close_all+0xc>
		close(i);
}
  800fd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd9:	c9                   	leave  
  800fda:	c3                   	ret    

00800fdb <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	57                   	push   %edi
  800fdf:	56                   	push   %esi
  800fe0:	53                   	push   %ebx
  800fe1:	83 ec 2c             	sub    $0x2c,%esp
  800fe4:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fe7:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fea:	50                   	push   %eax
  800feb:	ff 75 08             	pushl  0x8(%ebp)
  800fee:	e8 6e fe ff ff       	call   800e61 <fd_lookup>
  800ff3:	83 c4 08             	add    $0x8,%esp
  800ff6:	85 c0                	test   %eax,%eax
  800ff8:	0f 88 c1 00 00 00    	js     8010bf <dup+0xe4>
		return r;
	close(newfdnum);
  800ffe:	83 ec 0c             	sub    $0xc,%esp
  801001:	56                   	push   %esi
  801002:	e8 84 ff ff ff       	call   800f8b <close>

	newfd = INDEX2FD(newfdnum);
  801007:	89 f3                	mov    %esi,%ebx
  801009:	c1 e3 0c             	shl    $0xc,%ebx
  80100c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  801012:	83 c4 04             	add    $0x4,%esp
  801015:	ff 75 e4             	pushl  -0x1c(%ebp)
  801018:	e8 de fd ff ff       	call   800dfb <fd2data>
  80101d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80101f:	89 1c 24             	mov    %ebx,(%esp)
  801022:	e8 d4 fd ff ff       	call   800dfb <fd2data>
  801027:	83 c4 10             	add    $0x10,%esp
  80102a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80102d:	89 f8                	mov    %edi,%eax
  80102f:	c1 e8 16             	shr    $0x16,%eax
  801032:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801039:	a8 01                	test   $0x1,%al
  80103b:	74 37                	je     801074 <dup+0x99>
  80103d:	89 f8                	mov    %edi,%eax
  80103f:	c1 e8 0c             	shr    $0xc,%eax
  801042:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801049:	f6 c2 01             	test   $0x1,%dl
  80104c:	74 26                	je     801074 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80104e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801055:	83 ec 0c             	sub    $0xc,%esp
  801058:	25 07 0e 00 00       	and    $0xe07,%eax
  80105d:	50                   	push   %eax
  80105e:	ff 75 d4             	pushl  -0x2c(%ebp)
  801061:	6a 00                	push   $0x0
  801063:	57                   	push   %edi
  801064:	6a 00                	push   $0x0
  801066:	e8 93 fb ff ff       	call   800bfe <sys_page_map>
  80106b:	89 c7                	mov    %eax,%edi
  80106d:	83 c4 20             	add    $0x20,%esp
  801070:	85 c0                	test   %eax,%eax
  801072:	78 2e                	js     8010a2 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801074:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801077:	89 d0                	mov    %edx,%eax
  801079:	c1 e8 0c             	shr    $0xc,%eax
  80107c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801083:	83 ec 0c             	sub    $0xc,%esp
  801086:	25 07 0e 00 00       	and    $0xe07,%eax
  80108b:	50                   	push   %eax
  80108c:	53                   	push   %ebx
  80108d:	6a 00                	push   $0x0
  80108f:	52                   	push   %edx
  801090:	6a 00                	push   $0x0
  801092:	e8 67 fb ff ff       	call   800bfe <sys_page_map>
  801097:	89 c7                	mov    %eax,%edi
  801099:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80109c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80109e:	85 ff                	test   %edi,%edi
  8010a0:	79 1d                	jns    8010bf <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  8010a2:	83 ec 08             	sub    $0x8,%esp
  8010a5:	53                   	push   %ebx
  8010a6:	6a 00                	push   $0x0
  8010a8:	e8 93 fb ff ff       	call   800c40 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010ad:	83 c4 08             	add    $0x8,%esp
  8010b0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8010b3:	6a 00                	push   $0x0
  8010b5:	e8 86 fb ff ff       	call   800c40 <sys_page_unmap>
	return r;
  8010ba:	83 c4 10             	add    $0x10,%esp
  8010bd:	89 f8                	mov    %edi,%eax
}
  8010bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c2:	5b                   	pop    %ebx
  8010c3:	5e                   	pop    %esi
  8010c4:	5f                   	pop    %edi
  8010c5:	5d                   	pop    %ebp
  8010c6:	c3                   	ret    

008010c7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	53                   	push   %ebx
  8010cb:	83 ec 14             	sub    $0x14,%esp
  8010ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d4:	50                   	push   %eax
  8010d5:	53                   	push   %ebx
  8010d6:	e8 86 fd ff ff       	call   800e61 <fd_lookup>
  8010db:	83 c4 08             	add    $0x8,%esp
  8010de:	89 c2                	mov    %eax,%edx
  8010e0:	85 c0                	test   %eax,%eax
  8010e2:	78 6d                	js     801151 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e4:	83 ec 08             	sub    $0x8,%esp
  8010e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010ea:	50                   	push   %eax
  8010eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ee:	ff 30                	pushl  (%eax)
  8010f0:	e8 c2 fd ff ff       	call   800eb7 <dev_lookup>
  8010f5:	83 c4 10             	add    $0x10,%esp
  8010f8:	85 c0                	test   %eax,%eax
  8010fa:	78 4c                	js     801148 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010fc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010ff:	8b 42 08             	mov    0x8(%edx),%eax
  801102:	83 e0 03             	and    $0x3,%eax
  801105:	83 f8 01             	cmp    $0x1,%eax
  801108:	75 21                	jne    80112b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80110a:	a1 08 40 80 00       	mov    0x804008,%eax
  80110f:	8b 40 48             	mov    0x48(%eax),%eax
  801112:	83 ec 04             	sub    $0x4,%esp
  801115:	53                   	push   %ebx
  801116:	50                   	push   %eax
  801117:	68 cd 2c 80 00       	push   $0x802ccd
  80111c:	e8 93 f0 ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  801121:	83 c4 10             	add    $0x10,%esp
  801124:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801129:	eb 26                	jmp    801151 <read+0x8a>
	}
	if (!dev->dev_read)
  80112b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112e:	8b 40 08             	mov    0x8(%eax),%eax
  801131:	85 c0                	test   %eax,%eax
  801133:	74 17                	je     80114c <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801135:	83 ec 04             	sub    $0x4,%esp
  801138:	ff 75 10             	pushl  0x10(%ebp)
  80113b:	ff 75 0c             	pushl  0xc(%ebp)
  80113e:	52                   	push   %edx
  80113f:	ff d0                	call   *%eax
  801141:	89 c2                	mov    %eax,%edx
  801143:	83 c4 10             	add    $0x10,%esp
  801146:	eb 09                	jmp    801151 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801148:	89 c2                	mov    %eax,%edx
  80114a:	eb 05                	jmp    801151 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  80114c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  801151:	89 d0                	mov    %edx,%eax
  801153:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801156:	c9                   	leave  
  801157:	c3                   	ret    

00801158 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801158:	55                   	push   %ebp
  801159:	89 e5                	mov    %esp,%ebp
  80115b:	57                   	push   %edi
  80115c:	56                   	push   %esi
  80115d:	53                   	push   %ebx
  80115e:	83 ec 0c             	sub    $0xc,%esp
  801161:	8b 7d 08             	mov    0x8(%ebp),%edi
  801164:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801167:	bb 00 00 00 00       	mov    $0x0,%ebx
  80116c:	eb 21                	jmp    80118f <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80116e:	83 ec 04             	sub    $0x4,%esp
  801171:	89 f0                	mov    %esi,%eax
  801173:	29 d8                	sub    %ebx,%eax
  801175:	50                   	push   %eax
  801176:	89 d8                	mov    %ebx,%eax
  801178:	03 45 0c             	add    0xc(%ebp),%eax
  80117b:	50                   	push   %eax
  80117c:	57                   	push   %edi
  80117d:	e8 45 ff ff ff       	call   8010c7 <read>
		if (m < 0)
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	85 c0                	test   %eax,%eax
  801187:	78 10                	js     801199 <readn+0x41>
			return m;
		if (m == 0)
  801189:	85 c0                	test   %eax,%eax
  80118b:	74 0a                	je     801197 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80118d:	01 c3                	add    %eax,%ebx
  80118f:	39 f3                	cmp    %esi,%ebx
  801191:	72 db                	jb     80116e <readn+0x16>
  801193:	89 d8                	mov    %ebx,%eax
  801195:	eb 02                	jmp    801199 <readn+0x41>
  801197:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119c:	5b                   	pop    %ebx
  80119d:	5e                   	pop    %esi
  80119e:	5f                   	pop    %edi
  80119f:	5d                   	pop    %ebp
  8011a0:	c3                   	ret    

008011a1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011a1:	55                   	push   %ebp
  8011a2:	89 e5                	mov    %esp,%ebp
  8011a4:	53                   	push   %ebx
  8011a5:	83 ec 14             	sub    $0x14,%esp
  8011a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ae:	50                   	push   %eax
  8011af:	53                   	push   %ebx
  8011b0:	e8 ac fc ff ff       	call   800e61 <fd_lookup>
  8011b5:	83 c4 08             	add    $0x8,%esp
  8011b8:	89 c2                	mov    %eax,%edx
  8011ba:	85 c0                	test   %eax,%eax
  8011bc:	78 68                	js     801226 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011be:	83 ec 08             	sub    $0x8,%esp
  8011c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c4:	50                   	push   %eax
  8011c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c8:	ff 30                	pushl  (%eax)
  8011ca:	e8 e8 fc ff ff       	call   800eb7 <dev_lookup>
  8011cf:	83 c4 10             	add    $0x10,%esp
  8011d2:	85 c0                	test   %eax,%eax
  8011d4:	78 47                	js     80121d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011dd:	75 21                	jne    801200 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011df:	a1 08 40 80 00       	mov    0x804008,%eax
  8011e4:	8b 40 48             	mov    0x48(%eax),%eax
  8011e7:	83 ec 04             	sub    $0x4,%esp
  8011ea:	53                   	push   %ebx
  8011eb:	50                   	push   %eax
  8011ec:	68 e9 2c 80 00       	push   $0x802ce9
  8011f1:	e8 be ef ff ff       	call   8001b4 <cprintf>
		return -E_INVAL;
  8011f6:	83 c4 10             	add    $0x10,%esp
  8011f9:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8011fe:	eb 26                	jmp    801226 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801200:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801203:	8b 52 0c             	mov    0xc(%edx),%edx
  801206:	85 d2                	test   %edx,%edx
  801208:	74 17                	je     801221 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80120a:	83 ec 04             	sub    $0x4,%esp
  80120d:	ff 75 10             	pushl  0x10(%ebp)
  801210:	ff 75 0c             	pushl  0xc(%ebp)
  801213:	50                   	push   %eax
  801214:	ff d2                	call   *%edx
  801216:	89 c2                	mov    %eax,%edx
  801218:	83 c4 10             	add    $0x10,%esp
  80121b:	eb 09                	jmp    801226 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80121d:	89 c2                	mov    %eax,%edx
  80121f:	eb 05                	jmp    801226 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  801221:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  801226:	89 d0                	mov    %edx,%eax
  801228:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80122b:	c9                   	leave  
  80122c:	c3                   	ret    

0080122d <seek>:

int
seek(int fdnum, off_t offset)
{
  80122d:	55                   	push   %ebp
  80122e:	89 e5                	mov    %esp,%ebp
  801230:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801233:	8d 45 fc             	lea    -0x4(%ebp),%eax
  801236:	50                   	push   %eax
  801237:	ff 75 08             	pushl  0x8(%ebp)
  80123a:	e8 22 fc ff ff       	call   800e61 <fd_lookup>
  80123f:	83 c4 08             	add    $0x8,%esp
  801242:	85 c0                	test   %eax,%eax
  801244:	78 0e                	js     801254 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  801246:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801249:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124c:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80124f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801254:	c9                   	leave  
  801255:	c3                   	ret    

00801256 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801256:	55                   	push   %ebp
  801257:	89 e5                	mov    %esp,%ebp
  801259:	53                   	push   %ebx
  80125a:	83 ec 14             	sub    $0x14,%esp
  80125d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801260:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801263:	50                   	push   %eax
  801264:	53                   	push   %ebx
  801265:	e8 f7 fb ff ff       	call   800e61 <fd_lookup>
  80126a:	83 c4 08             	add    $0x8,%esp
  80126d:	89 c2                	mov    %eax,%edx
  80126f:	85 c0                	test   %eax,%eax
  801271:	78 65                	js     8012d8 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801273:	83 ec 08             	sub    $0x8,%esp
  801276:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801279:	50                   	push   %eax
  80127a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80127d:	ff 30                	pushl  (%eax)
  80127f:	e8 33 fc ff ff       	call   800eb7 <dev_lookup>
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	85 c0                	test   %eax,%eax
  801289:	78 44                	js     8012cf <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80128b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80128e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801292:	75 21                	jne    8012b5 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801294:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801299:	8b 40 48             	mov    0x48(%eax),%eax
  80129c:	83 ec 04             	sub    $0x4,%esp
  80129f:	53                   	push   %ebx
  8012a0:	50                   	push   %eax
  8012a1:	68 ac 2c 80 00       	push   $0x802cac
  8012a6:	e8 09 ef ff ff       	call   8001b4 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  8012ab:	83 c4 10             	add    $0x10,%esp
  8012ae:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8012b3:	eb 23                	jmp    8012d8 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  8012b5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012b8:	8b 52 18             	mov    0x18(%edx),%edx
  8012bb:	85 d2                	test   %edx,%edx
  8012bd:	74 14                	je     8012d3 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012bf:	83 ec 08             	sub    $0x8,%esp
  8012c2:	ff 75 0c             	pushl  0xc(%ebp)
  8012c5:	50                   	push   %eax
  8012c6:	ff d2                	call   *%edx
  8012c8:	89 c2                	mov    %eax,%edx
  8012ca:	83 c4 10             	add    $0x10,%esp
  8012cd:	eb 09                	jmp    8012d8 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012cf:	89 c2                	mov    %eax,%edx
  8012d1:	eb 05                	jmp    8012d8 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  8012d3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  8012d8:	89 d0                	mov    %edx,%eax
  8012da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012dd:	c9                   	leave  
  8012de:	c3                   	ret    

008012df <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012df:	55                   	push   %ebp
  8012e0:	89 e5                	mov    %esp,%ebp
  8012e2:	53                   	push   %ebx
  8012e3:	83 ec 14             	sub    $0x14,%esp
  8012e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012ec:	50                   	push   %eax
  8012ed:	ff 75 08             	pushl  0x8(%ebp)
  8012f0:	e8 6c fb ff ff       	call   800e61 <fd_lookup>
  8012f5:	83 c4 08             	add    $0x8,%esp
  8012f8:	89 c2                	mov    %eax,%edx
  8012fa:	85 c0                	test   %eax,%eax
  8012fc:	78 58                	js     801356 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012fe:	83 ec 08             	sub    $0x8,%esp
  801301:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801304:	50                   	push   %eax
  801305:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801308:	ff 30                	pushl  (%eax)
  80130a:	e8 a8 fb ff ff       	call   800eb7 <dev_lookup>
  80130f:	83 c4 10             	add    $0x10,%esp
  801312:	85 c0                	test   %eax,%eax
  801314:	78 37                	js     80134d <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  801316:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801319:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80131d:	74 32                	je     801351 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80131f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801322:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801329:	00 00 00 
	stat->st_isdir = 0;
  80132c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801333:	00 00 00 
	stat->st_dev = dev;
  801336:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80133c:	83 ec 08             	sub    $0x8,%esp
  80133f:	53                   	push   %ebx
  801340:	ff 75 f0             	pushl  -0x10(%ebp)
  801343:	ff 50 14             	call   *0x14(%eax)
  801346:	89 c2                	mov    %eax,%edx
  801348:	83 c4 10             	add    $0x10,%esp
  80134b:	eb 09                	jmp    801356 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80134d:	89 c2                	mov    %eax,%edx
  80134f:	eb 05                	jmp    801356 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  801351:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  801356:	89 d0                	mov    %edx,%eax
  801358:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135b:	c9                   	leave  
  80135c:	c3                   	ret    

0080135d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80135d:	55                   	push   %ebp
  80135e:	89 e5                	mov    %esp,%ebp
  801360:	56                   	push   %esi
  801361:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801362:	83 ec 08             	sub    $0x8,%esp
  801365:	6a 00                	push   $0x0
  801367:	ff 75 08             	pushl  0x8(%ebp)
  80136a:	e8 e3 01 00 00       	call   801552 <open>
  80136f:	89 c3                	mov    %eax,%ebx
  801371:	83 c4 10             	add    $0x10,%esp
  801374:	85 c0                	test   %eax,%eax
  801376:	78 1b                	js     801393 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801378:	83 ec 08             	sub    $0x8,%esp
  80137b:	ff 75 0c             	pushl  0xc(%ebp)
  80137e:	50                   	push   %eax
  80137f:	e8 5b ff ff ff       	call   8012df <fstat>
  801384:	89 c6                	mov    %eax,%esi
	close(fd);
  801386:	89 1c 24             	mov    %ebx,(%esp)
  801389:	e8 fd fb ff ff       	call   800f8b <close>
	return r;
  80138e:	83 c4 10             	add    $0x10,%esp
  801391:	89 f0                	mov    %esi,%eax
}
  801393:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801396:	5b                   	pop    %ebx
  801397:	5e                   	pop    %esi
  801398:	5d                   	pop    %ebp
  801399:	c3                   	ret    

0080139a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80139a:	55                   	push   %ebp
  80139b:	89 e5                	mov    %esp,%ebp
  80139d:	56                   	push   %esi
  80139e:	53                   	push   %ebx
  80139f:	89 c6                	mov    %eax,%esi
  8013a1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013a3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013aa:	75 12                	jne    8013be <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013ac:	83 ec 0c             	sub    $0xc,%esp
  8013af:	6a 01                	push   $0x1
  8013b1:	e8 1e 12 00 00       	call   8025d4 <ipc_find_env>
  8013b6:	a3 00 40 80 00       	mov    %eax,0x804000
  8013bb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013be:	6a 07                	push   $0x7
  8013c0:	68 00 50 80 00       	push   $0x805000
  8013c5:	56                   	push   %esi
  8013c6:	ff 35 00 40 80 00    	pushl  0x804000
  8013cc:	e8 af 11 00 00       	call   802580 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013d1:	83 c4 0c             	add    $0xc,%esp
  8013d4:	6a 00                	push   $0x0
  8013d6:	53                   	push   %ebx
  8013d7:	6a 00                	push   $0x0
  8013d9:	e8 39 11 00 00       	call   802517 <ipc_recv>
}
  8013de:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013e1:	5b                   	pop    %ebx
  8013e2:	5e                   	pop    %esi
  8013e3:	5d                   	pop    %ebp
  8013e4:	c3                   	ret    

008013e5 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013e5:	55                   	push   %ebp
  8013e6:	89 e5                	mov    %esp,%ebp
  8013e8:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ee:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f1:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f9:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801403:	b8 02 00 00 00       	mov    $0x2,%eax
  801408:	e8 8d ff ff ff       	call   80139a <fsipc>
}
  80140d:	c9                   	leave  
  80140e:	c3                   	ret    

0080140f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80140f:	55                   	push   %ebp
  801410:	89 e5                	mov    %esp,%ebp
  801412:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801415:	8b 45 08             	mov    0x8(%ebp),%eax
  801418:	8b 40 0c             	mov    0xc(%eax),%eax
  80141b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801420:	ba 00 00 00 00       	mov    $0x0,%edx
  801425:	b8 06 00 00 00       	mov    $0x6,%eax
  80142a:	e8 6b ff ff ff       	call   80139a <fsipc>
}
  80142f:	c9                   	leave  
  801430:	c3                   	ret    

00801431 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801431:	55                   	push   %ebp
  801432:	89 e5                	mov    %esp,%ebp
  801434:	53                   	push   %ebx
  801435:	83 ec 04             	sub    $0x4,%esp
  801438:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80143b:	8b 45 08             	mov    0x8(%ebp),%eax
  80143e:	8b 40 0c             	mov    0xc(%eax),%eax
  801441:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801446:	ba 00 00 00 00       	mov    $0x0,%edx
  80144b:	b8 05 00 00 00       	mov    $0x5,%eax
  801450:	e8 45 ff ff ff       	call   80139a <fsipc>
  801455:	85 c0                	test   %eax,%eax
  801457:	78 2c                	js     801485 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801459:	83 ec 08             	sub    $0x8,%esp
  80145c:	68 00 50 80 00       	push   $0x805000
  801461:	53                   	push   %ebx
  801462:	e8 51 f3 ff ff       	call   8007b8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801467:	a1 80 50 80 00       	mov    0x805080,%eax
  80146c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801472:	a1 84 50 80 00       	mov    0x805084,%eax
  801477:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80147d:	83 c4 10             	add    $0x10,%esp
  801480:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801485:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801488:	c9                   	leave  
  801489:	c3                   	ret    

0080148a <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	83 ec 0c             	sub    $0xc,%esp
  801490:	8b 45 10             	mov    0x10(%ebp),%eax
  801493:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801498:	ba f8 0f 00 00       	mov    $0xff8,%edx
  80149d:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8014a3:	8b 52 0c             	mov    0xc(%edx),%edx
  8014a6:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014ac:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  8014b1:	50                   	push   %eax
  8014b2:	ff 75 0c             	pushl  0xc(%ebp)
  8014b5:	68 08 50 80 00       	push   $0x805008
  8014ba:	e8 8b f4 ff ff       	call   80094a <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c4:	b8 04 00 00 00       	mov    $0x4,%eax
  8014c9:	e8 cc fe ff ff       	call   80139a <fsipc>
	//panic("devfile_write not implemented");
}
  8014ce:	c9                   	leave  
  8014cf:	c3                   	ret    

008014d0 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  8014d0:	55                   	push   %ebp
  8014d1:	89 e5                	mov    %esp,%ebp
  8014d3:	56                   	push   %esi
  8014d4:	53                   	push   %ebx
  8014d5:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8014db:	8b 40 0c             	mov    0xc(%eax),%eax
  8014de:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014e3:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ee:	b8 03 00 00 00       	mov    $0x3,%eax
  8014f3:	e8 a2 fe ff ff       	call   80139a <fsipc>
  8014f8:	89 c3                	mov    %eax,%ebx
  8014fa:	85 c0                	test   %eax,%eax
  8014fc:	78 4b                	js     801549 <devfile_read+0x79>
		return r;
	assert(r <= n);
  8014fe:	39 c6                	cmp    %eax,%esi
  801500:	73 16                	jae    801518 <devfile_read+0x48>
  801502:	68 1c 2d 80 00       	push   $0x802d1c
  801507:	68 23 2d 80 00       	push   $0x802d23
  80150c:	6a 7c                	push   $0x7c
  80150e:	68 38 2d 80 00       	push   $0x802d38
  801513:	e8 c3 eb ff ff       	call   8000db <_panic>
	assert(r <= PGSIZE);
  801518:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80151d:	7e 16                	jle    801535 <devfile_read+0x65>
  80151f:	68 43 2d 80 00       	push   $0x802d43
  801524:	68 23 2d 80 00       	push   $0x802d23
  801529:	6a 7d                	push   $0x7d
  80152b:	68 38 2d 80 00       	push   $0x802d38
  801530:	e8 a6 eb ff ff       	call   8000db <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801535:	83 ec 04             	sub    $0x4,%esp
  801538:	50                   	push   %eax
  801539:	68 00 50 80 00       	push   $0x805000
  80153e:	ff 75 0c             	pushl  0xc(%ebp)
  801541:	e8 04 f4 ff ff       	call   80094a <memmove>
	return r;
  801546:	83 c4 10             	add    $0x10,%esp
}
  801549:	89 d8                	mov    %ebx,%eax
  80154b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80154e:	5b                   	pop    %ebx
  80154f:	5e                   	pop    %esi
  801550:	5d                   	pop    %ebp
  801551:	c3                   	ret    

00801552 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801552:	55                   	push   %ebp
  801553:	89 e5                	mov    %esp,%ebp
  801555:	53                   	push   %ebx
  801556:	83 ec 20             	sub    $0x20,%esp
  801559:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  80155c:	53                   	push   %ebx
  80155d:	e8 1d f2 ff ff       	call   80077f <strlen>
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80156a:	7f 67                	jg     8015d3 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80156c:	83 ec 0c             	sub    $0xc,%esp
  80156f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801572:	50                   	push   %eax
  801573:	e8 9a f8 ff ff       	call   800e12 <fd_alloc>
  801578:	83 c4 10             	add    $0x10,%esp
		return r;
  80157b:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  80157d:	85 c0                	test   %eax,%eax
  80157f:	78 57                	js     8015d8 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801581:	83 ec 08             	sub    $0x8,%esp
  801584:	53                   	push   %ebx
  801585:	68 00 50 80 00       	push   $0x805000
  80158a:	e8 29 f2 ff ff       	call   8007b8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80158f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801592:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801597:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80159a:	b8 01 00 00 00       	mov    $0x1,%eax
  80159f:	e8 f6 fd ff ff       	call   80139a <fsipc>
  8015a4:	89 c3                	mov    %eax,%ebx
  8015a6:	83 c4 10             	add    $0x10,%esp
  8015a9:	85 c0                	test   %eax,%eax
  8015ab:	79 14                	jns    8015c1 <open+0x6f>
		fd_close(fd, 0);
  8015ad:	83 ec 08             	sub    $0x8,%esp
  8015b0:	6a 00                	push   $0x0
  8015b2:	ff 75 f4             	pushl  -0xc(%ebp)
  8015b5:	e8 50 f9 ff ff       	call   800f0a <fd_close>
		return r;
  8015ba:	83 c4 10             	add    $0x10,%esp
  8015bd:	89 da                	mov    %ebx,%edx
  8015bf:	eb 17                	jmp    8015d8 <open+0x86>
	}

	return fd2num(fd);
  8015c1:	83 ec 0c             	sub    $0xc,%esp
  8015c4:	ff 75 f4             	pushl  -0xc(%ebp)
  8015c7:	e8 1f f8 ff ff       	call   800deb <fd2num>
  8015cc:	89 c2                	mov    %eax,%edx
  8015ce:	83 c4 10             	add    $0x10,%esp
  8015d1:	eb 05                	jmp    8015d8 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  8015d3:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  8015d8:	89 d0                	mov    %edx,%eax
  8015da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015dd:	c9                   	leave  
  8015de:	c3                   	ret    

008015df <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015df:	55                   	push   %ebp
  8015e0:	89 e5                	mov    %esp,%ebp
  8015e2:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8015ea:	b8 08 00 00 00       	mov    $0x8,%eax
  8015ef:	e8 a6 fd ff ff       	call   80139a <fsipc>
}
  8015f4:	c9                   	leave  
  8015f5:	c3                   	ret    

008015f6 <spawn>:
// argv: pointer to null-terminated array of pointers to strings,
// 	 which will be passed to the child as its command-line arguments.
// Returns child envid on success, < 0 on failure.
int
spawn(const char *prog, const char **argv)
{
  8015f6:	55                   	push   %ebp
  8015f7:	89 e5                	mov    %esp,%ebp
  8015f9:	57                   	push   %edi
  8015fa:	56                   	push   %esi
  8015fb:	53                   	push   %ebx
  8015fc:	81 ec 94 02 00 00    	sub    $0x294,%esp
	//   - Call sys_env_set_trapframe(child, &child_tf) to set up the
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
  801602:	6a 00                	push   $0x0
  801604:	ff 75 08             	pushl  0x8(%ebp)
  801607:	e8 46 ff ff ff       	call   801552 <open>
  80160c:	89 c7                	mov    %eax,%edi
  80160e:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801614:	83 c4 10             	add    $0x10,%esp
  801617:	85 c0                	test   %eax,%eax
  801619:	0f 88 82 04 00 00    	js     801aa1 <spawn+0x4ab>
		return r;
	fd = r;

	// Read elf header
	elf = (struct Elf*) elf_buf;
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf)
  80161f:	83 ec 04             	sub    $0x4,%esp
  801622:	68 00 02 00 00       	push   $0x200
  801627:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80162d:	50                   	push   %eax
  80162e:	57                   	push   %edi
  80162f:	e8 24 fb ff ff       	call   801158 <readn>
  801634:	83 c4 10             	add    $0x10,%esp
  801637:	3d 00 02 00 00       	cmp    $0x200,%eax
  80163c:	75 0c                	jne    80164a <spawn+0x54>
	    || elf->e_magic != ELF_MAGIC) {
  80163e:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801645:	45 4c 46 
  801648:	74 33                	je     80167d <spawn+0x87>
		close(fd);
  80164a:	83 ec 0c             	sub    $0xc,%esp
  80164d:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801653:	e8 33 f9 ff ff       	call   800f8b <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801658:	83 c4 0c             	add    $0xc,%esp
  80165b:	68 7f 45 4c 46       	push   $0x464c457f
  801660:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801666:	68 4f 2d 80 00       	push   $0x802d4f
  80166b:	e8 44 eb ff ff       	call   8001b4 <cprintf>
		return -E_NOT_EXEC;
  801670:	83 c4 10             	add    $0x10,%esp
  801673:	bb f2 ff ff ff       	mov    $0xfffffff2,%ebx
  801678:	e9 d7 04 00 00       	jmp    801b54 <spawn+0x55e>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80167d:	b8 07 00 00 00       	mov    $0x7,%eax
  801682:	cd 30                	int    $0x30
  801684:	89 85 74 fd ff ff    	mov    %eax,-0x28c(%ebp)
  80168a:	89 85 84 fd ff ff    	mov    %eax,-0x27c(%ebp)
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
  801690:	85 c0                	test   %eax,%eax
  801692:	0f 88 14 04 00 00    	js     801aac <spawn+0x4b6>
		return r;
	child = r;

	// Set up trap frame, including initial stack.
	child_tf = envs[ENVX(child)].env_tf;
  801698:	89 c6                	mov    %eax,%esi
  80169a:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  8016a0:	6b f6 7c             	imul   $0x7c,%esi,%esi
  8016a3:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  8016a9:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8016af:	b9 11 00 00 00       	mov    $0x11,%ecx
  8016b4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8016b6:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8016bc:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8016c2:	bb 00 00 00 00       	mov    $0x0,%ebx
	char *string_store;
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
  8016c7:	be 00 00 00 00       	mov    $0x0,%esi
  8016cc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8016cf:	eb 13                	jmp    8016e4 <spawn+0xee>
	for (argc = 0; argv[argc] != 0; argc++)
		string_size += strlen(argv[argc]) + 1;
  8016d1:	83 ec 0c             	sub    $0xc,%esp
  8016d4:	50                   	push   %eax
  8016d5:	e8 a5 f0 ff ff       	call   80077f <strlen>
  8016da:	8d 74 30 01          	lea    0x1(%eax,%esi,1),%esi
	uintptr_t *argv_store;

	// Count the number of arguments (argc)
	// and the total amount of space needed for strings (string_size).
	string_size = 0;
	for (argc = 0; argv[argc] != 0; argc++)
  8016de:	83 c3 01             	add    $0x1,%ebx
  8016e1:	83 c4 10             	add    $0x10,%esp
  8016e4:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
  8016eb:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8016ee:	85 c0                	test   %eax,%eax
  8016f0:	75 df                	jne    8016d1 <spawn+0xdb>
  8016f2:	89 9d 88 fd ff ff    	mov    %ebx,-0x278(%ebp)
  8016f8:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	// Determine where to place the strings and the argv array.
	// Set up pointers into the temporary page 'UTEMP'; we'll map a page
	// there later, then remap that page into the child environment
	// at (USTACKTOP - PGSIZE).
	// strings is the topmost thing on the stack.
	string_store = (char*) UTEMP + PGSIZE - string_size;
  8016fe:	bf 00 10 40 00       	mov    $0x401000,%edi
  801703:	29 f7                	sub    %esi,%edi
	// argv is below that.  There's one argument pointer per argument, plus
	// a null pointer.
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801705:	89 fa                	mov    %edi,%edx
  801707:	83 e2 fc             	and    $0xfffffffc,%edx
  80170a:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801711:	29 c2                	sub    %eax,%edx
  801713:	89 95 94 fd ff ff    	mov    %edx,-0x26c(%ebp)

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
  801719:	8d 42 f8             	lea    -0x8(%edx),%eax
  80171c:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801721:	0f 86 9b 03 00 00    	jbe    801ac2 <spawn+0x4cc>
		return -E_NO_MEM;

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801727:	83 ec 04             	sub    $0x4,%esp
  80172a:	6a 07                	push   $0x7
  80172c:	68 00 00 40 00       	push   $0x400000
  801731:	6a 00                	push   $0x0
  801733:	e8 83 f4 ff ff       	call   800bbb <sys_page_alloc>
  801738:	83 c4 10             	add    $0x10,%esp
  80173b:	85 c0                	test   %eax,%eax
  80173d:	0f 88 89 03 00 00    	js     801acc <spawn+0x4d6>
  801743:	be 00 00 00 00       	mov    $0x0,%esi
  801748:	89 9d 90 fd ff ff    	mov    %ebx,-0x270(%ebp)
  80174e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801751:	eb 30                	jmp    801783 <spawn+0x18d>
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
		argv_store[i] = UTEMP2USTACK(string_store);
  801753:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801759:	8b 8d 94 fd ff ff    	mov    -0x26c(%ebp),%ecx
  80175f:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801762:	83 ec 08             	sub    $0x8,%esp
  801765:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801768:	57                   	push   %edi
  801769:	e8 4a f0 ff ff       	call   8007b8 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80176e:	83 c4 04             	add    $0x4,%esp
  801771:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801774:	e8 06 f0 ff ff       	call   80077f <strlen>
  801779:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	//	  (Again, argv should use an address valid in the child's
	//	  environment.)
	//
	//	* Set *init_esp to the initial stack pointer for the child,
	//	  (Again, use an address valid in the child's environment.)
	for (i = 0; i < argc; i++) {
  80177d:	83 c6 01             	add    $0x1,%esi
  801780:	83 c4 10             	add    $0x10,%esp
  801783:	39 b5 90 fd ff ff    	cmp    %esi,-0x270(%ebp)
  801789:	7f c8                	jg     801753 <spawn+0x15d>
		argv_store[i] = UTEMP2USTACK(string_store);
		strcpy(string_store, argv[i]);
		string_store += strlen(argv[i]) + 1;
	}
	argv_store[argc] = 0;
  80178b:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801791:	8b 8d 80 fd ff ff    	mov    -0x280(%ebp),%ecx
  801797:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char*)UTEMP + PGSIZE);
  80179e:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8017a4:	74 19                	je     8017bf <spawn+0x1c9>
  8017a6:	68 dc 2d 80 00       	push   $0x802ddc
  8017ab:	68 23 2d 80 00       	push   $0x802d23
  8017b0:	68 f2 00 00 00       	push   $0xf2
  8017b5:	68 69 2d 80 00       	push   $0x802d69
  8017ba:	e8 1c e9 ff ff       	call   8000db <_panic>

	argv_store[-1] = UTEMP2USTACK(argv_store);
  8017bf:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8017c5:	89 f8                	mov    %edi,%eax
  8017c7:	2d 00 30 80 11       	sub    $0x11803000,%eax
  8017cc:	89 47 fc             	mov    %eax,-0x4(%edi)
	argv_store[-2] = argc;
  8017cf:	8b 85 88 fd ff ff    	mov    -0x278(%ebp),%eax
  8017d5:	89 47 f8             	mov    %eax,-0x8(%edi)

	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8017d8:	8d 87 f8 cf 7f ee    	lea    -0x11803008(%edi),%eax
  8017de:	89 85 e0 fd ff ff    	mov    %eax,-0x220(%ebp)

	// After completing the stack, map it into the child's address space
	// and unmap it from ours!
	if ((r = sys_page_map(0, UTEMP, child, (void*) (USTACKTOP - PGSIZE), PTE_P | PTE_U | PTE_W)) < 0)
  8017e4:	83 ec 0c             	sub    $0xc,%esp
  8017e7:	6a 07                	push   $0x7
  8017e9:	68 00 d0 bf ee       	push   $0xeebfd000
  8017ee:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  8017f4:	68 00 00 40 00       	push   $0x400000
  8017f9:	6a 00                	push   $0x0
  8017fb:	e8 fe f3 ff ff       	call   800bfe <sys_page_map>
  801800:	89 c3                	mov    %eax,%ebx
  801802:	83 c4 20             	add    $0x20,%esp
  801805:	85 c0                	test   %eax,%eax
  801807:	0f 88 35 03 00 00    	js     801b42 <spawn+0x54c>
		goto error;
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80180d:	83 ec 08             	sub    $0x8,%esp
  801810:	68 00 00 40 00       	push   $0x400000
  801815:	6a 00                	push   $0x0
  801817:	e8 24 f4 ff ff       	call   800c40 <sys_page_unmap>
  80181c:	89 c3                	mov    %eax,%ebx
  80181e:	83 c4 10             	add    $0x10,%esp
  801821:	85 c0                	test   %eax,%eax
  801823:	0f 88 19 03 00 00    	js     801b42 <spawn+0x54c>

	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
  801829:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  80182f:	8d 84 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%eax
  801836:	89 85 7c fd ff ff    	mov    %eax,-0x284(%ebp)
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  80183c:	c7 85 78 fd ff ff 00 	movl   $0x0,-0x288(%ebp)
  801843:	00 00 00 
  801846:	e9 88 01 00 00       	jmp    8019d3 <spawn+0x3dd>
		if (ph->p_type != ELF_PROG_LOAD)
  80184b:	8b 85 7c fd ff ff    	mov    -0x284(%ebp),%eax
  801851:	83 38 01             	cmpl   $0x1,(%eax)
  801854:	0f 85 6b 01 00 00    	jne    8019c5 <spawn+0x3cf>
			continue;
		perm = PTE_P | PTE_U;
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  80185a:	89 c1                	mov    %eax,%ecx
  80185c:	8b 40 18             	mov    0x18(%eax),%eax
  80185f:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801865:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801868:	83 f8 01             	cmp    $0x1,%eax
  80186b:	19 c0                	sbb    %eax,%eax
  80186d:	83 e0 fe             	and    $0xfffffffe,%eax
  801870:	83 c0 07             	add    $0x7,%eax
  801873:	89 85 88 fd ff ff    	mov    %eax,-0x278(%ebp)
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
  801879:	89 c8                	mov    %ecx,%eax
  80187b:	8b 79 04             	mov    0x4(%ecx),%edi
  80187e:	89 f9                	mov    %edi,%ecx
  801880:	89 bd 80 fd ff ff    	mov    %edi,-0x280(%ebp)
  801886:	8b 78 10             	mov    0x10(%eax),%edi
  801889:	8b 50 14             	mov    0x14(%eax),%edx
  80188c:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
  801892:	8b 70 08             	mov    0x8(%eax),%esi
	int i, r;
	void *blk;

	//cprintf("map_segment %x+%x\n", va, memsz);

	if ((i = PGOFF(va))) {
  801895:	89 f0                	mov    %esi,%eax
  801897:	25 ff 0f 00 00       	and    $0xfff,%eax
  80189c:	74 14                	je     8018b2 <spawn+0x2bc>
		va -= i;
  80189e:	29 c6                	sub    %eax,%esi
		memsz += i;
  8018a0:	01 c2                	add    %eax,%edx
  8018a2:	89 95 90 fd ff ff    	mov    %edx,-0x270(%ebp)
		filesz += i;
  8018a8:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8018aa:	29 c1                	sub    %eax,%ecx
  8018ac:	89 8d 80 fd ff ff    	mov    %ecx,-0x280(%ebp)
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8018b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8018b7:	e9 f7 00 00 00       	jmp    8019b3 <spawn+0x3bd>
		if (i >= filesz) {
  8018bc:	39 fb                	cmp    %edi,%ebx
  8018be:	72 27                	jb     8018e7 <spawn+0x2f1>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
  8018c0:	83 ec 04             	sub    $0x4,%esp
  8018c3:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  8018c9:	56                   	push   %esi
  8018ca:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  8018d0:	e8 e6 f2 ff ff       	call   800bbb <sys_page_alloc>
  8018d5:	83 c4 10             	add    $0x10,%esp
  8018d8:	85 c0                	test   %eax,%eax
  8018da:	0f 89 c7 00 00 00    	jns    8019a7 <spawn+0x3b1>
  8018e0:	89 c3                	mov    %eax,%ebx
  8018e2:	e9 f6 01 00 00       	jmp    801add <spawn+0x4e7>
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  8018e7:	83 ec 04             	sub    $0x4,%esp
  8018ea:	6a 07                	push   $0x7
  8018ec:	68 00 00 40 00       	push   $0x400000
  8018f1:	6a 00                	push   $0x0
  8018f3:	e8 c3 f2 ff ff       	call   800bbb <sys_page_alloc>
  8018f8:	83 c4 10             	add    $0x10,%esp
  8018fb:	85 c0                	test   %eax,%eax
  8018fd:	0f 88 d0 01 00 00    	js     801ad3 <spawn+0x4dd>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801903:	83 ec 08             	sub    $0x8,%esp
  801906:	8b 85 80 fd ff ff    	mov    -0x280(%ebp),%eax
  80190c:	03 85 94 fd ff ff    	add    -0x26c(%ebp),%eax
  801912:	50                   	push   %eax
  801913:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801919:	e8 0f f9 ff ff       	call   80122d <seek>
  80191e:	83 c4 10             	add    $0x10,%esp
  801921:	85 c0                	test   %eax,%eax
  801923:	0f 88 ae 01 00 00    	js     801ad7 <spawn+0x4e1>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801929:	83 ec 04             	sub    $0x4,%esp
  80192c:	89 f8                	mov    %edi,%eax
  80192e:	2b 85 94 fd ff ff    	sub    -0x26c(%ebp),%eax
  801934:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801939:	b9 00 10 00 00       	mov    $0x1000,%ecx
  80193e:	0f 47 c1             	cmova  %ecx,%eax
  801941:	50                   	push   %eax
  801942:	68 00 00 40 00       	push   $0x400000
  801947:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80194d:	e8 06 f8 ff ff       	call   801158 <readn>
  801952:	83 c4 10             	add    $0x10,%esp
  801955:	85 c0                	test   %eax,%eax
  801957:	0f 88 7e 01 00 00    	js     801adb <spawn+0x4e5>
				return r;
			if ((r = sys_page_map(0, UTEMP, child, (void*) (va + i), perm)) < 0)
  80195d:	83 ec 0c             	sub    $0xc,%esp
  801960:	ff b5 88 fd ff ff    	pushl  -0x278(%ebp)
  801966:	56                   	push   %esi
  801967:	ff b5 84 fd ff ff    	pushl  -0x27c(%ebp)
  80196d:	68 00 00 40 00       	push   $0x400000
  801972:	6a 00                	push   $0x0
  801974:	e8 85 f2 ff ff       	call   800bfe <sys_page_map>
  801979:	83 c4 20             	add    $0x20,%esp
  80197c:	85 c0                	test   %eax,%eax
  80197e:	79 15                	jns    801995 <spawn+0x39f>
				panic("spawn: sys_page_map data: %e", r);
  801980:	50                   	push   %eax
  801981:	68 75 2d 80 00       	push   $0x802d75
  801986:	68 25 01 00 00       	push   $0x125
  80198b:	68 69 2d 80 00       	push   $0x802d69
  801990:	e8 46 e7 ff ff       	call   8000db <_panic>
			sys_page_unmap(0, UTEMP);
  801995:	83 ec 08             	sub    $0x8,%esp
  801998:	68 00 00 40 00       	push   $0x400000
  80199d:	6a 00                	push   $0x0
  80199f:	e8 9c f2 ff ff       	call   800c40 <sys_page_unmap>
  8019a4:	83 c4 10             	add    $0x10,%esp
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
  8019a7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8019ad:	81 c6 00 10 00 00    	add    $0x1000,%esi
  8019b3:	89 9d 94 fd ff ff    	mov    %ebx,-0x26c(%ebp)
  8019b9:	3b 9d 90 fd ff ff    	cmp    -0x270(%ebp),%ebx
  8019bf:	0f 82 f7 fe ff ff    	jb     8018bc <spawn+0x2c6>
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
		return r;

	// Set up program segments as defined in ELF header.
	ph = (struct Proghdr*) (elf_buf + elf->e_phoff);
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8019c5:	83 85 78 fd ff ff 01 	addl   $0x1,-0x288(%ebp)
  8019cc:	83 85 7c fd ff ff 20 	addl   $0x20,-0x284(%ebp)
  8019d3:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8019da:	39 85 78 fd ff ff    	cmp    %eax,-0x288(%ebp)
  8019e0:	0f 8c 65 fe ff ff    	jl     80184b <spawn+0x255>
			perm |= PTE_W;
		if ((r = map_segment(child, ph->p_va, ph->p_memsz,
				     fd, ph->p_filesz, ph->p_offset, perm)) < 0)
			goto error;
	}
	close(fd);
  8019e6:	83 ec 0c             	sub    $0xc,%esp
  8019e9:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8019ef:	e8 97 f5 ff ff       	call   800f8b <close>
  8019f4:	83 c4 10             	add    $0x10,%esp
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r=0,pn=0;
	for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  8019f7:	bb 00 08 00 00       	mov    $0x800,%ebx
  8019fc:	8b b5 84 fd ff ff    	mov    -0x27c(%ebp),%esi
        if ((uvpd[pn >> 10] & PTE_P) &&uvpt[pn] & PTE_SHARE)
  801a02:	89 d8                	mov    %ebx,%eax
  801a04:	c1 f8 0a             	sar    $0xa,%eax
  801a07:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801a0e:	a8 01                	test   $0x1,%al
  801a10:	74 3e                	je     801a50 <spawn+0x45a>
  801a12:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801a19:	f6 c4 04             	test   $0x4,%ah
  801a1c:	74 32                	je     801a50 <spawn+0x45a>
            if ( (r = sys_page_map(thisenv->env_id, (void *)(pn*PGSIZE), child, (void *)(pn*PGSIZE), uvpt[pn] & PTE_SYSCALL )) < 0)
  801a1e:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801a25:	89 da                	mov    %ebx,%edx
  801a27:	c1 e2 0c             	shl    $0xc,%edx
  801a2a:	8b 0d 08 40 80 00    	mov    0x804008,%ecx
  801a30:	8b 49 48             	mov    0x48(%ecx),%ecx
  801a33:	83 ec 0c             	sub    $0xc,%esp
  801a36:	25 07 0e 00 00       	and    $0xe07,%eax
  801a3b:	50                   	push   %eax
  801a3c:	52                   	push   %edx
  801a3d:	56                   	push   %esi
  801a3e:	52                   	push   %edx
  801a3f:	51                   	push   %ecx
  801a40:	e8 b9 f1 ff ff       	call   800bfe <sys_page_map>
  801a45:	83 c4 20             	add    $0x20,%esp
  801a48:	85 c0                	test   %eax,%eax
  801a4a:	0f 88 dd 00 00 00    	js     801b2d <spawn+0x537>
static int
copy_shared_pages(envid_t child)
{
	// LAB 5: Your code here.
	int r=0,pn=0;
	for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  801a50:	83 c3 01             	add    $0x1,%ebx
  801a53:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  801a59:	75 a7                	jne    801a02 <spawn+0x40c>
  801a5b:	e9 9e 00 00 00       	jmp    801afe <spawn+0x508>
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
		panic("sys_env_set_trapframe: %e", r);
  801a60:	50                   	push   %eax
  801a61:	68 92 2d 80 00       	push   $0x802d92
  801a66:	68 86 00 00 00       	push   $0x86
  801a6b:	68 69 2d 80 00       	push   $0x802d69
  801a70:	e8 66 e6 ff ff       	call   8000db <_panic>

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801a75:	83 ec 08             	sub    $0x8,%esp
  801a78:	6a 02                	push   $0x2
  801a7a:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801a80:	e8 fd f1 ff ff       	call   800c82 <sys_env_set_status>
  801a85:	83 c4 10             	add    $0x10,%esp
  801a88:	85 c0                	test   %eax,%eax
  801a8a:	79 2b                	jns    801ab7 <spawn+0x4c1>
		panic("sys_env_set_status: %e", r);
  801a8c:	50                   	push   %eax
  801a8d:	68 ac 2d 80 00       	push   $0x802dac
  801a92:	68 89 00 00 00       	push   $0x89
  801a97:	68 69 2d 80 00       	push   $0x802d69
  801a9c:	e8 3a e6 ff ff       	call   8000db <_panic>
	//     correct initial eip and esp values in the child.
	//
	//   - Start the child process running with sys_env_set_status().

	if ((r = open(prog, O_RDONLY)) < 0)
		return r;
  801aa1:	8b 9d 8c fd ff ff    	mov    -0x274(%ebp),%ebx
  801aa7:	e9 a8 00 00 00       	jmp    801b54 <spawn+0x55e>
		return -E_NOT_EXEC;
	}

	// Create new child environment
	if ((r = sys_exofork()) < 0)
		return r;
  801aac:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801ab2:	e9 9d 00 00 00       	jmp    801b54 <spawn+0x55e>
		panic("sys_env_set_trapframe: %e", r);

	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
		panic("sys_env_set_status: %e", r);

	return child;
  801ab7:	8b 9d 74 fd ff ff    	mov    -0x28c(%ebp),%ebx
  801abd:	e9 92 00 00 00       	jmp    801b54 <spawn+0x55e>
	argv_store = (uintptr_t*) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));

	// Make sure that argv, strings, and the 2 words that hold 'argc'
	// and 'argv' themselves will all fit in a single stack page.
	if ((void*) (argv_store - 2) < (void*) UTEMP)
		return -E_NO_MEM;
  801ac2:	bb fc ff ff ff       	mov    $0xfffffffc,%ebx
  801ac7:	e9 88 00 00 00       	jmp    801b54 <spawn+0x55e>

	// Allocate the single stack page at UTEMP.
	if ((r = sys_page_alloc(0, (void*) UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
		return r;
  801acc:	89 c3                	mov    %eax,%ebx
  801ace:	e9 81 00 00 00       	jmp    801b54 <spawn+0x55e>
			// allocate a blank page
			if ((r = sys_page_alloc(child, (void*) (va + i), perm)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  801ad3:	89 c3                	mov    %eax,%ebx
  801ad5:	eb 06                	jmp    801add <spawn+0x4e7>
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ad7:	89 c3                	mov    %eax,%ebx
  801ad9:	eb 02                	jmp    801add <spawn+0x4e7>
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
  801adb:	89 c3                	mov    %eax,%ebx
		panic("sys_env_set_status: %e", r);

	return child;

error:
	sys_env_destroy(child);
  801add:	83 ec 0c             	sub    $0xc,%esp
  801ae0:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801ae6:	e8 51 f0 ff ff       	call   800b3c <sys_env_destroy>
	close(fd);
  801aeb:	83 c4 04             	add    $0x4,%esp
  801aee:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801af4:	e8 92 f4 ff ff       	call   800f8b <close>
	return r;
  801af9:	83 c4 10             	add    $0x10,%esp
  801afc:	eb 56                	jmp    801b54 <spawn+0x55e>

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);

	child_tf.tf_eflags |= FL_IOPL_3;   // devious: see user/faultio.c
  801afe:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801b05:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801b08:	83 ec 08             	sub    $0x8,%esp
  801b0b:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801b11:	50                   	push   %eax
  801b12:	ff b5 74 fd ff ff    	pushl  -0x28c(%ebp)
  801b18:	e8 a7 f1 ff ff       	call   800cc4 <sys_env_set_trapframe>
  801b1d:	83 c4 10             	add    $0x10,%esp
  801b20:	85 c0                	test   %eax,%eax
  801b22:	0f 89 4d ff ff ff    	jns    801a75 <spawn+0x47f>
  801b28:	e9 33 ff ff ff       	jmp    801a60 <spawn+0x46a>
	close(fd);
	fd = -1;

	// Copy shared library state.
	if ((r = copy_shared_pages(child)) < 0)
		panic("copy_shared_pages: %e", r);
  801b2d:	50                   	push   %eax
  801b2e:	68 c3 2d 80 00       	push   $0x802dc3
  801b33:	68 82 00 00 00       	push   $0x82
  801b38:	68 69 2d 80 00       	push   $0x802d69
  801b3d:	e8 99 e5 ff ff       	call   8000db <_panic>
		goto error;

	return 0;

error:
	sys_page_unmap(0, UTEMP);
  801b42:	83 ec 08             	sub    $0x8,%esp
  801b45:	68 00 00 40 00       	push   $0x400000
  801b4a:	6a 00                	push   $0x0
  801b4c:	e8 ef f0 ff ff       	call   800c40 <sys_page_unmap>
  801b51:	83 c4 10             	add    $0x10,%esp

error:
	sys_env_destroy(child);
	close(fd);
	return r;
}
  801b54:	89 d8                	mov    %ebx,%eax
  801b56:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b59:	5b                   	pop    %ebx
  801b5a:	5e                   	pop    %esi
  801b5b:	5f                   	pop    %edi
  801b5c:	5d                   	pop    %ebp
  801b5d:	c3                   	ret    

00801b5e <spawnl>:
// Spawn, taking command-line arguments array directly on the stack.
// NOTE: Must have a sentinal of NULL at the end of the args
// (none of the args may be NULL).
int
spawnl(const char *prog, const char *arg0, ...)
{
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	56                   	push   %esi
  801b62:	53                   	push   %ebx
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b63:	8d 55 10             	lea    0x10(%ebp),%edx
{
	// We calculate argc by advancing the args until we hit NULL.
	// The contract of the function guarantees that the last
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
  801b66:	b8 00 00 00 00       	mov    $0x0,%eax
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b6b:	eb 03                	jmp    801b70 <spawnl+0x12>
		argc++;
  801b6d:	83 c0 01             	add    $0x1,%eax
	// argument will always be NULL, and that none of the other
	// arguments will be NULL.
	int argc=0;
	va_list vl;
	va_start(vl, arg0);
	while(va_arg(vl, void *) != NULL)
  801b70:	83 c2 04             	add    $0x4,%edx
  801b73:	83 7a fc 00          	cmpl   $0x0,-0x4(%edx)
  801b77:	75 f4                	jne    801b6d <spawnl+0xf>
		argc++;
	va_end(vl);

	// Now that we have the size of the args, do a second pass
	// and store the values in a VLA, which has the format of argv
	const char *argv[argc+2];
  801b79:	8d 14 85 1a 00 00 00 	lea    0x1a(,%eax,4),%edx
  801b80:	83 e2 f0             	and    $0xfffffff0,%edx
  801b83:	29 d4                	sub    %edx,%esp
  801b85:	8d 54 24 03          	lea    0x3(%esp),%edx
  801b89:	c1 ea 02             	shr    $0x2,%edx
  801b8c:	8d 34 95 00 00 00 00 	lea    0x0(,%edx,4),%esi
  801b93:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801b95:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b98:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc+1] = NULL;
  801b9f:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801ba6:	00 
  801ba7:	89 c2                	mov    %eax,%edx

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801ba9:	b8 00 00 00 00       	mov    $0x0,%eax
  801bae:	eb 0a                	jmp    801bba <spawnl+0x5c>
		argv[i+1] = va_arg(vl, const char *);
  801bb0:	83 c0 01             	add    $0x1,%eax
  801bb3:	8b 4c 85 0c          	mov    0xc(%ebp,%eax,4),%ecx
  801bb7:	89 0c 83             	mov    %ecx,(%ebx,%eax,4)
	argv[0] = arg0;
	argv[argc+1] = NULL;

	va_start(vl, arg0);
	unsigned i;
	for(i=0;i<argc;i++)
  801bba:	39 d0                	cmp    %edx,%eax
  801bbc:	75 f2                	jne    801bb0 <spawnl+0x52>
		argv[i+1] = va_arg(vl, const char *);
	va_end(vl);
	return spawn(prog, argv);
  801bbe:	83 ec 08             	sub    $0x8,%esp
  801bc1:	56                   	push   %esi
  801bc2:	ff 75 08             	pushl  0x8(%ebp)
  801bc5:	e8 2c fa ff ff       	call   8015f6 <spawn>
}
  801bca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bcd:	5b                   	pop    %ebx
  801bce:	5e                   	pop    %esi
  801bcf:	5d                   	pop    %ebp
  801bd0:	c3                   	ret    

00801bd1 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801bd1:	55                   	push   %ebp
  801bd2:	89 e5                	mov    %esp,%ebp
  801bd4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801bd7:	68 04 2e 80 00       	push   $0x802e04
  801bdc:	ff 75 0c             	pushl  0xc(%ebp)
  801bdf:	e8 d4 eb ff ff       	call   8007b8 <strcpy>
	return 0;
}
  801be4:	b8 00 00 00 00       	mov    $0x0,%eax
  801be9:	c9                   	leave  
  801bea:	c3                   	ret    

00801beb <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801beb:	55                   	push   %ebp
  801bec:	89 e5                	mov    %esp,%ebp
  801bee:	53                   	push   %ebx
  801bef:	83 ec 10             	sub    $0x10,%esp
  801bf2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801bf5:	53                   	push   %ebx
  801bf6:	e8 12 0a 00 00       	call   80260d <pageref>
  801bfb:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801bfe:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801c03:	83 f8 01             	cmp    $0x1,%eax
  801c06:	75 10                	jne    801c18 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801c08:	83 ec 0c             	sub    $0xc,%esp
  801c0b:	ff 73 0c             	pushl  0xc(%ebx)
  801c0e:	e8 c0 02 00 00       	call   801ed3 <nsipc_close>
  801c13:	89 c2                	mov    %eax,%edx
  801c15:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801c18:	89 d0                	mov    %edx,%eax
  801c1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c1d:	c9                   	leave  
  801c1e:	c3                   	ret    

00801c1f <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801c1f:	55                   	push   %ebp
  801c20:	89 e5                	mov    %esp,%ebp
  801c22:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801c25:	6a 00                	push   $0x0
  801c27:	ff 75 10             	pushl  0x10(%ebp)
  801c2a:	ff 75 0c             	pushl  0xc(%ebp)
  801c2d:	8b 45 08             	mov    0x8(%ebp),%eax
  801c30:	ff 70 0c             	pushl  0xc(%eax)
  801c33:	e8 78 03 00 00       	call   801fb0 <nsipc_send>
}
  801c38:	c9                   	leave  
  801c39:	c3                   	ret    

00801c3a <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c3a:	55                   	push   %ebp
  801c3b:	89 e5                	mov    %esp,%ebp
  801c3d:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c40:	6a 00                	push   $0x0
  801c42:	ff 75 10             	pushl  0x10(%ebp)
  801c45:	ff 75 0c             	pushl  0xc(%ebp)
  801c48:	8b 45 08             	mov    0x8(%ebp),%eax
  801c4b:	ff 70 0c             	pushl  0xc(%eax)
  801c4e:	e8 f1 02 00 00       	call   801f44 <nsipc_recv>
}
  801c53:	c9                   	leave  
  801c54:	c3                   	ret    

00801c55 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c55:	55                   	push   %ebp
  801c56:	89 e5                	mov    %esp,%ebp
  801c58:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c5b:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c5e:	52                   	push   %edx
  801c5f:	50                   	push   %eax
  801c60:	e8 fc f1 ff ff       	call   800e61 <fd_lookup>
  801c65:	83 c4 10             	add    $0x10,%esp
  801c68:	85 c0                	test   %eax,%eax
  801c6a:	78 17                	js     801c83 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c6c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c6f:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801c75:	39 08                	cmp    %ecx,(%eax)
  801c77:	75 05                	jne    801c7e <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c79:	8b 40 0c             	mov    0xc(%eax),%eax
  801c7c:	eb 05                	jmp    801c83 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c7e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c83:	c9                   	leave  
  801c84:	c3                   	ret    

00801c85 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801c85:	55                   	push   %ebp
  801c86:	89 e5                	mov    %esp,%ebp
  801c88:	56                   	push   %esi
  801c89:	53                   	push   %ebx
  801c8a:	83 ec 1c             	sub    $0x1c,%esp
  801c8d:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801c8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c92:	50                   	push   %eax
  801c93:	e8 7a f1 ff ff       	call   800e12 <fd_alloc>
  801c98:	89 c3                	mov    %eax,%ebx
  801c9a:	83 c4 10             	add    $0x10,%esp
  801c9d:	85 c0                	test   %eax,%eax
  801c9f:	78 1b                	js     801cbc <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801ca1:	83 ec 04             	sub    $0x4,%esp
  801ca4:	68 07 04 00 00       	push   $0x407
  801ca9:	ff 75 f4             	pushl  -0xc(%ebp)
  801cac:	6a 00                	push   $0x0
  801cae:	e8 08 ef ff ff       	call   800bbb <sys_page_alloc>
  801cb3:	89 c3                	mov    %eax,%ebx
  801cb5:	83 c4 10             	add    $0x10,%esp
  801cb8:	85 c0                	test   %eax,%eax
  801cba:	79 10                	jns    801ccc <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801cbc:	83 ec 0c             	sub    $0xc,%esp
  801cbf:	56                   	push   %esi
  801cc0:	e8 0e 02 00 00       	call   801ed3 <nsipc_close>
		return r;
  801cc5:	83 c4 10             	add    $0x10,%esp
  801cc8:	89 d8                	mov    %ebx,%eax
  801cca:	eb 24                	jmp    801cf0 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801ccc:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801cd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cd5:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801cd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cda:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ce1:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801ce4:	83 ec 0c             	sub    $0xc,%esp
  801ce7:	50                   	push   %eax
  801ce8:	e8 fe f0 ff ff       	call   800deb <fd2num>
  801ced:	83 c4 10             	add    $0x10,%esp
}
  801cf0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cf3:	5b                   	pop    %ebx
  801cf4:	5e                   	pop    %esi
  801cf5:	5d                   	pop    %ebp
  801cf6:	c3                   	ret    

00801cf7 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cf7:	55                   	push   %ebp
  801cf8:	89 e5                	mov    %esp,%ebp
  801cfa:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cfd:	8b 45 08             	mov    0x8(%ebp),%eax
  801d00:	e8 50 ff ff ff       	call   801c55 <fd2sockid>
		return r;
  801d05:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d07:	85 c0                	test   %eax,%eax
  801d09:	78 1f                	js     801d2a <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d0b:	83 ec 04             	sub    $0x4,%esp
  801d0e:	ff 75 10             	pushl  0x10(%ebp)
  801d11:	ff 75 0c             	pushl  0xc(%ebp)
  801d14:	50                   	push   %eax
  801d15:	e8 12 01 00 00       	call   801e2c <nsipc_accept>
  801d1a:	83 c4 10             	add    $0x10,%esp
		return r;
  801d1d:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801d1f:	85 c0                	test   %eax,%eax
  801d21:	78 07                	js     801d2a <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801d23:	e8 5d ff ff ff       	call   801c85 <alloc_sockfd>
  801d28:	89 c1                	mov    %eax,%ecx
}
  801d2a:	89 c8                	mov    %ecx,%eax
  801d2c:	c9                   	leave  
  801d2d:	c3                   	ret    

00801d2e <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801d2e:	55                   	push   %ebp
  801d2f:	89 e5                	mov    %esp,%ebp
  801d31:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d34:	8b 45 08             	mov    0x8(%ebp),%eax
  801d37:	e8 19 ff ff ff       	call   801c55 <fd2sockid>
  801d3c:	85 c0                	test   %eax,%eax
  801d3e:	78 12                	js     801d52 <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801d40:	83 ec 04             	sub    $0x4,%esp
  801d43:	ff 75 10             	pushl  0x10(%ebp)
  801d46:	ff 75 0c             	pushl  0xc(%ebp)
  801d49:	50                   	push   %eax
  801d4a:	e8 2d 01 00 00       	call   801e7c <nsipc_bind>
  801d4f:	83 c4 10             	add    $0x10,%esp
}
  801d52:	c9                   	leave  
  801d53:	c3                   	ret    

00801d54 <shutdown>:

int
shutdown(int s, int how)
{
  801d54:	55                   	push   %ebp
  801d55:	89 e5                	mov    %esp,%ebp
  801d57:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d5a:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5d:	e8 f3 fe ff ff       	call   801c55 <fd2sockid>
  801d62:	85 c0                	test   %eax,%eax
  801d64:	78 0f                	js     801d75 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801d66:	83 ec 08             	sub    $0x8,%esp
  801d69:	ff 75 0c             	pushl  0xc(%ebp)
  801d6c:	50                   	push   %eax
  801d6d:	e8 3f 01 00 00       	call   801eb1 <nsipc_shutdown>
  801d72:	83 c4 10             	add    $0x10,%esp
}
  801d75:	c9                   	leave  
  801d76:	c3                   	ret    

00801d77 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d77:	55                   	push   %ebp
  801d78:	89 e5                	mov    %esp,%ebp
  801d7a:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d7d:	8b 45 08             	mov    0x8(%ebp),%eax
  801d80:	e8 d0 fe ff ff       	call   801c55 <fd2sockid>
  801d85:	85 c0                	test   %eax,%eax
  801d87:	78 12                	js     801d9b <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801d89:	83 ec 04             	sub    $0x4,%esp
  801d8c:	ff 75 10             	pushl  0x10(%ebp)
  801d8f:	ff 75 0c             	pushl  0xc(%ebp)
  801d92:	50                   	push   %eax
  801d93:	e8 55 01 00 00       	call   801eed <nsipc_connect>
  801d98:	83 c4 10             	add    $0x10,%esp
}
  801d9b:	c9                   	leave  
  801d9c:	c3                   	ret    

00801d9d <listen>:

int
listen(int s, int backlog)
{
  801d9d:	55                   	push   %ebp
  801d9e:	89 e5                	mov    %esp,%ebp
  801da0:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801da3:	8b 45 08             	mov    0x8(%ebp),%eax
  801da6:	e8 aa fe ff ff       	call   801c55 <fd2sockid>
  801dab:	85 c0                	test   %eax,%eax
  801dad:	78 0f                	js     801dbe <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801daf:	83 ec 08             	sub    $0x8,%esp
  801db2:	ff 75 0c             	pushl  0xc(%ebp)
  801db5:	50                   	push   %eax
  801db6:	e8 67 01 00 00       	call   801f22 <nsipc_listen>
  801dbb:	83 c4 10             	add    $0x10,%esp
}
  801dbe:	c9                   	leave  
  801dbf:	c3                   	ret    

00801dc0 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801dc0:	55                   	push   %ebp
  801dc1:	89 e5                	mov    %esp,%ebp
  801dc3:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801dc6:	ff 75 10             	pushl  0x10(%ebp)
  801dc9:	ff 75 0c             	pushl  0xc(%ebp)
  801dcc:	ff 75 08             	pushl  0x8(%ebp)
  801dcf:	e8 3a 02 00 00       	call   80200e <nsipc_socket>
  801dd4:	83 c4 10             	add    $0x10,%esp
  801dd7:	85 c0                	test   %eax,%eax
  801dd9:	78 05                	js     801de0 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ddb:	e8 a5 fe ff ff       	call   801c85 <alloc_sockfd>
}
  801de0:	c9                   	leave  
  801de1:	c3                   	ret    

00801de2 <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801de2:	55                   	push   %ebp
  801de3:	89 e5                	mov    %esp,%ebp
  801de5:	53                   	push   %ebx
  801de6:	83 ec 04             	sub    $0x4,%esp
  801de9:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801deb:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  801df2:	75 12                	jne    801e06 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801df4:	83 ec 0c             	sub    $0xc,%esp
  801df7:	6a 02                	push   $0x2
  801df9:	e8 d6 07 00 00       	call   8025d4 <ipc_find_env>
  801dfe:	a3 04 40 80 00       	mov    %eax,0x804004
  801e03:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801e06:	6a 07                	push   $0x7
  801e08:	68 00 60 80 00       	push   $0x806000
  801e0d:	53                   	push   %ebx
  801e0e:	ff 35 04 40 80 00    	pushl  0x804004
  801e14:	e8 67 07 00 00       	call   802580 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801e19:	83 c4 0c             	add    $0xc,%esp
  801e1c:	6a 00                	push   $0x0
  801e1e:	6a 00                	push   $0x0
  801e20:	6a 00                	push   $0x0
  801e22:	e8 f0 06 00 00       	call   802517 <ipc_recv>
}
  801e27:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e2a:	c9                   	leave  
  801e2b:	c3                   	ret    

00801e2c <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801e2c:	55                   	push   %ebp
  801e2d:	89 e5                	mov    %esp,%ebp
  801e2f:	56                   	push   %esi
  801e30:	53                   	push   %ebx
  801e31:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801e34:	8b 45 08             	mov    0x8(%ebp),%eax
  801e37:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e3c:	8b 06                	mov    (%esi),%eax
  801e3e:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e43:	b8 01 00 00 00       	mov    $0x1,%eax
  801e48:	e8 95 ff ff ff       	call   801de2 <nsipc>
  801e4d:	89 c3                	mov    %eax,%ebx
  801e4f:	85 c0                	test   %eax,%eax
  801e51:	78 20                	js     801e73 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e53:	83 ec 04             	sub    $0x4,%esp
  801e56:	ff 35 10 60 80 00    	pushl  0x806010
  801e5c:	68 00 60 80 00       	push   $0x806000
  801e61:	ff 75 0c             	pushl  0xc(%ebp)
  801e64:	e8 e1 ea ff ff       	call   80094a <memmove>
		*addrlen = ret->ret_addrlen;
  801e69:	a1 10 60 80 00       	mov    0x806010,%eax
  801e6e:	89 06                	mov    %eax,(%esi)
  801e70:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801e73:	89 d8                	mov    %ebx,%eax
  801e75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e78:	5b                   	pop    %ebx
  801e79:	5e                   	pop    %esi
  801e7a:	5d                   	pop    %ebp
  801e7b:	c3                   	ret    

00801e7c <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e7c:	55                   	push   %ebp
  801e7d:	89 e5                	mov    %esp,%ebp
  801e7f:	53                   	push   %ebx
  801e80:	83 ec 08             	sub    $0x8,%esp
  801e83:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e86:	8b 45 08             	mov    0x8(%ebp),%eax
  801e89:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e8e:	53                   	push   %ebx
  801e8f:	ff 75 0c             	pushl  0xc(%ebp)
  801e92:	68 04 60 80 00       	push   $0x806004
  801e97:	e8 ae ea ff ff       	call   80094a <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e9c:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801ea2:	b8 02 00 00 00       	mov    $0x2,%eax
  801ea7:	e8 36 ff ff ff       	call   801de2 <nsipc>
}
  801eac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801eaf:	c9                   	leave  
  801eb0:	c3                   	ret    

00801eb1 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801eb7:	8b 45 08             	mov    0x8(%ebp),%eax
  801eba:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801ebf:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ec2:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801ec7:	b8 03 00 00 00       	mov    $0x3,%eax
  801ecc:	e8 11 ff ff ff       	call   801de2 <nsipc>
}
  801ed1:	c9                   	leave  
  801ed2:	c3                   	ret    

00801ed3 <nsipc_close>:

int
nsipc_close(int s)
{
  801ed3:	55                   	push   %ebp
  801ed4:	89 e5                	mov    %esp,%ebp
  801ed6:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ed9:	8b 45 08             	mov    0x8(%ebp),%eax
  801edc:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ee1:	b8 04 00 00 00       	mov    $0x4,%eax
  801ee6:	e8 f7 fe ff ff       	call   801de2 <nsipc>
}
  801eeb:	c9                   	leave  
  801eec:	c3                   	ret    

00801eed <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801eed:	55                   	push   %ebp
  801eee:	89 e5                	mov    %esp,%ebp
  801ef0:	53                   	push   %ebx
  801ef1:	83 ec 08             	sub    $0x8,%esp
  801ef4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ef7:	8b 45 08             	mov    0x8(%ebp),%eax
  801efa:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801eff:	53                   	push   %ebx
  801f00:	ff 75 0c             	pushl  0xc(%ebp)
  801f03:	68 04 60 80 00       	push   $0x806004
  801f08:	e8 3d ea ff ff       	call   80094a <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801f0d:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801f13:	b8 05 00 00 00       	mov    $0x5,%eax
  801f18:	e8 c5 fe ff ff       	call   801de2 <nsipc>
}
  801f1d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f20:	c9                   	leave  
  801f21:	c3                   	ret    

00801f22 <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801f22:	55                   	push   %ebp
  801f23:	89 e5                	mov    %esp,%ebp
  801f25:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801f28:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2b:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801f30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f33:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801f38:	b8 06 00 00 00       	mov    $0x6,%eax
  801f3d:	e8 a0 fe ff ff       	call   801de2 <nsipc>
}
  801f42:	c9                   	leave  
  801f43:	c3                   	ret    

00801f44 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	56                   	push   %esi
  801f48:	53                   	push   %ebx
  801f49:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f4c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f4f:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f54:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f5a:	8b 45 14             	mov    0x14(%ebp),%eax
  801f5d:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f62:	b8 07 00 00 00       	mov    $0x7,%eax
  801f67:	e8 76 fe ff ff       	call   801de2 <nsipc>
  801f6c:	89 c3                	mov    %eax,%ebx
  801f6e:	85 c0                	test   %eax,%eax
  801f70:	78 35                	js     801fa7 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801f72:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f77:	7f 04                	jg     801f7d <nsipc_recv+0x39>
  801f79:	39 c6                	cmp    %eax,%esi
  801f7b:	7d 16                	jge    801f93 <nsipc_recv+0x4f>
  801f7d:	68 10 2e 80 00       	push   $0x802e10
  801f82:	68 23 2d 80 00       	push   $0x802d23
  801f87:	6a 62                	push   $0x62
  801f89:	68 25 2e 80 00       	push   $0x802e25
  801f8e:	e8 48 e1 ff ff       	call   8000db <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f93:	83 ec 04             	sub    $0x4,%esp
  801f96:	50                   	push   %eax
  801f97:	68 00 60 80 00       	push   $0x806000
  801f9c:	ff 75 0c             	pushl  0xc(%ebp)
  801f9f:	e8 a6 e9 ff ff       	call   80094a <memmove>
  801fa4:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801fa7:	89 d8                	mov    %ebx,%eax
  801fa9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fac:	5b                   	pop    %ebx
  801fad:	5e                   	pop    %esi
  801fae:	5d                   	pop    %ebp
  801faf:	c3                   	ret    

00801fb0 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801fb0:	55                   	push   %ebp
  801fb1:	89 e5                	mov    %esp,%ebp
  801fb3:	53                   	push   %ebx
  801fb4:	83 ec 04             	sub    $0x4,%esp
  801fb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801fba:	8b 45 08             	mov    0x8(%ebp),%eax
  801fbd:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801fc2:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801fc8:	7e 16                	jle    801fe0 <nsipc_send+0x30>
  801fca:	68 31 2e 80 00       	push   $0x802e31
  801fcf:	68 23 2d 80 00       	push   $0x802d23
  801fd4:	6a 6d                	push   $0x6d
  801fd6:	68 25 2e 80 00       	push   $0x802e25
  801fdb:	e8 fb e0 ff ff       	call   8000db <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801fe0:	83 ec 04             	sub    $0x4,%esp
  801fe3:	53                   	push   %ebx
  801fe4:	ff 75 0c             	pushl  0xc(%ebp)
  801fe7:	68 0c 60 80 00       	push   $0x80600c
  801fec:	e8 59 e9 ff ff       	call   80094a <memmove>
	nsipcbuf.send.req_size = size;
  801ff1:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801ff7:	8b 45 14             	mov    0x14(%ebp),%eax
  801ffa:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801fff:	b8 08 00 00 00       	mov    $0x8,%eax
  802004:	e8 d9 fd ff ff       	call   801de2 <nsipc>
}
  802009:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80200c:	c9                   	leave  
  80200d:	c3                   	ret    

0080200e <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  80200e:	55                   	push   %ebp
  80200f:	89 e5                	mov    %esp,%ebp
  802011:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  802014:	8b 45 08             	mov    0x8(%ebp),%eax
  802017:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  80201c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80201f:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  802024:	8b 45 10             	mov    0x10(%ebp),%eax
  802027:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  80202c:	b8 09 00 00 00       	mov    $0x9,%eax
  802031:	e8 ac fd ff ff       	call   801de2 <nsipc>
}
  802036:	c9                   	leave  
  802037:	c3                   	ret    

00802038 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802038:	55                   	push   %ebp
  802039:	89 e5                	mov    %esp,%ebp
  80203b:	56                   	push   %esi
  80203c:	53                   	push   %ebx
  80203d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802040:	83 ec 0c             	sub    $0xc,%esp
  802043:	ff 75 08             	pushl  0x8(%ebp)
  802046:	e8 b0 ed ff ff       	call   800dfb <fd2data>
  80204b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80204d:	83 c4 08             	add    $0x8,%esp
  802050:	68 3d 2e 80 00       	push   $0x802e3d
  802055:	53                   	push   %ebx
  802056:	e8 5d e7 ff ff       	call   8007b8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80205b:	8b 46 04             	mov    0x4(%esi),%eax
  80205e:	2b 06                	sub    (%esi),%eax
  802060:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802066:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80206d:	00 00 00 
	stat->st_dev = &devpipe;
  802070:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  802077:	30 80 00 
	return 0;
}
  80207a:	b8 00 00 00 00       	mov    $0x0,%eax
  80207f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802082:	5b                   	pop    %ebx
  802083:	5e                   	pop    %esi
  802084:	5d                   	pop    %ebp
  802085:	c3                   	ret    

00802086 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802086:	55                   	push   %ebp
  802087:	89 e5                	mov    %esp,%ebp
  802089:	53                   	push   %ebx
  80208a:	83 ec 0c             	sub    $0xc,%esp
  80208d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802090:	53                   	push   %ebx
  802091:	6a 00                	push   $0x0
  802093:	e8 a8 eb ff ff       	call   800c40 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802098:	89 1c 24             	mov    %ebx,(%esp)
  80209b:	e8 5b ed ff ff       	call   800dfb <fd2data>
  8020a0:	83 c4 08             	add    $0x8,%esp
  8020a3:	50                   	push   %eax
  8020a4:	6a 00                	push   $0x0
  8020a6:	e8 95 eb ff ff       	call   800c40 <sys_page_unmap>
}
  8020ab:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020ae:	c9                   	leave  
  8020af:	c3                   	ret    

008020b0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  8020b0:	55                   	push   %ebp
  8020b1:	89 e5                	mov    %esp,%ebp
  8020b3:	57                   	push   %edi
  8020b4:	56                   	push   %esi
  8020b5:	53                   	push   %ebx
  8020b6:	83 ec 1c             	sub    $0x1c,%esp
  8020b9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8020bc:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  8020be:	a1 08 40 80 00       	mov    0x804008,%eax
  8020c3:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  8020c6:	83 ec 0c             	sub    $0xc,%esp
  8020c9:	ff 75 e0             	pushl  -0x20(%ebp)
  8020cc:	e8 3c 05 00 00       	call   80260d <pageref>
  8020d1:	89 c3                	mov    %eax,%ebx
  8020d3:	89 3c 24             	mov    %edi,(%esp)
  8020d6:	e8 32 05 00 00       	call   80260d <pageref>
  8020db:	83 c4 10             	add    $0x10,%esp
  8020de:	39 c3                	cmp    %eax,%ebx
  8020e0:	0f 94 c1             	sete   %cl
  8020e3:	0f b6 c9             	movzbl %cl,%ecx
  8020e6:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8020e9:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8020ef:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8020f2:	39 ce                	cmp    %ecx,%esi
  8020f4:	74 1b                	je     802111 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8020f6:	39 c3                	cmp    %eax,%ebx
  8020f8:	75 c4                	jne    8020be <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8020fa:	8b 42 58             	mov    0x58(%edx),%eax
  8020fd:	ff 75 e4             	pushl  -0x1c(%ebp)
  802100:	50                   	push   %eax
  802101:	56                   	push   %esi
  802102:	68 44 2e 80 00       	push   $0x802e44
  802107:	e8 a8 e0 ff ff       	call   8001b4 <cprintf>
  80210c:	83 c4 10             	add    $0x10,%esp
  80210f:	eb ad                	jmp    8020be <_pipeisclosed+0xe>
	}
}
  802111:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802117:	5b                   	pop    %ebx
  802118:	5e                   	pop    %esi
  802119:	5f                   	pop    %edi
  80211a:	5d                   	pop    %ebp
  80211b:	c3                   	ret    

0080211c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  80211c:	55                   	push   %ebp
  80211d:	89 e5                	mov    %esp,%ebp
  80211f:	57                   	push   %edi
  802120:	56                   	push   %esi
  802121:	53                   	push   %ebx
  802122:	83 ec 28             	sub    $0x28,%esp
  802125:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  802128:	56                   	push   %esi
  802129:	e8 cd ec ff ff       	call   800dfb <fd2data>
  80212e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802130:	83 c4 10             	add    $0x10,%esp
  802133:	bf 00 00 00 00       	mov    $0x0,%edi
  802138:	eb 4b                	jmp    802185 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  80213a:	89 da                	mov    %ebx,%edx
  80213c:	89 f0                	mov    %esi,%eax
  80213e:	e8 6d ff ff ff       	call   8020b0 <_pipeisclosed>
  802143:	85 c0                	test   %eax,%eax
  802145:	75 48                	jne    80218f <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  802147:	e8 50 ea ff ff       	call   800b9c <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80214c:	8b 43 04             	mov    0x4(%ebx),%eax
  80214f:	8b 0b                	mov    (%ebx),%ecx
  802151:	8d 51 20             	lea    0x20(%ecx),%edx
  802154:	39 d0                	cmp    %edx,%eax
  802156:	73 e2                	jae    80213a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802158:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80215b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80215f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802162:	89 c2                	mov    %eax,%edx
  802164:	c1 fa 1f             	sar    $0x1f,%edx
  802167:	89 d1                	mov    %edx,%ecx
  802169:	c1 e9 1b             	shr    $0x1b,%ecx
  80216c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80216f:	83 e2 1f             	and    $0x1f,%edx
  802172:	29 ca                	sub    %ecx,%edx
  802174:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802178:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80217c:	83 c0 01             	add    $0x1,%eax
  80217f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802182:	83 c7 01             	add    $0x1,%edi
  802185:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802188:	75 c2                	jne    80214c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  80218a:	8b 45 10             	mov    0x10(%ebp),%eax
  80218d:	eb 05                	jmp    802194 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80218f:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  802194:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802197:	5b                   	pop    %ebx
  802198:	5e                   	pop    %esi
  802199:	5f                   	pop    %edi
  80219a:	5d                   	pop    %ebp
  80219b:	c3                   	ret    

0080219c <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  80219c:	55                   	push   %ebp
  80219d:	89 e5                	mov    %esp,%ebp
  80219f:	57                   	push   %edi
  8021a0:	56                   	push   %esi
  8021a1:	53                   	push   %ebx
  8021a2:	83 ec 18             	sub    $0x18,%esp
  8021a5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  8021a8:	57                   	push   %edi
  8021a9:	e8 4d ec ff ff       	call   800dfb <fd2data>
  8021ae:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021b0:	83 c4 10             	add    $0x10,%esp
  8021b3:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021b8:	eb 3d                	jmp    8021f7 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  8021ba:	85 db                	test   %ebx,%ebx
  8021bc:	74 04                	je     8021c2 <devpipe_read+0x26>
				return i;
  8021be:	89 d8                	mov    %ebx,%eax
  8021c0:	eb 44                	jmp    802206 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  8021c2:	89 f2                	mov    %esi,%edx
  8021c4:	89 f8                	mov    %edi,%eax
  8021c6:	e8 e5 fe ff ff       	call   8020b0 <_pipeisclosed>
  8021cb:	85 c0                	test   %eax,%eax
  8021cd:	75 32                	jne    802201 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  8021cf:	e8 c8 e9 ff ff       	call   800b9c <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8021d4:	8b 06                	mov    (%esi),%eax
  8021d6:	3b 46 04             	cmp    0x4(%esi),%eax
  8021d9:	74 df                	je     8021ba <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021db:	99                   	cltd   
  8021dc:	c1 ea 1b             	shr    $0x1b,%edx
  8021df:	01 d0                	add    %edx,%eax
  8021e1:	83 e0 1f             	and    $0x1f,%eax
  8021e4:	29 d0                	sub    %edx,%eax
  8021e6:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8021eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021ee:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8021f1:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021f4:	83 c3 01             	add    $0x1,%ebx
  8021f7:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8021fa:	75 d8                	jne    8021d4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8021fc:	8b 45 10             	mov    0x10(%ebp),%eax
  8021ff:	eb 05                	jmp    802206 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802201:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  802206:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802209:	5b                   	pop    %ebx
  80220a:	5e                   	pop    %esi
  80220b:	5f                   	pop    %edi
  80220c:	5d                   	pop    %ebp
  80220d:	c3                   	ret    

0080220e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  80220e:	55                   	push   %ebp
  80220f:	89 e5                	mov    %esp,%ebp
  802211:	56                   	push   %esi
  802212:	53                   	push   %ebx
  802213:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  802216:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802219:	50                   	push   %eax
  80221a:	e8 f3 eb ff ff       	call   800e12 <fd_alloc>
  80221f:	83 c4 10             	add    $0x10,%esp
  802222:	89 c2                	mov    %eax,%edx
  802224:	85 c0                	test   %eax,%eax
  802226:	0f 88 2c 01 00 00    	js     802358 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80222c:	83 ec 04             	sub    $0x4,%esp
  80222f:	68 07 04 00 00       	push   $0x407
  802234:	ff 75 f4             	pushl  -0xc(%ebp)
  802237:	6a 00                	push   $0x0
  802239:	e8 7d e9 ff ff       	call   800bbb <sys_page_alloc>
  80223e:	83 c4 10             	add    $0x10,%esp
  802241:	89 c2                	mov    %eax,%edx
  802243:	85 c0                	test   %eax,%eax
  802245:	0f 88 0d 01 00 00    	js     802358 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  80224b:	83 ec 0c             	sub    $0xc,%esp
  80224e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802251:	50                   	push   %eax
  802252:	e8 bb eb ff ff       	call   800e12 <fd_alloc>
  802257:	89 c3                	mov    %eax,%ebx
  802259:	83 c4 10             	add    $0x10,%esp
  80225c:	85 c0                	test   %eax,%eax
  80225e:	0f 88 e2 00 00 00    	js     802346 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802264:	83 ec 04             	sub    $0x4,%esp
  802267:	68 07 04 00 00       	push   $0x407
  80226c:	ff 75 f0             	pushl  -0x10(%ebp)
  80226f:	6a 00                	push   $0x0
  802271:	e8 45 e9 ff ff       	call   800bbb <sys_page_alloc>
  802276:	89 c3                	mov    %eax,%ebx
  802278:	83 c4 10             	add    $0x10,%esp
  80227b:	85 c0                	test   %eax,%eax
  80227d:	0f 88 c3 00 00 00    	js     802346 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  802283:	83 ec 0c             	sub    $0xc,%esp
  802286:	ff 75 f4             	pushl  -0xc(%ebp)
  802289:	e8 6d eb ff ff       	call   800dfb <fd2data>
  80228e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802290:	83 c4 0c             	add    $0xc,%esp
  802293:	68 07 04 00 00       	push   $0x407
  802298:	50                   	push   %eax
  802299:	6a 00                	push   $0x0
  80229b:	e8 1b e9 ff ff       	call   800bbb <sys_page_alloc>
  8022a0:	89 c3                	mov    %eax,%ebx
  8022a2:	83 c4 10             	add    $0x10,%esp
  8022a5:	85 c0                	test   %eax,%eax
  8022a7:	0f 88 89 00 00 00    	js     802336 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022ad:	83 ec 0c             	sub    $0xc,%esp
  8022b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8022b3:	e8 43 eb ff ff       	call   800dfb <fd2data>
  8022b8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8022bf:	50                   	push   %eax
  8022c0:	6a 00                	push   $0x0
  8022c2:	56                   	push   %esi
  8022c3:	6a 00                	push   $0x0
  8022c5:	e8 34 e9 ff ff       	call   800bfe <sys_page_map>
  8022ca:	89 c3                	mov    %eax,%ebx
  8022cc:	83 c4 20             	add    $0x20,%esp
  8022cf:	85 c0                	test   %eax,%eax
  8022d1:	78 55                	js     802328 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8022d3:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022dc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8022de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022e1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8022e8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022ee:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022f1:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8022f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022f6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8022fd:	83 ec 0c             	sub    $0xc,%esp
  802300:	ff 75 f4             	pushl  -0xc(%ebp)
  802303:	e8 e3 ea ff ff       	call   800deb <fd2num>
  802308:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80230b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  80230d:	83 c4 04             	add    $0x4,%esp
  802310:	ff 75 f0             	pushl  -0x10(%ebp)
  802313:	e8 d3 ea ff ff       	call   800deb <fd2num>
  802318:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80231b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  80231e:	83 c4 10             	add    $0x10,%esp
  802321:	ba 00 00 00 00       	mov    $0x0,%edx
  802326:	eb 30                	jmp    802358 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  802328:	83 ec 08             	sub    $0x8,%esp
  80232b:	56                   	push   %esi
  80232c:	6a 00                	push   $0x0
  80232e:	e8 0d e9 ff ff       	call   800c40 <sys_page_unmap>
  802333:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  802336:	83 ec 08             	sub    $0x8,%esp
  802339:	ff 75 f0             	pushl  -0x10(%ebp)
  80233c:	6a 00                	push   $0x0
  80233e:	e8 fd e8 ff ff       	call   800c40 <sys_page_unmap>
  802343:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  802346:	83 ec 08             	sub    $0x8,%esp
  802349:	ff 75 f4             	pushl  -0xc(%ebp)
  80234c:	6a 00                	push   $0x0
  80234e:	e8 ed e8 ff ff       	call   800c40 <sys_page_unmap>
  802353:	83 c4 10             	add    $0x10,%esp
  802356:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802358:	89 d0                	mov    %edx,%eax
  80235a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80235d:	5b                   	pop    %ebx
  80235e:	5e                   	pop    %esi
  80235f:	5d                   	pop    %ebp
  802360:	c3                   	ret    

00802361 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802361:	55                   	push   %ebp
  802362:	89 e5                	mov    %esp,%ebp
  802364:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802367:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80236a:	50                   	push   %eax
  80236b:	ff 75 08             	pushl  0x8(%ebp)
  80236e:	e8 ee ea ff ff       	call   800e61 <fd_lookup>
  802373:	83 c4 10             	add    $0x10,%esp
  802376:	85 c0                	test   %eax,%eax
  802378:	78 18                	js     802392 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  80237a:	83 ec 0c             	sub    $0xc,%esp
  80237d:	ff 75 f4             	pushl  -0xc(%ebp)
  802380:	e8 76 ea ff ff       	call   800dfb <fd2data>
	return _pipeisclosed(fd, p);
  802385:	89 c2                	mov    %eax,%edx
  802387:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80238a:	e8 21 fd ff ff       	call   8020b0 <_pipeisclosed>
  80238f:	83 c4 10             	add    $0x10,%esp
}
  802392:	c9                   	leave  
  802393:	c3                   	ret    

00802394 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  802394:	55                   	push   %ebp
  802395:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  802397:	b8 00 00 00 00       	mov    $0x0,%eax
  80239c:	5d                   	pop    %ebp
  80239d:	c3                   	ret    

0080239e <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80239e:	55                   	push   %ebp
  80239f:	89 e5                	mov    %esp,%ebp
  8023a1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8023a4:	68 5c 2e 80 00       	push   $0x802e5c
  8023a9:	ff 75 0c             	pushl  0xc(%ebp)
  8023ac:	e8 07 e4 ff ff       	call   8007b8 <strcpy>
	return 0;
}
  8023b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8023b6:	c9                   	leave  
  8023b7:	c3                   	ret    

008023b8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8023b8:	55                   	push   %ebp
  8023b9:	89 e5                	mov    %esp,%ebp
  8023bb:	57                   	push   %edi
  8023bc:	56                   	push   %esi
  8023bd:	53                   	push   %ebx
  8023be:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023c4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023c9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023cf:	eb 2d                	jmp    8023fe <devcons_write+0x46>
		m = n - tot;
  8023d1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8023d4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8023d6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8023d9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8023de:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023e1:	83 ec 04             	sub    $0x4,%esp
  8023e4:	53                   	push   %ebx
  8023e5:	03 45 0c             	add    0xc(%ebp),%eax
  8023e8:	50                   	push   %eax
  8023e9:	57                   	push   %edi
  8023ea:	e8 5b e5 ff ff       	call   80094a <memmove>
		sys_cputs(buf, m);
  8023ef:	83 c4 08             	add    $0x8,%esp
  8023f2:	53                   	push   %ebx
  8023f3:	57                   	push   %edi
  8023f4:	e8 06 e7 ff ff       	call   800aff <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023f9:	01 de                	add    %ebx,%esi
  8023fb:	83 c4 10             	add    $0x10,%esp
  8023fe:	89 f0                	mov    %esi,%eax
  802400:	3b 75 10             	cmp    0x10(%ebp),%esi
  802403:	72 cc                	jb     8023d1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  802405:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802408:	5b                   	pop    %ebx
  802409:	5e                   	pop    %esi
  80240a:	5f                   	pop    %edi
  80240b:	5d                   	pop    %ebp
  80240c:	c3                   	ret    

0080240d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  80240d:	55                   	push   %ebp
  80240e:	89 e5                	mov    %esp,%ebp
  802410:	83 ec 08             	sub    $0x8,%esp
  802413:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  802418:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80241c:	74 2a                	je     802448 <devcons_read+0x3b>
  80241e:	eb 05                	jmp    802425 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  802420:	e8 77 e7 ff ff       	call   800b9c <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  802425:	e8 f3 e6 ff ff       	call   800b1d <sys_cgetc>
  80242a:	85 c0                	test   %eax,%eax
  80242c:	74 f2                	je     802420 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  80242e:	85 c0                	test   %eax,%eax
  802430:	78 16                	js     802448 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  802432:	83 f8 04             	cmp    $0x4,%eax
  802435:	74 0c                	je     802443 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  802437:	8b 55 0c             	mov    0xc(%ebp),%edx
  80243a:	88 02                	mov    %al,(%edx)
	return 1;
  80243c:	b8 01 00 00 00       	mov    $0x1,%eax
  802441:	eb 05                	jmp    802448 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  802443:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802448:	c9                   	leave  
  802449:	c3                   	ret    

0080244a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  80244a:	55                   	push   %ebp
  80244b:	89 e5                	mov    %esp,%ebp
  80244d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802450:	8b 45 08             	mov    0x8(%ebp),%eax
  802453:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  802456:	6a 01                	push   $0x1
  802458:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80245b:	50                   	push   %eax
  80245c:	e8 9e e6 ff ff       	call   800aff <sys_cputs>
}
  802461:	83 c4 10             	add    $0x10,%esp
  802464:	c9                   	leave  
  802465:	c3                   	ret    

00802466 <getchar>:

int
getchar(void)
{
  802466:	55                   	push   %ebp
  802467:	89 e5                	mov    %esp,%ebp
  802469:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  80246c:	6a 01                	push   $0x1
  80246e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802471:	50                   	push   %eax
  802472:	6a 00                	push   $0x0
  802474:	e8 4e ec ff ff       	call   8010c7 <read>
	if (r < 0)
  802479:	83 c4 10             	add    $0x10,%esp
  80247c:	85 c0                	test   %eax,%eax
  80247e:	78 0f                	js     80248f <getchar+0x29>
		return r;
	if (r < 1)
  802480:	85 c0                	test   %eax,%eax
  802482:	7e 06                	jle    80248a <getchar+0x24>
		return -E_EOF;
	return c;
  802484:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802488:	eb 05                	jmp    80248f <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  80248a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80248f:	c9                   	leave  
  802490:	c3                   	ret    

00802491 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802491:	55                   	push   %ebp
  802492:	89 e5                	mov    %esp,%ebp
  802494:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802497:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80249a:	50                   	push   %eax
  80249b:	ff 75 08             	pushl  0x8(%ebp)
  80249e:	e8 be e9 ff ff       	call   800e61 <fd_lookup>
  8024a3:	83 c4 10             	add    $0x10,%esp
  8024a6:	85 c0                	test   %eax,%eax
  8024a8:	78 11                	js     8024bb <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  8024aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024ad:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024b3:	39 10                	cmp    %edx,(%eax)
  8024b5:	0f 94 c0             	sete   %al
  8024b8:	0f b6 c0             	movzbl %al,%eax
}
  8024bb:	c9                   	leave  
  8024bc:	c3                   	ret    

008024bd <opencons>:

int
opencons(void)
{
  8024bd:	55                   	push   %ebp
  8024be:	89 e5                	mov    %esp,%ebp
  8024c0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8024c6:	50                   	push   %eax
  8024c7:	e8 46 e9 ff ff       	call   800e12 <fd_alloc>
  8024cc:	83 c4 10             	add    $0x10,%esp
		return r;
  8024cf:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  8024d1:	85 c0                	test   %eax,%eax
  8024d3:	78 3e                	js     802513 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024d5:	83 ec 04             	sub    $0x4,%esp
  8024d8:	68 07 04 00 00       	push   $0x407
  8024dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8024e0:	6a 00                	push   $0x0
  8024e2:	e8 d4 e6 ff ff       	call   800bbb <sys_page_alloc>
  8024e7:	83 c4 10             	add    $0x10,%esp
		return r;
  8024ea:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024ec:	85 c0                	test   %eax,%eax
  8024ee:	78 23                	js     802513 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8024f0:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024f9:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024fe:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802505:	83 ec 0c             	sub    $0xc,%esp
  802508:	50                   	push   %eax
  802509:	e8 dd e8 ff ff       	call   800deb <fd2num>
  80250e:	89 c2                	mov    %eax,%edx
  802510:	83 c4 10             	add    $0x10,%esp
}
  802513:	89 d0                	mov    %edx,%eax
  802515:	c9                   	leave  
  802516:	c3                   	ret    

00802517 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802517:	55                   	push   %ebp
  802518:	89 e5                	mov    %esp,%ebp
  80251a:	56                   	push   %esi
  80251b:	53                   	push   %ebx
  80251c:	8b 75 08             	mov    0x8(%ebp),%esi
  80251f:	8b 45 0c             	mov    0xc(%ebp),%eax
  802522:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  802525:	85 c0                	test   %eax,%eax
  802527:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80252c:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  80252f:	83 ec 0c             	sub    $0xc,%esp
  802532:	50                   	push   %eax
  802533:	e8 33 e8 ff ff       	call   800d6b <sys_ipc_recv>
  802538:	83 c4 10             	add    $0x10,%esp
  80253b:	85 c0                	test   %eax,%eax
  80253d:	79 16                	jns    802555 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  80253f:	85 f6                	test   %esi,%esi
  802541:	74 06                	je     802549 <ipc_recv+0x32>
            *from_env_store = 0;
  802543:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  802549:	85 db                	test   %ebx,%ebx
  80254b:	74 2c                	je     802579 <ipc_recv+0x62>
            *perm_store = 0;
  80254d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  802553:	eb 24                	jmp    802579 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  802555:	85 f6                	test   %esi,%esi
  802557:	74 0a                	je     802563 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  802559:	a1 08 40 80 00       	mov    0x804008,%eax
  80255e:	8b 40 74             	mov    0x74(%eax),%eax
  802561:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  802563:	85 db                	test   %ebx,%ebx
  802565:	74 0a                	je     802571 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  802567:	a1 08 40 80 00       	mov    0x804008,%eax
  80256c:	8b 40 78             	mov    0x78(%eax),%eax
  80256f:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  802571:	a1 08 40 80 00       	mov    0x804008,%eax
  802576:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  802579:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80257c:	5b                   	pop    %ebx
  80257d:	5e                   	pop    %esi
  80257e:	5d                   	pop    %ebp
  80257f:	c3                   	ret    

00802580 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802580:	55                   	push   %ebp
  802581:	89 e5                	mov    %esp,%ebp
  802583:	57                   	push   %edi
  802584:	56                   	push   %esi
  802585:	53                   	push   %ebx
  802586:	83 ec 0c             	sub    $0xc,%esp
  802589:	8b 7d 08             	mov    0x8(%ebp),%edi
  80258c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80258f:	8b 45 10             	mov    0x10(%ebp),%eax
  802592:	85 c0                	test   %eax,%eax
  802594:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802599:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80259c:	eb 1c                	jmp    8025ba <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  80259e:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8025a1:	74 12                	je     8025b5 <ipc_send+0x35>
  8025a3:	50                   	push   %eax
  8025a4:	68 68 2e 80 00       	push   $0x802e68
  8025a9:	6a 3b                	push   $0x3b
  8025ab:	68 7e 2e 80 00       	push   $0x802e7e
  8025b0:	e8 26 db ff ff       	call   8000db <_panic>
		sys_yield();
  8025b5:	e8 e2 e5 ff ff       	call   800b9c <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  8025ba:	ff 75 14             	pushl  0x14(%ebp)
  8025bd:	53                   	push   %ebx
  8025be:	56                   	push   %esi
  8025bf:	57                   	push   %edi
  8025c0:	e8 83 e7 ff ff       	call   800d48 <sys_ipc_try_send>
  8025c5:	83 c4 10             	add    $0x10,%esp
  8025c8:	85 c0                	test   %eax,%eax
  8025ca:	78 d2                	js     80259e <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  8025cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025cf:	5b                   	pop    %ebx
  8025d0:	5e                   	pop    %esi
  8025d1:	5f                   	pop    %edi
  8025d2:	5d                   	pop    %ebp
  8025d3:	c3                   	ret    

008025d4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8025d4:	55                   	push   %ebp
  8025d5:	89 e5                	mov    %esp,%ebp
  8025d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8025da:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8025df:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8025e2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8025e8:	8b 52 50             	mov    0x50(%edx),%edx
  8025eb:	39 ca                	cmp    %ecx,%edx
  8025ed:	75 0d                	jne    8025fc <ipc_find_env+0x28>
			return envs[i].env_id;
  8025ef:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025f2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025f7:	8b 40 48             	mov    0x48(%eax),%eax
  8025fa:	eb 0f                	jmp    80260b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025fc:	83 c0 01             	add    $0x1,%eax
  8025ff:	3d 00 04 00 00       	cmp    $0x400,%eax
  802604:	75 d9                	jne    8025df <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802606:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80260b:	5d                   	pop    %ebp
  80260c:	c3                   	ret    

0080260d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80260d:	55                   	push   %ebp
  80260e:	89 e5                	mov    %esp,%ebp
  802610:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802613:	89 d0                	mov    %edx,%eax
  802615:	c1 e8 16             	shr    $0x16,%eax
  802618:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80261f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802624:	f6 c1 01             	test   $0x1,%cl
  802627:	74 1d                	je     802646 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802629:	c1 ea 0c             	shr    $0xc,%edx
  80262c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802633:	f6 c2 01             	test   $0x1,%dl
  802636:	74 0e                	je     802646 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802638:	c1 ea 0c             	shr    $0xc,%edx
  80263b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802642:	ef 
  802643:	0f b7 c0             	movzwl %ax,%eax
}
  802646:	5d                   	pop    %ebp
  802647:	c3                   	ret    
  802648:	66 90                	xchg   %ax,%ax
  80264a:	66 90                	xchg   %ax,%ax
  80264c:	66 90                	xchg   %ax,%ax
  80264e:	66 90                	xchg   %ax,%ax

00802650 <__udivdi3>:
  802650:	55                   	push   %ebp
  802651:	57                   	push   %edi
  802652:	56                   	push   %esi
  802653:	53                   	push   %ebx
  802654:	83 ec 1c             	sub    $0x1c,%esp
  802657:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80265b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80265f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802663:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802667:	85 f6                	test   %esi,%esi
  802669:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80266d:	89 ca                	mov    %ecx,%edx
  80266f:	89 f8                	mov    %edi,%eax
  802671:	75 3d                	jne    8026b0 <__udivdi3+0x60>
  802673:	39 cf                	cmp    %ecx,%edi
  802675:	0f 87 c5 00 00 00    	ja     802740 <__udivdi3+0xf0>
  80267b:	85 ff                	test   %edi,%edi
  80267d:	89 fd                	mov    %edi,%ebp
  80267f:	75 0b                	jne    80268c <__udivdi3+0x3c>
  802681:	b8 01 00 00 00       	mov    $0x1,%eax
  802686:	31 d2                	xor    %edx,%edx
  802688:	f7 f7                	div    %edi
  80268a:	89 c5                	mov    %eax,%ebp
  80268c:	89 c8                	mov    %ecx,%eax
  80268e:	31 d2                	xor    %edx,%edx
  802690:	f7 f5                	div    %ebp
  802692:	89 c1                	mov    %eax,%ecx
  802694:	89 d8                	mov    %ebx,%eax
  802696:	89 cf                	mov    %ecx,%edi
  802698:	f7 f5                	div    %ebp
  80269a:	89 c3                	mov    %eax,%ebx
  80269c:	89 d8                	mov    %ebx,%eax
  80269e:	89 fa                	mov    %edi,%edx
  8026a0:	83 c4 1c             	add    $0x1c,%esp
  8026a3:	5b                   	pop    %ebx
  8026a4:	5e                   	pop    %esi
  8026a5:	5f                   	pop    %edi
  8026a6:	5d                   	pop    %ebp
  8026a7:	c3                   	ret    
  8026a8:	90                   	nop
  8026a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8026b0:	39 ce                	cmp    %ecx,%esi
  8026b2:	77 74                	ja     802728 <__udivdi3+0xd8>
  8026b4:	0f bd fe             	bsr    %esi,%edi
  8026b7:	83 f7 1f             	xor    $0x1f,%edi
  8026ba:	0f 84 98 00 00 00    	je     802758 <__udivdi3+0x108>
  8026c0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8026c5:	89 f9                	mov    %edi,%ecx
  8026c7:	89 c5                	mov    %eax,%ebp
  8026c9:	29 fb                	sub    %edi,%ebx
  8026cb:	d3 e6                	shl    %cl,%esi
  8026cd:	89 d9                	mov    %ebx,%ecx
  8026cf:	d3 ed                	shr    %cl,%ebp
  8026d1:	89 f9                	mov    %edi,%ecx
  8026d3:	d3 e0                	shl    %cl,%eax
  8026d5:	09 ee                	or     %ebp,%esi
  8026d7:	89 d9                	mov    %ebx,%ecx
  8026d9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026dd:	89 d5                	mov    %edx,%ebp
  8026df:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026e3:	d3 ed                	shr    %cl,%ebp
  8026e5:	89 f9                	mov    %edi,%ecx
  8026e7:	d3 e2                	shl    %cl,%edx
  8026e9:	89 d9                	mov    %ebx,%ecx
  8026eb:	d3 e8                	shr    %cl,%eax
  8026ed:	09 c2                	or     %eax,%edx
  8026ef:	89 d0                	mov    %edx,%eax
  8026f1:	89 ea                	mov    %ebp,%edx
  8026f3:	f7 f6                	div    %esi
  8026f5:	89 d5                	mov    %edx,%ebp
  8026f7:	89 c3                	mov    %eax,%ebx
  8026f9:	f7 64 24 0c          	mull   0xc(%esp)
  8026fd:	39 d5                	cmp    %edx,%ebp
  8026ff:	72 10                	jb     802711 <__udivdi3+0xc1>
  802701:	8b 74 24 08          	mov    0x8(%esp),%esi
  802705:	89 f9                	mov    %edi,%ecx
  802707:	d3 e6                	shl    %cl,%esi
  802709:	39 c6                	cmp    %eax,%esi
  80270b:	73 07                	jae    802714 <__udivdi3+0xc4>
  80270d:	39 d5                	cmp    %edx,%ebp
  80270f:	75 03                	jne    802714 <__udivdi3+0xc4>
  802711:	83 eb 01             	sub    $0x1,%ebx
  802714:	31 ff                	xor    %edi,%edi
  802716:	89 d8                	mov    %ebx,%eax
  802718:	89 fa                	mov    %edi,%edx
  80271a:	83 c4 1c             	add    $0x1c,%esp
  80271d:	5b                   	pop    %ebx
  80271e:	5e                   	pop    %esi
  80271f:	5f                   	pop    %edi
  802720:	5d                   	pop    %ebp
  802721:	c3                   	ret    
  802722:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802728:	31 ff                	xor    %edi,%edi
  80272a:	31 db                	xor    %ebx,%ebx
  80272c:	89 d8                	mov    %ebx,%eax
  80272e:	89 fa                	mov    %edi,%edx
  802730:	83 c4 1c             	add    $0x1c,%esp
  802733:	5b                   	pop    %ebx
  802734:	5e                   	pop    %esi
  802735:	5f                   	pop    %edi
  802736:	5d                   	pop    %ebp
  802737:	c3                   	ret    
  802738:	90                   	nop
  802739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802740:	89 d8                	mov    %ebx,%eax
  802742:	f7 f7                	div    %edi
  802744:	31 ff                	xor    %edi,%edi
  802746:	89 c3                	mov    %eax,%ebx
  802748:	89 d8                	mov    %ebx,%eax
  80274a:	89 fa                	mov    %edi,%edx
  80274c:	83 c4 1c             	add    $0x1c,%esp
  80274f:	5b                   	pop    %ebx
  802750:	5e                   	pop    %esi
  802751:	5f                   	pop    %edi
  802752:	5d                   	pop    %ebp
  802753:	c3                   	ret    
  802754:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802758:	39 ce                	cmp    %ecx,%esi
  80275a:	72 0c                	jb     802768 <__udivdi3+0x118>
  80275c:	31 db                	xor    %ebx,%ebx
  80275e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802762:	0f 87 34 ff ff ff    	ja     80269c <__udivdi3+0x4c>
  802768:	bb 01 00 00 00       	mov    $0x1,%ebx
  80276d:	e9 2a ff ff ff       	jmp    80269c <__udivdi3+0x4c>
  802772:	66 90                	xchg   %ax,%ax
  802774:	66 90                	xchg   %ax,%ax
  802776:	66 90                	xchg   %ax,%ax
  802778:	66 90                	xchg   %ax,%ax
  80277a:	66 90                	xchg   %ax,%ax
  80277c:	66 90                	xchg   %ax,%ax
  80277e:	66 90                	xchg   %ax,%ax

00802780 <__umoddi3>:
  802780:	55                   	push   %ebp
  802781:	57                   	push   %edi
  802782:	56                   	push   %esi
  802783:	53                   	push   %ebx
  802784:	83 ec 1c             	sub    $0x1c,%esp
  802787:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80278b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80278f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802793:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802797:	85 d2                	test   %edx,%edx
  802799:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80279d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8027a1:	89 f3                	mov    %esi,%ebx
  8027a3:	89 3c 24             	mov    %edi,(%esp)
  8027a6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8027aa:	75 1c                	jne    8027c8 <__umoddi3+0x48>
  8027ac:	39 f7                	cmp    %esi,%edi
  8027ae:	76 50                	jbe    802800 <__umoddi3+0x80>
  8027b0:	89 c8                	mov    %ecx,%eax
  8027b2:	89 f2                	mov    %esi,%edx
  8027b4:	f7 f7                	div    %edi
  8027b6:	89 d0                	mov    %edx,%eax
  8027b8:	31 d2                	xor    %edx,%edx
  8027ba:	83 c4 1c             	add    $0x1c,%esp
  8027bd:	5b                   	pop    %ebx
  8027be:	5e                   	pop    %esi
  8027bf:	5f                   	pop    %edi
  8027c0:	5d                   	pop    %ebp
  8027c1:	c3                   	ret    
  8027c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8027c8:	39 f2                	cmp    %esi,%edx
  8027ca:	89 d0                	mov    %edx,%eax
  8027cc:	77 52                	ja     802820 <__umoddi3+0xa0>
  8027ce:	0f bd ea             	bsr    %edx,%ebp
  8027d1:	83 f5 1f             	xor    $0x1f,%ebp
  8027d4:	75 5a                	jne    802830 <__umoddi3+0xb0>
  8027d6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8027da:	0f 82 e0 00 00 00    	jb     8028c0 <__umoddi3+0x140>
  8027e0:	39 0c 24             	cmp    %ecx,(%esp)
  8027e3:	0f 86 d7 00 00 00    	jbe    8028c0 <__umoddi3+0x140>
  8027e9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027ed:	8b 54 24 04          	mov    0x4(%esp),%edx
  8027f1:	83 c4 1c             	add    $0x1c,%esp
  8027f4:	5b                   	pop    %ebx
  8027f5:	5e                   	pop    %esi
  8027f6:	5f                   	pop    %edi
  8027f7:	5d                   	pop    %ebp
  8027f8:	c3                   	ret    
  8027f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802800:	85 ff                	test   %edi,%edi
  802802:	89 fd                	mov    %edi,%ebp
  802804:	75 0b                	jne    802811 <__umoddi3+0x91>
  802806:	b8 01 00 00 00       	mov    $0x1,%eax
  80280b:	31 d2                	xor    %edx,%edx
  80280d:	f7 f7                	div    %edi
  80280f:	89 c5                	mov    %eax,%ebp
  802811:	89 f0                	mov    %esi,%eax
  802813:	31 d2                	xor    %edx,%edx
  802815:	f7 f5                	div    %ebp
  802817:	89 c8                	mov    %ecx,%eax
  802819:	f7 f5                	div    %ebp
  80281b:	89 d0                	mov    %edx,%eax
  80281d:	eb 99                	jmp    8027b8 <__umoddi3+0x38>
  80281f:	90                   	nop
  802820:	89 c8                	mov    %ecx,%eax
  802822:	89 f2                	mov    %esi,%edx
  802824:	83 c4 1c             	add    $0x1c,%esp
  802827:	5b                   	pop    %ebx
  802828:	5e                   	pop    %esi
  802829:	5f                   	pop    %edi
  80282a:	5d                   	pop    %ebp
  80282b:	c3                   	ret    
  80282c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802830:	8b 34 24             	mov    (%esp),%esi
  802833:	bf 20 00 00 00       	mov    $0x20,%edi
  802838:	89 e9                	mov    %ebp,%ecx
  80283a:	29 ef                	sub    %ebp,%edi
  80283c:	d3 e0                	shl    %cl,%eax
  80283e:	89 f9                	mov    %edi,%ecx
  802840:	89 f2                	mov    %esi,%edx
  802842:	d3 ea                	shr    %cl,%edx
  802844:	89 e9                	mov    %ebp,%ecx
  802846:	09 c2                	or     %eax,%edx
  802848:	89 d8                	mov    %ebx,%eax
  80284a:	89 14 24             	mov    %edx,(%esp)
  80284d:	89 f2                	mov    %esi,%edx
  80284f:	d3 e2                	shl    %cl,%edx
  802851:	89 f9                	mov    %edi,%ecx
  802853:	89 54 24 04          	mov    %edx,0x4(%esp)
  802857:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80285b:	d3 e8                	shr    %cl,%eax
  80285d:	89 e9                	mov    %ebp,%ecx
  80285f:	89 c6                	mov    %eax,%esi
  802861:	d3 e3                	shl    %cl,%ebx
  802863:	89 f9                	mov    %edi,%ecx
  802865:	89 d0                	mov    %edx,%eax
  802867:	d3 e8                	shr    %cl,%eax
  802869:	89 e9                	mov    %ebp,%ecx
  80286b:	09 d8                	or     %ebx,%eax
  80286d:	89 d3                	mov    %edx,%ebx
  80286f:	89 f2                	mov    %esi,%edx
  802871:	f7 34 24             	divl   (%esp)
  802874:	89 d6                	mov    %edx,%esi
  802876:	d3 e3                	shl    %cl,%ebx
  802878:	f7 64 24 04          	mull   0x4(%esp)
  80287c:	39 d6                	cmp    %edx,%esi
  80287e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802882:	89 d1                	mov    %edx,%ecx
  802884:	89 c3                	mov    %eax,%ebx
  802886:	72 08                	jb     802890 <__umoddi3+0x110>
  802888:	75 11                	jne    80289b <__umoddi3+0x11b>
  80288a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80288e:	73 0b                	jae    80289b <__umoddi3+0x11b>
  802890:	2b 44 24 04          	sub    0x4(%esp),%eax
  802894:	1b 14 24             	sbb    (%esp),%edx
  802897:	89 d1                	mov    %edx,%ecx
  802899:	89 c3                	mov    %eax,%ebx
  80289b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80289f:	29 da                	sub    %ebx,%edx
  8028a1:	19 ce                	sbb    %ecx,%esi
  8028a3:	89 f9                	mov    %edi,%ecx
  8028a5:	89 f0                	mov    %esi,%eax
  8028a7:	d3 e0                	shl    %cl,%eax
  8028a9:	89 e9                	mov    %ebp,%ecx
  8028ab:	d3 ea                	shr    %cl,%edx
  8028ad:	89 e9                	mov    %ebp,%ecx
  8028af:	d3 ee                	shr    %cl,%esi
  8028b1:	09 d0                	or     %edx,%eax
  8028b3:	89 f2                	mov    %esi,%edx
  8028b5:	83 c4 1c             	add    $0x1c,%esp
  8028b8:	5b                   	pop    %ebx
  8028b9:	5e                   	pop    %esi
  8028ba:	5f                   	pop    %edi
  8028bb:	5d                   	pop    %ebp
  8028bc:	c3                   	ret    
  8028bd:	8d 76 00             	lea    0x0(%esi),%esi
  8028c0:	29 f9                	sub    %edi,%ecx
  8028c2:	19 d6                	sbb    %edx,%esi
  8028c4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8028c8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8028cc:	e9 18 ff ff ff       	jmp    8027e9 <__umoddi3+0x69>
